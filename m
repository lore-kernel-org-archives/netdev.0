From: <David.Cai@microchip.com>
Subject: [PATCH v2 net-next]smsc911x: Adding support for Micochip LAN9250
 Ethernet controller
Date: Wed, 19 Apr 2017 21:26:43 +0000
Message-ID: <C3C28FB10418274EB7FD7C2B85C796A4412465FE@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <steve.glendinning@shawell.net>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:12724 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938270AbdDSV0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:26:45 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding support for Microchip LAN9250 Ethernet controller.

Signed-off-by: David Cai <david.cai@microchip.com>
---
Changes
V2
 -  email format changed
 - remove unnecessary text in commit log

 drivers/net/ethernet/smsc/smsc911x.c | 32 +++++++++++++++++++++++++++-----
 drivers/net/ethernet/smsc/smsc911x.h |  3 +++
 2 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index fa5ca09..22b1951 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -25,7 +25,7 @@
  *   LAN9215, LAN9216, LAN9217, LAN9218
  *   LAN9210, LAN9211
  *   LAN9220, LAN9221
- *   LAN89218
+ *   LAN89218,LAN9250
  *
  */
 
@@ -104,6 +104,9 @@ struct smsc911x_data {
 	/* used to decide which workarounds apply */
 	unsigned int generation;
 
+	/* used to decide which sub generation product work arounds to apply */
+	unsigned int sub_generation;
+
 	/* device configuration (copied from platform_data during probe) */
 	struct smsc911x_platform_config config;
 
@@ -1450,6 +1453,8 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 	unsigned int timeout;
 	unsigned int temp;
 	int ret;
+	unsigned int reset_offset = HW_CFG;
+	unsigned int reset_mask = HW_CFG_SRST_;
 
 	/*
 	 * Make sure to power-up the PHY chip before doing a reset, otherwise
@@ -1476,15 +1481,23 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 		}
 	}
 
+	if (pdata->sub_generation) {
+		/* special reset for  LAN9250 */
+		reset_offset = RESET_CTL;
+		reset_mask = RESET_CTL_DIGITAL_RST_;
+	}
+
 	/* Reset the LAN911x */
-	smsc911x_reg_write(pdata, HW_CFG, HW_CFG_SRST_);
+	smsc911x_reg_write(pdata, reset_offset, reset_mask);
+
+	/* verify reset bit is cleared */
 	timeout = 10;
 	do {
 		udelay(10);
-		temp = smsc911x_reg_read(pdata, HW_CFG);
-	} while ((--timeout) && (temp & HW_CFG_SRST_));
+		temp = smsc911x_reg_read(pdata, reset_offset);
+	} while ((--timeout) && (temp & reset_mask));
 
-	if (unlikely(temp & HW_CFG_SRST_)) {
+	if (unlikely(temp & reset_mask)) {
 		SMSC_WARN(pdata, drv, "Failed to complete reset");
 		return -EIO;
 	}
@@ -2251,6 +2264,9 @@ static int smsc911x_init(struct net_device *dev)
 	/* Default generation to zero (all workarounds apply) */
 	pdata->generation = 0;
 
+	/* Default sub_generation to zero */
+	pdata->sub_generation = 0;
+
 	pdata->idrev = smsc911x_reg_read(pdata, ID_REV);
 	switch (pdata->idrev & 0xFFFF0000) {
 	case 0x01180000:
@@ -2278,6 +2294,12 @@ static int smsc911x_init(struct net_device *dev)
 		pdata->generation = 4;
 		break;
 
+	case 0x92500000:
+		/* LAN9250 */
+		pdata->generation = 4;
+		pdata->sub_generation = 1;
+		break;
+
 	default:
 		SMSC_WARN(pdata, probe, "LAN911x not identified, idrev: 0x%08X",
 			  pdata->idrev);
diff --git a/drivers/net/ethernet/smsc/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
index 54d6489..6b2d479 100644
--- a/drivers/net/ethernet/smsc/smsc911x.h
+++ b/drivers/net/ethernet/smsc/smsc911x.h
@@ -303,6 +303,9 @@
 #define E2P_DATA_EEPROM_DATA_		0x000000FF
 #define LAN_REGISTER_EXTENT		0x00000100
 
+#define RESET_CTL			0x1F8
+#define RESET_CTL_DIGITAL_RST_		0x00000001
+
 /*
  * MAC Control and Status Register (Indirect Address)
  * Offset (through the MAC_CSR CMD and DATA port)
-- 
2.7.4
