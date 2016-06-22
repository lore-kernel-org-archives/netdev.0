From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 01/13] liquidio: soft command buffer limits
Date: Tue, 21 Jun 2016 22:53:03 -0700
Message-ID: <1466574795-4306-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0091.outbound.protection.outlook.com ([65.55.169.91]:52906
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbcFVGLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 02:11:23 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the limits of soft command buffer size and
num command buffers. This patch also has changes for queue macros
and limit related changes for new chips.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   | 36 ++++++++++++----------
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 16 +++++-----
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 25 +++++++--------
 .../net/ethernet/cavium/liquidio/octeon_config.h   | 12 +++++---
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 18 +++++------
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 13 ++++----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  4 +--
 .../net/ethernet/cavium/liquidio/request_manager.c |  6 ++--
 9 files changed, 69 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index 8ad7425..c577559 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -367,7 +367,8 @@ void lio_cn6xxx_enable_io_queues(struct octeon_device *oct)
 
 void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 {
-	u32 mask, i, loop = HZ;
+	int i;
+	u32 mask, loop = HZ;
 	u32 d32;
 
 	/* Reset the Enable bits for Input Queues. */
@@ -376,7 +377,7 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_INSTR_ENB, mask);
 
 	/* Wait until hardware indicates that the queues are out of reset. */
-	mask = oct->io_qmask.iq;
+	mask = (u32)oct->io_qmask.iq;
 	d32 = octeon_read_csr(oct, CN6XXX_SLI_PORT_IN_RST_IQ);
 	while (((d32 & mask) != mask) && loop--) {
 		d32 = octeon_read_csr(oct, CN6XXX_SLI_PORT_IN_RST_IQ);
@@ -384,8 +385,8 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 	}
 
 	/* Reset the doorbell register for each Input queue. */
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-		if (!(oct->io_qmask.iq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.iq & (1ULL << i)))
 			continue;
 		octeon_write_csr(oct, CN6XXX_SLI_IQ_DOORBELL(i), 0xFFFFFFFF);
 		d32 = octeon_read_csr(oct, CN6XXX_SLI_IQ_DOORBELL(i));
@@ -398,7 +399,7 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 
 	/* Wait until hardware indicates that the queues are out of reset. */
 	loop = HZ;
-	mask = oct->io_qmask.oq;
+	mask = (u32)oct->io_qmask.oq;
 	d32 = octeon_read_csr(oct, CN6XXX_SLI_PORT_IN_RST_OQ);
 	while (((d32 & mask) != mask) && loop--) {
 		d32 = octeon_read_csr(oct, CN6XXX_SLI_PORT_IN_RST_OQ);
@@ -408,8 +409,8 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 
 	/* Reset the doorbell register for each Output queue. */
 	/* for (i = 0; i < oct->num_oqs; i++) { */
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		if (!(oct->io_qmask.oq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.oq & (1ULL << i)))
 			continue;
 		octeon_write_csr(oct, CN6XXX_SLI_OQ_PKTS_CREDIT(i), 0xFFFFFFFF);
 		d32 = octeon_read_csr(oct, CN6XXX_SLI_OQ_PKTS_CREDIT(i));
@@ -429,16 +430,16 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 
 void lio_cn6xxx_reinit_regs(struct octeon_device *oct)
 {
-	u32 i;
+	int i;
 
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-		if (!(oct->io_qmask.iq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.iq & (1ULL << i)))
 			continue;
 		oct->fn_list.setup_iq_regs(oct, i);
 	}
 
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		if (!(oct->io_qmask.oq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.oq & (1ULL << i)))
 			continue;
 		oct->fn_list.setup_oq_regs(oct, i);
 	}
@@ -450,8 +451,8 @@ void lio_cn6xxx_reinit_regs(struct octeon_device *oct)
 	oct->fn_list.enable_io_queues(oct);
 
 	/* for (i = 0; i < oct->num_oqs; i++) { */
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		if (!(oct->io_qmask.oq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.oq & (1ULL << i)))
 			continue;
 		writel(oct->droq[i]->max_count, oct->droq[i]->pkts_credit_reg);
 	}
