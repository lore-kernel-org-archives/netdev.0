From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: handle iSCSI SD mode
Date: Tue, 29 Nov 2011 00:31:49 +0200
Message-ID: <1322519509-19802-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4986 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876Ab1K1WcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 17:32:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in iSCSI SD mode to bnx2x device assigned single mac address
which is supposted to be iscsi mac. If this mode is recognized
bnx2x will disable LRO, decrease number of queues to 1 and rx ring
size to the minumum allowed by FW, this in order minimize memory use.
It will tranfer mac for iscsi usage and zero primary mac of the netdev.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   12 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   21 ++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   12 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   50 +++++++++++++++++++---
 4 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0f7b7a4..6c7bd63 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2084,4 +2084,16 @@ static const u32 dmae_reg_go_c[] = {
 
 void bnx2x_set_ethtool_ops(struct net_device *netdev);
 void bnx2x_notify_link_changed(struct bnx2x *bp);
+
+
+#define BNX2X_MF_PROTOCOL(bp) \
+	((bp)->mf_config[BP_VN(bp)] & FUNC_MF_CFG_PROTOCOL_MASK)
+
+#ifdef BCM_CNIC
+#define BNX2X_IS_MF_PROTOCOL_ISCSI(bp) \
+	(BNX2X_MF_PROTOCOL(bp) == FUNC_MF_CFG_PROTOCOL_ISCSI)
+
+#define IS_MF_ISCSI_SD(bp) (IS_MF_SD(bp) && BNX2X_IS_MF_PROTOCOL_ISCSI(bp))
+#endif
+
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8336c78..76c6253 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1427,6 +1427,11 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 		break;
 	}
 
+#ifdef BCM_CNIC
+	/* override in ISCSI SD mod */
+	if (IS_MF_ISCSI_SD(bp))
+		bp->num_queues = 1;
+#endif
 	/* Add special queues */
 	bp->num_queues += NON_ETH_CONTEXT_USE;
 }
@@ -2970,8 +2975,13 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc = 0;
 
-	if (!is_valid_ether_addr((u8 *)(addr->sa_data)))
+	if (!bnx2x_is_valid_ether_addr(bp, addr->sa_data))
+		return -EINVAL;
+
+#ifdef BCM_CNIC
+	if (IS_MF_ISCSI_SD(bp) && !is_zero_ether_addr(addr->sa_data))
 		return -EINVAL;
+#endif
 
 	if (netif_running(dev))  {
 		rc = bnx2x_set_eth_mac(bp, false);
@@ -3087,7 +3097,12 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	u8 cos;
 	int rx_ring_size = 0;
 
-	/* if rx_ring_size specified - use it */
+#ifdef BCM_CNIC
+	if (IS_MF_ISCSI_SD(bp)) {
+		rx_ring_size = MIN_RX_SIZE_NONTPA;
+		bp->rx_ring_size = rx_ring_size;
+	} else
+#endif
 	if (!bp->rx_ring_size) {
 
 		rx_ring_size = MAX_RX_AVAIL/BNX2X_NUM_RX_QUEUES(bp);
@@ -3097,7 +3112,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 				     MIN_RX_SIZE_TPA, rx_ring_size);
 
 		bp->rx_ring_size = rx_ring_size;
-	} else
+	} else /* if rx_ring_size specified - use it */
 		rx_ring_size = bp->rx_ring_size;
 
 	/* Common */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 80c5ed0..2891cdc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -20,6 +20,7 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 
 
 #include "bnx2x.h"
@@ -1554,4 +1555,15 @@ static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
 	}
 }
 
