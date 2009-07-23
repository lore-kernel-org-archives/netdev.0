From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Enable FCoE offload when DCB is enabled
	for 82599
Date: Wed, 22 Jul 2009 17:07:12 -0700
Message-ID: <20090723000705.27299.19299.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:42088
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750901AbZGWAHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 20:07:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Currently, FCoE offload feature is turned on when the kernel config has
CONFIG_FCOE or CONFIG_FCOE_MODULE set. However, we really want to turn
FCoE offload on when there is FCoE traffic passing and turn it off when
it's just LAN traffic. Since FCoE depends on a lossless network provided
by DCB, this allows us to have FCoE turned on/off when user turns on DCB
using dcbtool.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    1 +
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   24 ++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c   |   16 ++++++----------
 3 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index cd22323..1b12c7b 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -327,6 +327,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
 #define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 26)
 #define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 27)
+#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 28)
 #define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 29)
 
 	u32 flags2;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index da2c851..1c72657 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -139,6 +139,18 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 		}
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
+#ifdef IXGBE_FCOE
+		/* Turn on FCoE offload */
+		if ((adapter->flags & IXGBE_FLAG_FCOE_CAPABLE) &&
+		    (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))) {
+			adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
+			adapter->ring_feature[RING_F_FCOE].indices =
+				IXGBE_FCRETA_SIZE;
+			netdev->features |= NETIF_F_FCOE_CRC;
+			netdev->features |= NETIF_F_FSO;
+			netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
+		}
+#endif /* IXGBE_FCOE */
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_open(netdev);
@@ -156,6 +168,18 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 			if (adapter->hw.mac.type == ixgbe_mac_82599EB)
 				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
+#ifdef IXGBE_FCOE
+			/* Turn off FCoE offload */
+			if (adapter->flags & (IXGBE_FLAG_FCOE_CAPABLE |
+			     IXGBE_FLAG_FCOE_ENABLED)) {
+				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+				adapter->ring_feature[RING_F_FCOE].indices = 0;
+				netdev->features &= ~NETIF_F_FCOE_CRC;
+				netdev->features &= ~NETIF_F_FSO;
+				netdev->fcoe_ddp_xid = 0;
+			}
+#endif /* IXGBE_FCOE */
 			ixgbe_init_interrupt_scheme(adapter);
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_open(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e3442f4..a2119d7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3806,8 +3806,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->atr_sample_rate = 20;
 		adapter->fdir_pballoc = 0;
 #ifdef IXGBE_FCOE
-		adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
-		adapter->ring_feature[RING_F_FCOE].indices = IXGBE_FCRETA_SIZE;
+		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
+		adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+		adapter->ring_feature[RING_F_FCOE].indices = 0;
 #endif /* IXGBE_FCOE */
 	}
 
@@ -5580,16 +5581,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 #endif
 
 #ifdef IXGBE_FCOE
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+	if (adapter->flags & IXGBE_FLAG_FCOE_CAPABLE) {
 		if (hw->mac.ops.get_device_caps) {
 			hw->mac.ops.get_device_caps(hw, &device_caps);
-			if (!(device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)) {
-				netdev->features |= NETIF_F_FCOE_CRC;
-				netdev->features |= NETIF_F_FSO;
-				netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
-			} else {
-				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
-			}
+			if (device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)
+				adapter->flags &= ~IXGBE_FLAG_FCOE_CAPABLE;
 		}
 	}
 #endif /* IXGBE_FCOE */

