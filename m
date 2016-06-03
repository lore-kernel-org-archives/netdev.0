From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 11/15] smc: connection data control (CDC)
Date: Fri,  3 Jun 2016 17:27:10 +0200
Message-ID: <201606031527.u53FQ0iX002632@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:65115 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1422729AbcFCP1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:54 -0400
Received: from pps.filterd (m0049461.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ0iX002632
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:54 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bbsej9wr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:53 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:51 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

send and receive CDC messages (via IB message send and CQE)

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   1 +
 net/smc/af_smc.c   |   8 ++
 net/smc/smc.h      |  89 +++++++++++++++++
 net/smc/smc_cdc.c  | 281 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_cdc.h  | 175 +++++++++++++++++++++++++++++++++
 net/smc/smc_core.c |   6 ++
 net/smc/smc_wr.c   |  19 ++++
 net/smc/smc_wr.h   |   8 ++
 8 files changed, 587 insertions(+)
 create mode 100644 net/smc/smc_cdc.c
 create mode 100644 net/smc/smc_cdc.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index 73320bf..ec0fd03 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,3 @@
 obj-$(CONFIG_SMC)	+= smc.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
+smc-y += smc_cdc.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 5cddce0..af82d28 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -32,6 +32,7 @@
 #include "smc.h"
 #include "smc_clc.h"
 #include "smc_llc.h"
+#include "smc_cdc.h"
 #include "smc_core.h"
 #include "smc_ib.h"
 #include "smc_pnet.h"
@@ -292,6 +293,7 @@ static void smc_conn_save_peer_info(struct smc_sock *smc,
 				    struct smc_clc_msg_accept_confirm *clc)
 {
 	smc->conn.peer_conn_idx = clc->conn_idx;
+	smc->conn.local_tx_ctrl.token = ntohl(clc->rmbe_alert_token);
 	smc->conn.peer_rmbe_len = smc_uncompress_bufsize(clc->rmbe_size);
 	atomic_set(&smc->conn.peer_rmbe_space, smc->conn.peer_rmbe_len);
 }
@@ -1212,6 +1214,12 @@ static int __init smc_init(void)
 		goto out_pnet;
 	}
 
