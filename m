From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] ixgbe: properly toggling netdev feature
	flags when disabling FCoE
Date: Mon, 19 Jul 2010 16:59:52 -0700
Message-ID: <20100719235949.14112.48380.stgit@localhost.localdomain>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:45224 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967237Ab0GTAAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 20:00:22 -0400
In-Reply-To: <20100719235831.14112.14175.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

When FCoE is disabled, there is a race condition that FCoE offload is
turned off but the FCoE protocol driver is still queuing I/O thinking
offload support still exists. This patch toggles off corresponding FCoE
netdev feature flags and notify the FCoE stack first, allowing FCoE
protocol stack driver to update its flags upon NETDEV_FEAT_CHANGE so no
I/O will be using offload.

Also, indicate FCoE offload flags in vlan_features in ixgbe_probe once
and do not toggle them in ixgbe_fcoe_enable/disable so when FCoE is
created on the VLAN interface, vlan_transfer_features() would properly
update the VLAN netdev features flag and notify the FCoE protocol driver
for NETDEV_FEAT_CHANGE.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |   19 ++++++-------------
 drivers/net/ixgbe/ixgbe_main.c |    5 +++++
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index f6ef4cd..1737d2b 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -622,9 +622,6 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 	netdev->features |= NETIF_F_FCOE_CRC;
 	netdev->features |= NETIF_F_FSO;
 	netdev->features |= NETIF_F_FCOE_MTU;
-	netdev->vlan_features |= NETIF_F_FCOE_CRC;
-	netdev->vlan_features |= NETIF_F_FSO;
-	netdev->vlan_features |= NETIF_F_FCOE_MTU;
 	netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
 
 	ixgbe_init_interrupt_scheme(adapter);
@@ -658,24 +655,20 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 		goto out_disable;
 
 	e_info(drv, "Disabling FCoE offload features.\n");
+	netdev->features &= ~NETIF_F_FCOE_CRC;
+	netdev->features &= ~NETIF_F_FSO;
+	netdev->features &= ~NETIF_F_FCOE_MTU;
+	netdev->fcoe_ddp_xid = 0;
+	netdev_features_change(netdev);
+
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_stop(netdev);
 
 	ixgbe_clear_interrupt_scheme(adapter);
-
 	adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
 	adapter->ring_feature[RING_F_FCOE].indices = 0;
-	netdev->features &= ~NETIF_F_FCOE_CRC;
-	netdev->features &= ~NETIF_F_FSO;
-	netdev->features &= ~NETIF_F_FCOE_MTU;
-	netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
-	netdev->vlan_features &= ~NETIF_F_FSO;
-	netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
-	netdev->fcoe_ddp_xid = 0;
-
 	ixgbe_cleanup_fcoe(adapter);
 	ixgbe_init_interrupt_scheme(adapter);
-	netdev_features_change(netdev);
 
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_open(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 813d2cb..7d619d6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6740,6 +6740,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 				adapter->flags &= ~IXGBE_FLAG_FCOE_CAPABLE;
 		}
 	}
+	if (adapter->flags & IXGBE_FLAG_FCOE_CAPABLE) {
+		netdev->vlan_features |= NETIF_F_FCOE_CRC;
+		netdev->vlan_features |= NETIF_F_FSO;
+		netdev->vlan_features |= NETIF_F_FCOE_MTU;
+	}
 #endif /* IXGBE_FCOE */
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;

