From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/15] smc: link layer control (LLC)
Date: Fri,  3 Jun 2016 17:27:09 +0200
Message-ID: <201606031527.u53FQ6R0040077@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45213 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932867AbcFCP1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:51 -0400
Received: from pps.filterd (m0048827.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ6R0040077
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:50 -0400
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com [195.75.94.113])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23b3g21cgw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:45 -0400
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:43 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

send and receive LLC messages CONFIRM_LINK (via IB message send and CQE)

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   2 +-
 net/smc/af_smc.c   |  94 ++++++++++++++++++++++++++++++-
 net/smc/smc_clc.h  |   2 +
 net/smc/smc_core.c |   8 +++
 net/smc/smc_core.h |   4 ++
 net/smc/smc_llc.c  | 158 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_llc.h  |  63 +++++++++++++++++++++
 7 files changed, 328 insertions(+), 3 deletions(-)
 create mode 100644 net/smc/smc_llc.c
 create mode 100644 net/smc/smc_llc.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index b19120e..73320bf 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_SMC)	+= smc.o
-smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o
+smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 2a7c0df..5cddce0 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -31,6 +31,7 @@
 
 #include "smc.h"
 #include "smc_clc.h"
+#include "smc_llc.h"
 #include "smc_core.h"
 #include "smc_ib.h"
 #include "smc_pnet.h"
@@ -252,6 +253,41 @@ out:
 	return rc;
 }
 
+static int smc_clnt_conf_first_link(struct smc_sock *smc, union ib_gid *gid)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link;
+	int rest;
+	int rc;
+
+	link = &lgr->lnk[SMC_SINGLE_LINK];
+	/* receive CONFIRM LINK request from server over RoCE fabric */
+	rest = wait_for_completion_interruptible_timeout(
+		&link->llc_confirm,
+		SMC_LLC_WAIT_FIRST_TIME);
+	if (rest <= 0) {
+		struct smc_clc_msg_decline dclc;
+
+		rc = smc_clc_wait_msg(smc, &dclc, sizeof(dclc),
+				      SMC_CLC_DECLINE);
+		return rc;
+	}
+
+	rc = smc_ib_modify_qp_rts(link);
+	if (rc)
+		return SMC_CLC_DECL_INTERR;
+
+	smc_wr_remember_qp_attr(link);
+	/* send CONFIRM LINK response over RoCE fabric */
+	rc = smc_llc_send_confirm_link(link,
+				       link->smcibdev->mac[link->ibport - 1],
+				       gid, SMC_LLC_RESP);
+	if (rc < 0)
+		return SMC_CLC_DECL_TCL;
+
+	return rc;
+}
+
 static void smc_conn_save_peer_info(struct smc_sock *smc,
 				    struct smc_clc_msg_accept_confirm *clc)
 {
@@ -369,7 +405,17 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	if (rc)
 		goto out_err_unlock;
 
-	/* tbd in follow-on patch: llc_confirm */
+	if (local_contact == SMC_FIRST_CONTACT) {
+		/* QP confirmation over RoCE fabric */
+		reason_code = smc_clnt_conf_first_link(
+			smc, &smcibdev->gid[ibport - 1]);
+		if (reason_code < 0) {
+			rc = reason_code;
+			goto out_err_unlock;
+		}
+		if (reason_code > 0)
+			goto decline_rdma_unlock;
+	}
 
 	mutex_unlock(&smc_create_lgr_pending);
 out_connected:
@@ -554,6 +600,36 @@ static void smc_close_non_accepted(struct sock *sk)
 	sock_put(sk);
 }
 
+static int smc_serv_conf_first_link(struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link;
+	int rest;
+	int rc;
+
+	link = &lgr->lnk[SMC_SINGLE_LINK];
+	/* send CONFIRM LINK request to client over the RoCE fabric */
+	rc = smc_llc_send_confirm_link(link,
+				       link->smcibdev->mac[link->ibport - 1],
+				       &link->smcibdev->gid[link->ibport - 1],
+				       SMC_LLC_REQ);
+	if (rc < 0)
+		return SMC_CLC_DECL_TCL;
+
+	/* receive CONFIRM LINK response from client over the RoCE fabric */
+	rest = wait_for_completion_interruptible_timeout(
+		&link->llc_confirm_resp,
+		SMC_LLC_WAIT_FIRST_TIME);
+	if (rest <= 0) {
+		struct smc_clc_msg_decline dclc;
+
+		rc = smc_clc_wait_msg(smc, &dclc, sizeof(dclc),
+				      SMC_CLC_DECLINE);
+	}
+
+	return rc;
+}
+
 /* setup for RDMA connection of server */
 static void smc_listen_work(struct work_struct *work)
 {
@@ -666,13 +742,21 @@ static void smc_listen_work(struct work_struct *work)
 		goto decline_rdma;
 	}
 
