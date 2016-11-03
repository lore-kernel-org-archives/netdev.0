From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V4 4/9] liquidio CN23XX: mailbox interrupt processing
Date: Thu, 3 Nov 2016 14:35:13 -0700
Message-ID: <1478208918-8330-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam01on0073.outbound.protection.outlook.com ([104.47.34.73]:60288
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932854AbcKCVgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 17:36:16 -0400
In-Reply-To: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for mailbox interrupt processing of various
commands.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 157 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  12 ++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   1 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  21 ++-
 4 files changed, 184 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 4c93eac..79b8c48 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -30,6 +30,7 @@
 #include "octeon_device.h"
 #include "cn23xx_pf_device.h"
 #include "octeon_main.h"
+#include "octeon_mailbox.h"
 
 #define RESET_NOTDONE 0
 #define RESET_DONE 1
@@ -677,6 +678,118 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
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
+		for (i = 0; i < oct->sriov_info.num_vfs_alloced; i++) {
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
+	struct octeon_mbox *mbox = NULL;
+	u16 mac_no = oct->pcie_port;
+	u16 pf_num = oct->pf_num;
+	u32 q_no, i;
+
+	if (!oct->sriov_info.max_vfs)
+		return 0;
+
+	for (i = 0; i < oct->sriov_info.max_vfs; i++) {
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
+	if (!oct->sriov_info.max_vfs)
+		return 0;
+
+	for (i = 0; i < oct->sriov_info.max_vfs; i++) {
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
@@ -871,6 +984,29 @@ static u64 cn23xx_pf_msix_interrupt_handler(void *dev)
 	return ret;
 }
 
+static void cn23xx_handle_pf_mbox_intr(struct octeon_device *oct)
+{
+	struct delayed_work *work;
+	u64 mbox_int_val;
+	u32 i, q_no;
+
+	mbox_int_val = readq(oct->mbox[0]->mbox_int_reg);
+
+	for (i = 0; i < oct->sriov_info.num_vfs_alloced; i++) {
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
@@ -886,6 +1022,10 @@ static irqreturn_t cn23xx_interrupt_handler(void *dev)
 		dev_err(&oct->pci_dev->dev, "OCTEON[%d]: Error Intr: 0x%016llx\n",
 			oct->octeon_id, CVM_CAST64(intr64));
 
+	/* When VFs write into MBOX_SIG2 reg,these intr is set in PF */
+	if (intr64 & CN23XX_INTR_VF_MBOX)
+		cn23xx_handle_pf_mbox_intr(oct);
+
 	if (oct->msix_on != LIO_FLAG_MSIX_ENABLED) {
 		if (intr64 & CN23XX_INTR_PKT_DATA)
 			oct->int_status |= OCT_DEV_INTR_PKT_DATA;
@@ -976,6 +1116,13 @@ static void cn23xx_enable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
 		intr_val = readq(cn23xx->intr_enb_reg64);
 		intr_val |= CN23XX_INTR_PKT_DATA;
 		writeq(intr_val, cn23xx->intr_enb_reg64);
+	} else if ((intr_flag & OCTEON_MBOX_INTR) &&
+		   (oct->sriov_info.max_vfs > 0)) {
+		if (oct->rev_id >= OCTEON_CN23XX_REV_1_1) {
+			intr_val = readq(cn23xx->intr_enb_reg64);
+			intr_val |= CN23XX_INTR_VF_MBOX;
+			writeq(intr_val, cn23xx->intr_enb_reg64);
+		}
 	}
 }
 
@@ -991,6 +1138,13 @@ static void cn23xx_disable_pf_interrupt(struct octeon_device *oct, u8 intr_flag)
 		intr_val = readq(cn23xx->intr_enb_reg64);
 		intr_val &= ~CN23XX_INTR_PKT_DATA;
 		writeq(intr_val, cn23xx->intr_enb_reg64);
+	} else if ((intr_flag & OCTEON_MBOX_INTR) &&
+		   (oct->sriov_info.max_vfs > 0)) {
+		if (oct->rev_id >= OCTEON_CN23XX_REV_1_1) {
+			intr_val = readq(cn23xx->intr_enb_reg64);
+			intr_val &= ~CN23XX_INTR_VF_MBOX;
+			writeq(intr_val, cn23xx->intr_enb_reg64);
+		}
 	}
 }
 
@@ -1137,6 +1291,9 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 
 	oct->fn_list.setup_iq_regs = cn23xx_setup_iq_regs;
 	oct->fn_list.setup_oq_regs = cn23xx_setup_oq_regs;
+	oct->fn_list.setup_mbox = cn23xx_setup_pf_mbox;
+	oct->fn_list.free_mbox = cn23xx_free_pf_mbox;
+
 	oct->fn_list.process_interrupt_regs = cn23xx_interrupt_handler;
 	oct->fn_list.msix_interrupt_handler = cn23xx_pf_msix_interrupt_handler;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 29f5985..438465b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1441,6 +1441,12 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		if (OCTEON_CN23XX_PF(oct))
 			octeon_free_ioq_vector(oct);
+
+	/* fallthrough */
+	case OCT_DEV_MBOX_SETUP_DONE:
+		if (OCTEON_CN23XX_PF(oct))
+			oct->fn_list.free_mbox(oct);
+
 	/* fallthrough */
 	case OCT_DEV_IN_RESET:
 	case OCT_DEV_DROQ_INIT_DONE:
@@ -4307,6 +4313,12 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	atomic_set(&octeon_dev->status, OCT_DEV_DROQ_INIT_DONE);
 
 	if (OCTEON_CN23XX_PF(octeon_dev)) {
+		if (octeon_dev->fn_list.setup_mbox(octeon_dev)) {
+			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: Mailbox setup failed\n");
+			return 1;
+		}
+		atomic_set(&octeon_dev->status, OCT_DEV_MBOX_SETUP_DONE);
+
 		if (octeon_allocate_ioq_vector(octeon_dev)) {
 			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: ioq vector allocation failed\n");
 			return 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 586b688..7f532fd 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -767,6 +767,7 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 		ioq_vector->oct_dev	= oct;
 		ioq_vector->iq_index	= i;
 		ioq_vector->droq_index	= i;
+		ioq_vector->mbox	= oct->mbox[i];
 
 		cpu_num = i % num_online_cpus();
 		cpumask_set_cpu(cpu_num, &ioq_vector->affinity_mask);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 77a6eb7..bdb10a0 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -54,6 +54,7 @@ enum octeon_pci_swap_mode {
 };
 
 #define  OCTEON_OUTPUT_INTR   (2)
+#define  OCTEON_MBOX_INTR     (4)
 #define  OCTEON_ALL_INTR      0xff
 
 /*---------------   PCI BAR1 index registers -------------*/
@@ -77,13 +78,14 @@ enum octeon_pci_swap_mode {
 #define    OCT_DEV_SC_BUFF_POOL_INIT_DONE 0x4
 #define    OCT_DEV_RESP_LIST_INIT_DONE    0x5
 #define    OCT_DEV_DROQ_INIT_DONE         0x6
-#define    OCT_DEV_IO_QUEUES_DONE         0x7
-#define    OCT_DEV_CONSOLE_INIT_DONE      0x8
-#define    OCT_DEV_HOST_OK                0x9
-#define    OCT_DEV_CORE_OK                0xa
-#define    OCT_DEV_RUNNING                0xb
-#define    OCT_DEV_IN_RESET               0xc
-#define    OCT_DEV_STATE_INVALID          0xd
+#define    OCT_DEV_MBOX_SETUP_DONE        0x8
+#define    OCT_DEV_IO_QUEUES_DONE         0x9
+#define    OCT_DEV_CONSOLE_INIT_DONE      0xa
+#define    OCT_DEV_HOST_OK                0xb
+#define    OCT_DEV_CORE_OK                0xc
+#define    OCT_DEV_RUNNING                0xd
+#define    OCT_DEV_IN_RESET               0xe
+#define    OCT_DEV_STATE_INVALID          0xf
 
 #define    OCT_DEV_STATES                 OCT_DEV_STATE_INVALID
 
@@ -209,6 +211,10 @@ struct octeon_fn_list {
 
 	irqreturn_t (*process_interrupt_regs)(void *);
 	u64 (*msix_interrupt_handler)(void *);
+
+	int (*setup_mbox)(struct octeon_device *);
+	int (*free_mbox)(struct octeon_device *);
+
 	int (*soft_reset)(struct octeon_device *);
 	int (*setup_device_regs)(struct octeon_device *);
 	void (*bar1_idx_setup)(struct octeon_device *, u64, u32, int);
@@ -355,6 +361,7 @@ struct octeon_ioq_vector {
 	int		        iq_index;
 	int		        droq_index;
 	int			vector;
+	struct octeon_mbox     *mbox;
 	struct cpumask		affinity_mask;
 	u32			ioq_num;
 };
-- 
1.8.3.1
