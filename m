From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/8] tipc: compensate for double accounting
 in socket rcv buffer
Date: Wed, 14 May 2014 12:42:11 -0700
Message-ID: <1400096531.7973.123.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
		 <1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>
		 <1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>
		 <A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
	 <1400089542.7973.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5373BD5C.9030703@donjonn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:61981 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbaENTmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:42:12 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so25620pbb.17
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 12:42:11 -0700 (PDT)
In-Reply-To: <5373BD5C.9030703@donjonn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 15:00 -0400, Jon Maloy wrote:

> This is where I don't get it.
> 
> sk_add_backlog(limit) is (via sk_rcvqueues_full) testing for
> 
>  (sk_backlog.len + sk_rmem_alloc) > limit
> 
> But, if the receiving user is slow, sk_rmem_alloc will run full eventually, even if we
> reduce sk_backlog.len with truesize of each transferred buffer, and sk_add_backlog
> should then start throwing away packets. Why doesn't this happen?

It definitely can happen if sender tries to send small packets, that
have a high truesize/len ratio.

$ nstat -a | egrep "TcpExtTCPBacklogDrop|IpInReceives|TcpExtTCPRcvCoalesce"
IpInReceives                    8357544624         0.0
TcpExtTCPBacklogDrop            13                 0.0
TcpExtTCPRcvCoalesce            437826621          0.0

You claim that "that sk_backlog.len does not
give correct information about the buffer situation.", but really it
does.

Your problem seems that you do not use the appropriate 'limit',
or assume very tight scheduling constraints (An incoming packet has to
be immediately consumed by receiver, otherwise following packet might be
dropped)

If rcvbuf_limit(sk, buf) is the limit for normal packets (sk_rmem_alloc)
in receive queue, then you need something bigger to allow bursts.


diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3f9912f87d0d..fe4f37d8029a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1457,7 +1457,7 @@ u32 tipc_sk_rcv(struct sock *sk, struct sk_buff *buf)
 	if (!sock_owned_by_user(sk)) {
 		res = filter_rcv(sk, buf);
 	} else {
-		if (sk_add_backlog(sk, buf, rcvbuf_limit(sk, buf)))
+		if (sk_add_backlog(sk, buf, 2 * rcvbuf_limit(sk, buf)))
 			res = TIPC_ERR_OVERLOAD;
 		else
 			res = TIPC_OK;
