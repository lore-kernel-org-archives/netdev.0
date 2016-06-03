From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 13/15] smc: receive data from RMBE
Date: Fri,  3 Jun 2016 17:27:12 +0200
Message-ID: <201606031527.u53FQ52x045195@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33547 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933195AbcFCP1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:55 -0400
Received: from pps.filterd (m0082756.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ52x045195
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:55 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23b4m8q6jw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:55 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:51 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move RMBE data into user space buffer and update managing cursors

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   2 +-
 net/smc/af_smc.c   |   7 +-
 net/smc/smc.h      |   4 +
 net/smc/smc_cdc.c  |   6 +-
 net/smc/smc_core.c |  10 +++
 net/smc/smc_rx.c   | 212 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_rx.h   |  22 ++++++
 net/smc/smc_tx.c   |  32 ++++++++
 net/smc/smc_tx.h   |   1 +
 9 files changed, 293 insertions(+), 3 deletions(-)
 create mode 100644 net/smc/smc_rx.c
 create mode 100644 net/smc/smc_rx.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index fc28d79..6255e29 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SMC)	+= smc.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
-smc-y += smc_cdc.o smc_tx.o
+smc-y += smc_cdc.o smc_tx.o smc_rx.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index c96a234..4652759 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -37,6 +37,7 @@
 #include "smc_ib.h"
 #include "smc_pnet.h"
 #include "smc_tx.h"
