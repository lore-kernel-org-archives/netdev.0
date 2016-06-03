From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 14/15] smc: socket closing and linkgroup cleanup
Date: Fri,  3 Jun 2016 17:27:13 +0200
Message-ID: <201606031527.u53FPxfl037202@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33605 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932164AbcFCP1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:49 -0400
Received: from pps.filterd (m0048817.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FPxfl037202
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:49 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bc7r8x8h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:48 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:46 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smc_shutdown() and smc_release() handling
delayed linkgroup cleanup for linkgroups without connections

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile    |   2 +-
 net/smc/af_smc.c    | 102 ++++++++++--
 net/smc/smc.h       |  20 ++-
 net/smc/smc_cdc.c   |  33 ++--
 net/smc/smc_cdc.h   |   1 +
 net/smc/smc_close.c | 434 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_close.h |  27 ++++
 net/smc/smc_core.c  |   6 +
 net/smc/smc_tx.c    |   8 +
 net/smc/smc_wr.c    |  47 ++++--
 net/smc/smc_wr.h    |   2 +
 11 files changed, 643 insertions(+), 39 deletions(-)
 create mode 100644 net/smc/smc_close.c
 create mode 100644 net/smc/smc_close.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index 6255e29..5cf0caf 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SMC)	+= smc.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
-smc-y += smc_cdc.o smc_tx.o smc_rx.o
+smc-y += smc_cdc.o smc_tx.o smc_rx.o smc_close.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 4652759..0a7d78d 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -38,6 +38,7 @@
 #include "smc_pnet.h"
 #include "smc_tx.h"
 #include "smc_rx.h"
+#include "smc_close.h"
 
 static DEFINE_MUTEX(smc_create_lgr_pending);	/* serialize link group
 						 * creation
@@ -69,14 +70,29 @@ static int smc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct smc_sock *smc;
+	int rc = 0;
 
 	if (!sk)
 		goto out;
 
 	smc = smc_sk(sk);
-	lock_sock(sk);
+	sock_hold(sk);
+	if (sk->sk_state == SMC_LISTEN)
+		/* smc_close_non_accepted() is called and acquires
+		 * sock lock for child sockets again
+		 */
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
+	else
+		lock_sock(sk);
 
-	sk->sk_state = SMC_CLOSED;
+	if (smc->use_fallback) {
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_state_change(sk);
+	} else {
+		sock_set_flag(sk, SOCK_DEAD);
+		rc = smc_close_active(smc);
+		sk->sk_shutdown |= SHUTDOWN_MASK;
+	}
 	if (smc->clcsock) {
 		sock_release(smc->clcsock);
 		smc->clcsock = NULL;
@@ -86,11 +102,18 @@ static int smc_release(struct socket *sock)
 	sock_set_flag(sk, SOCK_ZAPPED);
 	sock_orphan(sk);
 	sock->sk = NULL;
+	if (smc->use_fallback) {
+		schedule_delayed_work(&smc->sock_put_work, TCP_TIMEWAIT_LEN);
+	} else if (sk->sk_state == SMC_CLOSED) {
+		smc_conn_free(&smc->conn);
+		schedule_delayed_work(&smc->sock_put_work,
+				      SMC_CLOSE_SOCK_PUT_DELAY);
+	}
 	release_sock(sk);
 
 	sock_put(sk);
 out:
-	return 0;
+	return rc;
 }
 
 static void smc_destruct(struct sock *sk)
@@ -127,6 +150,7 @@ static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
 	INIT_WORK(&smc->tcp_listen_work, smc_tcp_listen_work);
 	INIT_LIST_HEAD(&smc->accept_q);
 	spin_lock_init(&smc->accept_q_lock);
+	INIT_DELAYED_WORK(&smc->sock_put_work, smc_close_sock_put_work);
 
 	return sk;
 }
@@ -569,8 +593,8 @@ static void smc_accept_unlink(struct sock *sk)
 /* remove a sock from the accept queue to bind it to a new socket created
  * for a socket accept call from user space
  */
-static struct sock *smc_accept_dequeue(struct sock *parent,
-				       struct socket *new_sock)
+struct sock *smc_accept_dequeue(struct sock *parent,
+				struct socket *new_sock)
 {
 	struct smc_sock *isk, *n;
 	struct sock *new_sk;
@@ -591,11 +615,16 @@ static struct sock *smc_accept_dequeue(struct sock *parent,
 }
 
 /* clean up for a created but never accepted sock */
-static void smc_close_non_accepted(struct sock *sk)
+void smc_close_non_accepted(struct sock *sk)
 {
 	struct smc_sock *smc = smc_sk(sk);
 
 	sock_hold(sk);
+	lock_sock(sk);
+	if (!sk->sk_lingertime)
+		/* wait long for peer closing */
+		sk->sk_lingertime = MAX_SCHEDULE_TIMEOUT;
+	smc_close_active(smc);
 	if (smc->clcsock) {
 		struct socket *tcp;
 
@@ -603,7 +632,9 @@ static void smc_close_non_accepted(struct sock *sk)
 		smc->clcsock = NULL;
 		sock_release(tcp);
 	}
-	/* more closing stuff to be added with socket closing patch */
+	sock_set_flag(sk, SOCK_ZAPPED);
+	sock_set_flag(sk, SOCK_DEAD);
+	release_sock(sk);
 	sock_put(sk);
 }
 
@@ -801,6 +832,9 @@ decline_rdma:
 
 out_err:
 	newsmcsk->sk_state = SMC_CLOSED;
+	smc_conn_free(&new_smc->conn);
+	schedule_delayed_work(&new_smc->sock_put_work,
+			      SMC_CLOSE_SOCK_PUT_DELAY);
 	goto enqueue; /* queue new sock with sk_err set */
 }
 
