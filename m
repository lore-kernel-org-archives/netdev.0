From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/3] ixgbe: Fix NAPI enable/disable path when using
	DCB
Date: Thu, 25 Dec 2008 01:02:23 -0800
Message-ID: <20081225090223.13754.9178.stgit@lost.foo-projects.org>
References: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:50907 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751597AbYLYJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 04:02:41 -0500
In-Reply-To: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This change allows DCB mode to change the number of queues, and presumably
the number of NAPI instances, safely.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c   |   11 ++++++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 8ac639d..4129976 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -148,6 +148,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			netdev->netdev_ops->ndo_stop(netdev);
 		ixgbe_reset_interrupt_capability(adapter);
 		ixgbe_napi_del_all(adapter);
+		INIT_LIST_HEAD(&netdev->napi_list);
 		kfree(adapter->tx_ring);
 		kfree(adapter->rx_ring);
 		adapter->tx_ring = NULL;
@@ -157,7 +158,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		ixgbe_init_interrupt_scheme(adapter);
-		ixgbe_napi_add_all(adapter);
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_open(netdev);
 	} else {
@@ -167,6 +167,7 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 				netdev->netdev_ops->ndo_stop(netdev);
 			ixgbe_reset_interrupt_capability(adapter);
 			ixgbe_napi_del_all(adapter);
+			INIT_LIST_HEAD(&netdev->napi_list);
 			kfree(adapter->tx_ring);
 			kfree(adapter->rx_ring);
 			adapter->tx_ring = NULL;
@@ -176,7 +177,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 			ixgbe_init_interrupt_scheme(adapter);
-			ixgbe_napi_add_all(adapter);
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_open(netdev);
 		}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b6ae9f6..acef3c6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2064,6 +2064,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	else
 		ixgbe_configure_msi_and_legacy(adapter);
 
+	ixgbe_napi_add_all(adapter);
+
 	clear_bit(__IXGBE_DOWN, &adapter->state);
 	ixgbe_napi_enable_all(adapter);
 
@@ -3176,8 +3178,13 @@ static int ixgbe_close(struct net_device *netdev)
 void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx, q_vectors;
+	struct net_device *netdev = adapter->netdev;
 	int (*poll)(struct napi_struct *, int);
 
+	/* check if we already have our netdev->napi_list populated */
+	if (&netdev->napi_list != netdev->napi_list.next)
+		return;
+
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		poll = &ixgbe_clean_rxonly;
 		/* Only enable as many vectors as we have rx queues. */
@@ -3271,6 +3278,7 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 	ixgbe_reset_interrupt_capability(adapter);
 	ixgbe_napi_del_all(adapter);
+	INIT_LIST_HEAD(&netdev->napi_list);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 
@@ -4212,8 +4220,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
 
-	ixgbe_napi_add_all(adapter);
-
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
@@ -4299,7 +4305,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 
 	DPRINTK(PROBE, INFO, "complete\n");
-	ixgbe_napi_del_all(adapter);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 

