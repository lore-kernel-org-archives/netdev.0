From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: DCB X540 devices support max traffic class of 4
Date: Thu,  6 Oct 2011 04:02:35 -0700
Message-ID: <1317898959-16550-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62105 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935413Ab1JFLCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:45 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

X540 devices can only support up to 4 traffic classes and
guarantee a "lossless" traffic class on some platforms.
This patch sets the X540 devices to initialize a max
traffic class value of 4 at probe time.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   21 ++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    1 +
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2b8ff95..1f936c8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4990,17 +4990,32 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	spin_lock_init(&adapter->fdir_perfect_lock);
 
 #ifdef CONFIG_IXGBE_DCB
+	switch (hw->mac.type) {
+	case ixgbe_mac_X540:
+		adapter->dcb_cfg.num_tcs.pg_tcs = X540_TRAFFIC_CLASS;
+		adapter->dcb_cfg.num_tcs.pfc_tcs = X540_TRAFFIC_CLASS;
+		break;
+	default:
+		adapter->dcb_cfg.num_tcs.pg_tcs = MAX_TRAFFIC_CLASS;
+		adapter->dcb_cfg.num_tcs.pfc_tcs = MAX_TRAFFIC_CLASS;
+		break;
+	}
+
 	/* Configure DCB traffic classes */
 	for (j = 0; j < MAX_TRAFFIC_CLASS; j++) {
 		tc = &adapter->dcb_cfg.tc_config[j];
 		tc->path[DCB_TX_CONFIG].bwg_id = 0;
 		tc->path[DCB_TX_CONFIG].bwg_percent = 12 + (j & 1);
-		tc->path[DCB_TX_CONFIG].up_to_tc_bitmap = 1 << j;
 		tc->path[DCB_RX_CONFIG].bwg_id = 0;
 		tc->path[DCB_RX_CONFIG].bwg_percent = 12 + (j & 1);
-		tc->path[DCB_RX_CONFIG].up_to_tc_bitmap = 1 << j;
 		tc->dcb_pfc = pfc_disabled;
 	}
+
+	/* Initialize default user to priority mapping, UPx->TC0 */
+	tc = &adapter->dcb_cfg.tc_config[0];
+	tc->path[DCB_TX_CONFIG].up_to_tc_bitmap = 0xFF;
+	tc->path[DCB_RX_CONFIG].up_to_tc_bitmap = 0xFF;
+
 	adapter->dcb_cfg.bw_percentage[DCB_TX_CONFIG][0] = 100;
 	adapter->dcb_cfg.bw_percentage[DCB_RX_CONFIG][0] = 100;
 	adapter->dcb_cfg.pfc_mode_enable = false;
@@ -7019,7 +7034,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	}
 
 	/* Hardware supports up to 8 traffic classes */
-	if (tc > MAX_TRAFFIC_CLASS ||
+	if (tc > adapter->dcb_cfg.num_tcs.pg_tcs ||
 	    (hw->mac.type == ixgbe_mac_82598EB && tc < MAX_TRAFFIC_CLASS))
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index baad0cb..4ea909c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -406,6 +406,7 @@
 
 /* DCB registers */
 #define MAX_TRAFFIC_CLASS        8
+#define X540_TRAFFIC_CLASS       4
 #define IXGBE_RMCS      0x03D00
 #define IXGBE_DPMCS     0x07F40
 #define IXGBE_PDPMCS    0x0CD00
-- 
1.7.6.4