@@ -937,7 +971,9 @@ static int smc_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	smc = smc_sk(sk);
 	lock_sock(sk);
-	if (sk->sk_state != SMC_ACTIVE)
+	if ((sk->sk_state != SMC_ACTIVE) &&
+	    (sk->sk_state != SMC_APPCLOSEWAIT1) &&
+	    (sk->sk_state != SMC_INIT))
 		goto out;
 	if (smc->use_fallback)
 		rc = smc->clcsock->ops->sendmsg(smc->clcsock, msg, len);
@@ -957,13 +993,20 @@ static int smc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	smc = smc_sk(sk);
 	lock_sock(sk);
-	if ((sk->sk_state != SMC_ACTIVE) && (sk->sk_state != SMC_CLOSED))
+	if ((sk->sk_state == SMC_INIT) ||
+	    (sk->sk_state == SMC_LISTEN) ||
+	    (sk->sk_state == SMC_APPFINCLOSEWAIT) ||
+	    (sk->sk_state == SMC_PEERFINCLOSEWAIT))
 		goto out;
 
-	if (smc->use_fallback)
+	if (smc->use_fallback) {
 		rc = smc->clcsock->ops->recvmsg(smc->clcsock, msg, len, flags);
-	else
+	} else {
+		if (sk->sk_state == SMC_CLOSED)
+			goto out;
 		rc = smc_rx_recvmsg(smc, msg, len, flags);
+	}
+
 out:
 	release_sock(sk);
 	return rc;
