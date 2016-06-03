From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/15] smc: work request (WR) base for use by LLC and CDC
Date: Fri,  3 Jun 2016 17:27:07 +0200
Message-ID: <201606031527.u53FQ1V4006327@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:27220 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753038AbcFCP1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:49 -0400
Received: from pps.filterd (m0075771.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ1V4006327
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:48 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bc6u93d8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:47 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:44 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The base containers for RDMA transport are work requests and completion
queue entries processed through Infiniband verbs:
* allocate and initialize these areas
* map these areas to DMA
* implement the basic communication consisting of work request posting
  and receival of completion queue events

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   2 +-
 net/smc/smc.h      |   4 +
 net/smc/smc_core.c |  11 ++
 net/smc/smc_core.h |  29 +++
 net/smc/smc_ib.c   |  71 +++++++
 net/smc/smc_ib.h   |  11 ++
 net/smc/smc_wr.c   | 558 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_wr.h   |  85 ++++++++
 8 files changed, 770 insertions(+), 1 deletion(-)
 create mode 100644 net/smc/smc_wr.c
 create mode 100644 net/smc/smc_wr.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index cb8bcd9..b19120e 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_SMC)	+= smc.o
-smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o
+smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 914f3da..460ca30 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -27,6 +27,10 @@ enum smc_state {		/* possible states of an SMC socket */
 
 struct smc_link_group;
 
+struct smc_wr_rx_hdr {	/* common prefix part of LLC and CDC to demultiplex */
+	u8			type;
+} __packed;
+
 struct smc_connection {
 	struct rb_node		alert_node;
 	struct smc_link_group	*lgr;		/* link group of connection */
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 53d7fd9..1543c5f 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -20,6 +20,7 @@
 #include "smc_clc.h"
 #include "smc_core.h"
 #include "smc_ib.h"
+#include "smc_wr.h"
 
 #define SMC_LGR_FREE_DELAY	(600 * HZ)
 
@@ -158,12 +159,20 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 	lnk->path_mtu = smcibdev->pattr[ibport - 1].active_mtu;
 	get_random_bytes(rndvec, sizeof(rndvec));
 	lnk->psn_initial = rndvec[0] + (rndvec[1] << 8) + (rndvec[2] << 16);
+	rc = smc_wr_alloc_link_mem(lnk);
+	if (rc)
+		goto free_lgr;
+	init_waitqueue_head(&lnk->wr_tx_wait);
 
 	smc->conn.lgr = lgr;
 	rwlock_init(&lgr->conns_lock);
 	spin_lock_bh(&smc_lgr_list.lock);
 	list_add_tail(&lgr->list, &smc_lgr_list.list);
 	spin_unlock_bh(&smc_lgr_list.lock);
+	return 0;
+
+free_lgr:
+	kfree(lgr);
 out:
 	return rc;
 }
@@ -199,6 +208,8 @@ void smc_conn_free(struct smc_connection *conn)
 static void smc_link_clear(struct smc_link *lnk)
 {
 	lnk->peer_qpn = 0;
+	smc_wr_free_link(lnk);
+	smc_wr_free_link_mem(lnk);
 }
 
 static void smc_lgr_free_sndbufs(struct smc_link_group *lgr)
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
index ad9b16d..575ff80 100644
--- a/net/smc/smc_core.h
+++ b/net/smc/smc_core.h
@@ -30,11 +30,40 @@ enum smc_lgr_role {		/* possible roles of a link group */
 	SMC_SERV	/* server */
 };
 
+#define SMC_WR_BUF_SIZE		48	/* size of work request buffer */
+
+struct smc_wr_buf {
+	u8	raw[SMC_WR_BUF_SIZE];
+} __packed;
+
 struct smc_link {
 	struct smc_ib_device	*smcibdev;	/* ib-device */
 	u8			ibport;		/* port - values 1 | 2 */
+	struct ib_pd		*roce_pd;	/* IB protection domain,
+						 * unique for every RoCE QP
+						 */
 	struct ib_qp		*roce_qp;	/* IB queue pair */
 	struct ib_qp_attr	qp_attr;	/* IB queue pair attributes */
+
+	struct smc_wr_buf	*wr_tx_bufs;	/* WR send payload buffers */
+	struct ib_send_wr	*wr_tx_ibs;	/* WR send meta data */
+	struct ib_sge		*wr_tx_sges;	/* WR send gather meta data */
+	struct smc_wr_tx_pend	*wr_tx_pends;	/* WR send waiting for CQE */
+	/* above four vectors have wr_tx_cnt elements and use the same index */
+	dma_addr_t		wr_tx_dma_addr;	/* DMA address of wr_tx_bufs */
+	atomic64_t		wr_tx_id;	/* seq # of last sent WR */
+	unsigned long		*wr_tx_mask;	/* bit mask of used indexes */
+	u32			wr_tx_cnt;	/* number of WR send buffers */
+	wait_queue_head_t	wr_tx_wait;	/* wait for free WR send buf */
+
+	struct smc_wr_buf	*wr_rx_bufs;	/* WR recv payload buffers */
+	struct ib_recv_wr	*wr_rx_ibs;	/* WR recv meta data */
+	struct ib_sge		*wr_rx_sges;	/* WR recv scatter meta data */
+	/* above three vectors have wr_rx_cnt elements and use the same index */
+	dma_addr_t		wr_rx_dma_addr;	/* DMA address of wr_rx_bufs */
+	u64			wr_rx_id;	/* seq # of last recv WR */
+	u32			wr_rx_cnt;	/* number of WR recv buffers */
+
 	union ib_gid		gid;		/* gid matching used vlan id */
 	u32			peer_qpn;	/* QP number of peer */
 	enum ib_mtu		path_mtu;	/* used mtu */
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 9ca1412..0701323 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -17,6 +17,7 @@
 #include "smc_pnet.h"
 #include "smc_ib.h"
 #include "smc_core.h"
+#include "smc_wr.h"
 #include "smc.h"
 
 struct smc_ib_devices smc_ib_devices = {	/* smc-registered ib devices */
@@ -30,6 +31,76 @@ u8 local_systemid[SMC_SYSTEMID_LEN] = SMC_LOCAL_SYSTEMID_RESET;	/* unique system
 								 * identifier
 								 */
 
+void smc_ib_dealloc_protection_domain(struct smc_link *lnk)
+{
+	ib_dealloc_pd(lnk->roce_pd);
+	lnk->roce_pd = NULL;
+}
+
+int smc_ib_create_protection_domain(struct smc_link *lnk)
+{
+	lnk->roce_pd = ib_alloc_pd(lnk->smcibdev->ibdev);
+	if (IS_ERR(lnk->roce_pd)) {
+		lnk->roce_pd = NULL;
+		return (int)PTR_ERR(lnk->roce_pd);
+	}
+	return 0;
+}
+
+static void smc_ib_qp_event_handler(struct ib_event *ibevent, void *priv)
+{
+	switch (ibevent->event) {
+	case IB_EVENT_DEVICE_FATAL:
+	case IB_EVENT_GID_CHANGE:
+	case IB_EVENT_PORT_ERR:
+	case IB_EVENT_QP_ACCESS_ERR:
+		/* tbd in follow-on patch:
+		 * abnormal close of corresponding connections
+		 */
+		break;
+	default:
+		break;
+	}
+}
+
+void smc_ib_destroy_queue_pair(struct smc_link *lnk)
+{
+	ib_destroy_qp(lnk->roce_qp);
+	lnk->roce_qp = NULL;
+}
+
+/* create a queue pair within the protection domain for a link */
+int smc_ib_create_queue_pair(struct smc_link *lnk)
+{
+	struct ib_qp_init_attr qp_attr = {
+		.event_handler = smc_ib_qp_event_handler,
+		.qp_context = lnk,
+		.send_cq = lnk->smcibdev->roce_cq_send,
+		.recv_cq = lnk->smcibdev->roce_cq_recv,
+		.srq = NULL,
+		.cap = {
+			.max_send_wr = SMC_WR_BUF_CNT,
+				/* include unsolicited rdma_writes as well,
+				 * there are max. 2 RDMA_WRITE per 1 WR_SEND
+				 */
+			.max_recv_wr = SMC_WR_BUF_CNT * 3,
+			.max_send_sge = SMC_IB_MAX_SEND_SGE,
+			.max_recv_sge = 1,
+			.max_inline_data = SMC_WR_TX_SIZE,
+		},
+		.sq_sig_type = IB_SIGNAL_REQ_WR,
+		.qp_type = IB_QPT_RC,
+	};
+
+	lnk->roce_qp = ib_create_qp(lnk->roce_pd, &qp_attr);
+	if (IS_ERR(lnk->roce_qp)) {
+		lnk->roce_qp = NULL;
+		return (int)PTR_ERR(lnk->roce_qp);
+	}
+	smc_wr_remember_qp_attr(lnk);
+	return 0;
+}
+
 /* map a new TX or RX buffer to DMA */
 int smc_ib_buf_map(struct smc_ib_device *smcibdev, int buf_size,
 		   struct smc_buf_desc *buf_slot,
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index 57167af..842a27f 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -16,6 +16,8 @@
 #define SMC_MAX_PORTS			2	/* Max # of ports */
 #define SMC_GID_SIZE			sizeof(union ib_gid)
 
+#define SMC_IB_MAX_SEND_SGE		2
+
 struct smc_ib_devices {			/* list of smc ib devices definition */
 	struct list_head	list;
 	spinlock_t		lock;	/* protects list of smc ib devices */
@@ -27,6 +29,10 @@ struct smc_ib_device {				/* ib-device infos for smc */
 	struct list_head	list;
 	struct ib_device	*ibdev;
 	struct ib_port_attr	pattr[SMC_MAX_PORTS];	/* ib dev. port attrs */
+	struct ib_cq		*roce_cq_send;	/* send completion queue */
+	struct ib_cq		*roce_cq_recv;	/* recv completion queue */
+	struct tasklet_struct	send_tasklet;	/* called by send cq handler */
+	struct tasklet_struct	recv_tasklet;	/* called by recv cq handler */
 	char			mac[SMC_MAX_PORTS][6]; /* mac address per port*/
 	union ib_gid		gid[SMC_MAX_PORTS]; /* gid per port */
 	u8			initialized : 1; /* ib dev CQ, evthdl done */
@@ -34,6 +40,7 @@ struct smc_ib_device {				/* ib-device infos for smc */
 
 struct smc_sock;
 struct smc_buf_desc;
+struct smc_link;
 
 int smc_ib_register_client(void) __init;
 void smc_ib_unregister_client(void);
@@ -41,5 +48,9 @@ bool smc_ib_port_active(struct smc_ib_device *, u8);
 int smc_ib_remember_port_attr(struct smc_ib_device *, u8);
 int smc_ib_buf_map(struct smc_ib_device *, int, struct smc_buf_desc *,
 		   enum dma_data_direction);
+void smc_ib_dealloc_protection_domain(struct smc_link *);
+int smc_ib_create_protection_domain(struct smc_link *);
+void smc_ib_destroy_queue_pair(struct smc_link *);
+int smc_ib_create_queue_pair(struct smc_link *);
 
 #endif
diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
new file mode 100644
index 0000000..6486ca6
--- /dev/null
+++ b/net/smc/smc_wr.c
@@ -0,0 +1,558 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Work Requests exploiting Infiniband API
+ *
+ * Work requests (WR) of type ib_post_send or ib_post_recv respectively
+ * are submitted to either RC SQ or RC RQ respectively
+ * (reliably connected send/receive queue)
+ * and become work queue entries (WQEs).
+ * While an SQ WR/WQE is pending, we track it until transmission completion.
+ * Through a send or receive completion queue (CQ) respectively,
+ * we get completion queue entries (CQEs) [aka work completions (WCs)].
+ * Since the CQ callback is called from IRQ context, we split work by using
+ * bottom halves implemented by tasklets.
+ *
+ * SMC uses this to exchange LLC (link layer control)
+ * and CDC (connection data control) messages.
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Steffen Maier <maier@linux.vnet.ibm.com>
+ */
+
+#include <linux/hashtable.h>
+
+#include "smc.h"
+#include "smc_wr.h"
+
+#define SMC_WR_MAX_POLL_CQE 10	/* max. # of compl. queue elements in 1 poll */
+
+#define SMC_WR_RX_HASH_BITS 4
+static DEFINE_HASHTABLE(smc_wr_rx_hash, SMC_WR_RX_HASH_BITS);
+static DEFINE_SPINLOCK(smc_wr_rx_hash_lock);
+
+struct smc_wr_tx_pend {	/* control data for a pending send request */
+	u64			wr_id;		/* work request id sent */
+	smc_wr_tx_handler	handler;
+	enum ib_wc_status	wc_status;	/* CQE status */
+	struct smc_link		*link;
+	u32			idx;
+	struct smc_wr_tx_pend_priv priv;
+};
+
+/******************************** send queue *********************************/
+
+/*------------------------------- completion --------------------------------*/
+
+static inline int smc_wr_tx_find_pending_index(struct smc_link *link, u64 wr_id)
+{
+	u32 i;
+
+	for (i = 0; i < link->wr_tx_cnt; i++) {
+		if (link->wr_tx_pends[i].wr_id == wr_id)
+			return i;
+	}
+	return link->wr_tx_cnt;
+}
+
+static inline void smc_wr_tx_process_cqe(struct ib_wc *wc)
+{
+	struct smc_wr_tx_pend pnd_snd;
+	struct smc_link *link;
+	u32 pnd_snd_idx;
+	int i;
+
+	link = wc->qp->qp_context;
+	pnd_snd_idx = smc_wr_tx_find_pending_index(link, wc->wr_id);
+	if (pnd_snd_idx == link->wr_tx_cnt)
+		return;
+	link->wr_tx_pends[pnd_snd_idx].wc_status = wc->status;
+	memcpy(&pnd_snd, &link->wr_tx_pends[pnd_snd_idx], sizeof(pnd_snd));
+	/* clear the full struct smc_wr_tx_pend including .priv */
+	memset(&link->wr_tx_pends[pnd_snd_idx], 0,
+	       sizeof(link->wr_tx_pends[pnd_snd_idx]));
+	memset(&link->wr_tx_bufs[pnd_snd_idx], 0,
+	       sizeof(link->wr_tx_bufs[pnd_snd_idx]));
+	if (!test_and_clear_bit(pnd_snd_idx, link->wr_tx_mask))
+		return;
+	if (wc->status) {
+		for_each_set_bit(i, link->wr_tx_mask, link->wr_tx_cnt) {
+			/* clear full struct smc_wr_tx_pend including .priv */
+			memset(&link->wr_tx_pends[i], 0,
+			       sizeof(link->wr_tx_pends[i]));
+			memset(&link->wr_tx_bufs[i], 0,
+			       sizeof(link->wr_tx_bufs[i]));
+			clear_bit(i, link->wr_tx_mask);
+		}
+		/* tbd in future patch: terminate connections of this link
+		 * group abnormally
+		 */
+	}
+	if (pnd_snd.handler)
+		pnd_snd.handler(&pnd_snd.priv, link, wc->status);
+	wake_up(&link->wr_tx_wait);
+}
+
+static void smc_wr_tx_tasklet_fn(unsigned long data)
+{
+	struct smc_ib_device *dev = (struct smc_ib_device *)data;
+	struct ib_wc wc[SMC_WR_MAX_POLL_CQE];
+	int i = 0, rc;
+	int polled = 0;
+
+again:
+	polled++;
+	do {
+		rc = ib_poll_cq(dev->roce_cq_send, SMC_WR_MAX_POLL_CQE, wc);
+		if (polled == 1) {
+			ib_req_notify_cq(dev->roce_cq_send,
+					 IB_CQ_NEXT_COMP |
+					 IB_CQ_REPORT_MISSED_EVENTS);
+		}
+		if (!rc)
+			break;
+		for (i = 0; i < rc; i++)
+			smc_wr_tx_process_cqe(&wc[i]);
+	} while (rc > 0);
+	if (polled == 1)
+		goto again;
+}
+
+void smc_wr_tx_cq_handler(struct ib_cq *ib_cq, void *cq_context)
+{
+	struct smc_ib_device *dev = (struct smc_ib_device *)cq_context;
+
+	tasklet_schedule(&dev->send_tasklet);
+}
+
+/*---------------------------- request submission ---------------------------*/
+
+static inline int smc_wr_tx_get_free_slot_index(struct smc_link *link, u32 *idx)
+{
+	*idx = link->wr_tx_cnt;
+	for_each_clear_bit(*idx, link->wr_tx_mask, link->wr_tx_cnt) {
+		if (!test_and_set_bit(*idx, link->wr_tx_mask))
+			return 0;
+	}
+	*idx = link->wr_tx_cnt;
+	return -EBUSY;
+}
+
+/**
+ * smc_wr_tx_get_free_slot() - returns buffer for message assembly,
+ *			and sets info for pending transmit tracking
+ * @link:		Pointer to smc_link used to later send the message.
+ * @handler:		Send completion handler function pointer.
+ * @wr_buf:		Out value returns pointer to message buffer.
+ * @wr_pend_priv:	Out value returns pointer serving as handler context.
+ *
+ * Return: 0 on success, or -errno on error.
+ */
+int smc_wr_tx_get_free_slot(struct smc_link *link,
+			    smc_wr_tx_handler handler,
+			    struct smc_wr_buf **wr_buf,
+			    struct smc_wr_tx_pend_priv **wr_pend_priv)
+{
+	struct smc_wr_tx_pend *wr_pend;
+	struct ib_send_wr *wr_ib;
+	u64 wr_id;
+	u32 idx;
+	int rc;
+
+	*wr_buf = NULL;
+	*wr_pend_priv = NULL;
+	if (in_softirq()) {
+		rc = smc_wr_tx_get_free_slot_index(link, &idx);
+		if (rc)
+			return rc;
+	} else {
+		rc = wait_event_interruptible_timeout(
+			link->wr_tx_wait,
+			(smc_wr_tx_get_free_slot_index(link, &idx) != -EBUSY),
+			SMC_WR_TX_WAIT_FREE_SLOT_TIME);
+		if (!rc) {
+			/* tbd in future patch: timeout - terminate connections
+			 * of this link group abnormally
+			 */
+			return -EPIPE;
+		}
+		if (rc == -ERESTARTSYS)
+			return -EINTR;
+		if (idx == link->wr_tx_cnt)
+			return -EPIPE;
+	}
+	wr_id = smc_wr_tx_get_next_wr_id(link);
+	wr_pend = &link->wr_tx_pends[idx];
+	wr_pend->wr_id = wr_id;
+	wr_pend->handler = handler;
+	wr_pend->link = link;
+	wr_pend->idx = idx;
+	wr_ib = &link->wr_tx_ibs[idx];
+	wr_ib->wr_id = wr_id;
+	*wr_buf = &link->wr_tx_bufs[idx];
+	*wr_pend_priv = &wr_pend->priv;
+	return 0;
+}
+
+int smc_wr_tx_put_slot(struct smc_link *link,
+		       struct smc_wr_tx_pend_priv *wr_pend_priv)
+{
+	struct smc_wr_tx_pend *pend;
+
+	pend = container_of(wr_pend_priv, struct smc_wr_tx_pend, priv);
+	if (pend->idx < link->wr_tx_cnt) {
+		/* clear the full struct smc_wr_tx_pend including .priv */
+		memset(&link->wr_tx_pends[pend->idx], 0,
+		       sizeof(link->wr_tx_pends[pend->idx]));
+		memset(&link->wr_tx_bufs[pend->idx], 0,
+		       sizeof(link->wr_tx_bufs[pend->idx]));
+		test_and_clear_bit(pend->idx, link->wr_tx_mask);
+		return 1;
+	}
+
+	return 0;
+}
+
+/* Send prepared WR slot via ib_post_send.
+ * @priv: pointer to smc_wr_tx_pend_priv identifying prepared message buffer
+ */
+int smc_wr_tx_send(struct smc_link *link, struct smc_wr_tx_pend_priv *priv)
+{
+	struct ib_send_wr *failed_wr = NULL;
+	struct smc_wr_tx_pend *pend;
+	int rc;
+
+	ib_req_notify_cq(link->smcibdev->roce_cq_send,
+			 IB_CQ_SOLICITED_MASK | IB_CQ_REPORT_MISSED_EVENTS);
+	pend = container_of(priv, struct smc_wr_tx_pend, priv);
+	rc = ib_post_send(link->roce_qp, &link->wr_tx_ibs[pend->idx],
+			  &failed_wr);
+	if (rc)
+		smc_wr_tx_put_slot(link, priv);
+	return rc;
+}
+
+/****************************** receive queue ********************************/
+
+int smc_wr_rx_register_handler(struct smc_wr_rx_handler *handler)
+{
+	struct smc_wr_rx_handler *h_iter;
+	int rc = 0;
+
+	spin_lock(&smc_wr_rx_hash_lock);
+	hash_for_each_possible(smc_wr_rx_hash, h_iter, list, handler->type) {
+		if (h_iter->type == handler->type) {
+			rc = -EEXIST;
+			goto out_unlock;
+		}
+	}
+	hash_add(smc_wr_rx_hash, &handler->list, handler->type);
+out_unlock:
+	spin_unlock(&smc_wr_rx_hash_lock);
+	return rc;
+}
+
+/* Demultiplex a received work request based on the message type to its handler.
+ * Relies on smc_wr_rx_hash having been completely filled before any IB WRs,
+ * and not being modified any more afterwards so we don't need to lock it.
+ */
+static inline void smc_wr_rx_demultiplex(struct ib_wc *wc)
+{
+	struct smc_link *link = (struct smc_link *)wc->qp->qp_context;
+	struct smc_wr_rx_handler *handler;
+	struct smc_wr_rx_hdr *wr_rx;
+	u32 index;
+
+	if (wc->byte_len < sizeof(*wr_rx))
+		return; /* short message */
+	index = wc->wr_id % link->wr_rx_cnt;
+	wr_rx = (struct smc_wr_rx_hdr *)&link->wr_rx_bufs[index];
+	hash_for_each_possible(smc_wr_rx_hash, handler, list, wr_rx->type) {
+		if (handler->type == wr_rx->type)
+			handler->handler(wc, wr_rx);
+	}
+}
+
+static inline void smc_wr_rx_process_cqes(struct ib_wc wc[], int num)
+{
+	struct smc_link *link;
+	int i;
+
+	for (i = 0; i < num; i++) {
+		link = wc[i].qp->qp_context;
+		if (wc[i].status == IB_WC_SUCCESS) {
+			smc_wr_rx_demultiplex(&wc[i]);
+			smc_wr_rx_post(link); /* refill WR RX */
+		} else {
+			/* handle status errors */
+			switch (wc[i].status) {
+			case IB_WC_RETRY_EXC_ERR:
+			case IB_WC_RNR_RETRY_EXC_ERR:
+			case IB_WC_WR_FLUSH_ERR:
+			/* tbd in future patch: terminate connections of this
+			 * link group abnormally
+			 */
+				break;
+			default:
+				smc_wr_rx_post(link); /* refill WR RX */
+				break;
+			}
+		}
+	}
+}
+
+static void smc_wr_rx_tasklet_fn(unsigned long data)
+{
+	struct smc_ib_device *dev = (struct smc_ib_device *)data;
+	struct ib_wc wc[SMC_WR_MAX_POLL_CQE];
+	int polled = 0;
+	int rc;
+
+again:
+	polled++;
+	do {
+		memset(&wc, 0, sizeof(wc));
+		rc = ib_poll_cq(dev->roce_cq_recv, SMC_WR_MAX_POLL_CQE, wc);
+		if (polled == 1) {
+			ib_req_notify_cq(dev->roce_cq_recv,
+					 IB_CQ_SOLICITED_MASK
+					 | IB_CQ_REPORT_MISSED_EVENTS);
+		}
+		if (!rc)
+			break;
+		smc_wr_rx_process_cqes(&wc[0], rc);
+	} while (rc > 0);
+	if (polled == 1)
+		goto again;
+}
+
+void smc_wr_rx_cq_handler(struct ib_cq *ib_cq, void *cq_context)
+{
+	struct smc_ib_device *dev = (struct smc_ib_device *)cq_context;
+
+	tasklet_schedule(&dev->recv_tasklet);
+}
+
+int smc_wr_rx_post_init(struct smc_link *link)
+{
+	u32 i;
+	int rc = 0;
+
+	for (i = 0; i < link->wr_rx_cnt; i++)
+		rc = smc_wr_rx_post(link);
+	return rc;
+}
+
+/***************************** init, exit, misc ******************************/
+
+void smc_wr_remember_qp_attr(struct smc_link *lnk)
+{
+	struct ib_qp_attr *attr = &lnk->qp_attr;
+	struct ib_qp_init_attr init_attr;
+
+	memset(attr, 0, sizeof(*attr));
+	memset(&init_attr, 0, sizeof(init_attr));
+	ib_query_qp(lnk->roce_qp, attr,
+		    IB_QP_STATE |
+		    IB_QP_CUR_STATE |
+		    IB_QP_PKEY_INDEX |
+		    IB_QP_PORT |
+		    IB_QP_QKEY |
+		    IB_QP_AV |
+		    IB_QP_PATH_MTU |
+		    IB_QP_TIMEOUT |
+		    IB_QP_RETRY_CNT |
+		    IB_QP_RNR_RETRY |
+		    IB_QP_RQ_PSN |
+		    IB_QP_ALT_PATH |
+		    IB_QP_MIN_RNR_TIMER |
+		    IB_QP_SQ_PSN |
+		    IB_QP_PATH_MIG_STATE |
+		    IB_QP_CAP |
+		    IB_QP_DEST_QPN,
+		    &init_attr);
+
+	lnk->wr_tx_cnt = min_t(size_t, SMC_WR_BUF_CNT,
+			       lnk->qp_attr.cap.max_send_wr);
+	lnk->wr_rx_cnt = min_t(size_t, SMC_WR_BUF_CNT * 3,
+			       lnk->qp_attr.cap.max_recv_wr);
+}
+
+static void smc_wr_init_sge(struct smc_link *lnk)
+{
+	u32 i;
+
+	for (i = 0; i < lnk->wr_tx_cnt; i++) {
+		lnk->wr_tx_sges[i].addr =
+			lnk->wr_tx_dma_addr + i * SMC_WR_BUF_SIZE;
+		lnk->wr_tx_sges[i].length = SMC_WR_TX_SIZE;
+		lnk->wr_tx_ibs[i].next = NULL;
+		lnk->wr_tx_ibs[i].sg_list = &lnk->wr_tx_sges[i];
+		lnk->wr_tx_ibs[i].num_sge = 1;
+		lnk->wr_tx_ibs[i].opcode = IB_WR_SEND;
+		lnk->wr_tx_ibs[i].send_flags =
+			IB_SEND_SIGNALED | IB_SEND_SOLICITED | IB_SEND_INLINE;
+	}
+	for (i = 0; i < lnk->wr_rx_cnt; i++) {
+		lnk->wr_rx_sges[i].addr =
+			lnk->wr_rx_dma_addr + i * SMC_WR_BUF_SIZE;
+		lnk->wr_rx_sges[i].length = SMC_WR_BUF_SIZE;
+		lnk->wr_rx_ibs[i].next = NULL;
+		lnk->wr_rx_ibs[i].sg_list = &lnk->wr_rx_sges[i];
+		lnk->wr_rx_ibs[i].num_sge = 1;
+	}
+}
+
+void smc_wr_free_link(struct smc_link *lnk)
+{
+	struct ib_device *ibdev;
+
+	memset(lnk->wr_tx_mask, 0,
+	       BITS_TO_LONGS(SMC_WR_BUF_CNT) * sizeof(*lnk->wr_tx_mask));
+
+	if (!lnk->smcibdev)
+		return;
+	ibdev = lnk->smcibdev->ibdev;
+
+	if (lnk->wr_rx_dma_addr) {
+		ib_dma_unmap_single(ibdev, lnk->wr_rx_dma_addr,
+				    SMC_WR_BUF_SIZE * lnk->wr_rx_cnt,
+				    DMA_FROM_DEVICE);
+		lnk->wr_rx_dma_addr = 0;
+	}
+	if (lnk->wr_tx_dma_addr) {
+		ib_dma_unmap_single(ibdev, lnk->wr_tx_dma_addr,
+				    SMC_WR_BUF_SIZE * lnk->wr_tx_cnt,
+				    DMA_TO_DEVICE);
+		lnk->wr_tx_dma_addr = 0;
+	}
+}
+
+void smc_wr_free_link_mem(struct smc_link *lnk)
+{
+	kfree(lnk->wr_tx_pends);
+	lnk->wr_tx_pends = NULL;
+	kfree(lnk->wr_tx_mask);
+	lnk->wr_tx_mask = NULL;
+	kfree(lnk->wr_tx_sges);
+	lnk->wr_tx_sges = NULL;
+	kfree(lnk->wr_rx_sges);
+	lnk->wr_rx_sges = NULL;
+	kfree(lnk->wr_rx_ibs);
+	lnk->wr_rx_ibs = NULL;
+	kfree(lnk->wr_tx_ibs);
+	lnk->wr_tx_ibs = NULL;
+	kfree(lnk->wr_tx_bufs);
+	lnk->wr_tx_bufs = NULL;
+	kfree(lnk->wr_rx_bufs);
+	lnk->wr_rx_bufs = NULL;
+}
+
+int smc_wr_alloc_link_mem(struct smc_link *link)
+{
+	/* allocate link related memory */
+	link->wr_tx_bufs = kcalloc(SMC_WR_BUF_CNT, SMC_WR_BUF_SIZE, GFP_KERNEL);
+	if (!link->wr_tx_bufs)
+		goto no_mem;
+	link->wr_rx_bufs = kcalloc(SMC_WR_BUF_CNT * 3, SMC_WR_BUF_SIZE,
+				   GFP_KERNEL);
+	if (!link->wr_rx_bufs)
+		goto no_mem_wr_tx_bufs;
+	link->wr_tx_ibs = kcalloc(SMC_WR_BUF_CNT, sizeof(link->wr_tx_ibs[0]),
+				  GFP_KERNEL);
+	if (!link->wr_tx_ibs)
+		goto no_mem_wr_rx_bufs;
+	link->wr_rx_ibs = kcalloc(SMC_WR_BUF_CNT * 3,
+				  sizeof(link->wr_rx_ibs[0]),
+				  GFP_KERNEL);
+	if (!link->wr_rx_ibs)
+		goto no_mem_wr_tx_ibs;
+	link->wr_tx_sges = kcalloc(SMC_WR_BUF_CNT, sizeof(link->wr_tx_sges[0]),
+				   GFP_KERNEL);
+	if (!link->wr_tx_sges)
+		goto no_mem_wr_rx_ibs;
+	link->wr_rx_sges = kcalloc(SMC_WR_BUF_CNT * 3,
+				   sizeof(link->wr_rx_sges[0]),
+				   GFP_KERNEL);
+	if (!link->wr_rx_sges)
+		goto no_mem_wr_tx_sges;
+	link->wr_tx_mask = kzalloc(
+		BITS_TO_LONGS(SMC_WR_BUF_CNT) * sizeof(*link->wr_tx_mask),
+		GFP_KERNEL);
+	if (!link->wr_tx_mask)
+		goto no_mem_wr_rx_sges;
+	link->wr_tx_pends = kcalloc(SMC_WR_BUF_CNT,
+				    sizeof(link->wr_tx_pends[0]),
+				    GFP_KERNEL);
+	if (!link->wr_tx_pends)
+		goto no_mem_wr_tx_mask;
+	return 0;
+
+no_mem_wr_tx_mask:
+	kfree(link->wr_tx_mask);
+no_mem_wr_rx_sges:
+	kfree(link->wr_rx_sges);
+no_mem_wr_tx_sges:
+	kfree(link->wr_tx_sges);
+no_mem_wr_rx_ibs:
+	kfree(link->wr_rx_ibs);
+no_mem_wr_tx_ibs:
+	kfree(link->wr_tx_ibs);
+no_mem_wr_rx_bufs:
+	kfree(link->wr_rx_bufs);
+no_mem_wr_tx_bufs:
+	kfree(link->wr_tx_bufs);
+no_mem:
+	return -ENOMEM;
+}
+
+void smc_wr_remove_dev(struct smc_ib_device *smcibdev)
+{
+	tasklet_kill(&smcibdev->recv_tasklet);
+	tasklet_kill(&smcibdev->send_tasklet);
+}
+
+void smc_wr_add_dev(struct smc_ib_device *smcibdev)
+{
+	tasklet_init(&smcibdev->recv_tasklet, smc_wr_rx_tasklet_fn,
+		     (unsigned long)smcibdev);
+	tasklet_init(&smcibdev->send_tasklet, smc_wr_tx_tasklet_fn,
+		     (unsigned long)smcibdev);
+}
+
+int smc_wr_create_link(struct smc_link *lnk)
+{
+	struct ib_device *ibdev = lnk->smcibdev->ibdev;
+	int rc = 0;
+
+	atomic64_set(&lnk->wr_tx_id, 0);
+	lnk->wr_rx_id = 0;
+	lnk->wr_rx_dma_addr = ib_dma_map_single(
+		ibdev, lnk->wr_rx_bufs,	SMC_WR_BUF_SIZE * lnk->wr_rx_cnt,
+		DMA_FROM_DEVICE);
+	if (ib_dma_mapping_error(ibdev, lnk->wr_rx_dma_addr)) {
+		lnk->wr_rx_dma_addr = 0;
+		rc = -EIO;
+		goto out;
+	}
+	lnk->wr_tx_dma_addr = ib_dma_map_single(
+		ibdev, lnk->wr_tx_bufs,	SMC_WR_BUF_SIZE * lnk->wr_tx_cnt,
+		DMA_TO_DEVICE);
+	if (ib_dma_mapping_error(ibdev, lnk->wr_tx_dma_addr)) {
+		rc = -EIO;
+		goto dma_unmap;
+	}
+	smc_wr_init_sge(lnk);
+	memset(lnk->wr_tx_mask, 0,
+	       BITS_TO_LONGS(SMC_WR_BUF_CNT) * sizeof(*lnk->wr_tx_mask));
+	return rc;
+
+dma_unmap:
+	ib_dma_unmap_single(ibdev, lnk->wr_rx_dma_addr,
+			    SMC_WR_BUF_SIZE * lnk->wr_rx_cnt,
+			    DMA_FROM_DEVICE);
+	lnk->wr_rx_dma_addr = 0;
+out:
+	return rc;
+}
diff --git a/net/smc/smc_wr.h b/net/smc/smc_wr.h
new file mode 100644
index 0000000..ba7f831
--- /dev/null
+++ b/net/smc/smc_wr.h
@@ -0,0 +1,85 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Work Requests exploiting Infiniband API
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Steffen Maier <maier@linux.vnet.ibm.com>
+ */
+
+#ifndef SMC_WR_H
+#define SMC_WR_H
+
+#include <rdma/ib_verbs.h>
+
+#include "smc.h"
+#include "smc_core.h"
+
+#define SMC_WR_MAX_CQE 32768	/* max. # of completion queue elements */
+#define SMC_WR_BUF_CNT 16	/* # of ctrl buffers per link */
+
+#define SMC_WR_TX_WAIT_FREE_SLOT_TIME	(10 * HZ)
+#define SMC_WR_TX_WAIT_PENDING_TIME	(5 * HZ)
+
+#define SMC_WR_TX_SIZE 44 /* actual size of wr_send data (<=SMC_WR_BUF_SIZE) */
+
+#define SMC_WR_TX_PEND_PRIV_SIZE 32
+
+struct smc_wr_tx_pend_priv {
+	u8			priv[SMC_WR_TX_PEND_PRIV_SIZE];
+};
+
+typedef void (*smc_wr_tx_handler)(struct smc_wr_tx_pend_priv *,
+				  struct smc_link *,
+				  enum ib_wc_status);
+
+struct smc_wr_rx_handler {
+	struct hlist_node	list;	/* hash table collision resolution */
+	void			(*handler)(struct ib_wc *, void *);
+	u8			type;
+};
+
+/* Only used by RDMA write WRs.
+ * All other WRs (CDC/LLC) use smc_wr_tx_send handling WR_ID implicitly
+ */
+static inline u64 smc_wr_tx_get_next_wr_id(struct smc_link *link)
+{
+	return atomic64_inc_return(&link->wr_tx_id);
+}
+
+/* post a new receive work request to fill a completed old work request entry */
+static inline int smc_wr_rx_post(struct smc_link *link)
+{
+	struct ib_recv_wr *bad_recv_wr = NULL;
+	int rc;
+	u64 wr_id;
+	u32 index;
+
+	wr_id = ++link->wr_rx_id; /* tasklet context, thus not atomic */
+	index = wr_id % link->wr_rx_cnt;
+	link->wr_rx_ibs[index].wr_id = wr_id;
+	rc = ib_post_recv(link->roce_qp, &link->wr_rx_ibs[index], &bad_recv_wr);
+	return rc;
+}
+
+int smc_wr_create_link(struct smc_link *);
+int smc_wr_alloc_link_mem(struct smc_link *);
+void smc_wr_free_link(struct smc_link *);
+void smc_wr_free_link_mem(struct smc_link *);
+void smc_wr_remember_qp_attr(struct smc_link *);
+void smc_wr_remove_dev(struct smc_ib_device *);
+void smc_wr_add_dev(struct smc_ib_device *);
+
+int smc_wr_tx_get_free_slot(struct smc_link *, smc_wr_tx_handler,
+			    struct smc_wr_buf **,
+			    struct smc_wr_tx_pend_priv **);
+int smc_wr_tx_put_slot(struct smc_link *, struct smc_wr_tx_pend_priv *);
+int smc_wr_tx_send(struct smc_link *, struct smc_wr_tx_pend_priv *);
+void smc_wr_tx_cq_handler(struct ib_cq *, void *);
+
+int smc_wr_rx_register_handler(struct smc_wr_rx_handler *);
+int smc_wr_rx_post_init(struct smc_link *);
+void smc_wr_rx_cq_handler(struct ib_cq *, void *);
+
+#endif /* SMC_WR_H */
-- 
2.6.6