@@ -557,7 +558,8 @@ lio_cn6xxx_process_pcie_error_intr(struct octeon_device *oct, u64 intr64)
 int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 {
 	struct octeon_droq *droq;
-	u32 oq_no, pkt_count, droq_time_mask, droq_mask, droq_int_enb;
+	int oq_no;
+	u32 pkt_count, droq_time_mask, droq_mask, droq_int_enb;
 	u32 droq_cnt_enb, droq_cnt_mask;
 
 	droq_cnt_enb = octeon_read_csr(oct, CN6XXX_SLI_PKT_CNT_INT_ENB);
@@ -573,8 +575,8 @@ int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 	oct->droq_intr = 0;
 
 	/* for (oq_no = 0; oq_no < oct->num_oqs; oq_no++) { */
-	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
-		if (!(droq_mask & (1 << oq_no)))
+	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct); oq_no++) {
+		if (!(droq_mask & (1ULL << oq_no)))
 			continue;
 
 		droq = oct->droq[oq_no];
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 4523c86..56f465b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -528,8 +528,8 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	struct octeon_device *oct_dev = lio->oct_dev;
 	int i = 0, j;
 
-	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES; j++) {
-		if (!(oct_dev->io_qmask.iq & (1UL << j)))
+	for (j = 0; j < MAX_OCTEON_INSTR_QUEUES(oct); j++) {
+		if (!(oct_dev->io_qmask.iq & (1ULL << j)))
 			continue;
 		data[i++] =
 			CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_posted);
@@ -556,8 +556,8 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	}
 
 	/* for (j = 0; j < oct_dev->num_oqs; j++){ */
