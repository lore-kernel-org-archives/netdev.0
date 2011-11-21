From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 4/5] KSZ8851-SNL: Fix MAC address change problem
Date: Mon, 21 Nov 2011 10:57:59 -0800
Message-ID: <1321901880-12883-5-git-send-email-sboyd@codeaurora.org>
References: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Cc: Tristram Ha <Tristram.Ha@micrel.com>, linux-kernel@vger.kernel.org,
	Sebastien Jan <s-jan@ti.com>, Ben Dooks <ben@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

When device is off it is under power saving mode. Changing the MAC address
in that situation will result in the device not communicating as the first
write to the MAC address register is not executed.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
[ben@simtec.co.uk: cleaned up header]
Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/ethernet/micrel/ks8851.c |   47 +++++++++++++++++++--------------
 drivers/net/ethernet/micrel/ks8851.h |    2 +-
 2 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index d1669bc..208e25a 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -343,6 +343,26 @@ static void ks8851_soft_reset(struct ks8851_net *ks, unsigned op)
 }
 
 /**
+ * ks8851_set_powermode - set power mode of the device
+ * @ks: The device state
+ * @pwrmode: The power mode value to write to KS_PMECR.
+ *
+ * Change the power mode of the chip.
+ */
+static void ks8851_set_powermode(struct ks8851_net *ks, unsigned pwrmode)
+{
+	unsigned pmecr;
+
+	netif_dbg(ks, hw, ks->netdev, "setting power mode %d\n", pwrmode);
+
+	pmecr = ks8851_rdreg16(ks, KS_PMECR);
+	pmecr &= ~PMECR_PM_MASK;
+	pmecr |= pwrmode;
+
+	ks8851_wrreg16(ks, KS_PMECR, pmecr);
+}
+
+/**
  * ks8851_write_mac_addr - write mac address to device registers
  * @dev: The network device
  *
@@ -358,8 +378,15 @@ static int ks8851_write_mac_addr(struct net_device *dev)
 
 	mutex_lock(&ks->lock);
 
+	/*
+	 * Wake up chip in case it was powered off when stopped; otherwise,
+	 * the first write to the MAC address does not take effect.
+	 */
+	ks8851_set_powermode(ks, PMECR_PM_NORMAL);
 	for (i = 0; i < ETH_ALEN; i++)
 		ks8851_wrreg8(ks, KS_MAR(i), dev->dev_addr[i]);
+	if (!netif_running(dev))
+		ks8851_set_powermode(ks, PMECR_PM_SOFTDOWN);
 
 	mutex_unlock(&ks->lock);
 
@@ -765,26 +792,6 @@ static void ks8851_tx_work(struct work_struct *work)
 }
 
 /**
- * ks8851_set_powermode - set power mode of the device
- * @ks: The device state
- * @pwrmode: The power mode value to write to KS_PMECR.
- *
- * Change the power mode of the chip.
- */
-static void ks8851_set_powermode(struct ks8851_net *ks, unsigned pwrmode)
-{
-	unsigned pmecr;
-
-	netif_dbg(ks, hw, ks->netdev, "setting power mode %d\n", pwrmode);
-
-	pmecr = ks8851_rdreg16(ks, KS_PMECR);
-	pmecr &= ~PMECR_PM_MASK;
-	pmecr |= pwrmode;
-
-	ks8851_wrreg16(ks, KS_PMECR, pmecr);
-}
-
-/**
  * ks8851_net_open - open network device
  * @dev: The network device being opened.
  *
diff --git a/drivers/net/ethernet/micrel/ks8851.h b/drivers/net/ethernet/micrel/ks8851.h
index 537fb06e..b2703a1 100644
--- a/drivers/net/ethernet/micrel/ks8851.h
+++ b/drivers/net/ethernet/micrel/ks8851.h
@@ -16,7 +16,7 @@
 #define CCR_32PIN				(1 << 0)
 
 /* MAC address registers */
-#define KS_MAR(_m)				0x15 - (_m)
+#define KS_MAR(_m)				(0x15 - (_m))
 #define KS_MARL					0x10
 #define KS_MARM					0x12
 #define KS_MARH					0x14
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