+static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
+{
+	if (is_valid_ether_addr(addr))
+		return true;
+#ifdef BCM_CNIC
+	if (is_zero_ether_addr(addr) && IS_MF_ISCSI_SD(bp))
+		return true;
+#endif
+	return false;
+}
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0cdbb70..2213e0b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7017,6 +7017,13 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 {
 	unsigned long ramrod_flags = 0;
 
+#ifdef BCM_CNIC
+	if (is_zero_ether_addr(bp->dev->dev_addr) && IS_MF_ISCSI_SD(bp)) {
+		DP(NETIF_MSG_IFUP, "Ignoring Zero MAC for iSCSI SD mode\n");
+		return 0;
+	}
+#endif
+
 	DP(NETIF_MSG_IFUP, "Adding Eth MAC\n");
 
 	__set_bit(RAMROD_COMP_WAIT, &ramrod_flags);
@@ -9400,7 +9407,8 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 			bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
 
 #ifdef BCM_CNIC
-		/* iSCSI and FCoE NPAR MACs: if there is no either iSCSI or
+		/*
+		 * iSCSI and FCoE NPAR MACs: if there is no either iSCSI or
 		 * FCoE MAC then the appropriate feature should be disabled.
 		 */
 		if (IS_MF_SI(bp)) {
@@ -9422,11 +9430,22 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				val = MF_CFG_RD(bp, func_ext_config[func].
 						    fcoe_mac_addr_lower);
 				bnx2x_set_mac_buf(fip_mac, val, val2);
-				BNX2X_DEV_INFO("Read FCoE L2 MAC to %pM\n",
+				BNX2X_DEV_INFO("Read FCoE L2 MAC: %pM\n",
 					       fip_mac);
 
 			} else
 				bp->flags |= NO_FCOE_FLAG;
+		} else { /* SD mode */
+			if (BNX2X_IS_MF_PROTOCOL_ISCSI(bp)) {
+				/* use primary mac as iscsi mac */
+				memcpy(iscsi_mac, bp->dev->dev_addr, ETH_ALEN);
+				/* Zero primary MAC configuration */
+				memset(bp->dev->dev_addr, 0, ETH_ALEN);
+
+				BNX2X_DEV_INFO("SD ISCSI MODE\n");
+				BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
+					       iscsi_mac);
+			}
 		}
 #endif
 	} else {
@@ -9475,7 +9494,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	}
 #endif
 
-	if (!is_valid_ether_addr(bp->dev->dev_addr))
+	if (!bnx2x_is_valid_ether_addr(bp, bp->dev->dev_addr))
 		dev_err(&bp->pdev->dev,
 			"bad Ethernet MAC address configuration: "
 			"%pM, change it manually before bringing up "
@@ -9866,15 +9885,20 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	bp->multi_mode = multi_mode;
 
+	bp->disable_tpa = disable_tpa;
+
+#ifdef BCM_CNIC
+	bp->disable_tpa |= IS_MF_ISCSI_SD(bp);
+#endif
+
 	/* Set TPA flags */
-	if (disable_tpa) {
+	if (bp->disable_tpa) {
 		bp->flags &= ~TPA_ENABLE_FLAG;
 		bp->dev->features &= ~NETIF_F_LRO;
 	} else {
 		bp->flags |= TPA_ENABLE_FLAG;
 		bp->dev->features |= NETIF_F_LRO;
 	}
-	bp->disable_tpa = disable_tpa;
 
 	if (CHIP_IS_E1(bp))
 		bp->dropless_fc = 0;
@@ -10145,6 +10169,11 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 	}
 
 	bp->rx_mode = rx_mode;
+#ifdef BCM_CNIC
+	/* handle ISCSI SD mode */
+	if (IS_MF_ISCSI_SD(bp))
+		bp->rx_mode = BNX2X_RX_MODE_NONE;
+#endif
 
 	/* Schedule the rx_mode command */
 	if (test_bit(BNX2X_FILTER_RX_MODE_PENDING, &bp->sp_state)) {
@@ -10224,6 +10253,15 @@ static void poll_bnx2x(struct net_device *dev)
 }
 #endif
 
+static int bnx2x_validate_addr(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	if (!bnx2x_is_valid_ether_addr(bp, dev->dev_addr))
+		return -EADDRNOTAVAIL;
+	return 0;
+}
+
 static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_open		= bnx2x_open,
 	.ndo_stop		= bnx2x_close,
@@ -10231,7 +10269,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_select_queue	= bnx2x_select_queue,
 	.ndo_set_rx_mode	= bnx2x_set_rx_mode,
 	.ndo_set_mac_address	= bnx2x_change_mac_addr,
-	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_validate_addr	= bnx2x_validate_addr,
 	.ndo_do_ioctl		= bnx2x_ioctl,
 	.ndo_change_mtu		= bnx2x_change_mtu,
 	.ndo_fix_features	= bnx2x_fix_features,
-- 
1.7.7.2
