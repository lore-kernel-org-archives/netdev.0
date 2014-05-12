From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/8] net: Make enabling of zero UDP6 csums more restrictive
Date: Mon, 12 May 2014 09:58:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405120946580.32524@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:49256 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366AbaELREO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 13:04:14 -0400
Received: by mail-qa0-f73.google.com with SMTP id hw13so1072404qab.2
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 10:04:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 6935 permits zero checksums to be used in IPv6 however this is
recommended only for certain tunnel protocols, it does not make
checksums completely optional like they are in IPv4.

This patch restricts the use of IPv6 zero checksums that was previously
intoduced. no_check6_tx and no_check6_rx have been added to control
the use of checksums in UDP6 RX and TX path. The normal
sk_no_check_{rx,tx} settings are not used (this avoids ambiguity when
dealing with a dual stack socket).

A helper function has been added (udp_set_no_check6) which can be
called by tunnel impelmentations to all zero checksums (send on the
socket, and accept them as valid).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/udp.h      | 24 +++++++++++++++++++++++-
 include/uapi/linux/udp.h |  2 ++
 net/ipv4/udp.c           | 20 +++++++++++++++++++-
 net/ipv6/udp.c           |  6 +++---
 4 files changed, 47 insertions(+), 5 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 42278bb..247cfdc 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -47,7 +47,9 @@ struct udp_sock {
 #define udp_portaddr_node	inet.sk.__sk_common.skc_portaddr_node
 	int		 pending;	/* Any pending frames ? */
 	unsigned int	 corkflag;	/* Cork is required */
-  	__u16		 encap_type;	/* Is this an Encapsulation socket? */
+	__u8		 encap_type;	/* Is this an Encapsulation socket? */
+	unsigned char	 no_check6_tx:1,/* Send zero UDP6 checksums on TX? */
+			 no_check6_rx:1;/* Allow zero UDP6 checksums on RX? */
 	/*
 	 * Following member retains the information to create a UDP header
 	 * when the socket is uncorked.
@@ -76,6 +78,26 @@ static inline struct udp_sock *udp_sk(const struct sock *sk)
 	return (struct udp_sock *)sk;
 }
 
+static inline void udp_set_no_check6_tx(struct sock *sk, bool val)
+{
+	udp_sk(sk)->no_check6_tx = val;
+}
+
+static inline void udp_set_no_check6_rx(struct sock *sk, bool val)
+{
+	udp_sk(sk)->no_check6_rx = val;
+}
+
+static inline bool udp_get_no_check6_tx(struct sock *sk)
+{
+	return udp_sk(sk)->no_check6_tx;
+}
+
+static inline bool udp_get_no_check6_rx(struct sock *sk)
+{
+	return udp_sk(sk)->no_check6_rx;
+}
+
 #define udp_portaddr_for_each_entry(__sk, node, list) \
 	hlist_nulls_for_each_entry(__sk, node, list, __sk_common.skc_portaddr_node)
 
diff --git a/include/uapi/linux/udp.h b/include/uapi/linux/udp.h
index e2bcfd7..ef83820 100644
--- a/include/uapi/linux/udp.h
+++ b/include/uapi/linux/udp.h
@@ -29,6 +29,8 @@ struct udphdr {
 /* UDP socket options */
 #define UDP_CORK	1	/* Never send partially complete segments */
 #define UDP_ENCAP	100	/* Set the socket to accept encapsulated packets */
+#define UDP_NO_CHECK6_TX 101	/* Disable sending checksum for UDP6 */
+#define UDP_NO_CHECK6_RX 102	/* Disable accpeting checksum for UDP6 */
 
 /* UDP encapsulation types */
 #define UDP_ENCAP_ESPINUDP_NON_IKE	1 /* draft-ietf-ipsec-nat-t-ike-00/01 */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6b5d15b..ece58cd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1968,7 +1968,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		       int (*push_pending_frames)(struct sock *))
 {
 	struct udp_sock *up = udp_sk(sk);
-	int val;
+	int val, valbool;
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
 
@@ -1978,6 +1978,8 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
 
+	valbool = val ? 1 : 0;
+
 	switch (optname) {
 	case UDP_CORK:
 		if (val != 0) {
@@ -2007,6 +2009,14 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		}
 		break;
 
+	case UDP_NO_CHECK6_TX:
+		up->no_check6_tx = valbool;
+		break;
+
+	case UDP_NO_CHECK6_RX:
+		up->no_check6_rx = valbool;
+		break;
+
 	/*
 	 * 	UDP-Lite's partial checksum coverage (RFC 3828).
 	 */
@@ -2089,6 +2099,14 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 		val = up->encap_type;
 		break;
 
+	case UDP_NO_CHECK6_TX:
+		val = up->no_check6_tx;
+		break;
+
+	case UDP_NO_CHECK6_RX:
+		val = up->no_check6_rx;
+		break;
+
 	/* The following two cannot be changed on UDP sockets, the return is
 	 * always 0 (which corresponds to the full checksum coverage of UDP). */
 	case UDPLITE_SEND_CSCOV:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b8db453..37de9c3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -794,10 +794,10 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
 	while (sk) {
-		/* If zero checksum and sk_no_check is not on for
+		/* If zero checksum and no_check is not on for
 		 * the socket then skip it.
 		 */
-		if (uh->check || sk->sk_no_check_rx)
+		if (uh->check || udp_sk(sk)->no_check6_rx)
 			stack[count++] = sk;
 
 		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
@@ -1037,7 +1037,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
-	else if (sk->sk_no_check_tx) {   /* UDP csum disabled */
+	else if (up->no_check6_tx) {   /* UDP csum disabled */
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
-- 
1.9.1.423.g4596e3a
