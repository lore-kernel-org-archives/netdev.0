From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 6/6] 6lowpan: handle context
	based source address
Date: Wed, 14 Aug 2013 13:01:48 +0200
Message-ID: <1376478108-3539-7-git-send-email-alex.aring@gmail.com>
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

Handle context based address when a unspecific address is specified.
For other context based address we print a warning and drop the packet
currently because we don't support it right now.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 48 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index d299560..90eddce 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -243,6 +243,39 @@ lowpan_uncompress_addr(struct sk_buff *skb,
 	return 0;
 }
 
+/* Uncompress address function for source context
+ * based address(non-multicast).
+ */
+static int
+lowpan_uncompress_context_based_src_addr(struct sk_buff *skb,
+		struct in6_addr *ipaddr,
+		const u8 sam)
+{
+	switch (sam) {
+	case LOWPAN_IPHC_ADDR_00:
+		/* unspec address ::
+		 * Do nothing, address is already ::
+		 */
+		break;
+	case LOWPAN_IPHC_ADDR_01:
+		/* TODO */
+	case LOWPAN_IPHC_ADDR_02:
+		/* TODO */
+	case LOWPAN_IPHC_ADDR_03:
+		/* TODO */
+		netdev_warn(skb->dev, "SAM value 0x%x not supported\n", sam);
+		return -EINVAL;
+	default:
+		pr_debug("Invalid sam value: 0x%x\n", sam);
+		return -EINVAL;
+	}
+
+	pr_debug("Reconstructed context based ipv6 src addr is:\n");
+	lowpan_raw_dump_inline(NULL, NULL, ipaddr->s6_addr, 16);
+
+	return 0;
+}
+
 /* Uncompress function for multicast destination address,
  * when M bit is set.
  */
@@ -971,9 +1004,18 @@ lowpan_process_data(struct sk_buff *skb)
 	/* Extract SAM to the tmp variable */
 	tmp = ((iphc1 & LOWPAN_IPHC_SAM) >> LOWPAN_IPHC_SAM_BIT) & 0x03;
 
-	/* Source address uncompression */
-	pr_debug("source address stateless compression\n");
-	err = lowpan_uncompress_addr(skb, &hdr.saddr, tmp, _saddr);
+	if (iphc1 & LOWPAN_IPHC_SAC) {
+		/* Source address context based uncompression */
+		pr_debug("SAC bit is set. Handle context based source address.\n");
+		err = lowpan_uncompress_context_based_src_addr(
+				skb, &hdr.saddr, tmp);
+	} else {
+		/* Source address uncompression */
+		pr_debug("source address stateless compression\n");
+		err = lowpan_uncompress_addr(skb, &hdr.saddr, tmp, _saddr);
+	}
+
+	/* Check on error of previous branch */
 	if (err)
 		goto drop;
 
-- 
1.8.3.3


------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
