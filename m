From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 8/9] liquidio CN23XX: VF interrupt
Date: Sun, 27 Nov 2016 20:51:41 -0800
Message-ID: <1480308702-6261-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0082.outbound.protection.outlook.com ([104.47.41.82]:58144
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754134AbcK1Ewm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 23:52:42 -0500
In-Reply-To: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF interrupt processing.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    | 265 +++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   6 +
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |   7 -
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 162 +++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   3 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 6 files changed, 438 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
index e514797..9ded8fc 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -27,6 +27,26 @@
 #include "octeon_main.h"
 #include "octeon_mailbox.h"
 
+u32 cn23xx_vf_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us)
+{
+	/* This gives the SLI clock per microsec */
+	u32 oqticks_per_us = (u32)oct->pfvf_hsword.coproc_tics_per_us;
+
+	/* This gives the clock cycles per millisecond */
+	oqticks_per_us *= 1000;
+
+	/* This gives the oq ticks (1024 core clock cycles) per millisecond */
+	oqticks_per_us /= 1024;
+
+	/* time_intr is in microseconds. The next 2 steps gives the oq ticks
+	 * corressponding to time_intr.
+	 */
+	oqticks_per_us *= time_intr_in_us;
+	oqticks_per_us /= 1000;
+
+	return oqticks_per_us;
+}
+
 static int cn23xx_vf_reset_io_queues(struct octeon_device *oct, u32 num_queues)
 {
 	u32 loop = BUSY_READING_REG_VF_LOOP_COUNT;
@@ -212,6 +232,11 @@ static void cn23xx_setup_vf_iq_regs(struct octeon_device *oct, u32 iq_no)
 	 */
 	pkt_in_done = readq(iq->inst_cnt_reg);
 
+	if (oct->msix_on) {
+		/* Set CINT_ENB to enable IQ interrupt */
+		writeq((pkt_in_done | CN23XX_INTR_CINT_ENB),
+		       iq->inst_cnt_reg);
+	}
 	iq->reset_instr_cnt = 0;
 }
 
@@ -342,6 +367,240 @@ static void cn23xx_disable_vf_io_queues(struct octeon_device *oct)
 	cn23xx_vf_reset_io_queues(oct, num_queues);
 }
 
