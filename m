From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] gro: Handle inline VLAN tags
Date: Fri, 16 Nov 2012 20:17:10 +0000
Message-ID: <1353097030.2743.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41323 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab2KPURO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 15:17:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The receive paths for skbs with inline and out-of-line VLAN tags (VLAN
RX accleration) were made largely consistent in 2.6.37, with tags
pulled out by software as necessary.  However GRO doesn't do this, so
it is not effective for VLAN-tagged packets received on devices
without VLAN RX acceleration.

napi_gro_frags() must not free the skb and does not advance the
skb->data pointer, so cannot use vlan_untag().  Extract the core of
vlan_untag() into a new function __vlan_untag() that allows the offset
to the VLAN tag to be specified and returns an error code.  Add
kernel-doc comments for both those functions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Tested with sfc using both napi_gro_receive() and napi_gro_frags().  On
a Core i7 920 (Nehalem) system it increased TCP/IPv4 receive throughput
over a VLAN from ~8.0 to ~9.3 Gbit/s.

Ben.

 include/linux/if_vlan.h |    6 ++++
 net/8021q/vlan_core.c   |   60 ++++++++++++++++++++++++++++++++---------------
 net/core/dev.c          |   27 ++++++++++++++++----
 3 files changed, 68 insertions(+), 25 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index d06cc5c..a2167c3 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -91,6 +91,7 @@ extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern bool vlan_do_receive(struct sk_buff **skb);
+extern int __vlan_untag(struct sk_buff *skb, int offset);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
 extern int vlan_vid_add(struct net_device *dev, unsigned short vid);
@@ -126,6 +127,11 @@ static inline bool vlan_do_receive(struct sk_buff **skb)
 	return false;
 }
 
+static inline int __vlan_untag(struct sk_buff *skb, int offset)
+{
+	return 0;
+}
+
 static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
 	return skb;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 65e06ab..8486430 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -93,20 +93,53 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
-static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
+/**
+ *	__vlan_untag - pull VLAN tag out of 802.1q packet header
+ *	@skb: sk_buff to edit; may be cloned but not shared.
+ *	@offset: Offset from @skb->data to VLAN tag.  Must be either
+ *		0 or %ETH_HLEN.
+ *
+ *	This updates the @mac_header but no other header offset.  The
+ *	caller is expected to check the @protocol and that there is no
+ *	out-of-line tag before calling this.
+ */
+int __vlan_untag(struct sk_buff *skb, int offset)
 {
+	struct vlan_hdr *vhdr;
+	u16 vlan_tci;
+
+	if (unlikely(!pskb_may_pull(skb, offset + VLAN_HLEN)))
+		return -EINVAL;
+
+	vhdr = (struct vlan_hdr *) (skb->data + offset);
+	vlan_tci = ntohs(vhdr->h_vlan_TCI);
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
+
+	skb->len -= VLAN_HLEN;
+	skb_postpull_rcsum(skb, skb->data + offset, VLAN_HLEN);
+	skb->data += VLAN_HLEN;
+	vlan_set_encap_proto(skb, vhdr);
+
 	if (skb_cow(skb, skb_headroom(skb)) < 0)
-		return NULL;
-	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
+		return -ENOMEM;
+
+	memmove(skb->data + offset - ETH_HLEN,
+		skb->data + offset - VLAN_ETH_HLEN, 2 * ETH_ALEN);
 	skb->mac_header += VLAN_HLEN;
-	return skb;
+	return 0;
 }
 
+/**
+ *	vlan_untag - pull VLAN tag out of packet header, if appropriate
+ *	@skb: sk_buff to edit; may be cloned or shared.
+ *
+ *	If @skb has an inline VLAN tag and no out-of-line VLAN tag,
+ *	pull the tag out-of-line and reset all header offsets.  Return
+ *	the edited sk_buff.  If allocation fails or the VLAN tag is
+ *	invalid, free @skb and return NULL.
+ */
 struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
-	struct vlan_hdr *vhdr;
-	u16 vlan_tci;
-
 	if (unlikely(vlan_tx_tag_present(skb))) {
 		/* vlan_tci is already set-up so leave this for another time */
 		return skb;
@@ -116,18 +149,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 	if (unlikely(!skb))
 		goto err_free;
 
-	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
-		goto err_free;
-
-	vhdr = (struct vlan_hdr *) skb->data;
-	vlan_tci = ntohs(vhdr->h_vlan_TCI);
-	__vlan_hwaccel_put_tag(skb, vlan_tci);
-
-	skb_pull_rcsum(skb, VLAN_HLEN);
-	vlan_set_encap_proto(skb, vhdr);
-
-	skb = vlan_reorder_header(skb);
-	if (unlikely(!skb))
+	if (unlikely(__vlan_untag(skb, 0)))
 		goto err_free;
 
 	skb_reset_network_header(skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index b4978e2..9d658eb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3668,6 +3668,13 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
 
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
+	if (unlikely(skb->protocol == htons(ETH_P_8021Q)) &&
+	    !vlan_tx_tag_present(skb)) {
+		skb = vlan_untag(skb);
+		if (unlikely(!skb))
+			return GRO_DROP;
+	}
+
 	skb_gro_reset_offset(skb);
 
 	return napi_skb_finish(__napi_gro_receive(napi, skb), skb);
@@ -3743,11 +3750,8 @@ static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 	eth = skb_gro_header_fast(skb, off);
 	if (skb_gro_header_hard(skb, hlen)) {
 		eth = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!eth)) {
-			napi_reuse_skb(napi, skb);
-			skb = NULL;
-			goto out;
-		}
+		if (unlikely(!eth))
+			goto fail;
 	}
 
 	skb_gro_pull(skb, sizeof(*eth));
@@ -3758,8 +3762,19 @@ static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 	 */
 	skb->protocol = eth->h_proto;
 
-out:
+	if (unlikely(skb->protocol == htons(ETH_P_8021Q)) &&
+	    !vlan_tx_tag_present(skb)) {
+		if (unlikely(__vlan_untag(skb, sizeof(*eth))))
+			goto fail;
+		skb_gro_reset_offset(skb);
+		skb_gro_pull(skb, sizeof(*eth));
+	}
+
 	return skb;
+
+fail:
+	napi_reuse_skb(napi, skb);
+	return NULL;
 }
 
 gro_result_t napi_gro_frags(struct napi_struct *napi)
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
