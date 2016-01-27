From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH net-next 3/3] sctp: Add GSO support
Date: Wed, 27 Jan 2016 15:06:33 -0200
Message-ID: <b4da9001ca69a7279f68b9cbd0f2a14839a269e6.1453913331.git.marcelo.leitner@gmail.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, brouer@redhat.com,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933529AbcA0RHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 12:07:02 -0500
In-Reply-To: <cover.1453913331.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables SCTP to do GSO.

SCTP has this pecualiarty that its packets cannot be just segmented to
(P)MTU. Its chunks must be contained in IP segments, padding respected.
So we can't just generate a big skb, set gso_size to the fragmentation
point and deliver it to IP layer.

Instead, this patch proposes that SCTP build a skb as it would be if it
was received using GRO. That is, there will be a cover skb with the
headers (incluing SCTP one) and children ones containing the actual SCTP
chunks, already segmented in a way that respects SCTP RFCs and MTU.

This way SCTP can benefit from GSO and instead of passing several
packets through the stack, it can pass a single large packet if there
are enough data queued and cwnd allows.

Main points that need help:
- Usage of skb_gro_receive()
  It fits nicely in there and properly handles offsets/lens, though the
  name means another thing. If you agree with this usage, we can rename
  it to something like skb_coalesce

- Checksum handling
  Why only packets with checksum offloaded can be GSOed? Most of the
  NICs doesn't support SCTP CRC offloading and this will nearly defeat
  this feature. If checksum is being computed in sw, it doesn't really
  matter if it's earlier or later, right?
  This patch hacks skb_needs_check() to allow using GSO with sw-computed
  checksums.
  Also the meaning of UNNECESSARY and NONE are quite foggy to me yet and
  its usage may be wrong.

- gso_size = 1
  There is skb_is_gso() all over the stack and it basically checks for
  non-zero skb_shinfo(skb)->gso_size. Setting it to 1 is the hacky way I
  found to keep skb_is_gso() working while being able to signal to
  skb_segment() that it shouldn't use gso_size but instead the fragment
  sizes themselves. skb_segment() will mainly just unpack the skb then.

- socket / gso max values
  usage of sk_setup_caps() still needs a review

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/linux/netdev_features.h |   7 +-
 include/linux/netdevice.h       |   1 +
 net/core/dev.c                  |   6 +-
 net/core/skbuff.c               |  12 +-
 net/ipv4/af_inet.c              |   1 +
 net/sctp/offload.c              |  53 +++++++
 net/sctp/output.c               | 338 +++++++++++++++++++++++++---------------
 net/sctp/socket.c               |   2 +
 8 files changed, 292 insertions(+), 128 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d9654f0eecb3519383441afa6b131ff9a5898485..f678998841f1800e0f2fe416a79935197d4ed305 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -48,8 +48,9 @@ enum {
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
+	NETIF_F_GSO_SCTP_BIT,		/* ... SCTP fragmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
+		NETIF_F_GSO_SCTP_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
@@ -119,6 +120,7 @@ enum {
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
+#define NETIF_F_GSO_SCTP	__NETIF_F(GSO_SCTP)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
@@ -144,7 +146,8 @@ enum {
 
 /* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
-				 NETIF_F_TSO6 | NETIF_F_UFO)
+				 NETIF_F_TSO6 | NETIF_F_UFO | \
+				 NETIF_F_GSO_SCTP)
 
 /* List of IP checksum features. Note that NETIF_F_ HW_CSUM should not be
  * set in features when NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM are set--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 289c2314d76668b8357728382bb33d6828617458..ce14fab858bf96dd0f85aca237350c8d8317756e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3928,6 +3928,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_SCTP    != (NETIF_F_GSO_SCTP >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d852f251c503b193823b71b27aaef3fb3ae..9583284086967c0746de5f553535e25e125714a5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2680,7 +2680,11 @@ EXPORT_SYMBOL(skb_mac_gso_segment);
 static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
 {
 	if (tx_path)
-		return skb->ip_summed != CHECKSUM_PARTIAL;
+		/* FIXME: Why only packets with checksum offloading are
+		 * supported for GSO?
+		 */
+		return skb->ip_summed != CHECKSUM_PARTIAL &&
+		       skb->ip_summed != CHECKSUM_UNNECESSARY;
 	else
 		return skb->ip_summed == CHECKSUM_NONE;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 704b69682085dec77f3d0f990aaf0024afd705b9..96f223f8d769d2765fd64348830c76cb222906c8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3017,8 +3017,16 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		int size;
 
 		len = head_skb->len - offset;
-		if (len > mss)
-			len = mss;
+		if (len > mss) {
+			/* FIXME: A define is surely welcomed, but maybe
+			 * shinfo->txflags is better for this flag, but
+			 * we need to expand it then
+			 */
+			if (mss == 1)
+				len = list_skb->len;
+			else
+				len = mss;
+		}
 
 		hsize = skb_headlen(head_skb) - offset;
 		if (hsize < 0)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5c5db6636704daa0c49fc13e84b2c5b282a44ed3..ec1c779bb664d1399d74f2bd7016e30b648ce47d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1220,6 +1220,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_TUNNEL_REMCSUM |
+		       SKB_GSO_SCTP |
 		       0)))
 		goto out;
 
