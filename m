From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 4/9] liquidio:RX queue alloc changes
Date: Tue, 14 Jun 2016 16:54:46 -0700
Message-ID: <1465948491-10541-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0084.outbound.protection.outlook.com ([65.55.169.84]:34976
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751332AbcFOAKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:10:09 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to allocate rx queue's memory based on numa node and also use
page based buffers for rx traffic improvements.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 27 ++++++++---------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 35 ++++++++++++++++------
 drivers/net/ethernet/cavium/liquidio/octeon_main.h | 23 ++++++++------
 3 files changed, 52 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 967fe4d..c06807d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -783,14 +783,15 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 
 int octeon_setup_output_queues(struct octeon_device *oct)
 {
-	u32 i, num_oqs = 0;
+	u32 num_oqs = 0;
 	u32 num_descs = 0;
 	u32 desc_size = 0;
+	u32 oq_no = 0;
+	int numa_node = cpu_to_node(oq_no % num_online_cpus());
 
+	num_oqs = 1;
 	/* this causes queue 0 to be default queue */
 	if (OCTEON_CN6XXX(oct)) {
-		/* CFG_GET_OQ_MAX_BASE_Q(CHIP_FIELD(oct, cn6xxx, conf)); */
-		num_oqs = 1;
 		num_descs =
 			CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
 		desc_size =
@@ -798,19 +799,15 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	}
 
 	oct->num_oqs = 0;
+	oct->droq[0] = vmalloc_node(sizeof(*oct->droq[0]), numa_node);
+	if (!oct->droq[0])
+		oct->droq[0] = vmalloc(sizeof(*oct->droq[0]));
+	if (!oct->droq[0])
+		return 1;
 
-	for (i = 0; i < num_oqs; i++) {
-		oct->droq[i] = vmalloc(sizeof(*oct->droq[i]));
-		if (!oct->droq[i])
-			return 1;
-
-		memset(oct->droq[i], 0, sizeof(struct octeon_droq));
-
-		if (octeon_init_droq(oct, i, num_descs, desc_size, NULL))
-			return 1;
-
-		oct->num_oqs++;
-	}
+	if (octeon_init_droq(oct, oq_no, num_descs, desc_size, NULL))
+		return 1;
+	oct->num_oqs++;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 174072b..1f648dc 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -242,6 +242,8 @@ int octeon_init_droq(struct octeon_device *oct,
 	struct octeon_droq *droq;
 	u32 desc_ring_size = 0, c_num_descs = 0, c_buf_size = 0;
 	u32 c_pkts_per_intr = 0, c_refill_threshold = 0;
+	int orig_node = dev_to_node(&oct->pci_dev->dev);
+	int numa_node = cpu_to_node(q_no % num_online_cpus());
 
 	dev_dbg(&oct->pci_dev->dev, "%s[%d]\n", __func__, q_no);
 
@@ -261,15 +263,23 @@ int octeon_init_droq(struct octeon_device *oct,
 		struct octeon_config *conf6x = CHIP_FIELD(oct, cn6xxx, conf);
 
 		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf6x);
-		c_refill_threshold = (u32)CFG_GET_OQ_REFILL_THRESHOLD(conf6x);
+		c_refill_threshold =
+			(u32)CFG_GET_OQ_REFILL_THRESHOLD(conf6x);
+	} else {
+		return 1;
 	}
 
 	droq->max_count = c_num_descs;
 	droq->buffer_size = c_buf_size;
 
 	desc_ring_size = droq->max_count * OCT_DROQ_DESC_SIZE;
+	set_dev_node(&oct->pci_dev->dev, numa_node);
 	droq->desc_ring = lio_dma_alloc(oct, desc_ring_size,
 					(dma_addr_t *)&droq->desc_ring_dma);
+	set_dev_node(&oct->pci_dev->dev, orig_node);
+	if (!droq->desc_ring)
+		droq->desc_ring = lio_dma_alloc(oct, desc_ring_size,
+					(dma_addr_t *)&droq->desc_ring_dma);
 
 	if (!droq->desc_ring) {
 		dev_err(&oct->pci_dev->dev,
@@ -283,12 +293,11 @@ int octeon_init_droq(struct octeon_device *oct,
 		droq->max_count);
 
 	droq->info_list =
-		cnnic_alloc_aligned_dma(oct->pci_dev,
-					(droq->max_count * OCT_DROQ_INFO_SIZE),
-					&droq->info_alloc_size,
-					&droq->info_base_addr,
-					&droq->info_list_dma);
-
+		cnnic_numa_alloc_aligned_dma((droq->max_count *
+					      OCT_DROQ_INFO_SIZE),
+					     &droq->info_alloc_size,
+					     &droq->info_base_addr,
+					     numa_node);
 	if (!droq->info_list) {
 		dev_err(&oct->pci_dev->dev, "Cannot allocate memory for info list.\n");
 		lio_dma_free(oct, (droq->max_count * OCT_DROQ_DESC_SIZE),
@@ -297,7 +306,12 @@ int octeon_init_droq(struct octeon_device *oct,
 	}
 
 	droq->recv_buf_list = (struct octeon_recv_buffer *)
-			      vmalloc(droq->max_count *
+			      vmalloc_node(droq->max_count *
+						OCT_DROQ_RECVBUF_SIZE,
+						numa_node);
+	if (!droq->recv_buf_list)
+		droq->recv_buf_list = (struct octeon_recv_buffer *)
+				      vmalloc(droq->max_count *
 						OCT_DROQ_RECVBUF_SIZE);
 	if (!droq->recv_buf_list) {
 		dev_err(&oct->pci_dev->dev, "Output queue recv buf list alloc failed\n");
@@ -949,6 +963,7 @@ int octeon_create_droq(struct octeon_device *oct,
 		       u32 desc_size, void *app_ctx)
 {
 	struct octeon_droq *droq;
+	int numa_node = cpu_to_node(q_no % num_online_cpus());
 
 	if (oct->droq[q_no]) {
 		dev_dbg(&oct->pci_dev->dev, "Droq already in use. Cannot create droq %d again\n",
@@ -957,7 +972,9 @@ int octeon_create_droq(struct octeon_device *oct,
 	}
 
 	/* Allocate the DS for the new droq. */
-	droq = vmalloc(sizeof(*droq));
+	droq = vmalloc_node(sizeof(*droq), numa_node);
+	if (!droq)
+		droq = vmalloc(sizeof(*droq));
 	if (!droq)
 		goto create_droq_fail;
 	memset(droq, 0, sizeof(struct octeon_droq));
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index cbd0819..0ff3efc 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -126,22 +126,27 @@ static inline int octeon_map_pci_barx(struct octeon_device *oct,
 }
 
 static inline void *
-cnnic_alloc_aligned_dma(struct pci_dev *pci_dev,
-			u32 size,
-			u32 *alloc_size,
-			size_t *orig_ptr,
-			size_t *dma_addr __attribute__((unused)))
+cnnic_numa_alloc_aligned_dma(u32 size,
+			     u32 *alloc_size,
+			     size_t *orig_ptr,
+			     int numa_node)
 {
 	int retries = 0;
 	void *ptr = NULL;
 
 #define OCTEON_MAX_ALLOC_RETRIES     1
 	do {
-		ptr =
-		    (void *)__get_free_pages(GFP_KERNEL,
-					     get_order(size));
+		struct page *page = NULL;
+
+		page = alloc_pages_node(numa_node,
+					GFP_KERNEL,
+					get_order(size));
+		if (!page)
+			page = alloc_pages(GFP_KERNEL,
+					   get_order(size));
+		ptr = (void *)page_address(page);
 		if ((unsigned long)ptr & 0x07) {
-			free_pages((unsigned long)ptr, get_order(size));
+			__free_pages(page, get_order(size));
 			ptr = NULL;
 			/* Increment the size required if the first
 			 * attempt failed.
-- 
1.8.3.1
