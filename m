From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 4/5] liquidio CN23XX: mailbox interrupt processing
Date: Fri, 9 Sep 2016 13:08:26 -0700
Message-ID: <1473451707-26397-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam03on0050.outbound.protection.outlook.com ([104.47.42.50]:62176
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754895AbcIIUJC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 16:09:02 -0400
In-Reply-To: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for mailbox interrupt processing of various
commands.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 157 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |   8 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   1 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   6 +
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  28 ++--
 5 files changed, 184 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index b3c61302..4d975d8 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -30,6 +30,7 @@
 #include "octeon_device.h"
 #include "cn23xx_pf_device.h"
 #include "octeon_main.h"
+#include "octeon_mailbox.h"
 
 #define RESET_NOTDONE 0
 #define RESET_DONE 1
@@ -682,6 +683,118 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 	}
 }
 
+static void cn23xx_pf_mbox_thread(struct work_struct *work)
+{
+	struct cavium_wk *wk = (struct cavium_wk *)work;
+	struct octeon_mbox *mbox = (struct octeon_mbox *)wk->ctxptr;
+	struct octeon_device *oct = mbox->oct_dev;
+	u64 mbox_int_val, val64;
+	u32 q_no, i;
+
+	if (oct->rev_id < OCTEON_CN23XX_REV_1_1) {
+		/*read and clear by writing 1*/
+		mbox_int_val = readq(mbox->mbox_int_reg);
+		writeq(mbox_int_val, mbox->mbox_int_reg);
+
+		for (i = 0; i < oct->sriov_info.num_vfs; i++) {
+			q_no = i * oct->sriov_info.rings_per_vf;
+
+			val64 = readq(oct->mbox[q_no]->mbox_write_reg);
+
+			if (val64 && (val64 != OCTEON_PFVFACK)) {
+				if (octeon_mbox_read(oct->mbox[q_no]))
+					octeon_mbox_process_message(
+					    oct->mbox[q_no]);
+			}
+		}
+
+		schedule_delayed_work(&wk->work, msecs_to_jiffies(10));
+	} else {
+		octeon_mbox_process_message(mbox);
+	}
+}
+
+static int cn23xx_setup_pf_mbox(struct octeon_device *oct)
+{
+	u32 q_no, i;
+	u16 mac_no = oct->pcie_port;
+	u16 pf_num = oct->pf_num;
+	struct octeon_mbox *mbox = NULL;
+
+	if (!oct->sriov_info.num_vfs)
+		return 0;
+
+	for (i = 0; i < oct->sriov_info.num_vfs; i++) {
+		q_no = i * oct->sriov_info.rings_per_vf;
+
+		mbox = vmalloc(sizeof(*mbox));
+		if (!mbox)
+			goto free_mbox;
+
+		memset(mbox, 0, sizeof(struct octeon_mbox));
+
+		spin_lock_init(&mbox->lock);
+
+		mbox->oct_dev = oct;
+
+		mbox->q_no = q_no;
+
+		mbox->state = OCTEON_MBOX_STATE_IDLE;
+
+		/* PF mbox interrupt reg */
+		mbox->mbox_int_reg = (u8 *)oct->mmio[0].hw_addr +
+				     CN23XX_SLI_MAC_PF_MBOX_INT(mac_no, pf_num);
+
+		/* PF writes into SIG0 reg */
+		mbox->mbox_write_reg = (u8 *)oct->mmio[0].hw_addr +
+				       CN23XX_SLI_PKT_PF_VF_MBOX_SIG(q_no, 0);
+
+		/* PF reads from SIG1 reg */
+		mbox->mbox_read_reg = (u8 *)oct->mmio[0].hw_addr +
+				      CN23XX_SLI_PKT_PF_VF_MBOX_SIG(q_no, 1);
+
+		/*Mail Box Thread creation*/
+		INIT_DELAYED_WORK(&mbox->mbox_poll_wk.work,
+				  cn23xx_pf_mbox_thread);
+		mbox->mbox_poll_wk.ctxptr = (void *)mbox;
+
+		oct->mbox[q_no] = mbox;
+
+		writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+	}
+
+	if (oct->rev_id < OCTEON_CN23XX_REV_1_1)
+		schedule_delayed_work(&oct->mbox[0]->mbox_poll_wk.work,
+				      msecs_to_jiffies(0));
+
+	return 0;
+
+free_mbox:
+	while (i) {
+		i--;
+		vfree(oct->mbox[i]);
+	}
+
+	return 1;
+}
+
+static int cn23xx_free_pf_mbox(struct octeon_device *oct)
+{
+	u32 q_no, i;
+
+	if (!oct->sriov_info.num_vfs)
+		return 0;
+
+	for (i = 0; i < oct->sriov_info.num_vfs; i++) {
+		q_no = i * oct->sriov_info.rings_per_vf;
+		cancel_delayed_work_sync(
+		    &oct->mbox[q_no]->mbox_poll_wk.work);
+		vfree(oct->mbox[q_no]);
+	}
+
+	return 0;
+}
+
 static int cn23xx_enable_io_queues(struct octeon_device *oct)
 {
 	u64 reg_val;
@@ -876,6 +989,29 @@ static u64 cn23xx_pf_msix_interrupt_handler(void *dev)
 	return ret;
 }
 
