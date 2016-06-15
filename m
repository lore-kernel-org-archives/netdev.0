From: Alexander Aring <aar@pengutronix.de>
Subject: [PATCHv4 net-next 12/12] 6lowpan: add support for 802.15.4 short addr handling
Date: Wed, 15 Jun 2016 21:20:27 +0200
Message-ID: <20160615192027.4064-13-aar@pengutronix.de>
References: <20160615192027.4064-1-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:46309 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932235AbcFOTVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:21:23 -0400
In-Reply-To: <20160615192027.4064-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds necessary handling for use the short address for
802.15.4 6lowpan. It contains support for IPHC address compression
and new matching algorithmn to decide which link layer address will be
used for 802.15.4 frame.

Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 net/6lowpan/iphc.c          | 167 ++++++++++++++++++++++++++++++++++++--------
 net/ieee802154/6lowpan/tx.c | 113 +++++++++++++++---------------
 2 files changed, 195 insertions(+), 85 deletions(-)

diff --git a/net/6lowpan/iphc.c b/net/6lowpan/iphc.c
index 8501dd5..79f1fa2 100644
--- a/net/6lowpan/iphc.c
+++ b/net/6lowpan/iphc.c
@@ -761,22 +761,75 @@ static const u8 lowpan_iphc_dam_to_sam_value[] = {
 	[LOWPAN_IPHC_DAM_11] = LOWPAN_IPHC_SAM_11,
 };
 
