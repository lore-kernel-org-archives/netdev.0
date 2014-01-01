From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2: Enable auto-mdix when autoneg is disabled.
Date: Tue, 31 Dec 2013 23:22:33 -0800
Message-ID: <1388560955-32586-3-git-send-email-mchan@broadcom.com>
References: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
 <1388560955-32586-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52675 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbaAAG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:58:48 -0500
In-Reply-To: <1388560955-32586-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auto-mdix currently only works if autoneg is enabled.  This patch enables
auto-mdix all the time by setting a bit in a PHY register.  Define
meaningful constants for this PHY registers.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   12 +++++++++---
 drivers/net/ethernet/broadcom/bnx2.h |    6 ++++++
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 1ae3348..b380c69 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2343,9 +2343,15 @@ bnx2_init_copper_phy(struct bnx2 *bp, int reset_phy)
 	}
 
 	/* ethernet@wirespeed */
-	bnx2_write_phy(bp, 0x18, 0x7007);
-	bnx2_read_phy(bp, 0x18, &val);
-	bnx2_write_phy(bp, 0x18, val | (1 << 15) | (1 << 4));
+	bnx2_write_phy(bp, MII_BNX2_AUX_CTL, AUX_CTL_MISC_CTL);
+	bnx2_read_phy(bp, MII_BNX2_AUX_CTL, &val);
+	val |=  AUX_CTL_MISC_CTL_WR | AUX_CTL_MISC_CTL_WIRESPEED;
+
+	/* auto-mdix */
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
+		val |=  AUX_CTL_MISC_CTL_AUTOMDIX;
+
+	bnx2_write_phy(bp, MII_BNX2_AUX_CTL, val);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 18cb2d2..39f40d1 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6471,6 +6471,12 @@ struct l2_fhdr {
 
 #define BCM5708S_TX_ACTL3			0x17
 
+#define MII_BNX2_AUX_CTL			0x18
+#define AUX_CTL_MISC_CTL			 0x7007
+#define AUX_CTL_MISC_CTL_WIRESPEED		  (1 << 4)
+#define AUX_CTL_MISC_CTL_AUTOMDIX		  (1 << 9)
+#define AUX_CTL_MISC_CTL_WR			  (1 << 15)
+
 #define MII_BNX2_DSP_RW_PORT			0x15
 #define MII_BNX2_DSP_ADDRESS			0x17
 #define MII_BNX2_DSP_EXPAND_REG			 0x0f00
-- 
1.7.1