+#include "smc_rx.h"
 
 static DEFINE_MUTEX(smc_create_lgr_pending);	/* serialize link group
 						 * creation
@@ -422,6 +423,7 @@ static int smc_connect_rdma(struct smc_sock *smc)
 
 	mutex_unlock(&smc_create_lgr_pending);
 	smc_tx_init(smc);
+	smc_rx_init(smc);
 
 out_connected:
 	smc_copy_sock_settings_to_clc(smc);
@@ -765,6 +767,7 @@ static void smc_listen_work(struct work_struct *work)
 	}
 
 	smc_tx_init(new_smc);
+	smc_rx_init(new_smc);
 
 out_connected:
 	sk_refcnt_debug_inc(newsmcsk);
@@ -960,7 +963,7 @@ static int smc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	if (smc->use_fallback)
 		rc = smc->clcsock->ops->recvmsg(smc->clcsock, msg, len, flags);
 	else
-		rc = sock_no_recvmsg(sock, msg, len, flags);
+		rc = smc_rx_recvmsg(smc, msg, len, flags);
 out:
 	release_sock(sk);
 	return rc;
@@ -1026,6 +1029,8 @@ static unsigned int smc_poll(struct file *file, struct socket *sock,
 			sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		}
+		if (atomic_read(&smc->conn.bytes_to_rcv))
+			mask |= POLLIN | POLLRDNORM;
 		/* for now - to be enhanced in follow-on patch */
 	}
 
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 488bc86..8aa9be8 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -107,6 +107,10 @@ struct smc_connection {
 	struct smc_buf_desc	*rmb_desc;	/* RMBE descriptor */
 	int			rmbe_size;	/* RMBE size <== sock rmem */
 	int			rmbe_size_short;/* compressed notation */
+	int			rmbe_update_limit;
+						/* lower limit for consumer
+						 * cursor update
+						 */
 
 	struct smc_host_cdc_msg	local_tx_ctrl;	/* host byte order staging
 						 * buffer for CDC msg send
diff --git a/net/smc/smc_cdc.c b/net/smc/smc_cdc.c
index 01b582a..d8a8dce 100644
--- a/net/smc/smc_cdc.c
+++ b/net/smc/smc_cdc.c
@@ -15,6 +15,7 @@
 #include "smc_wr.h"
 #include "smc_cdc.h"
 #include "smc_tx.h"
+#include "smc_rx.h"
 
 /********************************** send *************************************/
 
@@ -190,6 +191,7 @@ static void smc_cdc_msg_recv_action(struct smc_sock *smc,
 		atomic_add(diff_prod, &conn->bytes_to_rcv);
 		/* guarantee 0 <= bytes_to_rcv <= rmbe_size */
 		smp_mb__after_atomic();
+		smc->sk.sk_data_ready(&smc->sk);
 	}
 
 	if (conn->local_rx_ctrl.conn_state_flags.peer_conn_abort)
@@ -213,7 +215,9 @@ static void smc_cdc_msg_recv_action(struct smc_sock *smc,
 		return;
 
 	/* data available */
-	/* subsequent patch: send delayed ack, wake receivers */
+	if ((conn->local_rx_ctrl.prod_flags.write_blocked) ||
+	    (conn->local_rx_ctrl.prod_flags.cons_curs_upd_req))
+		smc_tx_consumer_update(conn);
 }
 
 /* called under tasklet context */
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index d751d3f..cbc9c0e 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -511,6 +511,15 @@ struct smc_buf_desc *smc_rmb_get_slot(struct smc_link_group *lgr,
 	return NULL;
 }
 
+/* one of the conditions for announcing a receiver's current window size is
+ * that it "results in a minimum increase in the window size of 10% of the
+ * receive buffer space" [RFC7609]
+ */
+static inline int smc_rmb_wnd_update_limit(int rmbe_size)
+{
+	return min_t(int, rmbe_size / 10, SOCK_MIN_SNDBUF / 2);
+}
+
 /* create the tx buffer for an SMC socket */
 int smc_sndbuf_create(struct smc_sock *smc)
 {
@@ -642,6 +651,7 @@ int smc_rmb_create(struct smc_sock *smc)
 		conn->rmbe_size_short = tmp_bufsize_short;
 		smc->sk.sk_rcvbuf = tmp_bufsize * 2;
 		atomic_set(&conn->bytes_to_rcv, 0);
+		conn->rmbe_update_limit = smc_rmb_wnd_update_limit(tmp_bufsize);
 		return 0;
 	} else {
 		return -ENOMEM;
diff --git a/net/smc/smc_rx.c b/net/smc/smc_rx.c
new file mode 100644
index 0000000..44f9b4d
--- /dev/null
+++ b/net/smc/smc_rx.c
@@ -0,0 +1,212 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Manage RMBE
+ * copy new RMBE data into user space
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#include <linux/net.h>
+#include <linux/rcupdate.h>
+#include <net/sock.h>
+
+#include "smc.h"
+#include "smc_core.h"
+#include "smc_cdc.h"
+#include "smc_tx.h" /* smc_tx_consumer_update() */
+#include "smc_rx.h"
+
+/* callback implementation for sk.sk_data_ready()
+ * to wakeup rcvbuf consumers that blocked with smc_rx_wait_data().
+ * indirectly called by smc_cdc_msg_recv_action().
+ */
+static void smc_rx_data_ready(struct sock *sk)
+{
+	struct socket_wq *wq;
+
+	/* derived from sock_def_readable() */
+	/* called already in smc_listen_work() */
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (skwq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
+						POLLRDNORM | POLLRDBAND);
+	if ((sk->sk_shutdown == SHUTDOWN_MASK) ||
+	    (sk->sk_state == SMC_CLOSED))
+		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_HUP);
+	else
+		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
+	rcu_read_unlock();
+}
+
+/* blocks rcvbuf consumer until >=len bytes available or timeout or interrupted
+ *   @smc    smc socket
+ *   @timeo  pointer to max seconds to wait, pointer to value 0 for no timeout
+ * Returns:
+ * 1 if at least 1 byte available in rcvbuf or if socket error/shutdown.
+ * 0 otherwise (nothing in rcvbuf nor timeout, e.g. interrupted).
+ */
+static int smc_rx_wait_data(struct smc_sock *smc, long *timeo)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct sock *sk = &smc->sk;
+	DEFINE_WAIT(wait);
+	int rc;
+
+	if (atomic_read(&conn->bytes_to_rcv))
+		return 1;
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
+	rc = sk_wait_event(sk, timeo,
+			   sk->sk_err ||
+			   sk->sk_shutdown & RCV_SHUTDOWN ||
+			   sock_flag(sk, SOCK_DONE) ||
+			   atomic_read(&conn->bytes_to_rcv) ||
+			   smc_cdc_rxed_any_close_or_senddone(conn));
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
+	finish_wait(sk_sleep(sk), &wait);
+	return rc;
+}
+
+/* rcvbuf consumer: main API called by socket layer.
+ * called under sk lock.
+ */
+int smc_rx_recvmsg(struct smc_sock *smc, struct msghdr *msg, size_t len,
+		   int flags)
+{
+	size_t copylen, read_done = 0, read_remaining = len;
+	size_t chunk_len, chunk_off, chunk_len_sum;
+	struct smc_connection *conn = &smc->conn;
+	union smc_host_cursor_ovl cons;
+	int readable, chunk;
+	char *rcvbuf_base;
+	struct sock *sk;
+	long timeo;
+	int target;		/* Read at least these many bytes */
+	int rc;
+
+	if (unlikely(flags & MSG_ERRQUEUE))
+		return -EINVAL; /* future work for sk.sk_family == AF_SMC */
+	if (flags & MSG_OOB)
+		return -EINVAL; /* future work */
+
+	sk = &smc->sk;
+	if (sk->sk_state == SMC_LISTEN)
+		return -ENOTCONN;
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
+
+	msg->msg_namelen = 0;
+	/* we currently use 1 RMBE per RMB, so RMBE == RMB base addr */
+	rcvbuf_base = conn->rmb_desc->cpu_addr;
+
+	do { /* while (read_remaining) */
+		if (read_done >= target)
+			break;
+
+		if (atomic_read(&conn->bytes_to_rcv))
+			goto copy;
+
+		if (read_done) {
+			if (sk->sk_err ||
+			    sk->sk_state == SMC_CLOSED ||
+			    (sk->sk_shutdown & RCV_SHUTDOWN) ||
+			    !timeo ||
+			    signal_pending(current) ||
+			    smc_cdc_rxed_any_close_or_senddone(conn) ||
+			    conn->local_tx_ctrl.conn_state_flags.
+			    peer_conn_abort)
+				break;
+		} else {
+			if (sock_flag(sk, SOCK_DONE))
+				break;
+			if (sk->sk_err) {
+				read_done = sock_error(sk);
+				break;
+			}
+			if (sk->sk_shutdown & RCV_SHUTDOWN ||
+			    smc_cdc_rxed_any_close_or_senddone(conn) ||
+			    conn->local_tx_ctrl.conn_state_flags.
+			    peer_conn_abort)
+				break;
+			if (sk->sk_state == SMC_CLOSED) {
+				if (!sock_flag(sk, SOCK_DONE)) {
+					/* This occurs when user tries to read
+					 * from never connected socket.
+					 */
+					read_done = -ENOTCONN;
+					break;
+				}
+				break;
+			}
+			if (signal_pending(current)) {
+				read_done = sock_intr_errno(timeo);
+				break;
+			}
+		}
+
+		if (!atomic_read(&conn->bytes_to_rcv)) {
+			smc_rx_wait_data(smc, &timeo);
+			continue;
+		}
+
+copy:
+		/* initialize variables for 1st iteration of subsequent loop */
+		/* could be just 1 byte, even after smc_rx_wait_data above */
+		readable = atomic_read(&conn->bytes_to_rcv);
+		/* not more than what user space asked for */
+		copylen = min_t(size_t, read_remaining, readable);
+		cons.acurs = smc_curs_read(conn->local_tx_ctrl.cons.acurs);
+		/* determine chunks where to read from rcvbuf */
+		/* either unwrapped case, or 1st chunk of wrapped case */
+		chunk_len = min_t(size_t,
+				  copylen, conn->rmbe_size - cons.curs.count);
+		chunk_len_sum = chunk_len;
+		chunk_off = cons.curs.count;
+		for (chunk = 0; chunk < 2; chunk++) {
+			if (!(flags & MSG_TRUNC)) {
+				rc = memcpy_to_msg(msg, rcvbuf_base + chunk_off,
+						   chunk_len);
+				if (rc) {
+					if (!read_done)
+						read_done = -EFAULT;
+					goto out;
+				}
+			}
+			read_remaining -= chunk_len;
+			read_done += chunk_len;
+
+			if (chunk_len_sum == copylen)
+				break; /* either on 1st or 2nd iteration */
+			/* prepare next (== 2nd) iteration */
+			chunk_len = copylen - chunk_len; /* remainder */
+			chunk_len_sum += chunk_len;
+			chunk_off = 0; /* modulo offset in recv ring buffer */
+		}
+
+		/* update cursors */
+		if (!(flags & MSG_PEEK)) {
+			smc_curs_add(conn->rmbe_size, &cons.curs, copylen);
+			/* increased in recv tasklet smc_cdc_msg_rcv() */
+			smp_mb__before_atomic();
+			atomic_sub(copylen, &conn->bytes_to_rcv);
+			/* guarantee 0 <= bytes_to_rcv <= rmbe_size */
+			smp_mb__after_atomic();
+			xchg(&conn->local_tx_ctrl.cons.acurs, cons.acurs);
+			/* send consumer cursor update if required */
+			/* similar to advertising new TCP rcv_wnd if required */
+			smc_tx_consumer_update(conn);
+		}
+	} while (read_remaining);
+out:
+	return read_done;
+}
+
+/* Initialize receive properties on connection establishment. NB: not __init! */
+void smc_rx_init(struct smc_sock *smc)
+{
+	smc->sk.sk_data_ready = smc_rx_data_ready;
+}
diff --git a/net/smc/smc_rx.h b/net/smc/smc_rx.h
new file mode 100644
index 0000000..f8abe66
--- /dev/null
+++ b/net/smc/smc_rx.h
@@ -0,0 +1,22 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Manage RMBE
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#ifndef SMC_RX_H
+#define SMC_RX_H
+
+#include <linux/socket.h>
+#include <linux/types.h>
+
+#include "smc.h"
+
+void smc_rx_init(struct smc_sock *);
+int smc_rx_recvmsg(struct smc_sock *, struct msghdr *, size_t, int);
+
+#endif /* SMC_RX_H */
diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
index 4a791c5..4cd54e1 100644
--- a/net/smc/smc_tx.c
+++ b/net/smc/smc_tx.c
@@ -410,6 +410,38 @@ static void smc_tx_work(struct work_struct *work)
 	release_sock(&smc->sk);
 }
 
