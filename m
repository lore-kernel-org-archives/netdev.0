From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] e1000e: i219 execute unit hang fix on every reset or power state transition
Date: Wed,  3 Jun 2015 04:27:49 -0700
Message-ID: <1433330876-2658-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24080 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754489AbbFCL2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:00 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

After testing various cases, the conclusion is that the fix MUST be
executed BEFORE any event that the HW is reset or transition to D3.
To fix that I moved the execution to the relevant places but per
Alexander Duyck's review, ensure now that the DMA is valid and was not
freed before manipulating the ring.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 76b1a90..14ee6a6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4043,6 +4043,8 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		}
 	}
 
+	if (hw->mac.type == e1000_pch_spt)
+		e1000_flush_desc_rings(adapter);
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
 
@@ -4215,10 +4217,6 @@ void e1000e_down(struct e1000_adapter *adapter, bool reset)
 	spin_unlock(&adapter->stats64_lock);
 
 	e1000e_flush_descriptors(adapter);
-	if (hw->mac.type == e1000_pch_spt)
-		e1000_flush_desc_rings(adapter);
-	e1000_clean_tx_ring(adapter->tx_ring);
-	e1000_clean_rx_ring(adapter->rx_ring);
 
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -4229,8 +4227,14 @@ void e1000e_down(struct e1000_adapter *adapter, bool reset)
 	    e1000_lv_jumbo_workaround_ich8lan(hw, false))
 		e_dbg("failed to disable jumbo frame workaround mode\n");
 
-	if (reset && !pci_channel_offline(adapter->pdev))
-		e1000e_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev)) {
+		if (reset)
+			e1000e_reset(adapter);
+		else if (hw->mac.type == e1000_pch_spt)
+			e1000_flush_desc_rings(adapter);
+	}
+	e1000_clean_tx_ring(adapter->tx_ring);
+	e1000_clean_rx_ring(adapter->rx_ring);
 }
 
 void e1000e_reinit_locked(struct e1000_adapter *adapter)
-- 
2.1.0
