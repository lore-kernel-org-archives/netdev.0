From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 4/6] 6lowpan: fix fragmentation
Date: Wed, 14 May 2014 17:43:09 +0200
Message-ID: <1400082191-16493-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400082191-16493-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently, 6lowpan creates one 802.15.4 MAC header for the original
packet the device was given by upper layers and reuses this header for
all fragments, if fragmentation is required. This also reuses frame
sequence numbers, which must not happen. 6lowpan also has issues with
fragmentation in the presence of security headers, since those may imply
the presence of trailing fields that are not accounted for by the
fragmentation code right now.

Fix both of these issues by properly allocating fragment skbs with
headromm and tailroom as specified by the underlying device, create one
header for each skb instead of reusing the original header, let the
underlying device do the rest.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/ieee802154/6lowpan_rtnl.c |  198 ++++++++++++++++++++++-------------------
 1 file changed, 104 insertions(+), 94 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index d0191c5..1ae8a56 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -220,139 +220,149 @@ static int lowpan_set_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int
-lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
-		     int mlen, int plen, int offset, int type)
+static struct sk_buff*
+lowpan_alloc_frag(struct sk_buff *skb, int size,
+		  const struct ieee802154_hdr *master_hdr)
 {
+	struct net_device *real_dev = lowpan_dev_info(skb->dev)->real_dev;
 	struct sk_buff *frag;
-	int hlen;
-
-	hlen = (type == LOWPAN_DISPATCH_FRAG1) ?
-			LOWPAN_FRAG1_HEAD_SIZE : LOWPAN_FRAGN_HEAD_SIZE;
-
-	raw_dump_inline(__func__, "6lowpan fragment header", head, hlen);
+	int rc;
+
+	frag = alloc_skb(real_dev->hard_header_len +
+			 real_dev->needed_tailroom + size,
+			 GFP_ATOMIC);
+
+	if (likely(frag)) {
+		frag->dev = real_dev;
+		frag->priority = skb->priority;
+		skb_reserve(frag, real_dev->hard_header_len);
+		skb_reset_network_header(frag);
+		*mac_cb(frag) = *mac_cb(skb);
+
+		rc = dev_hard_header(frag, real_dev, 0, &master_hdr->dest,
+				     &master_hdr->source, size);
+		if (rc < 0) {
+			kfree_skb(frag);
+			return ERR_PTR(-rc);
+		}
+	} else {
+		frag = ERR_PTR(ENOMEM);
+	}
 
-	frag = netdev_alloc_skb(skb->dev,
-				hlen + mlen + plen + IEEE802154_MFR_SIZE);
-	if (!frag)
-		return -ENOMEM;
+	return frag;
+}
 
-	frag->priority = skb->priority;
+static int
+lowpan_xmit_fragment(struct sk_buff *skb, const struct ieee802154_hdr *wpan_hdr,
+		     u8 *frag_hdr, int frag_hdrlen,
+		     int offset, int len)
+{
+	struct sk_buff *frag;
 
-	/* copy header, MFR and payload */
-	skb_put(frag, mlen);
-	skb_copy_to_linear_data(frag, skb_mac_header(skb), mlen);
+	raw_dump_inline(__func__, " fragment header", frag_hdr, frag_hdrlen);
 
-	skb_put(frag, hlen);
-	skb_copy_to_linear_data_offset(frag, mlen, head, hlen);
+	frag = lowpan_alloc_frag(skb, frag_hdrlen + len, wpan_hdr);
+	if (IS_ERR(frag))
+		return -PTR_ERR(frag);
 
-	skb_put(frag, plen);
-	skb_copy_to_linear_data_offset(frag, mlen + hlen,
-				       skb_network_header(skb) + offset, plen);
+	memcpy(skb_put(frag, frag_hdrlen), frag_hdr, frag_hdrlen);
+	memcpy(skb_put(frag, len), skb_network_header(skb) + offset, len);
 
-	raw_dump_table(__func__, " raw fragment dump", frag->data, frag->len);
+	raw_dump_table(__func__, " fragment dump", frag->data, frag->len);
 
 	return dev_queue_xmit(frag);
 }
 
 static int
-lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
+lowpan_xmit_fragmented(struct sk_buff *skb, struct net_device *dev,
+		       const struct ieee802154_hdr *wpan_hdr)
 {
-	int err;
-	u16 dgram_offset, dgram_size, payload_length, header_length,
-	    lowpan_size, frag_plen, offset;
-	__be16 tag;
-	u8 head[5];
-
-	header_length = skb->mac_len;
-	payload_length = skb->len - header_length;
-	tag = lowpan_dev_info(dev)->fragment_tag++;
-	lowpan_size = skb_network_header_len(skb);
+	u16 dgram_size, dgram_offset;
+	__be16 frag_tag;
+	u8 frag_hdr[5];
+	int frag_cap, frag_len, payload_cap, rc;
+	int skb_unprocessed, skb_offset;
+
 	dgram_size = lowpan_uncompress_size(skb, &dgram_offset) -
-		     header_length;
+		     skb->mac_len;
+	frag_tag = lowpan_dev_info(dev)->fragment_tag++;
 
-	/* first fragment header */
-	head[0] = LOWPAN_DISPATCH_FRAG1 | ((dgram_size >> 8) & 0x7);
-	head[1] = dgram_size & 0xff;
-	memcpy(head + 2, &tag, sizeof(tag));
+	frag_hdr[0] = LOWPAN_DISPATCH_FRAG1 | ((dgram_size >> 8) & 0x07);
+	frag_hdr[1] = dgram_size & 0xff;
+	memcpy(frag_hdr + 2, &frag_tag, sizeof(frag_tag));
 
-	/* calc the nearest payload length(divided to 8) for first fragment
-	 * which fits into a IEEE802154_MTU
-	 */
-	frag_plen = round_down(IEEE802154_MTU - header_length -
-			       LOWPAN_FRAG1_HEAD_SIZE - lowpan_size -
-			       IEEE802154_MFR_SIZE, 8);
-
-	err = lowpan_fragment_xmit(skb, head, header_length,
-				   frag_plen + lowpan_size, 0,
-				   LOWPAN_DISPATCH_FRAG1);
-	if (err) {
-		pr_debug("%s unable to send FRAG1 packet (tag: %d)",
-			 __func__, tag);
-		goto exit;
-	}
+	payload_cap = ieee802154_max_payload(wpan_hdr);
 
-	offset = lowpan_size + frag_plen;
-	dgram_offset += frag_plen;
+	frag_len = round_down(payload_cap - LOWPAN_FRAG1_HEAD_SIZE -
+			      skb_network_header_len(skb), 8);
 
-	/* next fragment header */
-	head[0] &= ~LOWPAN_DISPATCH_FRAG1;
-	head[0] |= LOWPAN_DISPATCH_FRAGN;
+	skb_offset = skb_network_header_len(skb);
+	skb_unprocessed = skb->len - skb->mac_len - skb_offset;
 
-	frag_plen = round_down(IEEE802154_MTU - header_length -
-			       LOWPAN_FRAGN_HEAD_SIZE - IEEE802154_MFR_SIZE, 8);
+	rc = lowpan_xmit_fragment(skb, wpan_hdr, frag_hdr,
+				  LOWPAN_FRAG1_HEAD_SIZE, 0,
+				  frag_len + skb_network_header_len(skb));
+	if (rc) {
+		pr_debug("%s unable to send FRAG1 packet (tag: %d)",
+			 __func__, frag_tag);
+		goto err;
+	}
 
-	while (payload_length - offset > 0) {
-		int len = frag_plen;
+	frag_hdr[0] &= ~LOWPAN_DISPATCH_FRAG1;
+	frag_hdr[0] |= LOWPAN_DISPATCH_FRAGN;
+	frag_cap = round_down(payload_cap - LOWPAN_FRAGN_HEAD_SIZE, 8);
 
-		head[4] = dgram_offset >> 3;
+	while (skb_unprocessed >= frag_cap) {
+		dgram_offset += frag_len;
+		skb_offset += frag_len;
+		skb_unprocessed -= frag_len;
+		frag_len = min(frag_cap, skb_unprocessed);
 
-		if (payload_length - offset < len)
-			len = payload_length - offset;
+		frag_hdr[4] = dgram_offset >> 3;
 
-		err = lowpan_fragment_xmit(skb, head, header_length, len,
-					   offset, LOWPAN_DISPATCH_FRAGN);
-		if (err) {
+		rc = lowpan_xmit_fragment(skb, wpan_hdr, frag_hdr,
+					  LOWPAN_FRAGN_HEAD_SIZE, skb_offset,
+					  frag_len);
+		if (rc) {
 			pr_debug("%s unable to send a FRAGN packet. (tag: %d, offset: %d)\n",
-				 __func__, tag, offset);
-			goto exit;
+				 __func__, frag_tag, skb_offset);
+			goto err;
 		}
-
-		offset += len;
-		dgram_offset += len;
 	}
 
-exit:
-	return err;
+	consume_skb(skb);
+	return NET_XMIT_SUCCESS;
+
+err:
+	kfree_skb(skb);
+	return rc;
 }
 
 static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int err = -1;
+	struct ieee802154_hdr wpan_hdr;
+	int max_single;
 
 	pr_debug("package xmit\n");
 
-	skb->dev = lowpan_dev_info(dev)->real_dev;
-	if (skb->dev == NULL) {
-		pr_debug("ERROR: no real wpan device found\n");
-		goto error;
+	if (ieee802154_hdr_peek(skb, &wpan_hdr) < 0) {
+		kfree_skb(skb);
+		return NET_XMIT_DROP;
 	}
 
-	/* Send directly if less than the MTU minus the 2 checksum bytes. */
-	if (skb->len <= IEEE802154_MTU - IEEE802154_MFR_SIZE) {
-		err = dev_queue_xmit(skb);
-		goto out;
-	}
+	max_single = ieee802154_max_payload(&wpan_hdr);
 
-	pr_debug("frame is too big, fragmentation is needed\n");
-	err = lowpan_skb_fragmentation(skb, dev);
-error:
-	dev_kfree_skb(skb);
-out:
-	if (err)
-		pr_debug("ERROR: xmit failed\n");
+	if (skb_tail_pointer(skb) - skb_network_header(skb) <= max_single) {
+		skb->dev = lowpan_dev_info(dev)->real_dev;
+		return dev_queue_xmit(skb);
+	} else {
+		netdev_tx_t rc;
+
+		pr_debug("frame is too big, fragmentation is needed\n");
+		rc = lowpan_xmit_fragmented(skb, dev, &wpan_hdr);
 
-	return (err < 0) ? NET_XMIT_DROP : err;
+		return rc < 0 ? NET_XMIT_DROP : rc;
+	}
 }
 
 static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
