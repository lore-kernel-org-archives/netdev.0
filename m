From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 07/12] ixgbe: Add support for the
	net_device_ops.ndo_fcoe_control to 82599
Date: Fri, 14 Aug 2009 15:43:24 -0700
Message-ID: <20090814224323.1640.74134.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:58145
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757189AbZHNWno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 18:43:44 -0400
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds support to the net_device_ops.ndo_fcoe_control for 82599. This
consequently allows us to dynamically turn FCoE offload feature on or off
upon incoming calls to ndo_fcoe_control. When this happens, FCoE offload
features are enabled/disabled accordingly, and this is regardless of whether
DCB being turned on or not.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    1 
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   33 ----------
 drivers/net/ixgbe/ixgbe_fcoe.c   |  120 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c   |    1 
 4 files changed, 122 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 8f1f8ba..3c25524 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -485,6 +485,7 @@ extern int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 extern int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
                               struct scatterlist *sgl, unsigned int sgc);
 extern int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid);
+extern int ixgbe_fcoe_control(struct net_device *netdev, u32 op);
 #endif /* IXGBE_FCOE */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 34bca45..e05c62a 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -139,23 +139,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 		}
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
-#ifdef IXGBE_FCOE
-		/* Turn on FCoE offload */
-		if ((adapter->flags & IXGBE_FLAG_FCOE_CAPABLE) &&
-		    (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))) {
-			adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
-			adapter->ring_feature[RING_F_FCOE].indices =
-				IXGBE_FCRETA_SIZE;
-			netdev->features |= NETIF_F_FCOE_CRC;
-			netdev->features |= NETIF_F_FSO;
-			netdev->features |= NETIF_F_FCOE_MTU;
-			netdev->vlan_features |= NETIF_F_FCOE_CRC;
-			netdev->vlan_features |= NETIF_F_FSO;
-			netdev->vlan_features |= NETIF_F_FCOE_MTU;
-			netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
-			netdev_features_change(netdev);
-		}
-#endif /* IXGBE_FCOE */
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_open(netdev);
@@ -174,22 +157,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			if (adapter->hw.mac.type == ixgbe_mac_82599EB)
 				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 
-#ifdef IXGBE_FCOE
-			/* Turn off FCoE offload */
-			if (adapter->flags & (IXGBE_FLAG_FCOE_CAPABLE |
-			     IXGBE_FLAG_FCOE_ENABLED)) {
-				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
-				adapter->ring_feature[RING_F_FCOE].indices = 0;
-				netdev->features &= ~NETIF_F_FCOE_CRC;
-				netdev->features &= ~NETIF_F_FSO;
-				netdev->features &= ~NETIF_F_FCOE_MTU;
-				netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
-				netdev->vlan_features &= ~NETIF_F_FSO;
-				netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
-				netdev->fcoe_ddp_xid = 0;
-				netdev_features_change(netdev);
-			}
-#endif /* IXGBE_FCOE */
 			ixgbe_init_interrupt_scheme(adapter);
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_open(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 28cf104..b67ed27 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -554,3 +554,123 @@ void ixgbe_cleanup_fcoe(struct ixgbe_adapter *adapter)
 		fcoe->pool = NULL;
 	}
 }
+
+/**
+ * ixgbe_enable_fcoe - turn on FCoE offload feature
+ * @netdev: the corresponding netdev
+ *
+ * Turns on FCoE offload feature in 82599.
+ *
+ * Returns : 0 indicates success or -EINVAL on failure
+ */
+static int ixgbe_enable_fcoe(struct net_device *netdev)
+{
+	int rc = -EINVAL;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+		goto out_enable;
+
+	DPRINTK(DRV, INFO, "Enabling FCoE offload features.\n");
+	if (netif_running(netdev))
+		netdev->netdev_ops->ndo_stop(netdev);
+
+	ixgbe_clear_interrupt_scheme(adapter);
+
+	adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
+	adapter->ring_feature[RING_F_FCOE].indices = IXGBE_FCRETA_SIZE;
+	netdev->features |= NETIF_F_FCOE_CRC;
+	netdev->features |= NETIF_F_FSO;
+	netdev->features |= NETIF_F_FCOE_MTU;
+	netdev->vlan_features |= NETIF_F_FCOE_CRC;
+	netdev->vlan_features |= NETIF_F_FSO;
+	netdev->vlan_features |= NETIF_F_FCOE_MTU;
+	netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
+	netdev_features_change(netdev);
+
+	ixgbe_init_interrupt_scheme(adapter);
+
+	if (netif_running(netdev))
+		netdev->netdev_ops->ndo_open(netdev);
+	rc = 0;
+
+out_enable:
+	return rc;
+}
+
+/**
+ * ixgbe_disable_fcoe - turn off FCoE offload feature
+ * @netdev: the corresponding netdev
+ *
+ * Turns off FCoE offload feature in 82599.
+ *
+ * Returns : 0 indicates success or -EINVAL on failure
+ */
+static int ixgbe_disable_fcoe(struct net_device *netdev)
+{
+	int rc = -EINVAL;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
+		goto out_disable;
+
+	DPRINTK(DRV, INFO, "Disabling FCoE offload features.\n");
+	if (netif_running(netdev))
+		netdev->netdev_ops->ndo_stop(netdev);
+
+	ixgbe_clear_interrupt_scheme(adapter);
+
+	adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+	adapter->ring_feature[RING_F_FCOE].indices = 0;
+	netdev->features &= ~NETIF_F_FCOE_CRC;
+	netdev->features &= ~NETIF_F_FSO;
+	netdev->features &= ~NETIF_F_FCOE_MTU;
+	netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
+	netdev->vlan_features &= ~NETIF_F_FSO;
+	netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
+	netdev->fcoe_ddp_xid = 0;
+	netdev_features_change(netdev);
+
+	ixgbe_cleanup_fcoe(adapter);
+
+	ixgbe_init_interrupt_scheme(adapter);
+	if (netif_running(netdev))
+		netdev->netdev_ops->ndo_open(netdev);
+	rc = 0;
+
+out_disable:
+	return rc;
+}
+
+/**
+ * ixgbe_fcoe_control - turn on or off FCoE offload feature
+ * @adapter : ixgbe adapter
+ * @ops : FCoE related command codes
+ *
+ * Supports op code NETDEV_FCOE_ENABLE to turn on FCoE offload
+ * features and op code NETDEV_FCOE_DISABLE to turn off FCoE
+ * offload features in 82599.
+ *
+ * Returns : 0 indicates success or -EINVAL on failure
+ */
+int ixgbe_fcoe_control(struct net_device *netdev, u32 op)
+{
+	int rc = -EINVAL;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (!(adapter->flags & IXGBE_FLAG_FCOE_CAPABLE))
+		goto out;
+
+	switch (op) {
+	case NETDEV_FCOE_ENABLE:
+		rc = ixgbe_enable_fcoe(netdev);
+		break;
+	case NETDEV_FCOE_DISABLE:
+		rc = ixgbe_disable_fcoe(netdev);
+		break;
+	default:
+		break;
+	}
+out:
+	return rc;
+}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d69d277..9738317 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5376,6 +5376,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #ifdef IXGBE_FCOE
 	.ndo_fcoe_ddp_setup = ixgbe_fcoe_ddp_get,
 	.ndo_fcoe_ddp_done = ixgbe_fcoe_ddp_put,
+	.ndo_fcoe_control = ixgbe_fcoe_control,
 #endif /* IXGBE_FCOE */
 };
 