@@ -1023,7 +1066,8 @@ static unsigned int smc_poll(struct file *file, struct socket *sock,
 			mask |= smc_accept_poll(sk);
 		if (sk->sk_err)
 			mask |= POLLERR;
-		if (atomic_read(&smc->conn.sndbuf_space)) {
+		if (atomic_read(&smc->conn.sndbuf_space) ||
+		    (sk->sk_shutdown & SEND_SHUTDOWN)) {
 			mask |= POLLOUT | POLLWRNORM;
 		} else {
 			sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
@@ -1031,7 +1075,14 @@ static unsigned int smc_poll(struct file *file, struct socket *sock,
 		}
 		if (atomic_read(&smc->conn.bytes_to_rcv))
 			mask |= POLLIN | POLLRDNORM;
-		/* for now - to be enhanced in follow-on patch */
+		if ((sk->sk_shutdown == SHUTDOWN_MASK) ||
+		    (sk->sk_state == SMC_CLOSED))
+			mask |= POLLHUP;
+		if (sk->sk_shutdown & RCV_SHUTDOWN)
+			mask |= POLLIN | POLLRDNORM | POLLRDHUP;
+		if (sk->sk_state == SMC_APPCLOSEWAIT1)
+			mask |= POLLIN;
+
 	}
 
 	return mask;
@@ -1051,7 +1102,12 @@ static int smc_shutdown(struct socket *sock, int how)
 	lock_sock(sk);
 
 	rc = -ENOTCONN;
-	if (sk->sk_state == SMC_CLOSED)
+	if ((sk->sk_state != SMC_ACTIVE) &&
+	    (sk->sk_state != SMC_PEERCLOSEWAIT1) &&
+	    (sk->sk_state != SMC_PEERCLOSEWAIT2) &&
+	    (sk->sk_state != SMC_APPCLOSEWAIT1) &&
+	    (sk->sk_state != SMC_APPCLOSEWAIT2) &&
+	    (sk->sk_state != SMC_APPFINCLOSEWAIT))
 		goto out;
 	if (smc->use_fallback) {
 		rc = kernel_sock_shutdown(smc->clcsock, how);
@@ -1059,7 +1115,23 @@ static int smc_shutdown(struct socket *sock, int how)
 		if (sk->sk_shutdown == SHUTDOWN_MASK)
 			sk->sk_state = SMC_CLOSED;
 	} else {
-		rc = sock_no_shutdown(sock, how);
+		switch (how) {
+		case SHUT_RDWR:		/* shutdown in both directions */
+			rc = smc_close_active(smc);
+			break;
+		case SHUT_WR:
+			rc = smc_close_shutdown_write(smc);
+			break;
+		case SHUT_RD:
+			if (sk->sk_state == SMC_APPFINCLOSEWAIT)
+				sk->sk_state = SMC_CLOSED;
+			rc = 0;
+			/* nothing more to do because peer is not involved */
+			break;
+		}
+		rc = kernel_sock_shutdown(smc->clcsock, how);
+		/* map sock_shutdown_cmd constants to sk_shutdown value range */
+		sk->sk_shutdown |= how + 1;
 	}
 
 out:
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 8aa9be8..559cd08 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -23,6 +23,16 @@ enum smc_state {		/* possible states of an SMC socket */
 	SMC_INIT	= 2,
 	SMC_CLOSED	= 7,
 	SMC_LISTEN	= 10,
+	/* normal close */
+	SMC_PEERCLOSEWAIT1	= 20,
+	SMC_PEERCLOSEWAIT2	= 21,
+	SMC_APPFINCLOSEWAIT	= 24,
+	SMC_APPCLOSEWAIT1	= 22,
+	SMC_APPCLOSEWAIT2	= 23,
+	SMC_PEERFINCLOSEWAIT	= 25,
+	/* abnormal close */
+	SMC_PEERABORTWAIT	= 26,
+	SMC_PROCESSABORT	= 27,
 };
 
 struct smc_link_group;
@@ -153,8 +163,14 @@ struct smc_sock {				/* smc sock container */
 	struct work_struct	smc_listen_work;/* prepare new accept socket */
 	struct list_head	accept_q;	/* sockets to be accepted */
 	spinlock_t		accept_q_lock;	/* protects accept_q */
+	struct delayed_work	sock_put_work;	/* final socket freeing */
 	u8			use_fallback : 1, /* fallback to tcp */
-				clc_started : 1;/* smc_connect_rdma ran */
+				clc_started : 1,/* smc_connect_rdma ran */
+				wait_close_tx_prepared : 1;
+						/* shutdown wr or close
+						 * started, waiting for unsent
+						 * data to be sent
+						 */
 };
 
 static inline struct smc_sock *smc_sk(const struct sock *sk)
@@ -238,5 +254,7 @@ int smc_netinfo_by_tcpsk(struct socket *, __be32 *, u8 *);
 void smc_conn_free(struct smc_connection *);
 int smc_conn_create(struct smc_sock *, __be32, struct smc_ib_device *, u8,
 		    struct smc_clc_msg_local *, int);
+struct sock *smc_accept_dequeue(struct sock *, struct socket *);
+void smc_close_non_accepted(struct sock *);
 
 #endif	/* _SMC_H */
diff --git a/net/smc/smc_cdc.c b/net/smc/smc_cdc.c
index d8a8dce..38b80e5 100644
--- a/net/smc/smc_cdc.c
+++ b/net/smc/smc_cdc.c
@@ -16,6 +16,7 @@
 #include "smc_cdc.h"
 #include "smc_tx.h"
 #include "smc_rx.h"
+#include "smc_close.h"
 
 /********************************** send *************************************/
 
@@ -54,6 +55,9 @@ static void smc_cdc_tx_handler(struct smc_wr_tx_pend_priv *pnd_snd,
 		     cdcpend->cursor.acurs);
 	}
 	smc_tx_sndbuf_nonfull(smc);
+	if (smc->sk.sk_state != SMC_ACTIVE)
+		/* wake up smc_close_wait_tx_pends() */
+		smc->sk.sk_state_change(&smc->sk);
 	bh_unlock_sock(&smc->sk);
 }
 
@@ -146,6 +150,14 @@ void smc_cdc_tx_dismiss_slots(struct smc_connection *conn)
 				(unsigned long)conn);
 }
 
+bool smc_cdc_tx_has_pending(struct smc_connection *conn)
+{
+	struct smc_link *link = &conn->lgr->lnk[SMC_SINGLE_LINK];
+
+	return smc_wr_tx_has_pending(link, SMC_CDC_MSG_TYPE,
+				     smc_cdc_tx_filter, (unsigned long)conn);
+}
+
 /********************************* receive ***********************************/
 
 static inline bool smc_cdc_before(u16 seq1, u16 seq2)
@@ -194,21 +206,20 @@ static void smc_cdc_msg_recv_action(struct smc_sock *smc,
 		smc->sk.sk_data_ready(&smc->sk);
 	}
 
