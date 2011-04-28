From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: add RCU protection to inet->opt
Date: Thu, 28 Apr 2011 13:20:32 -0700 (PDT)
Message-ID: <20110428.132032.115947683.davem@davemloft.net>
References: <1302881994.3613.34.camel@edumazet-laptop>
	<1303415137.2784.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932917Ab1D1UVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:21:05 -0400
In-Reply-To: <1303415137.2784.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Apr 2011 21:45:37 +0200

> [PATCH] inet: add RCU protection to inet->opt

Applied, although I had to add the following build fix to the
final commit:

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index cc67367..962a607 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -416,7 +416,6 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	int rc;
 	struct l2tp_ip_sock *lsa = l2tp_ip_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	struct ip_options *opt = inet->opt;
 	struct rtable *rt = NULL;
 	int connected = 0;
 	__be32 daddr;
@@ -471,9 +470,14 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		rt = (struct rtable *) __sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
+		struct ip_options_rcu *inet_opt;
+
+		inet_opt = rcu_dereference_protected(inet->inet_opt,
+						     sock_owned_by_user(sk));
+
 		/* Use correct destination address if we have options. */
-		if (opt && opt->srr)
-			daddr = opt->faddr;
+		if (inet_opt && inet_opt->opt.srr)
+			daddr = inet_opt->opt.faddr;
 
 		/* If this fails, retransmit mechanism of transport layer will
 		 * keep trying until route appears or the connection times
