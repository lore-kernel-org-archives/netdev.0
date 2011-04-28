From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: add RCU protection to inet->opt
Date: Thu, 28 Apr 2011 13:52:26 -0700 (PDT)
Message-ID: <20110428.135226.242113407.davem@davemloft.net>
References: <1303415137.2784.23.camel@edumazet-laptop>
	<20110428.132032.115947683.davem@davemloft.net>
	<1304023759.2954.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933481Ab1D1Uw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:52:59 -0400
In-Reply-To: <1304023759.2954.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Apr 2011 22:49:19 +0200

> Are you sure socket is locked at this point ? ( by a priori call to
> lock_sock())

Ugh, it's not, I'll commit this fix which is safe because we're only
peeking at inet_opt to fetch the faddr value then we never reference
it again:

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 962a607..e13c166 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -472,13 +472,15 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	if (rt == NULL) {
 		struct ip_options_rcu *inet_opt;
 
-		inet_opt = rcu_dereference_protected(inet->inet_opt,
-						     sock_owned_by_user(sk));
+		rcu_read_lock();
+		inet_opt = rcu_dereference(inet->inet_opt);
 
 		/* Use correct destination address if we have options. */
 		if (inet_opt && inet_opt->opt.srr)
 			daddr = inet_opt->opt.faddr;
 
+		rcu_read_unlock();
+
 		/* If this fails, retransmit mechanism of transport layer will
 		 * keep trying until route appears or the connection times
 		 * itself out.