+static void cn23xx_handle_pf_mbox_intr(struct octeon_device *oct)
+{
+	u64 mbox_int_val;
+	u32 i, q_no;
+	struct delayed_work *work;
+
+	mbox_int_val = readq(oct->mbox[0]->mbox_int_reg);
+
+	for (i = 0; i < oct->sriov_info.num_vfs; i++) {
+		q_no = i * oct->sriov_info.rings_per_vf;
+
+		if (mbox_int_val & BIT_ULL(q_no)) {
+			writeq(BIT_ULL(q_no),
+			       oct->mbox[0]->mbox_int_reg);
+			if (octeon_mbox_read(oct->mbox[q_no])) {
+				work = &oct->mbox[q_no]->mbox_poll_wk.work;
+				schedule_delayed_work(work,
+						      msecs_to_jiffies(0));
+			}
+		}
+	}
+}
+
 static irqreturn_t cn23xx_interrupt_handler(void *dev)
 {
 	struct octeon_device *oct = (struct octeon_device *)dev;
@@ -891,6 +1027,10 @@ static irqreturn_t cn23xx_interrupt_handler(void *dev)
 		dev_err(&oct->pci_dev->dev, "OCTEON[%d]: Error Intr: 0x%016llx\n",
 			oct->octeon_id, CVM_CAST64(intr64));
 
+	/* When VFs write into MBOX_SIG2 reg,these intr is set in PF */
+	if (intr64 & CN23XX_INTR_VF_MBOX)
+		cn23xx_handle_pf_mbox_intr(oct);
+
 	if (oct->msix_on != LIO_FLAG_MSIX_ENABLED) {
 		if (intr64 & CN23XX_INTR_PKT_DATA)
 			oct->int_status |= OCT_DEV_INTR_PKT_DATA;
@@ -981,6 +1121,13 @@ static void cn23xx_enable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
 		intr_val = readq(cn23xx->intr_enb_reg64);
 		intr_val |= CN23XX_INTR_PKT_DATA;
 		writeq(intr_val, cn23xx->intr_enb_reg64);
+	} else if ((intr_flag & OCTEON_MBOX_INTR) &&
+		   (oct->sriov_info.num_vfs > 0)) {
+		if (oct->rev_id >= OCTEON_CN23XX_REV_1_1) {
+			intr_val = readq(cn23xx->intr_enb_reg64);
+			intr_val |= CN23XX_INTR_VF_MBOX;
+			writeq(intr_val, cn23xx->intr_enb_reg64);
+		}
 	}
 }
 
@@ -996,6 +1143,13 @@ static void cn23xx_disable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
 		intr_val = readq(cn23xx->intr_enb_reg64);
 		intr_val &= ~CN23XX_INTR_PKT_DATA;
 		writeq(intr_val, cn23xx->intr_enb_reg64);
+	} else if ((intr_flag & OCTEON_MBOX_INTR) &&
+		   (oct->sriov_info.num_vfs > 0)) {
+		if (oct->rev_id >= OCTEON_CN23XX_REV_1_1) {
+			intr_val = readq(cn23xx->intr_enb_reg64);
+			intr_val &= ~CN23XX_INTR_VF_MBOX;
+			writeq(intr_val, cn23xx->intr_enb_reg64);
+		}
 	}
 }
 
@@ -1268,6 +1422,9 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 
 	oct->fn_list.setup_iq_regs = cn23xx_setup_iq_regs;
 	oct->fn_list.setup_oq_regs = cn23xx_setup_oq_regs;
+	oct->fn_list.setup_mbox = cn23xx_setup_pf_mbox;
+	oct->fn_list.free_mbox = cn23xx_free_pf_mbox;
+
 	oct->fn_list.process_interrupt_regs = cn23xx_interrupt_handler;
 	oct->fn_list.msix_interrupt_handler = cn23xx_pf_msix_interrupt_handler;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 438d32f..e480c23 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1449,8 +1449,10 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 				pci_disable_msi(oct->pci_dev);
 		}
 
-		if (OCTEON_CN23XX_PF(oct))
+		if (OCTEON_CN23XX_PF(oct)) {
 			octeon_free_ioq_vector(oct);
+			oct->fn_list.free_mbox(oct);
+		}
 	/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