diff --git a/net/sctp/offload.c b/net/sctp/offload.c
index 7080a6318da7110c1688dd0c5bb240356dbd0cd3..3b96035fa180a4e7195f7b6e7a8be7b97c8f8b26 100644
--- a/net/sctp/offload.c
+++ b/net/sctp/offload.c
@@ -36,8 +36,61 @@
 #include <net/sctp/checksum.h>
 #include <net/protocol.h>
 
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
+	segs = skb_segment(skb, features);
+	if (IS_ERR(segs))
+		goto out;
+
+	/* All that is left is update SCTP CRC if necessary */
+	for (skb = segs; skb; skb = skb->next) {
+		if (skb->ip_summed != CHECKSUM_PARTIAL) {
+			sh = sctp_hdr(skb);
+			sh->checksum = sctp_gso_make_checksum(skb);
+		}
+	}
+
+out:
+	return segs;
+}
+
 static const struct net_offload sctp_offload = {
 	.callbacks = {
+		.gso_segment = sctp_gso_segment,
 	},
 };
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 9d610eddd19ef2320fc34ae9d91e7426ae5f50f9..5e619b1b7b47737447bce746b2420bac3427fde4 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -381,12 +381,14 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
 	struct sctphdr *sh;
-	struct sk_buff *nskb;
+	struct sk_buff *nskb = NULL, *head = NULL;
 	struct sctp_chunk *chunk, *tmp;
-	struct sock *sk;
+	struct sock *sk = asoc->base.sk;
 	int err = 0;
 	int padding;		/* How much padding do we need?  */
+	int pkt_size;
 	__u8 has_data = 0;
+	int gso = 0;
 	struct dst_entry *dst;
 	unsigned char *auth = NULL;	/* pointer to auth in skb data */
 
@@ -396,37 +398,44 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	if (list_empty(&packet->chunk_list))
 		return err;
 
-	/* Set up convenience variables... */
+	/* TODO: double check this */
 	chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
 	sk = chunk->skb->sk;
+	dst_hold(tp->dst);
+	sk_setup_caps(sk, tp->dst);
+
+	if (packet->size > tp->pathmtu) {
+		WARN_ON(packet->ipfragok);
+		if (sk_can_gso(sk)) {
+			gso = 1;
+			pkt_size = packet->overhead;
+		} else {
+			/* Something nasty happened */
+			/* FIXME */
+			printk("Damn, we can't GSO and packet is too big %d for pmtu %d.\n",
+			       packet->size, tp->pathmtu);
+			goto nomem;
+		}
+	} else {
+		pkt_size = packet->size;
+	}
 
