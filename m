From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 3/3] qlcnic: Fix updating netdev->features
Date: Tue, 21 May 2013 15:27:01 -0400
Message-ID: <1369164421-20996-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:7349 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752560Ab3EUTwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 15:52:15 -0400
In-Reply-To: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o After change in EPORT features of 82xx adapter, netdev->features needs to
  be updated to reflect EPORT feature updates but driver was manipulating
  netdev->features at wrong place.
o This patch uses netdev_update_features() and .ndo_fix_features() to
  update netdev->features properly.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       |    6 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c    |   49 +++++++++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |   49 +++------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c |    3 +
 4 files changed, 61 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 019c5f7..c1b693c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -907,8 +907,11 @@ struct qlcnic_ipaddr {
 #define QLCNIC_FW_HANG			0x4000
 #define QLCNIC_FW_LRO_MSS_CAP		0x8000
 #define QLCNIC_TX_INTR_SHARED		0x10000
+#define QLCNIC_APP_CHANGED_FLAGS	0x20000
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
+#define QLCNIC_IS_TSO_CAPABLE(adapter)  \
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 
 #define QLCNIC_DEF_NUM_STS_DESC_RINGS	4
 #define QLCNIC_MSIX_TBL_SPACE		8192
@@ -1034,6 +1037,7 @@ struct qlcnic_adapter {
 	spinlock_t rx_mac_learn_lock;
 	u32 file_prd_off;	/*File fw product offset*/
 	u32 fw_version;
+	u32 offload_flags;
 	const struct firmware *fw;
 };
 
@@ -1542,6 +1546,8 @@ void qlcnic_add_lb_filter(struct qlcnic_adapter *, struct sk_buff *, int, u16);
 int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter);
 int qlcnic_read_mac_addr(struct qlcnic_adapter *);
 int qlcnic_setup_netdev(struct qlcnic_adapter *, struct net_device *, int);
+void qlcnic_set_netdev_features(struct qlcnic_adapter *,
+				struct qlcnic_esw_func_cfg *);
 void qlcnic_sriov_vf_schedule_multi(struct net_device *);
 void qlcnic_vf_add_mc_list(struct net_device *, u16);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 6a6512b..106a12f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -973,16 +973,57 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	return rc;
 }
 
+static netdev_features_t qlcnic_process_flags(struct qlcnic_adapter *adapter,
+					      netdev_features_t features)
+{
+	u32 offload_flags = adapter->offload_flags;
+
+	if (offload_flags & BIT_0) {
+		features |= NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+			    NETIF_F_IPV6_CSUM;
+		adapter->rx_csum = 1;
+		if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
+			if (!(offload_flags & BIT_1))
+				features &= ~NETIF_F_TSO;
+			else
+				features |= NETIF_F_TSO;
+
+			if (!(offload_flags & BIT_2))
+				features &= ~NETIF_F_TSO6;
+			else
+				features |= NETIF_F_TSO6;
+		}
+	} else {
+		features &= ~(NETIF_F_RXCSUM |
+			      NETIF_F_IP_CSUM |
+			      NETIF_F_IPV6_CSUM);
+
+		if (QLCNIC_IS_TSO_CAPABLE(adapter))
+			features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+		adapter->rx_csum = 0;
+	}
+
+	return features;
+}
 
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	netdev_features_t changed;
 
-	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) &&
-	    qlcnic_82xx_check(adapter)) {
-		netdev_features_t changed = features ^ netdev->features;
-		features ^= changed & (NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
+	if (qlcnic_82xx_check(adapter) &&
+	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+		if (adapter->flags & QLCNIC_APP_CHANGED_FLAGS) {
+			features = qlcnic_process_flags(adapter, features);
+		} else {
+			changed = features ^ netdev->features;
+			features ^= changed & (NETIF_F_RXCSUM |
+					       NETIF_F_IP_CSUM |
+					       NETIF_F_IPV6_CSUM |
+					       NETIF_F_TSO |
+					       NETIF_F_TSO6);
+		}
 	}
 
 	if (!(features & NETIF_F_RXCSUM))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0da38df..aeb26a8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -84,14 +84,9 @@ static int qlcnic_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
-static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
-				struct qlcnic_esw_func_cfg *);
 static int qlcnic_vlan_rx_add(struct net_device *, __be16, u16);
 static int qlcnic_vlan_rx_del(struct net_device *, __be16, u16);
 
-#define QLCNIC_IS_TSO_CAPABLE(adapter)	\
-	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
-
 static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -1074,8 +1069,6 @@ void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 
 	if (!esw_cfg->promisc_mode)
 		adapter->flags |= QLCNIC_PROMISC_DISABLED;
-
-	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
 int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
@@ -1090,51 +1083,23 @@ int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
 			return -EIO;
 	qlcnic_set_vlan_config(adapter, &esw_cfg);
 	qlcnic_set_eswitch_port_features(adapter, &esw_cfg);
+	qlcnic_set_netdev_features(adapter, &esw_cfg);
 
 	return 0;
 }
 
-static void
-qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
-		struct qlcnic_esw_func_cfg *esw_cfg)
+void qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
+				struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev = adapter->netdev;
-	unsigned long features, vlan_features;
 
 	if (qlcnic_83xx_check(adapter))
 		return;
 
-	features = (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-		    NETIF_F_IPV6_CSUM | NETIF_F_GRO);
-	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
-			NETIF_F_IPV6_CSUM);
-
-	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
-		features |= (NETIF_F_TSO | NETIF_F_TSO6);
-		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
-	}
-
-	if (netdev->features & NETIF_F_LRO)
-		features |= NETIF_F_LRO;
-
-	if (esw_cfg->offload_flags & BIT_0) {
-		netdev->features |= features;
-		adapter->rx_csum = 1;
-		if (!(esw_cfg->offload_flags & BIT_1)) {
-			netdev->features &= ~NETIF_F_TSO;
-			features &= ~NETIF_F_TSO;
-		}
-		if (!(esw_cfg->offload_flags & BIT_2)) {
-			netdev->features &= ~NETIF_F_TSO6;
-			features &= ~NETIF_F_TSO6;
-		}
-	} else {
-		netdev->features &= ~features;
-		features &= ~features;
-		adapter->rx_csum = 0;
-	}
-
-	netdev->vlan_features = (features & vlan_features);
+	adapter->offload_flags = esw_cfg->offload_flags;
+	adapter->flags |= QLCNIC_APP_CHANGED_FLAGS;
+	netdev_update_features(netdev);
+	adapter->flags &= ~QLCNIC_APP_CHANGED_FLAGS;
 }
 
 static int
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 4e22e79..e7a2fe2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -544,6 +544,9 @@ static ssize_t qlcnic_sysfs_write_esw_config(struct file *file,
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
 			qlcnic_set_eswitch_port_features(adapter, &esw_cfg[i]);
+			rtnl_lock();
+			qlcnic_set_netdev_features(adapter, &esw_cfg[i]);
+			rtnl_unlock();
 			break;
 		case QLCNIC_ADD_VLAN:
 			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
-- 
1.5.6