@@ -4275,6 +4277,10 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	atomic_set(&octeon_dev->status, OCT_DEV_DROQ_INIT_DONE);
 
 	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		if (octeon_dev->fn_list.setup_mbox(octeon_dev)) {
+			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: Mailbox setup failed\n");
+			return 1;
+		}
 		if (octeon_allocate_ioq_vector(octeon_dev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: ioq vector allocation failed\n");
 			return 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 03a4eac..1136801 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -768,6 +768,7 @@ octeon_allocate_ioq_vector(struct octeon_device  *oct)
 		ioq_vector->oct_dev	= oct;
 		ioq_vector->iq_index	= i;
 		ioq_vector->droq_index	= i;
+		ioq_vector->mbox	= oct->mbox[i];
 
 		cpu_num = i % num_online_cpus();
 		cpumask_set_cpu(cpu_num, &ioq_vector->affinity_mask);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 3a71451..fc62d7d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -54,6 +54,7 @@ enum octeon_pci_swap_mode {
 };
 
 #define  OCTEON_OUTPUT_INTR   (2)
+#define  OCTEON_MBOX_INTR     (4)
 #define  OCTEON_ALL_INTR      0xff
 
 /*---------------   PCI BAR1 index registers -------------*/
@@ -209,6 +210,10 @@ struct octeon_fn_list {
 
 	irqreturn_t (*process_interrupt_regs)(void *);
 	u64 (*msix_interrupt_handler)(void *);
+
+	int (*setup_mbox)(struct octeon_device *);
+	int (*free_mbox)(struct octeon_device *);
+
 	int (*soft_reset)(struct octeon_device *);
 	int (*setup_device_regs)(struct octeon_device *);
 	void (*bar1_idx_setup)(struct octeon_device *, u64, u32, int);
@@ -349,6 +354,7 @@ struct octeon_ioq_vector {
 	int		        iq_index;
 	int		        droq_index;
 	int			vector;
+	struct octeon_mbox     *mbox;
 	struct cpumask		affinity_mask;
 	u32			ioq_num;
 };
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index f60e532..924f158 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -19,6 +19,7 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
@@ -211,7 +212,7 @@ int octeon_delete_droq(struct octeon_device *oct, u32 q_no)
 {
 	struct octeon_droq *droq = oct->droq[q_no];
 
-	dev_dbg(&oct->pci_dev->dev, "%s[%d]\n", __func__, q_no);
+	pr_devel("%s[%d]\n", __func__, q_no);
 
 	octeon_droq_destroy_ring_buffers(oct, droq);
 	vfree(droq->recv_buf_list);
@@ -243,7 +244,7 @@ int octeon_init_droq(struct octeon_device *oct,
 	int orig_node = dev_to_node(&oct->pci_dev->dev);
 	int numa_node = cpu_to_node(q_no % num_online_cpus());
 
-	dev_dbg(&oct->pci_dev->dev, "%s[%d]\n", __func__, q_no);
+	pr_devel("%s[%d]\n", __func__, q_no);
 
 	droq = oct->droq[q_no];
 	memset(droq, 0, OCT_DROQ_SIZE);
@@ -290,10 +291,10 @@ int octeon_init_droq(struct octeon_device *oct,
 		return 1;
 	}
 
-	dev_dbg(&oct->pci_dev->dev, "droq[%d]: desc_ring: virt: 0x%p, dma: %lx\n",
-		q_no, droq->desc_ring, droq->desc_ring_dma);
-	dev_dbg(&oct->pci_dev->dev, "droq[%d]: num_desc: %d\n", q_no,
-		droq->max_count);
+	pr_devel("droq[%d]: desc_ring: virt: 0x%p, dma: %lx\n",
+		 q_no, droq->desc_ring, droq->desc_ring_dma);
+	pr_devel("droq[%d]: num_desc: %d\n", q_no,
+		 droq->max_count);
 
 	droq->info_list =
 		cnnic_numa_alloc_aligned_dma((droq->max_count *
@@ -327,8 +328,8 @@ int octeon_init_droq(struct octeon_device *oct,
 	droq->pkts_per_intr = c_pkts_per_intr;
 	droq->refill_threshold = c_refill_threshold;
 
-	dev_dbg(&oct->pci_dev->dev, "DROQ INIT: max_empty_descs: %d\n",
-		droq->max_empty_descs);
+	pr_devel("DROQ INIT: max_empty_descs: %d\n",
+		 droq->max_empty_descs);
 
 	spin_lock_init(&droq->lock);
 
@@ -628,9 +629,6 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			dev_err(&oct->pci_dev->dev,
 				"DROQ[%d] idx: %d len:0, pkt_cnt: %d\n",
 				droq->q_no, droq->read_idx, pkt_count);
-			print_hex_dump_bytes("", DUMP_PREFIX_ADDRESS,
-					     (u8 *)info,
-					     OCT_DROQ_INFO_SIZE);
 			break;
 		}
 
@@ -978,8 +976,8 @@ int octeon_create_droq(struct octeon_device *oct,
 	int numa_node = cpu_to_node(q_no % num_online_cpus());
 
 	if (oct->droq[q_no]) {
-		dev_dbg(&oct->pci_dev->dev, "Droq already in use. Cannot create droq %d again\n",
-			q_no);
+		pr_devel("Droq already in use. Cannot create droq %d again\n",
+			 q_no);
 		return 1;
 	}
 
@@ -1000,8 +998,8 @@ int octeon_create_droq(struct octeon_device *oct,
 
 	oct->num_oqs++;
 
-	dev_dbg(&oct->pci_dev->dev, "%s: Total number of OQ: %d\n", __func__,
-		oct->num_oqs);
+	pr_devel("%s: Total number of OQ: %d\n", __func__,
+		 oct->num_oqs);
 
 	/* Global Droq register settings */
 
-- 
1.8.3.1
