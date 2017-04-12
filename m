From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 09/14] esp: Add gso handlers for esp4 and esp6
Date: Wed, 12 Apr 2017 08:26:48 +0200
Message-ID: <1491978413-5700-10-git-send-email-steffen.klassert@secunet.com>
References: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57610 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751205AbdDLG3r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:29:47 -0400
In-Reply-To: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the xfrm_type by an encap function pointer
and implements esp4_gso_encap and esp6_gso_encap. These functions
doing the basic esp encapsulation for a GSO packet. In case the
GSO packet needs to be segmented in software, we add gso_segment
functions. This codepath is going to be used on esp hardware
offloads.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c         | 10 +++++-
 net/ipv4/esp4_offload.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/esp6.c         |  8 +++--
 net/ipv6/esp6_offload.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_replay.c  |  3 +-
 5 files changed, 203 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 91e6a40..4382f30 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -161,11 +161,19 @@ static struct ip_esp_hdr *esp_output_set_extra(struct sk_buff *skb,
 	 * encryption.
 	 */
 	if ((x->props.flags & XFRM_STATE_ESN)) {
+		__u32 seqhi;
+		struct xfrm_offload *xo = xfrm_offload(skb);
+
+		if (xo)
+			seqhi = xo->seq.hi;
+		else
+			seqhi = XFRM_SKB_CB(skb)->seq.output.hi;
+
 		extra->esphoff = (unsigned char *)esph -
 				 skb_transport_header(skb);
 		esph = (struct ip_esp_hdr *)((unsigned char *)esph - 4);
 		extra->seqhi = esph->spi;
-		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		esph->seq_no = htonl(seqhi);
 	}
 
 	esph->spi = x->id.spi;
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index efaaa44..1e39564 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -84,6 +84,97 @@ static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
 	return NULL;
 }
 
