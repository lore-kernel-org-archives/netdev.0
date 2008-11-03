From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 04/15] tg3: Preserve LAA when device control is released
Date: Mon, 3 Nov 2008 02:11:19 -0800
Message-ID: <1225751620.6175@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4898 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756679AbYKCWdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the __tg3_set_mac_addr() function earlier in the file
listing, to avoid a function prototype, and calls the function to
restore the LAA after a driver unload chip reset.  With this code in
place, the administrator can wake the machine using the LAA.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   76 +++++++++++++++++++++++++++-------------------------
 1 files changed, 39 insertions(+), 37 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e04cd98..9bd1be4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2014,6 +2014,43 @@ static void tg3_power_down_phy(struct tg3 *tp)
 	tg3_writephy(tp, MII_BMCR, BMCR_PDOWN);
 }
 
+/* tp->lock is held. */
+static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
+{
+	u32 addr_high, addr_low;
+	int i;
+
+	addr_high = ((tp->dev->dev_addr[0] << 8) |
+		     tp->dev->dev_addr[1]);
+	addr_low = ((tp->dev->dev_addr[2] << 24) |
+		    (tp->dev->dev_addr[3] << 16) |
+		    (tp->dev->dev_addr[4] <<  8) |
+		    (tp->dev->dev_addr[5] <<  0));
+	for (i = 0; i < 4; i++) {
+		if (i == 1 && skip_mac_1)
+			continue;
+		tw32(MAC_ADDR_0_HIGH + (i * 8), addr_high);
+		tw32(MAC_ADDR_0_LOW + (i * 8), addr_low);
+	}
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
+		for (i = 0; i < 12; i++) {
+			tw32(MAC_EXTADDR_0_HIGH + (i * 8), addr_high);
+			tw32(MAC_EXTADDR_0_LOW + (i * 8), addr_low);
+		}
+	}
+
+	addr_high = (tp->dev->dev_addr[0] +
+		     tp->dev->dev_addr[1] +
+		     tp->dev->dev_addr[2] +
+		     tp->dev->dev_addr[3] +
+		     tp->dev->dev_addr[4] +
+		     tp->dev->dev_addr[5]) &
+		TX_BACKOFF_SEED_MASK;
+	tw32(MAC_TX_BACKOFF_SEED, addr_high);
+}
+
 static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 {
 	u32 misc_host_ctrl;
@@ -2101,6 +2138,8 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		}
 	}
 
+	__tg3_set_mac_addr(tp, 0);
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		u32 val;
 
@@ -6901,43 +6940,6 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 }
 
 
-/* tp->lock is held. */
-static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
-{
-	u32 addr_high, addr_low;
-	int i;
-
-	addr_high = ((tp->dev->dev_addr[0] << 8) |
-		     tp->dev->dev_addr[1]);
-	addr_low = ((tp->dev->dev_addr[2] << 24) |
-		    (tp->dev->dev_addr[3] << 16) |
-		    (tp->dev->dev_addr[4] <<  8) |
-		    (tp->dev->dev_addr[5] <<  0));
-	for (i = 0; i < 4; i++) {
-		if (i == 1 && skip_mac_1)
-			continue;
-		tw32(MAC_ADDR_0_HIGH + (i * 8), addr_high);
-		tw32(MAC_ADDR_0_LOW + (i * 8), addr_low);
-	}
-
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
-		for (i = 0; i < 12; i++) {
-			tw32(MAC_EXTADDR_0_HIGH + (i * 8), addr_high);
-			tw32(MAC_EXTADDR_0_LOW + (i * 8), addr_low);
-		}
-	}
-
-	addr_high = (tp->dev->dev_addr[0] +
-		     tp->dev->dev_addr[1] +
-		     tp->dev->dev_addr[2] +
-		     tp->dev->dev_addr[3] +
-		     tp->dev->dev_addr[4] +
-		     tp->dev->dev_addr[5]) &
-		TX_BACKOFF_SEED_MASK;
-	tw32(MAC_TX_BACKOFF_SEED, addr_high);
-}
-
 static int tg3_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct tg3 *tp = netdev_priv(dev);
-- 
1.5.6.4



