From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/15] ipv4: Lock socket and use cork flow in
 ip4_datagram_connect().
Date: Sun, 08 May 2011 15:37:31 -0700 (PDT)
Message-ID: <20110508.153731.39162029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718Ab1EHWiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3031624C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is to make sure that an l2tp socket's inet cork flow is
fully filled in, when it's encapsulated in UDP.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/datagram.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index d5a2e69..424fafb 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -24,7 +24,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *) uaddr;
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	struct rtable *rt;
 	__be32 saddr;
 	int oif;
@@ -39,6 +39,8 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	sk_dst_reset(sk);
 
+	lock_sock(sk);
+
 	oif = sk->sk_bound_dev_if;
 	saddr = inet->inet_saddr;
 	if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
@@ -47,7 +49,8 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		if (!saddr)
 			saddr = inet->mc_addr;
 	}
-	rt = ip_route_connect(&fl4, usin->sin_addr.s_addr, saddr,
+	fl4 = &inet->cork.fl.u.ip4;
+	rt = ip_route_connect(fl4, usin->sin_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      sk->sk_protocol,
 			      inet->inet_sport, usin->sin_port, sk, true);
@@ -55,26 +58,30 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
-		return err;
+		goto out;
 	}
 
 	if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
 		ip_rt_put(rt);
-		return -EACCES;
+		err = -EACCES;
+		goto out;
 	}
 	if (!inet->inet_saddr)
-		inet->inet_saddr = fl4.saddr;	/* Update source address */
+		inet->inet_saddr = fl4->saddr;	/* Update source address */
 	if (!inet->inet_rcv_saddr) {
-		inet->inet_rcv_saddr = fl4.saddr;
+		inet->inet_rcv_saddr = fl4->saddr;
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
 	}
-	inet->inet_daddr = fl4.daddr;
+	inet->inet_daddr = fl4->daddr;
 	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
 
 	sk_dst_set(sk, &rt->dst);
-	return 0;
+	err = 0;
+out:
+	release_sock(sk);
+	return err;
 }
 EXPORT_SYMBOL(ip4_datagram_connect);
-- 
1.7.5.1