+static void esp4_gso_encap(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ip_esp_hdr *esph;
+	struct iphdr *iph = ip_hdr(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	int proto = iph->protocol;
+
+	skb_push(skb, -skb_network_offset(skb));
+	esph = ip_esp_hdr(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	esph->spi = x->id.spi;
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+
+	xo->proto = proto;
+}
+
+static struct sk_buff *esp4_gso_segment(struct sk_buff *skb,
+				        netdev_features_t features)
+{
+	__u32 seq;
+	int err = 0;
+	struct sk_buff *skb2;
+	struct xfrm_state *x;
+	struct ip_esp_hdr *esph;
+	struct crypto_aead *aead;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	netdev_features_t esp_features = features;
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	if (!xo)
+		goto out;
+
+	seq = xo->seq.low;
+
+	x = skb->sp->xvec[skb->sp->len - 1];
+	aead = x->data;
+	esph = ip_esp_hdr(skb);
+
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
+	if (!(features & NETIF_F_HW_ESP))
+		esp_features = features & ~(NETIF_F_SG | NETIF_F_CSUM_MASK);
+
+	segs = x->outer_mode->gso_segment(x, skb, esp_features);
+	if (IS_ERR_OR_NULL(segs))
+		goto out;
+
+	__skb_pull(skb, skb->data - skb_mac_header(skb));
+
+	skb2 = segs;
+	do {
+		struct sk_buff *nskb = skb2->next;
+
+		xo = xfrm_offload(skb2);
+		xo->flags |= XFRM_GSO_SEGMENT;
+		xo->seq.low = seq;
+		xo->seq.hi = xfrm_replay_seqhi(x, seq);
+
+		if(!(features & NETIF_F_HW_ESP))
+			xo->flags |= CRYPTO_FALLBACK;
+
+		x->outer_mode->xmit(x, skb2);
+
+		err = x->type_offload->xmit(x, skb2, esp_features);
+		if (err) {
+			kfree_skb_list(segs);
+			return ERR_PTR(err);
+		}
+
+		if (!skb_is_gso(skb2))
+			seq++;
+		else
+			seq += skb_shinfo(skb2)->gso_segs;
+
+		skb_push(skb2, skb2->mac_len);
+		skb2 = nskb;
+	} while (skb2);
+
+out:
+	return segs;
+}
+
 static int esp_input_tail(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct crypto_aead *aead = x->data;
@@ -173,6 +264,7 @@ static int esp_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features_
 static const struct net_offload esp4_offload = {
 	.callbacks = {
 		.gro_receive = esp4_gro_receive,
+		.gso_segment = esp4_gso_segment,
 	},
 };
 
@@ -182,6 +274,7 @@ static const struct xfrm_type_offload esp_type_offload = {
 	.proto	     	= IPPROTO_ESP,
 	.input_tail	= esp_input_tail,
 	.xmit		= esp_xmit,
+	.encap		= esp4_gso_encap,
 };
 
 static int __init esp4_offload_init(void)
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index cc654a7..82d3da8 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -179,9 +179,14 @@ static struct ip_esp_hdr *esp_output_set_esn(struct sk_buff *skb,
 	 * encryption.
 	 */
 	if ((x->props.flags & XFRM_STATE_ESN)) {
+		struct xfrm_offload *xo = xfrm_offload(skb);
+
 		esph = (void *)(skb_transport_header(skb) - sizeof(__be32));
 		*seqhi = esph->spi;
-		esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		if (xo)
+			esph->seq_no = htonl(xo->seq.hi);
+		else
+			esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
 	}
 
 	esph->spi = x->id.spi;
@@ -223,7 +228,6 @@ int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 	struct sk_buff *trailer;
 	int tailen = esp->tailen;
 
-	*skb_mac_header(skb) = IPPROTO_ESP;
 	esph = ip_esp_hdr(skb);
 
 	if (!skb_cloned(skb)) {
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index 5dd20c0..06e9721 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -86,6 +86,97 @@ static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
 	return NULL;
 }
 
+static void esp6_gso_encap(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ip_esp_hdr *esph;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	int proto = iph->nexthdr;
+
+	skb_push(skb, -skb_network_offset(skb));
+	esph = ip_esp_hdr(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
+
+	esph->spi = x->id.spi;
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
+
+	xo->proto = proto;
+}
+
+static struct sk_buff *esp6_gso_segment(struct sk_buff *skb,
+				        netdev_features_t features)
+{
+	__u32 seq;
+	int err = 0;
+	struct sk_buff *skb2;
+	struct xfrm_state *x;
+	struct ip_esp_hdr *esph;
+	struct crypto_aead *aead;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	netdev_features_t esp_features = features;
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	if (xo)
+		goto out;
+
+	seq = xo->seq.low;
+
+	x = skb->sp->xvec[skb->sp->len - 1];
+	aead = x->data;
+	esph = ip_esp_hdr(skb);
+
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
+	if (!(features & NETIF_F_HW_ESP))
+		esp_features = features & ~(NETIF_F_SG | NETIF_F_CSUM_MASK);
+
+	segs = x->outer_mode->gso_segment(x, skb, esp_features);
+	if (IS_ERR_OR_NULL(segs))
+		goto out;
+
+	__skb_pull(skb, skb->data - skb_mac_header(skb));
+
+	skb2 = segs;
+	do {
+		struct sk_buff *nskb = skb2->next;
+
+		xo = xfrm_offload(skb2);
+		xo->flags |= XFRM_GSO_SEGMENT;
+		xo->seq.low = seq;
+		xo->seq.hi = xfrm_replay_seqhi(x, seq);
+
+		if(!(features & NETIF_F_HW_ESP))
+			xo->flags |= CRYPTO_FALLBACK;
+
+		x->outer_mode->xmit(x, skb2);
+
+		err = x->type_offload->xmit(x, skb2, esp_features);
+		if (err) {
+			kfree_skb_list(segs);
+			return ERR_PTR(err);
+		}
+
+		if (!skb_is_gso(skb2))
+			seq++;
+		else
+			seq += skb_shinfo(skb2)->gso_segs;
+
+		skb_push(skb2, skb2->mac_len);
+		skb2 = nskb;
+	} while (skb2);
+
+out:
+	return segs;
+}
+
 static int esp6_input_tail(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct crypto_aead *aead = x->data;
@@ -176,6 +267,7 @@ static int esp6_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features
 static const struct net_offload esp6_offload = {
 	.callbacks = {
 		.gro_receive = esp6_gro_receive,
+		.gso_segment = esp6_gso_segment,
 	},
 };
 
@@ -185,6 +277,7 @@ static const struct xfrm_type_offload esp6_type_offload = {
 	.proto	     	= IPPROTO_ESP,
 	.input_tail	= esp6_input_tail,
 	.xmit		= esp6_xmit,
+	.encap		= esp6_gso_encap,
 };
 
 static int __init esp6_offload_init(void)
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
2.7.4
