From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 5/8] l2tp: add L2TPv3 IP encapsulation socket
Date: Sun, 22 Feb 2009 17:52:20 GMT
Message-ID: <200902221752.n1MHqKxN006546@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48326 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbZBVRrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 12:47:08 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 8A959A62087
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:53:02 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Pytew4-sn679 for <netdev@vger.kernel.org>;
	Sun, 22 Feb 2009 17:52:55 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id F3521A620B3
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id n1MHqKxN006546
	for netdev@vger.kernel.org; Sun, 22 Feb 2009 17:52:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add L2TP over IP support.

This patch adds a new L2TPIP socket family and modifies the core to
handle the case where there is no UDP header in the L2TP packet. Since
L2TP/UDP and L2TP/IP packets differ in layout, the datapath packet
handling code needs changes.

We can't use raw sockets for this because the semantics of raw sockets
don't lend themselves to the socket-per-tunnel model - we need to
differentiate sockets between the same IP peers by L2TP tunnel ids.

Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.c
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/l2tp_core.c
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.c
@@ -39,16 +39,19 @@
 #include <linux/inetdevice.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
+#include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/udp.h>
 #include <linux/hash.h>
 #include <linux/sort.h>
 #include <linux/proc_fs.h>
+#include <linux/l2tp.h>
 #include <net/net_namespace.h>
 #include <net/dst.h>
 #include <net/ip.h>
 #include <net/udp.h>
 #include <net/xfrm.h>
+#include <net/protocol.h>
 
 #include <asm/byteorder.h>
 #include <asm/atomic.h>
@@ -411,9 +414,9 @@ out:
  * session-id have already been parsed and ptr points to the data
  * after the session-id.
  */
