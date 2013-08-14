From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 5/6] 6lowpan:
	lowpan_uncompress_addr with address_mode
Date: Wed, 14 Aug 2013 13:01:47 +0200
Message-ID: <1376478108-3539-6-git-send-email-alex.aring@gmail.com>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1376478108-3539-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch drop the pre and postcount calculation from the
lowpan_uncompress_addr function.

We use instead a switch case over address_mode value, it's easier
to understand what's going on there.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 144 +++++++++++++++++++++++++----------------------
 net/ieee802154/6lowpan.h |   8 ++-
 2 files changed, 82 insertions(+), 70 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 0df8874..d299560 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -67,30 +67,6 @@ static const u8 lowpan_ttl_values[] = {0, 1, 64, 255};
 
 static LIST_HEAD(lowpan_devices);
 
-/*
- * Uncompression of linklocal:
- *   0 -> 16 bytes from packet
- *   1 -> 2  bytes from prefix - bunch of zeroes and 8 from packet
- *   2 -> 2  bytes from prefix - zeroes + 2 from packet
- *   3 -> 2  bytes from prefix - infer 8 bytes from lladdr
- *
- *  NOTE: => the uncompress function does change 0xf to 0x10
- *  NOTE: 0x00 => no-autoconfig => unspecified
- */
-static const u8 lowpan_unc_llconf[] = {0x0f, 0x28, 0x22, 0x20};
-
-/*
- * Uncompression of ctx-based:
- *   0 -> 0 bits  from packet [unspecified / reserved]
- *   1 -> 8 bytes from prefix - bunch of zeroes and 8 from packet
- *   2 -> 8 bytes from prefix - zeroes + 2 from packet
- *   3 -> 8 bytes from prefix - infer 8 bytes from lladdr
- */
-static const u8 lowpan_unc_ctxconf[] = {0x00, 0x88, 0x82, 0x80};
-
-/* Link local prefix */
-static const u8 lowpan_llprefix[] = {0xfe, 0x80};
-
 /* private device info */
 struct lowpan_dev_info {
 	struct net_device	*real_dev; /* real WPAN device ptr */
@@ -182,50 +158,86 @@ lowpan_compress_addr_64(u8 **hc06_ptr, u8 shift, const struct in6_addr *ipaddr,
 	return rol8(val, shift);
 }
 
-static void
-lowpan_uip_ds6_set_addr_iid(struct in6_addr *ipaddr, unsigned char *lladdr)
-{
-	memcpy(&ipaddr->s6_addr[8], lladdr, IEEE802154_ADDR_LEN);
-	/* second bit-flip (Universe/Local) is done according RFC2464 */
-	ipaddr->s6_addr[8] ^= 0x02;
-}
-
 /*
- * Uncompress addresses based on a prefix and a postfix with zeroes in
- * between. If the postfix is zero in length it will use the link address
- * to configure the IP address (autoconf style).
- * pref_post_count takes a byte where the first nibble specify prefix count
- * and the second postfix count (NOTE: 15/0xf => 16 bytes copy).
+ * Uncompress address function for source and
+ * destination address(non-multicast).
+ *
+ * address_mode is sam value or dam value.
  */
 static int
-lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
-	u8 const *prefix, u8 pref_post_count, unsigned char *lladdr)
+lowpan_uncompress_addr(struct sk_buff *skb,
+		struct in6_addr *ipaddr,
+		const u8 address_mode,
+		const struct ieee802154_addr *lladdr)
 {
-	u8 prefcount = pref_post_count >> 4;
-	u8 postcount = pref_post_count & 0x0f;
-
-	/* full nibble 15 => 16 */
-	prefcount = (prefcount == 15 ? 16 : prefcount);
-	postcount = (postcount == 15 ? 16 : postcount);
-
-	if (lladdr)
-		lowpan_raw_dump_inline(__func__, "linklocal address",
-						lladdr,	IEEE802154_ADDR_LEN);
-	if (prefcount > 0)
-		memcpy(ipaddr, prefix, prefcount);
-
-	if (postcount > 0) {
-		memcpy(&ipaddr->s6_addr[16 - postcount], skb->data, postcount);
-		skb_pull(skb, postcount);
-	} else if (prefcount > 0) {
-		if (lladdr == NULL)
+	bool fail;
+
+	switch (address_mode) {
+	case LOWPAN_IPHC_ADDR_00:
+		/* for global link addresses */
+		fail = lowpan_fetch_skb(skb, ipaddr->s6_addr, 16);
+		break;
+	case LOWPAN_IPHC_ADDR_01:
+		/* fe:80::XXXX:XXXX:XXXX:XXXX */
+		ipaddr->s6_addr[0] = 0xFE;
+		ipaddr->s6_addr[1] = 0x80;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[8], 8);
+		break;
+	case LOWPAN_IPHC_ADDR_02:
+		/* fe:80::ff:fe00:XXXX */
+		ipaddr->s6_addr[0] = 0xFE;
+		ipaddr->s6_addr[1] = 0x80;
+		ipaddr->s6_addr[11] = 0xFF;
+		ipaddr->s6_addr[12] = 0xFE;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[14], 2);
+		break;
+	case LOWPAN_IPHC_ADDR_03:
+		fail = false;
+		switch (lladdr->addr_type) {
+		case IEEE802154_ADDR_LONG:
+			/* fe:80::XXXX:XXXX:XXXX:XXXX
+			 *        \_________________/
+			 *              hwaddr
+			 */
+			ipaddr->s6_addr[0] = 0xFE;
+			ipaddr->s6_addr[1] = 0x80;
+			memcpy(&ipaddr->s6_addr[8], lladdr->hwaddr,
+					IEEE802154_ADDR_LEN);
+			/* second bit-flip (Universe/Local)
+			 * is done according RFC2464
+			 */
+			ipaddr->s6_addr[8] ^= 0x02;
+			break;
+		case IEEE802154_ADDR_SHORT:
+			/* fe:80::ff:fe00:XXXX
+			 *		  \__/
+			 *	       short_addr
+			 *
+			 * Universe/Local bit is zero.
+			 */
+			ipaddr->s6_addr[0] = 0xFE;
+			ipaddr->s6_addr[1] = 0x80;
+			ipaddr->s6_addr[11] = 0xFF;
+			ipaddr->s6_addr[12] = 0xFE;
+			memcpy(&ipaddr->s6_addr[14], &lladdr->short_addr,
+					UIP_802154_SHORTADDR_LEN);
+			break;
+		default:
+			pr_debug("Invalid addr_type set\n");
 			return -EINVAL;
+		}
+		break;
+	default:
+		pr_debug("Invalid address mode value: 0x%x\n", address_mode);
+		return -EINVAL;
+	}
 
