From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 11/11] ixgbe: Don't reset the hardware when
	switching between LFC and PFC
Date: Sun, 17 May 2009 15:35:57 -0700
Message-ID: <20090517223556.14124.39453.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

When running in DCB mode, switching between link flow control and priority
flow control shouldn't need to reset the hardware.  This removes that
reset.

This also extends the set_all() dcbnl callback to return a value indicating
that the HW config changed, however a reset was not required.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   66 ++++++++++++++++++++++++++++----------
 1 files changed, 49 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 6cbff96..d56890f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -28,15 +28,22 @@
 
 #include "ixgbe.h"
 #include <linux/dcbnl.h>
+#include "ixgbe_dcb_82598.h"
+#include "ixgbe_dcb_82599.h"
 
 /* Callbacks for DCB netlink in the kernel */
 #define BIT_DCB_MODE	0x01
 #define BIT_PFC		0x02
 #define BIT_PG_RX	0x04
 #define BIT_PG_TX	0x08
-#define BIT_BCN         0x10
+#define BIT_RESETLINK   0x40
 #define BIT_LINKSPEED   0x80
 
+/* Responses for the DCB_C_SET_ALL command */
+#define DCB_HW_CHG_RST  0  /* DCB configuration changed with reset */
+#define DCB_NO_HW_CHG   1  /* DCB configuration did not change */
+#define DCB_HW_CHG      2  /* DCB configuration changed, no reset */
+
 int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
                        struct ixgbe_dcb_config *dst_dcb_cfg, int tc_max)
 {
@@ -195,8 +202,10 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_tx(struct net_device *netdev, int tc,
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].bwg_percent !=
 	     adapter->dcb_cfg.tc_config[tc].path[0].bwg_percent) ||
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap))
+	     adapter->dcb_cfg.tc_config[tc].path[0].up_to_tc_bitmap)) {
 		adapter->dcb_set_bitmap |= BIT_PG_TX;
+		adapter->dcb_set_bitmap |= BIT_RESETLINK;
+	}
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
@@ -207,8 +216,10 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
 	adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] = bw_pct;
 
 	if (adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] !=
-	    adapter->dcb_cfg.bw_percentage[0][bwg_id])
+	    adapter->dcb_cfg.bw_percentage[0][bwg_id]) {
 		adapter->dcb_set_bitmap |= BIT_PG_RX;
+		adapter->dcb_set_bitmap |= BIT_RESETLINK;
+	}
 }
 
 static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
@@ -235,8 +246,10 @@ static void ixgbe_dcbnl_set_pg_tc_cfg_rx(struct net_device *netdev, int tc,
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].bwg_percent !=
 	     adapter->dcb_cfg.tc_config[tc].path[1].bwg_percent) ||
 	    (adapter->temp_dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap !=
-	     adapter->dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap))
+	     adapter->dcb_cfg.tc_config[tc].path[1].up_to_tc_bitmap)) {
 		adapter->dcb_set_bitmap |= BIT_PG_RX;
+		adapter->dcb_set_bitmap |= BIT_RESETLINK;
+	}
 }
 
 static void ixgbe_dcbnl_set_pg_bwg_cfg_rx(struct net_device *netdev, int bwg_id,
@@ -247,8 +260,10 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_rx(struct net_device *netdev, int bwg_id,
 	adapter->temp_dcb_cfg.bw_percentage[1][bwg_id] = bw_pct;
 
 	if (adapter->temp_dcb_cfg.bw_percentage[1][bwg_id] !=
-	    adapter->dcb_cfg.bw_percentage[1][bwg_id])
+	    adapter->dcb_cfg.bw_percentage[1][bwg_id]) {
 		adapter->dcb_set_bitmap |= BIT_PG_RX;
+		adapter->dcb_set_bitmap |= BIT_RESETLINK;
+	}
 }
 
 static void ixgbe_dcbnl_get_pg_tc_cfg_tx(struct net_device *netdev, int tc,
@@ -317,21 +332,27 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int ret;
 
-	adapter->dcb_set_bitmap &= ~BIT_BCN;	/* no set for BCN */
 	if (!adapter->dcb_set_bitmap)
-		return 1;
+		return DCB_NO_HW_CHG;
 
-	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
-		msleep(1);
+	/*
+	 * Only take down the adapter if the configuration change
+	 * requires a reset.
+	 */
+	if (adapter->dcb_set_bitmap & BIT_RESETLINK) {
+		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+			msleep(1);
 
-	if (netif_running(netdev))
-		ixgbe_down(adapter);
+		if (netif_running(netdev))
+			ixgbe_down(adapter);
+	}
 
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
 				 adapter->ring_feature[RING_F_DCB].indices);
 	if (ret) {
-		clear_bit(__IXGBE_RESETTING, &adapter->state);
-		return ret;
+		if (adapter->dcb_set_bitmap & BIT_RESETLINK)
+			clear_bit(__IXGBE_RESETTING, &adapter->state);
+		return DCB_NO_HW_CHG;
 	}
 
 	if (adapter->dcb_cfg.pfc_mode_enable) {
@@ -346,14 +367,25 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 			adapter->hw.fc.requested_mode = ixgbe_fc_none;
 	}
 
-	if (netif_running(netdev))
-		ixgbe_up(adapter);
-
+	if (adapter->dcb_set_bitmap & BIT_RESETLINK) {
+		if (netif_running(netdev))
+			ixgbe_up(adapter);
+		ret = DCB_HW_CHG_RST;
+	} else if (adapter->dcb_set_bitmap & BIT_PFC) {
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+			ixgbe_dcb_config_pfc_82598(&adapter->hw,
+			                           &adapter->dcb_cfg);
+		else if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			ixgbe_dcb_config_pfc_82599(&adapter->hw,
+			                           &adapter->dcb_cfg);
+		ret = DCB_HW_CHG;
+	}
 	if (adapter->dcb_cfg.pfc_mode_enable)
 		adapter->hw.fc.current_mode = ixgbe_fc_pfc;
 
+	if (adapter->dcb_set_bitmap & BIT_RESETLINK)
+		clear_bit(__IXGBE_RESETTING, &adapter->state);
 	adapter->dcb_set_bitmap = 0x00;
-	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return ret;
 }
 