-	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES; j++) {
-		if (!(oct_dev->io_qmask.oq & (1UL << j)))
+	for (j = 0; j < MAX_OCTEON_OUTPUT_QUEUES(oct); j++) {
+		if (!(oct_dev->io_qmask.oq & (1ULL << j)))
 			continue;
 		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.pkts_received);
 		data[i++] = CVM_CAST64(oct_dev->droq[j]->stats.bytes_received);
@@ -581,8 +581,8 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	int num_iq_stats, num_oq_stats, i, j;
 
 	num_iq_stats = ARRAY_SIZE(oct_iq_stats_strings);
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-		if (!(oct_dev->io_qmask.iq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+		if (!(oct_dev->io_qmask.iq & (1ULL << i)))
 			continue;
 		for (j = 0; j < num_iq_stats; j++) {
 			sprintf(data, "IQ%d %s", i, oct_iq_stats_strings[j]);
@@ -592,8 +592,8 @@ static void lio_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 
 	num_oq_stats = ARRAY_SIZE(oct_droq_stats_strings);
 	/* for (i = 0; i < oct_dev->num_oqs; i++) { */
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		if (!(oct_dev->io_qmask.oq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if (!(oct_dev->io_qmask.oq & (1ULL << i)))
 			continue;
 		for (j = 0; j < num_oq_stats; j++) {
 			sprintf(data, "OQ%d %s", i, oct_droq_stats_strings[j]);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index d0ab97c..5a0977f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -224,8 +224,8 @@ static void octeon_droq_bh(unsigned long pdev)
 		(struct octeon_device_priv *)oct->priv;
 
 	/* for (q_no = 0; q_no < oct->num_oqs; q_no++) { */
-	for (q_no = 0; q_no < MAX_OCTEON_OUTPUT_QUEUES; q_no++) {
-		if (!(oct->io_qmask.oq & (1UL << q_no)))
+	for (q_no = 0; q_no < MAX_OCTEON_OUTPUT_QUEUES(oct); q_no++) {
+		if (!(oct->io_qmask.oq & (1ULL << q_no)))
 			continue;
 		reschedule |= octeon_droq_process_packets(oct, oct->droq[q_no],
 							  MAX_PACKET_BUDGET);
@@ -245,8 +245,8 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 	do {
 		pending_pkts = 0;
 
-		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-			if (!(oct->io_qmask.oq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.oq & (1ULL << i)))
 				continue;
 			pkt_cnt += octeon_droq_check_hw_for_pkts(oct,
 								 oct->droq[i]);
@@ -396,10 +396,10 @@ static inline void pcierror_quiesce_device(struct octeon_device *oct)
 		dev_err(&oct->pci_dev->dev, "There were pending requests\n");
 
 	/* Force all requests waiting to be fetched by OCTEON to complete. */
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
 		struct octeon_instr_queue *iq;
 
-		if (!(oct->io_qmask.iq & (1UL << i)))
+		if (!(oct->io_qmask.iq & (1ULL << i)))
 			continue;
 		iq = oct->instr_queue[i];
 
@@ -972,8 +972,9 @@ void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 	struct octeon_droq *droq;
 
 	if (oct->int_status & OCT_DEV_INTR_PKT_DATA) {
-		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
-			if (!(oct->droq_intr & (1 << oq_no)))
+		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct);
+		     oq_no++) {
+			if (!(oct->droq_intr & (1ULL << oq_no)))
 				continue;
 
 			droq = oct->droq[oq_no];
@@ -1160,8 +1161,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 	case OCT_DEV_DROQ_INIT_DONE:
 		/*atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);*/
 		mdelay(100);
-		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-			if (!(oct->io_qmask.oq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.oq & (1ULL << i)))
 				continue;
 			octeon_delete_droq(oct, i);
 		}
@@ -1188,8 +1189,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* fallthrough */
 	case OCT_DEV_INSTR_QUEUE_INIT_DONE:
-		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-			if (!(oct->io_qmask.iq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.iq & (1ULL << i)))
 				continue;
 			octeon_delete_instr_queue(oct, i);
 		}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 62a8dd5..4b8c948 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -37,7 +37,7 @@
 /* Maximum octeon devices defined as MAX_OCTEON_NICIF to support
  * multiple(<= MAX_OCTEON_NICIF) Miniports
  */
-#define   MAX_OCTEON_NICIF             32
+#define   MAX_OCTEON_NICIF             128
 #define   MAX_OCTEON_DEVICES           MAX_OCTEON_NICIF
 #define   MAX_OCTEON_LINKS	       MAX_OCTEON_NICIF
 #define   MAX_OCTEON_MULTICAST_ADDR    32
@@ -135,7 +135,7 @@
 #define CFG_GET_IS_SLI_BP_ON(cfg)                ((cfg)->misc.enable_sli_oq_bp)
 
 /* Max IOQs per OCTEON Link */
-#define MAX_IOQS_PER_NICIF              32
+#define MAX_IOQS_PER_NICIF              64
 
 enum lio_card_type {
 	LIO_210SV = 0, /* Two port, 66xx */
@@ -416,9 +416,11 @@ struct octeon_config {
 #define DISPATCH_LIST_SIZE                      BIT(OPCODE_MASK_BITS)
 
 /* Maximum number of Octeon Instruction (command) queues */
-#define MAX_OCTEON_INSTR_QUEUES         CN6XXX_MAX_INPUT_QUEUES
+#define MAX_OCTEON_INSTR_QUEUES(oct)         CN6XXX_MAX_INPUT_QUEUES
+/* Maximum number of Octeon Output queues */
+#define MAX_OCTEON_OUTPUT_QUEUES(oct)         CN6XXX_MAX_OUTPUT_QUEUES
 
-/* Maximum number of Octeon Instruction (command) queues */
-#define MAX_OCTEON_OUTPUT_QUEUES        CN6XXX_MAX_OUTPUT_QUEUES
+#define MAX_POSSIBLE_OCTEON_INSTR_QUEUES       CN6XXX_MAX_INPUT_QUEUES
+#define MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES      CN6XXX_MAX_OUTPUT_QUEUES
 
 #endif /* __OCTEON_CONFIG_H__  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 7b44b5c..e1ca617 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -645,12 +645,12 @@ void octeon_free_device_mem(struct octeon_device *oct)
 {
 	u32 i;
 
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
 		/* could check  mask as well */
 		vfree(oct->droq[i]);
 	}
 
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
 		/* could check mask as well */
 		vfree(oct->instr_queue[i]);
 	}
@@ -734,7 +734,7 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 	octeon_device[oct_idx] = oct;
 
 	oct->octeon_id = oct_idx;
-	snprintf((oct->device_name), sizeof(oct->device_name),
+	snprintf(oct->device_name, sizeof(oct->device_name),
 		 "LiquidIO%d", (oct->octeon_id));
 
 	return oct;
@@ -1157,8 +1157,8 @@ core_drv_init_err:
 int octeon_get_tx_qsize(struct octeon_device *oct, u32 q_no)
 
 {
-	if (oct && (q_no < MAX_OCTEON_INSTR_QUEUES) &&
-	    (oct->io_qmask.iq & (1UL << q_no)))
+	if (oct && (q_no < MAX_OCTEON_INSTR_QUEUES(oct)) &&
+	    (oct->io_qmask.iq & (1ULL << q_no)))
 		return oct->instr_queue[q_no]->max_count;
 
 	return -1;
@@ -1166,8 +1166,8 @@ int octeon_get_tx_qsize(struct octeon_device *oct, u32 q_no)
 
 int octeon_get_rx_qsize(struct octeon_device *oct, u32 q_no)
 {
-	if (oct && (q_no < MAX_OCTEON_OUTPUT_QUEUES) &&
-	    (oct->io_qmask.oq & (1UL << q_no)))
+	if (oct && (q_no < MAX_OCTEON_OUTPUT_QUEUES(oct)) &&
+	    (oct->io_qmask.oq & (1ULL << q_no)))
 		return oct->droq[q_no]->max_count;
 	return -1;
 }
@@ -1258,10 +1258,10 @@ void lio_pci_writeq(struct octeon_device *oct,
 int octeon_mem_access_ok(struct octeon_device *oct)
 {
 	u64 access_okay = 0;
+	u64 lmc0_reset_ctl;
 
 	/* Check to make sure a DDR interface is enabled */
-	u64 lmc0_reset_ctl = lio_pci_readq(oct, CN6XXX_LMC0_RESET_CTL);
-
+	lmc0_reset_ctl = lio_pci_readq(oct, CN6XXX_LMC0_RESET_CTL);
 	access_okay = (lmc0_reset_ctl & CN6XXX_LMC0_RESET_CTL_DDR3RST_MASK);
 
 	return access_okay ? 0 : 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 0950b94..dd88df7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -152,9 +152,9 @@ struct octeon_mmio {
 #define   MAX_OCTEON_MAPS    32
 
 struct octeon_io_enable {
-	u32 iq;
-	u32 oq;
-	u32 iq64B;
+	u64 iq;
+	u64 oq;
+	u64 iq64B;
 };
 
 struct octeon_reg_list {
@@ -325,7 +325,8 @@ struct octeon_device {
 	struct octeon_sc_buffer_pool	sc_buf_pool;
 
 	/** The input instruction queues */
-	struct octeon_instr_queue *instr_queue[MAX_OCTEON_INSTR_QUEUES];
+	struct octeon_instr_queue *instr_queue
+		[MAX_POSSIBLE_OCTEON_INSTR_QUEUES];
 
 	/** The doubly-linked list of instruction response */
 	struct octeon_response_list response_list[MAX_RESPONSE_LISTS];
@@ -333,7 +334,7 @@ struct octeon_device {
 	u32 num_oqs;
 
 	/** The DROQ output queues  */
-	struct octeon_droq *droq[MAX_OCTEON_OUTPUT_QUEUES];
+	struct octeon_droq *droq[MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES];
 
 	struct octeon_io_enable io_qmask;
 
@@ -382,7 +383,7 @@ struct octeon_device {
 
 	struct cavium_wq dma_comp_wq;
 
-	struct cavium_wq check_db_wq[MAX_OCTEON_INSTR_QUEUES];
+	struct cavium_wq check_db_wq[MAX_POSSIBLE_OCTEON_INSTR_QUEUES];
 
 	struct cavium_wk nic_poll_work;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 59a5293..d9bb2f7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -337,7 +337,7 @@ int octeon_init_droq(struct octeon_device *oct,
 	/* For 56xx Pass1, this function won't be called, so no checks. */
 	oct->fn_list.setup_oq_regs(oct, q_no);
 
-	oct->io_qmask.oq |= (1 << q_no);
+	oct->io_qmask.oq |= (1ULL << q_no);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 513f8a0..7c275ef 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -244,7 +244,7 @@ union octeon_instr_64B {
 
 /** The size of each buffer in soft command buffer pool
  */
-#define  SOFT_COMMAND_BUFFER_SIZE	1024
+#define  SOFT_COMMAND_BUFFER_SIZE	1536
 
 struct octeon_soft_command {
 	/** Soft command buffer info. */
@@ -282,7 +282,7 @@ struct octeon_soft_command {
 
 /** Maximum number of buffers to allocate into soft command buffer pool
  */
-#define  MAX_SOFT_COMMAND_BUFFERS	16
+#define  MAX_SOFT_COMMAND_BUFFERS	256
 
 /** Head of a soft command buffer pool.
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 8649677..51031010 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -150,7 +150,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	/* Initialize the spinlock for this instruction queue */
 	spin_lock_init(&iq->lock);
 
-	oct->io_qmask.iq |= (1 << iq_no);
+	oct->io_qmask.iq |= (1ULL << iq_no);
 
 	/* Set the 32B/64B mode for each input queue */
 	oct->io_qmask.iq64B |= ((conf->instr_type == 64) << iq_no);
@@ -253,8 +253,8 @@ int lio_wait_for_instr_fetch(struct octeon_device *oct)
 		instr_cnt = 0;
 
 		/*for (i = 0; i < oct->num_iqs; i++) {*/
-		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-			if (!(oct->io_qmask.iq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.iq & (1ULL << i)))
 				continue;
 			pending =
 			    atomic_read(&oct->
-- 
1.8.3.1