+void smc_tx_consumer_update(struct smc_connection *conn)
+{
+	union smc_host_cursor_ovl cfed, cons;
+	struct smc_cdc_tx_pend *pend;
+	struct smc_wr_buf *wr_buf;
+	int to_confirm, rc;
+
+	cons.acurs = smc_curs_read(conn->local_tx_ctrl.cons.acurs);
+	cfed.acurs = smc_curs_read(conn->rx_curs_confirmed.acurs);
+	to_confirm = smc_curs_diff(conn->rmbe_size, &cfed, &cons);
+
+	if (conn->local_rx_ctrl.prod_flags.cons_curs_upd_req ||
+	    ((to_confirm > conn->rmbe_update_limit) &&
+	     ((to_confirm > (conn->rmbe_size / 2)) ||
+	      conn->local_rx_ctrl.prod_flags.write_blocked))) {
+		rc = smc_cdc_get_free_slot(&conn->lgr->lnk[SMC_SINGLE_LINK],
+					   &wr_buf, &pend);
+		if (!rc)
+			rc = smc_cdc_msg_send(conn, wr_buf, pend);
+		if (rc < 0) {
+			schedule_work(&conn->tx_work);
+			return;
+		}
+		xchg(&conn->rx_curs_confirmed.acurs,
+		     smc_curs_read(conn->local_tx_ctrl.cons.acurs));
+		conn->local_rx_ctrl.prod_flags.cons_curs_upd_req = 0;
+	}
+	if (conn->local_rx_ctrl.prod_flags.write_blocked &&
+	    !atomic_read(&conn->bytes_to_rcv))
+		conn->local_rx_ctrl.prod_flags.write_blocked = 0;
+}
+
 /***************************** send initialize *******************************/
 
 /* Initialize send properties on connection establishment. NB: not __init! */
diff --git a/net/smc/smc_tx.h b/net/smc/smc_tx.h
index d949ca9..3984e4b 100644
--- a/net/smc/smc_tx.h
+++ b/net/smc/smc_tx.h
@@ -30,5 +30,6 @@ void smc_tx_init(struct smc_sock *);
 int smc_tx_sendmsg(struct smc_sock *, struct msghdr *, size_t);
 int smc_tx_sndbuf_nonempty(struct smc_connection *);
 void smc_tx_sndbuf_nonfull(struct smc_sock *);
+void smc_tx_consumer_update(struct smc_connection *);
 
 #endif /* SMC_TX_H */
-- 
2.6.6
