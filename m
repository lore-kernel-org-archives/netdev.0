From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 09/15] smc: initialize IB transport incl. PD, MR, QP, CQ, event, WR
Date: Thu, 24 Nov 2016 16:06:39 +0100
Message-ID: <20161124150645.90881-10-ubraun@linux.vnet.ibm.com>
References: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34516 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966322AbcKXPHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:07:11 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAOF3iAN144174
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:07:10 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26wyaxxr5y-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:07:10 -0500
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 24 Nov 2016 15:07:06 -0000
In-Reply-To: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare the link for RDMA transport:
Create a queue pair (QP) and move it into the state Ready-To-Receive (RTR).

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/af_smc.c   |  34 ++++++--
 net/smc/smc.h      |   1 +
 net/smc/smc_clc.c  |  10 ++-
 net/smc/smc_core.c |  74 +++++++++++++++++
 net/smc/smc_core.h |  18 +++++
 net/smc/smc_ib.c   | 230 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_ib.h   |  13 +++
 net/smc/smc_pnet.c |   3 +
 net/smc/smc_wr.c   |   2 +
 9 files changed, 376 insertions(+), 9 deletions(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 972ea76..fc7ef1e 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -349,9 +349,20 @@ static int smc_connect_rdma(struct smc_sock *smc)
 
 	if (local_contact == SMC_FIRST_CONTACT)
 		smc_link_save_peer_info(link, &aclc);
-	/* tbd in follow-on patch: more steps to setup RDMA communcication,
-	 * create rmbs, map rmbs, rtoken_handling, modify_qp
-	 */
+
+	rc = smc_rmb_rtoken_handling(&smc->conn, &aclc);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_INTERR;
+		goto decline_rdma_unlock;
+	}
+
+	if (local_contact == SMC_FIRST_CONTACT) {
+		rc = smc_ib_ready_link(link);
+		if (rc) {
+			reason_code = SMC_CLC_DECL_INTERR;
+			goto decline_rdma_unlock;
+		}
+	}
 
 	rc = smc_clc_send_confirm(smc);
 	if (rc)
@@ -648,9 +659,20 @@ static void smc_listen_work(struct work_struct *work)
 	if (local_contact == SMC_FIRST_CONTACT)
 		smc_link_save_peer_info(link, &cclc);
 
-	/* tbd in follow-on patch: more steps to setup RDMA communcication,
-	 * rtoken_handling, modify_qp
-	 */
+	rc = smc_rmb_rtoken_handling(&new_smc->conn, &cclc);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_INTERR;
+		goto decline_rdma;
+	}
+
+	/* tbd in follow-on patch: modify_qp, llc_confirm */
+	if (local_contact == SMC_FIRST_CONTACT) {
+		rc = smc_ib_ready_link(link);
+		if (rc) {
+			reason_code = SMC_CLC_DECL_INTERR;
+			goto decline_rdma;
+		}
+	}
 
 out_connected:
 	sk_refcnt_debug_inc(newsmcsk);
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 122677b..36fb1fa 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -40,6 +40,7 @@ struct smc_connection {
 	atomic_t		peer_rmbe_space;/* remaining free bytes in peer
 						 * rmbe
 						 */
+	int			rtoken_idx;	/* idx to peer RMB rkey/addr */
 
 	struct smc_buf_desc	*sndbuf_desc;	/* send buffer descriptor */
 	int			sndbuf_size;	/* sndbuf size <== sock wmem */
diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
index 746afc9..30cf5c8 100644
--- a/net/smc/smc_clc.c
+++ b/net/smc/smc_clc.c
@@ -200,13 +200,15 @@ int smc_clc_send_confirm(struct smc_sock *smc)
 	       SMC_GID_SIZE);
 	memcpy(&cclc.lcl.mac, &link->smcibdev->mac[link->ibport - 1],
 	       sizeof(link->smcibdev->mac));
-
-	/* tbd in follow-on patch: fill in rmb-related values */
-
 	hton24(cclc.qpn, link->roce_qp->qp_num);
+	cclc.rmb_rkey =
+		htonl(conn->rmb_desc->mr_rx[SMC_SINGLE_LINK]->rkey);
 	cclc.conn_idx = 1; /* for now: 1 RMB = 1 RMBE */
 	cclc.rmbe_alert_token = htonl(conn->alert_token_local);
 	cclc.qp_mtu = min(link->path_mtu, link->peer_mtu);
