From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 03/10] vmxnet3: fix messages printed before registration
Date: Tue, 15 Jan 2013 09:28:28 -0800
Message-ID: <1358270915-32758-4-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:32983 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823Ab3AORaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:08 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so170639pbc.28
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:08 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This messages that occur during boot time from this device
when netdev_err is called before calling register_netdevice().
Switch to using dev_XXX macros which correlate message with PCI info which
is available.

Rather than fixing the features message, just remove it since
the information is redundant and available through ethtool.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 99ef9ed..7b10d9c 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2671,10 +2671,6 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 	netdev->vlan_features = netdev->hw_features &
 				~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_FILTER;
-
-	netdev_info(adapter->netdev,
-		"features: sg csum vlan jf tso tsoIPv6 lro%s\n",
-		dma64 ? " highDMA" : "");
 }
 
 
@@ -2717,7 +2713,7 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 			adapter->intr.num_intrs = vectors;
 			return 0;
 		} else if (err < 0) {
-			netdev_err(adapter->netdev,
+			dev_err(&adapter->netdev->dev,
 				   "Failed to enable MSI-X, error: %d\n", err);
 			vectors = 0;
 		} else if (err < vector_threshold) {
@@ -2726,15 +2722,16 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 			/* If fails to enable required number of MSI-x vectors
 			 * try enabling minimum number of vectors required.
 			 */
-			netdev_err(adapter->netdev,
-				   "Failed to enable %d MSI-X, trying %d instead\n",
+			dev_err(&adapter->netdev->dev,
+				"Failed to enable %d MSI-X, trying %d instead\n",
 				    vectors, vector_threshold);
 			vectors = vector_threshold;
 		}
 	}
 
-	netdev_info(adapter->netdev,
-		    "Number of MSI-X interrupts which can be allocated are lower than min threshold required.\n");
+	dev_info(&adapter->pdev->dev,
+		 "Number of MSI-X interrupts which can be allocated "
+		 "is lower than min threshold required.\n");
 	return err;
 }
 
@@ -2800,9 +2797,9 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 			return;
 
 		/* If we cannot allocate MSIx vectors use only one rx queue */
-		netdev_info(adapter->netdev,
-			    "Failed to enable MSI-X, error %d . Limiting #rx queues to 1, try MSI.\n",
-			    err);
+		dev_info(&adapter->pdev->dev,
+			 "Failed to enable MSI-X, error %d. "
+			 "Limiting #rx queues to 1, try MSI.\n", err);
 
 		adapter->intr.type = VMXNET3_IT_MSI;
 	}
-- 
1.7.10.4
