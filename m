From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH v2] igb: improve handling of disconnected adapters
Date: Mon, 19 Oct 2015 11:52:04 -0400
Message-ID: <1445269924-26739-1-git-send-email-jarod@redhat.com>
References: <1444716624.2870.14.camel@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Mark Rustad <mark.d.rustad@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444716624.2870.14.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean up array_rd32 so that it uses igb_rd32 the same as rd32, per the
suggestion of Alexander Duyck, and use io_addr in more places, so that
we don't have the need to call E1000_REMOVED (which simply looks for a
null hw_addr) nearly as much.

CC: Mark Rustad <mark.d.rustad@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Alexander Duyck <alexander.duyck@gmail.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Acked-by: Alexander Duyck <aduyck@mirantis.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
Note: this patch is rebased on Jeff's next-queue/dev-queue branch, which
already had an earlier revision of this applied, so I've essentially
reverted a2675ab and applied the revised version of this, squashed them
together, and here is the end result, which matches the version Alex acked.

 drivers/net/ethernet/intel/igb/e1000_regs.h |  3 +--
 drivers/net/ethernet/intel/igb/igb_main.c   | 15 ++-------------
 2 files changed, 3 insertions(+), 15 deletions(-)

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
index 044a23e..68006a5 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -954,17 +954,12 @@ static int igb_request_msix(struct igb_adapter *adapter)
 	if (err)
 		goto err_out;
 
-	if (E1000_REMOVED(hw->hw_addr)) {
-		err = -EIO;
-		goto err_free;
-	}
-
 	for (i = 0; i < adapter->num_q_vectors; i++) {
 		struct igb_q_vector *q_vector = adapter->q_vector[i];
 
 		vector++;
 
-		q_vector->itr_register = hw->hw_addr + E1000_EITR(vector);
+		q_vector->itr_register = adapter->io_addr + E1000_EITR(vector);
 
 		if (q_vector->rx.ring && q_vector->tx.ring)
 			sprintf(q_vector->name, "%s-TxRx-%u", netdev->name,
@@ -1206,9 +1201,6 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	if (txr_count > 1 || rxr_count > 1)
 		return -ENOMEM;
 
-	if (E1000_REMOVED(adapter->hw.hw_addr))
-		return -EIO;
-
 	ring_count = txr_count + rxr_count;
 	size = sizeof(struct igb_q_vector) +
 	       (sizeof(struct igb_ring) * ring_count);
@@ -1238,7 +1230,7 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	q_vector->tx.work_limit = adapter->tx_work_limit;
 
 	/* initialize ITR configuration */
-	q_vector->itr_register = adapter->hw.hw_addr + E1000_EITR(0);
+	q_vector->itr_register = adapter->io_addr + E1000_EITR(0);
 	q_vector->itr_val = IGB_START_ITR;
 
 	/* initialize pointer to rings */
@@ -3281,9 +3273,6 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	u64 tdba = ring->dma;
 	int reg_idx = ring->reg_idx;
 
-	if (E1000_REMOVED(adapter->io_addr))
-		return;
-
 	/* disable the queue */
 	wr32(E1000_TXDCTL(reg_idx), 0);
 	wrfl();
-- 
1.8.3.1
