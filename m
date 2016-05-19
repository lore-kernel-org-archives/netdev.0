From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 1/4] liquidio updates and features
Date: Thu, 19 May 2016 11:56:30 -0700
Message-ID: <1463684193-25264-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0071.outbound.protection.outlook.com ([65.55.169.71]:22976
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753711AbcESTRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 15:17:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following set of four patches adds support for new features and updates
for liquidio smart nic adapters. This first patch:

1) Adds support for queue mapping between host queues and pci DPI queues
assigned by firmware for tx/rx queue numbers

2) Optimizations for instruction queues (IQ) which will have its own
gather list(glist) and gather list lock for finer level of locking.

3) Allocate queue's memory based on numa node and also use page based
buffers for rx traffic improvements.

4) Updated interrupt moderation defaults for better throughput and
utilisation.

5) Provide gmxport port information per octeon device.

6) Use of skb_mapping for tag in firmware for traffic path. Also start
using skb_tx_hash for xmit select queue. Introduce interrupt moderation
for TX also.

7) Update to new control command format between Firmware and driver.

8) Increase of number queues per interface to support new revision
of chips.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  59 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   7 +-
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h |   1 -
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 897 +++++++++++----------
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 290 ++++---
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  20 +-
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  33 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 224 ++---
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  69 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 230 +++---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  26 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  93 ++-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  25 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |  18 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  | 246 +++++-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  55 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |  29 +-
 .../net/ethernet/cavium/liquidio/request_manager.c | 281 ++++---
 .../ethernet/cavium/liquidio/response_manager.c    |  16 +-
 19 files changed, 1622 insertions(+), 997 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index 8ad7425..cbd8c4d 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -74,9 +74,9 @@ void lio_cn6xxx_enable_error_reporting(struct octeon_device *oct)
 	u32 val;
 
 	pci_read_config_dword(oct->pci_dev, CN6XXX_PCIE_DEVCTL, &val);
-	if (val & 0x000f0000) {
+	if (val & 0x000c0000) {
 		dev_err(&oct->pci_dev->dev, "PCI-E Link error detected: 0x%08x\n",
-			val & 0x000f0000);
+			val & 0x000c0000);
 	}
 
 	val |= 0xf;          /* Enable Link error reporting */
@@ -229,7 +229,7 @@ void lio_cn6xxx_setup_global_output_regs(struct octeon_device *oct)
 	/* / Select Packet count instead of bytes for SLI_PKTi_CNTS[CNT] */
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_BMODE, 0);
 
-	/* / Select ES,RO,NS setting from register for Output Queue Packet
+	/* Select ES, RO, NS setting from register for Output Queue Packet
 	 * Address
 	 */
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_DPADDR, 0xFFFFFFFF);
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
@@ -429,29 +430,29 @@ void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
 
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
 
 	oct->fn_list.setup_device_regs(oct);
 
-	oct->fn_list.enable_interrupt(oct->chip);
+	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
 
 	oct->fn_list.enable_io_queues(oct);
 
 	/* for (i = 0; i < oct->num_oqs; i++) { */
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		if (!(oct->io_qmask.oq & (1UL << i)))
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if (!(oct->io_qmask.oq & (1ULL << i)))
 			continue;
 		writel(oct->droq[i]->max_count, oct->droq[i]->pkts_credit_reg);
 	}
@@ -495,8 +496,7 @@ u32 lio_cn6xxx_bar1_idx_read(struct octeon_device *oct, u32 idx)
 }
 
 u32
