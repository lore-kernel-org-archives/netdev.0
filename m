From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 02/10 net-next] l2tp: Use ip4_datagram_connect() in l2tp_ip_connect()
Date: Mon, 30 Apr 2012 08:48:47 +0100
Message-ID: <1335772135-27910-3-git-send-email-jchapman@katalix.com>
References: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53474 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839Ab2D3Hs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 03:48:58 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id E5538A620FC
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 08:48:56 +0100 (BST)
In-Reply-To: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup the l2tp_ip code to make use of an existing ipv4 support function.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip.c |   54 ++++++---------------------------------------------
 1 files changed, 7 insertions(+), 47 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 585d93e..5162592 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -299,67 +299,27 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 {
 	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
 	struct inet_sock *inet = inet_sk(sk);
-	struct flowi4 *fl4;
-	struct rtable *rt;
-	__be32 saddr;
-	int oif, rc;
+	int rc;
 
-	rc = -EINVAL;
 	if (addr_len < sizeof(*lsa))
-		goto out;
+		return -EINVAL;
 
-	rc = -EAFNOSUPPORT;
-	if (lsa->l2tp_family != AF_INET)
-		goto out;
-
-	lock_sock(sk);
-
-	sk_dst_reset(sk);
-
-	oif = sk->sk_bound_dev_if;
-	saddr = inet->inet_saddr;
-
-	rc = -EINVAL;
 	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
-		goto out;
+		return -EINVAL;
 
-	fl4 = &inet->cork.fl.u.ip4;
-	rt = ip_route_connect(fl4, lsa->l2tp_addr.s_addr, saddr,
-			      RT_CONN_FLAGS(sk), oif,
-			      IPPROTO_L2TP,
-			      0, 0, sk, true);
-	if (IS_ERR(rt)) {
-		rc = PTR_ERR(rt);
-		if (rc == -ENETUNREACH)
-			IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
-		goto out;
-	}
+	rc = ip4_datagram_connect(sk, uaddr, addr_len);
+	if (rc < 0)
+		return rc;
 
-	rc = -ENETUNREACH;
-	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
-		ip_rt_put(rt);
-		goto out;
-	}
+	lock_sock(sk);
 
 	l2tp_ip_sk(sk)->peer_conn_id = lsa->l2tp_conn_id;
 
-	if (!inet->inet_saddr)
-		inet->inet_saddr = fl4->saddr;
-	if (!inet->inet_rcv_saddr)
-		inet->inet_rcv_saddr = fl4->saddr;
-	inet->inet_daddr = fl4->daddr;
-	sk->sk_state = TCP_ESTABLISHED;
-	inet->inet_id = jiffies;
-
-	sk_dst_set(sk, &rt->dst);
-
 	write_lock_bh(&l2tp_ip_lock);
 	hlist_del_init(&sk->sk_bind_node);
 	sk_add_bind_node(sk, &l2tp_ip_bind_table);
 	write_unlock_bh(&l2tp_ip_lock);
 
-	rc = 0;
-out:
 	release_sock(sk);
 	return rc;
 }
-- 
1.7.0.4
