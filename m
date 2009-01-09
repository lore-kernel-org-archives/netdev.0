From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 23:07:38 +0100
Message-ID: <20090109220737.GA4111@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1336 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758862AbZAIWHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:07:55 -0500
Content-Disposition: inline
In-Reply-To: <20090109212400.GA3727@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 10:24:00PM +0100, Willy Tarreau wrote:
> On Fri, Jan 09, 2009 at 09:51:17PM +0100, Eric Dumazet wrote:
> (...)
> > > Also, in your second mail, you're saying that your change
> > > might return more data than requested by the user. I can't
> > > find why, could you please explain to me, as I'm still quite
> > > ignorant in this area ?
> > 
> > Well, I just tested various user programs and indeed got this
> > strange result :
> > 
> > Here I call splice() with len=1000 (0x3e8), and you can see
> > it gives a result of 1460 at the second call.

OK finally I could reproduce it and found why we have this. It's
expected in fact.

The problem when we loop in tcp_read_sock() is that tss->len is
not decremented by the amount of bytes read, this one is done
only in tcp_splice_read() which is outer.

The solution I found was to do just like other callers, which means
use desc->count to keep the remaining number of bytes we want to
read. In fact, tcp_read_sock() is designed to use that one as a stop
condition, which explains why you first had to hide it.

Now with the attached patch as a replacement for my previous one,
both issues are solved :
  - I splice 1000 bytes if I ask to do so
  - I splice as much as possible if available (typically 23 kB).

My observed performances are still at the top of earlier results
and IMHO that way of counting bytes makes sense for an actor called
from tcp_read_sock().

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 35bcddf..51ff3aa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -522,8 +522,12 @@ static int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 				unsigned int offset, size_t len)
 {
 	struct tcp_splice_state *tss = rd_desc->arg.data;
+	int ret;
 
-	return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss->flags);
+	ret = skb_splice_bits(skb, offset, tss->pipe, rd_desc->count, tss->flags);
+	if (ret > 0)
+		rd_desc->count -= ret;
+	return ret;
 }
 
 static int __tcp_splice_read(struct sock *sk, struct tcp_splice_state *tss)
@@ -531,6 +535,7 @@ static int __tcp_splice_read(struct sock *sk, struct tcp_splice_state *tss)
 	/* Store TCP splice context information in read_descriptor_t. */
 	read_descriptor_t rd_desc = {
 		.arg.data = tss,
+		.count = tss->len,
 	};
 
 	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);

Regards,
Willy

