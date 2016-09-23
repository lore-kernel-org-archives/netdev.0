From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 07/11] esp: Add gso handlers for esp4 and esp6
Date: Fri, 23 Sep 2016 09:53:44 +0200
Message-ID: <1474617228-26103-8-git-send-email-steffen.klassert@secunet.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46014 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758464AbcIWHyG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:06 -0400
In-Reply-To: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the xfrm_type by an encap function pointer
and implements esp4_gso_encap and esp6_gso_encap. These functions
doing the basic esp encapsulation for a GSO packet. In case the
GSP packet needs to be segmented in software, we add gso_segment
functions. The secpath is extended to pass the needed informations
down the layers. This codepath is going to be used on esp hardware
offloads.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |  14 ++++++-
 net/ipv4/esp4.c         |  29 +++++++++++--
 net/ipv4/esp4_offload.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/esp6.c         |  27 +++++++++++-
 net/ipv6/esp6_offload.c | 106 +++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_replay.c  |   3 +-
 6 files changed, 280 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5016fa2..1af8489 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -372,6 +372,7 @@ struct xfrm_type {
 	int			(*init_state)(struct xfrm_state *x);
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
+	void			(*encap)(struct xfrm_state *, struct sk_buff *pskb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
 	int			(*reject)(struct xfrm_state *, struct sk_buff *,
 					  const struct flowi *);
@@ -979,7 +980,18 @@ void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
 struct sec_path {
 	atomic_t		refcnt;
 	int			len;
-	struct xfrm_state	*xvec[XFRM_MAX_DEPTH];
+
+        /* Output sequence number for replay protection on offloading. */
+	struct {
+		__u32 low;
+		__u32 hi;
+	} seq;
+
+	struct xfrm_state		*xvec[XFRM_MAX_DEPTH];
+
+	__u8				proto;
+	__u8				flags;
+#define SKB_GSO_SEGMENT			1
 };
 
 static inline int secpath_exists(struct sk_buff *skb)
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index cb1c10b..f61ba3c2 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -182,6 +182,22 @@ static void esp_output_done_esn(struct crypto_async_request *base, int err)
 	esp_output_done(base, err);
 }
 
+static void esp4_gso_encap(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ip_esp_hdr *esph;
+	struct iphdr *iph = ip_hdr(skb);
+	int proto = iph->protocol;
+
+	skb_push(skb, -skb_network_offset(skb));
+	esph = ip_esp_hdr(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	esph->spi = x->id.spi;
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+
+	skb->sp->proto = proto;
+}
+
 static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct esp_output_extra *extra;
@@ -207,7 +223,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int extralen;
 	int tailen;
 	__be64 seqno;
-	__u8 proto = *skb_mac_header(skb);
+	__u8 proto;
 
 	/* skb is pure payload to encrypt */
 
@@ -231,12 +247,18 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	assoclen = sizeof(*esph);
 	extralen = 0;
 
+	if (skb->sp && (skb->sp->flags & SKB_GSO_SEGMENT)) {
+		proto = skb->sp->proto;
+	} else {
+		proto = *skb_mac_header(skb);
+		*skb_mac_header(skb) = IPPROTO_ESP;
+	}
+
 	if (x->props.flags & XFRM_STATE_ESN) {
 		extralen += sizeof(*extra);
 		assoclen += sizeof(__be32);
 	}
 
-	*skb_mac_header(skb) = IPPROTO_ESP;
 	esph = ip_esp_hdr(skb);
 
 	/* this is non-NULL only with UDP Encapsulation */
@@ -942,7 +964,8 @@ static const struct xfrm_type esp_type =
 	.destructor	= esp_destroy,
 	.get_mtu	= esp4_get_mtu,
 	.input		= esp_input,
-	.output		= esp_output
+	.output		= esp_output,
+	.encap		= esp4_gso_encap,
 };
 
 static struct xfrm4_protocol esp4_protocol = {
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index 7277d15..d0831a8 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -71,10 +71,118 @@ static int esp4_gro_complete(struct sk_buff *skb, int nhoff)
 	return err;
 }
 
+static struct sk_buff *esp4_gso_segment(struct sk_buff *skb,
+				        netdev_features_t features)
+{
+	struct ip_esp_hdr *esph;
+	struct sk_buff *skb2;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct xfrm_state *x;
+	struct sec_path *sp;
+	struct crypto_aead *aead;
+	int err = 0;
+	const struct net_offload *ops;
+	int omaclen;
+	__u32 seq;
+	__u32 seqhi;
+
+	sp = skb->sp;
+	if (!sp || !sp->len)
+		goto out;
+
+	seq = sp->seq.low;
+	seqhi = sp->seq.hi;
+
+	x = sp->xvec[sp->len - 1];
+	aead = x->data;
+	esph = ip_esp_hdr(skb);
+
+	omaclen = skb->mac_len;
+	if (esph->spi != x->id.spi)
+		goto out;
+
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead)))
+		goto out;
+
+	__skb_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead));
+
+	skb->encap_hdr_csum = 1;
+
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
+		__skb_push(skb, skb->mac_len);
+		segs = skb_mac_gso_segment(skb, features);
+	} else {
+		skb->transport_header += x->props.header_len;
+		ops = rcu_dereference(inet_offloads[sp->proto]);
+		if (likely(ops && ops->callbacks.gso_segment))
+			segs = ops->callbacks.gso_segment(skb, features);
+	}
+	if (IS_ERR(segs))
+		goto out;
+	if (segs == NULL)
+		return ERR_PTR(-EINVAL);
+	__skb_pull(skb, skb->data - skb_mac_header(skb));
+
+	skb2 = segs;
+	do {
+		struct sk_buff *nskb = skb2->next;
+
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
+			skb2->network_header = skb2->network_header - x->props.header_len;
+			skb2->transport_header = skb2->network_header + sizeof(struct iphdr);
+			skb_reset_mac_len(skb2);
+			skb_pull(skb2, skb2->mac_len + x->props.header_len);
+		} else {
+			/* skb2 mac and data are pointing at the start of
+			 * mac address. Pull data forward to point to IP
+			 * payload past ESP header (i.e., transport data
+			 * that needs to be encrypted).
+			 * When IPsec transport mode is stacked with a tunnel,
+			 * the skb2->data needs to point at the inner IP
+			 * header for tunnelled packets. After ->gso_segment,
+			 * the skb2 wil have the network/ip header pointing
+			 * at the inner IP header, and the transport_header
+			 * will be pointing at the inner IP payload. Thus we
+			 * need to use omaclen and the outer iphdr length to
+			 * make sure that pointers are set up correctly in
+			 * every case.
+			 */
+			struct iphdr *oiph =
+				(struct iphdr *)(skb2->data + omaclen);
+			int ihl = oiph->ihl * 4;
+
+			 __skb_pull(skb2, omaclen + ihl + x->props.header_len);
+
+			/* move ->transport_header to point to esp header */
+			skb_reset_transport_header(skb2);
+			skb2->transport_header -= x->props.header_len;
+		}
+
+		skb2->sp->flags |= SKB_GSO_SEGMENT;
+		skb2->sp->seq.low = seq;
+		skb2->sp->seq.hi = xfrm_replay_seqhi(x, ntohl(seq));
+
+		err = x->type->output(x, skb2);
+		if (err) {
+			kfree_skb_list(segs);
+			return ERR_PTR(err);
+		}
+
+		seq++;
+
+		skb_push(skb2, skb2->mac_len);
+		skb2 = nskb;
+	} while (skb2);
+
+out:
+	return segs;
+}
+
 static const struct net_offload esp4_offload = {
 	.callbacks = {
 		.gro_receive = esp4_gro_receive,
 		.gro_complete = esp4_gro_complete,
+		.gso_segment = esp4_gso_segment,
 	},
 };
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 2280bc6..9bcb32b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -198,6 +198,22 @@ static void esp_output_done_esn(struct crypto_async_request *base, int err)
 	esp_output_done(base, err);
 }
 