-	/* tbd in follow-on patch: modify_qp, llc_confirm */
 	if (local_contact == SMC_FIRST_CONTACT) {
 		rc = smc_ib_ready_link(link);
 		if (rc) {
 			reason_code = SMC_CLC_DECL_INTERR;
 			goto decline_rdma;
 		}
+		/* QP confirmation over RoCE fabric */
+		reason_code = smc_serv_conf_first_link(new_smc);
+		if (reason_code < 0) {
+			/* peer is not aware of a problem */
+			rc = reason_code;
+			goto out_err;
+		}
+		if (reason_code > 0)
+			goto decline_rdma;
 	}
 
 out_connected:
@@ -1122,6 +1206,12 @@ static int __init smc_init(void)
 	if (rc)
 		return rc;
 
+	rc = smc_llc_init();
+	if (rc) {
+		pr_err("%s: smc_llc_init fails with %d\n", __func__, rc);
+		goto out_pnet;
+	}
+
 	rc = proto_register(&smc_proto, 1);
 	if (rc) {
 		pr_err("%s: proto_register fails with %d\n", __func__, rc);
diff --git a/net/smc/smc_clc.h b/net/smc/smc_clc.h
index ba42f7b..c1821ff 100644
--- a/net/smc/smc_clc.h
+++ b/net/smc/smc_clc.h
@@ -33,6 +33,8 @@ static const char SMC_EYECATCHER[4] = {'\xe2', '\xd4', '\xc3', '\xd9'};
 #define SMC_CLC_DECL_SYNCERR	0x04000000  /* synchronization error          */
 #define SMC_CLC_DECL_REPLY	0x06000000  /* reply to a received decline    */
 #define SMC_CLC_DECL_INTERR	0x99990000  /* internal error                 */
+#define SMC_CLC_DECL_TCL	0x02040000  /* timeout w4 QP confirm          */
+#define SMC_CLC_DECL_SEND	0x07000000  /* sending problem                */
 
 struct smc_clc_msg_hdr {	/* header1 of clc messages */
 	u8 eyecatcher[4];	/* eye catcher */
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index c8294f6..55944b4 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -21,9 +21,13 @@
 #include "smc_core.h"
 #include "smc_ib.h"
 #include "smc_wr.h"
+#include "smc_llc.h"
 
+#define SMC_LGR_NUM_INCR	256
 #define SMC_LGR_FREE_DELAY	(600 * HZ)
 
+static u32 smc_lgr_num;			/* unique link group number */
+
 /* Register connection's alert token in our lookup structure.
  * To use rbtrees we have to implement our own insert core.
  * Requires @conns_lock
@@ -150,6 +154,8 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 		INIT_LIST_HEAD(&lgr->sndbufs[i]);
 		INIT_LIST_HEAD(&lgr->rmbs[i]);
 	}
+	smc_lgr_num += SMC_LGR_NUM_INCR;
+	lgr->id = smc_lgr_num;
 	INIT_DELAYED_WORK(&lgr->free_work, smc_lgr_free_work);
 
 	lnk = &lgr->lnk[SMC_SINGLE_LINK];
@@ -176,6 +182,8 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 	rc = smc_wr_create_link(lnk);
 	if (rc)
 		goto destroy_qp;
+	init_completion(&lnk->llc_confirm);
+	init_completion(&lnk->llc_confirm_resp);
 
 	smc->conn.lgr = lgr;
 	rwlock_init(&lgr->conns_lock);
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
index 14fd82f..10b89ab 100644
--- a/net/smc/smc_core.h
+++ b/net/smc/smc_core.h
@@ -74,6 +74,9 @@ struct smc_link {
 	u32			peer_psn;	/* QP rx initial packet seqno */
 	u8			peer_mac[ETH_ALEN];	/* = gid[8:10||13:15] */
 	u8			peer_gid[sizeof(union ib_gid)];	/* gid of peer*/
+	u8			link_id;	/* unique # within link group */
+	struct completion	llc_confirm;	/* wait for rx of conf link */
+	struct completion	llc_confirm_resp; /* wait 4 rx of cnf lnk rsp */
 };
 
 /* For now we just allow one parallel link per link group. The SMC protocol
@@ -125,6 +128,7 @@ struct smc_link_group {
 							SMC_RMBS_PER_LGR_MAX)];
 						/* used rtoken elements */
 
+	u32			id;		/* unique lgr id */
 	struct delayed_work	free_work;	/* delayed freeing of an lgr */
 };
 
