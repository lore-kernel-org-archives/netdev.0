From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size function
Date: Wed, 26 Feb 2014 17:05:06 +0100
Message-ID: <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:53889 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaBZQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:05:32 -0500
Received: by mail-ee0-f50.google.com with SMTP id t10so648487eei.23
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:05:31 -0800 (PST)
In-Reply-To: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.h | 116 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 116 insertions(+)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 2b835db..b6ae0bc 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -306,6 +306,122 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
 	*hc_ptr += len;
 }
 
+static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
+{
+	switch (addr_mode) {
+	case LOWPAN_IPHC_ADDR_00:
+		return 16;
+	case LOWPAN_IPHC_ADDR_01:
+		return 8;
+	case LOWPAN_IPHC_ADDR_02:
+		return 2;
+	default:
+		return 0;
+	}
+}
+
+static inline u8 lowpan_next_hdr_size(const u8 h_enc, u16 *uncomp_header)
+{
+	u8 ret = 1;
+
+	if ((h_enc & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
+		*uncomp_header += sizeof(struct udphdr);
+
+		switch (h_enc & LOWPAN_NHC_UDP_CS_P_11) {
+		case LOWPAN_NHC_UDP_CS_P_00:
+			ret += 4;
+			break;
+		case LOWPAN_NHC_UDP_CS_P_01:
+		case LOWPAN_NHC_UDP_CS_P_10:
+			ret += 3;
+			break;
+		case LOWPAN_NHC_UDP_CS_P_11:
+			ret++;
+			break;
+		default:
+			break;
+		}
+
+		if (!(h_enc & LOWPAN_NHC_UDP_CS_C))
+			ret += 2;
+	}
+
+	return ret;
+}
+
+/**
+ *	lowpan_uncompress_size - returns skb->len size with uncompressed header
+ *	@skb: sk_buff with 6lowpan header inside
+ *	@datagram_offset: optional to get the datagram_offset value
+ *
+ *	Returns the skb->len with uncompressed header
+ */
+static inline u16
+lowpan_uncompress_size(const struct sk_buff *skb, u16 *dgram_offset)
+{
+	u16 ret = 2, uncomp_header = sizeof(struct ipv6hdr);
+	u8 iphc0, iphc1, h_enc;
+
+	iphc0 = skb_network_header(skb)[0];
+	iphc1 = skb_network_header(skb)[1];
+
+	switch ((iphc0 & LOWPAN_IPHC_TF) >> 3) {
+	case 0:
+		ret += 4;
+		break;
+	case 1:
+		ret += 3;
+		break;
+	case 2:
+		ret++;
+		break;
+	default:
+		break;
+	}
+
+	if (!(iphc0 & LOWPAN_IPHC_NH_C))
+		ret++;
+
+	if (!(iphc0 & 0x03))
+		ret++;
+
+	ret += lowpan_addr_mode_size((iphc1 & LOWPAN_IPHC_SAM) >>
+				     LOWPAN_IPHC_SAM_BIT);
+
+	if (iphc1 & LOWPAN_IPHC_M) {
+		switch ((iphc1 & LOWPAN_IPHC_DAM_11) >>
+			LOWPAN_IPHC_DAM_BIT) {
+		case LOWPAN_IPHC_DAM_00:
+			ret += 16;
+			break;
+		case LOWPAN_IPHC_DAM_01:
+			ret += 6;
+			break;
+		case LOWPAN_IPHC_DAM_10:
+			ret += 4;
+			break;
+		case LOWPAN_IPHC_DAM_11:
+			ret++;
+			break;
+		default:
+			break;
+		}
+	} else {
+		ret += lowpan_addr_mode_size((iphc1 & LOWPAN_IPHC_DAM_11) >>
+					     LOWPAN_IPHC_DAM_BIT);
+	}
+
+	if (iphc0 & LOWPAN_IPHC_NH_C) {
+		h_enc = skb_network_header(skb)[ret];
+		ret += lowpan_next_hdr_size(h_enc, &uncomp_header);
+	}
+
+	if (dgram_offset)
+		*dgram_offset = uncomp_header;
+
+	return skb->len + uncomp_header - ret;
+}
+
 typedef int (*skb_delivery_cb)(struct sk_buff *skb, struct net_device *dev);
 
 int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
-- 
1.9.0