-static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct in6_addr *ipaddr,
+static inline bool
+lowpan_iphc_compress_ctx_802154_lladdr(const struct in6_addr *ipaddr,
+				       const struct lowpan_iphc_ctx *ctx,
+				       const void *lladdr)
+{
+	const struct ieee802154_addr *addr = lladdr;
+	unsigned char extended_addr[EUI64_ADDR_LEN];
+	bool lladdr_compress = false;
+	struct in6_addr tmp = {};
+
+	switch (addr->mode) {
+	case IEEE802154_ADDR_LONG:
+		ieee802154_le64_to_be64(&extended_addr, &addr->extended_addr);
+		/* check for SAM/DAM = 11 */
+		memcpy(&tmp.s6_addr[8], &extended_addr, EUI64_ADDR_LEN);
+		/* second bit-flip (Universe/Local) is done according RFC2464 */
+		tmp.s6_addr[8] ^= 0x02;
+		/* context information are always used */
+		ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
+		if (ipv6_addr_equal(&tmp, ipaddr))
+			lladdr_compress = true;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		tmp.s6_addr[11] = 0xFF;
+		tmp.s6_addr[12] = 0xFE;
+		ieee802154_le16_to_be16(&tmp.s6_addr16[7],
+					&addr->short_addr);
+		/* context information are always used */
+		ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
+		if (ipv6_addr_equal(&tmp, ipaddr))
+			lladdr_compress = true;
+		break;
+	default:
+		/* should never handled and filtered by 802154 6lowpan */
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+	return lladdr_compress;
+}
+
+static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct net_device *dev,
+				   const struct in6_addr *ipaddr,
 				   const struct lowpan_iphc_ctx *ctx,
 				   const unsigned char *lladdr, bool sam)
 {
 	struct in6_addr tmp = {};
 	u8 dam;
 
-	/* check for SAM/DAM = 11 */
-	memcpy(&tmp.s6_addr[8], lladdr, 8);
-	/* second bit-flip (Universe/Local) is done according RFC2464 */
-	tmp.s6_addr[8] ^= 0x02;
-	/* context information are always used */
-	ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
-	if (ipv6_addr_equal(&tmp, ipaddr)) {
-		dam = LOWPAN_IPHC_DAM_11;
-		goto out;
+	switch (lowpan_dev(dev)->lltype) {
+	case LOWPAN_LLTYPE_IEEE802154:
+		if (lowpan_iphc_compress_ctx_802154_lladdr(ipaddr, ctx,
+							   lladdr)) {
+			dam = LOWPAN_IPHC_DAM_11;
+			goto out;
+		}
+		break;
+	default:
+		/* check for SAM/DAM = 11 */
+		memcpy(&tmp.s6_addr[8], lladdr, EUI64_ADDR_LEN);
+		/* second bit-flip (Universe/Local) is done according RFC2464 */
+		tmp.s6_addr[8] ^= 0x02;
+		/* context information are always used */
+		ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
+		if (ipv6_addr_equal(&tmp, ipaddr)) {
+			dam = LOWPAN_IPHC_DAM_11;
+			goto out;
+		}
+		break;
 	}
 
 	memset(&tmp, 0, sizeof(tmp));
@@ -813,28 +866,85 @@ out:
 		return dam;
 }
 
-static u8 lowpan_compress_addr_64(u8 **hc_ptr, const struct in6_addr *ipaddr,
+static inline bool
+lowpan_iphc_compress_802154_lladdr(const struct in6_addr *ipaddr,
+				   const void *lladdr)
+{
+	const struct ieee802154_addr *addr = lladdr;
+	unsigned char extended_addr[EUI64_ADDR_LEN];
+	bool lladdr_compress = false;
+	struct in6_addr tmp = {};
+
+	switch (addr->mode) {
+	case IEEE802154_ADDR_LONG:
+		ieee802154_le64_to_be64(&extended_addr, &addr->extended_addr);
+		if (is_addr_mac_addr_based(ipaddr, extended_addr))
+			lladdr_compress = true;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		/* fe:80::ff:fe00:XXXX
+		 *                \__/
+		 *             short_addr
+		 *
+		 * Universe/Local bit is zero.
+		 */
+		tmp.s6_addr[0] = 0xFE;
+		tmp.s6_addr[1] = 0x80;
+		tmp.s6_addr[11] = 0xFF;
+		tmp.s6_addr[12] = 0xFE;
+		ieee802154_le16_to_be16(&tmp.s6_addr16[7],
+					&addr->short_addr);
+		if (ipv6_addr_equal(&tmp, ipaddr))
+			lladdr_compress = true;
+		break;
+	default:
+		/* should never handled and filtered by 802154 6lowpan */
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+	return lladdr_compress;
+}
+
+static u8 lowpan_compress_addr_64(u8 **hc_ptr, const struct net_device *dev,
+				  const struct in6_addr *ipaddr,
 				  const unsigned char *lladdr, bool sam)
 {
-	u8 dam = LOWPAN_IPHC_DAM_00;
+	u8 dam = LOWPAN_IPHC_DAM_01;
 
-	if (is_addr_mac_addr_based(ipaddr, lladdr)) {
-		dam = LOWPAN_IPHC_DAM_11; /* 0-bits */
-		pr_debug("address compression 0 bits\n");
-	} else if (lowpan_is_iid_16_bit_compressable(ipaddr)) {
+	switch (lowpan_dev(dev)->lltype) {
+	case LOWPAN_LLTYPE_IEEE802154:
+		if (lowpan_iphc_compress_802154_lladdr(ipaddr, lladdr)) {
+			dam = LOWPAN_IPHC_DAM_11; /* 0-bits */
+			pr_debug("address compression 0 bits\n");
+			goto out;
+		}
+		break;
+	default:
+		if (is_addr_mac_addr_based(ipaddr, lladdr)) {
+			dam = LOWPAN_IPHC_DAM_11; /* 0-bits */
+			pr_debug("address compression 0 bits\n");
+			goto out;
+		}
+		break;
+	}
+
+	if (lowpan_is_iid_16_bit_compressable(ipaddr)) {
 		/* compress IID to 16 bits xxxx::XXXX */
 		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr16[7], 2);
 		dam = LOWPAN_IPHC_DAM_10; /* 16-bits */
 		raw_dump_inline(NULL, "Compressed ipv6 addr is (16 bits)",
 				*hc_ptr - 2, 2);
-	} else {
-		/* do not compress IID => xxxx::IID */
-		lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr16[4], 8);
-		dam = LOWPAN_IPHC_DAM_01; /* 64-bits */
-		raw_dump_inline(NULL, "Compressed ipv6 addr is (64 bits)",
-				*hc_ptr - 8, 8);
+		goto out;
 	}
 
+	/* do not compress IID => xxxx::IID */
+	lowpan_push_hc_data(hc_ptr, &ipaddr->s6_addr16[4], 8);
+	raw_dump_inline(NULL, "Compressed ipv6 addr is (64 bits)",
+			*hc_ptr - 8, 8);
+
+out:
+
 	if (sam)
 		return lowpan_iphc_dam_to_sam_value[dam];
 	else
@@ -1013,9 +1123,6 @@ int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 	iphc0 = LOWPAN_DISPATCH_IPHC;
 	iphc1 = 0;
 
-	raw_dump_inline(__func__, "saddr", saddr, EUI64_ADDR_LEN);
-	raw_dump_inline(__func__, "daddr", daddr, EUI64_ADDR_LEN);
-
 	raw_dump_table(__func__, "sending raw skb network uncompressed packet",
 		       skb->data, skb->len);
 
@@ -1088,14 +1195,15 @@ int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 		iphc1 |= LOWPAN_IPHC_SAC;
 	} else {
 		if (sci) {
-			iphc1 |= lowpan_compress_ctx_addr(&hc_ptr, &hdr->saddr,
+			iphc1 |= lowpan_compress_ctx_addr(&hc_ptr, dev,
+							  &hdr->saddr,
 							  &sci_entry, saddr,
 							  true);
 			iphc1 |= LOWPAN_IPHC_SAC;
 		} else {
 			if (ipv6_saddr_type & IPV6_ADDR_LINKLOCAL &&
 			    lowpan_is_linklocal_zero_padded(hdr->saddr)) {
-				iphc1 |= lowpan_compress_addr_64(&hc_ptr,
+				iphc1 |= lowpan_compress_addr_64(&hc_ptr, dev,
 								 &hdr->saddr,
 								 saddr, true);
 				pr_debug("source address unicast link-local %pI6c iphc1 0x%02x\n",
@@ -1123,14 +1231,15 @@ int lowpan_header_compress(struct sk_buff *skb, const struct net_device *dev,
 		}
 	} else {
 		if (dci) {
-			iphc1 |= lowpan_compress_ctx_addr(&hc_ptr, &hdr->daddr,
+			iphc1 |= lowpan_compress_ctx_addr(&hc_ptr, dev,
+							  &hdr->daddr,
 							  &dci_entry, daddr,
 							  false);
 			iphc1 |= LOWPAN_IPHC_DAC;
 		} else {
 			if (ipv6_daddr_type & IPV6_ADDR_LINKLOCAL &&
 			    lowpan_is_linklocal_zero_padded(hdr->daddr)) {
-				iphc1 |= lowpan_compress_addr_64(&hc_ptr,
+				iphc1 |= lowpan_compress_addr_64(&hc_ptr, dev,
 								 &hdr->daddr,
 								 daddr, false);
 				pr_debug("dest address unicast link-local %pI6c iphc1 0x%02x\n",
diff --git a/net/ieee802154/6lowpan/tx.c b/net/ieee802154/6lowpan/tx.c
index e459afd..dbb476d 100644
--- a/net/ieee802154/6lowpan/tx.c
+++ b/net/ieee802154/6lowpan/tx.c
@@ -9,6 +9,7 @@
  */
 
 #include <net/6lowpan.h>
+#include <net/ndisc.h>
 #include <net/ieee802154_netdev.h>
 #include <net/mac802154.h>
 
@@ -17,19 +18,9 @@
 #define LOWPAN_FRAG1_HEAD_SIZE	0x4
 #define LOWPAN_FRAGN_HEAD_SIZE	0x5
 
-/* don't save pan id, it's intra pan */
-struct lowpan_addr {
-	u8 mode;
-	union {
-		/* IPv6 needs big endian here */
-		__be64 extended_addr;
-		__be16 short_addr;
-	} u;
-};
-
 struct lowpan_addr_info {
-	struct lowpan_addr daddr;
-	struct lowpan_addr saddr;
+	struct ieee802154_addr daddr;
+	struct ieee802154_addr saddr;
 };
 
 static inline struct
@@ -48,12 +39,14 @@ lowpan_addr_info *lowpan_skb_priv(const struct sk_buff *skb)
  * RAW/DGRAM sockets.
  */
 int lowpan_header_create(struct sk_buff *skb, struct net_device *ldev,
-			 unsigned short type, const void *_daddr,
-			 const void *_saddr, unsigned int len)
+			 unsigned short type, const void *daddr,
+			 const void *saddr, unsigned int len)
 {
-	const u8 *saddr = _saddr;
-	const u8 *daddr = _daddr;
-	struct lowpan_addr_info *info;
+	struct wpan_dev *wpan_dev = lowpan_802154_dev(ldev)->wdev->ieee802154_ptr;
+	struct lowpan_addr_info *info = lowpan_skb_priv(skb);
+	struct lowpan_802154_neigh *llneigh = NULL;
+	const struct ipv6hdr *hdr = ipv6_hdr(skb);
+	struct neighbour *n;
 
 	/* TODO:
 	 * if this package isn't ipv6 one, where should it be routed?
@@ -61,21 +54,50 @@ int lowpan_header_create(struct sk_buff *skb, struct net_device *ldev,
 	if (type != ETH_P_IPV6)
 		return 0;
 
-	if (!saddr)
-		saddr = ldev->dev_addr;
+	/* intra-pan communication */
+	info->saddr.pan_id = wpan_dev->pan_id;
+	info->daddr.pan_id = info->saddr.pan_id;
 
-	raw_dump_inline(__func__, "saddr", (unsigned char *)saddr, 8);
-	raw_dump_inline(__func__, "daddr", (unsigned char *)daddr, 8);
+	if (!memcmp(daddr, ldev->broadcast, EUI64_ADDR_LEN)) {
+		info->daddr.short_addr = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
+		info->daddr.mode = IEEE802154_ADDR_SHORT;
+	} else {
+		__le16 short_addr = cpu_to_le16(IEEE802154_ADDR_SHORT_UNSPEC);
+
+		n = neigh_lookup(&nd_tbl, &hdr->daddr, ldev);
+		if (n) {
+			llneigh = lowpan_802154_neigh(neighbour_priv(n));
+			read_lock_bh(&n->lock);
+			short_addr = llneigh->short_addr;
+			read_unlock_bh(&n->lock);
+		}
 
-	info = lowpan_skb_priv(skb);
+		if (llneigh &&
+		    lowpan_802154_is_valid_src_short_addr(short_addr)) {
+			info->daddr.short_addr = short_addr;
+			info->daddr.mode = IEEE802154_ADDR_SHORT;
+		} else {
+			info->daddr.mode = IEEE802154_ADDR_LONG;
+			ieee802154_be64_to_le64(&info->daddr.extended_addr,
+						daddr);
+		}
 
-	/* TODO: Currently we only support extended_addr */
-	info->daddr.mode = IEEE802154_ADDR_LONG;
-	memcpy(&info->daddr.u.extended_addr, daddr,
-	       sizeof(info->daddr.u.extended_addr));
-	info->saddr.mode = IEEE802154_ADDR_LONG;
-	memcpy(&info->saddr.u.extended_addr, saddr,
-	       sizeof(info->daddr.u.extended_addr));
+		if (n)
+			neigh_release(n);
+	}
+
+	if (!saddr) {
+		if (lowpan_802154_is_valid_src_short_addr(wpan_dev->short_addr)) {
+			info->saddr.mode = IEEE802154_ADDR_SHORT;
+			info->saddr.short_addr = wpan_dev->short_addr;
+		} else {
+			info->saddr.mode = IEEE802154_ADDR_LONG;
+			info->saddr.extended_addr = wpan_dev->extended_addr;
+		}
+	} else {
+		info->saddr.mode = IEEE802154_ADDR_LONG;
+		ieee802154_be64_to_le64(&info->saddr.extended_addr, saddr);
+	}
 
 	return 0;
 }
@@ -209,47 +231,26 @@ static int lowpan_header(struct sk_buff *skb, struct net_device *ldev,
 			 u16 *dgram_size, u16 *dgram_offset)
 {
 	struct wpan_dev *wpan_dev = lowpan_802154_dev(ldev)->wdev->ieee802154_ptr;
-	struct ieee802154_addr sa, da;
 	struct ieee802154_mac_cb *cb = mac_cb_init(skb);
 	struct lowpan_addr_info info;
-	void *daddr, *saddr;
 
 	memcpy(&info, lowpan_skb_priv(skb), sizeof(info));
 
-	/* TODO: Currently we only support extended_addr */
-	daddr = &info.daddr.u.extended_addr;
-	saddr = &info.saddr.u.extended_addr;
-
 	*dgram_size = skb->len;
-	lowpan_header_compress(skb, ldev, daddr, saddr);
+	lowpan_header_compress(skb, ldev, &info.daddr, &info.saddr);
 	/* dgram_offset = (saved bytes after compression) + lowpan header len */
 	*dgram_offset = (*dgram_size - skb->len) + skb_network_header_len(skb);
 
 	cb->type = IEEE802154_FC_TYPE_DATA;
 
-	/* prepare wpan address data */
-	sa.mode = IEEE802154_ADDR_LONG;
-	sa.pan_id = wpan_dev->pan_id;
-	sa.extended_addr = ieee802154_devaddr_from_raw(saddr);
-
-	/* intra-PAN communications */
-	da.pan_id = sa.pan_id;
-
-	/* if the destination address is the broadcast address, use the
-	 * corresponding short address
-	 */
-	if (!memcmp(daddr, ldev->broadcast, EUI64_ADDR_LEN)) {
-		da.mode = IEEE802154_ADDR_SHORT;
-		da.short_addr = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
+	if (info.daddr.mode == IEEE802154_ADDR_SHORT &&
+	    ieee802154_is_broadcast_short_addr(info.daddr.short_addr))
 		cb->ackreq = false;
-	} else {
-		da.mode = IEEE802154_ADDR_LONG;
-		da.extended_addr = ieee802154_devaddr_from_raw(daddr);
+	else
 		cb->ackreq = wpan_dev->ackreq;
-	}
 
-	return wpan_dev_hard_header(skb, lowpan_802154_dev(ldev)->wdev, &da,
-				    &sa, 0);
+	return wpan_dev_hard_header(skb, lowpan_802154_dev(ldev)->wdev,
+				    &info.daddr, &info.saddr, 0);
 }
 
 netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *ldev)
-- 
2.8.3
