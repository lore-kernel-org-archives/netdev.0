From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 06/13] bnx2x: nvram enables dropless flow
 control
Date: Sun, 2 Dec 2012 16:05:50 +0200
Message-ID: <1354457157-4730-7-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2500 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199Ab2LBOFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:09 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is now possible to enable dropless flow control via nvram.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |   13 +++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   20 +++++++++++++++++++-
 3 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 641d884..03647bf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1488,7 +1488,7 @@ struct bnx2x {
 
 	int			qm_cid_count;
 
-	int			dropless_fc;
+	bool			dropless_fc;
 
 	void			*t2;
 	dma_addr_t		t2_mapping;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 9a51d49..3369a50 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -500,7 +500,15 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 	u32 e3_cmn_pin_cfg1;				    /* 0x170 */
 	#define PORT_HW_CFG_E3_OVER_CURRENT_MASK            0x000000FF
 	#define PORT_HW_CFG_E3_OVER_CURRENT_SHIFT                    0
-	u32 reserved0[7];				    /* 0x174 */
+
+	/*  pause on host ring */
+	u32 generic_features;                               /* 0x174 */
+	#define PORT_HW_CFG_PAUSE_ON_HOST_RING_MASK                   0x00000001
+	#define PORT_HW_CFG_PAUSE_ON_HOST_RING_SHIFT                  0
+	#define PORT_HW_CFG_PAUSE_ON_HOST_RING_DISABLED               0x00000000
+	#define PORT_HW_CFG_PAUSE_ON_HOST_RING_ENABLED                0x00000001
+
+	u32 reserved0[6];				    /* 0x178 */
 
 	u32 aeu_int_mask;				    /* 0x190 */
 
@@ -1518,12 +1526,13 @@ enum mf_cfg_afex_vlan_mode {
 /* This structure is not applicable and should not be accessed on 57711 */
 struct func_ext_cfg {
 	u32 func_cfg;
-	#define MACP_FUNC_CFG_FLAGS_MASK                0x000000FF
+	#define MACP_FUNC_CFG_FLAGS_MASK                0x0000007F
 	#define MACP_FUNC_CFG_FLAGS_SHIFT               0
 	#define MACP_FUNC_CFG_FLAGS_ENABLED             0x00000001
 	#define MACP_FUNC_CFG_FLAGS_ETHERNET            0x00000002
 	#define MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD       0x00000004
 	#define MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD        0x00000008
+	#define MACP_FUNC_CFG_PAUSE_ON_HOST_RING        0x00000080
 
 	u32 iscsi_mac_addr_upper;
 	u32 iscsi_mac_addr_lower;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 62fcf0f..89b3d10 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10641,8 +10641,26 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 			"bad Ethernet MAC address configuration: %pM\n"
 			"change it manually before bringing up the appropriate network interface\n",
 			bp->dev->dev_addr);
+}
 
+static bool __devinit bnx2x_get_dropless_info(struct bnx2x *bp)
+{
+	int tmp;
+	u32 cfg;
 
+	if (IS_MF(bp) && !CHIP_IS_E1x(bp)) {
+		/* Take function: tmp = func */
+		tmp = BP_ABS_FUNC(bp);
+		cfg = MF_CFG_RD(bp, func_ext_config[tmp].func_cfg);
+		cfg = !!(cfg & MACP_FUNC_CFG_PAUSE_ON_HOST_RING);
+	} else {
+		/* Take port: tmp = port */
+		tmp = BP_PORT(bp);
+		cfg = SHMEM_RD(bp,
+			       dev_info.port_hw_config[tmp].generic_features);
+		cfg = !!(cfg & PORT_HW_CFG_PAUSE_ON_HOST_RING_ENABLED);
+	}
+	return cfg;
 }
 
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
@@ -11063,7 +11081,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (CHIP_IS_E1(bp))
 		bp->dropless_fc = 0;
 	else
-		bp->dropless_fc = dropless_fc;
+		bp->dropless_fc = dropless_fc | bnx2x_get_dropless_info(bp);
 
 	bp->mrrs = mrrs;
 
-- 
1.7.1
