From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] vmxnet3: remove set_flag_le{16,64} functions
Date: Sat, 16 Oct 2010 00:33:12 -0700
Message-ID: <1287214392-8963-1-git-send-email-harvey.harrison@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57641 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab0JPHdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 03:33:36 -0400
Received: by iwn35 with SMTP id 35so1730575iwn.19
        for <netdev@vger.kernel.org>; Sat, 16 Oct 2010 00:33:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Opencode the flag setting in the few places it was being done.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c     |   35 +++++++-------------------------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |   10 +++-----
 drivers/net/vmxnet3/vmxnet3_int.h     |    4 ---
 3 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 198ce92..c52d259 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1548,23 +1548,6 @@ vmxnet3_free_irqs(struct vmxnet3_adapter *adapter)
 	}
 }
 
-
-inline void set_flag_le16(__le16 *data, u16 flag)
-{
-	*data = cpu_to_le16(le16_to_cpu(*data) | flag);
-}
-
-inline void set_flag_le64(__le64 *data, u64 flag)
-{
-	*data = cpu_to_le64(le64_to_cpu(*data) | flag);
-}
-
-inline void reset_flag_le64(__le64 *data, u64 flag)
-{
-	*data = cpu_to_le64(le64_to_cpu(*data) & ~flag);
-}
-
-
 static void
 vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
@@ -1580,8 +1563,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 			adapter->vlan_grp = grp;
 
 			/* update FEATURES to device */
-			set_flag_le64(&devRead->misc.uptFeatures,
-				      UPT1_F_RXVLAN);
+			devRead->misc.uptFeatures |= cpu_to_le64(UPT1_F_RXVLAN);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
 			/*
@@ -1617,8 +1599,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
 
 			/* update FEATURES to device */
-			reset_flag_le64(&devRead->misc.uptFeatures,
-					UPT1_F_RXVLAN);
+			devRead->misc.uptFeatures |= cpu_to_le64(UPT1_F_RXVLAN);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
 		}
@@ -1779,15 +1760,15 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 
 	/* set up feature flags */
 	if (adapter->rxcsum)
-		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXCSUM);
+		devRead->misc.uptFeatures |= cpu_to_le64(UPT1_F_RXCSUM);
 
 	if (adapter->lro) {
-		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_LRO);
+		devRead->misc.uptFeatures |= cpu_to_le64(UPT1_F_LRO);
 		devRead->misc.maxNumRxSG = cpu_to_le16(1 + MAX_SKB_FRAGS);
 	}
 	if ((adapter->netdev->features & NETIF_F_HW_VLAN_RX) &&
 	    adapter->vlan_grp) {
-		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXVLAN);
+		devRead->misc.uptFeatures |= cpu_to_le64(UPT1_F_RXVLAN);
 	}
 
 	devRead->misc.mtu = cpu_to_le32(adapter->netdev->mtu);
@@ -2594,7 +2575,7 @@ vmxnet3_suspend(struct device *device)
 		memcpy(pmConf->filters[i].pattern, netdev->dev_addr, ETH_ALEN);
 		pmConf->filters[i].mask[0] = 0x3F; /* LSB ETH_ALEN bits */
 
-		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_FILTER);
+		pmConf->wakeUpEvents |= cpu_to_le16(VMXNET3_PM_WAKEUP_FILTER);
 		i++;
 	}
 
@@ -2636,13 +2617,13 @@ vmxnet3_suspend(struct device *device)
 		pmConf->filters[i].mask[5] = 0x03; /* IPv4 TIP */
 		in_dev_put(in_dev);
 
-		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_FILTER);
+		pmConf->wakeUpEvents |= cpu_to_le16(VMXNET3_PM_WAKEUP_FILTER);
 		i++;
 	}
 
 skip_arp:
 	if (adapter->wol & WAKE_MAGIC)
-		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_MAGIC);
+		pmConf->wakeUpEvents |= cpu_to_le16(VMXNET3_PM_WAKEUP_MAGIC);
 
 	pmConf->numFilters = i;
 
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 7e4b5a8..79a72e8 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -50,13 +50,11 @@ vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
 		adapter->rxcsum = val;
 		if (netif_running(netdev)) {
 			if (val)
-				set_flag_le64(
-				&adapter->shared->devRead.misc.uptFeatures,
-				UPT1_F_RXCSUM);
+				adapter->shared->devRead.misc.uptFeatures |=
+					cpu_to_le64(UPT1_F_RXCSUM);
 			else
-				reset_flag_le64(
-				&adapter->shared->devRead.misc.uptFeatures,
-				UPT1_F_RXCSUM);
+				adapter->shared->devRead.misc.uptFeatures &= 
+					~cpu_to_le64(UPT1_F_RXCSUM);
 
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 2121c73..46aee6d 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -353,10 +353,6 @@ struct vmxnet3_adapter {
 #define VMXNET3_MAX_ETH_HDR_SIZE    22
 #define VMXNET3_MAX_SKB_BUF_SIZE    (3*1024)
 
-void set_flag_le16(__le16 *data, u16 flag);
-void set_flag_le64(__le64 *data, u64 flag);
-void reset_flag_le64(__le64 *data, u64 flag);
-
 int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
 
-- 
1.7.1

