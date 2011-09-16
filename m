From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] ixgbe: cleanup configuration of EITRSEL and VF reset path
Date: Thu, 15 Sep 2011 21:42:52 -0700
Message-ID: <1316148173-11209-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15976 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047Ab1IPEnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:43:00 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to cleanup some of the code related to SR-IOV and the
interrupt registers.  Specifically I am moving the EITRSEL configuration
into the MSI-X configuration section instead of enablement.  Also I am
fixing the VF shutdown path since it had operations in the incorrect order.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6378d7f..0ee7d09 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1516,6 +1516,12 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
+	/* Populate MSIX to EITR Select */
+	if (adapter->num_vfs > 32) {
+		u32 eitrsel = (1 << (adapter->num_vfs - 32)) - 1;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, eitrsel);
+	}
+
 	/*
 	 * Populate the IVAR table and set the ITR values to the
 	 * corresponding register.
@@ -2130,11 +2136,6 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 		ixgbe_irq_enable_queues(adapter, ~0);
 	if (flush)
 		IXGBE_WRITE_FLUSH(&adapter->hw);
-
-	if (adapter->num_vfs > 32) {
-		u32 eitrsel = (1 << (adapter->num_vfs - 32)) - 1;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, eitrsel);
-	}
 }
 
 /**
@@ -2313,8 +2314,6 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFF0000);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), ~0);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), ~0);
-		if (adapter->num_vfs > 32)
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, 0);
 		break;
 	default:
 		break;
@@ -3863,17 +3862,19 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	del_timer_sync(&adapter->service_timer);
 
-	/* disable receive for all VFs and wait one second */
 	if (adapter->num_vfs) {
+		/* Clear EITR Select mapping */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITRSEL, 0);
+
+		/* Mark all the VFs as inactive */
+		for (i = 0 ; i < adapter->num_vfs; i++)
+			adapter->vfinfo[i].clear_to_send = 0;
+
 		/* ping all the active vfs to let them know we are going down */
 		ixgbe_ping_all_vfs(adapter);
 
 		/* Disable all VFTE/VFRE TX/RX */
 		ixgbe_disable_tx_rx(adapter);
-
-		/* Mark all the VFs as inactive */
-		for (i = 0 ; i < adapter->num_vfs; i++)
-			adapter->vfinfo[i].clear_to_send = 0;
 	}
 
 	/* disable transmits in the hardware now that interrupts are off */
-- 
1.7.6