-	if (conn->local_rx_ctrl.conn_state_flags.peer_conn_abort)
+	if (conn->local_rx_ctrl.conn_state_flags.peer_conn_abort) {
 		smc->sk.sk_err = ECONNRESET;
-	if (smc_cdc_rxed_any_close_or_senddone(conn)) {
-		smc->sk.sk_shutdown |= RCV_SHUTDOWN;
-		sock_set_flag(&smc->sk, SOCK_DONE);
-
-		/* subsequent patch: terminate connection */
+		conn->local_tx_ctrl.conn_state_flags.peer_conn_abort = 1;
 	}
+	if (smc_cdc_rxed_any_close_or_senddone(conn))
+		smc_close_passive_received(smc);
 
 	/* piggy backed tx info */
 	/* trigger sndbuf consumer: RDMA write into peer RMBE and CDC */
-	if (diff_cons && smc_tx_prepared_sends(conn))
+	if (diff_cons && smc_tx_prepared_sends(conn)) {
 		smc_tx_sndbuf_nonempty(conn);
-
-	/* subsequent patch: trigger socket release if connection closed */
+		/* trigger socket release if connection closed */
+		smc_close_wake_tx_prepared(smc);
+	}
 
 	/* socket connected but not accepted */
 	if (!smc->sk.sk_socket)
@@ -237,10 +248,6 @@ static inline void smc_cdc_msg_recv(struct smc_cdc_msg *cdc,
 		return;
 	}
 	smc = container_of(connection, struct smc_sock, conn);
-	if (smc->sk.sk_state == SMC_CLOSED) {
-		read_unlock_bh(&lgr->conns_lock);
-		return;
-	}
 	sock_hold(&smc->sk);
 	read_unlock_bh(&lgr->conns_lock);
 	bh_lock_sock(&smc->sk);
diff --git a/net/smc/smc_cdc.h b/net/smc/smc_cdc.h
index 0190c9e..a150271 100644
--- a/net/smc/smc_cdc.h
+++ b/net/smc/smc_cdc.h
@@ -170,6 +170,7 @@ void smc_cdc_tx_dismiss_slots(struct smc_connection *);
 int smc_cdc_msg_send(struct smc_connection *, struct smc_wr_buf *,
 		     struct smc_cdc_tx_pend *);
 int smc_cdc_get_slot_and_msg_send(struct smc_connection *);
+bool smc_cdc_tx_has_pending(struct smc_connection *);
 int smc_cdc_init(void) __init;
 
 #endif /* SMC_CDC_H */
diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
new file mode 100644
index 0000000..c8845e7
--- /dev/null
+++ b/net/smc/smc_close.c
@@ -0,0 +1,434 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Socket Closing - normal and abnormal
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <linux/workqueue.h>
+#include <net/sock.h>
+
+#include "smc.h"
+#include "smc_tx.h"
+#include "smc_cdc.h"
+#include "smc_close.h"
+
+#define SMC_CLOSE_WAIT_TX_PENDS_TIME		(5 * HZ)
+
+static void smc_close_cleanup_listen(struct sock *parent)
+{
+	struct sock *sk;
+
+	/* Close non-accepted connections */
+	while ((sk = smc_accept_dequeue(parent, NULL)))
+		smc_close_non_accepted(sk);
+}
+
+static void smc_close_wait_tx_pends(struct smc_sock *smc)
+{
+	struct sock *sk = &smc->sk;
+	signed long timeout;
+	DEFINE_WAIT(wait);
+
+	timeout = SMC_CLOSE_WAIT_TX_PENDS_TIME;
+	do {
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (sk_wait_event(sk, &timeout,
+				  !smc_cdc_tx_has_pending(&smc->conn)))
+			break;
+	} while (!signal_pending(current) && timeout);
+	finish_wait(sk_sleep(sk), &wait);
+}
+
+/* wait for sndbuf data being transmitted */
+static void smc_close_stream_wait(struct smc_sock *smc, long timeout)
+{
+	struct sock *sk = &smc->sk;
+	DEFINE_WAIT(wait);
+
+	if (!timeout)
+		return;
+
+	smc->wait_close_tx_prepared = 1;
+	do {
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		if (sk_wait_event(sk, &timeout,
+				  !smc_tx_prepared_sends(&smc->conn) ||
+				  (sk->sk_err == ECONNABORTED) ||
+				  (sk->sk_err == ECONNRESET)))
+			break;
+	} while (!signal_pending(current) && timeout);
+
+	finish_wait(sk_sleep(sk), &wait);
+	smc->wait_close_tx_prepared = 0;
+}
+
+void smc_close_wake_tx_prepared(struct smc_sock *smc)
+{
+	if (smc->wait_close_tx_prepared)
+		/* wake up socket closing */
+		smc->sk.sk_state_change(&smc->sk);
+}
+
+static int smc_close_wr(struct smc_connection *conn)
+{
+	conn->local_tx_ctrl.conn_state_flags.peer_done_writing = 1;
+
+	return smc_cdc_get_slot_and_msg_send(conn);
+}
+
+static int smc_close_final(struct smc_connection *conn)
+{
+	if (atomic_read(&conn->bytes_to_rcv))
+		conn->local_tx_ctrl.conn_state_flags.peer_conn_abort = 1;
+	else
+		conn->local_tx_ctrl.conn_state_flags.peer_conn_closed = 1;
+
+	return smc_cdc_get_slot_and_msg_send(conn);
+}
+
+static int smc_close_abort(struct smc_connection *conn)
+{
+	conn->local_tx_ctrl.conn_state_flags.peer_conn_abort = 1;
+
+	return smc_cdc_get_slot_and_msg_send(conn);
+}
+
+/* terminate smc socket abnormally - active abort */
+void smc_close_active_abort(struct smc_sock *smc)
+{
+	bh_lock_sock(&smc->sk);
+	smc->sk.sk_err = ECONNABORTED;
+	if (smc->clcsock && smc->clcsock->sk) {
+		smc->clcsock->sk->sk_err = ECONNABORTED;
+		smc->clcsock->sk->sk_state_change(smc->clcsock->sk);
+	}
+	switch (smc->sk.sk_state) {
+	case SMC_INIT:
+		smc->sk.sk_state = SMC_PEERABORTWAIT;
+		break;
+	case SMC_APPCLOSEWAIT1:
+	case SMC_APPCLOSEWAIT2:
+		smc_close_abort(&smc->conn);
+		if (!smc_cdc_rxed_any_close(&smc->conn))
+			smc->sk.sk_state = SMC_PEERABORTWAIT;
+		else
+			smc->sk.sk_state = SMC_CLOSED;
+		break;
+	case SMC_PEERCLOSEWAIT1:
+	case SMC_PEERCLOSEWAIT2:
+		if (!smc->conn.local_tx_ctrl.conn_state_flags.
+							peer_conn_closed) {
+			smc_close_abort(&smc->conn);
+			smc->sk.sk_state = SMC_PEERABORTWAIT;
+		} else {
+			smc->sk.sk_state = SMC_CLOSED;
+		}
+		break;
+	case SMC_PROCESSABORT:
+	case SMC_APPFINCLOSEWAIT:
+		if (!smc->conn.local_tx_ctrl.conn_state_flags.
+							peer_conn_closed)
+			smc_close_abort(&smc->conn);
+		smc->sk.sk_state = SMC_CLOSED;
+		break;
+	case SMC_PEERFINCLOSEWAIT:
+	case SMC_PEERABORTWAIT:
+	case SMC_CLOSED:
+		break;
+	}
+
+	sock_set_flag(&smc->sk, SOCK_DEAD);
+	bh_unlock_sock(&smc->sk);
+	smc->sk.sk_state_change(&smc->sk);
+}
+
+int smc_close_active(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	long timeout = MAX_SCHEDULE_TIMEOUT;
+	struct sock *sk = &smc->sk;
+	int old_state;
+	int rc = 0;
+
+	if (sock_flag(sk, SOCK_LINGER) &&
+	    !(current->flags & PF_EXITING))
+		timeout = sk->sk_lingertime;
+
+again:
+	old_state = sk->sk_state;
+	switch (old_state) {
+	case SMC_INIT:
+		sk->sk_state = SMC_CLOSED;
+		if (smc->smc_listen_work.func)
+			flush_work(&smc->smc_listen_work);
+		sock_put(sk);
+		break;
+	case SMC_LISTEN:
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_state_change(sk); /* wake up accept */
+		if (smc->clcsock && smc->clcsock->sk) {
+			rc = kernel_sock_shutdown(smc->clcsock, SHUT_RDWR);
+			/* wake up kernel_accept of smc_tcp_listen_worker */
+			smc->clcsock->sk->sk_data_ready(smc->clcsock->sk);
+		}
+		release_sock(sk);
+		smc_close_cleanup_listen(sk);
+		flush_work(&smc->tcp_listen_work);
+		lock_sock(sk);
+		schedule_delayed_work(&smc->sock_put_work,
+				      SMC_CLOSE_SOCK_PUT_DELAY);
+		break;
+	case SMC_ACTIVE:
+		smc_close_stream_wait(smc, timeout);
+		release_sock(sk);
+		cancel_work_sync(&conn->tx_work);
+		lock_sock(sk);
+		if (sk->sk_state == SMC_ACTIVE) {
+			/* send close request */
+			rc = smc_close_final(conn);
+			sk->sk_state = SMC_PEERCLOSEWAIT1;
+		} else {
+			/* peer event has changed the state */
+			goto again;
+		}
+		break;
+	case SMC_APPFINCLOSEWAIT:
+		/* socket already shutdown wr or both (active close) */
+		if (conn->local_tx_ctrl.conn_state_flags.peer_done_writing &&
+		    !conn->local_tx_ctrl.conn_state_flags.peer_conn_closed) {
+			/* just shutdown wr done, send close request */
+			rc = smc_close_final(conn);
+		}
+		sk->sk_state = SMC_CLOSED;
+		smc_close_wait_tx_pends(smc);
+		break;
+	case SMC_APPCLOSEWAIT1:
+	case SMC_APPCLOSEWAIT2:
+		if (!smc_cdc_rxed_any_close(conn))
+			smc_close_stream_wait(smc, timeout);
+		release_sock(sk);
+		cancel_work_sync(&conn->tx_work);
+		lock_sock(sk);
+		if (sk->sk_err != ECONNABORTED) {
+			/* confirm close from peer */
+			rc = smc_close_final(conn);
+			if (rc)
+				break;
+		}
+		if (smc_cdc_rxed_any_close(conn)) {
+			/* peer has closed the socket already */
+			sk->sk_state = SMC_CLOSED;
+			smc_close_wait_tx_pends(smc);
+		} else {
+			/* peer has just issued a shutdown write */
+			sk->sk_state = SMC_PEERFINCLOSEWAIT;
+		}
+		break;
+	case SMC_PEERCLOSEWAIT1:
+	case SMC_PEERCLOSEWAIT2:
+		/* peer sending PeerConnectionClosed will cause transition */
+		break;
+	case SMC_PEERFINCLOSEWAIT:
+		sk->sk_state = SMC_CLOSED;
+		smc_close_wait_tx_pends(smc);
+		break;
+	case SMC_PROCESSABORT:
+		cancel_work_sync(&conn->tx_work);
+		smc_close_abort(conn);
+		sk->sk_state = SMC_CLOSED;
+		smc_close_wait_tx_pends(smc);
+		break;
+	case SMC_PEERABORTWAIT:
+	case SMC_CLOSED:
+		/* nothing to do, add tracing in future patch */
+		break;
+	}
+
+	if (old_state != sk->sk_state)
+		sk->sk_state_change(&smc->sk);
+	return rc;
+}
+
+static void smc_close_passive_abort_received(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct sock *sk = &smc->sk;
+
+	switch (sk->sk_state) {
+	case SMC_ACTIVE:
+	case SMC_APPFINCLOSEWAIT:
+	case SMC_APPCLOSEWAIT1:
+	case SMC_APPCLOSEWAIT2:
+		smc_close_abort(conn);
+		sk->sk_state = SMC_PROCESSABORT;
+		break;
+	case SMC_PEERCLOSEWAIT1:
+	case SMC_PEERCLOSEWAIT2:
+		if (conn->local_tx_ctrl.conn_state_flags.peer_done_writing &&
+		    !conn->local_tx_ctrl.conn_state_flags.peer_conn_closed) {
+			/* just shutdown, but not yet closed locally */
+			smc_close_abort(conn);
+			sk->sk_state = SMC_PROCESSABORT;
+		} else {
+			sk->sk_state = SMC_CLOSED;
+		}
+		break;
+	case SMC_PEERFINCLOSEWAIT:
+	case SMC_PEERABORTWAIT:
+		sk->sk_state = SMC_CLOSED;
+		break;
+	case SMC_INIT:
+	case SMC_PROCESSABORT:
+	/* nothing to do, add tracing in future patch */
+		break;
+	}
+}
+
+/* Some kind of closing has been received: peer_conn_closed, peer_conn_abort,
+ * or peer_done_writing.
+ * Called under tasklet context.
+ */
+void smc_close_passive_received(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct sock *sk = &smc->sk;
+	int old_state;
+
+	sk->sk_shutdown |= RCV_SHUTDOWN;
+	if (smc->clcsock && smc->clcsock->sk)
+		smc->clcsock->sk->sk_shutdown |= RCV_SHUTDOWN;
+	sock_set_flag(&smc->sk, SOCK_DONE);
+
+	old_state = sk->sk_state;
+
+	if (conn->local_rx_ctrl.conn_state_flags.peer_conn_abort) {
+		smc_close_passive_abort_received(smc);
+		goto set_flag;
+	}
+
+	switch (sk->sk_state) {
+	case SMC_INIT:
+		sk->sk_state = SMC_CLOSED;
+		schedule_delayed_work(&smc->sock_put_work,
+				      SMC_CLOSE_SOCK_PUT_DELAY);
+		break;
+	case SMC_ACTIVE:
+		sk->sk_state = SMC_APPCLOSEWAIT1;
+		break;
+	case SMC_PEERFINCLOSEWAIT:
+		if (smc_cdc_rxed_any_close(conn)) {
+			if (sock_flag(sk, SOCK_DEAD)) {
+				sk->sk_state = SMC_CLOSED;
+			} else {
+				/* just shutdown, but not yet closed locally */
+				sk->sk_state = SMC_APPFINCLOSEWAIT;
+			}
+		}
+		break;
+	case SMC_PEERCLOSEWAIT1:
+		if (conn->local_rx_ctrl.conn_state_flags.peer_done_writing)
+			sk->sk_state = SMC_PEERCLOSEWAIT2;
+		/* fall through to check for closing */
+	case SMC_PEERCLOSEWAIT2:
+		if (!smc_cdc_rxed_any_close(conn))
+			break;
+		if (sock_flag(sk, SOCK_DEAD)) {
+			/* smc_release has already been called locally */
+			sk->sk_state = SMC_CLOSED;
+		} else {
+			/* just shutdown, but not yet closed locally */
+			sk->sk_state = SMC_APPFINCLOSEWAIT;
+		}
+		break;
+	case SMC_APPCLOSEWAIT1:
+	case SMC_APPCLOSEWAIT2:
+	case SMC_APPFINCLOSEWAIT:
+	case SMC_PEERABORTWAIT:
+	case SMC_PROCESSABORT:
+	case SMC_CLOSED:
+		/* nothing to do, add tracing in future patch */
+		break;
+	}
+
+set_flag:
+	sock_set_flag(sk, SOCK_DONE);
+
+	if (old_state != sk->sk_state)
+		sk->sk_state_change(sk);
+
+	if ((sk->sk_state == SMC_CLOSED) && sock_flag(sk, SOCK_DEAD)) {
+		bh_unlock_sock(sk);
+		smc_conn_free(conn);
+		bh_lock_sock(sk);
+		schedule_delayed_work(&smc->sock_put_work,
+				      SMC_CLOSE_SOCK_PUT_DELAY);
+	}
+
+	sk->sk_data_ready(sk); /* wakeup blocked rcvbuf consumers */
+	sk->sk_write_space(sk); /* wakeup blocked sndbuf producers */
+}
+
+void smc_close_sock_put_work(struct work_struct *work)
+{
+	struct smc_sock *smc = container_of(to_delayed_work(work),
+					    struct smc_sock,
+					    sock_put_work);
+
+	sock_put(&smc->sk);
+}
+
+int smc_close_shutdown_write(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	long timeout = MAX_SCHEDULE_TIMEOUT;
+	struct sock *sk = &smc->sk;
+	int old_state;
+	int rc = 0;
+
+	if (sock_flag(sk, SOCK_LINGER))
+		timeout = sk->sk_lingertime;
+
+	old_state = sk->sk_state;
+	switch (old_state) {
+	case SMC_ACTIVE:
+		smc_close_stream_wait(smc, timeout);
+		release_sock(sk);
+		cancel_work_sync(&conn->tx_work);
+		lock_sock(sk);
+		if ((sk->sk_state == SMC_ACTIVE) ||
+		    (sk->sk_state == SMC_APPCLOSEWAIT1)) {
+			/* send close wr request */
+			rc = smc_close_wr(conn);
+			sk->sk_state = SMC_PEERCLOSEWAIT1;
+		};
+		break;
+	case SMC_APPCLOSEWAIT1:
+		/* passive close */
+		if (!smc_cdc_rxed_any_close(conn))
+			smc_close_stream_wait(smc, timeout);
+		release_sock(sk);
+		cancel_work_sync(&conn->tx_work);
+		lock_sock(sk);
+		/* confirm close from peer */
+		rc = smc_close_wr(conn);
+		sk->sk_state = SMC_APPCLOSEWAIT2;
+		break;
+	case SMC_APPCLOSEWAIT2:
+	case SMC_PEERFINCLOSEWAIT:
+	case SMC_PEERCLOSEWAIT1:
+	case SMC_PEERCLOSEWAIT2:
+	case SMC_APPFINCLOSEWAIT:
+	case SMC_PROCESSABORT:
+	case SMC_PEERABORTWAIT:
+		/* nothing to do, add tracing in future patch */
+		break;
+	}
+
+	if (old_state != sk->sk_state)
+		sk->sk_state_change(&smc->sk);
+	return rc;
+}
diff --git a/net/smc/smc_close.h b/net/smc/smc_close.h
new file mode 100644
index 0000000..e329b97
--- /dev/null
+++ b/net/smc/smc_close.h
@@ -0,0 +1,27 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Socket Closing
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#ifndef SMC_CLOSE_H
+#define SMC_CLOSE_H
+
+#include <linux/workqueue.h>
+
+#include "smc.h"
+
+#define SMC_CLOSE_SOCK_PUT_DELAY		HZ
+
+void smc_close_wake_tx_prepared(struct smc_sock *);
+void smc_close_active_abort(struct smc_sock *);
+int smc_close_active(struct smc_sock *);
+void smc_close_passive_received(struct smc_sock *);
+void smc_close_sock_put_work(struct work_struct *);
+int smc_close_shutdown_write(struct smc_sock *);
+
+#endif /* SMC_CLOSE_H */
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index cbc9c0e..5011e04 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -23,6 +23,7 @@
 #include "smc_wr.h"
 #include "smc_llc.h"
 #include "smc_cdc.h"
+#include "smc_close.h"
 
 #define SMC_LGR_NUM_INCR	256
 #define SMC_LGR_FREE_DELAY	(600 * HZ)
@@ -296,6 +297,7 @@ void smc_lgr_free(struct smc_link_group *lgr)
 void smc_lgr_terminate(struct smc_link_group *lgr)
 {
 	struct smc_connection *conn;
+	struct smc_sock *smc;
 	struct rb_node *node;
 
 	spin_lock_bh(&smc_lgr_list.lock);
@@ -312,7 +314,11 @@ void smc_lgr_terminate(struct smc_link_group *lgr)
 	node = rb_first(&lgr->conns_all);
 	while (node) {
 		conn = rb_entry(node, struct smc_connection, alert_node);
+		smc = container_of(conn, struct smc_sock, conn);
+		sock_hold(&smc->sk);
 		__smc_lgr_unregister_conn(conn);
+		smc_close_active_abort(smc);
+		sock_put(&smc->sk);
 		node = rb_first(&lgr->conns_all);
 	}
 	write_unlock_bh(&lgr->conns_lock);
diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
index 4cd54e1..b2f2b73 100644
--- a/net/smc/smc_tx.c
+++ b/net/smc/smc_tx.c
@@ -138,6 +138,7 @@ int smc_tx_sendmsg(struct smc_sock *smc, struct msghdr *msg, size_t len)
 		if (sk->sk_state == SMC_INIT)
 			return -ENOTCONN;
 		if (smc->sk.sk_shutdown & SEND_SHUTDOWN ||
+		    (smc->sk.sk_err == ECONNABORTED) ||
 		    conn->local_tx_ctrl.conn_state_flags.peer_conn_abort)
 			return -EPIPE;
 		if (smc_cdc_rxed_any_close(conn))
@@ -375,6 +376,13 @@ int smc_tx_sndbuf_nonempty(struct smc_connection *conn)
 				   &pend);
 	if (rc < 0) {
 		if (rc == -EBUSY) {
+			struct smc_sock *smc =
+				container_of(conn, struct smc_sock, conn);
+
+			if (smc->sk.sk_err == ECONNABORTED) {
+				rc = sock_error(&smc->sk);
+				goto out_unlock;
+			}
 			rc = 0;
 			schedule_work(&conn->tx_work);
 		}
diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
index 391b2bb..a7808c4 100644
--- a/net/smc/smc_wr.c
+++ b/net/smc/smc_wr.c
@@ -77,6 +77,8 @@ static inline void smc_wr_tx_process_cqe(struct ib_wc *wc)
 	if (!test_and_clear_bit(pnd_snd_idx, link->wr_tx_mask))
 		return;
 	if (wc->status) {
+		struct smc_link_group *lgr;
+
 		for_each_set_bit(i, link->wr_tx_mask, link->wr_tx_cnt) {
 			/* clear full struct smc_wr_tx_pend including .priv */
 			memset(&link->wr_tx_pends[i], 0,
@@ -85,9 +87,10 @@ static inline void smc_wr_tx_process_cqe(struct ib_wc *wc)
 			       sizeof(link->wr_tx_bufs[i]));
 			clear_bit(i, link->wr_tx_mask);
 		}
-		/* tbd in future patch: terminate connections of this link
-		 * group abnormally
-		 */
+		/* terminate connections of this link group abnormally */
+		lgr = container_of(link, struct smc_link_group,
+				   lnk[SMC_SINGLE_LINK]);
+		smc_lgr_terminate(lgr);
 	}
 	if (pnd_snd.handler)
 		pnd_snd.handler(&pnd_snd.priv, link, wc->status);
@@ -172,9 +175,12 @@ int smc_wr_tx_get_free_slot(struct smc_link *link,
 			(smc_wr_tx_get_free_slot_index(link, &idx) != -EBUSY),
 			SMC_WR_TX_WAIT_FREE_SLOT_TIME);
 		if (!rc) {
-			/* tbd in future patch: timeout - terminate connections
-			 * of this link group abnormally
-			 */
+			/* timeout - terminate connections */
+			struct smc_link_group *lgr;
+
+			lgr = container_of(link, struct smc_link_group,
+					   lnk[SMC_SINGLE_LINK]);
+			smc_lgr_terminate(lgr);
 			return -EPIPE;
 		}
 		if (rc == -ERESTARTSYS)
@@ -252,6 +258,24 @@ void smc_wr_tx_dismiss_slots(struct smc_link *link, u8 wr_rx_hdr_type,
 	}
 }
 
+bool smc_wr_tx_has_pending(struct smc_link *link, u8 wr_rx_hdr_type,
+			   smc_wr_tx_filter filter, unsigned long data)
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
+			return 1;
+	}
+	return 0;
+}
+
 /****************************** receive queue ********************************/
 
 int smc_wr_rx_register_handler(struct smc_wr_rx_handler *handler)
