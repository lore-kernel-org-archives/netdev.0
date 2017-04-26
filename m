From: <David.Cai@microchip.com>
Subject: [PATCH v3 net-next]smsc911x: Adding support for Micochip LAN9250
 Ethernet controller
Date: Wed, 26 Apr 2017 13:55:52 +0000
Message-ID: <C3C28FB10418274EB7FD7C2B85C796A441247573@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <steve.glendinning@shawell.net>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:47867 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3000792AbdDZNzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:55:55 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Cai <david.cai@microchip.com>

Adding support for Microchip LAN9250 Ethernet controller.

Signed-off-by: David Cai <david.cai@microchip.com>
---
Changes
V2
 -  email format changed
 - remove unnecessary text in commit log Changes
V3
 - defined all supported Ethernet controller chip ID.
 - removed pdata->sub_generation = 0;
 - changed 'if (pdata->sub_generation)' to 
 	 if (pdata>generation == 4 && pdata->sub_generation)
 
 drivers/net/ethernet/smsc/smsc911x.c | 55 ++++++++++++++++++++++++------------
 drivers/net/ethernet/smsc/smsc911x.h | 19 +++++++++++++
 2 files changed, 56 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index fa5ca09..e35fe96 100644
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
 	 * Make sure to power-up the PHY chip before doing a reset, otherwise @@ -1476,15 +1481,23 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 		}
 	}
 
+	if (pdata->generation == 4 && pdata->sub_generation) {
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
@@ -2253,31 +2266,37 @@ static int smsc911x_init(struct net_device *dev)
 
 	pdata->idrev = smsc911x_reg_read(pdata, ID_REV);
 	switch (pdata->idrev & 0xFFFF0000) {
-	case 0x01180000:
-	case 0x01170000:
-	case 0x01160000:
-	case 0x01150000:
-	case 0x218A0000:
+	case LAN9118:
+	case LAN9117:
+	case LAN9116:
+	case LAN9115:
+	case LAN89218:
 		/* LAN911[5678] family */
 		pdata->generation = pdata->idrev & 0x0000FFFF;
 		break;
 
-	case 0x118A0000:
-	case 0x117A0000:
-	case 0x116A0000:
-	case 0x115A0000:
+	case LAN9218:
+	case LAN9217:
+	case LAN9216:
+	case LAN9215:
 		/* LAN921[5678] family */
 		pdata->generation = 3;
 		break;
 
-	case 0x92100000:
-	case 0x92110000:
-	case 0x92200000:
-	case 0x92210000:
+	case LAN9210:
+	case LAN9211:
+	case LAN9220:
+	case LAN9221:
 		/* LAN9210/LAN9211/LAN9220/LAN9221 */
 		pdata->generation = 4;
 		break;
 
+	case LAN9250:
+		/* LAN9250 */
+		pdata->generation = 4;
+		pdata->sub_generation = 1;
+		break;
+
 	default:
 		SMSC_WARN(pdata, probe, "LAN911x not identified, idrev: 0x%08X",
 			  pdata->idrev);
diff --git a/drivers/net/ethernet/smsc/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
index 54d6489..8d75508 100644
--- a/drivers/net/ethernet/smsc/smsc911x.h
+++ b/drivers/net/ethernet/smsc/smsc911x.h
@@ -20,6 +20,22 @@
 #ifndef __SMSC911X_H__
 #define __SMSC911X_H__
 
+/*Chip ID*/
+#define LAN9115	0x01150000
+#define LAN9116	0x01160000
+#define LAN9117	0x01170000
+#define LAN9118	0x01180000
+#define LAN9215	0x115A0000
+#define LAN9216	0x116A0000
+#define LAN9217	0x117A0000
+#define LAN9218	0x118A0000
+#define LAN9210	0x92100000
+#define LAN9211	0x92110000
+#define LAN9220	0x92200000
+#define LAN9221	0x92210000
+#define LAN9250	0x92500000
+#define LAN89218	0x218A0000
+
 #define TX_FIFO_LOW_THRESHOLD	((u32)1600)
 #define SMSC911X_EEPROM_SIZE	((u32)128)
 #define USE_DEBUG		0
@@ -303,6 +319,9 @@
 #define E2P_DATA_EEPROM_DATA_		0x000000FF
 #define LAN_REGISTER_EXTENT		0x00000100
 
+#define RESET_CTL			0x1F8
+#define RESET_CTL_DIGITAL_RST_		0x00000001
+
 /*
  * MAC Control and Status Register (Indirect Address)
  * Offset (through the MAC_CSR CMD and DATA port)
