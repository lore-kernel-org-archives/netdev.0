From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: optimize DMA in NUMA systems
Date: Thu, 9 Mar 2017 17:03:24 -0800
Message-ID: <20170310010324.GA5986@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0047.outbound.protection.outlook.com ([104.47.37.47]:56384
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751313AbdCJBGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 20:06:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: VSR Burru <veerasenareddy.burru@cavium.com>

Optimize DMA in NUMA systems by allocating memory from NUMA node that NIC
is plugged in to; DMA will no longer cross NUMA nodes.  If NIC IRQs are
pinned to a local CPU, that CPU's access to the DMA'd data is also
optimized.

Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c        |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_device.c   |  4 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     | 10 ++--------
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h       |  2 +-
 drivers/net/ethernet/cavium/liquidio/request_manager.c | 13 +++----------
 5 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..682d5cf 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -782,7 +782,7 @@ static int setup_glists(struct octeon_device *oct, struct lio *lio, int num_iqs)
 	}
 
 	for (i = 0; i < num_iqs; i++) {
-		int numa_node = cpu_to_node(i % num_online_cpus());
+		int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 		spin_lock_init(&lio->glist_lock[i]);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 9675ffb..e21b477 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -793,7 +793,7 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 	u32 num_descs = 0;
 	u32 iq_no = 0;
 	union oct_txpciq txpciq;
-	int numa_node = cpu_to_node(iq_no % num_online_cpus());
+	int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 	if (OCTEON_CN6XXX(oct))
 		num_descs =
@@ -837,7 +837,7 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	u32 num_descs = 0;
 	u32 desc_size = 0;
 	u32 oq_no = 0;
-	int numa_node = cpu_to_node(oq_no % num_online_cpus());
+	int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 	if (OCTEON_CN6XXX(oct)) {
 		num_descs =
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 0be87d1..a91835d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -234,8 +234,7 @@ int octeon_init_droq(struct octeon_device *oct,
 	struct octeon_droq *droq;
 	u32 desc_ring_size = 0, c_num_descs = 0, c_buf_size = 0;
 	u32 c_pkts_per_intr = 0, c_refill_threshold = 0;
-	int orig_node = dev_to_node(&oct->pci_dev->dev);
-	int numa_node = cpu_to_node(q_no % num_online_cpus());
+	int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 	dev_dbg(&oct->pci_dev->dev, "%s[%d]\n", __func__, q_no);
 
@@ -275,13 +274,8 @@ int octeon_init_droq(struct octeon_device *oct,
 	droq->buffer_size = c_buf_size;
 
 	desc_ring_size = droq->max_count * OCT_DROQ_DESC_SIZE;
-	set_dev_node(&oct->pci_dev->dev, numa_node);
 	droq->desc_ring = lio_dma_alloc(oct, desc_ring_size,
 					(dma_addr_t *)&droq->desc_ring_dma);
-	set_dev_node(&oct->pci_dev->dev, orig_node);
-	if (!droq->desc_ring)
-		droq->desc_ring = lio_dma_alloc(oct, desc_ring_size,
-					(dma_addr_t *)&droq->desc_ring_dma);
 
 	if (!droq->desc_ring) {
 		dev_err(&oct->pci_dev->dev,
@@ -983,7 +977,7 @@ int octeon_create_droq(struct octeon_device *oct,
 		       u32 desc_size, void *app_ctx)
 {
 	struct octeon_droq *droq;
-	int numa_node = cpu_to_node(q_no % num_online_cpus());
+	int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 	if (oct->droq[q_no]) {
 		dev_dbg(&oct->pci_dev->dev, "Droq already in use. Cannot create droq %d again\n",
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 4608a5a..5063a12 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -152,7 +152,7 @@ struct octeon_instr_queue {
 	struct oct_iq_stats stats;
 
 	/** DMA mapped base address of the input descriptor ring. */
-	u64 base_addr_dma;
+	dma_addr_t base_addr_dma;
 
 	/** Application context */
 	void *app_ctx;
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 707bc15..261f448 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -62,8 +62,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	u32 iq_no = (u32)txpciq.s.q_no;
 	u32 q_size;
 	struct cavium_wq *db_wq;
-	int orig_node = dev_to_node(&oct->pci_dev->dev);
-	int numa_node = cpu_to_node(iq_no % num_online_cpus());
+	int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 	if (OCTEON_CN6XXX(oct))
 		conf = &(CFG_GET_IQ_CFG(CHIP_CONF(oct, cn6xxx)));
@@ -91,13 +90,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	iq->oct_dev = oct;
 
-	set_dev_node(&oct->pci_dev->dev, numa_node);
-	iq->base_addr = lio_dma_alloc(oct, q_size,
-				      (dma_addr_t *)&iq->base_addr_dma);
-	set_dev_node(&oct->pci_dev->dev, orig_node);
-	if (!iq->base_addr)
-		iq->base_addr = lio_dma_alloc(oct, q_size,
-					      (dma_addr_t *)&iq->base_addr_dma);
+	iq->base_addr = lio_dma_alloc(oct, q_size, &iq->base_addr_dma);
 	if (!iq->base_addr) {
 		dev_err(&oct->pci_dev->dev, "Cannot allocate memory for instr queue %d\n",
 			iq_no);
@@ -211,7 +204,7 @@ int octeon_setup_iq(struct octeon_device *oct,
 		    void *app_ctx)
 {
 	u32 iq_no = (u32)txpciq.s.q_no;
-	int numa_node = cpu_to_node(iq_no % num_online_cpus());
+	int numa_node = dev_to_node(&oct->pci_dev->dev);
 
 	if (oct->instr_queue[iq_no]) {
 		dev_dbg(&oct->pci_dev->dev, "IQ is in use. Cannot create the IQ: %d again\n",