+static void esp6_gso_encap(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ip_esp_hdr *esph;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	int proto = iph->nexthdr;
+
+	skb_push(skb, -skb_network_offset(skb));
+	esph = ip_esp_hdr(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	esph->spi = x->id.spi;
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+
+	skb->sp->proto = proto;
+}
+
 static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
@@ -223,7 +239,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *vaddr;
 	__be32 *seqhi;
 	__be64 seqno;
-	__u8 proto = *skb_mac_header(skb);
+	__u8 proto;
 
 	/* skb is pure payload to encrypt */
 	aead = x->data;
@@ -247,12 +263,18 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	assoclen = sizeof(*esph);
 	seqhilen = 0;
 
+	if (skb->sp && (skb->sp->flags & SKB_GSO_SEGMENT)) {
+		proto = skb->sp->proto;
+	} else {
+		proto = *skb_mac_header(skb);
+		*skb_mac_header(skb) = IPPROTO_ESP;
+	}
+
 	if (x->props.flags & XFRM_STATE_ESN) {
 		seqhilen += sizeof(__be32);
 		assoclen += seqhilen;
 	}
 
-	*skb_mac_header(skb) = IPPROTO_ESP;
 	esph = ip_esp_hdr(skb);
 
 	if (!skb_cloned(skb)) {
@@ -871,6 +893,7 @@ static const struct xfrm_type esp6_type = {
 	.get_mtu	= esp6_get_mtu,
 	.input		= esp6_input,
 	.output		= esp6_output,
+	.encap		= esp6_gso_encap,
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index e0006cf..51efab0 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -75,10 +75,116 @@ static int esp6_gro_complete(struct sk_buff *skb, int nhoff)
 	return err;
 }
 
+static struct sk_buff *esp6_gso_segment(struct sk_buff *skb,
+				        netdev_features_t features)
+{
+	struct ip_esp_hdr *esph;
+	struct sk_buff *skb2;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct xfrm_state *x;
+	struct sec_path *sp;
+	struct crypto_aead *aead;
+	int err = 0;
+	const struct net_offload *ops;
+	int omaclen;
+	__u32 seq;
+	__u32 seqhi;
+
+	sp = skb->sp;
+	if (!sp || !sp->len)
+		goto out;
+
+	seq = sp->seq.low;
+	seqhi = sp->seq.hi;
+
+	x = sp->xvec[sp->len - 1];
+	aead = x->data;
+	esph = ip_esp_hdr(skb);
+
+	omaclen = skb->mac_len;
+	if (esph->spi != x->id.spi)
+		goto out;
+
+	if (!pskb_may_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead)))
+		goto out;
+
+	__skb_pull(skb, sizeof(*esph) + crypto_aead_ivsize(aead));
+
+	skb->encap_hdr_csum = 1;
+
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
+		__skb_push(skb, skb->mac_len);
+		segs = skb_mac_gso_segment(skb, features);
+	} else {
+		skb->transport_header += x->props.header_len;
+		ops = rcu_dereference(inet_offloads[sp->proto]);
+		if (likely(ops && ops->callbacks.gso_segment))
+			segs = ops->callbacks.gso_segment(skb, features);
+	}
+	if (IS_ERR(segs))
+		goto out;
+	if (segs == NULL)
+		return ERR_PTR(-EINVAL);
+	__skb_pull(skb, skb->data - skb_mac_header(skb));
+
+	skb2 = segs;
+	do {
+		struct sk_buff *nskb = skb2->next;
+
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
+			skb2->network_header = skb2->network_header - x->props.header_len;
+			skb2->transport_header = skb2->network_header + sizeof(struct ipv6hdr);
+			skb_reset_mac_len(skb2);
+			skb_pull(skb2, skb2->mac_len + x->props.header_len);
+		} else {
+			/* skb2 mac and data are pointing at the start of
+			 * mac address. Pull data forward to point to IP
+			 * payload past ESP header (i.e., transport data
+			 * that needs to be encrypted).
+			 * When IPsec transport mode is stacked with a tunnel,
+			 * the skb2->data needs to point at the inner IP
+			 * header for tunnelled packets. After ->gso_segment,
+			 * the skb2 wil have the network/ip header pointing
+			 * at the inner IP header, and the transport_header
+			 * will be pointing at the inner IP payload. Thus we
+			 * need to use omaclen and the outer iphdr length to
+			 * make sure that pointers are set up correctly in
+			 * every case.
+			 */
+
+			 __skb_pull(skb2, omaclen + sizeof(struct ipv6hdr) + x->props.header_len);
+
+			/* move ->transport_header to point to esp header */
+			skb_reset_transport_header(skb2);
+			skb2->transport_header -= x->props.header_len;
+		}
+
+		skb2->sp->flags |= SKB_GSO_SEGMENT;
+		skb2->sp->seq.low = seq;
+		skb2->sp->seq.hi = xfrm_replay_seqhi(x, ntohl(seq));
+
+		err = x->type->output(x, skb2);
+		if (err) {
+			kfree_skb_list(segs);
+			return ERR_PTR(err);
+		}
+
+		seq++;
+
+		skb_push(skb2, skb2->mac_len);
+		skb2 = nskb;
+	} while (skb2);
+
+out:
+	return segs;
+}
+
+
 static const struct net_offload esp6_offload = {
 	.callbacks = {
 		.gro_receive = esp6_gro_receive,
 		.gro_complete = esp6_gro_complete,
+		.gso_segment = esp6_gso_segment,
 	},
 };
 
diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index cdc2e2e..20e68a3 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -45,7 +45,8 @@ u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq)
 
 	return seq_hi;
 }
-
+EXPORT_SYMBOL(xfrm_replay_seqhi);
+;
 static void xfrm_replay_notify(struct xfrm_state *x, int event)
 {
 	struct km_event c;
-- 
1.9.1