-	/* Allocate the new skb.  */
-	nskb = alloc_skb(packet->size + MAX_HEADER, GFP_ATOMIC);
-	if (!nskb)
+	/* Allocate the head skb, or main one if not in GSO */
+	head = alloc_skb(pkt_size + MAX_HEADER, GFP_ATOMIC);
+	if (!head)
 		goto nomem;
+	if (gso) {
+		NAPI_GRO_CB(head)->last = head;
+	} else {
+		nskb = head;
+	}
 
 	/* Make sure the outbound skb has enough header room reserved. */
-	skb_reserve(nskb, packet->overhead + MAX_HEADER);
-
-	/* Set the owning socket so that we know where to get the
-	 * destination IP address.
-	 */
-	sctp_packet_set_owner_w(nskb, sk);
-
-	if (!sctp_transport_dst_check(tp)) {
-		sctp_transport_route(tp, NULL, sctp_sk(sk));
-		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
-			sctp_assoc_sync_pmtu(sk, asoc);
-		}
-	}
-	dst = dst_clone(tp->dst);
-	if (!dst)
-		goto no_route;
-	skb_dst_set(nskb, dst);
+	skb_reserve(head, packet->overhead + MAX_HEADER);
 
 	/* Build the SCTP header.  */
-	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
-	skb_reset_transport_header(nskb);
+	sh = (struct sctphdr *)skb_push(head, sizeof(struct sctphdr));
+	skb_reset_transport_header(head);
 	sh->source = htons(packet->source_port);
 	sh->dest   = htons(packet->destination_port);
 
@@ -441,90 +450,164 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	sh->vtag     = htonl(packet->vtag);
 	sh->checksum = 0;
 
-	/**
-	 * 6.10 Bundling
-	 *
-	 *    An endpoint bundles chunks by simply including multiple
-	 *    chunks in one outbound SCTP packet.  ...
+	/* Set the owning socket so that we know where to get the
+	 * destination IP address.
 	 */
+	sctp_packet_set_owner_w(head, sk);
 
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
+	if (!sctp_transport_dst_check(tp)) {
+		sctp_transport_route(tp, NULL, sctp_sk(sk));
+		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
+			sctp_assoc_sync_pmtu(sk, asoc);
+		}
+	}
+	dst = dst_clone(tp->dst);
+	if (!dst)
+		goto no_route;
+	skb_dst_set(head, dst);
 
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
-
-			if (!chunk->resent && !tp->rto_pending) {
-				chunk->rtt_in_progress = 1;
-				tp->rto_pending = 1;
+	do {
+		/* Set up convenience variables... */
+		chunk = list_entry(packet->chunk_list.next, struct sctp_chunk, list);
+		WARN_ON(sk != chunk->skb->sk); /* XXX */
+
+		/* Calculate packet size, so it fits in PMTU. Leave
+		 * other chunks for the next packets. */
+		if (gso) {
+			pkt_size = packet->overhead;
+			list_for_each_entry(chunk, &packet->chunk_list, list) {
+				int padded = WORD_ROUND(chunk->skb->len);
+				if (pkt_size + padded > tp->pathmtu)
+					break;
+				pkt_size += padded;
 			}
 
-			has_data = 1;
+			/* Allocate the new skb.  */
+			nskb = alloc_skb(pkt_size + MAX_HEADER, GFP_ATOMIC);
+
+			/* Make sure the outbound skb has enough header room reserved. */
+			if (nskb)
+				skb_reserve(nskb, packet->overhead + MAX_HEADER);
 		}
+		if (!nskb)
+			goto nomem;
+
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
+		 */
+
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
 
-		padding = WORD_ROUND(chunk->skb->len) - chunk->skb->len;
-		if (padding)
-			memset(skb_put(chunk->skb, padding), 0, padding);
+			/* if this is the auth chunk that we are adding,
+			 * store pointer where it will be added and put
+			 * the auth into the packet.
+			 */
+			if (chunk == packet->auth) {
+				auth = skb_tail_pointer(nskb);
+			}
+
+			memcpy(skb_put(nskb, chunk->skb->len),
+				       chunk->skb->data, chunk->skb->len);
+
+			pr_debug("*** Chunk:%p[%s] %s 0x%x, length:%d, chunk->skb->len:%d, "
+				 "rtt_in_progress:%d\n", chunk,
+				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)),
+				 chunk->has_tsn ? "TSN" : "No TSN",
+				 chunk->has_tsn ? ntohl(chunk->subh.data_hdr->tsn) : 0,
+				 ntohs(chunk->chunk_hdr->length), chunk->skb->len,
+				 chunk->rtt_in_progress);
+
+			/*
+			 * If this is a control chunk, this is our last
+			 * reference. Free data chunks after they've been
+			 * acknowledged or have failed.
+			 * Re-queue auth chunks if needed.
+			 */
+			pkt_size -= WORD_ROUND(chunk->skb->len);
+
+			if (chunk == packet->auth && !list_empty(&packet->chunk_list))
+				list_add(&chunk->list, &packet->chunk_list);
+			else if (!sctp_chunk_is_data(chunk))
+				sctp_chunk_free(chunk);
 
