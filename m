From: Manish Rangankar <manish.rangankar@cavium.com>
Subject: [PATCH v2 4/6] qedi: Add LL2 iSCSI interface for offload iSCSI.
Date: Mon, 7 Nov 2016 22:57:01 -0800
Message-ID: <1478588223-16183-5-git-send-email-manish.rangankar@cavium.com>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <Yuval.Mintz@cavium.com>
To: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for iscsiuio interface using Light L2 (LL2) qed
interface.

Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
Signed-off-by: Arun Easi <arun.easi@cavium.com>
Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
---
 drivers/scsi/qedi/qedi.h      |  73 +++++++++
 drivers/scsi/qedi/qedi_main.c | 357 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 430 insertions(+)

diff --git a/drivers/scsi/qedi/qedi.h b/drivers/scsi/qedi/qedi.h
index 92136a3..e00c141 100644
--- a/drivers/scsi/qedi/qedi.h
+++ b/drivers/scsi/qedi/qedi.h
@@ -21,6 +21,7 @@
 #include <linux/qed/qed_if.h>
 #include "qedi_dbg.h"
 #include <linux/qed/qed_iscsi_if.h>
+#include <linux/qed/qed_ll2_if.h>
 #include "qedi_version.h"
 
 #define QEDI_MODULE_NAME		"qedi"
@@ -54,6 +55,78 @@
 #define QEDI_LOCAL_PORT_MAX     61024
 #define QEDI_LOCAL_PORT_RANGE   (QEDI_LOCAL_PORT_MAX - QEDI_LOCAL_PORT_MIN)
 #define QEDI_LOCAL_PORT_INVALID	0xffff
+#define TX_RX_RING		16
+#define RX_RING			(TX_RX_RING - 1)
+#define LL2_SINGLE_BUF_SIZE	0x400
+#define QEDI_PAGE_SIZE		4096
+#define QEDI_PAGE_ALIGN(addr)	ALIGN(addr, QEDI_PAGE_SIZE)
+#define QEDI_PAGE_MASK		(~((QEDI_PAGE_SIZE) - 1))
+
+#define QEDI_PAGE_SIZE		4096
+#define QEDI_PATH_HANDLE	0xFE0000000UL
+
+struct qedi_uio_ctrl {
+	/* meta data */
+	u32 uio_hsi_version;
+
+	/* user writes */
+	u32 host_tx_prod;
+	u32 host_rx_cons;
+	u32 host_rx_bd_cons;
+	u32 host_tx_pkt_len;
+	u32 host_rx_cons_cnt;
+
+	/* driver writes */
+	u32 hw_tx_cons;
+	u32 hw_rx_prod;
+	u32 hw_rx_bd_prod;
+	u32 hw_rx_prod_cnt;
+
+	/* other */
+	u8 mac_addr[6];
+	u8 reserve[2];
+};
+
+struct qedi_rx_bd {
+	u32 rx_pkt_index;
+	u32 rx_pkt_len;
+	u16 vlan_id;
+};
+
+#define QEDI_RX_DESC_CNT	(QEDI_PAGE_SIZE / sizeof(struct qedi_rx_bd))
+#define QEDI_MAX_RX_DESC_CNT	(QEDI_RX_DESC_CNT - 1)
+#define QEDI_NUM_RX_BD		(QEDI_RX_DESC_CNT * 1)
+#define QEDI_MAX_RX_BD		(QEDI_NUM_RX_BD - 1)
+
+#define QEDI_NEXT_RX_IDX(x)	((((x) & (QEDI_MAX_RX_DESC_CNT)) ==	\
+				  (QEDI_MAX_RX_DESC_CNT - 1)) ?		\
+				 (x) + 2 : (x) + 1)
+
+struct qedi_uio_dev {
+	struct uio_info		qedi_uinfo;
+	u32			uio_dev;
+	struct list_head	list;
+
+	u32			ll2_ring_size;
+	void			*ll2_ring;
+
+	u32			ll2_buf_size;
+	void			*ll2_buf;
+
+	void			*rx_pkt;
+	void			*tx_pkt;
+
+	struct qedi_ctx		*qedi;
+	struct pci_dev		*pdev;
+	void			*uctrl;
+};
+
+/* List to maintain the skb pointers */
+struct skb_work_list {
+	struct list_head list;
+	struct sk_buff *skb;
+	u16 vlan_id;
+};
 
 /* Queue sizes in number of elements */
 #define QEDI_SQ_SIZE		MAX_OUSTANDING_TASKS_PER_CON
diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
index 5845dc9..ef309c6 100644
--- a/drivers/scsi/qedi/qedi_main.c
+++ b/drivers/scsi/qedi/qedi_main.c
@@ -45,10 +45,13 @@
 static struct scsi_transport_template *qedi_scsi_transport;
 static struct pci_driver qedi_pci_driver;
 static DEFINE_PER_CPU(struct qedi_percpu_s, qedi_percpu);
+static LIST_HEAD(qedi_udev_list);
 /* Static function declaration */
 static int qedi_alloc_global_queues(struct qedi_ctx *qedi);
 static void qedi_free_global_queues(struct qedi_ctx *qedi);
 static struct qedi_cmd *qedi_get_cmd_from_tid(struct qedi_ctx *qedi, u32 tid);
+static void qedi_reset_uio_rings(struct qedi_uio_dev *udev);
+static void qedi_ll2_free_skbs(struct qedi_ctx *qedi);
 
 static int qedi_iscsi_event_cb(void *context, u8 fw_event_code, void *fw_handle)
 {
@@ -113,6 +116,224 @@ static int qedi_iscsi_event_cb(void *context, u8 fw_event_code, void *fw_handle)
 	return rval;
 }
 
+static int qedi_uio_open(struct uio_info *uinfo, struct inode *inode)
+{
+	struct qedi_uio_dev *udev = uinfo->priv;
+	struct qedi_ctx *qedi = udev->qedi;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (udev->uio_dev != -1)
+		return -EBUSY;
+
+	rtnl_lock();
+	udev->uio_dev = iminor(inode);
+	qedi_reset_uio_rings(udev);
+	set_bit(UIO_DEV_OPENED, &qedi->flags);
+	rtnl_unlock();
+
+	return 0;
+}
+
+static int qedi_uio_close(struct uio_info *uinfo, struct inode *inode)
+{
+	struct qedi_uio_dev *udev = uinfo->priv;
+	struct qedi_ctx *qedi = udev->qedi;
+
+	udev->uio_dev = -1;
+	clear_bit(UIO_DEV_OPENED, &qedi->flags);
+	qedi_ll2_free_skbs(qedi);
+	return 0;
+}
+
+static void __qedi_free_uio_rings(struct qedi_uio_dev *udev)
+{
+	if (udev->ll2_ring) {
+		free_page((unsigned long)udev->ll2_ring);
+		udev->ll2_ring = NULL;
+	}
+
+	if (udev->ll2_buf) {
+		free_pages((unsigned long)udev->ll2_buf, 2);
+		udev->ll2_buf = NULL;
+	}
+}
+
+static void __qedi_free_uio(struct qedi_uio_dev *udev)
+{
+	uio_unregister_device(&udev->qedi_uinfo);
+
+	__qedi_free_uio_rings(udev);
+
+	pci_dev_put(udev->pdev);
+	kfree(udev->uctrl);
+	kfree(udev);
+}
+
+static void qedi_free_uio(struct qedi_uio_dev *udev)
+{
+	if (!udev)
+		return;
+
+	list_del_init(&udev->list);
+	__qedi_free_uio(udev);
+}
+
+static void qedi_reset_uio_rings(struct qedi_uio_dev *udev)
+{
+	struct qedi_ctx *qedi = NULL;
+	struct qedi_uio_ctrl *uctrl = NULL;
+
+	qedi = udev->qedi;
+	uctrl = udev->uctrl;
+
+	spin_lock_bh(&qedi->ll2_lock);
+	uctrl->host_rx_cons = 0;
+	uctrl->hw_rx_prod = 0;
+	uctrl->hw_rx_bd_prod = 0;
+	uctrl->host_rx_bd_cons = 0;
+
+	memset(udev->ll2_ring, 0, udev->ll2_ring_size);
+	memset(udev->ll2_buf, 0, udev->ll2_buf_size);
+	spin_unlock_bh(&qedi->ll2_lock);
+}
+
+static int __qedi_alloc_uio_rings(struct qedi_uio_dev *udev)
+{
+	int rc = 0;
+
+	if (udev->ll2_ring || udev->ll2_buf)
+		return rc;
+
+	/* Allocating memory for LL2 ring  */
+	udev->ll2_ring_size = QEDI_PAGE_SIZE;
+	udev->ll2_ring = (void *)get_zeroed_page(GFP_KERNEL | __GFP_COMP);
+	if (!udev->ll2_ring) {
+		rc = -ENOMEM;
+		goto exit_alloc_ring;
+	}
+
+	/* Allocating memory for Tx/Rx pkt buffer */
+	udev->ll2_buf_size = TX_RX_RING * LL2_SINGLE_BUF_SIZE;
+	udev->ll2_buf_size = QEDI_PAGE_ALIGN(udev->ll2_buf_size);
+	udev->ll2_buf = (void *)__get_free_pages(GFP_KERNEL | __GFP_COMP |
+						 __GFP_ZERO, 2);
+	if (!udev->ll2_buf) {
+		rc = -ENOMEM;
+		goto exit_alloc_buf;
+	}
+	return rc;
+
+exit_alloc_buf:
+	free_page((unsigned long)udev->ll2_ring);
+	udev->ll2_ring = NULL;
+exit_alloc_ring:
+	return rc;
+}
+
+static int qedi_alloc_uio_rings(struct qedi_ctx *qedi)
+{
+	struct qedi_uio_dev *udev = NULL;
+	struct qedi_uio_ctrl *uctrl = NULL;
+	int rc = 0;
+
+	list_for_each_entry(udev, &qedi_udev_list, list) {
+		if (udev->pdev == qedi->pdev) {
+			udev->qedi = qedi;
+			if (__qedi_alloc_uio_rings(udev)) {
+				udev->qedi = NULL;
+				return -ENOMEM;
+			}
+			qedi->udev = udev;
+			return 0;
+		}
+	}
+
+	udev = kzalloc(sizeof(*udev), GFP_KERNEL);
+	if (!udev) {
+		rc = -ENOMEM;
+		goto err_udev;
+	}
+
+	uctrl = kzalloc(sizeof(*uctrl), GFP_KERNEL);
+	if (!uctrl) {
+		rc = -ENOMEM;
+		goto err_uctrl;
+	}
+
+	udev->uio_dev = -1;
+
+	udev->qedi = qedi;
+	udev->pdev = qedi->pdev;
+	udev->uctrl = uctrl;
+
+	rc = __qedi_alloc_uio_rings(udev);
+	if (rc)
+		goto err_uio_rings;
+
+	list_add(&udev->list, &qedi_udev_list);
+
+	pci_dev_get(udev->pdev);
+	qedi->udev = udev;
+
+	udev->tx_pkt = udev->ll2_buf;
+	udev->rx_pkt = udev->ll2_buf + LL2_SINGLE_BUF_SIZE;
+	return 0;
+
+ err_uio_rings:
+	kfree(uctrl);
+ err_uctrl:
+	kfree(udev);
+ err_udev:
+	return -ENOMEM;
+}
+
+static int qedi_init_uio(struct qedi_ctx *qedi)
+{
+	struct qedi_uio_dev *udev = qedi->udev;
+	struct uio_info *uinfo;
+	int ret = 0;
+
+	if (!udev)
+		return -ENOMEM;
+
+	uinfo = &udev->qedi_uinfo;
+
+	uinfo->mem[0].addr = (unsigned long)udev->uctrl;
+	uinfo->mem[0].size = sizeof(struct qedi_uio_ctrl);
+	uinfo->mem[0].memtype = UIO_MEM_LOGICAL;
+
+	uinfo->mem[1].addr = (unsigned long)udev->ll2_ring;
+	uinfo->mem[1].size = udev->ll2_ring_size;
+	uinfo->mem[1].memtype = UIO_MEM_LOGICAL;
+
+	uinfo->mem[2].addr = (unsigned long)udev->ll2_buf;
+	uinfo->mem[2].size = udev->ll2_buf_size;
+	uinfo->mem[2].memtype = UIO_MEM_LOGICAL;
+
+	uinfo->name = "qedi_uio";
+	uinfo->version = QEDI_MODULE_VERSION;
+	uinfo->irq = UIO_IRQ_CUSTOM;
+
+	uinfo->open = qedi_uio_open;
+	uinfo->release = qedi_uio_close;
+
+	if (udev->uio_dev == -1) {
+		if (!uinfo->priv) {
+			uinfo->priv = udev;
+
+			ret = uio_register_device(&udev->pdev->dev, uinfo);
+			if (ret) {
+				QEDI_ERR(&qedi->dbg_ctx,
+					 "UIO registration failed\n");
+			}
+		}
+	}
+
+	return ret;
+}
+
 static int qedi_alloc_and_init_sb(struct qedi_ctx *qedi,
 				  struct qed_sb_info *sb_info, u16 sb_id)
 {
@@ -442,6 +663,142 @@ static struct qedi_ctx *qedi_host_alloc(struct pci_dev *pdev)
 	return qedi;
 }
 