diff --git a/net/smc/smc_llc.c b/net/smc/smc_llc.c
new file mode 100644
index 0000000..1a3e811
--- /dev/null
+++ b/net/smc/smc_llc.c
@@ -0,0 +1,158 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Link Layer Control (LLC)
+ *
+ *  For now, we only support the necessary "confirm link" functionality
+ *  which happens for the first RoCE link after successful CLC handshake.
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Klaus Wacker <Klaus.Wacker@de.ibm.com>
+ *              Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#include <net/tcp.h>
+#include <rdma/ib_verbs.h>
+
+#include "smc.h"
+#include "smc_core.h"
+#include "smc_clc.h"
+#include "smc_llc.h"
+
+/********************************** send *************************************/
+
+struct smc_llc_tx_pend {
+};
+
+/* handler for send/transmission completion of an LLC msg */
+static void smc_llc_tx_handler(struct smc_wr_tx_pend_priv *pend,
+			       struct smc_link *link,
+			       enum ib_wc_status wc_status)
+{
+	/* future work: handle wc_status error for recovery and failover */
+}
+
+/**
+ * smc_llc_add_pending_send() - add LLC control message to pending WQE transmits
+ * @link: Pointer to SMC link used for sending LLC control message.
+ * @wr_buf: Out variable returning pointer to work request payload buffer.
+ * @pend: Out variable returning pointer to private pending WR tracking.
+ *	  It's the context the transmit complete handler will get.
+ *
+ * Reserves and pre-fills an entry for a pending work request send/tx.
+ * Used by mid-level smc_llc_send_msg() to prepare for later actual send/tx.
+ * Can sleep due to smc_get_ctrl_buf (if not in softirq context).
+ *
+ * Return: 0 on success, otherwise an error value.
+ */
+static int smc_llc_add_pending_send(struct smc_link *link,
+				    struct smc_wr_buf **wr_buf,
+				    struct smc_wr_tx_pend_priv **pend)
+{
+	int rc;
+
+	rc = smc_wr_tx_get_free_slot(link, smc_llc_tx_handler, wr_buf, pend);
+	if (rc < 0)
+		return rc;
+	BUILD_BUG_ON_MSG(
+		sizeof(union smc_llc_msg) > SMC_WR_BUF_SIZE,
+		"must increase SMC_WR_BUF_SIZE to at least sizeof(struct smc_llc_msg)");
+	BUILD_BUG_ON_MSG(
+		sizeof(union smc_llc_msg) != SMC_WR_TX_SIZE,
+		"must adapt SMC_WR_TX_SIZE to sizeof(struct smc_llc_msg); if not all smc_wr upper layer protocols use the same message size any more, must start to set link->wr_tx_sges[i].length on each individual smc_wr_tx_send()");
+	BUILD_BUG_ON_MSG(
+		sizeof(struct smc_llc_tx_pend) > SMC_WR_TX_PEND_PRIV_SIZE,
+		"must increase SMC_WR_TX_PEND_PRIV_SIZE to at least sizeof(struct smc_llc_tx_pend)");
+	return 0;
+}
+
+/* high-level API to send LLC confirm link */
+int smc_llc_send_confirm_link(struct smc_link *link, u8 mac[],
+			      union ib_gid *gid,
+			      enum smc_llc_reqresp reqresp)
+{
+	struct smc_link_group *lgr = container_of(link, struct smc_link_group,
+						  lnk[SMC_SINGLE_LINK]);
+	struct smc_llc_msg_confirm_link *confllc;
+	struct smc_wr_tx_pend_priv *pend;
+	struct smc_wr_buf *wr_buf;
+	int rc;
+
+	rc = smc_llc_add_pending_send(link, &wr_buf, &pend);
+	if (rc)
+		return rc;
+	confllc = (struct smc_llc_msg_confirm_link *)wr_buf;
+	memset(confllc, 0, sizeof(*confllc));
+	confllc->hd.common.type = SMC_LLC_CONFIRM_LINK;
+	confllc->hd.length = sizeof(struct smc_llc_msg_confirm_link);
+	if (reqresp == SMC_LLC_RESP)
+		confllc->hd.flags |= SMC_LLC_FLAG_RESP;
+	memcpy(confllc->sender_mac, mac, ETH_ALEN);
+	memcpy(&confllc->sender_gid, gid, SMC_GID_SIZE);
+	hton24(confllc->sender_qp_num, link->roce_qp->qp_num);
+	/* confllc->link_num = SMC_SINGLE_LINK; already done by memset above */
+	confllc->link_uid = htonl(lgr->id);
+	confllc->max_links = SMC_LINKS_PER_LGR_MAX;
+	/* send llc message */
+	rc = smc_wr_tx_send(link, pend);
+	return rc;
+}
+
+/********************************* receive ***********************************/
+
+static void smc_llc_rx_confirm_link(struct smc_link *link,
+				    struct smc_llc_msg_confirm_link *llc)
+{
+	struct smc_link_group *lgr;
+
+	lgr = container_of(link, struct smc_link_group, lnk[SMC_SINGLE_LINK]);
+	if (llc->hd.flags & SMC_LLC_FLAG_RESP) {
+		if (lgr->role == SMC_SERV)
+			complete(&link->llc_confirm_resp);
+	} else {
+		if (lgr->role == SMC_CLNT) {
+			link->link_id = llc->link_num;
+			complete(&link->llc_confirm);
+		}
+	}
+}
+
+static void smc_llc_rx_handler(struct ib_wc *wc, void *buf)
+{
+	struct smc_link *link = (struct smc_link *)wc->qp->qp_context;
+	union smc_llc_msg *llc = buf;
+
+	if (wc->byte_len < sizeof(*llc))
+		return; /* short message */
+	if (llc->raw.hdr.length != sizeof(*llc))
+		return; /* invalid message */
+	if (llc->raw.hdr.common.type == SMC_LLC_CONFIRM_LINK)
+		smc_llc_rx_confirm_link(link, &llc->confirm_link);
+}
+
+/***************************** init, exit, misc ******************************/
+
+static struct smc_wr_rx_handler smc_llc_rx_handlers[] = {
+	{
+		.handler	= smc_llc_rx_handler,
+		.type		= SMC_LLC_CONFIRM_LINK
+	},
+	{
+		.handler	= NULL,
+	}
+};
+
+int __init smc_llc_init(void)
+{
+	struct smc_wr_rx_handler *handler;
+	int rc = 0;
+
+	for (handler = smc_llc_rx_handlers; handler->handler; handler++) {
+		INIT_HLIST_NODE(&handler->list);
+		rc = smc_wr_rx_register_handler(handler);
+		if (rc)
+			break;
+	}
+	return rc;
+}
diff --git a/net/smc/smc_llc.h b/net/smc/smc_llc.h
new file mode 100644
index 0000000..932d96d
--- /dev/null
+++ b/net/smc/smc_llc.h
@@ -0,0 +1,63 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Definitions for LLC (link layer control) message handling
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Klaus Wacker <Klaus.Wacker@de.ibm.com>
+ *              Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#ifndef SMC_LLC_H
+#define SMC_LLC_H
+
+#include "smc_wr.h"
+
+#define SMC_LLC_FLAG_RESP		0x80
+
+#define SMC_LLC_WAIT_FIRST_TIME		(5 * HZ)
+
+enum smc_llc_reqresp {
+	SMC_LLC_REQ,
+	SMC_LLC_RESP
+};
+
+enum smc_llc_msg_type {
+	SMC_LLC_CONFIRM_LINK		= 0x01,
+};
+
+#define SMC_LLC_DATA_LEN		40
+
+struct smc_llc_hdr {
+	struct smc_wr_rx_hdr common;
+	u8 length;	/* 44 */
+	u8 reserved;
+	u8 flags;
+} __packed;
+
+struct smc_llc_msg_confirm_link {	/* type 0x01 */
+	struct smc_llc_hdr hd;
+	u8 sender_mac[ETH_ALEN];
+	union ib_gid sender_gid;
+	u8 sender_qp_num[3];
+	u8 link_num;
+	__be32 link_uid;
+	u8 max_links;
+	u8 reserved[9];
+} __packed;
+
+union smc_llc_msg {
+	struct smc_llc_msg_confirm_link confirm_link;
+	struct {
+		struct smc_llc_hdr hdr;
+		u8 data[SMC_LLC_DATA_LEN];
+	} __packed raw;
+} __packed;
+
+/* transmit */
+int smc_llc_send_confirm_link(struct smc_link *, u8 *, union ib_gid *,
+			      enum smc_llc_reqresp);
+int smc_llc_init(void) __init;
+
+#endif /* SMC_LLC_H */
-- 
2.6.6