-		/* no IID based configuration if no prefix and no data */
-		lowpan_uip_ds6_set_addr_iid(ipaddr, lladdr);
+	if (fail) {
+		pr_debug("Failed to fetch skb data\n");
+		return -EIO;
 	}
 
-	pr_debug("uncompressing %d + %d => ", prefcount, postcount);
+	pr_debug("Reconstructed ipv6 addr is:\n");
 	lowpan_raw_dump_inline(NULL, NULL, ipaddr->s6_addr, 16);
 
 	return 0;
@@ -775,7 +787,7 @@ lowpan_process_data(struct sk_buff *skb)
 {
 	struct ipv6hdr hdr = {};
 	u8 tmp, iphc0, iphc1, num_context = 0;
-	u8 *_saddr, *_daddr;
+	const struct ieee802154_addr *_saddr, *_daddr;
 	int err;
 
 	lowpan_raw_dump_table(__func__, "raw skb data dump", skb->data,
@@ -878,8 +890,8 @@ lowpan_process_data(struct sk_buff *skb)
 	if (lowpan_fetch_skb_u8(skb, &iphc1))
 		goto drop;
 
-	_saddr = mac_cb(skb)->sa.hwaddr;
-	_daddr = mac_cb(skb)->da.hwaddr;
+	_saddr = &mac_cb(skb)->sa;
+	_daddr = &mac_cb(skb)->da;
 
 	pr_debug("iphc0 = %02x, iphc1 = %02x\n", iphc0, iphc1);
 
@@ -961,8 +973,7 @@ lowpan_process_data(struct sk_buff *skb)
 
 	/* Source address uncompression */
 	pr_debug("source address stateless compression\n");
-	err = lowpan_uncompress_addr(skb, &hdr.saddr, lowpan_llprefix,
-				lowpan_unc_llconf[tmp], skb->data);
+	err = lowpan_uncompress_addr(skb, &hdr.saddr, tmp, _saddr);
 	if (err)
 		goto drop;
 
@@ -982,8 +993,7 @@ lowpan_process_data(struct sk_buff *skb)
 		}
 	} else {
 		pr_debug("dest: stateless compression\n");
-		err = lowpan_uncompress_addr(skb, &hdr.daddr, lowpan_llprefix,
-				lowpan_unc_llconf[tmp], skb->data);
+		err = lowpan_uncompress_addr(skb, &hdr.daddr, tmp, _daddr);
 		if (err)
 			goto drop;
 	}
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index e3348ec..6596644 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -196,10 +196,12 @@
 /* Values of fields within the IPHC encoding second byte */
 #define LOWPAN_IPHC_CID		0x80
 
+#define LOWPAN_IPHC_ADDR_00	0x00
+#define LOWPAN_IPHC_ADDR_01	0x01
+#define LOWPAN_IPHC_ADDR_02	0x02
+#define LOWPAN_IPHC_ADDR_03	0x03
+
 #define LOWPAN_IPHC_SAC		0x40
-#define LOWPAN_IPHC_SAM_00	0x00
-#define LOWPAN_IPHC_SAM_01	0x10
-#define LOWPAN_IPHC_SAM_10	0x20
 #define LOWPAN_IPHC_SAM		0x30
 
 #define LOWPAN_IPHC_SAM_BIT	4
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
