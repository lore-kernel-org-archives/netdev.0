From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v3 1/4] ip: Move checksum convert defines to inet
Date: Mon,  5 Jan 2015 13:56:14 -0800
Message-ID: <1420494977-15026-2-git-send-email-therbert@google.com>
References: <1420494977-15026-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:62807 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbbAEV43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:56:29 -0500
Received: by mail-ig0-f181.google.com with SMTP id a13so43848igq.2
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 13:56:29 -0800 (PST)
In-Reply-To: <1420494977-15026-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move convert_csum from udp_sock to inet_sock. This allows the
possibility that we can use convert checksum for different types
of sockets and also allows convert checksum to be enabled from
inet layer (what we'll want to do when enabling IP_CHECKSUM cmsg).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/udp.h     | 16 +---------------
 include/net/inet_sock.h | 17 +++++++++++++++++
 net/ipv4/fou.c          |  2 +-
 net/ipv4/udp.c          |  2 +-
 net/ipv4/udp_tunnel.c   |  2 +-
 net/ipv6/udp.c          |  2 +-
 6 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index ee32775..247cfdc 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -49,11 +49,7 @@ struct udp_sock {
 	unsigned int	 corkflag;	/* Cork is required */
 	__u8		 encap_type;	/* Is this an Encapsulation socket? */
 	unsigned char	 no_check6_tx:1,/* Send zero UDP6 checksums on TX? */
-			 no_check6_rx:1,/* Allow zero UDP6 checksums on RX? */
-			 convert_csum:1;/* On receive, convert checksum
-					 * unnecessary to checksum complete
-					 * if possible.
-					 */
+			 no_check6_rx:1;/* Allow zero UDP6 checksums on RX? */
 	/*
 	 * Following member retains the information to create a UDP header
 	 * when the socket is uncorked.
@@ -102,16 +98,6 @@ static inline bool udp_get_no_check6_rx(struct sock *sk)
 	return udp_sk(sk)->no_check6_rx;
 }
 
-static inline void udp_set_convert_csum(struct sock *sk, bool val)
-{
-	udp_sk(sk)->convert_csum = val;
-}
-
-static inline bool udp_get_convert_csum(struct sock *sk)
-{
-	return udp_sk(sk)->convert_csum;
-}
-
 #define udp_portaddr_for_each_entry(__sk, node, list) \
 	hlist_nulls_for_each_entry(__sk, node, list, __sk_common.skc_portaddr_node)
 
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index a829b77..360b110 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -184,6 +184,7 @@ struct inet_sock {
 				mc_all:1,
 				nodefrag:1;
 	__u8			rcv_tos;
+	__u8			convert_csum;
 	int			uc_index;
 	int			mc_index;
 	__be32			mc_addr;
@@ -250,4 +251,20 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return flags;
 }
 
+static inline void inet_inc_convert_csum(struct sock *sk)
+{
+	inet_sk(sk)->convert_csum++;
+}
+
+static inline void inet_dec_convert_csum(struct sock *sk)
+{
+	if (inet_sk(sk)->convert_csum > 0)
+		inet_sk(sk)->convert_csum--;
+}
+
+static inline bool inet_get_convert_csum(struct sock *sk)
+{
+	return !!inet_sk(sk)->convert_csum;
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index b986298..2197c36 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -490,7 +490,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 	sk->sk_user_data = fou;
 	fou->sock = sock;
 
-	udp_set_convert_csum(sk, true);
+	inet_inc_convert_csum(sk);
 
 	sk->sk_allocation = GFP_ATOMIC;
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 13b4dcf..53358d8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1806,7 +1806,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
-		if (udp_sk(sk)->convert_csum && uh->check && !IS_UDPLITE(sk))
+		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 inet_compute_pseudo);
 
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 1671263..9996e63 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -63,7 +63,7 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 	inet_sk(sk)->mc_loop = 0;
 
 	/* Enable CHECKSUM_UNNECESSARY to CHECKSUM_COMPLETE conversion */
-	udp_set_convert_csum(sk, true);
+	inet_inc_convert_csum(sk);
 
 	rcu_assign_sk_user_data(sk, cfg->sk_user_data);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 189dc4a..e41f017 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -909,7 +909,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			goto csum_error;
 		}
 
-		if (udp_sk(sk)->convert_csum && uh->check && !IS_UDPLITE(sk))
+		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 ip6_compute_pseudo);
 
-- 
2.2.0.rc0.207.ga3a616c
