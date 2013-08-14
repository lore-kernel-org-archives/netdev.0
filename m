From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 4/6] 6lowpan: add function to
	uncompress multicast addr
Date: Wed, 14 Aug 2013 13:01:46 +0200
Message-ID: <1376478108-3539-5-git-send-email-alex.aring@gmail.com>
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

Add function to uncompress multicast address.
This function split the uncompress function for a multicast address
in a seperate function.

To uncompress a multicast address is different than a other
non-multicasts addresses according to rfc6282.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 78 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 59 insertions(+), 19 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 632b3fd..0df8874 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -88,15 +88,6 @@ static const u8 lowpan_unc_llconf[] = {0x0f, 0x28, 0x22, 0x20};
  */
 static const u8 lowpan_unc_ctxconf[] = {0x00, 0x88, 0x82, 0x80};
 
-/*
- * Uncompression of ctx-base
- *   0 -> 0 bits from packet
- *   1 -> 2 bytes from prefix - bunch of zeroes 5 from packet
- *   2 -> 2 bytes from prefix - zeroes + 3 from packet
- *   3 -> 2 bytes from prefix - infer 1 bytes from lladdr
- */
-static const u8 lowpan_unc_mxconf[] = {0x0f, 0x25, 0x23, 0x21};
-
 /* Link local prefix */
 static const u8 lowpan_llprefix[] = {0xfe, 0x80};
 
@@ -240,6 +231,63 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
 	return 0;
 }
 
+/* Uncompress function for multicast destination address,
+ * when M bit is set.
+ */
+static int
+lowpan_uncompress_multicast_daddr(struct sk_buff *skb,
+		struct in6_addr *ipaddr,
+		const u8 dam)
+{
+	bool fail;
+
+	switch (dam) {
+	case LOWPAN_IPHC_DAM_00:
+		/* 00:  128 bits.  The full address
+		 * is carried in-line.
+		 */
+		fail = lowpan_fetch_skb(skb, ipaddr->s6_addr, 16);
+		break;
+	case LOWPAN_IPHC_DAM_01:
+		/* 01:  48 bits.  The address takes
+		 * the form ffXX::00XX:XXXX:XXXX.
+		 */
+		ipaddr->s6_addr[0] = 0xFF;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 1);
+		fail |= lowpan_fetch_skb(skb, &ipaddr->s6_addr[11], 5);
+		break;
+	case LOWPAN_IPHC_DAM_10:
+		/* 10:  32 bits.  The address takes
+		 * the form ffXX::00XX:XXXX.
+		 */
+		ipaddr->s6_addr[0] = 0xFF;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 1);
+		fail |= lowpan_fetch_skb(skb, &ipaddr->s6_addr[13], 3);
+		break;
+	case LOWPAN_IPHC_DAM_11:
+		/* 11:  8 bits.  The address takes
+		 * the form ff02::00XX.
+		 */
+		ipaddr->s6_addr[0] = 0xFF;
+		ipaddr->s6_addr[1] = 0x02;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[15], 1);
+		break;
+	default:
+		pr_debug("DAM value has a wrong value: 0x%x\n", dam);
+		return -EINVAL;
+	}
+
+	if (fail) {
+		pr_debug("Failed to fetch skb data\n");
+		return -EIO;
+	}
+
+	pr_debug("Reconstructed ipv6 multicast addr is:\n");
+	lowpan_raw_dump_inline(NULL, NULL, ipaddr->s6_addr, 16);
+
+	return 0;
+}
+
 static void
 lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 {
@@ -927,16 +975,8 @@ lowpan_process_data(struct sk_buff *skb)
 			pr_debug("dest: context-based mcast compression\n");
 			/* TODO: implement this */
 		} else {
-			u8 prefix[] = {0xff, 0x02};
-
-			pr_debug("dest: non context-based mcast compression\n");
-			if (0 < tmp && tmp < 3) {
-				if (lowpan_fetch_skb_u8(skb, &prefix[1]))
-					goto drop;
-			}
-
-			err = lowpan_uncompress_addr(skb, &hdr.daddr, prefix,
-					lowpan_unc_mxconf[tmp], NULL);
+			err = lowpan_uncompress_multicast_daddr(
+					skb, &hdr.daddr, tmp);
 			if (err)
 				goto drop;
 		}
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