-		/* if this is the auth chunk that we are adding,
-		 * store pointer where it will be added and put
-		 * the auth into the packet.
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
 		 */
-		if (chunk == packet->auth)
-			auth = skb_tail_pointer(nskb);
-
-		memcpy(skb_put(nskb, chunk->skb->len),
-			       chunk->skb->data, chunk->skb->len);
-
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
+		if (auth)
+			sctp_auth_calculate_hmac(asoc, nskb,
+						(struct sctp_auth_chunk *)auth,
+						GFP_ATOMIC);
+
+		/* Set up the IP options.  */
+		/* BUG: not implemented
+		 * For v4 this all lives somewhere in sk->sk_opt...
 		 */
-		if (!sctp_chunk_is_data(chunk))
-			sctp_chunk_free(chunk);
-	}
 
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
-					(struct sctp_auth_chunk *)auth,
-					GFP_ATOMIC);
+		/* Dump that on IP!  */
+		if (asoc) {
+			asoc->stats.opackets++;
+			if (asoc->peer.last_sent_to != tp)
+				/* Considering the multiple CPU scenario, this is a
+				 * "correcter" place for last_sent_to.  --xguo
+				 */
+				asoc->peer.last_sent_to = tp;
+		}
+
+
+		if (!gso ||
+		    skb_shinfo(head)->gso_segs >= sk->sk_gso_max_segs)
+//		    head->len + asoc->pathmtu >= sk->sk_gso_max_size)
+			break;
+
+		if (skb_gro_receive(&head, nskb))
+			goto nomem;
+		skb_shinfo(head)->gso_segs++;
+		/* FIXME: below is a lie */
+		skb_shinfo(head)->gso_size = 1;
+		nskb = NULL;
+	} while (!list_empty(&packet->chunk_list));
 
 	/* 2) Calculate the Adler-32 checksum of the whole packet,
 	 *    including the SCTP common header and all the
@@ -532,16 +615,21 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 *
 	 * Note: Adler-32 is no longer applicable, as has been replaced
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
+	 *
+	 * If it's a GSO packet, it's postponed to sctp_skb_segment.
 	 */
