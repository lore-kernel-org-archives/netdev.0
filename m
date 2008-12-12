From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgbe: fix DCB setstate to return success/failure
Date: Fri, 12 Dec 2008 01:53:33 -0800
Message-ID: <20081212095333.4458.80881.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Eric W Multanen <eric.w.multanen@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:42669 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758285AbYLLJxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 04:53:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Fix the DCB setstate operation function to check and not attempt
to enable DCB if MSI-X is not enabled.  Return a sucess/failure
status to DCB netlink layer.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   47 ++++++++++++++++++++++----------------
 1 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 615c280..a5d15e4 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -124,8 +124,9 @@ static u16 ixgbe_dcb_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
+static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 {
+	u8 err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	DPRINTK(DRV, INFO, "Set DCB Admin Mode.\n");
@@ -133,25 +134,31 @@ static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	if (state > 0) {
 		/* Turn on DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			return;
-		} else {
-			if (netif_running(netdev))
-				netdev->stop(netdev);
-			ixgbe_reset_interrupt_capability(adapter);
-			ixgbe_napi_del_all(adapter);
-			kfree(adapter->tx_ring);
-			kfree(adapter->rx_ring);
-			adapter->tx_ring = NULL;
-			adapter->rx_ring = NULL;
-			netdev->select_queue = &ixgbe_dcb_select_queue;
+			goto out;
+		}
 
-			adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-			adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
-			ixgbe_init_interrupt_scheme(adapter);
-			ixgbe_napi_add_all(adapter);
-			if (netif_running(netdev))
-				netdev->open(netdev);
+		if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+			DPRINTK(DRV, ERR, "Enable Failed, needs MSI-X\n");
+			err = 1;
+			goto out;
 		}
+
+		if (netif_running(netdev))
+			netdev->stop(netdev);
+		ixgbe_reset_interrupt_capability(adapter);
+		ixgbe_napi_del_all(adapter);
+		kfree(adapter->tx_ring);
+		kfree(adapter->rx_ring);
+		adapter->tx_ring = NULL;
+		adapter->rx_ring = NULL;
+		netdev->select_queue = &ixgbe_dcb_select_queue;
+
+		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
+		ixgbe_init_interrupt_scheme(adapter);
+		ixgbe_napi_add_all(adapter);
+		if (netif_running(netdev))
+			netdev->open(netdev);
 	} else {
 		/* Turn off DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
@@ -171,10 +178,10 @@ static void ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			ixgbe_napi_add_all(adapter);
 			if (netif_running(netdev))
 				netdev->open(netdev);
-		} else {
-			return;
 		}
 	}
+out:
+	return err;
 }
 
 static void ixgbe_dcbnl_get_perm_hw_addr(struct net_device *netdev,

