From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 2/2] sctp: Add GSO support
Date: Fri, 29 Apr 2016 18:33:33 -0300
Message-ID: <cb7fdb4757ac50d78836dd345e44de69a2eb1b23.1461965035.git.marcelo.leitner@gmail.com>
References: <cover.1461965035.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbcD2Vdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 17:33:49 -0400
In-Reply-To: <cover.1461965035.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP has this pecualiarity that its packets cannot be just segmented to
(P)MTU. Its chunks must be contained in IP segments, padding respected.
So we can't just generate a big skb, set gso_size to the fragmentation
point and deliver it to IP layer.

This patch takes a different approach. SCTP will now build a skb as it
would be if it was received using GRO. That is, there will be a cover
skb with protocol headers and children ones containing the actual
segments, already segmented to a way that respects SCTP RFCs.

With that, we can tell skb_segment() to just split based on frag_list,
trusting its sizes are already in accordance.

This way SCTP can benefit from GSO and instead of passing several
packets through the stack, it can pass a single large packet.

Tested-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/linux/netdev_features.h |   7 +-
 include/linux/netdevice.h       |   1 +
 include/linux/skbuff.h          |   7 +
 include/net/sctp/sctp.h         |   4 +
 include/net/sctp/structs.h      |   2 +
 net/core/skbuff.c               |  10 +-
 net/ipv4/af_inet.c              |   1 +
 net/sctp/Makefile               |   3 +-
 net/sctp/offload.c              |  98 +++++++++++
 net/sctp/output.c               | 348 +++++++++++++++++++++++++++-------------
 net/sctp/protocol.c             |   3 +
 net/sctp/socket.c               |   2 +
 12 files changed, 365 insertions(+), 121 deletions(-)
 create mode 100644 net/sctp/offload.c

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index bc87362667497fd845a2fcc5ad0eddbf031d1eaf..838aa14fec16cdc3814066351e4c533f64d0e340 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -53,8 +53,9 @@ enum {
 					 *     headers in software.
 					 */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
+	NETIF_F_GSO_SCTP_BIT,		/* ... SCTP fragmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
+		NETIF_F_GSO_SCTP_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
@@ -128,6 +129,7 @@ enum {
 #define NETIF_F_TSO_MANGLEID	__NETIF_F(TSO_MANGLEID)
 #define NETIF_F_GSO_PARTIAL	 __NETIF_F(GSO_PARTIAL)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
+#define NETIF_F_GSO_SCTP	__NETIF_F(GSO_SCTP)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
@@ -166,7 +168,8 @@ enum {
 				 NETIF_F_FSO)
 
 /* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_ALL_TSO | NETIF_F_UFO)
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_ALL_TSO | NETIF_F_UFO | \
+				 NETIF_F_GSO_SCTP)
 
 /*
  * If one device supports one of these features, then enable them
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 934ca866562d9ba9a9d2fb2e34f627660bd0c994..91f084d2d7e066c398cd98d3fd70eec8ec063d5d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4010,6 +4010,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_PARTIAL != (NETIF_F_GSO_PARTIAL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_SCTP    != (NETIF_F_GSO_SCTP >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c84a5a1078c5528bf6fc84573f63f3c6f470ce8f..df557f77732e0d74a896522e0c9f864f49d6438a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -301,6 +301,11 @@ struct sk_buff;
 #endif
 extern int sysctl_max_skb_frags;
 
+/* Set skb_shinfo(skb)->gso_size to this in case you want skb_segment to
+ * segment using its current segmentation instead.
+ */
+#define GSO_BY_FRAGS	0xFFFF
+
 typedef struct skb_frag_struct skb_frag_t;
 
 struct skb_frag_struct {
@@ -482,6 +487,8 @@ enum {
 	SKB_GSO_PARTIAL = 1 << 13,
 
 	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
+
+	SKB_GSO_SCTP = 1 << 15,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index b392ac8382f2bf0be118f797a4444cc0eb4ddeb5..632e205ca54bfe85124753e09445251056e19aa7 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -186,6 +186,10 @@ void sctp_assocs_proc_exit(struct net *net);
 int sctp_remaddr_proc_init(struct net *net);
 void sctp_remaddr_proc_exit(struct net *net);
 
+/*
+ * sctp/offload.c
+ */
+int sctp_offload_init(void);
 
 /*
  * Module global variables
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 558bae3cbe0d5107d52c8cb31b324cfd5479def0..692805bff54cdab723605e100a9bdbee8db6b563 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -696,6 +696,8 @@ struct sctp_packet {
 	size_t overhead;
 	/* This is the total size of all chunks INCLUDING padding.  */
 	size_t size;
+	/* This is the maximum size this packet may have */
+	size_t max_size;
 
 	/* The packet is destined for this transport address.
 	 * The function we finally use to pass down to the next lower
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1b05114baeb5e3aa4f333dccd24a97aff86892ec..537a20d2fe27c63cf452d3c81b4ccb7878a21619 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3113,9 +3113,13 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		int hsize;
 		int size;
 
-		len = head_skb->len - offset;
-		if (len > mss)
-			len = mss;
+		if (unlikely(mss == GSO_BY_FRAGS)) {
+			len = list_skb->len;
+		} else {
+			len = head_skb->len - offset;
+			if (len > mss)
+				len = mss;
+		}
 
 		hsize = skb_headlen(head_skb) - offset;
 		if (hsize < 0)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 2e6e65fc4d203b91a06075e02d2dd1ac8141f3db..0415e4be6962e4a6c590f92497ba62aa698f235c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1220,6 +1220,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCP_FIXEDID |
 		       SKB_GSO_TUNNEL_REMCSUM |
 		       SKB_GSO_PARTIAL |
+		       SKB_GSO_SCTP |
 		       0)))
 		goto out;
 
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 0fca5824ad0e93c905e2cbd59ff2ff7e2077ca7c..6c4f7496cec612b52e1e69664a209b4d58763be5 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -11,7 +11,8 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o ssnmap.o auth.o
+	  output.o input.o debug.o ssnmap.o auth.o \
+	  offload.o
 
 sctp_probe-y := probe.o
 
diff --git a/net/sctp/offload.c b/net/sctp/offload.c
new file mode 100644
index 0000000000000000000000000000000000000000..9e217fce70c0025b07ba7ef5d7c921119c410382
--- /dev/null
+++ b/net/sctp/offload.c
@@ -0,0 +1,98 @@
+/*
+ * sctp_offload - GRO/GSO Offloading for SCTP
+ *
+ * Copyright (C) 2015, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
+#include <linux/kprobes.h>
+#include <linux/socket.h>
+#include <linux/sctp.h>
+#include <linux/proc_fs.h>
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+#include <linux/kfifo.h>
+#include <linux/time.h>
+#include <net/net_namespace.h>
+
+#include <linux/skbuff.h>
+#include <net/sctp/sctp.h>
+#include <net/sctp/checksum.h>
+#include <net/protocol.h>
+
+static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
+{
+	skb->ip_summed = CHECKSUM_NONE;
+	return sctp_compute_cksum(skb, skb_transport_offset(skb));
+}
+
+static struct sk_buff *sctp_gso_segment(struct sk_buff *skb,
+					netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct sctphdr *sh;
+
+	sh = sctp_hdr(skb);
+	if (!pskb_may_pull(skb, sizeof(*sh)))
+		goto out;
+
+	__skb_pull(skb, sizeof(*sh));
+
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		/* Packet is from an untrusted source, reset gso_segs. */
+		int type = skb_shinfo(skb)->gso_type;
+
+		if (unlikely(type &
+			     ~(SKB_GSO_SCTP | SKB_GSO_DODGY |
+			       0) ||
+			     !(type & (SKB_GSO_SCTP))))
+			goto out;
+
+		/* This should not happen as no NIC has SCTP GSO
+		 * offloading, it's always via software and thus we
+		 * won't send a large packet down the stack.
+		 */
+		WARN_ONCE(1, "SCTP segmentation offloading to NICs is not supported.");
+		goto out;
+	}
+
+	segs = skb_segment(skb, features | NETIF_F_HW_CSUM);
+	if (IS_ERR(segs))
+		goto out;
+
+	/* All that is left is update SCTP CRC if necessary */
+	if (!(features & NETIF_F_SCTP_CRC)) {
+		for (skb = segs; skb; skb = skb->next) {
+			if (skb->ip_summed == CHECKSUM_PARTIAL) {
+				sh = sctp_hdr(skb);
+				sh->checksum = sctp_gso_make_checksum(skb);
+			}
+		}
+	}
+
+out:
+	return segs;
+}
+
+static const struct net_offload sctp_offload = {
+	.callbacks = {
+		.gso_segment = sctp_gso_segment,
+	},
+};
+
+int __init sctp_offload_init(void)
+{
+	return inet_add_offload(&sctp_offload, IPPROTO_SCTP);
+}
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 9844fe573029b9e262743440980f15277ddaf5a1..564a0e385325e0b92f9d32a8e2e3b48937800d15 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -84,18 +84,42 @@ static void sctp_packet_reset(struct sctp_packet *packet)
 struct sctp_packet *sctp_packet_config(struct sctp_packet *packet,
 				       __u32 vtag, int ecn_capable)
 {
-	struct sctp_chunk *chunk = NULL;
+	struct sctp_transport *tp = packet->transport;
+	struct sctp_association *asoc = tp->asoc;
 
 	pr_debug("%s: packet:%p vtag:0x%x\n", __func__, packet, vtag);
 
 	packet->vtag = vtag;
 
+	if (asoc && tp->dst) {
+		struct sock *sk = asoc->base.sk;
+
+		rcu_read_lock();
+		if (__sk_dst_get(sk) != tp->dst) {
+			dst_hold(tp->dst);
+			sk_setup_caps(sk, tp->dst);
+		}
+
+		if (sk_can_gso(sk)) {
+			struct net_device *dev = tp->dst->dev;
+
+			packet->max_size = dev->gso_max_size;
+		} else {
+			packet->max_size = asoc->pathmtu;
+		}
+		rcu_read_unlock();
+
+	} else {
+		packet->max_size = tp->pathmtu;
+	}
+
 	if (ecn_capable && sctp_packet_empty(packet)) {
-		chunk = sctp_get_ecne_prepend(packet->transport->asoc);
+		struct sctp_chunk *chunk;
 
 		/* If there a is a prepend chunk stick it on the list before
 		 * any other chunks get appended.
 		 */
+		chunk = sctp_get_ecne_prepend(asoc);
 		if (chunk)
 			sctp_packet_append_chunk(packet, chunk);
 	}
@@ -380,13 +404,16 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 {
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
+	struct sock *sk = asoc->base.sk;
 	struct sctphdr *sh;
-	struct sk_buff *nskb;
+	struct sk_buff *nskb = NULL, *head = NULL;
 	struct sctp_chunk *chunk, *tmp;
-	struct sock *sk;
 	int err = 0;
 	int padding;		/* How much padding do we need?  */
+	int pkt_size;
 	__u8 has_data = 0;
+	int gso = 0;
+	int pktcount = 0;
 	struct dst_entry *dst;
 	unsigned char *auth = NULL;	/* pointer to auth in skb data */
 
@@ -400,18 +427,37 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
 	sk = chunk->skb->sk;
 
-	/* Allocate the new skb.  */
-	nskb = alloc_skb(packet->size + MAX_HEADER, gfp);
-	if (!nskb)
+	/* Allocate the head skb, or main one if not in GSO */
+	if (packet->size > tp->pathmtu && !packet->ipfragok) {
+		if (sk_can_gso(sk)) {
+			gso = 1;
+			pkt_size = packet->overhead;
+		} else {
+			/* If this happens, we trash this packet and try
+			 * to build a new one, hopefully correct this
+			 * time. Application may notice this error.
+			 */
+			pr_err_once("Trying to GSO but underlying device doesn't support it.");
+			goto nomem;
+		}
+	} else {
+		pkt_size = packet->size;
+	}
+	head = alloc_skb(pkt_size + MAX_HEADER, gfp);
+	if (!head)
 		goto nomem;
+	if (gso) {
+		NAPI_GRO_CB(head)->last = head;
+		skb_shinfo(head)->gso_type = sk->sk_gso_type;
+	}
 
 	/* Make sure the outbound skb has enough header room reserved. */
-	skb_reserve(nskb, packet->overhead + MAX_HEADER);
+	skb_reserve(head, packet->overhead + MAX_HEADER);
 
 	/* Set the owning socket so that we know where to get the
 	 * destination IP address.
 	 */
-	sctp_packet_set_owner_w(nskb, sk);
+	sctp_packet_set_owner_w(head, sk);
 
 	if (!sctp_transport_dst_check(tp)) {
 		sctp_transport_route(tp, NULL, sctp_sk(sk));
@@ -422,11 +468,11 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	dst = dst_clone(tp->dst);
 	if (!dst)
 		goto no_route;
-	skb_dst_set(nskb, dst);
+	skb_dst_set(head, dst);
 
 	/* Build the SCTP header.  */
-	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
-	skb_reset_transport_header(nskb);
+	sh = (struct sctphdr *)skb_push(head, sizeof(struct sctphdr));
+	skb_reset_transport_header(head);
 	sh->source = htons(packet->source_port);
 	sh->dest   = htons(packet->destination_port);
 
@@ -441,90 +487,133 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	sh->vtag     = htonl(packet->vtag);
 	sh->checksum = 0;
 
-	/**
-	 * 6.10 Bundling
-	 *
-	 *    An endpoint bundles chunks by simply including multiple
-	 *    chunks in one outbound SCTP packet.  ...
-	 */
-
-	/**
-	 * 3.2  Chunk Field Descriptions
-	 *
-	 * The total length of a chunk (including Type, Length and
-	 * Value fields) MUST be a multiple of 4 bytes.  If the length
-	 * of the chunk is not a multiple of 4 bytes, the sender MUST
-	 * pad the chunk with all zero bytes and this padding is not
-	 * included in the chunk length field.  The sender should
-	 * never pad with more than 3 bytes.
-	 *
-	 * [This whole comment explains WORD_ROUND() below.]
-	 */
-
 	pr_debug("***sctp_transmit_packet***\n");
 
-	list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
-		list_del_init(&chunk->list);
-		if (sctp_chunk_is_data(chunk)) {
-			/* 6.3.1 C4) When data is in flight and when allowed
-			 * by rule C5, a new RTT measurement MUST be made each
-			 * round trip.  Furthermore, new RTT measurements
-			 * SHOULD be made no more than once per round-trip
-			 * for a given destination transport address.
-			 */
+	do {
+		/* Set up convenience variables... */
+		chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
+		pktcount++;
 
-			if (!chunk->resent && !tp->rto_pending) {
-				chunk->rtt_in_progress = 1;
-				tp->rto_pending = 1;
+		/* Calculate packet size, so it fits in PMTU. Leave
+		 * other chunks for the next packets.
+		 */
+		if (gso) {
+			pkt_size = packet->overhead;
+			list_for_each_entry(chunk, &packet->chunk_list, list) {
+				int padded = WORD_ROUND(chunk->skb->len);
+
+				if (pkt_size + padded > tp->pathmtu)
+					break;
+				pkt_size += padded;
 			}
 
-			has_data = 1;
-		}
+			/* Allocate the new skb.  */
+			nskb = alloc_skb(pkt_size + MAX_HEADER, gfp);
+			if (!nskb)
+				goto nomem;
 
-		padding = WORD_ROUND(chunk->skb->len) - chunk->skb->len;
-		if (padding)
-			memset(skb_put(chunk->skb, padding), 0, padding);
+			/* Make sure the outbound skb has enough header
+			 * room reserved.
+			 */
+			skb_reserve(nskb, packet->overhead + MAX_HEADER);
+		} else {
+			nskb = head;
+		}
 
-		/* if this is the auth chunk that we are adding,
-		 * store pointer where it will be added and put
-		 * the auth into the packet.
+		/**
+		 * 3.2  Chunk Field Descriptions
+		 *
+		 * The total length of a chunk (including Type, Length and
+		 * Value fields) MUST be a multiple of 4 bytes.  If the length
+		 * of the chunk is not a multiple of 4 bytes, the sender MUST
+		 * pad the chunk with all zero bytes and this padding is not
+		 * included in the chunk length field.  The sender should
+		 * never pad with more than 3 bytes.
+		 *
+		 * [This whole comment explains WORD_ROUND() below.]
 		 */
-		if (chunk == packet->auth)
-			auth = skb_tail_pointer(nskb);
 
-		memcpy(skb_put(nskb, chunk->skb->len),
+		pkt_size -= packet->overhead;
+		list_for_each_entry_safe(chunk, tmp, &packet->chunk_list, list) {
+			list_del_init(&chunk->list);
+			if (sctp_chunk_is_data(chunk)) {
+				/* 6.3.1 C4) When data is in flight and when allowed
+				 * by rule C5, a new RTT measurement MUST be made each
+				 * round trip.  Furthermore, new RTT measurements
+				 * SHOULD be made no more than once per round-trip
+				 * for a given destination transport address.
+				 */
+
+				if (!chunk->resent && !tp->rto_pending) {
+					chunk->rtt_in_progress = 1;
+					tp->rto_pending = 1;
+				}
+
+				has_data = 1;
+			}
+
+			padding = WORD_ROUND(chunk->skb->len) - chunk->skb->len;
+			if (padding)
+				memset(skb_put(chunk->skb, padding), 0, padding);
+
+			/* if this is the auth chunk that we are adding,
+			 * store pointer where it will be added and put
+			 * the auth into the packet.
+			 */
+			if (chunk == packet->auth)
+				auth = skb_tail_pointer(nskb);
+
+			memcpy(skb_put(nskb, chunk->skb->len),
 			       chunk->skb->data, chunk->skb->len);
 
-		pr_debug("*** Chunk:%p[%s] %s 0x%x, length:%d, chunk->skb->len:%d, "
-			 "rtt_in_progress:%d\n", chunk,
-			 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)),
-			 chunk->has_tsn ? "TSN" : "No TSN",
-			 chunk->has_tsn ? ntohl(chunk->subh.data_hdr->tsn) : 0,
-			 ntohs(chunk->chunk_hdr->length), chunk->skb->len,
-			 chunk->rtt_in_progress);
-
-		/*
-		 * If this is a control chunk, this is our last
-		 * reference. Free data chunks after they've been
-		 * acknowledged or have failed.
-		 */
-		if (!sctp_chunk_is_data(chunk))
-			sctp_chunk_free(chunk);
-	}
+			pr_debug("*** Chunk:%p[%s] %s 0x%x, length:%d, chunk->skb->len:%d, rtt_in_progress:%d\n",
+				 chunk,
+				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)),
+				 chunk->has_tsn ? "TSN" : "No TSN",
+				 chunk->has_tsn ? ntohl(chunk->subh.data_hdr->tsn) : 0,
+				 ntohs(chunk->chunk_hdr->length), chunk->skb->len,
+				 chunk->rtt_in_progress);
+
+			/* If this is a control chunk, this is our last
+			 * reference. Free data chunks after they've been
+			 * acknowledged or have failed.
+			 * Re-queue auth chunks if needed.
+			 */
+			pkt_size -= WORD_ROUND(chunk->skb->len);
 
-	/* SCTP-AUTH, Section 6.2
-	 *    The sender MUST calculate the MAC as described in RFC2104 [2]
-	 *    using the hash function H as described by the MAC Identifier and
-	 *    the shared association key K based on the endpoint pair shared key
-	 *    described by the shared key identifier.  The 'data' used for the
-	 *    computation of the AUTH-chunk is given by the AUTH chunk with its
-	 *    HMAC field set to zero (as shown in Figure 6) followed by all
-	 *    chunks that are placed after the AUTH chunk in the SCTP packet.
-	 */
-	if (auth)
-		sctp_auth_calculate_hmac(asoc, nskb,
-					 (struct sctp_auth_chunk *)auth,
-					 gfp);
+			if (chunk == packet->auth && !list_empty(&packet->chunk_list))
+				list_add(&chunk->list, &packet->chunk_list);
+			else if (!sctp_chunk_is_data(chunk))
+				sctp_chunk_free(chunk);
+
+			if (!pkt_size)
+				break;
+		}
+
+		/* SCTP-AUTH, Section 6.2
+		 *    The sender MUST calculate the MAC as described in RFC2104 [2]
+		 *    using the hash function H as described by the MAC Identifier and
+		 *    the shared association key K based on the endpoint pair shared key
+		 *    described by the shared key identifier.  The 'data' used for the
+		 *    computation of the AUTH-chunk is given by the AUTH chunk with its
+		 *    HMAC field set to zero (as shown in Figure 6) followed by all
+		 *    chunks that are placed after the AUTH chunk in the SCTP packet.
+		 */
+		if (auth)
+			sctp_auth_calculate_hmac(asoc, nskb,
+						 (struct sctp_auth_chunk *)auth,
+						 gfp);
+
+		if (!gso)
+			break;
+
+		if (skb_gro_receive(&head, nskb))
+			goto nomem;
+		nskb = NULL;
+		if (WARN_ON_ONCE(skb_shinfo(head)->gso_segs >=
+				 sk->sk_gso_max_segs))
+			goto nomem;
+	} while (!list_empty(&packet->chunk_list));
 
 	/* 2) Calculate the Adler-32 checksum of the whole packet,
 	 *    including the SCTP common header and all the
@@ -532,16 +621,18 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	 *
 	 * Note: Adler-32 is no longer applicable, as has been replaced
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
+	 *
+	 * If it's a GSO packet, it's postponed to sctp_skb_segment.
 	 */
-	if (!sctp_checksum_disable) {
-		if (!(dst->dev->features & NETIF_F_SCTP_CRC) ||
-		    (dst_xfrm(dst) != NULL) || packet->ipfragok) {
-			sh->checksum = sctp_compute_cksum(nskb, 0);
+	if (!sctp_checksum_disable || gso) {
+		if (!gso && (!(dst->dev->features & NETIF_F_SCTP_CRC) ||
+			     dst_xfrm(dst) || packet->ipfragok)) {
+			sh->checksum = sctp_compute_cksum(head, 0);
 		} else {
 			/* no need to seed pseudo checksum for SCTP */
-			nskb->ip_summed = CHECKSUM_PARTIAL;
-			nskb->csum_start = skb_transport_header(nskb) - nskb->head;
-			nskb->csum_offset = offsetof(struct sctphdr, checksum);
+			head->ip_summed = CHECKSUM_PARTIAL;
+			head->csum_start = skb_transport_header(head) - head->head;
+			head->csum_offset = offsetof(struct sctphdr, checksum);
 		}
 	}
 
@@ -557,7 +648,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 	 * Note: The works for IPv6 layer checks this bit too later
 	 * in transmission.  See IP6_ECN_flow_xmit().
 	 */
-	tp->af_specific->ecn_capable(nskb->sk);
+	tp->af_specific->ecn_capable(sk);
 
 	/* Set up the IP options.  */
 	/* BUG: not implemented
@@ -566,7 +657,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 
 	/* Dump that on IP!  */
 	if (asoc) {
-		asoc->stats.opackets++;
+		asoc->stats.opackets += pktcount;
 		if (asoc->peer.last_sent_to != tp)
 			/* Considering the multiple CPU scenario, this is a
 			 * "correcter" place for last_sent_to.  --xguo
@@ -589,16 +680,32 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 		}
 	}
 
-	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", nskb->len);
+	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", head->len);
+
+	if (gso) {
+		skb_shinfo(head)->gso_segs = pktcount;
+		skb_shinfo(head)->gso_size = GSO_BY_FRAGS;
 
-	nskb->ignore_df = packet->ipfragok;
-	tp->af_specific->sctp_xmit(nskb, tp);
+		/* We have to refresh this in case we are xmiting to
+		 * more than one transport at a time
+		 */
+		rcu_read_lock();
+		if (__sk_dst_get(sk) != tp->dst) {
+			dst_hold(tp->dst);
+			sk_setup_caps(sk, tp->dst);
+		}
+		rcu_read_unlock();
+	}
+	head->ignore_df = packet->ipfragok;
+	tp->af_specific->sctp_xmit(head, tp);
 
 out:
 	sctp_packet_reset(packet);
 	return err;
 no_route:
-	kfree_skb(nskb);
+	kfree_skb(head);
+	if (nskb != head)
+		kfree_skb(nskb);
 
 	if (asoc)
 		IP_INC_STATS(sock_net(asoc->base.sk), IPSTATS_MIB_OUTNOROUTES);
@@ -751,39 +858,50 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 					struct sctp_chunk *chunk,
 					u16 chunk_len)
 {
-	size_t psize;
-	size_t pmtu;
-	int too_big;
+	size_t psize, pmtu;
 	sctp_xmit_t retval = SCTP_XMIT_OK;
 
 	psize = packet->size;
-	pmtu  = ((packet->transport->asoc) ?
-		(packet->transport->asoc->pathmtu) :
-		(packet->transport->pathmtu));
-
-	too_big = (psize + chunk_len > pmtu);
+	if (packet->transport->asoc)
+		pmtu = packet->transport->asoc->pathmtu;
+	else
+		pmtu = packet->transport->pathmtu;
 
 	/* Decide if we need to fragment or resubmit later. */
-	if (too_big) {
-		/* It's OK to fragmet at IP level if any one of the following
+	if (psize + chunk_len > pmtu) {
+		/* It's OK to fragment at IP level if any one of the following
 		 * is true:
-		 * 	1. The packet is empty (meaning this chunk is greater
-		 * 	   the MTU)
-		 * 	2. The chunk we are adding is a control chunk
-		 * 	3. The packet doesn't have any data in it yet and data
-		 * 	requires authentication.
+		 *	1. The packet is empty (meaning this chunk is greater
+		 *	   the MTU)
+		 *	2. The packet doesn't have any data in it yet and data
+		 *	   requires authentication.
 		 */
-		if (sctp_packet_empty(packet) || !sctp_chunk_is_data(chunk) ||
+		if (sctp_packet_empty(packet) ||
 		    (!packet->has_data && chunk->auth)) {
 			/* We no longer do re-fragmentation.
 			 * Just fragment at the IP layer, if we
 			 * actually hit this condition
 			 */
 			packet->ipfragok = 1;
-		} else {
-			retval = SCTP_XMIT_PMTU_FULL;
+			goto out;
 		}
+
+		/* It is also okay to fragment if the chunk we are
+		 * adding is a control chunk, but only if current packet
+		 * is not a GSO one otherwise it causes fragmentation of
+		 * a large frame. So in this case we allow the
+		 * fragmentation by forcing it to be in a new packet.
+		 */
+		if (!sctp_chunk_is_data(chunk) && packet->has_data)
+			retval = SCTP_XMIT_PMTU_FULL;
+
+		if (psize + chunk_len > packet->max_size)
+			/* Hit GSO/PMTU limit, gotta flush */
+			retval = SCTP_XMIT_PMTU_FULL;
+
+		/* Otherwise it will fit in the GSO packet */
 	}
 
+out:
 	return retval;
 }
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d3d50daa248b06d7a4306d903b2dad89e9d2acbd..40022ee885d7e8d9fbce3c7d9df43f57f0bcfa0e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1516,6 +1516,9 @@ static __init int sctp_init(void)
 	if (status)
 		goto err_v6_add_protocol;
 
+	if (sctp_offload_init() < 0)
+		pr_crit("%s: Cannot add SCTP protocol offload\n", __func__);
+
 out:
 	return status;
 err_v6_add_protocol:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 777d0324594a33a407e9ec157a7634334b1292e2..c53f08eb61b3e0516685a94093b638979521dcb9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4003,6 +4003,8 @@ static int sctp_init_sock(struct sock *sk)
 		return -ESOCKTNOSUPPORT;
 	}
 
+	sk->sk_gso_type = SKB_GSO_SCTP;
+
 	/* Initialize default send parameters. These parameters can be
 	 * modified with the SCTP_DEFAULT_SEND_PARAM socket option.
 	 */
-- 
2.5.0
