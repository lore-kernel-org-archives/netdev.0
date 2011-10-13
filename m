From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] igb: Make certain one vector is always assigned in igb_request_irq
Date: Thu, 13 Oct 2011 00:15:06 -0700
Message-ID: <1318490112-5092-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10144 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753258Ab1JMHPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 03:15:19 -0400
In-Reply-To: <1318490112-5092-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes certain that one interrupt is always initialized in
igb_request_irq.  In addition we drop the use of adapter->pdev and
instead just call pdev since we made a local copy of the pointer earlier in
the function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3905a49..efc367b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1262,7 +1262,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 			goto request_done;
 		/* fall back to MSI */
 		igb_clear_interrupt_scheme(adapter);
-		if (!pci_enable_msi(adapter->pdev))
+		if (!pci_enable_msi(pdev))
 			adapter->flags |= IGB_FLAG_HAS_MSI;
 		igb_free_all_tx_resources(adapter);
 		igb_free_all_rx_resources(adapter);
@@ -1284,12 +1284,12 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		}
 		igb_setup_all_tx_resources(adapter);
 		igb_setup_all_rx_resources(adapter);
-	} else {
-		igb_assign_vector(adapter->q_vector[0], 0);
 	}
 
+	igb_assign_vector(adapter->q_vector[0], 0);
+
 	if (adapter->flags & IGB_FLAG_HAS_MSI) {
-		err = request_irq(adapter->pdev->irq, igb_intr_msi, 0,
+		err = request_irq(pdev->irq, igb_intr_msi, 0,
 				  netdev->name, adapter);
 		if (!err)
 			goto request_done;
@@ -1299,11 +1299,11 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		adapter->flags &= ~IGB_FLAG_HAS_MSI;
 	}
 
-	err = request_irq(adapter->pdev->irq, igb_intr, IRQF_SHARED,
+	err = request_irq(pdev->irq, igb_intr, IRQF_SHARED,
 			  netdev->name, adapter);
 
 	if (err)
-		dev_err(&adapter->pdev->dev, "Error %d getting interrupt\n",
+		dev_err(&pdev->dev, "Error %d getting interrupt\n",
 			err);
 
 request_done:
-- 
1.7.6.4