+	cclc.rmbe_size = conn->rmbe_size_short;
+	cclc.rmb_dma_addr =
+		cpu_to_be64((u64)conn->rmb_desc->dma_addr[SMC_SINGLE_LINK]);
 	hton24(cclc.psn, link->psn_initial);
 
 	memcpy(cclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
@@ -252,6 +254,8 @@ int smc_clc_send_accept(struct smc_sock *new_smc, int srv_first_contact)
 	memcpy(&aclc.lcl.mac, link->smcibdev->mac[link->ibport - 1],
 	       sizeof(link->smcibdev->mac[link->ibport - 1]));
 	hton24(aclc.qpn, link->roce_qp->qp_num);
+	aclc.rmb_rkey =
+		htonl(conn->rmb_desc->mr_rx[SMC_SINGLE_LINK]->rkey);
 	aclc.conn_idx = 1;			/* as long as 1 RMB = 1 RMBE */
 	aclc.rmbe_alert_token = htonl(conn->alert_token_local);
 	aclc.qp_mtu = link->path_mtu;
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 0eed4c1..2b2e739 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -166,6 +166,15 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 	if (rc)
 		goto free_lgr;
 	init_waitqueue_head(&lnk->wr_tx_wait);
+	rc = smc_ib_create_protection_domain(lnk);
+	if (rc)
+		goto free_link_mem;
+	rc = smc_ib_create_queue_pair(lnk);
+	if (rc)
+		goto dealloc_pd;
+	rc = smc_wr_create_link(lnk);
+	if (rc)
+		goto destroy_qp;
 
 	smc->conn.lgr = lgr;
 	rwlock_init(&lgr->conns_lock);
@@ -174,6 +183,12 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 	spin_unlock_bh(&smc_lgr_list.lock);
 	return 0;
 
+destroy_qp:
+	smc_ib_destroy_queue_pair(lnk);
+dealloc_pd:
+	smc_ib_dealloc_protection_domain(lnk);
+free_link_mem:
+	smc_wr_free_link_mem(lnk);
 free_lgr:
 	kfree(lgr);
 out:
@@ -211,7 +226,10 @@ void smc_conn_free(struct smc_connection *conn)
 static void smc_link_clear(struct smc_link *lnk)
 {
 	lnk->peer_qpn = 0;
+	smc_ib_modify_qp_reset(lnk);
 	smc_wr_free_link(lnk);
+	smc_ib_destroy_queue_pair(lnk);
+	smc_ib_dealloc_protection_domain(lnk);
 	smc_wr_free_link_mem(lnk);
 }
 
@@ -223,6 +241,10 @@ static void smc_lgr_free_sndbufs(struct smc_link_group *lgr)
 	for (i = 0; i < SMC_RMBE_SIZES; i++) {
 		list_for_each_entry_safe(sndbuf_desc, bf_desc, &lgr->sndbufs[i],
 					 list) {
+			list_del(&sndbuf_desc->list);
+			smc_ib_buf_unmap(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+					 smc_uncompress_bufsize(i),
+					 sndbuf_desc, DMA_TO_DEVICE);
 			kfree(sndbuf_desc->cpu_addr);
 			kfree(sndbuf_desc);
 		}
@@ -232,11 +254,16 @@ static void smc_lgr_free_sndbufs(struct smc_link_group *lgr)
 static void smc_lgr_free_rmbs(struct smc_link_group *lgr)
 {
 	struct smc_buf_desc *rmb_desc, *bf_desc;
+	struct smc_link *lnk = &lgr->lnk[SMC_SINGLE_LINK];
 	int i;
 
 	for (i = 0; i < SMC_RMBE_SIZES; i++) {
 		list_for_each_entry_safe(rmb_desc, bf_desc, &lgr->rmbs[i],
 					 list) {
+			list_del(&rmb_desc->list);
+			smc_ib_buf_unmap(lnk->smcibdev,
+					 smc_uncompress_bufsize(i),
+					 rmb_desc, DMA_FROM_DEVICE);
 			kfree(rmb_desc->cpu_addr);
 			kfree(rmb_desc);
 		}
@@ -550,6 +577,18 @@ int smc_rmb_create(struct smc_sock *smc)
 			kfree(rmb_desc);
 			continue; /* if mapping failed, try smaller one */
 		}
+		rc = smc_ib_get_memory_region(lgr->lnk[SMC_SINGLE_LINK].roce_pd,
+					      IB_ACCESS_REMOTE_WRITE |
+					      IB_ACCESS_LOCAL_WRITE,
+					     &rmb_desc->mr_rx[SMC_SINGLE_LINK]);
+		if (rc) {
+			smc_ib_buf_unmap(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+					 tmp_bufsize, rmb_desc,
+					 DMA_FROM_DEVICE);
+			kfree(rmb_desc->cpu_addr);
+			kfree(rmb_desc);
+			continue;
+		}
 		rmb_desc->used = 1;
 		write_lock_bh(&lgr->rmbs_lock);
 		list_add(&rmb_desc->list,
@@ -567,3 +606,38 @@ int smc_rmb_create(struct smc_sock *smc)
 		return -ENOMEM;
 	}
 }
+
+static inline int smc_rmb_reserve_rtoken_idx(struct smc_link_group *lgr)
+{
+	int i;
+
+	for_each_clear_bit(i, lgr->rtokens_used_mask, SMC_RMBS_PER_LGR_MAX) {
+		if (!test_and_set_bit(i, lgr->rtokens_used_mask))
+			return i;
+	}
+	return -ENOSPC;
+}
+
+/* save rkey and dma_addr received from peer during clc handshake */
+int smc_rmb_rtoken_handling(struct smc_connection *conn,
+			    struct smc_clc_msg_accept_confirm *clc)
+{
+	u64 dma_addr = be64_to_cpu(clc->rmb_dma_addr);
+	struct smc_link_group *lgr = conn->lgr;
+	u32 rkey = ntohl(clc->rmb_rkey);
+	int i;
+
+	for (i = 0; i < SMC_RMBS_PER_LGR_MAX; i++) {
+		if ((lgr->rtokens[i][SMC_SINGLE_LINK].rkey == rkey) &&
+		    test_bit(i, lgr->rtokens_used_mask)) {
+			conn->rtoken_idx = i;
+			return 0;
+		}
+	}
+	conn->rtoken_idx = smc_rmb_reserve_rtoken_idx(lgr);
+	if (conn->rtoken_idx < 0)
+		return conn->rtoken_idx;
+	lgr->rtokens[conn->rtoken_idx][SMC_SINGLE_LINK].rkey = rkey;
+	lgr->rtokens[conn->rtoken_idx][SMC_SINGLE_LINK].dma_addr = dma_addr;
+	return 0;
+}
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
index c841f5c..97805b2 100644
--- a/net/smc/smc_core.h
+++ b/net/smc/smc_core.h
@@ -90,9 +90,18 @@ struct smc_buf_desc {
 	u64			dma_addr[SMC_LINKS_PER_LGR_MAX];
 						/* mapped address of buffer */
 	void			*cpu_addr;	/* virtual address of buffer */
+	struct ib_mr		*mr_rx[SMC_LINKS_PER_LGR_MAX];
+						/* for rmb only:
+						 * rkey provided to peer
+						 */
 	u32			used;		/* currently used / unused */
 };
 
+struct smc_rtoken {				/* address/key of remote RMB */
+	u64			dma_addr;
+	u32			rkey;
+};
+
 struct smc_link_group {
 	struct list_head	list;
 	enum smc_lgr_role	role;		/* client or server */
@@ -109,6 +118,13 @@ struct smc_link_group {
 	rwlock_t		sndbufs_lock;	/* protects tx buffers */
 	struct list_head	rmbs[SMC_RMBE_SIZES];	/* rx buffers */
 	rwlock_t		rmbs_lock;	/* protects rx buffers */
+	struct smc_rtoken	rtokens[SMC_RMBS_PER_LGR_MAX]
+				       [SMC_LINKS_PER_LGR_MAX];
+						/* remote addr/key pairs */
+	unsigned long		rtokens_used_mask[BITS_TO_LONGS(
+							SMC_RMBS_PER_LGR_MAX)];
+						/* used rtoken elements */
+
 	struct delayed_work	free_work;	/* delayed freeing of an lgr */
 	bool			sync_err;	/* lgr no longer fits to peer */
 };
@@ -153,5 +169,7 @@ void smc_lgr_free(struct smc_link_group *lgr);
 void smc_lgr_terminate(struct smc_link_group *lgr);
 int smc_sndbuf_create(struct smc_sock *smc);
 int smc_rmb_create(struct smc_sock *smc);
+int smc_rmb_rtoken_handling(struct smc_connection *conn,
+			    struct smc_clc_msg_accept_confirm *clc);
 
 #endif
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index b3e40f7..0c044d6 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/random.h>
+#include <linux/workqueue.h>
 #include <rdma/ib_verbs.h>
 
 #include "smc_pnet.h"
@@ -20,6 +21,11 @@
 #include "smc_wr.h"
 #include "smc.h"
 
+#define SMC_QP_MIN_RNR_TIMER		5
+#define SMC_QP_TIMEOUT			15 /* 4096 * 2 ** timeout usec */
+#define SMC_QP_RETRY_CNT			7 /* 7: infinite */
+#define SMC_QP_RNR_RETRY			7 /* 7: infinite */
+
 struct smc_ib_devices smc_ib_devices = {	/* smc-registered ib devices */
 	.lock = __SPIN_LOCK_UNLOCKED(smc_ib_devices.lock),
 	.list = LIST_HEAD_INIT(smc_ib_devices.list),
@@ -31,6 +37,169 @@ u8 local_systemid[SMC_SYSTEMID_LEN] = SMC_LOCAL_SYSTEMID_RESET;	/* unique system
 								 * identifier
 								 */
 
+int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
+			     struct ib_mr **mr)
+{
+	int rc;
+
+	if (*mr)
+		return 0; /* already done */
+
+	/* obtain unique key -
+	 * next invocation of get_dma_mr returns a different key!
+	 */
+	*mr = pd->device->get_dma_mr(pd, access_flags);
+	rc = PTR_ERR_OR_ZERO(*mr);
+	if (IS_ERR(*mr))
+		*mr = NULL;
+	return rc;
+}
+
+static int smc_ib_modify_qp_init(struct smc_link *lnk)
+{
+	struct ib_qp_attr qp_attr;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_INIT;
+	qp_attr.pkey_index = 0;
+	qp_attr.port_num = lnk->ibport;
+	qp_attr.qp_access_flags = IB_ACCESS_LOCAL_WRITE
+				| IB_ACCESS_REMOTE_WRITE;
+	return ib_modify_qp(lnk->roce_qp, &qp_attr,
+			    IB_QP_STATE | IB_QP_PKEY_INDEX |
+			    IB_QP_ACCESS_FLAGS | IB_QP_PORT);
+}
+
+static int smc_ib_modify_qp_rtr(struct smc_link *lnk)
+{
+	enum ib_qp_attr_mask qp_attr_mask =
+		IB_QP_STATE | IB_QP_AV | IB_QP_PATH_MTU | IB_QP_DEST_QPN |
+		IB_QP_RQ_PSN | IB_QP_MAX_DEST_RD_ATOMIC | IB_QP_MIN_RNR_TIMER;
+	struct ib_qp_attr qp_attr;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_RTR;
+	qp_attr.path_mtu = min(lnk->path_mtu, lnk->peer_mtu);
+	qp_attr.ah_attr.port_num = lnk->ibport;
+	qp_attr.ah_attr.ah_flags = IB_AH_GRH;
+	qp_attr.ah_attr.grh.hop_limit = 1;
+	memcpy(&qp_attr.ah_attr.grh.dgid, lnk->peer_gid,
+	       sizeof(lnk->peer_gid));
+	memcpy(&qp_attr.ah_attr.dmac, lnk->peer_mac,
+	       sizeof(lnk->peer_mac));
+	qp_attr.dest_qp_num = lnk->peer_qpn;
+	qp_attr.rq_psn = lnk->peer_psn; /* starting receive packet seq # */
+	qp_attr.max_dest_rd_atomic = 1; /* max # of resources for incoming
+					 * requests
+					 */
+	qp_attr.min_rnr_timer = SMC_QP_MIN_RNR_TIMER;
+
+	return ib_modify_qp(lnk->roce_qp, &qp_attr, qp_attr_mask);
+}
+
+int smc_ib_modify_qp_rts(struct smc_link *lnk)
+{
+	struct ib_qp_attr qp_attr;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_RTS;
+	qp_attr.timeout = SMC_QP_TIMEOUT;	/* local ack timeout */
+	qp_attr.retry_cnt = SMC_QP_RETRY_CNT;	/* retry count */
+	qp_attr.rnr_retry = SMC_QP_RNR_RETRY;	/* RNR retries, 7=infinite */
+	qp_attr.sq_psn = lnk->psn_initial;	/* starting send packet seq # */
+	qp_attr.max_rd_atomic = 1;	/* # of outstanding RDMA reads and
+					 * atomic ops allowed
+					 */
+	return ib_modify_qp(lnk->roce_qp, &qp_attr,
+			    IB_QP_STATE | IB_QP_TIMEOUT | IB_QP_RETRY_CNT |
+			    IB_QP_SQ_PSN | IB_QP_RNR_RETRY |
+			    IB_QP_MAX_QP_RD_ATOMIC);
+}
+
+int smc_ib_modify_qp_reset(struct smc_link *lnk)
+{
+	struct ib_qp_attr qp_attr;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_RESET;
+	return ib_modify_qp(lnk->roce_qp, &qp_attr, IB_QP_STATE);
+}
+
+int smc_ib_ready_link(struct smc_link *lnk)
+{
+	struct smc_link_group *lgr =
+		container_of(lnk, struct smc_link_group, lnk[0]);
+	int rc = 0;
+
+	rc = smc_ib_modify_qp_init(lnk);
+	if (rc)
+		goto out;
+
+	rc = smc_ib_modify_qp_rtr(lnk);
+	if (rc)
+		goto out;
+	smc_wr_remember_qp_attr(lnk);
+	rc = ib_req_notify_cq(lnk->smcibdev->roce_cq_recv,
+			      IB_CQ_SOLICITED_MASK);
+	if (rc)
+		goto out;
+	rc = smc_wr_rx_post_init(lnk);
+	if (rc)
+		goto out;
+	smc_wr_remember_qp_attr(lnk);
+
+	if (lgr->role == SMC_SERV) {
+		rc = smc_ib_modify_qp_rts(lnk);
+		if (rc)
+			goto out;
+		smc_wr_remember_qp_attr(lnk);
+	}
+out:
+	return rc;
+}
+
+/* process context wrapper for might_sleep smc_ib_remember_port_attr */
+static void smc_ib_port_event_work(struct work_struct *work)
+{
+	struct smc_ib_device *smcibdev = container_of(
+		work, struct smc_ib_device, port_event_work);
+	u8 port_idx;
+
+	for_each_set_bit(port_idx, &smcibdev->port_event_mask, SMC_MAX_PORTS) {
+		smc_ib_remember_port_attr(smcibdev, port_idx + 1);
+		clear_bit(port_idx, &smcibdev->port_event_mask);
+	}
+}
+
+/* can be called in IRQ context */
+static void smc_ib_global_event_handler(struct ib_event_handler *handler,
+					struct ib_event *ibevent)
+{
+	struct smc_ib_device *smcibdev;
+	u8 port_idx;
+
+	smcibdev = container_of(handler, struct smc_ib_device, event_handler);
+	switch (ibevent->event) {
+	case IB_EVENT_PORT_ERR:
+		port_idx = ibevent->element.port_num - 1;
+		set_bit(port_idx, &smcibdev->port_event_mask);
+		schedule_work(&smcibdev->port_event_work);
+		/* fall through */
+	case IB_EVENT_DEVICE_FATAL:
+		/* tbd in follow-on patch:
+		 * abnormal close of corresponding connections
+		 */
+		break;
+	case IB_EVENT_PORT_ACTIVE:
+		port_idx = ibevent->element.port_num - 1;
+		set_bit(port_idx, &smcibdev->port_event_mask);
+		schedule_work(&smcibdev->port_event_work);
+		break;
+	default:
+		break;
+	}
+}
+
 void smc_ib_dealloc_protection_domain(struct smc_link *lnk)
 {
 	ib_dealloc_pd(lnk->roce_pd);
@@ -121,6 +290,17 @@ int smc_ib_buf_map(struct smc_ib_device *smcibdev, int buf_size,
 	return rc;
 }
 
+void smc_ib_buf_unmap(struct smc_ib_device *smcibdev, int buf_size,
+		      struct smc_buf_desc *buf_slot,
+		      enum dma_data_direction data_direction)
+{
+	if (!buf_slot->dma_addr[SMC_SINGLE_LINK])
+		return; /* already unmapped */
+	ib_dma_unmap_single(smcibdev->ibdev, *buf_slot->dma_addr, buf_size,
+			    data_direction);
+	buf_slot->dma_addr[SMC_SINGLE_LINK] = 0;
+}
+
 static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ibport)
 {
 	struct net_device *ndev;
@@ -184,6 +364,48 @@ int smc_ib_remember_port_attr(struct smc_ib_device *smcibdev, u8 ibport)
 	return rc;
 }
 
+long smc_ib_setup_per_ibdev(struct smc_ib_device *smcibdev)
+{
+	struct ib_cq_init_attr cqattr =	{
+		.cqe = SMC_WR_MAX_CQE, .comp_vector = 0 };
+	long rc;
+
+	smcibdev->roce_cq_send = ib_create_cq(smcibdev->ibdev,
+					      smc_wr_tx_cq_handler, NULL,
+					      smcibdev, &cqattr);
+	rc = PTR_ERR_OR_ZERO(smcibdev->roce_cq_send);
+	if (IS_ERR(smcibdev->roce_cq_send)) {
+		smcibdev->roce_cq_send = NULL;
+		goto err;
+	}
+	smcibdev->roce_cq_recv = ib_create_cq(smcibdev->ibdev,
+					      smc_wr_rx_cq_handler, NULL,
+					      smcibdev, &cqattr);
+	rc = PTR_ERR_OR_ZERO(smcibdev->roce_cq_recv);
+	if (IS_ERR(smcibdev->roce_cq_recv)) {
+		smcibdev->roce_cq_recv = NULL;
+		goto err_cq;
+	}
+	INIT_IB_EVENT_HANDLER(&smcibdev->event_handler, smcibdev->ibdev,
+			      smc_ib_global_event_handler);
+	ib_register_event_handler(&smcibdev->event_handler);
+	smc_wr_add_dev(smcibdev);
+	return rc;
+
+err_cq:
+	ib_destroy_cq(smcibdev->roce_cq_send);
+err:
+	return rc;
+}
+
+static void smc_ib_cleanup_per_ibdev(struct smc_ib_device *smcibdev)
+{
+	smc_wr_remove_dev(smcibdev);
+	ib_unregister_event_handler(&smcibdev->event_handler);
+	ib_destroy_cq(smcibdev->roce_cq_recv);
+	ib_destroy_cq(smcibdev->roce_cq_send);
+}
+
 static struct ib_client smc_ib_client;
 
 /* callback function for ib_register_client() */
@@ -200,6 +422,7 @@ static void smc_ib_add_dev(struct ib_device *ibdev)
 		return;
 
 	smcibdev->ibdev = ibdev;
+	INIT_WORK(&smcibdev->port_event_work, smc_ib_port_event_work);
 
 	for (i = 1; i <= SMC_MAX_PORTS; i++) {
 		if (smc_pnet_exists_in_table(smcibdev, i) &&
@@ -209,6 +432,10 @@ static void smc_ib_add_dev(struct ib_device *ibdev)
 				kfree(smcibdev);
 				return;
 			}
+			if (smc_ib_setup_per_ibdev(smcibdev)) {
+				kfree(smcibdev);
+				return;
+			}
 			smcibdev->initialized = 1;
 			break;
 		}
@@ -229,6 +456,9 @@ static void smc_ib_remove_dev(struct ib_device *ibdev, void *client_data)
 	spin_lock(&smc_ib_devices.lock);
 	list_del_init(&smcibdev->list); /* remove from smc_ib_devices */
 	spin_unlock(&smc_ib_devices.lock);
+	if (smcibdev->initialized)
+		smc_ib_cleanup_per_ibdev(smcibdev);
+	cancel_work_sync(&smcibdev->port_event_work);
 	kfree(smcibdev);
 }
 
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index 441fd16..3fe2d55 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -29,6 +29,7 @@ struct smc_ib_device {				/* ib-device infos for smc */
 	struct list_head	list;
 	struct ib_device	*ibdev;
 	struct ib_port_attr	pattr[SMC_MAX_PORTS];	/* ib dev. port attrs */
+	struct ib_event_handler	event_handler;	/* global ib_event handler */
 	struct ib_cq		*roce_cq_send;	/* send completion queue */
 	struct ib_cq		*roce_cq_recv;	/* recv completion queue */
 	struct tasklet_struct	send_tasklet;	/* called by send cq handler */
@@ -36,6 +37,8 @@ struct smc_ib_device {				/* ib-device infos for smc */
 	char			mac[SMC_MAX_PORTS][6]; /* mac address per port*/
 	union ib_gid		gid[SMC_MAX_PORTS]; /* gid per port */
 	u8			initialized : 1; /* ib dev CQ, evthdl done */
+	struct work_struct	port_event_work;
+	unsigned long		port_event_mask;
 };
 
 struct smc_buf_desc;
@@ -48,9 +51,19 @@ int smc_ib_remember_port_attr(struct smc_ib_device *smcibdev, u8 ibport);
 int smc_ib_buf_map(struct smc_ib_device *smcibdev, int buf_size,
 		   struct smc_buf_desc *buf_slot,
 		   enum dma_data_direction data_direction);
+void smc_ib_buf_unmap(struct smc_ib_device *smcibdev, int bufsize,
+		      struct smc_buf_desc *buf_slot,
+		      enum dma_data_direction data_direction);
 void smc_ib_dealloc_protection_domain(struct smc_link *lnk);
 int smc_ib_create_protection_domain(struct smc_link *lnk);
 void smc_ib_destroy_queue_pair(struct smc_link *lnk);
 int smc_ib_create_queue_pair(struct smc_link *lnk);
+int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
+			     struct ib_mr **mr);
+int smc_ib_ready_link(struct smc_link *lnk);
+int smc_ib_modify_qp_rts(struct smc_link *lnk);
+int smc_ib_modify_qp_reset(struct smc_link *lnk);
+long smc_ib_setup_per_ibdev(struct smc_ib_device *smcibdev);
+
 
 #endif
diff --git a/net/smc/smc_pnet.c b/net/smc/smc_pnet.c
index e007137..1b5c67b 100644
--- a/net/smc/smc_pnet.c
+++ b/net/smc/smc_pnet.c
@@ -223,6 +223,9 @@ static int smc_pnet_add_ib(struct smc_pnetentry *pnetelem, char *name,
 					       pnetelem->ib_port);
 		if (rc)
 			return rc;
+		rc = smc_ib_setup_per_ibdev(smcibdev);
+		if (rc)
+			return rc;
 		smcibdev->initialized = 1;
 	}
 	return rc;
diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
index a2bc6b6..5cbc1e5 100644
--- a/net/smc/smc_wr.c
+++ b/net/smc/smc_wr.c
@@ -393,6 +393,7 @@ static void smc_wr_init_sge(struct smc_link *lnk)
 		lnk->wr_tx_sges[i].addr =
 			lnk->wr_tx_dma_addr + i * SMC_WR_BUF_SIZE;
 		lnk->wr_tx_sges[i].length = SMC_WR_TX_SIZE;
+		lnk->wr_tx_sges[i].lkey = lnk->roce_pd->local_dma_lkey;
 		lnk->wr_tx_ibs[i].next = NULL;
 		lnk->wr_tx_ibs[i].sg_list = &lnk->wr_tx_sges[i];
 		lnk->wr_tx_ibs[i].num_sge = 1;
@@ -404,6 +405,7 @@ static void smc_wr_init_sge(struct smc_link *lnk)
 		lnk->wr_rx_sges[i].addr =
 			lnk->wr_rx_dma_addr + i * SMC_WR_BUF_SIZE;
 		lnk->wr_rx_sges[i].length = SMC_WR_BUF_SIZE;
+		lnk->wr_rx_sges[i].lkey = lnk->roce_pd->local_dma_lkey;
 		lnk->wr_rx_ibs[i].next = NULL;
 		lnk->wr_rx_ibs[i].sg_list = &lnk->wr_rx_sges[i];
 		lnk->wr_rx_ibs[i].num_sge = 1;
-- 
2.8.4