-	if (!sctp_checksum_disable) {
+	if (!sctp_checksum_disable || gso) {
 		if (!(dst->dev->features & NETIF_F_SCTP_CRC) ||
 		    (dst_xfrm(dst) != NULL) || packet->ipfragok) {
-			sh->checksum = sctp_compute_cksum(nskb, 0);
+			if (!gso)
+				sh->checksum = sctp_compute_cksum(head, 0);
+			else
+				head->ip_summed = CHECKSUM_UNNECESSARY;
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
 
@@ -557,22 +645,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * Note: The works for IPv6 layer checks this bit too later
 	 * in transmission.  See IP6_ECN_flow_xmit().
 	 */
-	tp->af_specific->ecn_capable(nskb->sk);
-
-	/* Set up the IP options.  */
-	/* BUG: not implemented
-	 * For v4 this all lives somewhere in sk->sk_opt...
-	 */
-
-	/* Dump that on IP!  */
-	if (asoc) {
-		asoc->stats.opackets++;
-		if (asoc->peer.last_sent_to != tp)
-			/* Considering the multiple CPU scenario, this is a
-			 * "correcter" place for last_sent_to.  --xguo
-			 */
-			asoc->peer.last_sent_to = tp;
-	}
+	tp->af_specific->ecn_capable(head->sk);
 
 	if (has_data) {
 		struct timer_list *timer;
@@ -589,16 +662,23 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 		}
 	}
 
-	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", nskb->len);
+	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", head->len);
 
-	nskb->ignore_df = packet->ipfragok;
-	tp->af_specific->sctp_xmit(nskb, tp);
+	head->ignore_df = packet->ipfragok;
+	printk("%s %d %d %d\n", __func__, head->len,
+	       packet->transport->pathmtu,
+	       packet->transport->pathmtu - packet->overhead);
+	if (gso)
+		skb_shinfo(head)->gso_type = SKB_GSO_SCTP;
+	tp->af_specific->sctp_xmit(head, tp);
 
 out:
 	sctp_packet_reset(packet);
+	sk_dst_reset(sk); /* FIXME: double check */
 	return err;
 no_route:
 	kfree_skb(nskb);
+	kfree_skb(head);
 
 	if (asoc)
 		IP_INC_STATS(sock_net(asoc->base.sk), IPSTATS_MIB_OUTNOROUTES);
@@ -635,7 +715,7 @@ nomem:
 static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 					   struct sctp_chunk *chunk)
 {
-	size_t datasize, rwnd, inflight, flight_size;
+	size_t datasize, rwnd, inflight, flight_size, maxsize;
 	struct sctp_transport *transport = packet->transport;
 	struct sctp_association *asoc = transport->asoc;
 	struct sctp_outq *q = &asoc->outqueue;
@@ -705,7 +785,15 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	/* Check whether this chunk and all the rest of pending data will fit
 	 * or delay in hopes of bundling a full sized packet.
 	 */
-	if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
+	if (packet->ipfragok) {
+		/* Means chunk won't fit and needs fragmentation at
+		 * transport level, so we can't do GSO.
+		 */
+		maxsize = transport->pathmtu;
+	} else {
+		maxsize = transport->dst->dev->gso_max_size;
+	}
+	if (chunk->skb->len + q->out_qlen >= maxsize - packet->overhead)
 		/* Enough data queued to fill a packet */
 		return SCTP_XMIT_OK;
 
@@ -764,6 +852,8 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 
 	/* Decide if we need to fragment or resubmit later. */
 	if (too_big) {
+		struct net_device *dev = packet->transport->dst->dev;
+
 		/* It's OK to fragmet at IP level if any one of the following
 		 * is true:
 		 * 	1. The packet is empty (meaning this chunk is greater
@@ -779,9 +869,11 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 			 * actually hit this condition
 			 */
 			packet->ipfragok = 1;
-		} else {
+		} else if (psize + chunk_len > dev->gso_max_size - packet->overhead) {
+			/* Hit GSO limit, gotta flush */
 			retval = SCTP_XMIT_PMTU_FULL;
 		}
+		/* Otherwise it will fit in the GSO packet */
 	}
 
 	return retval;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5ca2ebfe0be83882fcb841de6fa8029b6455ef85..064e5d375e612f2ec745f384d35f0e4c6b96212c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4001,6 +4001,8 @@ static int sctp_init_sock(struct sock *sk)
 		return -ESOCKTNOSUPPORT;
 	}
 
+	sk->sk_gso_type = SKB_GSO_SCTP;
+
 	/* Initialize default send parameters. These parameters can be
 	 * modified with the SCTP_DEFAULT_SEND_PARAM socket option.
 	 */
-- 
2.5.0
