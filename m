From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net: fec: reset rx mode when do suspend/resume or link status change
Date: Thu, 27 Jun 2013 13:09:19 +0800
Message-ID: <1372309759-5067-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<stephen@networkplumber.org>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe006.messaging.microsoft.com ([216.32.180.189]:43375
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003Ab3F0Fee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 01:34:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When do suspend/resume, or plug/unplug network cable, or net watchdog
timeout process, fec_restart reinit the enet group hash table to zero.

It is not reasonable for this, so re-config the enet group hash table
when these actions happen.

Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |  153 ++++++++++++++---------------
 1 files changed, 76 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a667015..ce7615d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -264,6 +264,81 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
+/* Set or clear the multicast filter for this adaptor.
+ * Skeleton taken from sunlance driver.
+ * The CPM Ethernet implementation allows Multicast as well as individual
+ * MAC address filtering.  Some of the drivers check to make sure it is
+ * a group multicast address, and discard those that are not.  I guess I
+ * will do the same for now, but just remove the test if you want
+ * individual filtering as well (do the upper net layers want or support
+ * this kind of feature?).
+ */
+
+#define HASH_BITS	6		/* #bits in hash */
+#define CRC32_POLY	0xEDB88320
+
+static void set_multicast_list(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct netdev_hw_addr *ha;
+	unsigned int i, bit, data, crc, tmp;
+	unsigned char hash;
+
+	if (ndev->flags & IFF_PROMISC) {
+		tmp = readl(fep->hwp + FEC_R_CNTRL);
+		tmp |= 0x8;
+		writel(tmp, fep->hwp + FEC_R_CNTRL);
+		return;
+	}
+
+	tmp = readl(fep->hwp + FEC_R_CNTRL);
+	tmp &= ~0x8;
+	writel(tmp, fep->hwp + FEC_R_CNTRL);
+
+	if (ndev->flags & IFF_ALLMULTI) {
+		/* Catch all multicast addresses, so set the
+		 * filter to all 1's
+		 */
+		writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+		writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+
+		return;
+	}
+
+	/* Clear filter and add the addresses in hash register
+	 */
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+
+	netdev_for_each_mc_addr(ha, ndev) {
+		/* calculate crc32 value of mac address */
+		crc = 0xffffffff;
+
+		for (i = 0; i < ndev->addr_len; i++) {
+			data = ha->addr[i];
+			for (bit = 0; bit < 8; bit++, data >>= 1) {
+				crc = (crc >> 1) ^
+				(((crc ^ data) & 1) ? CRC32_POLY : 0);
+			}
+		}
+
+		/* only upper 6 bits (HASH_BITS) are used
+		 * which point to specific bit in he hash registers
+		 */
+		hash = (crc >> (32 - HASH_BITS)) & 0x3f;
+
+		if (hash > 31) {
+			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+			tmp |= 1 << (hash - 32);
+			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+		} else {
+			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+			tmp |= 1 << hash;
+			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+		}
+	}
+}
+
 static netdev_tx_t
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -472,8 +547,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
 	/* Reset all multicast.	*/
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+	set_multicast_list(ndev);
 #ifndef CONFIG_M5272
 	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
 	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
@@ -1590,81 +1664,6 @@ fec_enet_close(struct net_device *ndev)
 	return 0;
 }
 
-/* Set or clear the multicast filter for this adaptor.
- * Skeleton taken from sunlance driver.
- * The CPM Ethernet implementation allows Multicast as well as individual
- * MAC address filtering.  Some of the drivers check to make sure it is
- * a group multicast address, and discard those that are not.  I guess I
- * will do the same for now, but just remove the test if you want
- * individual filtering as well (do the upper net layers want or support
- * this kind of feature?).
- */
-
-#define HASH_BITS	6		/* #bits in hash */
-#define CRC32_POLY	0xEDB88320
-
-static void set_multicast_list(struct net_device *ndev)
-{
-	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct netdev_hw_addr *ha;
-	unsigned int i, bit, data, crc, tmp;
-	unsigned char hash;
-
-	if (ndev->flags & IFF_PROMISC) {
-		tmp = readl(fep->hwp + FEC_R_CNTRL);
-		tmp |= 0x8;
-		writel(tmp, fep->hwp + FEC_R_CNTRL);
-		return;
-	}
-
-	tmp = readl(fep->hwp + FEC_R_CNTRL);
-	tmp &= ~0x8;
-	writel(tmp, fep->hwp + FEC_R_CNTRL);
-
-	if (ndev->flags & IFF_ALLMULTI) {
-		/* Catch all multicast addresses, so set the
-		 * filter to all 1's
-		 */
-		writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-		writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-
-		return;
-	}
-
-	/* Clear filter and add the addresses in hash register
-	 */
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-
-	netdev_for_each_mc_addr(ha, ndev) {
-		/* calculate crc32 value of mac address */
-		crc = 0xffffffff;
-
-		for (i = 0; i < ndev->addr_len; i++) {
-			data = ha->addr[i];
-			for (bit = 0; bit < 8; bit++, data >>= 1) {
-				crc = (crc >> 1) ^
-				(((crc ^ data) & 1) ? CRC32_POLY : 0);
-			}
-		}
-
-		/* only upper 6 bits (HASH_BITS) are used
-		 * which point to specific bit in he hash registers
-		 */
-		hash = (crc >> (32 - HASH_BITS)) & 0x3f;
-
-		if (hash > 31) {
-			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-			tmp |= 1 << (hash - 32);
-			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-		} else {
-			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-			tmp |= 1 << hash;
-			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-		}
-	}
-}
-
 /* Set a MAC change in hardware. */
 static int
 fec_set_mac_address(struct net_device *ndev, void *p)
-- 
1.7.1