@@ -304,14 +328,19 @@ static inline void smc_wr_rx_process_cqes(struct ib_wc wc[], int num)
 			smc_wr_rx_demultiplex(&wc[i]);
 			smc_wr_rx_post(link); /* refill WR RX */
 		} else {
+			struct smc_link_group *lgr;
+
 			/* handle status errors */
 			switch (wc[i].status) {
 			case IB_WC_RETRY_EXC_ERR:
 			case IB_WC_RNR_RETRY_EXC_ERR:
 			case IB_WC_WR_FLUSH_ERR:
-			/* tbd in future patch: terminate connections of this
-			 * link group abnormally
-			 */
+				/* terminate connections of this link group
+				 * abnormally
+				 */
+				lgr = container_of(link, struct smc_link_group,
+						   lnk[SMC_SINGLE_LINK]);
+				smc_lgr_terminate(lgr);
 				break;
 			default:
 				smc_wr_rx_post(link); /* refill WR RX */
diff --git a/net/smc/smc_wr.h b/net/smc/smc_wr.h
index bb8bf87..2f6b645 100644
--- a/net/smc/smc_wr.h
+++ b/net/smc/smc_wr.h
@@ -82,6 +82,8 @@ int smc_wr_tx_get_free_slot(struct smc_link *, smc_wr_tx_handler,
 int smc_wr_tx_put_slot(struct smc_link *, struct smc_wr_tx_pend_priv *);
 int smc_wr_tx_send(struct smc_link *, struct smc_wr_tx_pend_priv *);
 void smc_wr_tx_cq_handler(struct ib_cq *, void *);
+bool smc_wr_tx_has_pending(struct smc_link *, u8,
+			   smc_wr_tx_filter, unsigned long);
 void smc_wr_tx_dismiss_slots(struct smc_link *, u8,
 			     smc_wr_tx_filter, smc_wr_tx_dismisser,
 			     unsigned long);
-- 
2.6.6
