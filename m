From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] igb: improve handling of disconnected adapters
Date: Sun, 13 Dec 2015 00:31:29 -0800
Message-ID: <1449995490-17020-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28018 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbbLMIbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:31:38 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>

Clean up array_rd32 so that it uses igb_rd32 the same as rd32, per the
suggestion of Alexander Duyck, and use io_addr in more places, so that
we don't have the need to call E1000_REMOVED (which simply looks for a
null hw_addr) nearly as much.

Signed-off-by: Jarod Wilson <jarod@redhat.com>
Acked-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h | 3 +--
 drivers/net/ethernet/intel/igb/igb_main.c   | 5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 0fdcd4d..21d9d02 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -386,8 +386,7 @@ do { \
 #define array_wr32(reg, offset, value) \
 	wr32((reg) + ((offset) << 2), (value))
 
-#define array_rd32(reg, offset) \
-	(readl(hw->hw_addr + reg + ((offset) << 2)))
+#define array_rd32(reg, offset) (igb_rd32(hw, reg + ((offset) << 2)))
 
 /* DMA Coalescing registers */
 #define E1000_PCIEMISC	0x05BB8 /* PCIE misc config register */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fa3b4cb..7afde45 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -946,7 +946,6 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 static int igb_request_msix(struct igb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	struct e1000_hw *hw = &adapter->hw;
 	int i, err = 0, vector = 0, free_vector = 0;
 
 	err = request_irq(adapter->msix_entries[vector].vector,
@@ -959,7 +958,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 
 		vector++;
 
-		q_vector->itr_register = hw->hw_addr + E1000_EITR(vector);
+		q_vector->itr_register = adapter->io_addr + E1000_EITR(vector);
 
 		if (q_vector->rx.ring && q_vector->tx.ring)
 			sprintf(q_vector->name, "%s-TxRx-%u", netdev->name,
@@ -1230,7 +1229,7 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	q_vector->tx.work_limit = adapter->tx_work_limit;
 
 	/* initialize ITR configuration */
-	q_vector->itr_register = adapter->hw.hw_addr + E1000_EITR(0);
+	q_vector->itr_register = adapter->io_addr + E1000_EITR(0);
 	q_vector->itr_val = IGB_START_ITR;
 
 	/* initialize pointer to rings */
-- 
2.5.0