-static void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
-			     unsigned char *ptr, unsigned char *optr, u16 hdrflags,
-			     int length, int (*payload_hook)(struct sk_buff *skb))
+void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
+		      unsigned char *ptr, unsigned char *optr, u16 hdrflags,
+		      int length, int (*payload_hook)(struct sk_buff *skb))
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	int offset;
@@ -427,16 +430,18 @@ static void l2tp_recv_common(struct l2tp
 	if (session->ref)
 		(*session->ref)(session);
 
-	/* Parse and check optional cookie */
-	if (session->peer_cookie_len > 0) {
-		if (memcmp(ptr, &session->peer_cookie[0], session->peer_cookie_len)) {
-			PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-			       "%s: cookie mismatch (%u/%u). Discarding.\n",
-			       tunnel->name, tunnel->tunnel_id, session->session_id);
-			session->stats.rx_cookie_discards++;
-			goto discard;
+	if (tunnel->version == L2TP_HDR_VER_3) {
+		/* Parse and check optional cookie */
+		if (session->peer_cookie_len > 0) {
+			if (memcmp(ptr, &session->peer_cookie[0], session->peer_cookie_len)) {
+				PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
+				       "%s: cookie mismatch (%u/%u). Discarding.\n",
+				       tunnel->name, tunnel->tunnel_id, session->session_id);
+				session->stats.rx_cookie_discards++;
+				goto discard;
+			}
+			ptr += session->peer_cookie_len;
 		}
-		ptr += session->peer_cookie_len;
 	}
 
 	/* Handle the optional sequence numbers. Sequence numbers are
@@ -610,6 +615,7 @@ discard:
 
 	l2tp_session_dec_refcount(session);
 }
+EXPORT_SYMBOL(l2tp_recv_common);
 
 /* Internal UDP receive frame. Do the real work of receiving an L2TP data frame
  * here. The skb is not on a list when we get here.
@@ -787,15 +793,21 @@ static int l2tp_build_l2tpv2_header(stru
 
 static int l2tp_build_l2tpv3_header(struct l2tp_session *session, void *buf)
 {
+	struct l2tp_tunnel *tunnel = session->tunnel;
 	char *bufp = buf;
 	char *optr = bufp;
-	u16 flags = L2TP_HDR_VER_3;
 
-	/* Setup L2TP header. */
-	*((__be16 *) bufp) = htons(flags);
-	bufp += 2;
-	*((__be16 *) bufp) = 0;
-	bufp += 2;
+	/* Setup L2TP header. The header differs slightly for UDP and
+	 * IP encapsulations. For UDP, there is 4 bytes of flags.
+	 */
+	if (tunnel->encap == L2TP_ENCAPTYPE_UDP) {
+		u16 flags = L2TP_HDR_VER_3;
+		*((__be16 *) bufp) = htons(flags);
+		bufp += 2;
+		*((__be16 *) bufp) = 0;
+		bufp += 2;
+	}
+
 	*((__be32 *) bufp) = htonl(session->peer_session_id);
 	bufp += 4;
 	if (session->cookie_len) {
@@ -840,10 +852,11 @@ int l2tp_xmit_core(struct l2tp_session *
 
 	if (session->debug & L2TP_MSG_DATA) {
 		int i;
-		unsigned char *datap = skb->data + sizeof(struct udphdr);
+		int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
+		unsigned char *datap = skb->data + uhlen;
 
 		printk(KERN_DEBUG "%s: xmit:", session->name);
-		for (i = 0; i < (len - sizeof(struct udphdr)); i++) {
+		for (i = 0; i < (len - uhlen); i++) {
 			printk(" %02X", *datap++);
 			if (i == 31) {
 				printk(" ...");
@@ -894,20 +907,22 @@ static inline void l2tp_skb_set_owner_w(
 int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len)
 {
 	int data_len = skb->len;
-	struct sock *sk = session->tunnel->sock;
+	struct l2tp_tunnel *tunnel = session->tunnel;
+	struct sock *sk = tunnel->sock;
 	struct udphdr *uh;
 	struct inet_sock *inet;
 	__wsum csum = 0;
 	int old_headroom;
 	int new_headroom;
 	int headroom;
+	int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 
 	/* Check that there's enough headroom in the skb to insert IP,
 	 * UDP and L2TP headers. If not enough, expand it to
 	 * make room. Adjust truesize.
 	 */
 	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
-		sizeof(struct udphdr) + hdr_len;
+		uhlen + hdr_len;
 	old_headroom = skb_headroom(skb);
 	if (skb_cow_head(skb, headroom))
 		goto abort;
@@ -919,19 +934,27 @@ int l2tp_xmit_skb(struct l2tp_session *s
 	/* Setup L2TP header */
 	session->build_header(session, __skb_push(skb, hdr_len));
 
-	/* Setup UDP header */
-	inet = inet_sk(sk);
-	__skb_push(skb, sizeof(*uh));
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-	uh->source = inet->sport;
-	uh->dest = inet->dport;
-	uh->len = htons(sizeof(struct udphdr) + hdr_len + data_len);
-	uh->check = 0;
-
-	/* *BROKEN* Calculate UDP checksum if configured to do so */
-	if (sk->sk_no_check != UDP_CSUM_NOXMIT)
-		csum = udp_csum_outgoing(sk, skb);
+	switch (tunnel->encap) {
+	case L2TP_ENCAPTYPE_UDP:
+		/* Setup UDP header */
+		inet = inet_sk(sk);
+		__skb_push(skb, sizeof(*uh));
+		skb_reset_transport_header(skb);
+		uh = udp_hdr(skb);
+		uh->source = inet->sport;
+		uh->dest = inet->dport;
+		uh->len = htons(uhlen + hdr_len + data_len);
+		uh->check = 0;
+
+		/* *BROKEN* Calculate UDP checksum if configured to do so */
+		if (sk->sk_no_check != UDP_CSUM_NOXMIT)
+			csum = udp_csum_outgoing(sk, skb);
+
+		break;
+
+	case L2TP_ENCAPTYPE_IP:
+		break;
+	}
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
@@ -972,9 +995,15 @@ void l2tp_tunnel_destruct(struct sock *s
 	/* Close all sessions */
 	l2tp_tunnel_closeall(tunnel);
 
-	/* No longer an encapsulation socket. See net/ipv4/udp.c */
-	(udp_sk(sk))->encap_type = 0;
-	(udp_sk(sk))->encap_rcv = NULL;
+	switch (tunnel->encap) {
+	case L2TP_ENCAPTYPE_UDP:
+		/* No longer an encapsulation socket. See net/ipv4/udp.c */
+		(udp_sk(sk))->encap_type = 0;
+		(udp_sk(sk))->encap_rcv = NULL;
+		break;
+	case L2TP_ENCAPTYPE_IP:
+		break;
+	}
 
 	/* Remove hooks into tunnel socket */
 	tunnel->sock = NULL;
@@ -1127,12 +1156,15 @@ int l2tp_tunnel_create(int fd, int versi
 	sprintf(&tunnel->name[0], "tunl %u", tunnel_id);
 	rwlock_init(&tunnel->hlist_lock);
 
-	if (cfg)
+	if (cfg->debug)
 		tunnel->debug = cfg->debug;
 
-	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
-	udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
-	udp_sk(sk)->encap_rcv = l2tp_udp_encap_recv;
+	tunnel->encap = cfg->encap;
+	if (tunnel->encap == L2TP_ENCAPTYPE_UDP) {
+		/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
+		udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
+		udp_sk(sk)->encap_rcv = l2tp_udp_encap_recv;
+	}
 
 	sk->sk_user_data = tunnel;
 
@@ -1213,7 +1245,9 @@ void l2tp_session_set_header_len(struct 
 		if (session->send_seq)
 			session->header_len += 4;
 	} else {
-		session->header_len = 8 + session->cookie_len + session->l2specific_len + session->offset;
+		session->header_len = 4 + session->cookie_len + session->l2specific_len + session->offset;
+		if (session->tunnel->encap == L2TP_ENCAPTYPE_UDP)
+			session->header_len += 4;
 	}
 
 }
Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.h
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/l2tp_core.h
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_core.h
@@ -48,6 +48,11 @@ enum l2tp_l2spec_type {
 	L2TP_L2SPECTYPE_DEFAULT,
 };
 
+enum l2tp_encap_type {
+	L2TP_ENCAPTYPE_UDP,
+	L2TP_ENCAPTYPE_IP,
+};
+
 struct sk_buff;
 
 struct l2tp_stats {
@@ -82,6 +87,7 @@ struct l2tp_session_cfg {
 						 * control of LNS. */
 	int			debug;		/* bitmask of debug message
 						 * categories */
+	u16			vlan_id;	/* VLAN pseudowire only */
 	u16			offset;		/* offset to payload */
 	u16			l2specific_len;	/* Layer 2 specific length */
 	u16			l2specific_type; /* Layer 2 specific type */
@@ -93,6 +99,7 @@ struct l2tp_session_cfg {
 						  * (in jiffies) */
 	int			mtu;
 	int			mru;
+	char			*ifname;
 };
 
 struct l2tp_session {
@@ -157,6 +164,7 @@ struct l2tp_session {
 struct l2tp_tunnel_cfg {
 	int			debug;		/* bitmask of debug message
 						 * categories */
+	enum l2tp_encap_type	encap;
 };
 
 struct l2tp_tunnel {
@@ -172,6 +180,7 @@ struct l2tp_tunnel {
 	char			name[20];	/* for logging */
 	int			debug;		/* bitmask of debug message
 						 * categories */
+  	enum l2tp_encap_type	encap;
 	struct l2tp_stats	stats;
 
 	struct list_head	list;		/* Keep a list of all tunnels */
@@ -224,6 +233,7 @@ extern int l2tp_tunnel_create(int fd, in
 extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
 extern void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
 extern void l2tp_session_free(struct l2tp_session *session);
+extern void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb, unsigned char *ptr, unsigned char *optr, u16 hdrflags, int length, int (*payload_hook)(struct sk_buff *skb));
 extern int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb, int (*payload_hook)(struct sk_buff *skb));
 extern int l2tp_udp_encap_recv(struct sock *sk, struct sk_buff *skb);
 
Index: net-next-2.6-l2tpv3-2/net/l2tp/Makefile
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/Makefile
+++ net-next-2.6-l2tpv3-2/net/l2tp/Makefile
@@ -6,4 +6,4 @@ obj-$(CONFIG_L2TP) += l2tp_core.o
 
 # Build l2tp as modules if L2TP is M
 obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_PPPOL2TP)) += l2tp_ppp.o
-
+obj-$(subst y,$(CONFIG_L2TP),$(CONFIG_L2TP_IP)) += l2tp_ip.o
Index: net-next-2.6-l2tpv3-2/net/l2tp/l2tp_ip.c
===================================================================
--- /dev/null
+++ net-next-2.6-l2tpv3-2/net/l2tp/l2tp_ip.c
@@ -0,0 +1,622 @@
+/*
+ * L2TPv3 IP encapsulation support
+ *
+ * Copyright (c) 2008,2009 Katalix Systems Ltd
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/icmp.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/random.h>
+#include <linux/socket.h>
+#include <linux/l2tp.h>
+#include <linux/in.h>
+#include <net/sock.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/udp.h>
+#include <net/inet_common.h>
+#include <net/inet_hashtables.h>
+#include <net/tcp_states.h>
+#include <net/protocol.h>
+#include <net/xfrm.h>
+
+#include "l2tp_core.h"
+
+struct l2tp_ip_sock {
+	/* inet_sock has to be the first member of l2tp_ip_sock */
+	struct inet_sock	inet;
+
+	__u32			conn_id;
+	__u32			peer_conn_id;
+
+	__u64			tx_packets;
+	__u64			tx_bytes;
+	__u64			tx_errors;
+	__u64			rx_packets;
+	__u64			rx_bytes;
+	__u64			rx_errors;
+};
+
+static DEFINE_RWLOCK(l2tp_ip_lock);
+static struct hlist_head l2tp_ip_table;
+static struct hlist_head l2tp_ip_bind_table;
+
+static inline struct l2tp_ip_sock *l2tp_ip_sk(const struct sock *sk)
+{
+	return (struct l2tp_ip_sock *)sk;
+}
+
+static struct sock *__l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif, u32 tunnel_id)
+{
+	struct hlist_node *node;
+	struct sock *sk;
+
+	sk_for_each_bound(sk, node, &l2tp_ip_bind_table) {
+		struct inet_sock *inet = inet_sk(sk);
+		struct l2tp_ip_sock *l2tp = l2tp_ip_sk(sk);
+
+		if (l2tp == NULL)
+			continue;
+
+		if ((l2tp->conn_id == tunnel_id) &&
+#ifdef CONFIG_NET_NS
+		    (sk->sk_net == net) &&
+#endif
+		    !(inet->rcv_saddr && inet->rcv_saddr != laddr) &&
+		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+			goto found;
+	}
+
+	sk = NULL;
+found:
+	return sk;
+}
+
+static inline struct sock *l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif, u32 tunnel_id)
+{
+	struct sock *sk = __l2tp_ip_bind_lookup(net, laddr, dif, tunnel_id);
+	if (sk)
+		sock_hold(sk);
+
+	return sk;
+}
+
+/* When processing receive frames, there are two cases to
+ * consider. Data frames consist of a non-zero session-id and an
+ * optional cookie. Control frames consist of a regular L2TP header
+ * preceded by 32-bits of zeros.
+ *
+ * L2TPv3 Session Header Over IP
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                           Session ID                          |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |               Cookie (optional, maximum 64 bits)...
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *                                                                 |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * L2TPv3 Control Message Header Over IP
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                      (32 bits of zeros)                       |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |T|L|x|x|S|x|x|x|x|x|x|x|  Ver  |             Length            |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                     Control Connection ID                     |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |               Ns              |               Nr              |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * All control frames are passed to userspace.
+ */
+static int l2tp_ip_recv(struct sk_buff *skb)
+{
+	struct sock *sk;
+	u32 session_id;
+	u32 tunnel_id;
+	unsigned char *ptr, *optr;
+	struct l2tp_session *session;
+	struct l2tp_tunnel *tunnel = NULL;
+	int length;
+	int offset;
+
+	/* Point to L2TP header */
+	optr = ptr = skb->data;
+
+	if (!pskb_may_pull(skb, 4))
+		goto discard;
+
+	session_id = ntohl(*((__be32 *) ptr));
+	ptr += 4;
+
+	/* RFC3931: L2TP/IP packets have the first 4 bytes containing
+	 * the session_id. If it is 0, the packet is a L2TP control
+	 * frame and the session_id value can be discarded.
+	 */
+	if (session_id == 0) {
+		__skb_pull(skb, 4);
+		goto pass_up;
+	}
+
+	/* Ok, this is a data packet. Lookup the session. */
+	session = l2tp_session_find(NULL, session_id);
+	if (session == NULL)
+		goto discard;
+
+	tunnel = session->tunnel;
+	if (tunnel == NULL)
+		goto discard;
+
+	/* Trace packet contents, if enabled */
+	if (tunnel->debug & L2TP_MSG_DATA) {
+		length = min(32u, skb->len);
+		if (!pskb_may_pull(skb, length))
+			goto discard;
+
+		printk(KERN_DEBUG "%s: ip recv: ", tunnel->name);
+
+		offset = 0;
+		do {
+			printk(" %02X", ptr[offset]);
+		} while (++offset < length);
+
+		printk("\n");
+	}
+
+	l2tp_recv_common(session, skb, ptr, optr, 0, skb->len, NULL);
+
+	return 0;
+
+pass_up:
+	/* Get the tunnel_id from the L2TP header */
+	if (!pskb_may_pull(skb, 12))
+		goto discard;
+
+	if ((skb->data[0] & 0xc0) != 0xc0)
+		goto discard;
+
+	tunnel_id = ntohl(*(__be32 *) &skb->data[4]);
+	tunnel = l2tp_tunnel_find(tunnel_id);
+	if (tunnel != NULL)
+		sk = tunnel->sock;
+	else {
+		struct iphdr *iph = (struct iphdr *) skb_network_header(skb);
+
+		read_lock_bh(&l2tp_ip_lock);
+		sk = __l2tp_ip_bind_lookup(&init_net, iph->saddr, 0, tunnel_id);
+		read_unlock_bh(&l2tp_ip_lock);
+	}
+
+	if (sk == NULL)
+		goto discard;
+
+	sock_hold(sk);
+
+	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
+		goto discard_put;
+
+	nf_reset(skb);
+
+	return sk_receive_skb(sk, skb, 1);
+
+discard_put:
+	sock_put(sk);
+
+discard:
+	kfree_skb(skb);
+	return 0;
+}
+
+static int l2tp_ip_open(struct sock *sk)
+{
+	/* Prevent autobind. We don't have ports. */
+	inet_sk(sk)->num = IPPROTO_L2TP;
+
+	write_lock_bh(&l2tp_ip_lock);
+	sk_add_node(sk, &l2tp_ip_table);
+	write_unlock_bh(&l2tp_ip_lock);
+
+	return 0;
+}
+
+static void l2tp_ip_close(struct sock *sk, long timeout)
+{
+	write_lock_bh(&l2tp_ip_lock);
+	hlist_del_init(&sk->sk_bind_node);
+	hlist_del_init(&sk->sk_node);
+	write_unlock_bh(&l2tp_ip_lock);
+	sk_common_release(sk);
+}
+
+static void l2tp_ip_destroy_sock(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+		kfree_skb(skb);
+
+	sk_refcnt_debug_dec(sk);
+}
+
+static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct sockaddr_l2tpip *addr = (struct sockaddr_l2tpip *) uaddr;
+	int ret = -EINVAL;
+	int chk_addr_ret;
+
+	ret = -EADDRINUSE;
+	read_lock_bh(&l2tp_ip_lock);
+	if (__l2tp_ip_bind_lookup(&init_net, addr->l2tp_addr.s_addr, sk->sk_bound_dev_if, addr->l2tp_conn_id))
+		goto out_in_use;
+
+	read_unlock_bh(&l2tp_ip_lock);
+
+	lock_sock(sk);
+	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_l2tpip))
+		goto out;
+
+	chk_addr_ret = inet_addr_type(&init_net, addr->l2tp_addr.s_addr);
+	ret = -EADDRNOTAVAIL;
+	if (addr->l2tp_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
+	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
+		goto out;
+
+	inet->rcv_saddr = inet->saddr = addr->l2tp_addr.s_addr;
+	if (chk_addr_ret == RTN_MULTICAST || chk_addr_ret == RTN_BROADCAST)
+		inet->saddr = 0;  /* Use device */
+	sk_dst_reset(sk);
+
+	l2tp_ip_sk(sk)->conn_id = addr->l2tp_conn_id;
+
+	write_lock_bh(&l2tp_ip_lock);
+	sk_add_bind_node(sk, &l2tp_ip_bind_table);
+	sk_del_node_init(sk);
+	write_unlock_bh(&l2tp_ip_lock);
+	ret = 0;
+out:
+	release_sock(sk);
+
+	return ret;
+
+out_in_use:
+	read_unlock_bh(&l2tp_ip_lock);
+
+	return ret;
+}
+
+static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+{
+	int rc;
+	struct inet_sock *inet = inet_sk(sk);
+	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
+	struct rtable *rt;
+	__be32 saddr;
+	int oif;
+
+	rc = -EINVAL;
+	if (addr_len < sizeof(*lsa))
+		goto out;
+
+	rc = -EAFNOSUPPORT;
+	if (lsa->l2tp_family != AF_INET)
+		goto out;
+
+	sk_dst_reset(sk);
+
+	oif = sk->sk_bound_dev_if;
+	saddr = inet->saddr;
+
+	rc = -EINVAL;
+	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
+		goto out;
+
+	rc = ip_route_connect(&rt, lsa->l2tp_addr.s_addr, saddr,
+			      RT_CONN_FLAGS(sk), oif,
+			      IPPROTO_L2TP,
+			      0, 0, sk, 1);
+	if (rc) {
+		if (rc == -ENETUNREACH)
+			IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
+		goto out;
+	}
+
+	rc = -ENETUNREACH;
+	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
+		ip_rt_put(rt);
+		goto out;
+	}
+
+	l2tp_ip_sk(sk)->peer_conn_id = lsa->l2tp_conn_id;
+
+	if (!inet->saddr)
+		inet->saddr = rt->rt_src;
+	if (!inet->rcv_saddr)
+		inet->rcv_saddr = rt->rt_src;
+	inet->daddr = rt->rt_dst;
+	sk->sk_state = TCP_ESTABLISHED;
+	inet->id = jiffies;
+
+	sk_dst_set(sk, &rt->u.dst);
+
+	write_lock_bh(&l2tp_ip_lock);
+	hlist_del_init(&sk->sk_bind_node);
+	sk_add_bind_node(sk, &l2tp_ip_bind_table);
+	write_unlock_bh(&l2tp_ip_lock);
+
+	rc = 0;
+out:
+	return rc;
+}
+
+static int l2tp_ip_getname(struct socket *sock, struct sockaddr *uaddr,
+			   int *uaddr_len, int peer)
+{
+	struct sock *sk		= sock->sk;
+	struct inet_sock *inet	= inet_sk(sk);
+	struct l2tp_ip_sock *lsk = l2tp_ip_sk(sk);
+	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *)uaddr;
+
+	memset(lsa, 0, sizeof(*lsa));
+	lsa->l2tp_family = AF_INET;
+	if (peer) {
+		if (!inet->dport)
+			return -ENOTCONN;
+		lsa->l2tp_conn_id = lsk->peer_conn_id;
+		lsa->l2tp_addr.s_addr = inet->daddr;
+	} else {
+		__be32 addr = inet->rcv_saddr;
+		if (!addr)
+			addr = inet->saddr;
+		lsa->l2tp_conn_id = lsk->conn_id;
+		lsa->l2tp_addr.s_addr = addr;
+	}
+	*uaddr_len = sizeof(*lsa);
+	return 0;
+}
+
+static int l2tp_ip_backlog_recv(struct sock *sk, struct sk_buff *skb)
+{
+	int rc;
+
+	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
+		goto drop;
+
+	nf_reset(skb);
+
+	/* Charge it to the socket, dropping if the queue is full. */
+	rc = sock_queue_rcv_skb(sk, skb);
+	if (rc < 0)
+		goto drop;
+
+	return 0;
+
+drop:
+	IP_INC_STATS(&init_net, IPSTATS_MIB_INDISCARDS);
+	kfree_skb(skb);
+	return -1;
+}
+
+/* Userspace will call sendmsg() on the tunnel socket to send L2TP
+ * control frames.
+ */
+static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg, size_t len)
+{
+	struct sk_buff *skb;
+	int rc;
+	struct l2tp_ip_sock *lsa = l2tp_ip_sk(sk);
+
+	rc = -ENOTCONN;
+	if (sock_flag(sk, SOCK_DEAD))
+		goto error;
+
+	/* Allocate a socket buffer */
+	rc = -ENOMEM;
+	skb = sock_wmalloc(sk, 2 + NET_SKB_PAD + sizeof(struct iphdr) +
+			   4 + len, 0, GFP_KERNEL);
+	if (!skb)
+		goto error;
+
+	/* Reserve space for headers, putting IP header on 4-byte boundary. */
+	skb_reserve(skb, 2 + NET_SKB_PAD);
+	skb_reset_network_header(skb);
+	skb_reserve(skb, sizeof(struct iphdr));
+	skb_reset_transport_header(skb);
+
+	/* Insert 0 session_id */
+	*((__be32 *) skb_put(skb, 4)) = 0;
+
+	/* Copy user data into skb */
+	rc = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	if (rc < 0) {
+		kfree_skb(skb);
+		goto error;
+	}
+
+	/* Queue the packet to IP for output */
+	rc = ip_queue_xmit(skb, 1);
+
+error:
+	/* Update stats */
+	if (rc >= 0) {
+		lsa->tx_packets++;
+		lsa->tx_bytes += len;
+		rc = len;
+	} else {
+		lsa->tx_errors++;
+	}
+
+	return rc;
+}
+
+static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+			   size_t len, int noblock, int flags, int *addr_len)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct l2tp_ip_sock *lsk = l2tp_ip_sk(sk);
+	size_t copied = 0;
+	int err = -EOPNOTSUPP;
+	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
+	struct sk_buff *skb;
+
+	if (flags & MSG_OOB)
+		goto out;
+
+	if (addr_len)
+		*addr_len = sizeof(*sin);
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		goto out;
+
+	copied = skb->len;
+	if (len < copied) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto done;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	/* Copy the address. */
+	if (sin) {
+		sin->sin_family = AF_INET;
+		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
+		sin->sin_port = 0;
+		memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
+	}
+	if (inet->cmsg_flags)
+		ip_cmsg_recv(msg, skb);
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+done:
+	skb_free_datagram(sk, skb);
+out:
+	if (err) {
+		lsk->rx_errors++;
+		return err;
+	}
+
+	lsk->rx_packets++;
+	lsk->rx_bytes += copied;
+
+	return copied;
+}
+
+struct proto l2tp_ip_prot = {
+	.name		   = "L2TP/IP",
+	.owner		   = THIS_MODULE,
+	.init		   = l2tp_ip_open,
+	.close		   = l2tp_ip_close,
+	.bind		   = l2tp_ip_bind,
+	.connect	   = l2tp_ip_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = udp_ioctl,
+	.destroy	   = l2tp_ip_destroy_sock,
+	.setsockopt	   = ip_setsockopt,
+	.getsockopt	   = ip_getsockopt,
+	.sendmsg	   = l2tp_ip_sendmsg,
+	.recvmsg	   = l2tp_ip_recvmsg,
+	.backlog_rcv	   = l2tp_ip_backlog_recv,
+	.hash		   = inet_hash,
+	.unhash		   = inet_unhash,
+	.obj_size	   = sizeof(struct l2tp_ip_sock),
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_udp_setsockopt,
+	.compat_getsockopt = compat_udp_getsockopt,
+#endif
+};
+
+static const struct proto_ops l2tp_ip_ops = {
+	.family		   = PF_INET,
+	.owner		   = THIS_MODULE,
+	.release	   = inet_release,
+	.bind		   = inet_bind,
+	.connect	   = inet_dgram_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = l2tp_ip_getname,
+	.poll		   = datagram_poll,
+	.ioctl		   = inet_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
+#endif
+};
+
+static struct inet_protosw l2tp_ip_protosw = {
+	.type		= SOCK_DGRAM,
+	.protocol	= IPPROTO_L2TP,
+	.prot		= &l2tp_ip_prot,
+	.ops		= &l2tp_ip_ops,
+	.capability	= -1,
+	.no_check	= 0,
+};
+
+static struct net_protocol l2tp_ip_protocol __read_mostly = {
+	.handler	= l2tp_ip_recv,
+};
+
+static int __init l2tp_ip_init(void)
+{
+	int err;
+
+	printk(KERN_INFO "L2TP/IP support (L2TPv3)\n");
+
+	err = proto_register(&l2tp_ip_prot, 1);
+	if (err != 0)
+		goto out;
+
+	err = inet_add_protocol(&l2tp_ip_protocol, IPPROTO_L2TP);
+	if (err)
+		goto out1;
+
+	inet_register_protosw(&l2tp_ip_protosw);
+	return 0;
+
+out1:
+	proto_unregister(&l2tp_ip_prot);
+out:
+	return err;
+}
+
+static void __exit l2tp_ip_exit(void)
+{
+	inet_unregister_protosw(&l2tp_ip_protosw);
+	inet_del_protocol(&l2tp_ip_protocol, IPPROTO_L2TP);
+	proto_unregister(&l2tp_ip_prot);
+}
+
+module_init(l2tp_ip_init);
+module_exit(l2tp_ip_exit);
+
+/*
+ * __stringify doesn't likes enums, so use SOCK_DGRAM (2) and
+ * IPPROTO_L2TP (115) values directly.
+ */
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_INET, 2, 115);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
+MODULE_DESCRIPTION("L2TP over IP");
Index: net-next-2.6-l2tpv3-2/include/linux/l2tp.h
===================================================================
--- /dev/null
+++ net-next-2.6-l2tpv3-2/include/linux/l2tp.h
@@ -0,0 +1,38 @@
+/*
+ * L2TP-over-IP socket for L2TPv3.
+ *
+ * Author: James Chapman <jchapman@katalix.com>
+ */
+
+#ifndef _LINUX_L2TP_H_
+#define _LINUX_L2TP_H_
+
+#include <linux/types.h>
+#ifdef __KERNEL__
+#include <linux/socket.h>
+#include <linux/in.h>
+#endif
+
+#define IPPROTO_L2TP		115
+
+/**
+ * struct sockaddr_l2tpip - the sockaddr structure for L2TP-over-IP sockets
+ * @l2tp_family:  address family number AF_L2TPIP.
+ * @l2tp_addr:    protocol specific address information
+ * @l2tp_conn_id: connection id of tunnel
+ */
+struct sockaddr_l2tpip {
+	/* The first fields must match struct sockaddr_in */
+	sa_family_t	l2tp_family;	/* AF_INET */
+	__be16		l2tp_unused;	/* INET port number (unused) */
+	struct in_addr	l2tp_addr;	/* Internet address */
+
+	__u32		l2tp_conn_id;	/* Connection ID of tunnel */
+
+	/* Pad to size of `struct sockaddr'. */
+	unsigned char	__pad[sizeof(struct sockaddr) - sizeof(sa_family_t) -
+			      sizeof(__be16) - sizeof(struct in_addr) -
+			      sizeof(__u32)];
+};
+
+#endif
Index: net-next-2.6-l2tpv3-2/net/l2tp/Kconfig
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/l2tp/Kconfig
+++ net-next-2.6-l2tpv3-2/net/l2tp/Kconfig
@@ -51,3 +51,21 @@ config L2TP_V3
 	  If you are connecting to L2TPv3 equipment, or you want to
 	  tunnel raw ethernet frames using L2TP, say Y here. If
 	  unsure, say N.
+
+config L2TP_IP
+	tristate "L2TP IP encapsulation for L2TPv3"
+	depends on L2TP_V3
+	help
+	  Support for L2TP-over-IP socket family.
+
+	  The L2TPv3 protocol defines two possible encapsulations for
+	  L2TP frames, namely UDP and plain IP (without UDP). This
+	  driver provides a new L2TPIP socket family with which
+	  userspace L2TPv3 daemons may create L2TP/IP tunnel sockets
+	  when UDP encapsulation is not required. When L2TP is carried
+	  in IP packets, it used IP protocol number 115, so this port
+	  must be enabled in firewalls.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called l2tp_ip.
+
