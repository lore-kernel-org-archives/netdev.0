From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 08/10] bnx2x: Add CMS functionality for 848x3
Date: Mon, 31 Jan 2011 16:22:46 +0200
Message-ID: <1296483766.17181.118.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837Ab1AaOZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CMS(Common Mode Sense) functionality for 848x3 as this reduces power consumption and allows a better 10G link stability

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    6 ++++++
 drivers/net/bnx2x/bnx2x_link.c |   17 ++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 7c35f4e..51d69db 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -330,6 +330,12 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 #define PORT_HW_CFG_ENABLE_BAM_ON_KR_DISABLED		      0x00000000
 #define PORT_HW_CFG_ENABLE_BAM_ON_KR_ENABLED		      0x00100000
 
+	/*  Enable Common Mode Sense */
+#define PORT_HW_CFG_ENABLE_CMS_MASK			      0x00200000
+#define PORT_HW_CFG_ENABLE_CMS_SHIFT			      21
+#define PORT_HW_CFG_ENABLE_CMS_DISABLED			      0x00000000
+#define PORT_HW_CFG_ENABLE_CMS_ENABLED			      0x00200000
+
 	u32 speed_capability_mask2;			    /* 0x28C */
 #define PORT_HW_CFG_SPEED_CAPABILITY2_D3_MASK		      0x0000FFFF
 #define PORT_HW_CFG_SPEED_CAPABILITY2_D3_SHIFT		      0
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index aeaeea1..9ef15ce 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -6301,7 +6301,7 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	u8 port, initialize = 1;
 	u16 val, adj;
 	u16 temp;
-	u32 actual_phy_selection;
+	u32 actual_phy_selection, cms_enable;
 	u8 rc = 0;
 
 	/* This is just for MDIO_CTL_REG_84823_MEDIA register. */
@@ -6373,6 +6373,21 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		rc = bnx2x_848xx_cmn_config_init(phy, params, vars);
 	else
 		bnx2x_save_848xx_spirom_version(phy, params);
+	cms_enable = REG_RD(bp, params->shmem_base +
+			offsetof(struct shmem_region,
+			dev_info.port_hw_config[params->port].default_cfg)) &
+			PORT_HW_CFG_ENABLE_CMS_MASK;
+
+	bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+		MDIO_CTL_REG_84823_USER_CTRL_REG, &val);
+	if (cms_enable)
+		val |= MDIO_CTL_REG_84823_USER_CTRL_CMS;
+	else
+		val &= ~MDIO_CTL_REG_84823_USER_CTRL_CMS;
+	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+		MDIO_CTL_REG_84823_USER_CTRL_REG, val);
+
+
 	return rc;
 }
 
-- 
1.7.1





