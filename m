From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2]: PHY workaround for 5709 A0.
Date: Thu, 01 Feb 2007 10:47:58 -0800
Message-ID: <1170355679.9765.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2405 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422850AbXBASDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 13:03:13 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: PHY workaround for 5709 A0.

5709 A0 copper devices will not link up with some link partners
without this workaround.

Update driver to 1.5.5.

Signed-off-by: Michael Chan <mchan@broadcom.com> 

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 953808e..ee7b75b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.4"
-#define DRV_MODULE_RELDATE	"January 24, 2007"
+#define DRV_MODULE_VERSION	"1.5.5"
+#define DRV_MODULE_RELDATE	"February 1, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -1356,6 +1356,14 @@ bnx2_init_copper_phy(struct bnx2 *bp)
 		bnx2_write_phy(bp, 0x18, 0x0400);
 	}
 
+	if (bp->phy_flags & PHY_DIS_EARLY_DAC_FLAG) {
+		bnx2_write_phy(bp, MII_BNX2_DSP_ADDRESS,
+			       MII_BNX2_DSP_EXPAND_REG | 0x8);
+		bnx2_read_phy(bp, MII_BNX2_DSP_RW_PORT, &val);
+		val &= ~(1 << 8);
+		bnx2_write_phy(bp, MII_BNX2_DSP_RW_PORT, val);
+	}
+
 	if (bp->dev->mtu > 1500) {
 		/* Set extended packet length bit */
 		bnx2_write_phy(bp, 0x18, 0x7);
@@ -5918,6 +5926,8 @@ bnx2_init_board(struct pci_dev *pdev, st
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
 		   CHIP_NUM(bp) == CHIP_NUM_5708)
 		bp->phy_flags |= PHY_CRC_FIX_FLAG;
+	else if (CHIP_ID(bp) == CHIP_ID_5709_A0)
+		bp->phy_flags |= PHY_DIS_EARLY_DAC_FLAG;
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 13b6f9b..ccbdf81 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6288,6 +6288,10 @@ struct l2_fhdr {
 
 #define BCM5708S_TX_ACTL3			0x17
 
+#define MII_BNX2_DSP_RW_PORT			0x15
+#define MII_BNX2_DSP_ADDRESS			0x17
+#define MII_BNX2_DSP_EXPAND_REG			 0x0f00
+
 #define MIN_ETHERNET_PACKET_SIZE	60
 #define MAX_ETHERNET_PACKET_SIZE	1514
 #define MAX_ETHERNET_JUMBO_PACKET_SIZE	9014
@@ -6489,6 +6493,7 @@ struct bnx2 {
 #define PHY_INT_MODE_MASK_FLAG		0x300
 #define PHY_INT_MODE_AUTO_POLLING_FLAG	0x100
 #define PHY_INT_MODE_LINK_READY_FLAG	0x200
+#define PHY_DIS_EARLY_DAC_FLAG		0x400
 
 	u32			chip_id;
 	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
@@ -6512,6 +6517,7 @@ struct bnx2 {
 #define CHIP_ID_5708_A0			0x57080000
 #define CHIP_ID_5708_B0			0x57081000
 #define CHIP_ID_5708_B1			0x57081010
+#define CHIP_ID_5709_A0			0x57090000
 
 #define CHIP_BOND_ID(bp)		(((bp)->chip_id) & 0xf)
 