+	rc = smc_cdc_init();
+	if (rc) {
+		pr_err("%s: smc_cdc_init fails with %d\n", __func__, rc);
+		goto out_pnet;
+	}
+
 	rc = proto_register(&smc_proto, 1);
 	if (rc) {
 		pr_err("%s: proto_register fails with %d\n", __func__, rc);
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 17a2d9d..49e56469 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -31,6 +31,66 @@ struct smc_wr_rx_hdr {	/* common prefix part of LLC and CDC to demultiplex */
 	u8			type;
 } __packed;
 
+struct smc_cdc_conn_state_flags {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	u8	peer_done_writing : 1;	/* Sending done indicator */
+	u8	peer_conn_closed : 1;	/* Peer connection closed indicator */
+	u8	peer_conn_abort : 1;	/* Abnormal close indicator */
+	u8	reserved : 5;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	u8	reserved : 5;
+	u8	peer_conn_abort : 1;
+	u8	peer_conn_closed : 1;
+	u8	peer_done_writing : 1;
+#endif
+} __packed;
+
+struct smc_cdc_producer_flags {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	u8	write_blocked : 1;	/* Writing Blocked, no rx buf space */
+	u8	urg_data_pending : 1;	/* Urgent Data Pending */
+	u8	urg_data_present : 1;	/* Urgent Data Present */
+	u8	cons_curs_upd_req : 1;	/* cursor update requested */
+	u8	failover_validation : 1;/* message replay due to failover */
+	u8	reserved : 3;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	u8	reserved : 3;
+	u8	failover_validation : 1;
+	u8	cons_curs_upd_req : 1;
+	u8	urg_data_present : 1;
+	u8	urg_data_pending : 1;
+	u8	write_blocked : 1;
+#endif
+} __packed;
+
+/* in host byte order */
+struct smc_host_cursor {	/* SMC cursor - an offset in an RMBE */
+	u16	reserved;
+	u16	wrap;		/* window wrap sequence number */
+	u32	count;		/* cursor (= offset) part */
+} __aligned(8);
+
+/* in host byte order */
+union smc_host_cursor_ovl {		/* overlay for atomic cursor handling */
+	struct smc_host_cursor	curs;
+	u64			acurs;
+} __aligned(8);
+
+/* in host byte order, except for flag bitfields in network byte order */
+struct smc_host_cdc_msg {		/* Connection Data Control message */
+	struct smc_wr_rx_hdr		common; /* .type = 0xFE */
+	u8				len;	/* length = 44 */
+	u16				seqno;	/* connection seq # */
+	u32				token;	/* alert_token */
+	union smc_host_cursor_ovl	prod;		/* producer cursor */
+	union smc_host_cursor_ovl	cons;		/* consumer cursor,
+							 * piggy backed "ack"
+							 */
+	struct smc_cdc_producer_flags	prod_flags;	/* conn. tx/rx status */
+	struct smc_cdc_conn_state_flags	conn_state_flags; /* peer conn. status*/
+	u8				reserved[18];
+} __packed __aligned(8);
+
 struct smc_connection {
 	struct rb_node		alert_node;
 	struct smc_link_group	*lgr;		/* link group of connection */
@@ -47,6 +107,35 @@ struct smc_connection {
 	struct smc_buf_desc	*rmb_desc;	/* RMBE descriptor */
 	int			rmbe_size;	/* RMBE size <== sock rmem */
 	int			rmbe_size_short;/* compressed notation */
+
+	struct smc_host_cdc_msg	local_tx_ctrl;	/* host byte order staging
+						 * buffer for CDC msg send
+						 * .prod cf. TCP snd_nxt
+						 * .cons cf. TCP sends ack
+						 */
+	union smc_host_cursor_ovl tx_curs_prep;	/* tx - prepared data
+						 * snd_max..wmem_alloc
+						 */
+	union smc_host_cursor_ovl tx_curs_sent;	/* tx - sent data
+						 * snd_nxt ?
+						 */
+	union smc_host_cursor_ovl tx_curs_fin;	/* tx - confirmed by peer
+						 * snd-wnd-begin ?
+						 */
+	atomic_t		sndbuf_space;	/* remaining space in sndbuf */
+	u16			tx_cdc_seq;	/* sequence # for CDC send */
+	spinlock_t		send_lock;	/* protect wr_sends */
+
+	struct smc_host_cdc_msg	local_rx_ctrl;	/* filled during event_handl.
+						 * .prod cf. TCP rcv_nxt
+						 * .cons cf. TCP snd_una
+						 */
+	union smc_host_cursor_ovl rx_curs_confirmed; /* confirmed to peer
+						      * source of snd_una ?
+						      */
+	atomic_t		bytes_to_rcv;	/* arrived data,
+						 * not yet received
+						 */
 };
 
 struct smc_sock {				/* smc sock container */
diff --git a/net/smc/smc_cdc.c b/net/smc/smc_cdc.c
new file mode 100644
index 0000000..2db2b27
--- /dev/null
+++ b/net/smc/smc_cdc.c
@@ -0,0 +1,281 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Connection Data Control (CDC)
+ * handles flow control
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#include <linux/spinlock.h>
+
+#include "smc.h"
+#include "smc_wr.h"
+#include "smc_cdc.h"
+
+/********************************** send *************************************/
+
+struct smc_cdc_tx_pend {
+	struct smc_connection	*conn;		/* socket connection */
+	union smc_host_cursor_ovl cursor;	/* tx sndbuf cursor sent */
+	union smc_host_cursor_ovl p_cursor;	/* rx RMBE cursor produced */
+	u16			ctrl_seq;	/* conn. tx sequence # */
+};
+
+/* handler for send/transmission completion of a CDC msg */
+static void smc_cdc_tx_handler(struct smc_wr_tx_pend_priv *pnd_snd,
+			       struct smc_link *link,
+			       enum ib_wc_status wc_status)
+{
+	struct smc_cdc_tx_pend *cdcpend = (struct smc_cdc_tx_pend *)pnd_snd;
+	struct smc_sock *smc;
+	int diff;
+
+	if (!cdcpend->conn)
+		/* already dismissed */
+		return;
+
+	smc = container_of(cdcpend->conn, struct smc_sock, conn);
+	bh_lock_sock(&smc->sk);
+	if (!wc_status) {
+		diff = smc_curs_diff(cdcpend->conn->sndbuf_size,
+				     &cdcpend->conn->tx_curs_fin,
+				     &cdcpend->cursor);
+		/* sndbuf_space is decreased in smc_sendmsg */
+		smp_mb__before_atomic();
+		atomic_add(diff, &cdcpend->conn->sndbuf_space);
+		/* guarantee 0 <= sndbuf_space <= sndbuf_size */
+		smp_mb__after_atomic();
+		xchg(&cdcpend->conn->tx_curs_fin.acurs,
+		     cdcpend->cursor.acurs);
+	}
+	/* subsequent patch: wake if send buffer space available */
+	bh_unlock_sock(&smc->sk);
+}
+
+int smc_cdc_get_free_slot(struct smc_link *link,
+			  struct smc_wr_buf **wr_buf,
+			  struct smc_cdc_tx_pend **pend)
+{
+	return smc_wr_tx_get_free_slot(link, smc_cdc_tx_handler, wr_buf,
+				       (struct smc_wr_tx_pend_priv **)pend);
+}
+
+static inline void smc_cdc_add_pending_send(struct smc_connection *conn,
+					    struct smc_cdc_tx_pend *pend)
+{
+	BUILD_BUG_ON_MSG(
+		sizeof(struct smc_cdc_msg) > SMC_WR_BUF_SIZE,
+		"must increase SMC_WR_BUF_SIZE to at least sizeof(struct smc_cdc_msg)");
+	BUILD_BUG_ON_MSG(
+		sizeof(struct smc_cdc_msg) != SMC_WR_TX_SIZE,
+		"must adapt SMC_WR_TX_SIZE to sizeof(struct smc_cdc_msg); if not all smc_wr upper layer protocols use the same message size any more, must start to set link->wr_tx_sges[i].length on each individual smc_wr_tx_send()");
+	BUILD_BUG_ON_MSG(
+		sizeof(struct smc_cdc_tx_pend) > SMC_WR_TX_PEND_PRIV_SIZE,
+		"must increase SMC_WR_TX_PEND_PRIV_SIZE to at least sizeof(struct smc_cdc_tx_pend)");
+	pend->conn = conn;
+	pend->cursor.curs = conn->tx_curs_sent.curs;
+	pend->p_cursor.curs = conn->local_tx_ctrl.prod.curs;
+	pend->ctrl_seq = conn->tx_cdc_seq;
+}
+
+int smc_cdc_msg_send(struct smc_connection *conn,
+		     struct smc_wr_buf *wr_buf,
+		     struct smc_cdc_tx_pend *pend)
+{
+	struct smc_link *link;
+	int rc;
+
+	link = &conn->lgr->lnk[SMC_SINGLE_LINK];
+
+	smc_cdc_add_pending_send(conn, pend);
+
+	conn->tx_cdc_seq++;
+	conn->local_tx_ctrl.seqno = conn->tx_cdc_seq;
+	smc_host_msg_to_cdc((struct smc_cdc_msg *)wr_buf, &conn->local_tx_ctrl);
+	rc = smc_wr_tx_send(link, (struct smc_wr_tx_pend_priv *)pend);
+	if (rc)
+		return rc;
+	xchg(&conn->rx_curs_confirmed.acurs,
+	     smc_curs_read(conn->local_tx_ctrl.cons.acurs));
+	return rc;
+}
+
+int smc_cdc_get_slot_and_msg_send(struct smc_connection *conn)
+{
+	struct smc_cdc_tx_pend *pend;
+	struct smc_wr_buf *wr_buf;
+	int rc;
+
+	rc = smc_cdc_get_free_slot(&conn->lgr->lnk[SMC_SINGLE_LINK], &wr_buf,
+				   &pend);
+	if (rc)
+		return rc;
+
+	return smc_cdc_msg_send(conn, wr_buf, pend);
+}
+
+static bool smc_cdc_tx_filter(struct smc_wr_tx_pend_priv *tx_pend,
+			      unsigned long data)
+{
+	struct smc_connection *conn = (struct smc_connection *)data;
+	struct smc_cdc_tx_pend *cdc_pend =
+		(struct smc_cdc_tx_pend *)tx_pend;
+
+	return cdc_pend->conn == conn;
+}
+
+static void smc_cdc_tx_dismisser(struct smc_wr_tx_pend_priv *tx_pend)
+{
+	struct smc_cdc_tx_pend *cdc_pend =
+		(struct smc_cdc_tx_pend *)tx_pend;
+
+	cdc_pend->conn = NULL;
+}
+
+void smc_cdc_tx_dismiss_slots(struct smc_connection *conn)
+{
+	struct smc_link *link = &conn->lgr->lnk[SMC_SINGLE_LINK];
+
+	smc_wr_tx_dismiss_slots(link, SMC_CDC_MSG_TYPE,
+				smc_cdc_tx_filter, smc_cdc_tx_dismisser,
+				(unsigned long)conn);
+}
+
+/********************************* receive ***********************************/
+
+static inline bool smc_cdc_before(u16 seq1, u16 seq2)
+{
+	return (s16)(seq1 - seq2) < 0;
+}
+
+static void smc_cdc_msg_recv_action(struct smc_sock *smc,
+				    struct smc_link *link,
+				    struct smc_cdc_msg *cdc)
+{
+	union smc_host_cursor_ovl cons_old, prod_old;
+	struct smc_connection *conn = &smc->conn;
+	int diff_cons, diff_prod;
+
+	if (!cdc->prod_flags.failover_validation) {
+		if (smc_cdc_before(ntohs(cdc->seqno),
+				   conn->local_rx_ctrl.seqno))
+			/* received seqno is old */
+			return;
+	}
+	prod_old.acurs = smc_curs_read(conn->local_rx_ctrl.prod.acurs);
+	cons_old.acurs = smc_curs_read(conn->local_rx_ctrl.cons.acurs);
+	smc_cdc_msg_to_host(&conn->local_rx_ctrl, cdc);
+
+	diff_cons = smc_curs_diff(conn->peer_rmbe_len, &cons_old,
+				  &conn->local_rx_ctrl.cons);
+	if (diff_cons) {
+		/* peer_rmbe_space is decreased during data transfer with RDMA
+		 * write
+		 */
+		smp_mb__before_atomic();
+		atomic_add(diff_cons, &conn->peer_rmbe_space);
+		/* guarantee 0 <= peer_rmbe_space <= peer_rmbe_len */
+		smp_mb__after_atomic();
+	}
+
+	diff_prod = smc_curs_diff(conn->rmbe_size, &prod_old,
+				  &conn->local_rx_ctrl.prod);
+	if (diff_prod) {
+		/* bytes_to_rcv is decreased in smc_recvmsg */
+		smp_mb__before_atomic();
+		atomic_add(diff_prod, &conn->bytes_to_rcv);
+		/* guarantee 0 <= bytes_to_rcv <= rmbe_size */
+		smp_mb__after_atomic();
+	}
+
+	if (conn->local_rx_ctrl.conn_state_flags.peer_conn_abort)
+		smc->sk.sk_err = ECONNRESET;
+	if (smc_cdc_rxed_any_close_or_senddone(conn)) {
+		smc->sk.sk_shutdown |= RCV_SHUTDOWN;
+		sock_set_flag(&smc->sk, SOCK_DONE);
+
+		/* subsequent patch: terminate connection */
+	}
+
+	/* piggy backed tx info */
+	/* subsequent patch: wake receivers if receive buffer space available */
+
+	/* subsequent patch: trigger socket release if connection closed */
+
+	/* socket connected but not accepted */
+	if (!smc->sk.sk_socket)
+		return;
+
+	/* data available */
+	/* subsequent patch: send delayed ack, wake receivers */
+}
+
+/* called under tasklet context */
+static inline void smc_cdc_msg_recv(struct smc_cdc_msg *cdc,
+				    struct smc_link *link, u64 wr_id)
+{
+	struct smc_link_group *lgr = container_of(link, struct smc_link_group,
+						  lnk[SMC_SINGLE_LINK]);
+	struct smc_connection *connection;
+	struct smc_sock *smc;
+
+	/* lookup connection */
+	read_lock_bh(&lgr->conns_lock);
+	connection = smc_lgr_find_conn(ntohl(cdc->token), lgr);
+	if (!connection) {
+		read_unlock_bh(&lgr->conns_lock);
+		return;
+	}
+	smc = container_of(connection, struct smc_sock, conn);
+	if (smc->sk.sk_state == SMC_CLOSED) {
+		read_unlock_bh(&lgr->conns_lock);
+		return;
+	}
+	sock_hold(&smc->sk);
+	read_unlock_bh(&lgr->conns_lock);
+	bh_lock_sock(&smc->sk);
+	smc_cdc_msg_recv_action(smc, link, cdc);
+	bh_unlock_sock(&smc->sk);
+	sock_put(&smc->sk); /* no free sk in softirq-context */
+}
+
+/***************************** init, exit, misc ******************************/
+
+static void smc_cdc_rx_handler(struct ib_wc *wc, void *buf)
+{
+	struct smc_link *link = (struct smc_link *)wc->qp->qp_context;
+	struct smc_cdc_msg *cdc = buf;
+
+	if (wc->byte_len < sizeof(*cdc))
+		return; /* short message */
+	if (cdc->len != sizeof(*cdc))
+		return; /* invalid message */
+	smc_cdc_msg_recv(cdc, link, wc->wr_id);
+}
+
+static struct smc_wr_rx_handler smc_cdc_rx_handlers[] = {
+	{
+		.handler	= smc_cdc_rx_handler,
+		.type		= SMC_CDC_MSG_TYPE
+	},
+	{
+		.handler	= NULL,
+	}
+};
+
+int __init smc_cdc_init(void)
+{
+	struct smc_wr_rx_handler *handler;
+	int rc = 0;
+
+	for (handler = smc_cdc_rx_handlers; handler->handler; handler++) {
+		INIT_HLIST_NODE(&handler->list);
+		rc = smc_wr_rx_register_handler(handler);
+		if (rc)
+			break;
+	}
+	return rc;
+}
diff --git a/net/smc/smc_cdc.h b/net/smc/smc_cdc.h
new file mode 100644
index 0000000..0190c9e
--- /dev/null
+++ b/net/smc/smc_cdc.h
@@ -0,0 +1,175 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Connection Data Control (CDC)
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#ifndef SMC_CDC_H
+#define SMC_CDC_H
+
+#include <linux/kernel.h> /* max_t */
+#include <linux/compiler.h> /* __packed */
+#include <linux/atomic.h> /* xchg */
+
+#include "smc.h"
+#include "smc_core.h"
+#include "smc_wr.h"
+
+#define	SMC_CDC_MSG_TYPE		0xFE
+
+/* in network byte order */
+struct smc_cdc_cursor {		/* SMC cursor */
+	__be16	reserved;
+	__be16	wrap;
+	__be32	count;
+} __packed __aligned(8);
+
+/* in network byte order */
+union smc_cdc_cursor_ovl {
+	struct	smc_cdc_cursor	curs;
+	__be64			acurs;
+} __packed __aligned(8);
+
+/* in network byte order */
+struct smc_cdc_msg {
+	struct smc_wr_rx_hdr		common; /* .type = 0xFE */
+	u8				len;	/* 44 */
+	__be16				seqno;
+	__be32				token;
+	union smc_cdc_cursor_ovl	prod;
+	union smc_cdc_cursor_ovl	cons;	/* piggy backed "ack" */
+	struct smc_cdc_producer_flags	prod_flags;
+	struct smc_cdc_conn_state_flags	conn_state_flags;
+	u8				reserved[18];
+} __packed;
+
+static inline bool smc_cdc_rxed_any_close(struct smc_connection *conn)
+{
+	return conn->local_rx_ctrl.conn_state_flags.peer_conn_abort ||
+	       conn->local_rx_ctrl.conn_state_flags.peer_conn_closed;
+}
+
+static inline bool smc_cdc_rxed_any_close_or_senddone(
+	struct smc_connection *conn)
+{
+	return smc_cdc_rxed_any_close(conn) ||
+	       conn->local_rx_ctrl.conn_state_flags.peer_done_writing;
+}
+
+static inline void smc_curs_add(int size, struct smc_host_cursor *curs,
+				int value)
+{
+	curs->wrap += (curs->count + value) / size;
+	curs->count = (curs->count + value) % size;
+}
+
+static inline u64 smc_curs_read(u64 c)
+{
+#if BITS_PER_LONG != 64
+	/* We must enforce atomic readout on 32bit, otherwise the
+	 * update on another cpu can hit inbetween the readout of
+	 * the low 32bit and the high 32bit portion.
+	 */
+	return cmpxchg64(&c, 0, 0);
+#else
+	/* On 64 bit the cursor read is atomic versus the update */
+	return c;
+#endif
+}
+
+static inline __be64 smc_curs_read_net(__be64 c)
+{
+#if BITS_PER_LONG != 64
+	/* We must enforce atomic readout on 32bit, otherwise the
+	 * update on another cpu can hit inbetween the readout of
+	 * the low 32bit and the high 32bit portion.
+	 */
+	return cmpxchg64(&c, 0, 0);
+#else
+	/* On 64 bit the cursor read is atomic versus the update */
+	return c;
+#endif
+}
+
+/* calculate cursor difference between old and new, where old <= new */
+static inline int smc_curs_diff(unsigned int size,
+				union smc_host_cursor_ovl *old,
+				union smc_host_cursor_ovl *new)
+{
+	if (old->curs.wrap != new->curs.wrap)
+		return max_t(int, 0,
+			     ((size - old->curs.count) + new->curs.count));
+
+	return max_t(int, 0, (new->curs.count - old->curs.count));
+}
+
+static inline void smc_host_cursor_to_cdc(struct smc_cdc_cursor *peer,
+					  union smc_host_cursor_ovl *local)
+{
+	union smc_host_cursor_ovl temp;
+
+	temp.acurs = smc_curs_read(local->acurs);
+	peer->count = htonl(temp.curs.count);
+	peer->wrap = htons(temp.curs.wrap);
+	/* peer->reserved = htons(0); must be ensured by caller */
+}
+
+static inline void smc_host_msg_to_cdc(struct smc_cdc_msg *peer,
+				       struct smc_host_cdc_msg *local)
+{
+	peer->common.type = local->common.type;
+	peer->len = local->len;
+	peer->seqno = htons(local->seqno);
+	peer->token = htonl(local->token);
+	smc_host_cursor_to_cdc(&peer->prod.curs, &local->prod);
+	smc_host_cursor_to_cdc(&peer->cons.curs, &local->cons);
+	peer->prod_flags = local->prod_flags;
+	peer->conn_state_flags = local->conn_state_flags;
+}
+
+static inline void smc_cdc_cursor_to_host(union smc_host_cursor_ovl *local,
+					  union smc_cdc_cursor_ovl *peer)
+{
+	union smc_host_cursor_ovl temp, old;
+	union smc_cdc_cursor_ovl net;
+
+	old.acurs = smc_curs_read(local->acurs);
+	net.acurs = smc_curs_read_net(peer->acurs);
+	temp.curs.count = ntohl(net.curs.count);
+	temp.curs.wrap = ntohs(net.curs.wrap);
+	if ((old.curs.wrap > temp.curs.wrap) && temp.curs.wrap)
+		return;
+	if ((old.curs.wrap == temp.curs.wrap) &&
+	    (old.curs.count > temp.curs.count))
+		return;
+	xchg(&local->acurs, temp.acurs);
+}
+
+static inline void smc_cdc_msg_to_host(struct smc_host_cdc_msg *local,
+				       struct smc_cdc_msg *peer)
+{
+	local->common.type = peer->common.type;
+	local->len = peer->len;
+	local->seqno = ntohs(peer->seqno);
+	local->token = ntohl(peer->token);
+	smc_cdc_cursor_to_host(&local->prod, &peer->prod);
+	smc_cdc_cursor_to_host(&local->cons, &peer->cons);
+	local->prod_flags = peer->prod_flags;
+	local->conn_state_flags = peer->conn_state_flags;
+}
+
+struct smc_cdc_tx_pend;
+
+int smc_cdc_get_free_slot(struct smc_link *, struct smc_wr_buf **,
+			  struct smc_cdc_tx_pend **);
+void smc_cdc_tx_dismiss_slots(struct smc_connection *);
+int smc_cdc_msg_send(struct smc_connection *, struct smc_wr_buf *,
+		     struct smc_cdc_tx_pend *);
+int smc_cdc_get_slot_and_msg_send(struct smc_connection *);
+int smc_cdc_init(void) __init;
+
+#endif /* SMC_CDC_H */
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 55944b4..d751d3f 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -22,6 +22,7 @@
 #include "smc_ib.h"
 #include "smc_wr.h"
 #include "smc_llc.h"
+#include "smc_cdc.h"
 
 #define SMC_LGR_NUM_INCR	256
 #define SMC_LGR_FREE_DELAY	(600 * HZ)
@@ -229,6 +230,7 @@ void smc_conn_free(struct smc_connection *conn)
 
 	if (!lgr)
 		return;
+	smc_cdc_tx_dismiss_slots(conn);
 	smc_lgr_unregister_conn(conn);
 	smc_rmb_unuse(conn);
 	smc_sndbuf_unuse(conn);
@@ -460,6 +462,8 @@ int smc_conn_create(struct smc_sock *smc, __be32 peer_in_addr,
 		smc_lgr_register_conn(conn); /* add smc conn to lgr */
 		rc = smc_link_determine_gid(conn->lgr);
 	}
+	conn->local_tx_ctrl.common.type = SMC_CDC_MSG_TYPE;
+	conn->local_tx_ctrl.len = sizeof(struct smc_cdc_msg);
 
 out:
 	return rc ? rc : local_contact;
@@ -560,6 +564,7 @@ int smc_sndbuf_create(struct smc_sock *smc)
 		conn->sndbuf_desc = sndbuf_desc;
 		conn->sndbuf_size = tmp_bufsize;
 		smc->sk.sk_sndbuf = tmp_bufsize * 2;
+		atomic_set(&conn->sndbuf_space, tmp_bufsize);
 		return 0;
 	} else {
 		return -ENOMEM;
@@ -636,6 +641,7 @@ int smc_rmb_create(struct smc_sock *smc)
 		conn->rmbe_size = tmp_bufsize;
 		conn->rmbe_size_short = tmp_bufsize_short;
 		smc->sk.sk_rcvbuf = tmp_bufsize * 2;
+		atomic_set(&conn->bytes_to_rcv, 0);
 		return 0;
 	} else {
 		return -ENOMEM;
diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
index 09eaef0..391b2bb 100644
--- a/net/smc/smc_wr.c
+++ b/net/smc/smc_wr.c
@@ -233,6 +233,25 @@ int smc_wr_tx_send(struct smc_link *link, struct smc_wr_tx_pend_priv *priv)
 	return rc;
 }
 
+void smc_wr_tx_dismiss_slots(struct smc_link *link, u8 wr_rx_hdr_type,
+			     smc_wr_tx_filter filter,
+			     smc_wr_tx_dismisser dismisser,
+			     unsigned long data)
+{
+	struct smc_wr_tx_pend_priv *tx_pend;
+	struct smc_wr_rx_hdr *wr_rx;
+	int i;
+
+	for_each_set_bit(i, link->wr_tx_mask, link->wr_tx_cnt) {
+		wr_rx = (struct smc_wr_rx_hdr *)&link->wr_rx_bufs[i];
+		if (wr_rx->type != wr_rx_hdr_type)
+			continue;
+		tx_pend = &link->wr_tx_pends[i].priv;
+		if (filter(tx_pend, data))
+			dismisser(tx_pend);
+	}
+}
+
 /****************************** receive queue ********************************/
 
 int smc_wr_rx_register_handler(struct smc_wr_rx_handler *handler)
diff --git a/net/smc/smc_wr.h b/net/smc/smc_wr.h
index ba7f831..bb8bf87 100644
--- a/net/smc/smc_wr.h
+++ b/net/smc/smc_wr.h
@@ -34,6 +34,11 @@ typedef void (*smc_wr_tx_handler)(struct smc_wr_tx_pend_priv *,
 				  struct smc_link *,
 				  enum ib_wc_status);
 
+typedef bool (*smc_wr_tx_filter)(struct smc_wr_tx_pend_priv *,
+				 unsigned long);
+
+typedef void (*smc_wr_tx_dismisser)(struct smc_wr_tx_pend_priv *);
+
 struct smc_wr_rx_handler {
 	struct hlist_node	list;	/* hash table collision resolution */
 	void			(*handler)(struct ib_wc *, void *);
@@ -77,6 +82,9 @@ int smc_wr_tx_get_free_slot(struct smc_link *, smc_wr_tx_handler,
 int smc_wr_tx_put_slot(struct smc_link *, struct smc_wr_tx_pend_priv *);
 int smc_wr_tx_send(struct smc_link *, struct smc_wr_tx_pend_priv *);
 void smc_wr_tx_cq_handler(struct ib_cq *, void *);
+void smc_wr_tx_dismiss_slots(struct smc_link *, u8,
+			     smc_wr_tx_filter, smc_wr_tx_dismisser,
+			     unsigned long);
 
 int smc_wr_rx_register_handler(struct smc_wr_rx_handler *);
 int smc_wr_rx_post_init(struct smc_link *);
-- 
2.6.6