-lio_cn6xxx_update_read_index(struct octeon_device *oct __attribute__((unused)),
-			     struct octeon_instr_queue *iq)
+lio_cn6xxx_update_read_index(struct octeon_instr_queue *iq)
 {
 	u32 new_idx = readl(iq->inst_cnt_reg);
 
@@ -517,18 +517,20 @@ lio_cn6xxx_update_read_index(struct octeon_device *oct __attribute__((unused)),
 	return new_idx;
 }
 
-void lio_cn6xxx_enable_interrupt(void *chip)
+void lio_cn6xxx_enable_interrupt(struct octeon_device *oct,
+				 u8 unused __attribute__((unused)))
 {
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	u64 mask = cn6xxx->intr_mask64 | CN6XXX_INTR_DMA0_FORCE;
 
 	/* Enable Interrupt */
 	writeq(mask, cn6xxx->intr_enb_reg64);
 }
 
-void lio_cn6xxx_disable_interrupt(void *chip)
+void lio_cn6xxx_disable_interrupt(struct octeon_device *oct,
+				  u8 unused __attribute__((unused)))
 {
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
+	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 
 	/* Disable Interrupts */
 	writeq(0, cn6xxx->intr_enb_reg64);
@@ -557,7 +559,8 @@ lio_cn6xxx_process_pcie_error_intr(struct octeon_device *oct, u64 intr64)
 int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 {
 	struct octeon_droq *droq;
-	u32 oq_no, pkt_count, droq_time_mask, droq_mask, droq_int_enb;
+	int oq_no;
+	u32 pkt_count, droq_time_mask, droq_mask, droq_int_enb;
 	u32 droq_cnt_enb, droq_cnt_mask;
 
 	droq_cnt_enb = octeon_read_csr(oct, CN6XXX_SLI_PKT_CNT_INT_ENB);
@@ -573,12 +576,12 @@ int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 	oct->droq_intr = 0;
 
 	/* for (oq_no = 0; oq_no < oct->num_oqs; oq_no++) { */
-	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
-		if (!(droq_mask & (1 << oq_no)))
+	for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct); oq_no++) {
+		if (!(droq_mask & (1ULL << oq_no)))
 			continue;
 
 		droq = oct->droq[oq_no];
-		pkt_count = octeon_droq_check_hw_for_pkts(oct, droq);
+		pkt_count = octeon_droq_check_hw_for_pkts(droq);
 		if (pkt_count) {
 			oct->droq_intr |= (1ULL << oq_no);
 			if (droq->ops.poll_mode) {
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index f779187..29b9790 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -91,10 +91,9 @@ void lio_cn6xxx_bar1_idx_setup(struct octeon_device *oct, u64 core_addr,
 void lio_cn6xxx_bar1_idx_write(struct octeon_device *oct, u32 idx, u32 mask);
 u32 lio_cn6xxx_bar1_idx_read(struct octeon_device *oct, u32 idx);
 u32
-lio_cn6xxx_update_read_index(struct octeon_device *oct __attribute__((unused)),
-			     struct octeon_instr_queue *iq);
-void lio_cn6xxx_enable_interrupt(void *chip);
-void lio_cn6xxx_disable_interrupt(void *chip);
+lio_cn6xxx_update_read_index(struct octeon_instr_queue *iq);
+void lio_cn6xxx_enable_interrupt(struct octeon_device *oct, u8 unused);
+void lio_cn6xxx_disable_interrupt(struct octeon_device *oct, u8 unused);
 void cn6xxx_get_pcie_qlmport(struct octeon_device *oct);
 void lio_cn6xxx_setup_reg_address(struct octeon_device *oct, void *chip,
 				  struct octeon_reg_list *reg_list);
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
index 38cddbd..d45a0f4 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
@@ -29,7 +29,6 @@
 
 #ifndef __CN68XX_REGS_H__
 #define __CN68XX_REGS_H__
-#include "cn66xx_regs.h"
 
 /*###################### REQUEST QUEUE #########################*/
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8de79ae..1a49d77 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -21,6 +21,7 @@
 **********************************************************************/
 #include <linux/version.h>
 #include <linux/module.h>
+#include <linux/init.h>
 #include <linux/crc32.h>
 #include <linux/dma-mapping.h>
 #include <linux/pci.h>
@@ -37,6 +38,7 @@
 #include <linux/list.h>
 #include <linux/workqueue.h>
 #include <linux/interrupt.h>
+#include <linux/kthread.h>
 #include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
@@ -72,6 +74,9 @@ MODULE_PARM_DESC(console_bitmask,
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
+#define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
+	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
+
 static int debug = -1;
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
@@ -84,6 +89,8 @@ static int conf_type;
 module_param(conf_type, int, 0);
 MODULE_PARM_DESC(conf_type, "select octeon configuration 0 default 1 ovs");
 
+static int ptp_enable = 1;
+
 /* Bit mask values for lio->ifstate */
 #define   LIO_IFSTATE_DROQ_OPS             0x01
 #define   LIO_IFSTATE_REGISTERED           0x02
@@ -166,6 +173,8 @@ struct octnic_gather {
 	 *  received from the IP layer.
 	 */
 	struct octeon_sg_entry *sg;
+
+	u64 sg_dma_ptr;
 };
 
 /** This structure is used by NIC driver to store information required
@@ -207,7 +216,6 @@ static int octeon_device_init(struct octeon_device *);
 static void liquidio_remove(struct pci_dev *pdev);
 static int liquidio_probe(struct pci_dev *pdev,
 			  const struct pci_device_id *ent);
-
 static struct handshake handshake[MAX_OCTEON_DEVICES];
 static struct completion first_stage;
 
@@ -220,11 +228,12 @@ static void octeon_droq_bh(unsigned long pdev)
 		(struct octeon_device_priv *)oct->priv;
 
 	/* for (q_no = 0; q_no < oct->num_oqs; q_no++) { */
-	for (q_no = 0; q_no < MAX_OCTEON_OUTPUT_QUEUES; q_no++) {
-		if (!(oct->io_qmask.oq & (1UL << q_no)))
+	for (q_no = 0; q_no < MAX_OCTEON_OUTPUT_QUEUES(oct); q_no++) {
+		if (!(oct->io_qmask.oq & (1ULL << q_no)))
 			continue;
 		reschedule |= octeon_droq_process_packets(oct, oct->droq[q_no],
 							  MAX_PACKET_BUDGET);
+		lio_enable_irq(oct->droq[q_no], NULL);
 	}
 
 	if (reschedule)
@@ -241,11 +250,10 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 	do {
 		pending_pkts = 0;
 
-		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-			if (!(oct->io_qmask.oq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.oq & (1ULL << i)))
 				continue;
-			pkt_cnt += octeon_droq_check_hw_for_pkts(oct,
-								 oct->droq[i]);
+			pkt_cnt += octeon_droq_check_hw_for_pkts(oct->droq[i]);
 		}
 		if (pkt_cnt > 0) {
 			pending_pkts += pkt_cnt;
@@ -392,10 +400,10 @@ static inline void pcierror_quiesce_device(struct octeon_device *oct)
 		dev_err(&oct->pci_dev->dev, "There were pending requests\n");
 
 	/* Force all requests waiting to be fetched by OCTEON to complete. */
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
 		struct octeon_instr_queue *iq;
 
-		if (!(oct->io_qmask.iq & (1UL << i)))
+		if (!(oct->io_qmask.iq & (1ULL << i)))
 			continue;
 		iq = oct->instr_queue[i];
 
@@ -405,7 +413,7 @@ static inline void pcierror_quiesce_device(struct octeon_device *oct)
 			iq->octeon_read_index = iq->host_write_index;
 			iq->stats.instr_processed +=
 				atomic_read(&iq->instr_pending);
-			lio_process_iq_request_list(oct, iq);
+			lio_process_iq_request_list(oct, iq, 0);
 			spin_unlock_bh(&iq->lock);
 		}
 	}
@@ -448,7 +456,7 @@ static void stop_pci_io(struct octeon_device *oct)
 	pci_disable_device(oct->pci_dev);
 
 	/* Disable interrupts  */
-	oct->fn_list.disable_interrupt(oct->chip);
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
 
 	pcierror_quiesce_device(oct);
 
@@ -500,7 +508,8 @@ static pci_ers_result_t liquidio_pcie_error_detected(struct pci_dev *pdev,
  * \brief mmio handler
  * @param pdev Pointer to PCI device
  */
-static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
+static pci_ers_result_t liquidio_pcie_mmio_enabled(
+				struct pci_dev *pdev __attribute__((unused)))
 {
 	/* We should never hit this since we never ask for a reset for a Fatal
 	 * Error. We always return DISCONNECT in io_error above.
@@ -516,7 +525,8 @@ static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
  * Restart the card from scratch, as if from a cold-boot. Implementation
  * resembles the first-half of the octeon_resume routine.
  */
-static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
+static pci_ers_result_t liquidio_pcie_slot_reset(
+				struct pci_dev *pdev __attribute__((unused)))
 {
 	/* We should never hit this since we never ask for a reset for a Fatal
 	 * Error. We always return DISCONNECT in io_error above.
@@ -533,7 +543,7 @@ static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
  * its OK to resume normal operation. Implementation resembles the
  * second-half of the octeon_resume routine.
  */
-static void liquidio_pcie_resume(struct pci_dev *pdev)
+static void liquidio_pcie_resume(struct pci_dev *pdev __attribute__((unused)))
 {
 	/* Nothing to be done here. */
 }
@@ -544,7 +554,8 @@ static void liquidio_pcie_resume(struct pci_dev *pdev)
  * @param pdev Pointer to PCI device
  * @param state state to suspend to
  */
-static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
+static int liquidio_suspend(struct pci_dev *pdev __attribute__((unused)),
+			    pm_message_t state __attribute__((unused)))
 {
 	return 0;
 }
@@ -553,7 +564,7 @@ static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
  * \brief called when resuming
  * @param pdev Pointer to PCI device
  */
-static int liquidio_resume(struct pci_dev *pdev)
+static int liquidio_resume(struct pci_dev *pdev __attribute__((unused)))
 {
 	return 0;
 }
@@ -678,11 +689,18 @@ static inline void txqs_start(struct net_device *netdev)
  */
 static inline void txqs_wake(struct net_device *netdev)
 {
+	struct lio *lio = GET_LIO(netdev);
+
 	if (netif_is_multiqueue(netdev)) {
 		int i;
 
-		for (i = 0; i < netdev->num_tx_queues; i++)
-			netif_wake_subqueue(netdev, i);
+		for (i = 0; i < netdev->num_tx_queues; i++) {
+			int qno = lio->linfo.txpciq[i %
+				(lio->linfo.num_txpciq)].s.q_no;
+
+			if (__netif_subqueue_stopped(netdev, i))
+				netif_wake_subqueue(netdev, i);
+		}
 	} else {
 		netif_wake_queue(netdev);
 	}
@@ -705,7 +723,7 @@ static void start_txq(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 
-	if (lio->linfo.link.s.status) {
+	if (lio->linfo.link.s.link_up) {
 		txqs_start(netdev);
 		return;
 	}
@@ -752,11 +770,14 @@ static inline int check_txq_status(struct lio *lio)
 
 		/* check each sub-queue state */
 		for (q = 0; q < numqs; q++) {
-			iq = lio->linfo.txpciq[q & (lio->linfo.num_txpciq - 1)];
+			iq = lio->linfo.txpciq[q %
+				(lio->linfo.num_txpciq)].s.q_no;
 			if (octnet_iq_is_full(lio->oct_dev, iq))
 				continue;
-			wake_q(lio->netdev, q);
-			ret_val++;
+			if (__netif_subqueue_stopped(lio->netdev, q)) {
+				wake_q(lio->netdev, q);
+				ret_val++;
+			}
 		}
 	} else {
 		if (octnet_iq_is_full(lio->oct_dev, lio->txq))
@@ -787,64 +808,116 @@ static inline struct list_head *list_delete_head(struct list_head *root)
 }
 
 /**
- * \brief Delete gather list
+ * \brief Delete gather lists
  * @param lio per-network private data
  */
-static void delete_glist(struct lio *lio)
+static void delete_glists(struct lio *lio)
 {
 	struct octnic_gather *g;
+	int i;
 
-	do {
-		g = (struct octnic_gather *)
-		    list_delete_head(&lio->glist);
-		if (g) {
-			if (g->sg)
-				kfree((void *)((unsigned long)g->sg -
-						g->adjust));
-			kfree(g);
-		}
-	} while (g);
+	if (!lio->glist)
+		return;
+
+	for (i = 0; i < lio->linfo.num_txpciq; i++) {
+		do {
+			g = (struct octnic_gather *)
+				list_delete_head(&lio->glist[i]);
+			if (g) {
+				if (g->sg) {
+					dma_unmap_single(&lio->oct_dev->
+							 pci_dev->dev,
+							 g->sg_dma_ptr,
+							 g->sg_size,
+							 DMA_TO_DEVICE);
+					kfree((void *)((unsigned long)g->sg -
+						       g->adjust));
+				}
+				kfree(g);
+			}
+		} while (g);
+	}
+
+	kfree((void *)lio->glist);
 }
 
 /**
- * \brief Setup gather list
+ * \brief Setup gather lists
  * @param lio per-network private data
  */
-static int setup_glist(struct lio *lio)
+static int setup_glists(struct octeon_device *oct, struct lio *lio, int num_iqs)
 {
-	int i;
+	int i, j;
 	struct octnic_gather *g;
 
-	INIT_LIST_HEAD(&lio->glist);
+	lio->glist_lock = kcalloc(num_iqs, sizeof(*lio->glist_lock),
+				  GFP_KERNEL);
+	if (!lio->glist_lock)
+		return 1;
 
-	for (i = 0; i < lio->tx_qsize; i++) {
-		g = kzalloc(sizeof(*g), GFP_KERNEL);
-		if (!g)
-			break;
+	lio->glist = kcalloc(num_iqs, sizeof(*lio->glist),
+			     GFP_KERNEL);
+	if (!lio->glist) {
+		kfree((void *)lio->glist_lock);
+		return 1;
+	}
 
-		g->sg_size =
-			((ROUNDUP4(OCTNIC_MAX_SG) >> 2) * OCT_SG_ENTRY_SIZE);
+	for (i = 0; i < num_iqs; i++) {
+		int numa_node = cpu_to_node(i % num_online_cpus());
 
-		g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
-		if (!g->sg) {
-			kfree(g);
-			break;
+		spin_lock_init(&lio->glist_lock[i]);
+
+		INIT_LIST_HEAD(&lio->glist[i]);
+
+		for (j = 0; j < lio->tx_qsize; j++) {
+			g = kzalloc_node(sizeof(*g), GFP_KERNEL,
+					 numa_node);
+			if (!g)
+				g = kzalloc(sizeof(*g), GFP_KERNEL);
+			if (!g)
+				break;
+
+			g->sg_size = ((ROUNDUP4(OCTNIC_MAX_SG) >> 2) *
+				      OCT_SG_ENTRY_SIZE);
+
+			g->sg = kmalloc_node(g->sg_size + 8,
+					     GFP_KERNEL, numa_node);
+			if (!g->sg)
+				g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
+			if (!g->sg) {
+				kfree(g);
+				break;
+			}
+
+			/* The gather component should be aligned on 64-bit
+			 * boundary
+			 */
+			if (((unsigned long)g->sg) & 7) {
+				g->adjust = 8 - (((unsigned long)g->sg) & 7);
+				g->sg = (struct octeon_sg_entry *)
+					((unsigned long)g->sg + g->adjust);
+			}
+			g->sg_dma_ptr = dma_map_single(&oct->pci_dev->dev,
+						       g->sg, g->sg_size,
+						       DMA_TO_DEVICE);
+			if (dma_mapping_error(&oct->pci_dev->dev,
+					      g->sg_dma_ptr)) {
+				kfree((void *)((unsigned long)g->sg -
+					       g->adjust));
+				kfree(g);
+				break;
+			}
+
+			list_add_tail(&g->list, &lio->glist[i]);
 		}
 
-		/* The gather component should be aligned on 64-bit boundary */
-		if (((unsigned long)g->sg) & 7) {
-			g->adjust = 8 - (((unsigned long)g->sg) & 7);
-			g->sg = (struct octeon_sg_entry *)
-				((unsigned long)g->sg + g->adjust);
+		if (j != lio->tx_qsize) {
+			delete_glists(lio);
+			return 1;
 		}
-		list_add_tail(&g->list, &lio->glist);
 	}
 
-	if (i == lio->tx_qsize)
-		return 0;
-
-	delete_glist(lio);
-	return 1;
+	return 0;
 }
 
 /**
@@ -858,7 +931,7 @@ static void print_link_info(struct net_device *netdev)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED) {
 		struct oct_link_info *linfo = &lio->linfo;
 
-		if (linfo->link.s.status) {
+		if (linfo->link.s.link_up) {
 			netif_info(lio, link, lio->netdev, "%d Mbps %s Duplex UP\n",
 				   linfo->link.s.speed,
 				   (linfo->link.s.duplex) ? "Full" : "Half");
@@ -880,13 +953,15 @@ static inline void update_link_status(struct net_device *netdev,
 				      union oct_link_status *ls)
 {
 	struct lio *lio = GET_LIO(netdev);
+	int changed = (lio->linfo.link.u64 != ls->u64);
 
-	if ((lio->intf_open) && (lio->linfo.link.u64 != ls->u64)) {
-		lio->linfo.link.u64 = ls->u64;
+	lio->linfo.link.u64 = ls->u64;
 
+	if ((lio->intf_open) && (changed)) {
 		print_link_info(netdev);
+		lio->link_changes++;
 
-		if (lio->linfo.link.s.status) {
+		if (lio->linfo.link.s.link_up) {
 			netif_carrier_on(netdev);
 			/* start_txq(netdev); */
 			txqs_wake(netdev);
@@ -901,7 +976,6 @@ static inline void update_link_status(struct net_device *netdev,
  * \brief Droq packet processor sceduler
  * @param oct octeon device
  */
-static
 void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 {
 	struct octeon_device_priv *oct_priv =
@@ -910,10 +984,10 @@ void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 	struct octeon_droq *droq;
 
 	if (oct->int_status & OCT_DEV_INTR_PKT_DATA) {
-		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES; oq_no++) {
-			if (!(oct->droq_intr & (1 << oq_no)))
+		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct);
+		     oq_no++) {
+			if (!(oct->droq_intr & (1ULL << oq_no)))
 				continue;
-
 			droq = oct->droq[oq_no];
 
 			if (droq->ops.poll_mode) {
@@ -932,13 +1006,14 @@ void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
  * @param dev octeon device
  */
 static
-irqreturn_t liquidio_intr_handler(int irq __attribute__((unused)), void *dev)
+irqreturn_t liquidio_legacy_intr_handler(int irq __attribute__((unused)),
+					 void *dev)
 {
 	struct octeon_device *oct = (struct octeon_device *)dev;
 	irqreturn_t ret;
 
 	/* Disable our interrupts for the duration of ISR */
-	oct->fn_list.disable_interrupt(oct->chip);
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
 
 	ret = oct->fn_list.process_interrupt_regs(oct);
 
@@ -947,7 +1022,7 @@ irqreturn_t liquidio_intr_handler(int irq __attribute__((unused)), void *dev)
 
 	/* Re-enable our interrupts  */
 	if (!(atomic_read(&oct->status) == OCT_DEV_IN_RESET))
-		oct->fn_list.enable_interrupt(oct->chip);
+		oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
 
 	return ret;
 }
@@ -964,12 +1039,13 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 
 	err = pci_enable_msi(oct->pci_dev);
 	if (err)
-		dev_warn(&oct->pci_dev->dev, "Reverting to legacy interrupts. Error: %d\n",
-			 err);
+		dev_warn(&oct->pci_dev->dev, "Reverting to legacy interrupts. Error: %d\n"
+			 , err);
 	else
 		oct->flags |= LIO_FLAG_MSI_ENABLED;
 
-	irqret = request_irq(oct->pci_dev->irq, liquidio_intr_handler,
+	irqret = request_irq(oct->pci_dev->irq,
+			     liquidio_legacy_intr_handler,
 			     IRQF_SHARED, "octeon", oct);
 	if (irqret) {
 		if (oct->flags & LIO_FLAG_MSI_ENABLED)
@@ -978,7 +1054,6 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 			irqret);
 		return 1;
 	}
-
 	return 0;
 }
 
@@ -987,7 +1062,9 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
  * @param pdev PCI device structure
  * @param ent unused
  */
-static int liquidio_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int
+liquidio_probe(struct pci_dev *pdev,
+	       const struct pci_device_id *ent __attribute__((unused)))
 {
 	struct octeon_device *oct_dev = NULL;
 	struct handshake *hs;
@@ -1022,6 +1099,9 @@ static int liquidio_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENOMEM;
 	}
 
+	oct_dev->rx_pause = 1;
+	oct_dev->tx_pause = 1;
+
 	dev_dbg(&oct_dev->pci_dev->dev, "Device is ready\n");
 
 	return 0;
@@ -1159,18 +1239,15 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 static void send_rx_ctrl_cmd(struct lio *lio, int start_stop)
 {
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.s.cmd = OCTNET_CMD_RX_CTL;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = start_stop;
+	nctrl.ncmd.s.param1 = start_stop;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.netpndev = (u64)lio->netdev;
 
-	nparams.resp_order = OCTEON_RESP_NORESPONSE;
-
-	if (octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams) < 0)
+	if (octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl) < 0)
 		netif_info(lio, rx_err, lio->netdev, "Failed to send RX Control message\n");
 }
 
@@ -1186,6 +1263,7 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 {
 	struct net_device *netdev = oct->props[ifidx].netdev;
 	struct lio *lio;
+	struct napi_struct *napi, *n;
 
 	if (!netdev) {
 		dev_err(&oct->pci_dev->dev, "%s No netdevice ptr for index %d\n",
@@ -1202,13 +1280,18 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		txqs_stop(netdev);
 
+	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+		napi_disable(napi);
+
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
-	delete_glist(lio);
+	delete_glists(lio);
 
 	free_netdev(netdev);
 
+	oct->props[ifidx].gmxport = -1;
+
 	oct->props[ifidx].netdev = NULL;
 }
 
@@ -1216,7 +1299,7 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
  * \brief Stop complete NIC functionality
  * @param oct octeon device
  */
-static int liquidio_stop_nic_module(struct octeon_device *oct)
+int liquidio_stop_nic_module(struct octeon_device *oct)
 {
 	int i, j;
 	struct lio *lio;
@@ -1227,10 +1310,15 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 		return 1;
 	}
 
+	spin_lock_bh(&oct->cmd_resp_wqlock);
+	oct->cmd_resp_state = OCT_DRV_OFFLINE;
+	spin_unlock_bh(&oct->cmd_resp_wqlock);
+
 	for (i = 0; i < oct->ifcount; i++) {
 		lio = GET_LIO(oct->props[i].netdev);
 		for (j = 0; j < lio->linfo.num_rxpciq; j++)
-			octeon_unregister_droq_ops(oct, lio->linfo.rxpciq[j]);
+			octeon_unregister_droq_ops(oct,
+						   lio->linfo.rxpciq[j].s.q_no);
 	}
 
 	for (i = 0; i < oct->ifcount; i++)
@@ -1274,6 +1362,7 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 {
 	u32 dev_id, rev_id;
 	int ret = 1;
+	char *s;
 
 	pci_read_config_dword(oct->pci_dev, 0, &dev_id);
 	pci_read_config_dword(oct->pci_dev, 8, &rev_id);
@@ -1283,22 +1372,27 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 	case OCTEON_CN68XX_PCIID:
 		oct->chip_id = OCTEON_CN68XX;
 		ret = lio_setup_cn68xx_octeon_device(oct);
+		s = "CN68XX";
 		break;
 
 	case OCTEON_CN66XX_PCIID:
 		oct->chip_id = OCTEON_CN66XX;
 		ret = lio_setup_cn66xx_octeon_device(oct);
+		s = "CN66XX";
 		break;
+
 	default:
+		s = "?";
 		dev_err(&oct->pci_dev->dev, "Unknown device found (dev_id: %x)\n",
 			dev_id);
 	}
 
 	if (!ret)
-		dev_info(&oct->pci_dev->dev, "CN68XX PASS%d.%d %s\n",
+		dev_info(&oct->pci_dev->dev, "%s PASS%d.%d %s Version: %s\n", s,
 			 OCTEON_MAJOR_REV(oct),
 			 OCTEON_MINOR_REV(oct),
-			 octeon_get_conf(oct)->card_name);
+			 octeon_get_conf(oct)->card_name,
+			 LIQUIDIO_VERSION);
 
 	return ret;
 }
@@ -1326,6 +1420,16 @@ static int octeon_pci_os_setup(struct octeon_device *oct)
 	return 0;
 }
 
+static inline int skb_iq(struct lio *lio, struct sk_buff *skb)
+{
+	int q = 0;
+
+	if (netif_is_multiqueue(lio->netdev))
+		q = skb->queue_mapping % lio->linfo.num_txpciq;
+
+	return q;
+}
+
 /**
  * \brief Check Tx queue state for a given network buffer
  * @param lio per-network private data
@@ -1337,14 +1441,18 @@ static inline int check_txq_state(struct lio *lio, struct sk_buff *skb)
 
 	if (netif_is_multiqueue(lio->netdev)) {
 		q = skb->queue_mapping;
-		iq = lio->linfo.txpciq[(q & (lio->linfo.num_txpciq - 1))];
+		iq = lio->linfo.txpciq[(q % (lio->linfo.num_txpciq))].s.q_no;
 	} else {
 		iq = lio->txq;
+		q = iq;
 	}
 
 	if (octnet_iq_is_full(lio->oct_dev, iq))
 		return 0;
-	wake_q(lio->netdev, q);
+
+	if (__netif_subqueue_stopped(lio->netdev, q))
+		wake_q(lio->netdev, q);
+
 	return 1;
 }
 
@@ -1367,7 +1475,7 @@ static void free_netbuf(void *buf)
 
 	check_txq_state(lio, skb);
 
-	recv_buffer_free((struct sk_buff *)skb);
+	tx_buffer_free(skb);
 }
 
 /**
@@ -1380,7 +1488,7 @@ static void free_netsgbuf(void *buf)
 	struct sk_buff *skb;
 	struct lio *lio;
 	struct octnic_gather *g;
-	int i, frags;
+	int i, frags, iq;
 
 	finfo = (struct octnet_buf_free_info *)buf;
 	skb = finfo->skb;
@@ -1402,17 +1510,17 @@ static void free_netsgbuf(void *buf)
 		i++;
 	}
 
-	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
-			 finfo->dptr, g->sg_size,
-			 DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(&lio->oct_dev->pci_dev->dev,
+				g->sg_dma_ptr, g->sg_size, DMA_TO_DEVICE);
 
-	spin_lock(&lio->lock);
-	list_add_tail(&g->list, &lio->glist);
-	spin_unlock(&lio->lock);
+	iq = skb_iq(lio, skb);
+	spin_lock(&lio->glist_lock[iq]);
+	list_add_tail(&g->list, &lio->glist[iq]);
+	spin_unlock(&lio->glist_lock[iq]);
 
 	check_txq_state(lio, skb);     /* mq support: sub-queue state check */
 
-	recv_buffer_free((struct sk_buff *)skb);
+	tx_buffer_free(skb);
 }
 
 /**
@@ -1426,7 +1534,7 @@ static void free_netsgbuf_with_resp(void *buf)
 	struct sk_buff *skb;
 	struct lio *lio;
 	struct octnic_gather *g;
-	int i, frags;
+	int i, frags, iq;
 
 	sc = (struct octeon_soft_command *)buf;
 	skb = (struct sk_buff *)sc->callback_arg;
@@ -1450,13 +1558,14 @@ static void free_netsgbuf_with_resp(void *buf)
 		i++;
 	}
 
-	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
-			 finfo->dptr, g->sg_size,
-			 DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(&lio->oct_dev->pci_dev->dev,
+				g->sg_dma_ptr, g->sg_size, DMA_TO_DEVICE);
 
-	spin_lock(&lio->lock);
-	list_add_tail(&g->list, &lio->glist);
-	spin_unlock(&lio->lock);
+	iq = skb_iq(lio, skb);
+
+	spin_lock(&lio->glist_lock[iq]);
+	list_add_tail(&g->list, &lio->glist[iq]);
+	spin_unlock(&lio->glist_lock[iq]);
 
 	/* Don't free the skb yet */
 
@@ -1526,6 +1635,7 @@ static int liquidio_ptp_gettime(struct ptp_clock_info *ptp,
 				struct timespec64 *ts)
 {
 	u64 ns;
+	u32 remainder;
 	unsigned long flags;
 	struct lio *lio = container_of(ptp, struct lio, ptp_info);
 	struct octeon_device *oct = (struct octeon_device *)lio->oct_dev;
@@ -1535,7 +1645,8 @@ static int liquidio_ptp_gettime(struct ptp_clock_info *ptp,
 	ns += lio->ptp_adjust;
 	spin_unlock_irqrestore(&lio->ptp_lock, flags);
 
-	*ts = ns_to_timespec64(ns);
+	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
+	ts->tv_nsec = remainder;
 
 	return 0;
 }
@@ -1569,8 +1680,10 @@ static int liquidio_ptp_settime(struct ptp_clock_info *ptp,
  * @param rq request
  * @param on is it on
  */
-static int liquidio_ptp_enable(struct ptp_clock_info *ptp,
-			       struct ptp_clock_request *rq, int on)
+static int
+liquidio_ptp_enable(struct ptp_clock_info *ptp __attribute__((unused)),
+		    struct ptp_clock_request *rq __attribute__((unused)),
+		    int on __attribute__((unused)))
 {
 	return -EOPNOTSUPP;
 }
@@ -1612,7 +1725,7 @@ static void oct_ptp_open(struct net_device *netdev)
  * \brief Init PTP clock
  * @param oct octeon device
  */
-static void liquidio_ptp_init(struct octeon_device *oct)
+void liquidio_ptp_init(struct octeon_device *oct)
 {
 	u64 clock_comp, cfg;
 
@@ -1657,6 +1770,7 @@ static int load_firmware(struct octeon_device *oct)
 	if (ret) {
 		dev_err(&oct->pci_dev->dev, "Request firmware failed. Could not find file %s.\n.",
 			fw_name);
+		release_firmware(fw);
 		return ret;
 	}
 
@@ -1710,7 +1824,7 @@ static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
  * @param buf pointer to resp structure
  */
 static void if_cfg_callback(struct octeon_device *oct,
-			    u32 status,
+			    u32 status __attribute__((unused)),
 			    void *buf)
 {
 	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
@@ -1724,7 +1838,10 @@ static void if_cfg_callback(struct octeon_device *oct,
 	if (resp->status)
 		dev_err(&oct->pci_dev->dev, "nic if cfg instruction failed. Status: %llx\n",
 			CVM_CAST64(resp->status));
-	ACCESS_ONCE(ctx->cond) = 1;
+	WRITE_ONCE(ctx->cond, 1);
+
+	snprintf(oct->fw_info.liquidio_firmware_version, 32, "%s",
+		 resp->cfg_info.liquidio_firmware_version);
 
 	/* This barrier is required to be sure that the response has been
 	 * written fully before waking up the handler
@@ -1741,16 +1858,16 @@ static void if_cfg_callback(struct octeon_device *oct,
  * @returns selected queue number
  */
 static u16 select_q(struct net_device *dev, struct sk_buff *skb,
-		    void *accel_priv, select_queue_fallback_t fallback)
+		    void *accel_priv __attribute__((unused)),
+		    select_queue_fallback_t fallback __attribute__((unused)))
 {
-	int qindex;
+	u32 qindex = 0;
 	struct lio *lio;
 
 	lio = GET_LIO(dev);
-	/* select queue on chosen queue_mapping or core */
-	qindex = skb_rx_queue_recorded(skb) ?
-		 skb_get_rx_queue(skb) : smp_processor_id();
-	return (u16)(qindex & (lio->linfo.num_txpciq - 1));
+	qindex = skb_tx_hash(dev, skb);
+
+	return (u16)(qindex % (lio->linfo.num_txpciq));
 }
 
 /** Routine to push packets arriving on Octeon interface upto network layer.
@@ -1759,26 +1876,27 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
  * @param len      - size of total data received.
  * @param rh       - Control header associated with the packet
  * @param param    - additional control data with the packet
+ * @param arg	   - farg registered in droq_ops
  */
 static void
-liquidio_push_packet(u32 octeon_id,
+liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		     void *skbuff,
 		     u32 len,
 		     union octeon_rh *rh,
-		     void *param)
+		     void *param,
+		     void *arg)
 {
 	struct napi_struct *napi = param;
-	struct octeon_device *oct = lio_get_device(octeon_id);
 	struct sk_buff *skb = (struct sk_buff *)skbuff;
 	struct skb_shared_hwtstamps *shhwtstamps;
 	u64 ns;
-	struct net_device *netdev =
-		(struct net_device *)oct->props[rh->r_dh.link].netdev;
+	struct net_device *netdev = (struct net_device *)arg;
 	struct octeon_droq *droq = container_of(param, struct octeon_droq,
 						napi);
 	if (netdev) {
 		int packet_was_received;
 		struct lio *lio = GET_LIO(netdev);
+		struct octeon_device *oct = lio->oct_dev;
 
 		/* Do not proceed if the interface is not in RUNNING state. */
 		if (!ifstate_check(lio, LIO_IFSTATE_RUNNING)) {
@@ -1789,27 +1907,60 @@ liquidio_push_packet(u32 octeon_id,
 
 		skb->dev = netdev;
 
-		if (rh->r_dh.has_hwtstamp) {
-			/* timestamp is included from the hardware at the
-			 * beginning of the packet.
-			 */
-			if (ifstate_check(lio,
-					  LIO_IFSTATE_RX_TIMESTAMP_ENABLED)) {
-				/* Nanoseconds are in the first 64-bits
-				 * of the packet.
+		skb_record_rx_queue(skb, droq->q_no);
+		if (likely(len > MIN_SKB_SIZE)) {
+			struct octeon_skb_page_info *pg_info;
+			unsigned char *va;
+
+			pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+			if (pg_info->page) {
+				/* For Paged allocation use the frags */
+				va = page_address(pg_info->page) +
+					pg_info->page_offset;
+				memcpy(skb->data, va, MIN_SKB_SIZE);
+				skb_put(skb, MIN_SKB_SIZE);
+				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+						pg_info->page,
+						pg_info->page_offset +
+						MIN_SKB_SIZE,
+						len - MIN_SKB_SIZE,
+						LIO_RXBUFFER_SZ);
+			}
+		} else {
+			struct octeon_skb_page_info *pg_info =
+				((struct octeon_skb_page_info *)(skb->cb));
+			skb_copy_to_linear_data(skb, page_address(pg_info->page)
+						+ pg_info->page_offset, len);
+			skb_put(skb, len);
+			put_page(pg_info->page);
+		}
+
+		if (((oct->chip_id == OCTEON_CN66XX) ||
+		     (oct->chip_id == OCTEON_CN68XX)) &&
+		    ptp_enable) {
+			if (rh->r_dh.has_hwtstamp) {
+				/* timestamp is included from the hardware at
+				 * the beginning of the packet.
 				 */
-				memcpy(&ns, (skb->data), sizeof(ns));
-				shhwtstamps = skb_hwtstamps(skb);
-				shhwtstamps->hwtstamp =
-					ns_to_ktime(ns + lio->ptp_adjust);
+				if (ifstate_check
+				    (lio, LIO_IFSTATE_RX_TIMESTAMP_ENABLED)) {
+					/* Nanoseconds are in the first 64-bits
+					 * of the packet.
+					 */
+					memcpy(&ns, (skb->data), sizeof(ns));
+					shhwtstamps = skb_hwtstamps(skb);
+					shhwtstamps->hwtstamp =
+						ns_to_ktime(ns +
+							    lio->ptp_adjust);
+				}
+				skb_pull(skb, sizeof(ns));
 			}
-			skb_pull(skb, sizeof(ns));
 		}
 
 		skb->protocol = eth_type_trans(skb, skb->dev);
 
 		if ((netdev->features & NETIF_F_RXCSUM) &&
-		    (rh->r_dh.csum_verified == CNNIC_CSUM_VERIFIED))
+		    (rh->r_dh.csum_verified & CNNIC_CSUM_VERIFIED))
 			/* checksum has already been verified */
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
@@ -1900,7 +2051,6 @@ octnet_napi_finish:
 				     0);
 	return 0;
 }
-
 /**
  * \brief Entry point for NAPI polling
  * @param napi NAPI structure
@@ -2064,11 +2214,12 @@ static int liquidio_open(struct net_device *netdev)
 	oct_ptp_open(netdev);
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
+
 	setup_tx_poll_fn(netdev);
+
 	start_txq(netdev);
 
 	netif_info(lio, ifup, lio->netdev, "Interface Open, ready for traffic\n");
-	try_module_get(THIS_MODULE);
 
 	/* tell Octeon to start forwarding packets to host */
 	send_rx_ctrl_cmd(lio, 1);
@@ -2088,41 +2239,34 @@ static int liquidio_open(struct net_device *netdev)
  */
 static int liquidio_stop(struct net_device *netdev)
 {
-	struct napi_struct *napi, *n;
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 
-	netif_info(lio, ifdown, lio->netdev, "Stopping interface!\n");
+	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
+
+	netif_tx_disable(netdev);
+
 	/* Inform that netif carrier is down */
+	netif_carrier_off(netdev);
 	lio->intf_open = 0;
-	lio->linfo.link.s.status = 0;
+	lio->linfo.link.s.link_up = 0;
+	lio->link_changes++;
 
-	netif_carrier_off(netdev);
+	/* Pause for a moment and wait for Octeon to flush out (to the wire) any
+	 * egress packets that are in-flight.
+	 */
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule_timeout(msecs_to_jiffies(100));
 
-	/* tell Octeon to stop forwarding packets to host */
+	/* Now it should be safe to tell Octeon that nic interface is down. */
 	send_rx_ctrl_cmd(lio, 0);
 
-	cancel_delayed_work_sync(&lio->txq_status_wq.wk.work);
-	flush_workqueue(lio->txq_status_wq.wq);
-	destroy_workqueue(lio->txq_status_wq.wq);
-
 	if (lio->ptp_clock) {
 		ptp_clock_unregister(lio->ptp_clock);
 		lio->ptp_clock = NULL;
 	}
 
-	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
-
-	/* This is a hack that allows DHCP to continue working. */
-	set_bit(__LINK_STATE_START, &lio->netdev->state);
-
-	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
-		napi_disable(napi);
-
-	txqs_stop(netdev);
-
 	dev_info(&oct->pci_dev->dev, "%s interface is stopped\n", netdev->name);
-	module_put(THIS_MODULE);
 
 	return 0;
 }
@@ -2235,7 +2379,6 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	struct netdev_hw_addr *ha;
 	u64 *mc;
 	int ret, i;
@@ -2246,10 +2389,10 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	/* Create a ctrl pkt command to be sent to core app. */
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_MULTI_LIST;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = get_new_flags(netdev);
-	nctrl.ncmd.s.param3 = mc_count;
+	nctrl.ncmd.s.param1 = get_new_flags(netdev);
+	nctrl.ncmd.s.param2 = mc_count;
 	nctrl.ncmd.s.more = mc_count;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
@@ -2270,9 +2413,7 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	 */
 	nctrl.wait_time = 0;
 
-	nparams.resp_order = OCTEON_RESP_NORESPONSE;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "DEVFLAGS change failed in core (ret: 0x%x)\n",
 			ret);
@@ -2290,19 +2431,17 @@ static int liquidio_set_mac(struct net_device *netdev, void *p)
 	struct octeon_device *oct = lio->oct_dev;
 	struct sockaddr *addr = (struct sockaddr *)p;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 
-	if ((!is_valid_ether_addr(addr->sa_data)) ||
-	    (ifstate_check(lio, LIO_IFSTATE_RUNNING)))
+	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MACADDR;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = 0;
+	nctrl.ncmd.s.param1 = 0;
 	nctrl.ncmd.s.more = 1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 	nctrl.wait_time = 100;
@@ -2311,9 +2450,7 @@ static int liquidio_set_mac(struct net_device *netdev, void *p)
 	/* The MAC Address is presented in network byte order. */
 	memcpy((u8 *)&nctrl.udd[0] + 2, addr->sa_data, ETH_ALEN);
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "MAC Address change failed\n");
 		return -ENOMEM;
@@ -2341,7 +2478,7 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 	oct = lio->oct_dev;
 
 	for (i = 0; i < lio->linfo.num_txpciq; i++) {
-		iq_no = lio->linfo.txpciq[i];
+		iq_no = lio->linfo.txpciq[i].s.q_no;
 		iq_stats = &oct->instr_queue[iq_no]->stats;
 		pkts += iq_stats->tx_done;
 		drop += iq_stats->tx_dropped;
@@ -2357,7 +2494,7 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 	bytes = 0;
 
 	for (i = 0; i < lio->linfo.num_rxpciq; i++) {
-		oq_no = lio->linfo.rxpciq[i];
+		oq_no = lio->linfo.rxpciq[i].s.q_no;
 		oq_stats = &oct->droq[oq_no]->stats;
 		pkts += oq_stats->rx_pkts_received;
 		drop += (oq_stats->rx_dropped +
@@ -2383,19 +2520,16 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
-	int max_frm_size = new_mtu + OCTNET_FRM_HEADER_SIZE;
 	int ret = 0;
 
-	/* Limit the MTU to make sure the ethernet packets are between 64 bytes
-	 * and 65535 bytes
+	/* Limit the MTU to make sure the ethernet packets are between 68 bytes
+	 * and 16000 bytes
 	 */
-	if ((max_frm_size < OCTNET_MIN_FRM_SIZE) ||
-	    (max_frm_size > OCTNET_MAX_FRM_SIZE)) {
+	if ((new_mtu < LIO_MIN_MTU_SIZE) ||
+	    (new_mtu > LIO_MAX_MTU_SIZE)) {
 		dev_err(&oct->pci_dev->dev, "Invalid MTU: %d\n", new_mtu);
 		dev_err(&oct->pci_dev->dev, "Valid range %d and %d\n",
-			(OCTNET_MIN_FRM_SIZE - OCTNET_FRM_HEADER_SIZE),
-			(OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE));
+			LIO_MIN_MTU_SIZE, LIO_MAX_MTU_SIZE);
 		return -EINVAL;
 	}
 
@@ -2403,15 +2537,13 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MTU;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = new_mtu;
+	nctrl.ncmd.s.param1 = new_mtu;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Failed to set MTU\n");
 		return -1;
@@ -2428,7 +2560,7 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
  * @param ifr interface request
  * @param cmd command
  */
-static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct hwtstamp_config conf;
 	struct lio *lio = GET_LIO(netdev);
@@ -2489,7 +2621,7 @@ static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return hwtstamp_ioctl(netdev, ifr, cmd);
+		return hwtstamp_ioctl(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -2536,7 +2668,7 @@ static void handle_timestamp(struct octeon_device *oct,
 	}
 
 	octeon_free_soft_command(oct, sc);
-	recv_buffer_free(skb);
+	tx_buffer_free(skb);
 }
 
 /* \brief Send a data packet that will be timestamped
@@ -2551,10 +2683,9 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 {
 	int retval;
 	struct octeon_soft_command *sc;
-	struct octeon_instr_ih *ih;
-	struct octeon_instr_rdp *rdp;
 	struct lio *lio;
 	int ring_doorbell;
+	u32 len;
 
 	lio = finfo->lio;
 
@@ -2576,14 +2707,14 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 	sc->callback_arg = finfo->skb;
 	sc->iq_no = ndata->q_no;
 
-	ih = (struct octeon_instr_ih *)&sc->cmd.ih;
-	rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+	len = (u32)((struct octeon_instr_ih2 *)(&sc->cmd.cmd2.ih2))->dlengsz;
 
 	ring_doorbell = !xmit_more;
+
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
-				     sc, ih->dlengsz, ndata->reqtype);
+				     sc, len, ndata->reqtype);
 
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		dev_err(&oct->pci_dev->dev, "timestamp data packet failed status: %x\n",
 			retval);
 		octeon_free_soft_command(oct, sc);
@@ -2594,68 +2725,6 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 	return retval;
 }
 
-static inline int is_ipv4(struct sk_buff *skb)
-{
-	return (skb->protocol == htons(ETH_P_IP)) &&
-	       (ip_hdr(skb)->version == 4);
-}
-
-static inline int is_vlan(struct sk_buff *skb)
-{
-	return skb->protocol == htons(ETH_P_8021Q);
-}
-
-static inline int is_ip_fragmented(struct sk_buff *skb)
-{
-	/* The Don't fragment and Reserved flag fields are ignored.
-	 * IP is fragmented if
-	 * -  the More fragments bit is set (indicating this IP is a fragment
-	 * with more to follow; the current offset could be 0 ).
-	 * -  ths offset field is non-zero.
-	 */
-	return (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) ? 1 : 0;
-}
-
-static inline int is_ipv6(struct sk_buff *skb)
-{
-	return (skb->protocol == htons(ETH_P_IPV6)) &&
-	       (ipv6_hdr(skb)->version == 6);
-}
-
-static inline int is_with_extn_hdr(struct sk_buff *skb)
-{
-	return (ipv6_hdr(skb)->nexthdr != IPPROTO_TCP) &&
-	       (ipv6_hdr(skb)->nexthdr != IPPROTO_UDP);
-}
-
-static inline int is_tcpudp(struct sk_buff *skb)
-{
-	return (ip_hdr(skb)->protocol == IPPROTO_TCP) ||
-	       (ip_hdr(skb)->protocol == IPPROTO_UDP);
-}
-
-static inline u32 get_ipv4_5tuple_tag(struct sk_buff *skb)
-{
-	u32 tag;
-	struct iphdr *iphdr = ip_hdr(skb);
-
-	tag = crc32(0, &iphdr->protocol, 1);
-	tag = crc32(tag, (u8 *)&iphdr->saddr, 8);
-	tag = crc32(tag, skb_transport_header(skb), 4);
-	return tag;
-}
-
-static inline u32 get_ipv6_5tuple_tag(struct sk_buff *skb)
-{
-	u32 tag;
-	struct ipv6hdr *ipv6hdr = ipv6_hdr(skb);
-
-	tag = crc32(0, &ipv6hdr->nexthdr, 1);
-	tag = crc32(tag, (u8 *)&ipv6hdr->saddr, 32);
-	tag = crc32(tag, skb_transport_header(skb), 4);
-	return tag;
-}
-
 /** \brief Transmit networks packets to the Octeon interface
  * @param skbuff   skbuff struct to be passed to network layer.
  * @param netdev    pointer to network device
@@ -2670,18 +2739,22 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct octnic_data_pkt ndata;
 	struct octeon_device *oct;
 	struct oct_iq_stats *stats;
-	int cpu = 0, status = 0;
+	struct octeon_instr_irh *irh;
+	union tx_info *tx_info;
+	int status = 0;
 	int q_idx = 0, iq_no = 0;
-	int xmit_more;
+	int xmit_more, j;
+	u64 dptr = 0;
 	u32 tag = 0;
 
 	lio = GET_LIO(netdev);
 	oct = lio->oct_dev;
 
 	if (netif_is_multiqueue(netdev)) {
-		cpu = skb->queue_mapping;
-		q_idx = (cpu & (lio->linfo.num_txpciq - 1));
-		iq_no = lio->linfo.txpciq[q_idx];
+		q_idx = skb->queue_mapping;
+		q_idx = (q_idx % (lio->linfo.num_txpciq));
+		tag = q_idx;
+		iq_no = lio->linfo.txpciq[q_idx].s.q_no;
 	} else {
 		iq_no = lio->txq;
 	}
@@ -2692,11 +2765,11 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * transmitted.
 	 */
 	if (!(atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING) ||
-	    (!lio->linfo.link.s.status) ||
+	    (!lio->linfo.link.s.link_up) ||
 	    (skb->len <= 0)) {
 		netif_info(lio, tx_err, lio->netdev,
 			   "Transmit failed link_status : %d\n",
-			   lio->linfo.link.s.status);
+			   lio->linfo.link.s.link_up);
 		goto lio_xmit_failed;
 	}
 
@@ -2714,7 +2787,6 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	ndata.buf = (void *)finfo;
 
 	ndata.q_no = iq_no;
-
 	if (netif_is_multiqueue(netdev)) {
 		if (octnet_iq_is_full(oct, ndata.q_no)) {
 			/* defer sending if queue is full */
@@ -2728,64 +2800,22 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 			/* defer sending if queue is full */
 			stats->tx_iq_busy++;
 			netif_info(lio, tx_err, lio->netdev, "Transmit failed iq:%d full\n",
-				   ndata.q_no);
+				   lio->txq);
 			return NETDEV_TX_BUSY;
 		}
 	}
 	/* pr_info(" XMIT - valid Qs: %d, 1st Q no: %d, cpu:  %d, q_no:%d\n",
-	 *	lio->linfo.num_txpciq, lio->txq, cpu, ndata.q_no );
+	 *	lio->linfo.num_txpciq, lio->txq, cpu, ndata.q_no);
 	 */
 
 	ndata.datasize = skb->len;
 
 	cmdsetup.u64 = 0;
-	cmdsetup.s.ifidx = lio->linfo.ifidx;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (is_ipv4(skb) && !is_ip_fragmented(skb) && is_tcpudp(skb)) {
-			tag = get_ipv4_5tuple_tag(skb);
+	cmdsetup.s.iq_no = iq_no;
 
-			cmdsetup.s.cksum_offset = sizeof(struct ethhdr) + 1;
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		cmdsetup.s.transport_csum = 1;
 
-			if (ip_hdr(skb)->ihl > 5)
-				cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV4OPTS;
-
-		} else if (is_ipv6(skb)) {
-			tag = get_ipv6_5tuple_tag(skb);
-
-			cmdsetup.s.cksum_offset = sizeof(struct ethhdr) + 1;
-
-			if (is_with_extn_hdr(skb))
-				cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV6EXTHDR;
-
-		} else if (is_vlan(skb)) {
-			if (vlan_eth_hdr(skb)->h_vlan_encapsulated_proto
-				== htons(ETH_P_IP) &&
-				!is_ip_fragmented(skb) && is_tcpudp(skb)) {
-				tag = get_ipv4_5tuple_tag(skb);
-
-				cmdsetup.s.cksum_offset =
-					sizeof(struct vlan_ethhdr) + 1;
-
-				if (ip_hdr(skb)->ihl > 5)
-					cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV4OPTS;
-
-			} else if (vlan_eth_hdr(skb)->h_vlan_encapsulated_proto
-				== htons(ETH_P_IPV6)) {
-				tag = get_ipv6_5tuple_tag(skb);
-
-				cmdsetup.s.cksum_offset =
-					sizeof(struct vlan_ethhdr) + 1;
-
-				if (is_with_extn_hdr(skb))
-					cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV6EXTHDR;
-			}
-		}
-	}
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		cmdsetup.s.timestamp = 1;
@@ -2793,20 +2823,21 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	if (skb_shinfo(skb)->nr_frags == 0) {
 		cmdsetup.s.u.datasize = skb->len;
-		octnet_prepare_pci_cmd(&ndata.cmd, &cmdsetup, tag);
+		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
+
 		/* Offload checksum calculation for TCP/UDP packets */
-		ndata.cmd.dptr = dma_map_single(&oct->pci_dev->dev,
-						skb->data,
-						skb->len,
-						DMA_TO_DEVICE);
-		if (dma_mapping_error(&oct->pci_dev->dev, ndata.cmd.dptr)) {
+		dptr = dma_map_single(&oct->pci_dev->dev,
+				      skb->data,
+				      skb->len,
+				      DMA_TO_DEVICE);
+		if (dma_mapping_error(&oct->pci_dev->dev, dptr)) {
 			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 1\n",
 				__func__);
 			return NETDEV_TX_BUSY;
 		}
 
-		finfo->dptr = ndata.cmd.dptr;
-
+		ndata.cmd.cmd2.dptr = dptr;
+		finfo->dptr = dptr;
 		ndata.reqtype = REQTYPE_NORESP_NET;
 
 	} else {
@@ -2814,9 +2845,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		struct skb_frag_struct *frag;
 		struct octnic_gather *g;
 
-		spin_lock(&lio->lock);
-		g = (struct octnic_gather *)list_delete_head(&lio->glist);
-		spin_unlock(&lio->lock);
+		spin_lock(&lio->glist_lock[q_idx]);
+		g = (struct octnic_gather *)
+			list_delete_head(&lio->glist[q_idx]);
+		spin_unlock(&lio->glist_lock[q_idx]);
 
 		if (!g) {
 			netif_info(lio, tx_err, lio->netdev,
@@ -2826,7 +2858,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		cmdsetup.s.gather = 1;
 		cmdsetup.s.u.gatherptrs = (skb_shinfo(skb)->nr_frags + 1);
-		octnet_prepare_pci_cmd(&ndata.cmd, &cmdsetup, tag);
+		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
 
 		memset(g->sg, 0, g->sg_size);
 
@@ -2853,34 +2885,43 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 					     frag->size,
 					     DMA_TO_DEVICE);
 
+			if (dma_mapping_error(&oct->pci_dev->dev,
+					      g->sg[i >> 2].ptr[i & 3])) {
+				dma_unmap_single(&oct->pci_dev->dev,
+						 g->sg[0].ptr[0],
+						 skb->len - skb->data_len,
+						 DMA_TO_DEVICE);
+				for (j = 1; j < i; j++) {
+					frag = &skb_shinfo(skb)->frags[j - 1];
+					dma_unmap_page(&oct->pci_dev->dev,
+						       g->sg[j >> 2].ptr[j & 3],
+						       frag->size,
+						       DMA_TO_DEVICE);
+				}
+				dev_err(&oct->pci_dev->dev, "%s DMA mapping error 3\n",
+					__func__);
+				return NETDEV_TX_BUSY;
+			}
+
 			add_sg_size(&g->sg[(i >> 2)], frag->size, (i & 3));
 			i++;
 		}
 
-		ndata.cmd.dptr = dma_map_single(&oct->pci_dev->dev,
-						g->sg, g->sg_size,
-						DMA_TO_DEVICE);
-		if (dma_mapping_error(&oct->pci_dev->dev, ndata.cmd.dptr)) {
-			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 3\n",
-				__func__);
-			dma_unmap_single(&oct->pci_dev->dev, g->sg[0].ptr[0],
-					 skb->len - skb->data_len,
-					 DMA_TO_DEVICE);
-			return NETDEV_TX_BUSY;
-		}
+		dma_sync_single_for_device(&oct->pci_dev->dev, g->sg_dma_ptr,
+					   g->sg_size, DMA_TO_DEVICE);
+		dptr = g->sg_dma_ptr;
 
-		finfo->dptr = ndata.cmd.dptr;
+		ndata.cmd.cmd2.dptr = dptr;
+		finfo->dptr = dptr;
 		finfo->g = g;
 
 		ndata.reqtype = REQTYPE_NORESP_NET_SG;
 	}
 
-	if (skb_shinfo(skb)->gso_size) {
-		struct octeon_instr_irh *irh =
-			(struct octeon_instr_irh *)&ndata.cmd.irh;
-		union tx_info *tx_info = (union tx_info *)&ndata.cmd.ossp[0];
+	irh = (struct octeon_instr_irh *)&ndata.cmd.cmd2.irh;
+	tx_info = (union tx_info *)&ndata.cmd.cmd2.ossp[0];
 
-		irh->len = 1;   /* to indicate that ossp[0] contains tx_info */
+	if (skb_shinfo(skb)->gso_size) {
 		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
 		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
 	}
@@ -2901,7 +2942,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	netif_trans_update(netdev);
 
-	stats->tx_done++;
+	if (skb_shinfo(skb)->gso_size)
+		stats->tx_done += skb_shinfo(skb)->gso_segs;
+	else
+		stats->tx_done++;
 	stats->tx_tot_bytes += skb->len;
 
 	return NETDEV_TX_OK;
@@ -2910,9 +2954,10 @@ lio_xmit_failed:
 	stats->tx_dropped++;
 	netif_info(lio, tx_err, lio->netdev, "IQ%d Transmit dropped:%llu\n",
 		   iq_no, stats->tx_dropped);
-	dma_unmap_single(&oct->pci_dev->dev, ndata.cmd.dptr,
-			 ndata.datasize, DMA_TO_DEVICE);
-	recv_buffer_free(skb);
+	if (dptr)
+		dma_unmap_single(&oct->pci_dev->dev, dptr,
+				 ndata.datasize, DMA_TO_DEVICE);
+	tx_buffer_free(skb);
 	return NETDEV_TX_OK;
 }
 
@@ -2932,27 +2977,24 @@ static void liquidio_tx_timeout(struct net_device *netdev)
 	txqs_wake(netdev);
 }
 
-int liquidio_set_feature(struct net_device *netdev, int cmd)
+int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int ret = 0;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = cmd;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = OCTNIC_LROIPV4 | OCTNIC_LROIPV6;
+	nctrl.ncmd.s.param1 = param1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
-	nparams.resp_order = OCTEON_RESP_NORESPONSE;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Feature change failed in core (ret: 0x%x)\n",
 			ret);
@@ -3008,10 +3050,12 @@ static int liquidio_set_features(struct net_device *netdev,
 		return 0;
 
 	if ((features & NETIF_F_LRO) && (lio->dev_capability & NETIF_F_LRO))
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE);
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 	else if (!(features & NETIF_F_LRO) &&
 		 (lio->dev_capability & NETIF_F_LRO))
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE);
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
 	return 0;
 }
@@ -3082,24 +3126,27 @@ static int lio_nic_info(struct octeon_recv_info *recv_info, void *buf)
 {
 	struct octeon_device *oct = (struct octeon_device *)buf;
 	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
-	int ifidx = 0;
+	int gmxport = 0;
 	union oct_link_status *ls;
 	int i;
 
-	if ((recv_pkt->buffer_size[0] != sizeof(*ls)) ||
-	    (recv_pkt->rh.r_nic_info.ifidx > oct->ifcount)) {
+	if (recv_pkt->buffer_size[0] != sizeof(*ls)) {
 		dev_err(&oct->pci_dev->dev, "Malformed NIC_INFO, len=%d, ifidx=%d\n",
 			recv_pkt->buffer_size[0],
-			recv_pkt->rh.r_nic_info.ifidx);
+			recv_pkt->rh.r_nic_info.gmxport);
 		goto nic_info_err;
 	}
 
-	ifidx = recv_pkt->rh.r_nic_info.ifidx;
+	gmxport = recv_pkt->rh.r_nic_info.gmxport;
 	ls = (union oct_link_status *)get_rbd(recv_pkt->buffer_ptr[0]);
 
 	octeon_swap_8B_data((u64 *)ls, (sizeof(union oct_link_status)) >> 3);
-
-	update_link_status(oct->props[ifidx].netdev, ls);
+	for (i = 0; i < oct->ifcount; i++) {
+		if (oct->props[i].gmxport == gmxport) {
+			update_link_status(oct->props[i].netdev, ls);
+			break;
+		}
+	}
 
 nic_info_err:
 	for (i = 0; i < recv_pkt->buffer_count; i++)
@@ -3125,13 +3172,13 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	struct liquidio_if_cfg_context *ctx;
 	struct liquidio_if_cfg_resp *resp;
 	struct octdev_props *props;
-	int retval, num_iqueues, num_oqueues, q_no;
-	u64 q_mask;
-	int num_cpus = num_online_cpus();
+	int retval, num_iqueues, num_oqueues;
 	union oct_nic_if_cfg if_cfg;
 	unsigned int base_queue;
 	unsigned int gmx_port_id;
 	u32 resp_size, ctx_size;
+	u32 ifidx_or_pfnum;
+	u64 base_macaddr;
 
 	/* This is to handle link status changes */
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
@@ -3167,14 +3214,12 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			CFG_GET_BASE_QUE_NIC_IF(octeon_get_conf(octeon_dev), i);
 		gmx_port_id =
 			CFG_GET_GMXID_NIC_IF(octeon_get_conf(octeon_dev), i);
-		if (num_iqueues > num_cpus)
-			num_iqueues = num_cpus;
-		if (num_oqueues > num_cpus)
-			num_oqueues = num_cpus;
+		ifidx_or_pfnum = i;
+
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"requesting config for interface %d, iqs %d, oqs %d\n",
-			i, num_iqueues, num_oqueues);
-		ACCESS_ONCE(ctx->cond) = 0;
+			ifidx_or_pfnum, num_iqueues, num_oqueues);
+		WRITE_ONCE(ctx->cond, 0);
 		ctx->octeon_id = lio_get_device_id(octeon_dev);
 		init_waitqueue_head(&ctx->wc);
 
@@ -3183,16 +3228,19 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		if_cfg.s.num_oqueues = num_oqueues;
 		if_cfg.s.base_queue = base_queue;
 		if_cfg.s.gmx_port_id = gmx_port_id;
+
+		sc->iq_no = 0;
+
 		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
-					    OPCODE_NIC_IF_CFG, i,
+					    OPCODE_NIC_IF_CFG, 0,
 					    if_cfg.u64, 0);
 
 		sc->callback = if_cfg_callback;
 		sc->callback_arg = sc;
-		sc->wait_time = 1000;
+		sc->wait_time = 3000;
 
 		retval = octeon_send_soft_command(octeon_dev, sc);
-		if (retval) {
+		if (retval == IQ_SEND_FAILED) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				"iq/oq config failed status: %x\n",
 				retval);
@@ -3227,6 +3275,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			"interface %d, iqmask %016llx, oqmask %016llx, numiqueues %d, numoqueues %d\n",
 			i, resp->cfg_info.iqmask, resp->cfg_info.oqmask,
 			num_iqueues, num_oqueues);
+
 		netdev = alloc_etherdev_mq(LIO_SIZE, num_iqueues);
 
 		if (!netdev) {
@@ -3234,8 +3283,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			goto setup_nic_dev_fail;
 		}
 
-		props = &octeon_dev->props[i];
-		props->netdev = netdev;
+		SET_NETDEV_DEV(netdev, &octeon_dev->pci_dev->dev);
 
 		if (num_iqueues > 1)
 			lionetdevops.ndo_select_queue = select_q;
@@ -3249,24 +3297,24 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		memset(lio, 0, sizeof(struct lio));
 
-		lio->linfo.ifidx = resp->cfg_info.ifidx;
-		lio->ifidx = resp->cfg_info.ifidx;
+		lio->ifidx = ifidx_or_pfnum;
+
+		props = &octeon_dev->props[i];
+		props->gmxport = resp->cfg_info.linfo.gmxport;
+		props->netdev = netdev;
 
 		lio->linfo.num_rxpciq = num_oqueues;
 		lio->linfo.num_txpciq = num_iqueues;
-		q_mask = resp->cfg_info.oqmask;
-		/* q_mask is 0-based and already verified mask is nonzero */
+
 		for (j = 0; j < num_oqueues; j++) {
-			q_no = __ffs64(q_mask);
-			q_mask &= (~(1UL << q_no));
-			lio->linfo.rxpciq[j] = q_no;
+			lio->linfo.rxpciq[j].u64 =
+				resp->cfg_info.linfo.rxpciq[j].u64;
 		}
-		q_mask = resp->cfg_info.iqmask;
 		for (j = 0; j < num_iqueues; j++) {
-			q_no = __ffs64(q_mask);
-			q_mask &= (~(1UL << q_no));
-			lio->linfo.txpciq[j] = q_no;
+			lio->linfo.txpciq[j].u64 =
+				resp->cfg_info.linfo.txpciq[j].u64;
 		}
+
 		lio->linfo.hw_addr = resp->cfg_info.linfo.hw_addr;
 		lio->linfo.gmxport = resp->cfg_info.linfo.gmxport;
 		lio->linfo.link.u64 = resp->cfg_info.linfo.link.u64;
@@ -3274,14 +3322,15 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		lio->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 		lio->dev_capability = NETIF_F_HIGHDMA
-				      | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-				      | NETIF_F_SG | NETIF_F_RXCSUM
-				      | NETIF_F_TSO | NETIF_F_TSO6
-				      | NETIF_F_LRO;
+			| NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
+			| NETIF_F_SG | NETIF_F_RXCSUM
+			| NETIF_F_GRO
+			| NETIF_F_TSO | NETIF_F_TSO6
+			| NETIF_F_LRO;
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
-		netdev->features = lio->dev_capability;
 		netdev->vlan_features = lio->dev_capability;
+		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
 
 		netdev->hw_features = lio->dev_capability;
 
@@ -3291,12 +3340,13 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		lio->oct_dev = octeon_dev;
 		lio->octprops = props;
 		lio->netdev = netdev;
-		spin_lock_init(&lio->lock);
 
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"if%d gmx: %d hw_addr: 0x%llx\n", i,
 			lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
 
+		base_macaddr = lio->linfo.hw_addr;
+
 		/* 64-bit swap required on LE machines */
 		octeon_swap_8B_data(&lio->linfo.hw_addr, 1);
 		for (j = 0; j < 6; j++)
@@ -3306,23 +3356,22 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		ether_addr_copy(netdev->dev_addr, mac);
 
-		if (setup_io_queues(octeon_dev, netdev)) {
+		/* By default all interfaces on a single Octeon uses the same
+		 * tx and rx queues
+		 */
+		lio->txq = lio->linfo.txpciq[0].s.q_no;
+		lio->rxq = lio->linfo.rxpciq[0].s.q_no;
+		if (setup_io_queues(octeon_dev, i)) {
 			dev_err(&octeon_dev->pci_dev->dev, "I/O queues creation failed\n");
 			goto setup_nic_dev_fail;
 		}
 
 		ifstate_set(lio, LIO_IFSTATE_DROQ_OPS);
 
-		/* By default all interfaces on a single Octeon uses the same
-		 * tx and rx queues
-		 */
-		lio->txq = lio->linfo.txpciq[0];
-		lio->rxq = lio->linfo.rxpciq[0];
-
 		lio->tx_qsize = octeon_get_tx_qsize(octeon_dev, lio->txq);
 		lio->rx_qsize = octeon_get_rx_qsize(octeon_dev, lio->rxq);
 
-		if (setup_glist(lio)) {
+		if (setup_glists(octeon_dev, lio, num_iqueues)) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				"Gather list allocation failed\n");
 			goto setup_nic_dev_fail;
@@ -3330,11 +3379,15 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		/* Register ethtool support */
 		liquidio_set_ethtool_ops(netdev);
+		octeon_dev->priv_flags = 0x0;
 
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE);
+		if (netdev->features & NETIF_F_LRO)
+			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
 		if ((debug != -1) && (debug & NETIF_MSG_HW))
-			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE);
+			liquidio_set_feature(netdev,
+					     OCTNET_CMD_VERBOSE_ENABLE, 0);
 
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
@@ -3346,13 +3399,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			"Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
 			i, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
 		netif_carrier_off(netdev);
-
-		if (lio->linfo.link.s.status) {
-			netif_carrier_on(netdev);
-			start_txq(netdev);
-		} else {
-			netif_carrier_off(netdev);
-		}
+		lio->link_changes++;
 
 		ifstate_set(lio, LIO_IFSTATE_REGISTERED);
 
@@ -3386,7 +3433,7 @@ setup_nic_dev_fail:
 static int liquidio_init_nic_module(struct octeon_device *oct)
 {
 	struct oct_intrmod_cfg *intrmod_cfg;
-	int retval = 0;
+	int i, retval = 0;
 	int num_nic_ports = CFG_GET_NUM_NIC_PORTS(octeon_get_conf(oct));
 
 	dev_dbg(&oct->pci_dev->dev, "Initializing network interfaces\n");
@@ -3400,6 +3447,9 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	memset(oct->props, 0,
 	       sizeof(struct octdev_props) * num_nic_ports);
 
+	for (i = 0; i < MAX_OCTEON_LINKS; i++)
+		oct->props[i].gmxport = -1;
+
 	retval = setup_nic_devices(oct);
 	if (retval) {
 		dev_err(&oct->pci_dev->dev, "Setup NIC devices failed\n");
@@ -3410,15 +3460,19 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 
 	/* Initialize interrupt moderation params */
 	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
-	intrmod_cfg->intrmod_enable = 1;
-	intrmod_cfg->intrmod_check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
-	intrmod_cfg->intrmod_maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
-	intrmod_cfg->intrmod_minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
-	intrmod_cfg->intrmod_maxcnt_trigger = LIO_INTRMOD_MAXCNT_TRIGGER;
-	intrmod_cfg->intrmod_maxtmr_trigger = LIO_INTRMOD_MAXTMR_TRIGGER;
-	intrmod_cfg->intrmod_mintmr_trigger = LIO_INTRMOD_MINTMR_TRIGGER;
-	intrmod_cfg->intrmod_mincnt_trigger = LIO_INTRMOD_MINCNT_TRIGGER;
-
+	intrmod_cfg->rx_enable = 1;
+	intrmod_cfg->check_intrvl =   LIO_INTRMOD_CHECK_INTERVAL;
+	intrmod_cfg->maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
+	intrmod_cfg->minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
+	intrmod_cfg->rx_maxcnt_trigger = LIO_INTRMOD_RXMAXCNT_TRIGGER;
+	intrmod_cfg->rx_maxtmr_trigger = LIO_INTRMOD_RXMAXTMR_TRIGGER;
+	intrmod_cfg->rx_mintmr_trigger = LIO_INTRMOD_RXMINTMR_TRIGGER;
+	intrmod_cfg->rx_mincnt_trigger = LIO_INTRMOD_RXMINCNT_TRIGGER;
+	intrmod_cfg->tx_enable = 1;
+	intrmod_cfg->tx_maxcnt_trigger = LIO_INTRMOD_TXMAXCNT_TRIGGER;
+	intrmod_cfg->tx_mincnt_trigger = LIO_INTRMOD_TXMINCNT_TRIGGER;
+	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
+	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
 
 	return retval;
@@ -3439,8 +3493,10 @@ static void nic_starter(struct work_struct *work)
 {
 	struct octeon_device *oct;
 	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct pci_dev *pdev;
 
 	oct = (struct octeon_device *)wk->ctxptr;
+	pdev = (struct pci_dev *)oct->pci_dev;
 
 	if (atomic_read(&oct->status) == OCT_DEV_RUNNING)
 		return;
@@ -3460,7 +3516,6 @@ static void nic_starter(struct work_struct *work)
 
 	if (oct->app_mode && oct->app_mode == CVM_DRV_NIC_APP) {
 		dev_dbg(&oct->pci_dev->dev, "Starting NIC module\n");
-
 		if (liquidio_init_nic_module(oct))
 			dev_err(&oct->pci_dev->dev, "NIC initialization failed\n");
 		else
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 0ac347c..e4bee85 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -27,15 +27,12 @@
 
 #ifndef __LIQUIDIO_COMMON_H__
 #define __LIQUIDIO_COMMON_H__
-
-#include "octeon_config.h"
-
-#define LIQUIDIO_VERSION        "1.1.9"
-#define LIQUIDIO_MAJOR_VERSION  1
-#define LIQUIDIO_MINOR_VERSION  1
-#define LIQUIDIO_MICRO_VERSION  9
-
+#define LIQUIDIO_BASE_VERSION   "1.4"
+#define LIQUIDIO_MICRO_VERSION  ".1"
+#define LIQUIDIO_PACKAGE ""
+#define LIQUIDIO_VERSION  "1.4.1"
 #define CONTROL_IQ 0
+
 /** Tag types used by Octeon cores in its work. */
 enum octeon_tag_type {
 	ORDERED_TAG = 0,
@@ -96,26 +93,26 @@ enum octeon_tag_type {
  * max, index is wrapped-around to the start.
  */
 #define INCR_INDEX(index, count, max)                \
-do {                                                 \
+{                                                 \
 	if (((index) + (count)) >= (max))            \
 		index = ((index) + (count)) - (max); \
 	else                                         \
 		index += (count);                    \
-} while (0)
+}
 
 #define INCR_INDEX_BY1(index, max)	\
-do {                                    \
+{                                    \
 	if ((++(index)) == (max))       \
 		index = 0;	        \
-} while (0)
+}
 
 #define DECR_INDEX(index, count, max)                  \
-do {						       \
+{						       \
 	if ((count) > (index))                         \
 		index = ((max) - ((count - index)));   \
 	else                                           \
 		index -= count;			       \
-} while (0)
+}
 
 #define OCT_BOARD_NAME 32
 #define OCT_SERIAL_LEN 64
@@ -172,11 +169,12 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 }
 
 /*------------------------- End Scatter/Gather ---------------------------*/
-
 #define   OCTNET_FRM_PTP_HEADER_SIZE  8
-#define   OCTNET_FRM_HEADER_SIZE     30 /* PTP timestamp + VLAN + Ethernet */
 
-#define   OCTNET_MIN_FRM_SIZE        (64  + OCTNET_FRM_PTP_HEADER_SIZE)
+#define   OCTNET_FRM_HEADER_SIZE     22 /* VLAN + Ethernet */
+
+#define   OCTNET_MIN_FRM_SIZE        64
+
 #define   OCTNET_MAX_FRM_SIZE        (16000 + OCTNET_FRM_HEADER_SIZE)
 
 #define   OCTNET_DEFAULT_FRM_SIZE    (1500 + OCTNET_FRM_HEADER_SIZE)
@@ -211,6 +209,16 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_IPSECV2_AH_ESP_CTL 0x13
 #define   OCTNET_CMD_VERBOSE_ENABLE   0x14
 #define   OCTNET_CMD_VERBOSE_DISABLE  0x15
+#define   OCTNET_CMD_ENABLE_VLAN_FILTER 0x16
+#define   OCTNET_CMD_ADD_VLAN_FILTER  0x17
+#define   OCTNET_CMD_DEL_VLAN_FILTER  0x18
+
+#define   OCTNET_CMD_ID_ACTIVE         0x1a
+
+#define   OCTNET_CMD_RXCSUM_ENABLE     0x0
+#define   OCTNET_CMD_RXCSUM_DISABLE    0x1
+#define   OCTNET_CMD_TXCSUM_ENABLE     0x0
+#define   OCTNET_CMD_TXCSUM_DISABLE    0x1
 
 /* RX(packets coming from wire) Checksum verification flags */
 /* TCP/UDP csum */
@@ -258,19 +266,19 @@ union octnet_cmd {
 
 		u64 more:6; /* How many udd words follow the command */
 
-		u64 param1:29;
+		u64 reserved:29;
 
-		u64 param2:16;
+		u64 param1:16;
 
-		u64 param3:8;
+		u64 param2:8;
 
 #else
 
-		u64 param3:8;
+		u64 param2:8;
 
-		u64 param2:16;
+		u64 param1:16;
 
-		u64 param1:29;
+		u64 reserved:29;
 
 		u64 more:6;
 
@@ -284,7 +292,7 @@ union octnet_cmd {
 #define   OCTNET_CMD_SIZE     (sizeof(union octnet_cmd))
 
 /** Instruction Header */
-struct octeon_instr_ih {
+struct octeon_instr_ih2 {
 #ifdef __BIG_ENDIAN_BITFIELD
 	/** Raw mode indicator 1 = RAW */
 	u64 raw:1;
@@ -348,15 +356,15 @@ struct octeon_instr_irh {
 	u64 opcode:4;
 	u64 rflag:1;
 	u64 subcode:7;
-	u64 len:3;
-	u64 rid:13;
-	u64 reserved:4;
+	u64 vlan:12;
+	u64 priority:3;
+	u64 reserved:5;
 	u64 ossp:32;             /* opcode/subcode specific parameters */
 #else
 	u64 ossp:32;             /* opcode/subcode specific parameters */
-	u64 reserved:4;
-	u64 rid:13;
-	u64 len:3;
+	u64 reserved:5;
+	u64 priority:3;
+	u64 vlan:12;
 	u64 subcode:7;
 	u64 rflag:1;
 	u64 opcode:4;
@@ -383,75 +391,77 @@ union octeon_rh {
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
-		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;      /** request id in response to pkt sent by host */
-		u64 reserved:4;
-		u64 ossp:32;     /** opcode/subcode specific parameters */
+		u64 len:3;     /** additional 64-bit words */
+		u64 reserved:17;
+		u64 ossp:32;   /** opcode/subcode specific parameters */
 	} r;
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
-		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;      /** request id in response to pkt sent by host */
-		u64 extra:24;
-		u64 link:8;
+		u64 len:3;     /** additional 64-bit words */
+		u64 extra:28;
+		u64 vlan:12;
+		u64 priority:3;
 		u64 csum_verified:3;     /** checksum verified. */
 		u64 has_hwtstamp:1;      /** Has hardware timestamp. 1 = yes. */
+		u64 encap_on:1;
+		u64 has_hash:1;          /** Has hash (rth or rss). 1 = yes. */
 	} r_dh;
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
-		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;      /** request id in response to pkt sent by host */
+		u64 len:3;     /** additional 64-bit words */
+		u64 reserved:11;
 		u64 num_gmx_ports:8;
-		u64 max_nic_ports:8;
+		u64 max_nic_ports:10;
 		u64 app_cap_flags:4;
-		u64 app_mode:16;
+		u64 app_mode:8;
+		u64 pkind:8;
 	} r_core_drv_init;
 	struct {
 		u64 opcode:4;
 		u64 subcode:8;
 		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;
-		u64 reserved:4;
+		u64 reserved:8;
 		u64 extra:25;
-		u64 ifidx:7;
+		u64 gmxport:16;
 	} r_nic_info;
 #else
 	u64 u64;
 	struct {
 		u64 ossp:32;  /** opcode/subcode specific parameters */
-		u64 reserved:4;
-		u64 rid:13;   /** req id in response to pkt sent by host */
+		u64 reserved:17;
 		u64 len:3;    /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
 	} r;
 	struct {
+		u64 has_hash:1;          /** Has hash (rth or rss). 1 = yes. */
+		u64 encap_on:1;
 		u64 has_hwtstamp:1;      /** 1 = has hwtstamp */
 		u64 csum_verified:3;     /** checksum verified. */
-		u64 link:8;
-		u64 extra:24;
-		u64 rid:13;   /** req id in response to pkt sent by host */
+		u64 priority:3;
+		u64 vlan:12;
+		u64 extra:28;
 		u64 len:3;    /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
 	} r_dh;
 	struct {
-		u64 app_mode:16;
+		u64 pkind:8;
+		u64 app_mode:8;
 		u64 app_cap_flags:4;
-		u64 max_nic_ports:8;
+		u64 max_nic_ports:10;
 		u64 num_gmx_ports:8;
-		u64 rid:13;
+		u64 reserved:11;
 		u64 len:3;       /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
 	} r_core_drv_init;
 	struct {
-		u64 ifidx:7;
+		u64 gmxport:16;
 		u64 extra:25;
-		u64 reserved:4;
-		u64 rid:13;
+		u64 reserved:8;
 		u64 len:3;       /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
@@ -461,30 +471,25 @@ union octeon_rh {
 
 #define  OCT_RH_SIZE   (sizeof(union  octeon_rh))
 
-#define OCT_PKT_PARAM_IPV4OPTS   1
-#define OCT_PKT_PARAM_IPV6EXTHDR 2
-
 union octnic_packet_params {
 	u32 u32;
 	struct {
 #ifdef __BIG_ENDIAN_BITFIELD
-		u32 reserved:6;
+		u32 reserved:24;
+		u32 ip_csum:1;		/* Perform IP header checksum(s) */
+		/* Perform Outer transport header checksum */
+		u32 transport_csum:1;
+		/* Find tunnel, and perform transport csum. */
 		u32 tnl_csum:1;
-		u32 ip_csum:1;
-		u32 ipv4opts_ipv6exthdr:2;
-		u32 ipsec_ops:4;
-		u32 tsflag:1;
-		u32 csoffset:9;
-		u32 ifidx:8;
+		u32 tsflag:1;		/* Timestamp this packet */
+		u32 ipsec_ops:4;	/* IPsec operation */
 #else
-		u32 ifidx:8;
-		u32 csoffset:9;
-		u32 tsflag:1;
 		u32 ipsec_ops:4;
-		u32 ipv4opts_ipv6exthdr:2;
-		u32 ip_csum:1;
+		u32 tsflag:1;
 		u32 tnl_csum:1;
-		u32 reserved:6;
+		u32 transport_csum:1;
+		u32 ip_csum:1;
+		u32 reserved:7;
 #endif
 	} s;
 };
@@ -496,56 +501,96 @@ union oct_link_status {
 	struct {
 #ifdef __BIG_ENDIAN_BITFIELD
 		u64 duplex:8;
-		u64 status:8;
 		u64 mtu:16;
 		u64 speed:16;
+		u64 link_up:1;
 		u64 autoneg:1;
-		u64 interface:4;
+		u64 if_mode:5;
 		u64 pause:1;
-		u64 reserved:10;
+		u64 flashing:1;
+		u64 reserved:15;
 #else
-		u64 reserved:10;
+		u64 reserved:15;
+		u64 flashing:1;
 		u64 pause:1;
-		u64 interface:4;
+		u64 if_mode:5;
 		u64 autoneg:1;
+		u64 link_up:1;
 		u64 speed:16;
 		u64 mtu:16;
-		u64 status:8;
 		u64 duplex:8;
 #endif
 	} s;
 };
 
+/** The txpciq info passed to host from the firmware */
+
+union oct_txpciq {
+	u64 u64;
+
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 q_no:8;
+		u64 port:8;
+		u64 pkind:6;
+		u64 use_qpg:1;
+		u64 qpg:11;
+		u64 reserved:30;
+#else
+		u64 reserved:30;
+		u64 qpg:11;
+		u64 use_qpg:1;
+		u64 pkind:6;
+		u64 port:8;
+		u64 q_no:8;
+#endif
+	} s;
+};
+
+/** The txpciq info passed to host from the firmware */
+
+union oct_rxpciq {
+	u64 u64;
+
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 q_no:8;
+		u64 reserved:56;
+#else
+		u64 reserved:56;
+		u64 q_no:8;
+#endif
+	} s;
+};
+
 /** Information for a OCTEON ethernet interface shared between core & host. */
 struct oct_link_info {
 	union oct_link_status link;
 	u64 hw_addr;
 
 #ifdef __BIG_ENDIAN_BITFIELD
-	u16 gmxport;
-	u8 rsvd[3];
-	u8 num_txpciq;
-	u8 num_rxpciq;
-	u8 ifidx;
+	u64 gmxport:16;
+	u64 rsvd:32;
+	u64 num_txpciq:8;
+	u64 num_rxpciq:8;
 #else
-	u8 ifidx;
-	u8 num_rxpciq;
-	u8 num_txpciq;
-	u8 rsvd[3];
-	u16 gmxport;
+	u64 num_rxpciq:8;
+	u64 num_txpciq:8;
+	u64 rsvd:32;
+	u64 gmxport:16;
 #endif
 
-	u8 txpciq[MAX_IOQS_PER_NICIF];
-	u8 rxpciq[MAX_IOQS_PER_NICIF];
+	union oct_txpciq txpciq[MAX_IOQS_PER_NICIF];
+	union oct_rxpciq rxpciq[MAX_IOQS_PER_NICIF];
 };
 
 #define OCT_LINK_INFO_SIZE   (sizeof(struct oct_link_info))
 
 struct liquidio_if_cfg_info {
-	u64 ifidx;
 	u64 iqmask; /** mask for IQs enabled for  the port */
 	u64 oqmask; /** mask for OQs enabled for the port */
 	struct oct_link_info linfo; /** initial link information */
+	char   liquidio_firmware_version[32];
 };
 
 /** Stats for each NIC port in RX direction. */
@@ -570,10 +615,16 @@ struct nic_rx_stats {
 	u64 fw_err_pko;
 	u64 fw_err_link;
 	u64 fw_err_drop;
+
+	/* LRO */
 	u64 fw_lro_pkts;   /* Number of packets that are LROed      */
 	u64 fw_lro_octs;   /* Number of octets that are LROed       */
 	u64 fw_total_lro;  /* Number of LRO packets formed          */
 	u64 fw_lro_aborts; /* Number of times lRO of packet aborted */
+	u64 fw_lro_aborts_port;
+	u64 fw_lro_aborts_seq;
+	u64 fw_lro_aborts_tsval;
+	u64 fw_lro_aborts_timer;
 	/* intrmod: packet forward rate */
 	u64 fwd_rate;
 };
@@ -597,9 +648,13 @@ struct nic_tx_stats {
 	/* firmware stats */
 	u64 fw_total_sent;
 	u64 fw_total_fwd;
+	u64 fw_total_fwd_bytes;
 	u64 fw_err_pko;
 	u64 fw_err_link;
 	u64 fw_err_drop;
+	u64 fw_err_tso;
+	u64 fw_tso;		/* number of tso requests */
+	u64 fw_tso_fwd;		/* number of packets segmented in tso */
 };
 
 struct oct_link_stats {
@@ -630,23 +685,44 @@ struct oct_mdio_cmd {
 
 #define OCT_LINK_STATS_SIZE   (sizeof(struct oct_link_stats))
 
+/* intrmod: max. packet rate threshold */
+#define LIO_INTRMOD_MAXPKT_RATETHR	196608
+/* intrmod: min. packet rate threshold */
+#define LIO_INTRMOD_MINPKT_RATETHR	9216
+/* intrmod: max. packets to trigger interrupt */
+#define LIO_INTRMOD_RXMAXCNT_TRIGGER	384
+/* intrmod: min. packets to trigger interrupt */
+#define LIO_INTRMOD_RXMINCNT_TRIGGER	0
+/* intrmod: max. time to trigger interrupt */
+#define LIO_INTRMOD_RXMAXTMR_TRIGGER	128
+/* 66xx:intrmod: min. time to trigger interrupt
+ * (value of 1 is optimum for TCP_RR)
+ */
+#define LIO_INTRMOD_RXMINTMR_TRIGGER	1
+
+/* intrmod: max. packets to trigger interrupt */
+#define LIO_INTRMOD_TXMAXCNT_TRIGGER	64
+/* intrmod: min. packets to trigger interrupt */
+#define LIO_INTRMOD_TXMINCNT_TRIGGER	0
+
+/* intrmod: poll interval in seconds */
 #define LIO_INTRMOD_CHECK_INTERVAL  1
-#define LIO_INTRMOD_MAXPKT_RATETHR  196608 /* max pkt rate threshold */
-#define LIO_INTRMOD_MINPKT_RATETHR  9216   /* min pkt rate threshold */
-#define LIO_INTRMOD_MAXCNT_TRIGGER  384    /* max pkts to trigger interrupt */
-#define LIO_INTRMOD_MINCNT_TRIGGER  1      /* min pkts to trigger interrupt */
-#define LIO_INTRMOD_MAXTMR_TRIGGER  128    /* max time to trigger interrupt */
-#define LIO_INTRMOD_MINTMR_TRIGGER  32     /* min time to trigger interrupt */
 
 struct oct_intrmod_cfg {
-	u64 intrmod_enable;
-	u64 intrmod_check_intrvl;
-	u64 intrmod_maxpkt_ratethr;
-	u64 intrmod_minpkt_ratethr;
-	u64 intrmod_maxcnt_trigger;
-	u64 intrmod_maxtmr_trigger;
-	u64 intrmod_mincnt_trigger;
-	u64 intrmod_mintmr_trigger;
+	u64 rx_enable;
+	u64 tx_enable;
+	u64 check_intrvl;
+	u64 maxpkt_ratethr;
+	u64 minpkt_ratethr;
+	u64 rx_maxcnt_trigger;
+	u64 rx_mincnt_trigger;
+	u64 rx_maxtmr_trigger;
+	u64 rx_mintmr_trigger;
+	u64 tx_mincnt_trigger;
+	u64 tx_maxcnt_trigger;
+	u64 rx_frames;
+	u64 tx_frames;
+	u64 rx_usecs;
 };
 
 #define BASE_QUEUE_NOT_REQUESTED 65535
@@ -659,9 +735,9 @@ union oct_nic_if_cfg {
 		u64 num_iqueues:16;
 		u64 num_oqueues:16;
 		u64 gmx_port_id:8;
-		u64 reserved:8;
+		u64 vf_id:8;
 #else
-		u64 reserved:8;
+		u64 vf_id:8;
 		u64 gmx_port_id:8;
 		u64 num_oqueues:16;
 		u64 num_iqueues:16;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 62a8dd5..8906c2c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -37,10 +37,11 @@
 /* Maximum octeon devices defined as MAX_OCTEON_NICIF to support
  * multiple(<= MAX_OCTEON_NICIF) Miniports
  */
-#define   MAX_OCTEON_NICIF             32
+#define   MAX_OCTEON_NICIF             128
 #define   MAX_OCTEON_DEVICES           MAX_OCTEON_NICIF
 #define   MAX_OCTEON_LINKS	       MAX_OCTEON_NICIF
 #define   MAX_OCTEON_MULTICAST_ADDR    32
+#define   MAX_OCTEON_UNICAST_ADDR      32
 
 /* CN6xxx IQ configuration macros */
 #define   CN6XXX_MAX_INPUT_QUEUES      32
@@ -92,6 +93,9 @@
 #define CFG_GET_IQ_DB_MIN(cfg)                   ((cfg)->iq.db_min)
 #define CFG_GET_IQ_DB_TIMEOUT(cfg)               ((cfg)->iq.db_timeout)
 
+#define CFG_GET_IQ_INTR_PKT(cfg)               ((cfg)->iq.iq_intr_pkt)
+#define CFG_SET_IQ_INTR_PKT(cfg, val)            (cfg)->iq.iq_intr_pkt = val
+
 #define CFG_GET_OQ_MAX_Q(cfg)                    ((cfg)->oq.max_oqs)
 #define CFG_GET_OQ_INFO_PTR(cfg)                 ((cfg)->oq.info_ptr)
 #define CFG_GET_OQ_PKTS_PER_INTR(cfg)            ((cfg)->oq.pkts_per_intr)
@@ -135,7 +139,7 @@
 #define CFG_GET_IS_SLI_BP_ON(cfg)                ((cfg)->misc.enable_sli_oq_bp)
 
 /* Max IOQs per OCTEON Link */
-#define MAX_IOQS_PER_NICIF              32
+#define MAX_IOQS_PER_NICIF              64
 
 enum lio_card_type {
 	LIO_210SV = 0, /* Two port, 66xx */
@@ -226,7 +230,7 @@ struct octeon_oq_config {
 	 */
 	u64 refill_threshold:16;
 
-	/** If set, the Output queue uses info-pointer mode. (Default: 1 ) */
+	/** If set, the Output queue uses info-pointer mode. (Default: 1) */
 	u64 info_ptr:32;
 
 	/* Max number of OQs available */
@@ -236,7 +240,7 @@ struct octeon_oq_config {
 	/* Max number of OQs available */
 	u64 max_oqs:8;
 
-	/** If set, the Output queue uses info-pointer mode. (Default: 1 ) */
+	/** If set, the Output queue uses info-pointer mode. (Default: 1) */
 	u64 info_ptr:32;
 
 	/** The number of buffers that were consumed during packet processing by
@@ -416,9 +420,11 @@ struct octeon_config {
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
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 466147e..9c21f95 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -170,8 +170,8 @@ struct octeon_pci_console_desc {
 				offsetof(struct cvmx_bootmem_desc, field),   \
 				SIZEOF_FIELD(struct cvmx_bootmem_desc, field))
 
-#define __cvmx_bootmem_lock(flags)
-#define __cvmx_bootmem_unlock(flags)
+#define __cvmx_bootmem_lock(flags)	(flags = flags)
+#define __cvmx_bootmem_unlock(flags)	(flags = flags)
 
 /**
  * This macro returns a member of the
@@ -234,7 +234,7 @@ static void CVMX_BOOTMEM_NAMED_GET_NAME(struct octeon_device *oct,
 					u32 len)
 {
 	addr += offsetof(struct cvmx_bootmem_named_block_desc, name);
-	octeon_pci_read_core_mem(oct, addr, str, len);
+	octeon_pci_read_core_mem(oct, addr, (u8 *)str, len);
 	str[len] = 0;
 }
 
@@ -323,6 +323,9 @@ static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 			if (name && named_size) {
 				char *name_tmp =
 					kmalloc(name_length + 1, GFP_KERNEL);
+				if (!name_tmp)
+					break;
+
 				CVMX_BOOTMEM_NAMED_GET_NAME(oct, named_addr,
 							    name_tmp,
 							    name_length);
@@ -383,7 +386,7 @@ static void octeon_remote_unlock(void)
 int octeon_console_send_cmd(struct octeon_device *oct, char *cmd_str,
 			    u32 wait_hundredths)
 {
-	u32 len = strlen(cmd_str);
+	u32 len = (u32)strlen(cmd_str);
 
 	dev_dbg(&oct->pci_dev->dev, "sending \"%s\" to bootloader\n", cmd_str);
 
@@ -440,8 +443,7 @@ int octeon_wait_for_bootloader(struct octeon_device *oct,
 }
 
 static void octeon_console_handle_result(struct octeon_device *oct,
-					 size_t console_num,
-					 char *buffer, s32 bytes_read)
+					 size_t console_num)
 {
 	struct octeon_console *console;
 
@@ -492,7 +494,7 @@ static void check_console(struct work_struct *work)
 	struct octeon_console *console;
 	struct cavium_wk *wk = (struct cavium_wk *)work;
 	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
-	size_t console_num = wk->ctxul;
+	u32 console_num = (u32)wk->ctxul;
 	u32 delay;
 
 	console = &oct->console[console_num];
@@ -505,20 +507,17 @@ static void check_console(struct work_struct *work)
 		 */
 		bytes_read =
 			octeon_console_read(oct, console_num, console_buffer,
-					    sizeof(console_buffer) - 1, 0);
+					    sizeof(console_buffer) - 1);
 		if (bytes_read > 0) {
 			total_read += bytes_read;
-			if (console->waiting) {
-				octeon_console_handle_result(oct, console_num,
-							     console_buffer,
-							     bytes_read);
-			}
+			if (console->waiting)
+				octeon_console_handle_result(oct, console_num);
 			if (octeon_console_debug_enabled(console_num)) {
 				output_console_line(oct, console, console_num,
 						    console_buffer, bytes_read);
 			}
 		} else if (bytes_read < 0) {
-			dev_err(&oct->pci_dev->dev, "Error reading console %lu, ret=%d\n",
+			dev_err(&oct->pci_dev->dev, "Error reading console %u, ret=%d\n",
 				console_num, bytes_read);
 		}
 
@@ -530,7 +529,7 @@ static void check_console(struct work_struct *work)
 	 */
 	if (octeon_console_debug_enabled(console_num) &&
 	    (total_read == 0) && (console->leftover[0])) {
-		dev_info(&oct->pci_dev->dev, "%lu: %s\n",
+		dev_info(&oct->pci_dev->dev, "%u: %s\n",
 			 console_num, console->leftover);
 		console->leftover[0] = '\0';
 	}
@@ -676,7 +675,7 @@ static inline int octeon_console_avail_bytes(u32 buffer_size,
 }
 
 int octeon_console_read(struct octeon_device *oct, u32 console_num,
-			char *buffer, u32 buf_size, u32 flags)
+			char *buffer, u32 buf_size)
 {
 	int bytes_to_read;
 	u32 rd_idx, wr_idx;
@@ -712,7 +711,7 @@ int octeon_console_read(struct octeon_device *oct, u32 console_num,
 		bytes_to_read = console->buffer_size - rd_idx;
 
 	octeon_pci_read_core_mem(oct, console->output_base_addr + rd_idx,
-				 buffer, bytes_to_read);
+				 (u8 *)buffer, bytes_to_read);
 	octeon_write_device_mem32(oct, console->addr +
 				  offsetof(struct octeon_pci_console,
 					   output_read_index),
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index f67641a..e41aa4a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -449,10 +449,10 @@ static struct octeon_config_ptr {
 };
 
 static char oct_dev_state_str[OCT_DEV_STATES + 1][32] = {
-	"BEGIN",	"PCI-MAP-DONE",	      "DISPATCH-INIT-DONE",
+	"BEGIN", "PCI-MAP-DONE", "DISPATCH-INIT-DONE",
 	"IQ-INIT-DONE", "SCBUFF-POOL-INIT-DONE", "RESPLIST-INIT-DONE",
 	"DROQ-INIT-DONE", "IO-QUEUES-INIT-DONE", "CONSOLE-INIT-DONE",
-	"HOST-READY",	"CORE-READY",	      "RUNNING",	   "IN-RESET",
+	"HOST-READY", "CORE-READY", "RUNNING", "IN-RESET",
 	"INVALID"
 };
 
@@ -550,17 +550,19 @@ static char *get_oct_app_string(u32 app_mode)
 	return oct_dev_app_str[CVM_DRV_INVALID_APP - CVM_DRV_APP_START];
 }
 
+u8 fbuf[4 * 1024 * 1024];
+
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			     size_t size)
 {
 	int ret = 0;
-	u8 *p;
-	u8 *buffer;
+	u8 *p = fbuf;
 	u32 crc32_result;
 	u64 load_addr;
 	u32 image_len;
 	struct octeon_firmware_file_header *h;
-	u32 i;
+	u32 i, rem, base_len = strlen(LIQUIDIO_BASE_VERSION);
+	char *base;
 
 	if (size < sizeof(struct octeon_firmware_file_header)) {
 		dev_err(&oct->pci_dev->dev, "Firmware file too small (%d < %d).\n",
@@ -576,19 +578,26 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 		return -EINVAL;
 	}
 
-	crc32_result =
-		crc32(~0, data,
-		      sizeof(struct octeon_firmware_file_header) -
-		      sizeof(u32)) ^ ~0U;
+	crc32_result = crc32((unsigned int)~0, data,
+			     sizeof(struct octeon_firmware_file_header) -
+			     sizeof(u32)) ^ ~0U;
 	if (crc32_result != be32_to_cpu(h->crc32)) {
 		dev_err(&oct->pci_dev->dev, "Firmware CRC mismatch (0x%08x != 0x%08x).\n",
 			crc32_result, be32_to_cpu(h->crc32));
 		return -EINVAL;
 	}
 
-	if (memcmp(LIQUIDIO_VERSION, h->version, strlen(LIQUIDIO_VERSION))) {
-		dev_err(&oct->pci_dev->dev, "Unmatched firmware version. Expected %s, got %s.\n",
-			LIQUIDIO_VERSION, h->version);
+	if (strncmp(LIQUIDIO_PACKAGE, h->version, strlen(LIQUIDIO_PACKAGE))) {
+		dev_err(&oct->pci_dev->dev, "Unmatched firmware package type. Expected %s, got %s.\n",
+			LIQUIDIO_PACKAGE, h->version);
+		return -EINVAL;
+	}
+
+	base = h->version + strlen(LIQUIDIO_PACKAGE);
+	ret = memcmp(LIQUIDIO_BASE_VERSION, base, base_len);
+	if (ret) {
+		dev_err(&oct->pci_dev->dev, "Unmatched firmware version. Expected %s.x, got %s.\n",
+			LIQUIDIO_BASE_VERSION, base);
 		return -EINVAL;
 	}
 
@@ -602,60 +611,59 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 	snprintf(oct->fw_info.liquidio_firmware_version, 32, "LIQUIDIO: %s",
 		 h->version);
 
-	buffer = kmalloc(size, GFP_KERNEL);
-	if (!buffer)
-		return -ENOMEM;
-
-	memcpy(buffer, data, size);
-
-	p = buffer + sizeof(struct octeon_firmware_file_header);
+	data += sizeof(struct octeon_firmware_file_header);
 
+	dev_info(&oct->pci_dev->dev, "%s: Loading %d images\n", __func__,
+		 be32_to_cpu(h->num_images));
 	/* load all images */
 	for (i = 0; i < be32_to_cpu(h->num_images); i++) {
 		load_addr = be64_to_cpu(h->desc[i].addr);
 		image_len = be32_to_cpu(h->desc[i].len);
 
-		/* validate the image */
-		crc32_result = crc32(~0, p, image_len) ^ ~0U;
-		if (crc32_result != be32_to_cpu(h->desc[i].crc32)) {
-			dev_err(&oct->pci_dev->dev,
-				"Firmware CRC mismatch in image %d (0x%08x != 0x%08x).\n",
-				i, crc32_result,
-				be32_to_cpu(h->desc[i].crc32));
-			ret = -EINVAL;
-			goto done_downloading;
-		}
+		dev_info(&oct->pci_dev->dev, "Loading firmware %d at %llx\n",
+			 image_len, load_addr);
 
-		/* download the image */
-		octeon_pci_write_core_mem(oct, load_addr, p, image_len);
+		/* Write in 4MB chunks*/
+		rem = image_len;
 
-		p += image_len;
-		dev_dbg(&oct->pci_dev->dev,
-			"Downloaded image %d (%d bytes) to address 0x%016llx\n",
-			i, image_len, load_addr);
+		while (rem) {
+			if (rem < (4 * 1024 * 1024))
+				size = rem;
+			else
+				size = 4 * 1024 * 1024;
+
+			memcpy(p, data, size);
+
+			/* download the image */
+			octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
+
+			data += size;
+			rem -= (u32)size;
+			load_addr += size;
+		}
 	}
+	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
+		 h->bootcmd);
 
 	/* Invoke the bootcmd */
 	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
 
-done_downloading:
-	kfree(buffer);
-
-	return ret;
+	return 0;
 }
 
 void octeon_free_device_mem(struct octeon_device *oct)
 {
-	u32 i;
+	int i;
 
-	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES; i++) {
-		/* could check  mask as well */
-		vfree(oct->droq[i]);
+	for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+		if ((oct->io_qmask.oq & (1ULL << i)) &&
+		    (oct->droq[i]))
+			vfree(oct->droq[i]);
 	}
-
-	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-		/* could check mask as well */
-		vfree(oct->instr_queue[i]);
+	for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+		if ((oct->io_qmask.iq & (1ULL << i)) &&
+		    (oct->instr_queue[i]))
+			vfree(oct->instr_queue[i]);
 	}
 
 	i = oct->octeon_id;
@@ -677,7 +685,6 @@ static struct octeon_device *octeon_allocate_device_mem(u32 pci_id,
 	case OCTEON_CN66XX:
 		configsize = sizeof(struct octeon_cn6xxx);
 		break;
-
 	default:
 		pr_err("%s: Unknown PCI Device: 0x%x\n",
 		       __func__,
@@ -737,55 +744,65 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 	octeon_device[oct_idx] = oct;
 
 	oct->octeon_id = oct_idx;
-	snprintf((oct->device_name), sizeof(oct->device_name),
+	snprintf(oct->device_name, sizeof(oct->device_name),
 		 "LiquidIO%d", (oct->octeon_id));
 
 	return oct;
 }
 
+/* this function is only for setting up the first queue */
 int octeon_setup_instr_queues(struct octeon_device *oct)
 {
-	u32 i, num_iqs = 0;
+	u32 num_iqs = 0;
 	u32 num_descs = 0;
+	u32 iq_no = 0;
+	union oct_txpciq txpciq;
+	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
+	num_iqs = 1;
 	/* this causes queue 0 to be default queue */
-	if (OCTEON_CN6XXX(oct)) {
-		num_iqs = 1;
+	if (OCTEON_CN6XXX(oct))
 		num_descs =
 			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
-	}
 
 	oct->num_iqs = 0;
 
-	for (i = 0; i < num_iqs; i++) {
-		oct->instr_queue[i] =
+	oct->instr_queue[0] = vmalloc_node(sizeof(*oct->instr_queue[0]),
+				numa_node);
+	if (!oct->instr_queue[0])
+		oct->instr_queue[0] =
 			vmalloc(sizeof(struct octeon_instr_queue));
-		if (!oct->instr_queue[i])
-			return 1;
-
-		memset(oct->instr_queue[i], 0,
-		       sizeof(struct octeon_instr_queue));
-
-		oct->instr_queue[i]->app_ctx = (void *)(size_t)i;
-		if (octeon_init_instr_queue(oct, i, num_descs))
-			return 1;
-
-		oct->num_iqs++;
+	if (!oct->instr_queue[0])
+		return 1;
+	memset(oct->instr_queue[0], 0, sizeof(struct octeon_instr_queue));
+	oct->instr_queue[0]->q_index = 0;
+	oct->instr_queue[0]->app_ctx = (void *)(size_t)0;
+	oct->instr_queue[0]->ifidx = 0;
+	txpciq.u64 = 0;
+	txpciq.s.q_no = iq_no;
+	txpciq.s.use_qpg = 0;
+	txpciq.s.qpg = 0;
+	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
+		/* prevent memory leak */
+		vfree(oct->instr_queue[0]);
+		return 1;
 	}
 
+	oct->num_iqs++;
 	return 0;
 }
 
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
@@ -793,19 +810,15 @@ int octeon_setup_output_queues(struct octeon_device *oct)
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
@@ -1151,20 +1164,20 @@ core_drv_init_err:
 	return 0;
 }
 
-int octeon_get_tx_qsize(struct octeon_device *oct, u32 q_no)
+int octeon_get_tx_qsize(struct octeon_device *oct, int q_no)
 
 {
-	if (oct && (q_no < MAX_OCTEON_INSTR_QUEUES) &&
-	    (oct->io_qmask.iq & (1UL << q_no)))
+	if (oct && (q_no < MAX_OCTEON_INSTR_QUEUES(oct)) &&
+	    (oct->io_qmask.iq & (1ULL << q_no)))
 		return oct->instr_queue[q_no]->max_count;
 
 	return -1;
 }
 
-int octeon_get_rx_qsize(struct octeon_device *oct, u32 q_no)
+int octeon_get_rx_qsize(struct octeon_device *oct, int q_no)
 {
-	if (oct && (q_no < MAX_OCTEON_OUTPUT_QUEUES) &&
-	    (oct->io_qmask.oq & (1UL << q_no)))
+	if (oct && (q_no < MAX_OCTEON_OUTPUT_QUEUES(oct)) &&
+	    (oct->io_qmask.oq & (1ULL << q_no)))
 		return oct->droq[q_no]->max_count;
 	return -1;
 }
@@ -1255,10 +1268,10 @@ void lio_pci_writeq(struct octeon_device *oct,
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
@@ -1272,9 +1285,6 @@ int octeon_wait_for_ddr_init(struct octeon_device *oct, u32 *timeout)
 	if (!timeout)
 		return ret;
 
-	while (*timeout == 0)
-		schedule_timeout_uninterruptible(HZ / 10);
-
 	for (ms = 0; (ret != 0) && ((*timeout == 0) || (ms <= *timeout));
 	     ms += HZ / 10) {
 		ret = octeon_mem_access_ok(oct);
@@ -1302,3 +1312,33 @@ int lio_get_device_id(void *dev)
 			return octeon_dev->octeon_id;
 	return -1;
 }
+
+void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
+{
+	u16 chip_id = 0;
+
+	if (!droq && !iq)
+		return;
+
+	if (droq)
+		chip_id = droq->oct_dev->chip_id;
+	else if (iq)
+		chip_id = iq->oct_dev->chip_id;
+
+	/* the whole thing needs to be atomic, ideally */
+	if ((chip_id !=  OCTEON_CN66XX) &&
+	    (chip_id !=  OCTEON_CN68XX)) {
+		if (droq) {
+			spin_lock_bh(&droq->lock);
+			writel(droq->pkt_count, droq->pkts_sent_reg);
+			droq->pkt_count = 0;
+			spin_unlock_bh(&droq->lock);
+		}
+		if (iq) {
+			spin_lock_bh(&iq->lock);
+			writel(iq->pkt_in_done, iq->inst_cnt_reg);
+			iq->pkt_in_done = 0;
+			spin_unlock_bh(&iq->lock);
+		}
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 36e1f85..b58b24c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -46,6 +46,8 @@ enum octeon_pci_swap_mode {
 	OCTEON_PCI_32BIT_LW_SWAP = 3
 };
 
+#define  OCTEON_ALL_INTR      0xff
+
 /*---------------   PCI BAR1 index registers -------------*/
 
 /* BAR1 Mask */
@@ -152,9 +154,9 @@ struct octeon_mmio {
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
@@ -204,14 +206,13 @@ struct octeon_fn_list {
 	void (*bar1_idx_setup)(struct octeon_device *, u64, u32, int);
 	void (*bar1_idx_write)(struct octeon_device *, u32, u32);
 	u32 (*bar1_idx_read)(struct octeon_device *, u32);
-	u32 (*update_iq_read_idx)(struct octeon_device *,
-				  struct octeon_instr_queue *);
+	u32 (*update_iq_read_idx)(struct octeon_instr_queue *);
 
 	void (*enable_oq_pkt_time_intr)(struct octeon_device *, u32);
 	void (*disable_oq_pkt_time_intr)(struct octeon_device *, u32);
 
-	void (*enable_interrupt)(void *);
-	void (*disable_interrupt)(void *);
+	void (*enable_interrupt)(struct octeon_device *, u8);
+	void (*disable_interrupt)(struct octeon_device *, u8);
 
 	void (*enable_io_queues)(struct octeon_device *);
 	void (*disable_io_queues)(struct octeon_device *);
@@ -222,7 +223,7 @@ struct octeon_fn_list {
 
 /* Structure for named memory blocks
  * Number of descriptors
- * available can be changed without affecting compatiblity,
+ * available can be changed without affecting compatibility,
  * but name length changes require a bump in the bootmem
  * descriptor version
  * Note: This structure must be naturally 64 bit aligned, as a single
@@ -255,7 +256,7 @@ struct oct_fw_info {
 struct cavium_wk {
 	struct delayed_work work;
 	void *ctxptr;
-	size_t ctxul;
+	u64 ctxul;
 };
 
 struct cavium_wq {
@@ -267,6 +268,7 @@ struct octdev_props {
 	/* Each interface in the Octeon device has a network
 	 * device pointer (used for OS specific calls).
 	 */
+	int    gmxport;
 	struct net_device *netdev;
 };
 
@@ -324,7 +326,8 @@ struct octeon_device {
 	struct octeon_sc_buffer_pool	sc_buf_pool;
 
 	/** The input instruction queues */
-	struct octeon_instr_queue *instr_queue[MAX_OCTEON_INSTR_QUEUES];
+	struct octeon_instr_queue *instr_queue
+		[MAX_POSSIBLE_OCTEON_INSTR_QUEUES];
 
 	/** The doubly-linked list of instruction response */
 	struct octeon_response_list response_list[MAX_RESPONSE_LISTS];
@@ -332,7 +335,7 @@ struct octeon_device {
 	u32 num_oqs;
 
 	/** The DROQ output queues  */
-	struct octeon_droq *droq[MAX_OCTEON_OUTPUT_QUEUES];
+	struct octeon_droq *droq[MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES];
 
 	struct octeon_io_enable io_qmask;
 
@@ -381,15 +384,29 @@ struct octeon_device {
 
 	struct cavium_wq dma_comp_wq;
 
-	struct cavium_wq check_db_wq[MAX_OCTEON_INSTR_QUEUES];
+	/** Lock for dma response list */
+	spinlock_t cmd_resp_wqlock;
+	u32 cmd_resp_state;
+
+	struct cavium_wq check_db_wq[MAX_POSSIBLE_OCTEON_INSTR_QUEUES];
 
 	struct cavium_wk nic_poll_work;
 
 	struct cavium_wk console_poll_work[MAX_OCTEON_MAPS];
 
 	void *priv;
+
+	int rx_pause;
+	int tx_pause;
+
+	struct oct_link_stats link_stats; /*stastics from firmware*/
+
+	/* private flags to control driver-specific features through ethtool */
+	u32 priv_flags;
 };
 
+#define  OCT_DRV_ONLINE 1
+#define  OCT_DRV_OFFLINE 2
 #define  OCTEON_CN6XXX(oct)           ((oct->chip_id == OCTEON_CN66XX) || \
 				       (oct->chip_id == OCTEON_CN68XX))
 #define CHIP_FIELD(oct, TYPE, field)             \
@@ -570,7 +587,7 @@ int octeon_console_write(struct octeon_device *oct, u32 console_num,
 			 char *buffer, u32 write_request_size, u32 flags);
 int octeon_console_write_avail(struct octeon_device *oct, u32 console_num);
 int octeon_console_read(struct octeon_device *oct, u32 console_num,
-			char *buffer, u32 buf_size, u32 flags);
+			char *buffer, u32 buf_size);
 int octeon_console_read_avail(struct octeon_device *oct, u32 console_num);
 
 /** Removes all attached consoles. */
@@ -617,9 +634,9 @@ int octeon_setup_instr_queues(struct octeon_device *oct);
  */
 int octeon_setup_output_queues(struct octeon_device *oct);
 
-int octeon_get_tx_qsize(struct octeon_device *oct, u32 q_no);
+int octeon_get_tx_qsize(struct octeon_device *oct, int q_no);
 
-int octeon_get_rx_qsize(struct octeon_device *oct, u32 q_no);
+int octeon_get_rx_qsize(struct octeon_device *oct, int q_no);
 
 /** Turns off the input and output queues for the device
  *  @param oct which octeon to disable
@@ -646,4 +663,26 @@ void *oct_get_config_info(struct octeon_device *oct, u16 card_type);
  */
 struct octeon_config *octeon_get_conf(struct octeon_device *oct);
 
+void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq);
+
+/* LiquidIO driver pivate flags */
+enum {
+	OCT_PRIV_FLAG_TX_BYTES = 0, /* Tx interrupts by pending byte count */
+};
+
+#define OCT_PRIV_FLAG_DEFAULT 0x0
+
+static inline u32 lio_get_priv_flag(struct octeon_device *octdev, u32 flag)
+{
+	return !!(octdev->priv_flags & (0x1 << flag));
+}
+
+static inline void lio_set_priv_flag(struct octeon_device *octdev, u32 flag,
+				     u32 val)
+{
+	if (val)
+		octdev->priv_flags |= (0x1 << flag);
+	else
+		octdev->priv_flags &= ~(0x1 << flag);
+}
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 174072b..4488690 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -42,8 +42,6 @@
 #include "liquidio_image.h"
 #include "octeon_mem_ops.h"
 
-/* #define CAVIUM_ONLY_PERF_MODE */
-
 #define     CVM_MIN(d1, d2)           (((d1) < (d2)) ? (d1) : (d2))
 #define     CVM_MAX(d1, d2)           (((d1) > (d2)) ? (d1) : (d2))
 
@@ -104,18 +102,26 @@ static inline void *octeon_get_dispatch_arg(struct octeon_device *octeon_dev,
 	return fn_arg;
 }
 
-u32 octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
-				  struct octeon_droq *droq)
+/** Check for packets on Droq. This function should be called with
+ * lock held.
+ *  @param  droq - Droq on which count is checked.
+ *  @return Returns packet count.
+ */
+u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq)
 {
 	u32 pkt_count = 0;
+	u32 last_count;
 
 	pkt_count = readl(droq->pkts_sent_reg);
-	if (pkt_count) {
-		atomic_add(pkt_count, &droq->pkts_pending);
-		writel(pkt_count, droq->pkts_sent_reg);
-	}
 
-	return pkt_count;
+	last_count = pkt_count - droq->pkt_count;
+	droq->pkt_count = pkt_count;
+
+	/* we shall write to cnts  at napi irq enable or end of droq tasklet */
+	if (last_count)
+		atomic_add(last_count, &droq->pkts_pending);
+
+	return last_count;
 }
 
 static void octeon_droq_compute_max_packet_bufs(struct octeon_droq *droq)
@@ -151,22 +157,26 @@ octeon_droq_destroy_ring_buffers(struct octeon_device *oct,
 				 struct octeon_droq *droq)
 {
 	u32 i;
+	struct octeon_skb_page_info *pg_info;
 
 	for (i = 0; i < droq->max_count; i++) {
-		if (droq->recv_buf_list[i].buffer) {
-			if (droq->desc_ring) {
-				lio_unmap_ring_info(oct->pci_dev,
-						    (u64)droq->
-						    desc_ring[i].info_ptr,
-						    OCT_DROQ_INFO_SIZE);
-				lio_unmap_ring(oct->pci_dev,
-					       (u64)droq->desc_ring[i].
-					       buffer_ptr,
-					       droq->buffer_size);
-			}
-			recv_buffer_free(droq->recv_buf_list[i].buffer);
-			droq->recv_buf_list[i].buffer = NULL;
-		}
+		pg_info = &droq->recv_buf_list[i].pg_info;
+
+		if (pg_info->dma)
+			lio_unmap_ring(oct->pci_dev,
+				       (u64)pg_info->dma);
+		pg_info->dma = 0;
+
+		if (pg_info->page)
+			recv_buffer_destroy(droq->recv_buf_list[i].buffer,
+					    pg_info);
+
+		if (droq->desc_ring && droq->desc_ring[i].info_ptr)
+			lio_unmap_ring_info(oct->pci_dev,
+					    (u64)droq->
+					    desc_ring[i].info_ptr,
+					    OCT_DROQ_INFO_SIZE);
+		droq->recv_buf_list[i].buffer = NULL;
 	}
 
 	octeon_droq_reset_indices(droq);
@@ -181,25 +191,23 @@ octeon_droq_setup_ring_buffers(struct octeon_device *oct,
 	struct octeon_droq_desc *desc_ring = droq->desc_ring;
 
 	for (i = 0; i < droq->max_count; i++) {
-		buf = recv_buffer_alloc(oct, droq->q_no, droq->buffer_size);
+		buf = recv_buffer_alloc(oct, &droq->recv_buf_list[i].pg_info);
 
 		if (!buf) {
 			dev_err(&oct->pci_dev->dev, "%s buffer alloc failed\n",
 				__func__);
+			droq->stats.rx_alloc_failure++;
 			return -ENOMEM;
 		}
 
 		droq->recv_buf_list[i].buffer = buf;
 		droq->recv_buf_list[i].data = get_rbd(buf);
-
 		droq->info_list[i].length = 0;
 
 		/* map ring buffers into memory */
 		desc_ring[i].info_ptr = lio_map_ring_info(droq, i);
 		desc_ring[i].buffer_ptr =
-			lio_map_ring(oct->pci_dev,
-				     droq->recv_buf_list[i].buffer,
-				     droq->buffer_size);
+			lio_map_ring(droq->recv_buf_list[i].buffer);
 	}
 
 	octeon_droq_reset_indices(droq);
@@ -242,6 +250,8 @@ int octeon_init_droq(struct octeon_device *oct,
 	struct octeon_droq *droq;
 	u32 desc_ring_size = 0, c_num_descs = 0, c_buf_size = 0;
 	u32 c_pkts_per_intr = 0, c_refill_threshold = 0;
+	int orig_node = dev_to_node(&oct->pci_dev->dev);
+	int numa_node = cpu_to_node(q_no % num_online_cpus());
 
 	dev_dbg(&oct->pci_dev->dev, "%s[%d]\n", __func__, q_no);
 
@@ -261,15 +271,23 @@ int octeon_init_droq(struct octeon_device *oct,
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
@@ -283,12 +301,11 @@ int octeon_init_droq(struct octeon_device *oct,
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
@@ -297,7 +314,12 @@ int octeon_init_droq(struct octeon_device *oct,
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
@@ -320,7 +342,7 @@ int octeon_init_droq(struct octeon_device *oct,
 	/* For 56xx Pass1, this function won't be called, so no checks. */
 	oct->fn_list.setup_oq_regs(oct, q_no);
 
-	oct->io_qmask.oq |= (1 << q_no);
+	oct->io_qmask.oq |= (1ULL << q_no);
 
 	return 0;
 
@@ -358,6 +380,7 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 	struct octeon_recv_pkt *recv_pkt;
 	struct octeon_recv_info *recv_info;
 	u32 i, bytes_left;
+	struct octeon_skb_page_info *pg_info;
 
 	info = &droq->info_list[idx];
 
@@ -375,9 +398,14 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 	bytes_left = (u32)info->length;
 
 	while (buf_cnt) {
-		lio_unmap_ring(octeon_dev->pci_dev,
-			       (u64)droq->desc_ring[idx].buffer_ptr,
-			       droq->buffer_size);
+		{
+			pg_info = &droq->recv_buf_list[idx].pg_info;
+
+			lio_unmap_ring(octeon_dev->pci_dev,
+				       (u64)pg_info->dma);
+			pg_info->page = NULL;
+			pg_info->dma = 0;
+		}
 
 		recv_pkt->buffer_size[i] =
 			(bytes_left >=
@@ -449,6 +477,7 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 	void *buf = NULL;
 	u8 *data;
 	u32 desc_refilled = 0;
+	struct octeon_skb_page_info *pg_info;
 
 	desc_ring = droq->desc_ring;
 
@@ -458,13 +487,22 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 		 * the buffer, else allocate.
 		 */
 		if (!droq->recv_buf_list[droq->refill_idx].buffer) {
-			buf = recv_buffer_alloc(octeon_dev, droq->q_no,
-						droq->buffer_size);
+			pg_info =
+				&droq->recv_buf_list[droq->refill_idx].pg_info;
+			/* Either recycle the existing pages or go for
+			 * new page alloc
+			 */
+			if (pg_info->page)
+				buf = recv_buffer_reuse(octeon_dev, pg_info);
+			else
+				buf = recv_buffer_alloc(octeon_dev, pg_info);
 			/* If a buffer could not be allocated, no point in
 			 * continuing
 			 */
-			if (!buf)
+			if (!buf) {
+				droq->stats.rx_alloc_failure++;
 				break;
+			}
 			droq->recv_buf_list[droq->refill_idx].buffer =
 				buf;
 			data = get_rbd(buf);
@@ -476,11 +514,8 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 		droq->recv_buf_list[droq->refill_idx].data = data;
 
 		desc_ring[droq->refill_idx].buffer_ptr =
-			lio_map_ring(octeon_dev->pci_dev,
-				     droq->recv_buf_list[droq->
-				     refill_idx].buffer,
-				     droq->buffer_size);
-
+			lio_map_ring(droq->recv_buf_list[droq->
+				     refill_idx].buffer);
 		/* Reset any previous values in the length field. */
 		droq->info_list[droq->refill_idx].length = 0;
 
@@ -539,7 +574,9 @@ octeon_droq_dispatch_pkt(struct octeon_device *oct,
 			droq->stats.dropped_nomem++;
 		}
 	} else {
-		dev_err(&oct->pci_dev->dev, "DROQ: No dispatch function\n");
+		dev_err(&oct->pci_dev->dev, "DROQ: No dispatch function (opcode %u/%u)\n",
+			(unsigned int)rh->r.opcode,
+			(unsigned int)rh->r.subcode);
 		droq->stats.dropped_nodispatch++;
 	}                       /* else (dispatch_fn ... */
 
@@ -586,6 +623,8 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 	for (pkt = 0; pkt < pkt_count; pkt++) {
 		u32 pkt_len = 0;
 		struct sk_buff *nicbuf = NULL;
+		struct octeon_skb_page_info *pg_info;
+		void *buf;
 
 		info = &droq->info_list[droq->read_idx];
 		octeon_swap_8B_data((u64 *)info, 2);
@@ -605,7 +644,6 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 		rh = &info->rh;
 
 		total_len += (u32)info->length;
-
 		if (OPCODE_SLOW_PATH(rh)) {
 			u32 buf_cnt;
 
@@ -614,50 +652,45 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			droq->refill_count += buf_cnt;
 		} else {
 			if (info->length <= droq->buffer_size) {
-				lio_unmap_ring(oct->pci_dev,
-					       (u64)droq->desc_ring[
-					       droq->read_idx].buffer_ptr,
-					       droq->buffer_size);
 				pkt_len = (u32)info->length;
 				nicbuf = droq->recv_buf_list[
 					droq->read_idx].buffer;
+				pg_info = &droq->recv_buf_list[
+					droq->read_idx].pg_info;
+				if (recv_buffer_recycle(oct, pg_info))
+					pg_info->page = NULL;
 				droq->recv_buf_list[droq->read_idx].buffer =
 					NULL;
+
 				INCR_INDEX_BY1(droq->read_idx, droq->max_count);
-				skb_put(nicbuf, pkt_len);
 				droq->refill_count++;
 			} else {
-				nicbuf = octeon_fast_packet_alloc(oct, droq,
-								  droq->q_no,
-								  (u32)
+				nicbuf = octeon_fast_packet_alloc((u32)
 								  info->length);
 				pkt_len = 0;
 				/* nicbuf allocation can fail. We'll handle it
 				 * inside the loop.
 				 */
 				while (pkt_len < info->length) {
-					int cpy_len;
+					int cpy_len, idx = droq->read_idx;
 
-					cpy_len = ((pkt_len +
-						droq->buffer_size) >
-						info->length) ?
+					cpy_len = ((pkt_len + droq->buffer_size)
+						   > info->length) ?
 						((u32)info->length - pkt_len) :
 						droq->buffer_size;
 
 					if (nicbuf) {
-						lio_unmap_ring(oct->pci_dev,
-							       (u64)
-							       droq->desc_ring
-							       [droq->read_idx].
-							       buffer_ptr,
-							       droq->
-							       buffer_size);
 						octeon_fast_packet_next(droq,
 									nicbuf,
 									cpy_len,
-									droq->
-									read_idx
-									);
+									idx);
+						buf = droq->recv_buf_list[idx].
+							buffer;
+						recv_buffer_fast_free(buf);
+						droq->recv_buf_list[idx].buffer
+							= NULL;
+					} else {
+						droq->stats.rx_alloc_failure++;
 					}
 
 					pkt_len += cpy_len;
@@ -668,12 +701,14 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			}
 
 			if (nicbuf) {
-				if (droq->ops.fptr)
+				if (droq->ops.fptr) {
 					droq->ops.fptr(oct->octeon_id,
-					nicbuf, pkt_len,
-					rh, &droq->napi);
-				else
+						       nicbuf, pkt_len,
+						       rh, &droq->napi,
+						       droq->ops.farg);
+				} else {
 					recv_buffer_free(nicbuf);
+				}
 			}
 		}
 
@@ -681,16 +716,16 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			int desc_refilled = octeon_droq_refill(oct, droq);
 
 			/* Flush the droq descriptor data to memory to be sure
-			* that when we update the credits the data in memory
-			* is accurate.
-			*/
+			 * that when we update the credits the data in memory
+			 * is accurate.
+			 */
 			wmb();
 			writel((desc_refilled), droq->pkts_credit_reg);
 			/* make sure mmio write completes */
 			mmiowb();
 		}
 
-	}                       /* for ( each packet )... */
+	}                       /* for (each packet)... */
 
 	/* Increment refill_count by the number of buffers processed. */
 	droq->stats.pkts_received += pkt;
@@ -714,16 +749,20 @@ octeon_droq_process_packets(struct octeon_device *oct,
 	u32 pkt_count = 0, pkts_processed = 0;
 	struct list_head *tmp, *tmp2;
 
+	/* Grab the lock */
+	spin_lock(&droq->lock);
+
+	octeon_droq_check_hw_for_pkts(droq);
 	pkt_count = atomic_read(&droq->pkts_pending);
-	if (!pkt_count)
+
+	if (!pkt_count) {
+		spin_unlock(&droq->lock);
 		return 0;
+	}
 
 	if (pkt_count > budget)
 		pkt_count = budget;
 
-	/* Grab the lock */
-	spin_lock(&droq->lock);
-
 	pkts_processed = octeon_droq_fast_process_packets(oct, droq, pkt_count);
 
 	atomic_sub(pkts_processed, &droq->pkts_pending);
@@ -768,6 +807,8 @@ octeon_droq_process_poll_pkts(struct octeon_device *oct,
 	spin_lock(&droq->lock);
 
 	while (total_pkts_processed < budget) {
+		octeon_droq_check_hw_for_pkts(droq);
+
 		pkts_available =
 			CVM_MIN((budget - total_pkts_processed),
 				(u32)(atomic_read(&droq->pkts_pending)));
@@ -782,8 +823,6 @@ octeon_droq_process_poll_pkts(struct octeon_device *oct,
 		atomic_sub(pkts_processed, &droq->pkts_pending);
 
 		total_pkts_processed += pkts_processed;
-
-		octeon_droq_check_hw_for_pkts(oct, droq);
 	}
 
 	spin_unlock(&droq->lock);
@@ -807,18 +846,6 @@ octeon_process_droq_poll_cmd(struct octeon_device *oct, u32 q_no, int cmd,
 			     u32 arg)
 {
 	struct octeon_droq *droq;
-	struct octeon_config *oct_cfg = NULL;
-
-	oct_cfg = octeon_get_conf(oct);
-
-	if (!oct_cfg)
-		return -EINVAL;
-
-	if (q_no >= CFG_GET_OQ_MAX_Q(oct_cfg)) {
-		dev_err(&oct->pci_dev->dev, "%s: droq id (%d) exceeds MAX (%d)\n",
-			__func__, q_no, (oct->num_oqs - 1));
-		return -EINVAL;
-	}
 
 	droq = oct->droq[q_no];
 
@@ -866,7 +893,6 @@ octeon_process_droq_poll_cmd(struct octeon_device *oct, u32 q_no, int cmd,
 		}
 		break;
 		}
-
 		return 0;
 	}
 
@@ -937,6 +963,7 @@ int octeon_unregister_droq_ops(struct octeon_device *oct, u32 q_no)
 	spin_lock_irqsave(&droq->lock, flags);
 
 	droq->ops.fptr = NULL;
+	droq->ops.farg = NULL;
 	droq->ops.drop_on_max = 0;
 
 	spin_unlock_irqrestore(&droq->lock, flags);
@@ -949,6 +976,7 @@ int octeon_create_droq(struct octeon_device *oct,
 		       u32 desc_size, void *app_ctx)
 {
 	struct octeon_droq *droq;
+	int numa_node = cpu_to_node(q_no % num_online_cpus());
 
 	if (oct->droq[q_no]) {
 		dev_dbg(&oct->pci_dev->dev, "Droq already in use. Cannot create droq %d again\n",
@@ -957,7 +985,9 @@ int octeon_create_droq(struct octeon_device *oct,
 	}
 
 	/* Allocate the DS for the new droq. */
-	droq = vmalloc(sizeof(*droq));
+	droq = vmalloc_node(sizeof(*droq), numa_node);
+	if (!droq)
+		droq = vmalloc(sizeof(*droq));
 	if (!droq)
 		goto create_droq_fail;
 	memset(droq, 0, sizeof(struct octeon_droq));
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 7940cce..50a0453 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -65,6 +65,17 @@ struct octeon_droq_info {
 
 #define OCT_DROQ_INFO_SIZE   (sizeof(struct octeon_droq_info))
 
+struct octeon_skb_page_info {
+	/* DMA address for the page */
+	dma_addr_t dma;
+
+	/* Page for the rx dma  **/
+	struct page *page;
+
+	/** which offset into page */
+	unsigned int page_offset;
+};
+
 /** Pointer to data buffer.
  *  Driver keeps a pointer to the data buffer that it made available to
  *  the Octeon device. Since the descriptor ring keeps physical (bus)
@@ -77,6 +88,9 @@ struct octeon_recv_buffer {
 
 	/** Data in the packet buffer.  */
 	u8 *data;
+
+	/** pg_info **/
+	struct octeon_skb_page_info pg_info;
 };
 
 #define OCT_DROQ_RECVBUF_SIZE    (sizeof(struct octeon_recv_buffer))
@@ -106,6 +120,10 @@ struct oct_droq_stats {
 
 	/** Num of Packets dropped due to receive path failures. */
 	u64 rx_dropped;
+
+	/** Num of failures of recv_buffer_alloc() */
+	u64 rx_alloc_failure;
+
 };
 
 #define POLL_EVENT_INTR_ARRIVED  1
@@ -213,7 +231,8 @@ struct octeon_droq_ops {
 	 *  data in the buffer. The receive header gives the port
 	 *  number to the caller.  Function pointer is set by caller.
 	 */
-	void (*fptr)(u32, void *, u32, union octeon_rh *, void *);
+	void (*fptr)(u32, void *, u32, union octeon_rh *, void *, void *);
+	void *farg;
 
 	/* This function will be called by the driver for all NAPI related
 	 * events. The first param is the octeon id. The second param is the
@@ -239,6 +258,8 @@ struct octeon_droq {
 
 	u32 q_no;
 
+	u32 pkt_count;
+
 	struct octeon_droq_ops ops;
 
 	struct octeon_device *oct_dev;
@@ -410,8 +431,7 @@ int octeon_unregister_dispatch_fn(struct octeon_device *oct,
 
 void octeon_droq_print_stats(void);
 
-u32 octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
-				  struct octeon_droq *droq);
+u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq);
 
 int octeon_create_droq(struct octeon_device *oct, u32 q_no,
 		       u32 num_descs, u32 desc_size, void *app_ctx);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 592fe49..ce84912 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -68,6 +68,7 @@ struct oct_iq_stats {
 };
 
 #define OCT_IQ_STATS_SIZE   (sizeof(struct oct_iq_stats))
+#define OCT_IQ_FLUSH_RUNNING_BIT	1
 
 /** The instruction (input) queue.
  *  The input queue is used to post raw (instruction) mode data or packet
@@ -75,18 +76,28 @@ struct oct_iq_stats {
  *  a Octeon device has one such structure to represent it.
 */
 struct octeon_instr_queue {
+	struct octeon_device *oct_dev;
+
 	/** A spinlock to protect access to the input ring.  */
 	spinlock_t lock;
 
+	/** A spinlock to protect while posting on the ring.  */
+	spinlock_t post_lock;
+
+	u32 pkt_in_done;
+
+	/** A spinlock to protect access to the input ring.*/
+	spinlock_t iq_flush_running_lock;
+
 	/** Flag that indicates if the queue uses 64 byte commands. */
 	u32 iqcmd_64B:1;
 
-	/** Queue Number. */
-	u32 iq_no:5;
+	/** Queue info. */
+	union oct_txpciq txpciq;
 
 	u32 rsvd:17;
 
-	/* Controls the periodic flushing of iq */
+	/* Controls whether extra flushing of IQ is done on Tx */
 	u32 do_auto_flush:1;
 
 	u32 status:8;
@@ -147,6 +158,13 @@ struct octeon_instr_queue {
 
 	/** Application context */
 	void *app_ctx;
+
+	/* network stack queue index */
+	int q_index;
+
+	/*os ifidx associated with this queue */
+	int ifidx;
+
 };
 
 /*----------------------  INSTRUCTION FORMAT ----------------------------*/
@@ -173,15 +191,23 @@ struct octeon_instr_32B {
 
 #define OCT_32B_INSTR_SIZE     (sizeof(struct octeon_instr_32B))
 
+union octeon_ih {
+	u64 ih2;
+	struct {
+		u64 ih3;
+		u64 pki_ih3;
+	} s;
+};
+
 /** 64-byte instruction format.
  *  Format of instruction for a 64-byte mode input queue.
  */
-struct octeon_instr_64B {
+struct octeon_instr2_64B {
 	/** Pointer where the input data is available. */
 	u64 dptr;
 
 	/** Instruction Header. */
-	u64 ih;
+	u64 ih2;
 
 	/** Input Request Header. */
 	u64 irh;
@@ -198,14 +224,44 @@ struct octeon_instr_64B {
 	u64 rptr;
 
 	u64 reserved;
+};
+
+struct octeon_instr3_64B {
+	/** Pointer where the input data is available. */
+	u64 dptr;
+
+	/** Instruction Header. */
+	u64 ih3;
+
+	/** Instruction Header. */
+	u64 pki_ih3;
+
+	/** Input Request Header. */
+	u64 irh;
+
+	/** opcode/subcode specific parameters */
+	u64 ossp[2];
+
+	/** Return Data Parameters */
+	u64 rdp;
+
+	/** Pointer where the response for a RAW mode packet will be written
+	 * by Octeon.
+	 */
+	u64 rptr;
 
 };
 
-#define OCT_64B_INSTR_SIZE     (sizeof(struct octeon_instr_64B))
+union octeon_instr_64B {
+	struct octeon_instr2_64B cmd2;
+	struct octeon_instr3_64B cmd3;
+};
+
+#define OCT_64B_INSTR_SIZE     (sizeof(union octeon_instr_64B))
 
 /** The size of each buffer in soft command buffer pool
  */
-#define  SOFT_COMMAND_BUFFER_SIZE	1024
+#define  SOFT_COMMAND_BUFFER_SIZE	1536
 
 struct octeon_soft_command {
 	/** Soft command buffer info. */
@@ -214,7 +270,8 @@ struct octeon_soft_command {
 	u32 size;
 
 	/** Command and return status */
-	struct octeon_instr_64B cmd;
+	union octeon_instr_64B cmd;
+
 #define COMPLETION_WORD_INIT    0xffffffffffffffffULL
 	u64 *status_word;
 
@@ -242,7 +299,7 @@ struct octeon_soft_command {
 
 /** Maximum number of buffers to allocate into soft command buffer pool
  */
-#define  MAX_SOFT_COMMAND_BUFFERS	16
+#define  MAX_SOFT_COMMAND_BUFFERS	256
 
 /** Head of a soft command buffer pool.
  */
@@ -268,14 +325,15 @@ void octeon_free_soft_command(struct octeon_device *oct,
 /**
  *  octeon_init_instr_queue()
  *  @param octeon_dev      - pointer to the octeon device structure.
- *  @param iq_no           - queue to be initialized (0 <= q_no <= 3).
+ *  @param txpciq          - queue to be initialized (0 <= q_no <= 3).
  *
  *  Called at driver init time for each input queue. iq_conf has the
  *  configuration parameters for the queue.
  *
  *  @return  Success: 0   Failure: 1
  */
-int octeon_init_instr_queue(struct octeon_device *octeon_dev, u32 iq_no,
+int octeon_init_instr_queue(struct octeon_device *octeon_dev,
+			    union oct_txpciq txpciq,
 			    u32 num_descs);
 
 /**
@@ -298,7 +356,7 @@ octeon_register_reqtype_free_fn(struct octeon_device *oct, int reqtype,
 
 int
 lio_process_iq_request_list(struct octeon_device *oct,
-			    struct octeon_instr_queue *iq);
+			    struct octeon_instr_queue *iq, u32 napi_budget);
 
 int octeon_send_command(struct octeon_device *oct, u32 iq_no,
 			u32 force_db, void *cmd, void *buf,
@@ -313,7 +371,14 @@ void octeon_prepare_soft_command(struct octeon_device *oct,
 int octeon_send_soft_command(struct octeon_device *oct,
 			     struct octeon_soft_command *sc);
 
-int octeon_setup_iq(struct octeon_device *oct, u32 iq_no,
-		    u32 num_descs, void *app_ctx);
+int octeon_setup_iq(struct octeon_device *oct, int ifidx,
+		    int q_index, union oct_txpciq iq_no, u32 num_descs,
+		    void *app_ctx);
 
+void octeon_update_iq_read_idx(struct octeon_device *oct,
+			       struct octeon_instr_queue *iq);
+
+int
+octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
+		u32 pending_thresh, u32 napi_budget);
 #endif				/* __OCTEON_IQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index cbd0819..bc14e4c 100644
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
@@ -169,7 +174,7 @@ sleep_cond(wait_queue_head_t *wait_queue, int *condition)
 
 	init_waitqueue_entry(&we, current);
 	add_wait_queue(wait_queue, &we);
-	while (!(ACCESS_ONCE(*condition))) {
+	while (!(READ_ONCE(*condition))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (signal_pending(current))
 			goto out;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 5aecef8..260b6e7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -44,22 +44,23 @@
 
 #define MEMOPS_IDX   MAX_BAR1_MAP_INDEX
 
+#ifdef __BIG_ENDIAN_BITFIELD
 static inline void
 octeon_toggle_bar1_swapmode(struct octeon_device *oct __attribute__((unused)),
 			    u32 idx __attribute__((unused)))
 {
-#ifdef __BIG_ENDIAN_BITFIELD
 	u32 mask;
 
 	mask = oct->fn_list.bar1_idx_read(oct, idx);
 	mask = (mask & 0x2) ? (mask & ~2) : (mask | 2);
 	oct->fn_list.bar1_idx_write(oct, idx, mask);
-#endif
 }
+#else
+#define octeon_toggle_bar1_swapmode(oct, idx)
+#endif
 
 static void
-octeon_pci_fastwrite(struct octeon_device *oct, u8 __iomem *mapped_addr,
-		     u8 *hostbuf, u32 len)
+octeon_pci_fastwrite(u8 __iomem *mapped_addr, u8 *hostbuf, u32 len)
 {
 	while ((len) && ((unsigned long)mapped_addr) & 7) {
 		writeb(*(hostbuf++), mapped_addr++);
@@ -82,8 +83,7 @@ octeon_pci_fastwrite(struct octeon_device *oct, u8 __iomem *mapped_addr,
 }
 
 static void
-octeon_pci_fastread(struct octeon_device *oct, u8 __iomem *mapped_addr,
-		    u8 *hostbuf, u32 len)
+octeon_pci_fastread(u8 __iomem *mapped_addr, u8 *hostbuf, u32 len)
 {
 	while ((len) && ((unsigned long)mapped_addr) & 7) {
 		*(hostbuf++) = readb(mapped_addr++);
@@ -136,11 +136,9 @@ __octeon_pci_rw_core_mem(struct octeon_device *oct, u64 addr,
 		}
 
 		if (op) {	/* read from core */
-			octeon_pci_fastread(oct, mapped_addr, hostbuf,
-					    copy_len);
+			octeon_pci_fastread(mapped_addr, hostbuf, copy_len);
 		} else {
-			octeon_pci_fastwrite(oct, mapped_addr, hostbuf,
-					     copy_len);
+			octeon_pci_fastwrite(mapped_addr, hostbuf, copy_len);
 		}
 
 		len -= copy_len;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index b3abe58..8f0755e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -30,6 +30,20 @@
 #include <linux/dma-mapping.h>
 #include <linux/ptp_clock_kernel.h>
 
+#define LIO_MAX_MTU_SIZE (OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE)
+#define LIO_MIN_MTU_SIZE 68
+
+struct oct_nic_stats_resp {
+	u64     rh;
+	struct oct_link_stats stats;
+	u64     status;
+};
+
+struct oct_nic_stats_ctrl {
+	struct completion complete;
+	struct net_device *netdev;
+};
+
 /** LiquidIO per-interface network private data */
 struct lio {
 	/** State of the interface. Rx/Tx happens only in the RUNNING state.  */
@@ -48,11 +62,11 @@ struct lio {
 	 */
 	int rxq;
 
-	/** Guards the glist */
-	spinlock_t lock;
+	/** Guards each glist */
+	spinlock_t *glist_lock;
 
-	/** Linked list of gather components */
-	struct list_head glist;
+	/** Array of gather component linked lists */
+	struct list_head *glist;
 
 	/** Pointer to the NIC properties for the Octeon device this network
 	 *  interface is associated with.
@@ -67,6 +81,9 @@ struct lio {
 	/** Link information sent by the core application for this interface. */
 	struct oct_link_info linfo;
 
+	/** counter of link changes */
+	u64 link_changes;
+
 	/** Size of Tx queue for this octeon device. */
 	u32 tx_qsize;
 
@@ -102,6 +119,7 @@ struct lio {
 	/* work queue for  txq status */
 	struct cavium_wq	txq_status_wq;
 
+	int netdev_uc_count;
 };
 
 #define LIO_SIZE         (sizeof(struct lio))
@@ -111,8 +129,9 @@ struct lio {
  * \brief Enable or disable feature
  * @param netdev    pointer to network device
  * @param cmd       Command that just requires acknowledgment
+ * @param param1    Parameter to command
  */
-int liquidio_set_feature(struct net_device *netdev, int cmd);
+int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1);
 
 /**
  * \brief Link control command completion callback
@@ -131,14 +150,30 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr);
  */
 void liquidio_set_ethtool_ops(struct net_device *netdev);
 
-static inline void
-*recv_buffer_alloc(struct octeon_device *oct __attribute__((unused)),
-		   u32 q_no __attribute__((unused)), u32 size)
-{
 #define SKB_ADJ_MASK  0x3F
 #define SKB_ADJ       (SKB_ADJ_MASK + 1)
 
-	struct sk_buff *skb = dev_alloc_skb(size + SKB_ADJ);
+#define MIN_SKB_SIZE       256 /* 8 bytes and more - 8 bytes for PTP */
+#define LIO_RXBUFFER_SZ    2048
+
+static inline void
+*recv_buffer_alloc(struct octeon_device *oct,
+		   struct octeon_skb_page_info *pg_info)
+{
+	struct page *page;
+	struct sk_buff *skb;
+	struct octeon_skb_page_info *skb_pg_info;
+
+	page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+	if (unlikely(!page))
+		return NULL;
+
+	skb = dev_alloc_skb(MIN_SKB_SIZE + SKB_ADJ);
+	if (unlikely(!skb)) {
+		__free_page(page);
+		pg_info->page = NULL;
+		return NULL;
+	}
 
 	if ((unsigned long)skb->data & SKB_ADJ_MASK) {
 		u32 r = SKB_ADJ - ((unsigned long)skb->data & SKB_ADJ_MASK);
@@ -146,11 +181,151 @@ static inline void
 		skb_reserve(skb, r);
 	}
 
+	skb_pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	/* Get DMA info */
+	pg_info->dma = dma_map_page(&oct->pci_dev->dev, page, 0,
+				    PAGE_SIZE, DMA_FROM_DEVICE);
+
+	/* Mapping failed!! */
+	if (dma_mapping_error(&oct->pci_dev->dev, pg_info->dma)) {
+		__free_page(page);
+		dev_kfree_skb_any((struct sk_buff *)skb);
+		pg_info->page = NULL;
+		return NULL;
+	}
+
+	pg_info->page = page;
+	pg_info->page_offset = 0;
+	skb_pg_info->page = page;
+	skb_pg_info->page_offset = 0;
+	skb_pg_info->dma = pg_info->dma;
+
 	return (void *)skb;
 }
 
+static inline void
+*recv_buffer_fast_alloc(u32 size)
+{
+	struct sk_buff *skb;
+	struct octeon_skb_page_info *skb_pg_info;
+
+	skb = dev_alloc_skb(size + SKB_ADJ);
+	if (unlikely(!skb))
+		return NULL;
+
+	if ((unsigned long)skb->data & SKB_ADJ_MASK) {
+		u32 r = SKB_ADJ - ((unsigned long)skb->data & SKB_ADJ_MASK);
+
+		skb_reserve(skb, r);
+	}
+
+	skb_pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	skb_pg_info->page = NULL;
+	skb_pg_info->page_offset = 0;
+	skb_pg_info->dma = 0;
+
+	return skb;
+}
+
+static inline int
+recv_buffer_recycle(struct octeon_device *oct, void *buf)
+{
+	struct octeon_skb_page_info *pg_info = buf;
+
+	if (!pg_info->page) {
+		dev_err(&oct->pci_dev->dev, "%s: pg_info->page NULL\n",
+			__func__);
+		return -ENOMEM;
+	}
+
+	if (unlikely(page_count(pg_info->page) != 1) ||
+	    unlikely(page_to_nid(pg_info->page)	!= numa_node_id())) {
+		dma_unmap_page(&oct->pci_dev->dev,
+			       pg_info->dma, (PAGE_SIZE << 0),
+			       DMA_FROM_DEVICE);
+		pg_info->dma = 0;
+		pg_info->page = NULL;
+		pg_info->page_offset = 0;
+		return -ENOMEM;
+	}
+
+	/* Flip to other half of the buffer */
+	if (pg_info->page_offset == 0)
+		pg_info->page_offset = LIO_RXBUFFER_SZ;
+	else
+		pg_info->page_offset = 0;
+	atomic_inc(&pg_info->page->_count);
+
+	return 0;
+}
+
+static inline void
+*recv_buffer_reuse(struct octeon_device *oct, void *buf)
+{
+	struct octeon_skb_page_info *pg_info = buf, *skb_pg_info;
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(MIN_SKB_SIZE + SKB_ADJ);
+	if (unlikely(!skb)) {
+		dma_unmap_page(&oct->pci_dev->dev,
+			       pg_info->dma, (PAGE_SIZE << 0),
+			       DMA_FROM_DEVICE);
+		return NULL;
+	}
+
+	if ((unsigned long)skb->data & SKB_ADJ_MASK) {
+		u32 r = SKB_ADJ - ((unsigned long)skb->data & SKB_ADJ_MASK);
+
+		skb_reserve(skb, r);
+	}
+
+	skb_pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	skb_pg_info->page = pg_info->page;
+	skb_pg_info->page_offset = pg_info->page_offset;
+	skb_pg_info->dma = pg_info->dma;
+
+	return skb;
+}
+
+static inline void
+recv_buffer_destroy(void *buffer, struct octeon_skb_page_info *pg_info)
+{
+	struct sk_buff *skb = (struct sk_buff *)buffer;
+
+	put_page(pg_info->page);
+	pg_info->dma = 0;
+	pg_info->page = NULL;
+	pg_info->page_offset = 0;
+
+	if (skb)
+		dev_kfree_skb_any(skb);
+}
+
 static inline void recv_buffer_free(void *buffer)
 {
+	struct sk_buff *skb = (struct sk_buff *)buffer;
+	struct octeon_skb_page_info *pg_info;
+
+	pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+
+	if (pg_info->page) {
+		put_page(pg_info->page);
+		pg_info->dma = 0;
+		pg_info->page = NULL;
+		pg_info->page_offset = 0;
+	}
+
+	dev_kfree_skb_any((struct sk_buff *)buffer);
+}
+
+static inline void
+recv_buffer_fast_free(void *buffer)
+{
+	dev_kfree_skb_any((struct sk_buff *)buffer);
+}
+
+static inline void tx_buffer_free(void *buffer)
+{
 	dev_kfree_skb_any((struct sk_buff *)buffer);
 }
 
@@ -159,7 +334,17 @@ static inline void recv_buffer_free(void *buffer)
 #define lio_dma_free(oct, size, virt_addr, dma_addr) \
 	dma_free_coherent(&oct->pci_dev->dev, size, virt_addr, dma_addr)
 
-#define   get_rbd(ptr)      (((struct sk_buff *)(ptr))->data)
+static inline
+void *get_rbd(struct sk_buff *skb)
+{
+	struct octeon_skb_page_info *pg_info;
+	unsigned char *va;
+
+	pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	va = page_address(pg_info->page) + pg_info->page_offset;
+
+	return va;
+}
 
 static inline u64
 lio_map_ring_info(struct octeon_droq *droq, u32 i)
@@ -170,7 +355,7 @@ lio_map_ring_info(struct octeon_droq *droq, u32 i)
 	dma_addr = dma_map_single(&oct->pci_dev->dev, &droq->info_list[i],
 				  OCT_DROQ_INFO_SIZE, DMA_FROM_DEVICE);
 
-	BUG_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
+	WARN_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
 
 	return (u64)dma_addr;
 }
@@ -183,33 +368,44 @@ lio_unmap_ring_info(struct pci_dev *pci_dev,
 }
 
 static inline u64
-lio_map_ring(struct pci_dev *pci_dev,
-	     void *buf, u32 size)
+lio_map_ring(void *buf)
 {
 	dma_addr_t dma_addr;
 
-	dma_addr = dma_map_single(&pci_dev->dev, get_rbd(buf), size,
-				  DMA_FROM_DEVICE);
+	struct sk_buff *skb = (struct sk_buff *)buf;
+	struct octeon_skb_page_info *pg_info;
 
-	BUG_ON(dma_mapping_error(&pci_dev->dev, dma_addr));
+	pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	if (!pg_info->page) {
+		pr_err("%s: pg_info->page NULL\n", __func__);
+		WARN_ON(1);
+	}
+
+	/* Get DMA info */
+	dma_addr = pg_info->dma;
+	if (!pg_info->dma) {
+		pr_err("%s: ERROR it should be already available\n",
+		       __func__);
+		WARN_ON(1);
+	}
+	dma_addr += pg_info->page_offset;
 
 	return (u64)dma_addr;
 }
 
 static inline void
 lio_unmap_ring(struct pci_dev *pci_dev,
-	       u64 buf_ptr, u32 size)
+	       u64 buf_ptr)
+
 {
-	dma_unmap_single(&pci_dev->dev,
-			 buf_ptr, size,
-			 DMA_FROM_DEVICE);
+	dma_unmap_page(&pci_dev->dev,
+		       buf_ptr, (PAGE_SIZE << 0),
+		       DMA_FROM_DEVICE);
 }
 
-static inline void *octeon_fast_packet_alloc(struct octeon_device *oct,
-					     struct octeon_droq *droq,
-					     u32 q_no, u32 size)
+static inline void *octeon_fast_packet_alloc(u32 size)
 {
-	return recv_buffer_alloc(oct, q_no, size);
+	return recv_buffer_fast_alloc(size);
 }
 
 static inline void octeon_fast_packet_next(struct octeon_droq *droq,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 1a01915..36f1970 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -44,11 +44,11 @@
 
 void *
 octeon_alloc_soft_command_resp(struct octeon_device    *oct,
-			       struct octeon_instr_64B *cmd,
-			       size_t		       rdatasize)
+			       union octeon_instr_64B *cmd,
+			       u32		       rdatasize)
 {
 	struct octeon_soft_command *sc;
-	struct octeon_instr_ih  *ih;
+	struct octeon_instr_ih2  *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
@@ -59,24 +59,25 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 		return NULL;
 
 	/* Copy existing command structure into the soft command */
-	memcpy(&sc->cmd, cmd, sizeof(struct octeon_instr_64B));
+	memcpy(&sc->cmd, cmd, sizeof(union octeon_instr_64B));
 
 	/* Add in the response related fields. Opcode and Param are already
 	 * there.
 	 */
-	ih      = (struct octeon_instr_ih *)&sc->cmd.ih;
-	ih->fsz = 40; /* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
+	ih2      = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+	rdp     = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+	irh     = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
+	ih2->fsz = 40; /* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
 
-	irh        = (struct octeon_instr_irh *)&sc->cmd.irh;
 	irh->rflag = 1; /* a response is required */
-	irh->len   = 4; /* means four 64-bit words immediately follow irh */
 
-	rdp            = (struct octeon_instr_rdp *)&sc->cmd.rdp;
 	rdp->pcie_port = oct->pcie_port;
 	rdp->rlen      = rdatasize;
 
 	*sc->status_word = COMPLETION_WORD_INIT;
 
+	sc->cmd.cmd2.rptr =  sc->dmarptr;
+
 	sc->wait_time = 1000;
 	sc->timeout = jiffies + sc->wait_time;
 
@@ -119,12 +120,11 @@ static void octnet_link_ctrl_callback(struct octeon_device *oct,
 
 static inline struct octeon_soft_command
 *octnic_alloc_ctrl_pkt_sc(struct octeon_device *oct,
-			  struct octnic_ctrl_pkt *nctrl,
-			  struct octnic_ctrl_params nparams)
+			  struct octnic_ctrl_pkt *nctrl)
 {
 	struct octeon_soft_command *sc = NULL;
 	u8 *data;
-	size_t rdatasize;
+	u32 rdatasize;
 	u32 uddsize = 0, datasize = 0;
 
 	uddsize = (u32)(nctrl->ncmd.s.more * 8);
@@ -143,7 +143,7 @@ static inline struct octeon_soft_command
 
 	data = (u8 *)sc->virtdptr;
 
-	memcpy(data, &nctrl->ncmd,  OCTNET_CMD_SIZE);
+	memcpy(data, &nctrl->ncmd, OCTNET_CMD_SIZE);
 
 	octeon_swap_8B_data((u64 *)data, (OCTNET_CMD_SIZE >> 3));
 
@@ -152,6 +152,8 @@ static inline struct octeon_soft_command
 		memcpy(data + OCTNET_CMD_SIZE, nctrl->udd, uddsize);
 	}
 
+	sc->iq_no = (u32)nctrl->iq_no;
+
 	octeon_prepare_soft_command(oct, sc, OPCODE_NIC, OPCODE_NIC_CMD,
 				    0, 0, 0);
 
@@ -164,26 +166,41 @@ static inline struct octeon_soft_command
 
 int
 octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
-			 struct octnic_ctrl_pkt *nctrl,
-			 struct octnic_ctrl_params nparams)
+			 struct octnic_ctrl_pkt *nctrl)
 {
 	int retval;
 	struct octeon_soft_command *sc = NULL;
 
-	sc = octnic_alloc_ctrl_pkt_sc(oct, nctrl, nparams);
+	spin_lock_bh(&oct->cmd_resp_wqlock);
+	/* Allow only rx ctrl command to stop traffic on the chip
+	 * during offline operations
+	 */
+	if ((oct->cmd_resp_state == OCT_DRV_OFFLINE) &&
+	    (nctrl->ncmd.s.cmd != OCTNET_CMD_RX_CTL)) {
+		spin_unlock_bh(&oct->cmd_resp_wqlock);
+		dev_err(&oct->pci_dev->dev,
+			"%s cmd:%d not processed since driver offline\n",
+			__func__, nctrl->ncmd.s.cmd);
+		return -1;
+	}
+
+	sc = octnic_alloc_ctrl_pkt_sc(oct, nctrl);
 	if (!sc) {
 		dev_err(&oct->pci_dev->dev, "%s soft command alloc failed\n",
 			__func__);
+		spin_unlock_bh(&oct->cmd_resp_wqlock);
 		return -1;
 	}
 
 	retval = octeon_send_soft_command(oct, sc);
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		octeon_free_soft_command(oct, sc);
-		dev_err(&oct->pci_dev->dev, "%s soft command send failed status: %x\n",
-			__func__, retval);
+		dev_err(&oct->pci_dev->dev, "%s soft command:%d send failed status: %x\n",
+			__func__, nctrl->ncmd.s.cmd, retval);
+		spin_unlock_bh(&oct->cmd_resp_wqlock);
 		return -1;
 	}
 
+	spin_unlock_bh(&oct->cmd_resp_wqlock);
 	return retval;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 0238857..6deb0ee 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -52,6 +52,9 @@ struct octnic_ctrl_pkt {
 	/** Additional data that may be needed by some commands. */
 	u64 udd[MAX_NCTRL_UDD];
 
+	/** Input queue to use to send this command. */
+	u64 iq_no;
+
 	/** Time to wait for Octeon software to respond to this control command.
 	 *  If wait_time is 0, OSI assumes no response is expected.
 	 */
@@ -82,7 +85,7 @@ struct octnic_data_pkt {
 	u32 datasize;
 
 	/** Command to be passed to the Octeon device software. */
-	struct octeon_instr_64B cmd;
+	union octeon_instr_64B cmd;
 
 	/** Input queue to use to send this command. */
 	u32 q_no;
@@ -94,15 +97,14 @@ struct octnic_data_pkt {
  */
 union octnic_cmd_setup {
 	struct {
-		u32 ifidx:8;
-		u32 cksum_offset:7;
+		u32 iq_no:8;
 		u32 gather:1;
 		u32 timestamp:1;
-		u32 ipv4opts_ipv6exthdr:2;
 		u32 ip_csum:1;
+		u32 transport_csum:1;
 		u32 tnl_csum:1;
+		u32 rsvd:19;
 
-		u32 rsvd:11;
 		union {
 			u32 datasize;
 			u32 gatherptrs;
@@ -113,9 +115,12 @@ union octnic_cmd_setup {
 
 };
 
-struct octnic_ctrl_params {
-	u32 resp_order;
-};
+static inline int octnet_iq_get_available(struct octeon_device *oct, u32 q_no)
+{
+	return ((oct->instr_queue[q_no]->max_count - 2) -
+			(u32)atomic_read(&oct->instr_queue[q_no]->
+						instr_pending));
+}
 
 static inline int octnet_iq_is_full(struct octeon_device *oct, u32 q_no)
 {
@@ -198,8 +203,8 @@ octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
  */
 void *
 octeon_alloc_soft_command_resp(struct octeon_device    *oct,
-			       struct octeon_instr_64B *cmd,
-			       size_t		       rdatasize);
+			       union octeon_instr_64B *cmd,
+			       u32		       rdatasize);
 
 /** Send a NIC data packet to the device
  * @param oct - octeon device pointer
@@ -214,14 +219,12 @@ int octnet_send_nic_data_pkt(struct octeon_device *oct,
 /** Send a NIC control packet to the device
  * @param oct - octeon device pointer
  * @param nctrl - control structure with command, timout, and callback info
- * @param nparams - response control structure
  *
  * @returns IQ_FAILED if it failed to add to the input queue. IQ_STOP if it the
  * queue should be stopped, and IQ_SEND_OK if it sent okay.
  */
 int
 octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
-			 struct octnic_ctrl_pkt *nctrl,
-			 struct octnic_ctrl_params nparams);
+			 struct octnic_ctrl_pkt *nctrl);
 
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index a2a2465..3c11fec 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -51,7 +51,7 @@ struct iq_post_status {
 };
 
 static void check_db_timeout(struct work_struct *work);
-static void  __check_db_timeout(struct octeon_device *oct, unsigned long iq_no);
+static void  __check_db_timeout(struct octeon_device *oct, u64 iq_no);
 
 static void (*reqtype_free_fn[MAX_OCTEON_DEVICES][REQTYPE_LAST + 1]) (void *);
 
@@ -69,12 +69,16 @@ static inline int IQ_INSTR_MODE_64B(struct octeon_device *oct, int iq_no)
 
 /* Return 0 on success, 1 on failure */
 int octeon_init_instr_queue(struct octeon_device *oct,
-			    u32 iq_no, u32 num_descs)
+			    union oct_txpciq txpciq,
+			    u32 num_descs)
 {
 	struct octeon_instr_queue *iq;
 	struct octeon_iq_config *conf = NULL;
+	u32 iq_no = (u32)txpciq.s.q_no;
 	u32 q_size;
 	struct cavium_wq *db_wq;
+	int orig_node = dev_to_node(&oct->pci_dev->dev);
+	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
 	if (OCTEON_CN6XXX(oct))
 		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn6xxx, conf)));
@@ -95,9 +99,15 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	q_size = (u32)conf->instr_type * num_descs;
 
 	iq = oct->instr_queue[iq_no];
+	iq->oct_dev = oct;
 
+	set_dev_node(&oct->pci_dev->dev, numa_node);
 	iq->base_addr = lio_dma_alloc(oct, q_size,
 				      (dma_addr_t *)&iq->base_addr_dma);
+	set_dev_node(&oct->pci_dev->dev, orig_node);
+	if (!iq->base_addr)
+		iq->base_addr = lio_dma_alloc(oct, q_size,
+					      (dma_addr_t *)&iq->base_addr_dma);
 	if (!iq->base_addr) {
 		dev_err(&oct->pci_dev->dev, "Cannot allocate memory for instr queue %d\n",
 			iq_no);
@@ -109,7 +119,11 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	/* Initialize a list to holds requests that have been posted to Octeon
 	 * but has yet to be fetched by octeon
 	 */
-	iq->request_list = vmalloc(sizeof(*iq->request_list) * num_descs);
+	iq->request_list = vmalloc_node((sizeof(*iq->request_list) * num_descs),
+					       numa_node);
+	if (!iq->request_list)
+		iq->request_list = vmalloc(sizeof(*iq->request_list) *
+						  num_descs);
 	if (!iq->request_list) {
 		lio_dma_free(oct, q_size, iq->base_addr, iq->base_addr_dma);
 		dev_err(&oct->pci_dev->dev, "Alloc failed for IQ[%d] nr free list\n",
@@ -122,7 +136,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	dev_dbg(&oct->pci_dev->dev, "IQ[%d]: base: %p basedma: %llx count: %d\n",
 		iq_no, iq->base_addr, iq->base_addr_dma, iq->max_count);
 
-	iq->iq_no = iq_no;
+	iq->txpciq.u64 = txpciq.u64;
 	iq->fill_threshold = (u32)conf->db_min;
 	iq->fill_cnt = 0;
 	iq->host_write_index = 0;
@@ -135,8 +149,11 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	/* Initialize the spinlock for this instruction queue */
 	spin_lock_init(&iq->lock);
+	spin_lock_init(&iq->post_lock);
 
-	oct->io_qmask.iq |= (1 << iq_no);
+	spin_lock_init(&iq->iq_flush_running_lock);
+
+	oct->io_qmask.iq |= (1ULL << iq_no);
 
 	/* Set the 32B/64B mode for each input queue */
 	oct->io_qmask.iq64B |= ((conf->instr_type == 64) << iq_no);
@@ -188,26 +205,38 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 
 /* Return 0 on success, 1 on failure */
 int octeon_setup_iq(struct octeon_device *oct,
-		    u32 iq_no,
+		    int ifidx,
+		    int q_index,
+		    union oct_txpciq txpciq,
 		    u32 num_descs,
 		    void *app_ctx)
 {
+	u32 iq_no = (u32)txpciq.s.q_no;
+	int numa_node = cpu_to_node(iq_no % num_online_cpus());
+
 	if (oct->instr_queue[iq_no]) {
 		dev_dbg(&oct->pci_dev->dev, "IQ is in use. Cannot create the IQ: %d again\n",
 			iq_no);
+		oct->instr_queue[iq_no]->txpciq.u64 = txpciq.u64;
 		oct->instr_queue[iq_no]->app_ctx = app_ctx;
 		return 0;
 	}
 	oct->instr_queue[iq_no] =
-	    vmalloc(sizeof(struct octeon_instr_queue));
+	    vmalloc_node(sizeof(struct octeon_instr_queue), numa_node);
+	if (!oct->instr_queue[iq_no])
+		oct->instr_queue[iq_no] =
+		    vmalloc(sizeof(struct octeon_instr_queue));
 	if (!oct->instr_queue[iq_no])
 		return 1;
 
 	memset(oct->instr_queue[iq_no], 0,
 	       sizeof(struct octeon_instr_queue));
 
+	oct->instr_queue[iq_no]->q_index = q_index;
 	oct->instr_queue[iq_no]->app_ctx = app_ctx;
-	if (octeon_init_instr_queue(oct, iq_no, num_descs)) {
+	oct->instr_queue[iq_no]->ifidx = ifidx;
+
+	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
 		vfree(oct->instr_queue[iq_no]);
 		oct->instr_queue[iq_no] = NULL;
 		return 1;
@@ -226,8 +255,8 @@ int lio_wait_for_instr_fetch(struct octeon_device *oct)
 		instr_cnt = 0;
 
 		/*for (i = 0; i < oct->num_iqs; i++) {*/
-		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES; i++) {
-			if (!(oct->io_qmask.iq & (1UL << i)))
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.iq & (1ULL << i)))
 				continue;
 			pending =
 			    atomic_read(&oct->
@@ -272,11 +301,9 @@ static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
 }
 
 static inline int
-__post_command(struct octeon_device *octeon_dev __attribute__((unused)),
-	       struct octeon_instr_queue *iq,
-	       u32 force_db __attribute__((unused)), u8 *cmd)
+__post_command(struct octeon_instr_queue *iq, u8 *cmd)
 {
-	u32 index = -1;
+	u32 index;
 
 	/* This ensures that the read index does not wrap around to the same
 	 * position if queue gets full before Octeon could fetch any instr.
@@ -302,9 +329,7 @@ __post_command(struct octeon_device *octeon_dev __attribute__((unused)),
 }
 
 static inline struct iq_post_status
-__post_command2(struct octeon_device *octeon_dev __attribute__((unused)),
-		struct octeon_instr_queue *iq,
-		u32 force_db __attribute__((unused)), u8 *cmd)
+__post_command2(struct octeon_instr_queue *iq, u8 *cmd)
 {
 	struct iq_post_status st;
 
@@ -362,17 +387,19 @@ __add_to_request_list(struct octeon_instr_queue *iq,
 	iq->request_list[idx].reqtype = reqtype;
 }
 
+/* Can only run in process context */
 int
 lio_process_iq_request_list(struct octeon_device *oct,
-			    struct octeon_instr_queue *iq)
+			    struct octeon_instr_queue *iq, u32 napi_budget)
 {
 	int reqtype;
 	void *buf;
 	u32 old = iq->flush_index;
 	u32 inst_count = 0;
-	unsigned pkts_compl = 0, bytes_compl = 0;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 	struct octeon_soft_command *sc;
 	struct octeon_instr_irh *irh;
+	unsigned long flags;
 
 	while (old != iq->octeon_read_index) {
 		reqtype = iq->request_list[old].reqtype;
@@ -394,7 +421,7 @@ lio_process_iq_request_list(struct octeon_device *oct,
 		case REQTYPE_SOFT_COMMAND:
 			sc = buf;
 
-			irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+			irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 			if (irh->rflag) {
 				/* We're expecting a response from Octeon.
 				 * It's up to lio_process_ordered_list() to
@@ -402,17 +429,22 @@ lio_process_iq_request_list(struct octeon_device *oct,
 				 * command response list because we expect
 				 * a response from Octeon.
 				 */
-				spin_lock_bh(&oct->response_list
-					[OCTEON_ORDERED_SC_LIST].lock);
+				spin_lock_irqsave
+					(&oct->response_list
+					 [OCTEON_ORDERED_SC_LIST].lock,
+					 flags);
 				atomic_inc(&oct->response_list
 					[OCTEON_ORDERED_SC_LIST].
 					pending_req_count);
 				list_add_tail(&sc->node, &oct->response_list
 					[OCTEON_ORDERED_SC_LIST].head);
-				spin_unlock_bh(&oct->response_list
-					[OCTEON_ORDERED_SC_LIST].lock);
+				spin_unlock_irqrestore
+					(&oct->response_list
+					 [OCTEON_ORDERED_SC_LIST].lock,
+					 flags);
 			} else {
 				if (sc->callback) {
+					/* This callback must not sleep */
 					sc->callback(oct, OCTEON_REQUEST_DONE,
 						     sc->callback_arg);
 				}
@@ -430,6 +462,9 @@ lio_process_iq_request_list(struct octeon_device *oct,
  skip_this:
 		inst_count++;
 		INCR_INDEX_BY1(old, iq->max_count);
+
+		if ((napi_budget) && (inst_count >= napi_budget))
+			break;
 	}
 	if (bytes_compl)
 		octeon_report_tx_completion_to_bql(iq->app_ctx, pkts_compl,
@@ -439,66 +474,101 @@ lio_process_iq_request_list(struct octeon_device *oct,
 	return inst_count;
 }
 
-static inline void
-update_iq_indices(struct octeon_device *oct, struct octeon_instr_queue *iq)
+/* Called from interrupt context */
+void octeon_update_iq_read_idx(struct octeon_device *oct,
+			       struct octeon_instr_queue *iq)
 {
-	u32 inst_processed = 0;
+	spin_lock_bh(&iq->lock);
 
 	/* Calculate how many commands Octeon has read and move the read index
 	 * accordingly.
 	 */
-	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(oct, iq);
+	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(iq);
 
-	/* Move the NORESPONSE requests to the per-device completion list. */
-	if (iq->flush_index != iq->octeon_read_index)
-		inst_processed = lio_process_iq_request_list(oct, iq);
-
-	if (inst_processed) {
-		atomic_sub(inst_processed, &iq->instr_pending);
-		iq->stats.instr_processed += inst_processed;
-	}
+	spin_unlock_bh(&iq->lock);
 }
 
-static void
+/* Can only be called from process context */
+int
 octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
-		u32 pending_thresh)
+		u32 pending_thresh, u32 napi_budget)
 {
+	u32 inst_processed = 0;
+	u32 tot_inst_processed = 0;
+	int tx_done = 1;
+
+	if (!spin_trylock(&iq->iq_flush_running_lock))
+		return tx_done;
+
+	spin_lock_bh(&iq->lock);
+
+	iq->octeon_read_index = oct->fn_list.update_iq_read_idx(iq);
+
 	if (atomic_read(&iq->instr_pending) >= (s32)pending_thresh) {
-		spin_lock_bh(&iq->lock);
-		update_iq_indices(oct, iq);
-		spin_unlock_bh(&iq->lock);
+		do {
+			/* Process any outstanding IQ packets. */
+			if (iq->flush_index == iq->octeon_read_index)
+				break;
+
+			if (napi_budget)
+				inst_processed = lio_process_iq_request_list
+					(oct, iq,
+					 napi_budget - tot_inst_processed);
+			else
+				inst_processed =
+					lio_process_iq_request_list(oct, iq, 0);
+
+			if (inst_processed) {
+				atomic_sub(inst_processed, &iq->instr_pending);
+				iq->stats.instr_processed += inst_processed;
+			}
+
+			tot_inst_processed += inst_processed;
+			inst_processed = 0;
+
+		} while (tot_inst_processed < napi_budget);
+
+		if (napi_budget && (tot_inst_processed >= napi_budget))
+			tx_done = 0;
 	}
+
+	iq->last_db_time = jiffies;
+
+	spin_unlock_bh(&iq->lock);
+
+	spin_unlock(&iq->iq_flush_running_lock);
+
+	return tx_done;
 }
 
-static void __check_db_timeout(struct octeon_device *oct, unsigned long iq_no)
+/* Process instruction queue after timeout.
+ * This routine gets called from a workqueue or when removing the module.
+ */
+static void __check_db_timeout(struct octeon_device *oct, u64 iq_no)
 {
 	struct octeon_instr_queue *iq;
 	u64 next_time;
 
 	if (!oct)
 		return;
+
 	iq = oct->instr_queue[iq_no];
 	if (!iq)
 		return;
 
+	/* return immediately, if no work pending */
+	if (!atomic_read(&iq->instr_pending))
+		return;
 	/* If jiffies - last_db_time < db_timeout do nothing  */
 	next_time = iq->last_db_time + iq->db_timeout;
 	if (!time_after(jiffies, (unsigned long)next_time))
 		return;
 	iq->last_db_time = jiffies;
 
-	/* Get the lock and prevent tasklets. This routine gets called from
-	 * the poll thread. Instructions can now be posted in tasklet context
-	 */
-	spin_lock_bh(&iq->lock);
-	if (iq->fill_cnt != 0)
-		ring_doorbell(oct, iq);
-
-	spin_unlock_bh(&iq->lock);
-
 	/* Flush the instruction queue */
-	if (iq->do_auto_flush)
-		octeon_flush_iq(oct, iq, 1);
+	octeon_flush_iq(oct, iq, 1, 0);
+
+	lio_enable_irq(NULL, iq);
 }
 
 /* Called by the Poll thread at regular intervals to check the instruction
@@ -508,11 +578,12 @@ static void check_db_timeout(struct work_struct *work)
 {
 	struct cavium_wk *wk = (struct cavium_wk *)work;
 	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
-	unsigned long iq_no = wk->ctxul;
+	u64 iq_no = wk->ctxul;
 	struct cavium_wq *db_wq = &oct->check_db_wq[iq_no];
+	u32 delay = 10;
 
 	__check_db_timeout(oct, iq_no);
-	queue_delayed_work(db_wq->wq, &db_wq->wk.work, msecs_to_jiffies(1));
+	queue_delayed_work(db_wq->wq, &db_wq->wk.work, msecs_to_jiffies(delay));
 }
 
 int
@@ -523,9 +594,12 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 	struct iq_post_status st;
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
 
-	spin_lock_bh(&iq->lock);
+	/* Get the lock and prevent other tasks and tx interrupt handler from
+	 * running.
+	 */
+	spin_lock_bh(&iq->post_lock);
 
-	st = __post_command2(oct, iq, force_db, cmd);
+	st = __post_command2(iq, cmd);
 
 	if (st.status != IQ_SEND_FAILED) {
 		octeon_report_sent_bytes_to_bql(buf, reqtype);
@@ -533,16 +607,19 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, bytes_sent, datasize);
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_posted, 1);
 
-		if (iq->fill_cnt >= iq->fill_threshold || force_db)
+		if (force_db)
 			ring_doorbell(oct, iq);
 	} else {
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_dropped, 1);
 	}
 
-	spin_unlock_bh(&iq->lock);
+	spin_unlock_bh(&iq->post_lock);
 
-	if (iq->do_auto_flush)
-		octeon_flush_iq(oct, iq, 2);
+	/* This is only done here to expedite packets being flushed
+	 * for cases where there are no IQ completion interrupts.
+	 */
+	/*if (iq->do_auto_flush)*/
+	/*	octeon_flush_iq(oct, iq, 2, 0);*/
 
 	return st.status;
 }
@@ -557,82 +634,78 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 			    u64 ossp1)
 {
 	struct octeon_config *oct_cfg;
-	struct octeon_instr_ih *ih;
+	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
-	BUG_ON(opcode > 15);
-	BUG_ON(subcode > 127);
+	WARN_ON(opcode > 15);
+	WARN_ON(subcode > 127);
 
 	oct_cfg = octeon_get_conf(oct);
 
-	ih          = (struct octeon_instr_ih *)&sc->cmd.ih;
-	ih->tagtype = ATOMIC_TAG;
-	ih->tag     = LIO_CONTROL;
-	ih->raw     = 1;
-	ih->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
+	ih2          = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+	ih2->tagtype = ATOMIC_TAG;
+	ih2->tag     = LIO_CONTROL;
+	ih2->raw     = 1;
+	ih2->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
 
 	if (sc->datasize) {
-		ih->dlengsz = sc->datasize;
-		ih->rs = 1;
+		ih2->dlengsz = sc->datasize;
+		ih2->rs = 1;
 	}
 
-	irh            = (struct octeon_instr_irh *)&sc->cmd.irh;
+	irh            = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 	irh->opcode    = opcode;
 	irh->subcode   = subcode;
 
 	/* opcode/subcode specific parameters (ossp) */
 	irh->ossp       = irh_ossp;
-	sc->cmd.ossp[0] = ossp0;
-	sc->cmd.ossp[1] = ossp1;
+	sc->cmd.cmd2.ossp[0] = ossp0;
+	sc->cmd.cmd2.ossp[1] = ossp1;
 
 	if (sc->rdatasize) {
-		rdp            = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
 		rdp->pcie_port = oct->pcie_port;
 		rdp->rlen      = sc->rdatasize;
 
 		irh->rflag =  1;
-		irh->len   =  4;
-		ih->fsz    = 40; /* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
+		ih2->fsz   = 40; /* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
 	} else {
 		irh->rflag =  0;
-		irh->len   =  2;
-		ih->fsz    = 24; /* irh + ossp[0] + ossp[1] = 24 bytes */
+		ih2->fsz   = 24; /* irh + ossp[0] + ossp[1] = 24 bytes */
 	}
-
-	while (!(oct->io_qmask.iq & (1 << sc->iq_no)))
-		sc->iq_no++;
 }
 
 int octeon_send_soft_command(struct octeon_device *oct,
 			     struct octeon_soft_command *sc)
 {
-	struct octeon_instr_ih *ih;
+	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
+	u32 len;
 
-	ih = (struct octeon_instr_ih *)&sc->cmd.ih;
-	if (ih->dlengsz) {
-		BUG_ON(!sc->dmadptr);
-		sc->cmd.dptr = sc->dmadptr;
+	ih2 = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+	if (ih2->dlengsz) {
+		WARN_ON(!sc->dmadptr);
+		sc->cmd.cmd2.dptr = sc->dmadptr;
 	}
-
-	irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+	irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 	if (irh->rflag) {
-		BUG_ON(!sc->dmarptr);
-		BUG_ON(!sc->status_word);
+		WARN_ON(!sc->dmarptr);
+		WARN_ON(!sc->status_word);
 		*sc->status_word = COMPLETION_WORD_INIT;
 
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
 
-		sc->cmd.rptr = sc->dmarptr;
+		sc->cmd.cmd2.rptr = sc->dmarptr;
 	}
+	len = (u32)ih2->dlengsz;
 
 	if (sc->wait_time)
 		sc->timeout = jiffies + sc->wait_time;
 
-	return octeon_send_command(oct, sc->iq_no, 1, &sc->cmd, sc,
-				   (u32)ih->dlengsz, REQTYPE_SOFT_COMMAND);
+	return (octeon_send_command(oct, sc->iq_no, 1, &sc->cmd, sc,
+				    len, REQTYPE_SOFT_COMMAND));
 }
 
 int octeon_setup_sc_buffer_pool(struct octeon_device *oct)
@@ -667,7 +740,7 @@ int octeon_free_sc_buffer_pool(struct octeon_device *oct)
 	struct list_head *tmp, *tmp2;
 	struct octeon_soft_command *sc;
 
-	spin_lock(&oct->sc_buf_pool.lock);
+	spin_lock_bh(&oct->sc_buf_pool.lock);
 
 	list_for_each_safe(tmp, tmp2, &oct->sc_buf_pool.head) {
 		list_del(tmp);
@@ -679,7 +752,7 @@ int octeon_free_sc_buffer_pool(struct octeon_device *oct)
 
 	INIT_LIST_HEAD(&oct->sc_buf_pool.head);
 
-	spin_unlock(&oct->sc_buf_pool.lock);
+	spin_unlock_bh(&oct->sc_buf_pool.lock);
 
 	return 0;
 }
@@ -695,13 +768,13 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	struct octeon_soft_command *sc = NULL;
 	struct list_head *tmp;
 
-	BUG_ON((offset + datasize + rdatasize + ctxsize) >
+	WARN_ON((offset + datasize + rdatasize + ctxsize) >
 	       SOFT_COMMAND_BUFFER_SIZE);
 
-	spin_lock(&oct->sc_buf_pool.lock);
+	spin_lock_bh(&oct->sc_buf_pool.lock);
 
 	if (list_empty(&oct->sc_buf_pool.head)) {
-		spin_unlock(&oct->sc_buf_pool.lock);
+		spin_unlock_bh(&oct->sc_buf_pool.lock);
 		return NULL;
 	}
 
@@ -712,7 +785,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 
 	atomic_inc(&oct->sc_buf_pool.alloc_buf_count);
 
-	spin_unlock(&oct->sc_buf_pool.lock);
+	spin_unlock_bh(&oct->sc_buf_pool.lock);
 
 	sc = (struct octeon_soft_command *)tmp;
 
@@ -742,7 +815,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	offset = (offset + datasize + 127) & 0xffffff80;
 
 	if (rdatasize) {
-		BUG_ON(rdatasize < 16);
+		WARN_ON(rdatasize < 16);
 		sc->virtrptr = (u8 *)sc + offset;
 		sc->dmarptr = dma_addr + offset;
 		sc->rdatasize = rdatasize;
@@ -755,11 +828,11 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 void octeon_free_soft_command(struct octeon_device *oct,
 			      struct octeon_soft_command *sc)
 {
-	spin_lock(&oct->sc_buf_pool.lock);
+	spin_lock_bh(&oct->sc_buf_pool.lock);
 
 	list_add_tail(&sc->node, &oct->sc_buf_pool.head);
 
 	atomic_dec(&oct->sc_buf_pool.alloc_buf_count);
 
-	spin_unlock(&oct->sc_buf_pool.lock);
+	spin_unlock_bh(&oct->sc_buf_pool.lock);
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 091f537..db1e63b 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -54,6 +54,7 @@ int octeon_setup_response_list(struct octeon_device *oct)
 		spin_lock_init(&oct->response_list[i].lock);
 		atomic_set(&oct->response_list[i].pending_req_count, 0);
 	}
+	spin_lock_init(&oct->cmd_resp_wqlock);
 
 	oct->dma_comp_wq.wq = create_workqueue("dma-comp");
 	if (!oct->dma_comp_wq.wq) {
@@ -64,7 +65,8 @@ int octeon_setup_response_list(struct octeon_device *oct)
 	cwq = &oct->dma_comp_wq;
 	INIT_DELAYED_WORK(&cwq->wk.work, oct_poll_req_completion);
 	cwq->wk.ctxptr = oct;
-	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
+	oct->cmd_resp_state = OCT_DRV_ONLINE;
+	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(50));
 
 	return ret;
 }
@@ -86,6 +88,7 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 	u32 status;
 	u64 status64;
 	struct octeon_instr_rdp *rdp;
+	u64 rptr;
 
 	ordered_sc_list = &octeon_dev->response_list[OCTEON_ORDERED_SC_LIST];
 
@@ -103,7 +106,8 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 
 		sc = (struct octeon_soft_command *)ordered_sc_list->
 		    head.next;
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+		rptr = sc->cmd.cmd2.rptr;
 
 		status = OCTEON_REQUEST_PENDING;
 
@@ -111,7 +115,7 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 		 * to where rptr is pointing to
 		 */
 		dma_sync_single_for_cpu(&octeon_dev->pci_dev->dev,
-					sc->cmd.rptr, rdp->rlen,
+					rptr, rdp->rlen,
 					DMA_FROM_DEVICE);
 		status64 = *sc->status_word;
 
@@ -141,7 +145,6 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 			if (sc->callback)
 				sc->callback(octeon_dev, status,
 					     sc->callback_arg);
-
 			request_complete++;
 
 		} else {
@@ -170,9 +173,8 @@ static void oct_poll_req_completion(struct work_struct *work)
 {
 	struct cavium_wk *wk = (struct cavium_wk *)work;
 	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
-	struct cavium_wq *cwq = &oct->dma_comp_wq;
+	struct cavium_wq *cwq =  &oct->dma_comp_wq;
 
 	lio_process_ordered_list(oct, 0);
-
-	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
+	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(50));
 }
-- 
1.8.3.1