+static int qedi_ll2_rx(void *cookie, struct sk_buff *skb, u32 arg1, u32 arg2)
+{
+	struct qedi_ctx *qedi = (struct qedi_ctx *)cookie;
+	struct qedi_uio_dev *udev;
+	struct qedi_uio_ctrl *uctrl;
+	struct skb_work_list *work;
+	u32 prod;
+
+	if (!qedi) {
+		QEDI_ERR(NULL, "qedi is NULL\n");
+		return -1;
+	}
+
+	if (!test_bit(UIO_DEV_OPENED, &qedi->flags)) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_UIO,
+			  "UIO DEV is not opened\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	udev = qedi->udev;
+	uctrl = udev->uctrl;
+
+	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Could not allocate work so dropping frame.\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	INIT_LIST_HEAD(&work->list);
+	work->skb = skb;
+
+	if (skb_vlan_tag_present(skb))
+		work->vlan_id = skb_vlan_tag_get(skb);
+
+	if (work->vlan_id)
+		__vlan_insert_tag(work->skb, htons(ETH_P_8021Q), work->vlan_id);
+
+	spin_lock_bh(&qedi->ll2_lock);
+	list_add_tail(&work->list, &qedi->ll2_skb_list);
+
+	++uctrl->hw_rx_prod_cnt;
+	prod = (uctrl->hw_rx_prod + 1) % RX_RING;
+	if (prod != uctrl->host_rx_cons) {
+		uctrl->hw_rx_prod = prod;
+		spin_unlock_bh(&qedi->ll2_lock);
+		wake_up_process(qedi->ll2_recv_thread);
+		return 0;
+	}
+
+	spin_unlock_bh(&qedi->ll2_lock);
+	return 0;
+}
+
+/* map this skb to iscsiuio mmaped region */
+static int qedi_ll2_process_skb(struct qedi_ctx *qedi, struct sk_buff *skb,
+				u16 vlan_id)
+{
+	struct qedi_uio_dev *udev = NULL;
+	struct qedi_uio_ctrl *uctrl = NULL;
+	struct qedi_rx_bd rxbd;
+	struct qedi_rx_bd *p_rxbd;
+	u32 rx_bd_prod;
+	void *pkt;
+	int len = 0;
+
+	if (!qedi) {
+		QEDI_ERR(NULL, "qedi is NULL\n");
+		return -1;
+	}
+
+	udev = qedi->udev;
+	uctrl = udev->uctrl;
+	pkt = udev->rx_pkt + (uctrl->hw_rx_prod * LL2_SINGLE_BUF_SIZE);
+	len = min_t(u32, skb->len, (u32)LL2_SINGLE_BUF_SIZE);
+	memcpy(pkt, skb->data, len);
+
+	memset(&rxbd, 0, sizeof(rxbd));
+	rxbd.rx_pkt_index = uctrl->hw_rx_prod;
+	rxbd.rx_pkt_len = len;
+	rxbd.vlan_id = vlan_id;
+
+	uctrl->hw_rx_bd_prod = (uctrl->hw_rx_bd_prod + 1) % QEDI_NUM_RX_BD;
+	rx_bd_prod = uctrl->hw_rx_bd_prod;
+	p_rxbd = (struct qedi_rx_bd *)udev->ll2_ring;
+	p_rxbd += rx_bd_prod;
+
+	memcpy(p_rxbd, &rxbd, sizeof(rxbd));
+
+	/* notify the iscsiuio about new packet */
+	uio_event_notify(&udev->qedi_uinfo);
+
+	return 0;
+}
+
+static void qedi_ll2_free_skbs(struct qedi_ctx *qedi)
+{
+	struct skb_work_list *work, *work_tmp;
+
+	spin_lock_bh(&qedi->ll2_lock);
+	list_for_each_entry_safe(work, work_tmp, &qedi->ll2_skb_list, list) {
+		list_del(&work->list);
+		if (work->skb)
+			kfree_skb(work->skb);
+		kfree(work);
+	}
+	spin_unlock_bh(&qedi->ll2_lock);
+}
+
+static int qedi_ll2_recv_thread(void *arg)
+{
+	struct qedi_ctx *qedi = (struct qedi_ctx *)arg;
+	struct skb_work_list *work, *work_tmp;
+
+	set_user_nice(current, -20);
+
+	while (!kthread_should_stop()) {
+		spin_lock_bh(&qedi->ll2_lock);
+		list_for_each_entry_safe(work, work_tmp, &qedi->ll2_skb_list,
+					 list) {
+			list_del(&work->list);
+			qedi_ll2_process_skb(qedi, work->skb, work->vlan_id);
+			kfree_skb(work->skb);
+			kfree(work);
+		}
+		set_current_state(TASK_INTERRUPTIBLE);
+		spin_unlock_bh(&qedi->ll2_lock);
+		schedule();
+	}
+
+	__set_current_state(TASK_RUNNING);
+	return 0;
+}
+
 static int qedi_set_iscsi_pf_param(struct qedi_ctx *qedi)
 {
 	u8 num_sq_pages;
-- 
1.8.3.1

