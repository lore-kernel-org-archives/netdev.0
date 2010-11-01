From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 6/8] bnx2x: Do not enable CL37 BAM unless it is
 explicitly enabled
Date: Mon, 1 Nov 2010 17:32:38 +0200
Message-ID: <1288625558.3533.18.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4138 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757443Ab0KAMOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling CL37 BAM on BCM8073 by default may lead to link issues since not all switches support it. So enable CL37 BAM only if explicitly selected.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    9 ++++++++-
 drivers/net/bnx2x/bnx2x_link.c |   18 ++++++++++++------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 18c8e23..4cfd4e9 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -244,7 +244,14 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 
 	u16 xgxs_config_tx[4];				    /* 0x1A0 */
 
-	u32 Reserved1[57];				    /* 0x1A8 */
+	u32 Reserved1[56];				    /* 0x1A8 */
+	u32 default_cfg;				    /* 0x288 */
+	/*  Enable BAM on KR */
+#define PORT_HW_CFG_ENABLE_BAM_ON_KR_MASK		      0x00100000
+#define PORT_HW_CFG_ENABLE_BAM_ON_KR_SHIFT		      20
+#define PORT_HW_CFG_ENABLE_BAM_ON_KR_DISABLED		      0x00000000
+#define PORT_HW_CFG_ENABLE_BAM_ON_KR_ENABLED		      0x00100000
+
 	u32 speed_capability_mask2;			    /* 0x28C */
 #define PORT_HW_CFG_SPEED_CAPABILITY2_D3_MASK		      0x0000FFFF
 #define PORT_HW_CFG_SPEED_CAPABILITY2_D3_SHIFT		      0
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 488e251..d076b91 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3525,13 +3525,19 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1): 0x%x\n", tmp1);
 
 	/* Enable CL37 BAM */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD,
-			MDIO_AN_REG_8073_BAM, &val);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD,
-			 MDIO_AN_REG_8073_BAM, val | 1);
+	if (REG_RD(bp, params->shmem_base +
+			 offsetof(struct shmem_region, dev_info.
+				  port_hw_config[params->port].default_cfg)) &
+	    PORT_HW_CFG_ENABLE_BAM_ON_KR_ENABLED) {
 
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_8073_BAM, &val);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8073_BAM, val | 1);
+		DP(NETIF_MSG_LINK, "Enable CL37 BAM on KR\n");
+	}
 	if (params->loopback_mode == LOOPBACK_EXT) {
 		bnx2x_807x_force_10G(bp, phy);
 		DP(NETIF_MSG_LINK, "Forced speed 10G on 807X\n");
-- 
1.7.1




