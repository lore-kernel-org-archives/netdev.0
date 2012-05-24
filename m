From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: take care of overlaps in tcp_try_coalesce()
Date: Thu, 24 May 2012 05:51:37 +0200
Message-ID: <1337831497.3361.3888.camel@edumazet-glaptop>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
	 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
	 <1337697203.3361.190.camel@edumazet-glaptop>
	 <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
	 <1337785681.3361.2923.camel@edumazet-glaptop>
	 <CAJyhjX02wjsVE2pM26a+7xTrAJwvLZo0UL-W6h8zMKEiC5qTug@mail.gmail.com>
	 <1337791018.3361.3024.camel@edumazet-glaptop>
	 <CAJyhjX1E_yzT1Vte+3iqc-PnfLiEEdFEyM9GcOCs-6TrUm86XQ@mail.gmail.com>
	 <1337798274.3361.3234.camel@edumazet-glaptop>
	 <CAJyhjX1UW=N0B9GFMt_u_gFEsLH2=8OJx0N7zJWVCrpic5Z9kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergio Correia <lists@uece.net>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41245 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430Ab2EXDvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 23:51:41 -0400
Received: by eeit10 with SMTP id t10so2291922eei.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 20:51:40 -0700 (PDT)
In-Reply-To: <CAJyhjX1UW=N0B9GFMt_u_gFEsLH2=8OJx0N7zJWVCrpic5Z9kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Thu, 2012-05-24 at 00:21 -0300, Sergio Correia wrote:

> With your patch applied, the warning hasn't shown up in the last
> hours. Without it, dmesg would have been completely taken by them by
> now.
> I might be able to reproduce your test setup tomorrow, and if so, I will retest.
> 

I am going to send an official patch right now.

My own testings confirmed the bug origin and I am confident the patch is
OK.

Thanks !

[PATCH] tcp: take care of overlaps in tcp_try_coalesce()

Sergio Correia reported following warning :

WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()

WARN(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq),
     "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
     tp->copied_seq, TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt);

It appears TCP coalescing, and more specifically commit b081f85c297
(net: implement tcp coalescing in tcp_queue_rcv()) should take care of
possible segment overlaps in receive queue. This was properly done in
the case of out_or_order_queue by the caller.

For example, segment at tail of queue have sequence 1000-2000, and we
add a segment with sequence 1500-2500.
This can happen in case of retransmits.

In this case, just don't do the coalescing.

Reported-by: Sergio Correia <lists@uece.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Sergio Correia <lists@uece.net>
---
 net/ipv4/tcp_input.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cfa2aa1..b224eb8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4555,6 +4555,11 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	if (tcp_hdr(from)->fin)
 		return false;
+
+	/* Its possible this segment overlaps with prior segment in queue */
+	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
+		return false;
+
 	if (!skb_try_coalesce(to, from, fragstolen, &delta))
 		return false;
 