+void cn23xx_vf_ask_pf_to_do_flr(struct octeon_device *oct)
+{
+	struct octeon_mbox_cmd mbox_cmd;
+
+	mbox_cmd.msg.u64 = 0;
+	mbox_cmd.msg.s.type = OCTEON_MBOX_REQUEST;
+	mbox_cmd.msg.s.resp_needed = 0;
+	mbox_cmd.msg.s.cmd = OCTEON_VF_FLR_REQUEST;
+	mbox_cmd.msg.s.len = 1;
+	mbox_cmd.q_no = 0;
+	mbox_cmd.recv_len = 0;
+	mbox_cmd.recv_status = 0;
+	mbox_cmd.fn = NULL;
+	mbox_cmd.fn_arg = 0;
+
+	octeon_mbox_write(oct, &mbox_cmd);
+}
+
+static void octeon_pfvf_hs_callback(struct octeon_device *oct,
+				    struct octeon_mbox_cmd *cmd,
+				    void *arg)
+{
+	u32 major = 0;
+
+	memcpy((uint8_t *)&oct->pfvf_hsword, cmd->msg.s.params,
+	       CN23XX_MAILBOX_MSGPARAM_SIZE);
+	if (cmd->recv_len > 1)  {
+		major = ((struct lio_version *)(cmd->data))->major;
+		major = major << 16;
+	}
+
+	atomic_set((atomic_t *)arg, major | 1);
+}
+
+int cn23xx_octeon_pfvf_handshake(struct octeon_device *oct)
+{
+	struct octeon_mbox_cmd mbox_cmd;
+	u32 q_no, count = 0;
+	atomic_t status;
+	u32 pfmajor;
+	u32 vfmajor;
+	u32 ret;
+
+	/* Sending VF_ACTIVE indication to the PF driver */
+	dev_dbg(&oct->pci_dev->dev, "requesting info from pf\n");
+
+	mbox_cmd.msg.u64 = 0;
+	mbox_cmd.msg.s.type = OCTEON_MBOX_REQUEST;
+	mbox_cmd.msg.s.resp_needed = 1;
+	mbox_cmd.msg.s.cmd = OCTEON_VF_ACTIVE;
+	mbox_cmd.msg.s.len = 2;
+	mbox_cmd.data[0] = 0;
+	((struct lio_version *)&mbox_cmd.data[0])->major =
+						LIQUIDIO_BASE_MAJOR_VERSION;
+	((struct lio_version *)&mbox_cmd.data[0])->minor =
+						LIQUIDIO_BASE_MINOR_VERSION;
+	((struct lio_version *)&mbox_cmd.data[0])->micro =
+						LIQUIDIO_BASE_MICRO_VERSION;
+	mbox_cmd.q_no = 0;
+	mbox_cmd.recv_len = 0;
+	mbox_cmd.recv_status = 0;
+	mbox_cmd.fn = (octeon_mbox_callback_t)octeon_pfvf_hs_callback;
+	mbox_cmd.fn_arg = (void *)&status;
+
+	/* Interrupts are not enabled at this point.
+	 * Enable them with default oq ticks
+	 */
+	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
+
+	octeon_mbox_write(oct, &mbox_cmd);
+
+	atomic_set(&status, 0);
+
+	do {
+		schedule_timeout_uninterruptible(1);
+	} while ((!atomic_read(&status)) && (count++ < 100000));
+
+	/* Disable the interrupt so that the interrupsts will be reenabled
+	 * with the oq ticks received from the PF
+	 */
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
+
+	ret = atomic_read(&status);
+	if (!ret) {
+		dev_err(&oct->pci_dev->dev, "octeon_pfvf_handshake timeout\n");
+		return 1;
+	}
+
+	for (q_no = 0 ; q_no < oct->num_iqs ; q_no++)
+		oct->instr_queue[q_no]->txpciq.s.pkind = oct->pfvf_hsword.pkind;
+
+	vfmajor = LIQUIDIO_BASE_MAJOR_VERSION;
+	pfmajor = ret >> 16;
+	if (pfmajor != vfmajor) {
+		dev_err(&oct->pci_dev->dev,
+			"VF Liquidio driver (major version %d) is not compatible with Liquidio PF driver (major version %d)\n",
+			vfmajor, pfmajor);
+		return 1;
+	}
+
+	dev_dbg(&oct->pci_dev->dev,
+		"VF Liquidio driver (major version %d), Liquidio PF driver (major version %d)\n",
+		vfmajor, pfmajor);
+
+	dev_dbg(&oct->pci_dev->dev, "got data from pf pkind is %d\n",
+		oct->pfvf_hsword.pkind);
+
+	return 0;
+}
+
+static void cn23xx_handle_vf_mbox_intr(struct octeon_ioq_vector *ioq_vector)
+{
+	struct octeon_device *oct = ioq_vector->oct_dev;
+	u64 mbox_int_val;
+
+	if (!ioq_vector->droq_index) {
+		/* read and clear by writing 1 */
+		mbox_int_val = readq(oct->mbox[0]->mbox_int_reg);
+		writeq(mbox_int_val, oct->mbox[0]->mbox_int_reg);
+		if (octeon_mbox_read(oct->mbox[0]))
+			schedule_delayed_work(&oct->mbox[0]->mbox_poll_wk.work,
+					      msecs_to_jiffies(0));
+	}
+}
+
+static u64 cn23xx_vf_msix_interrupt_handler(void *dev)
+{
+	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
+	struct octeon_device *oct = ioq_vector->oct_dev;
+	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
+	u64 pkts_sent;
+	u64 ret = 0;
+
+	dev_dbg(&oct->pci_dev->dev, "In %s octeon_dev @ %p\n", __func__, oct);
+	pkts_sent = readq(droq->pkts_sent_reg);
+
+	/* If our device has interrupted, then proceed. Also check
+	 * for all f's if interrupt was triggered on an error
+	 * and the PCI read fails.
+	 */
+	if (!pkts_sent || (pkts_sent == 0xFFFFFFFFFFFFFFFFULL))
+		return ret;
+
+	/* Write count reg in sli_pkt_cnts to clear these int. */
+	if ((pkts_sent & CN23XX_INTR_PO_INT) ||
+	    (pkts_sent & CN23XX_INTR_PI_INT)) {
+		if (pkts_sent & CN23XX_INTR_PO_INT)
+			ret |= MSIX_PO_INT;
+	}
+
+	if (pkts_sent & CN23XX_INTR_PI_INT)
+		/* We will clear the count when we update the read_index. */
+		ret |= MSIX_PI_INT;
+
+	if (pkts_sent & CN23XX_INTR_MBOX_INT) {
+		cn23xx_handle_vf_mbox_intr(ioq_vector);
+		ret |= MSIX_MBOX_INT;
+	}
+
+	return ret;
+}
+
+static void cn23xx_enable_vf_interrupt(struct octeon_device *oct, u8 intr_flag)
+{
+	struct octeon_cn23xx_vf *cn23xx = (struct octeon_cn23xx_vf *)oct->chip;
+	u32 q_no, time_threshold;
+
+	if (intr_flag & OCTEON_OUTPUT_INTR) {
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			/* Set up interrupt packet and time thresholds
+			 * for all the OQs
+			 */
+			time_threshold = cn23xx_vf_get_oq_ticks(
+				oct, (u32)CFG_GET_OQ_INTR_TIME(cn23xx->conf));
+
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no),
+			    (CFG_GET_OQ_INTR_PKT(cn23xx->conf) |
+			     ((u64)time_threshold << 32)));
+		}
+	}
+
+	if (intr_flag & OCTEON_INPUT_INTR) {
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			/* Set CINT_ENB to enable IQ interrupt */
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no),
+			    ((octeon_read_csr64(
+				  oct, CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no)) &
+			      ~CN23XX_PKT_IN_DONE_CNT_MASK) |
+			     CN23XX_INTR_CINT_ENB));
+		}
+	}
+
+	/* Set queue-0 MBOX_ENB to enable VF mailbox interrupt */
+	if (intr_flag & OCTEON_MBOX_INTR) {
+		octeon_write_csr64(
+		    oct, CN23XX_VF_SLI_PKT_MBOX_INT(0),
+		    (octeon_read_csr64(oct, CN23XX_VF_SLI_PKT_MBOX_INT(0)) |
+		     CN23XX_INTR_MBOX_ENB));
+	}
+}
+
+static void cn23xx_disable_vf_interrupt(struct octeon_device *oct, u8 intr_flag)
+{
+	u32 q_no;
+
+	if (intr_flag & OCTEON_OUTPUT_INTR) {
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			/* Write all 1's in INT_LEVEL reg to disable PO_INT */
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no),
+			    0x3fffffffffffff);
+		}
+	}
+	if (intr_flag & OCTEON_INPUT_INTR) {
+		for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no),
+			    (octeon_read_csr64(
+				 oct, CN23XX_VF_SLI_IQ_INSTR_COUNT64(q_no)) &
+			     ~(CN23XX_INTR_CINT_ENB |
+			       CN23XX_PKT_IN_DONE_CNT_MASK)));
+		}
+	}
+
+	if (intr_flag & OCTEON_MBOX_INTR) {
+		octeon_write_csr64(
+		    oct, CN23XX_VF_SLI_PKT_MBOX_INT(0),
+		    (octeon_read_csr64(oct, CN23XX_VF_SLI_PKT_MBOX_INT(0)) &
+		     ~CN23XX_INTR_MBOX_ENB));
+	}
+}
+
 int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 {
 	struct octeon_cn23xx_vf *cn23xx = (struct octeon_cn23xx_vf *)oct->chip;
@@ -397,8 +656,14 @@ int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 	oct->fn_list.setup_oq_regs = cn23xx_setup_vf_oq_regs;
 	oct->fn_list.setup_mbox = cn23xx_setup_vf_mbox;
 	oct->fn_list.free_mbox = cn23xx_free_vf_mbox;
+
+	oct->fn_list.msix_interrupt_handler = cn23xx_vf_msix_interrupt_handler;
+
 	oct->fn_list.setup_device_regs = cn23xx_setup_vf_device_regs;
 
+	oct->fn_list.enable_interrupt = cn23xx_enable_vf_interrupt;
+	oct->fn_list.disable_interrupt = cn23xx_disable_vf_interrupt;
+
 	oct->fn_list.enable_io_queues = cn23xx_enable_vf_io_queues;
 	oct->fn_list.disable_io_queues = cn23xx_disable_vf_io_queues;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index d17c1ce..8590bdb 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -34,6 +34,12 @@ struct octeon_cn23xx_vf {
 
 #define BUSY_READING_REG_VF_LOOP_COUNT		10000
 
+#define CN23XX_MAILBOX_MSGPARAM_SIZE		6
+
+void cn23xx_vf_ask_pf_to_do_flr(struct octeon_device *oct);
+
+int cn23xx_octeon_pfvf_handshake(struct octeon_device *oct);
+
 int cn23xx_setup_octeon_vf_device(struct octeon_device *oct);
 
 void cn23xx_dump_vf_initialized_regs(struct octeon_device *oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 403bcaa..f629c2f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -85,13 +85,6 @@ void octeon_update_tx_completion_counters(void *buf, int reqtype,
 	}
 
 	(*pkts_compl)++;
-/*TODO, Use some other pound define to suggest
- * the fact that iqs are not tied to netdevs
- * and can take traffic from different netdevs
- * hence bql reporting is done per packet
- * than in bulk. Usage of NO_NAPI in txq completion is
- * a little confusing
- */
 	*bytes_compl += skb->len;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index e8eaece..337285b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -59,6 +59,118 @@ struct octeon_device_priv {
 	.remove		= liquidio_vf_remove,
 };
 
+static
+int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
+{
+	struct octeon_device *oct = droq->oct_dev;
+	struct octeon_device_priv *oct_priv =
+	    (struct octeon_device_priv *)oct->priv;
+
+	if (droq->ops.poll_mode) {
+		droq->ops.napi_fn(droq);
+	} else {
+		if (ret & MSIX_PO_INT) {
+			dev_err(&oct->pci_dev->dev,
+				"should not come here should not get rx when poll mode = 0 for vf\n");
+			tasklet_schedule(&oct_priv->droq_tasklet);
+			return 1;
+		}
+		/* this will be flushed periodically by check iq db */
+		if (ret & MSIX_PI_INT)
+			return 0;
+	}
+	return 0;
+}
+
+static irqreturn_t
+liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
+{
+	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
+	struct octeon_device *oct = ioq_vector->oct_dev;
+	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
+	u64 ret;
+
+	ret = oct->fn_list.msix_interrupt_handler(ioq_vector);
+
+	if ((ret & MSIX_PO_INT) || (ret & MSIX_PI_INT))
+		liquidio_schedule_msix_droq_pkt_handler(droq, ret);
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * \brief Setup interrupt for octeon device
+ * @param oct octeon device
+ *
+ *  Enable interrupt in Octeon device as given in the PCI interrupt mask.
+ */
+static int octeon_setup_interrupt(struct octeon_device *oct)
+{
+	struct msix_entry *msix_entries;
+	int num_alloc_ioq_vectors;
+	int num_ioq_vectors;
+	int irqret;
+	int i;
+
+	if (oct->msix_on) {
+		oct->num_msix_irqs = oct->sriov_info.rings_per_vf;
+
+		oct->msix_entries = kcalloc(
+		    oct->num_msix_irqs, sizeof(struct msix_entry), GFP_KERNEL);
+		if (!oct->msix_entries)
+			return 1;
+
+		msix_entries = (struct msix_entry *)oct->msix_entries;
+
+		for (i = 0; i < oct->num_msix_irqs; i++)
+			msix_entries[i].entry = i;
+		num_alloc_ioq_vectors = pci_enable_msix_range(
+						oct->pci_dev, msix_entries,
+						oct->num_msix_irqs,
+						oct->num_msix_irqs);
+		if (num_alloc_ioq_vectors < 0) {
+			dev_err(&oct->pci_dev->dev, "unable to Allocate MSI-X interrupts\n");
+			kfree(oct->msix_entries);
+			oct->msix_entries = NULL;
+			return 1;
+		}
+		dev_dbg(&oct->pci_dev->dev, "OCTEON: Enough MSI-X interrupts are allocated...\n");
+
+		num_ioq_vectors = oct->num_msix_irqs;
+
+		for (i = 0; i < num_ioq_vectors; i++) {
+			irqret = request_irq(msix_entries[i].vector,
+					     liquidio_msix_intr_handler, 0,
+					     "octeon", &oct->ioq_vector[i]);
+			if (irqret) {
+				dev_err(&oct->pci_dev->dev,
+					"OCTEON: Request_irq failed for MSIX interrupt Error: %d\n",
+					irqret);
+
+				while (i) {
+					i--;
+					irq_set_affinity_hint(
+					    msix_entries[i].vector, NULL);
+					free_irq(msix_entries[i].vector,
+						 &oct->ioq_vector[i]);
+				}
+				pci_disable_msix(oct->pci_dev);
+				kfree(oct->msix_entries);
+				oct->msix_entries = NULL;
+				return 1;
+			}
+			oct->ioq_vector[i].vector = msix_entries[i].vector;
+			/* assign the cpu mask for this msix interrupt vector */
+			irq_set_affinity_hint(
+			    msix_entries[i].vector,
+			    (&oct->ioq_vector[i].affinity_mask));
+		}
+		dev_dbg(&oct->pci_dev->dev,
+			"OCTEON[%d]: MSI-X enabled\n", oct->octeon_id);
+	}
+	return 0;
+}
+
 /**
  * \brief PCI probe handler
  * @param pdev PCI device structure
@@ -77,6 +189,7 @@ struct octeon_device_priv {
 		dev_err(&pdev->dev, "Unable to allocate device\n");
 		return -ENOMEM;
 	}
+	oct_dev->msix_on = LIO_FLAG_MSIX_ENABLED;
 
 	dev_info(&pdev->dev, "Initializing device %x:%x.\n",
 		 (u32)pdev->vendor, (u32)pdev->device);
@@ -140,9 +253,37 @@ static void octeon_pci_flr(struct octeon_device *oct)
  */
 static void octeon_destroy_resources(struct octeon_device *oct)
 {
+	struct msix_entry *msix_entries;
 	int i;
 
 	switch (atomic_read(&oct->status)) {
+	case OCT_DEV_INTR_SET_DONE:
+		/* Disable interrupts  */
+		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
+
+		if (oct->msix_on) {
+			msix_entries = (struct msix_entry *)oct->msix_entries;
+			for (i = 0; i < oct->num_msix_irqs; i++) {
+				irq_set_affinity_hint(msix_entries[i].vector,
+						      NULL);
+				free_irq(msix_entries[i].vector,
+					 &oct->ioq_vector[i]);
+			}
+			pci_disable_msix(oct->pci_dev);
+			kfree(oct->msix_entries);
+			oct->msix_entries = NULL;
+		}
+		/* Soft reset the octeon device before exiting */
+		if (oct->pci_dev->reset_fn)
+			octeon_pci_flr(oct);
+		else
+			cn23xx_vf_ask_pf_to_do_flr(oct);
+
+		/* fallthrough */
+	case OCT_DEV_MSIX_ALLOC_VECTOR_DONE:
+		octeon_free_ioq_vector(oct);
+
+		/* fallthrough */
 	case OCT_DEV_MBOX_SETUP_DONE:
 		oct->fn_list.free_mbox(oct);
 
@@ -326,6 +467,27 @@ static int octeon_device_init(struct octeon_device *oct)
 	}
 	atomic_set(&oct->status, OCT_DEV_MBOX_SETUP_DONE);
 
+	if (octeon_allocate_ioq_vector(oct)) {
+		dev_err(&oct->pci_dev->dev, "ioq vector allocation failed\n");
+		return 1;
+	}
+	atomic_set(&oct->status, OCT_DEV_MSIX_ALLOC_VECTOR_DONE);
+
+	dev_info(&oct->pci_dev->dev, "OCTEON_CN23XX VF Version: %s, %d ioqs\n",
+		 LIQUIDIO_VERSION, oct->sriov_info.rings_per_vf);
+
+	/* Setup the interrupt handler and record the INT SUM register address*/
+	if (octeon_setup_interrupt(oct))
+		return 1;
+
+	if (cn23xx_octeon_pfvf_handshake(oct))
+		return 1;
+
+	/* Enable Octeon device interrupts */
+	oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
+
+	atomic_set(&oct->status, OCT_DEV_INTR_SET_DONE);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 8af08d4..a5bd796 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -754,6 +754,9 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 
 	if (OCTEON_CN23XX_PF(oct))
 		num_ioqs = oct->sriov_info.num_pf_rings;
+	else if (OCTEON_CN23XX_VF(oct))
+		num_ioqs = oct->sriov_info.rings_per_vf;
+
 	size = sizeof(struct octeon_ioq_vector) * num_ioqs;
 
 	oct->ioq_vector = vmalloc(size);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 1e6bfa1..18f6836 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -53,6 +53,7 @@ enum {
 	NUM_OCTEON_CONFS,
 };
 
+#define  OCTEON_INPUT_INTR    (1)
 #define  OCTEON_OUTPUT_INTR   (2)
 #define  OCTEON_MBOX_INTR     (4)
 #define  OCTEON_ALL_INTR      0xff
@@ -294,6 +295,7 @@ struct octdev_props {
 #define LIO_FLAG_MSIX_ENABLED	0x1
 #define MSIX_PO_INT		0x1
 #define MSIX_PI_INT		0x2
+#define MSIX_MBOX_INT		0x4
 
 struct octeon_pf_vf_hs_word {
 #ifdef __LITTLE_ENDIAN_BITFIELD
-- 
1.8.3.1
