From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v6 2/8] 6lowpan: add
	uncompress header size function
Date: Fri, 28 Feb 2014 07:32:44 +0100
Message-ID: <1393569170-25722-3-git-send-email-alex.aring@gmail.com>
References: <1393569170-25722-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393569170-25722-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch add a lookup function for uncompressed 6LoWPAN header
size. This is needed to estimate the real size after uncompress the
6LoWPAN header.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.h | 113 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 113 insertions(+)

diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 2b835db..0dccf62 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -306,6 +306,119 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
 	*hc_ptr += len;
 }
 
+static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
+{
+	static const u8 addr_sizes[] = {
+		[LOWPAN_IPHC_ADDR_00] = 16,
+		[LOWPAN_IPHC_ADDR_01] = 8,
+		[LOWPAN_IPHC_ADDR_02] = 2,
+		[LOWPAN_IPHC_ADDR_03] = 0,
+	};
+	return addr_sizes[addr_mode];
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


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
