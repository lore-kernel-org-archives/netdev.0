From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 12/15] smc: send data (through RDMA)
Date: Thu, 24 Nov 2016 16:06:42 +0100
Message-ID: <20161124150645.90881-13-ubraun@linux.vnet.ibm.com>
References: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54714 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S966324AbcKXPHM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:07:12 -0500
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAOF3iwA110760
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:07:12 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
        by mx0b-001b2d01.pphosted.com with ESMTP id 26wytem5pq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:07:11 -0500
Received: from localhost
        by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 24 Nov 2016 15:07:10 -0000
In-Reply-To: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

copy data to kernel send buffer, and trigger RDMA write

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile  |   2 +-
 net/smc/af_smc.c  |  13 +-
 net/smc/smc.h     |   1 +
 net/smc/smc_cdc.c |   7 +-
 net/smc/smc_tx.c  | 438 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_tx.h  |  34 +++++
 6 files changed, 491 insertions(+), 4 deletions(-)
 create mode 100644 net/smc/smc_tx.c
 create mode 100644 net/smc/smc_tx.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index ec0fd03..fc28d79 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SMC)	+= smc.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
-smc-y += smc_cdc.o
+smc-y += smc_cdc.o smc_tx.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 36a111c..4738f5a 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -37,6 +37,7 @@
 #include "smc_core.h"
 #include "smc_ib.h"
 #include "smc_pnet.h"
+#include "smc_tx.h"
 
 static DEFINE_MUTEX(smc_create_lgr_pending);	/* serialize link group
 						 * creation
@@ -420,6 +421,8 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	}
 
 	mutex_unlock(&smc_create_lgr_pending);
+	smc_tx_init(smc);
+
 out_connected:
 	smc_copy_sock_settings_to_clc(smc);
 	smc->sk.sk_state = SMC_ACTIVE;
@@ -761,6 +764,8 @@ static void smc_listen_work(struct work_struct *work)
 			goto decline_rdma;
 	}
 
+	smc_tx_init(new_smc);
+
 out_connected:
 	sk_refcnt_debug_inc(newsmcsk);
 	newsmcsk->sk_state = SMC_ACTIVE;
@@ -934,7 +939,7 @@ static int smc_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	if (smc->use_fallback)
 		rc = smc->clcsock->ops->sendmsg(smc->clcsock, msg, len);
 	else
-		rc = sock_no_sendmsg(sock, msg, len);
+		rc = smc_tx_sendmsg(smc, msg, len);
 out:
 	release_sock(sk);
 	return rc;
@@ -1015,6 +1020,12 @@ static unsigned int smc_poll(struct file *file, struct socket *sock,
 			mask |= smc_accept_poll(sk);
 		if (sk->sk_err)
 			mask |= POLLERR;
+		if (atomic_read(&smc->conn.sndbuf_space)) {
+			mask |= POLLOUT | POLLWRNORM;
+		} else {
+			sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
+			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		}
 		/* for now - to be enhanced in follow-on patch */
 	}
 
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 6cb9496..2956135 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -130,6 +130,7 @@ struct smc_connection {
 	atomic_t		sndbuf_space;	/* remaining space in sndbuf */
 	u16			tx_cdc_seq;	/* sequence # for CDC send */
 	spinlock_t		send_lock;	/* protect wr_sends */
+	struct work_struct	tx_work;	/* retry of smc_cdc_msg_send */
 
 	struct smc_host_cdc_msg	local_rx_ctrl;	/* filled during event_handl.
 						 * .prod cf. TCP rcv_nxt
diff --git a/net/smc/smc_cdc.c b/net/smc/smc_cdc.c
index e14809e..22af635 100644
--- a/net/smc/smc_cdc.c
+++ b/net/smc/smc_cdc.c
@@ -14,6 +14,7 @@
 #include "smc.h"
 #include "smc_wr.h"
 #include "smc_cdc.h"
+#include "smc_tx.h"
 
 /********************************** send *************************************/
 
@@ -52,7 +53,7 @@ static void smc_cdc_tx_handler(struct smc_wr_tx_pend_priv *pnd_snd,
 			       smc_curs_read(&cdcpend->cursor, cdcpend->conn),
 			       cdcpend->conn);
 	}
-	/* subsequent patch: wake if send buffer space available */
+	smc_tx_sndbuf_nonfull(smc);
 	bh_unlock_sock(&smc->sk);
 }
 
@@ -208,7 +209,9 @@ static void smc_cdc_msg_recv_action(struct smc_sock *smc,
 	}
 
 	/* piggy backed tx info */
-	/* subsequent patch: wake receivers if receive buffer space available */
+	/* trigger sndbuf consumer: RDMA write into peer RMBE and CDC */
+	if (diff_cons && smc_tx_prepared_sends(conn))
+		smc_tx_sndbuf_nonempty(conn);
 
 	/* subsequent patch: trigger socket release if connection closed */
 
diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
new file mode 100644
index 0000000..d86bef6
--- /dev/null
+++ b/net/smc/smc_tx.c
@@ -0,0 +1,438 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Manage send buffer.
+ * Producer:
+ * Copy user space data into send buffer, if send buffer space available.
+ * Consumer:
+ * Trigger RDMA write into RMBE of peer and send CDC, if RMBE space available.
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <linux/net.h>
+#include <linux/rcupdate.h>
+#include <linux/workqueue.h>
+#include <net/sock.h>
+
+#include "smc.h"
+#include "smc_wr.h"
+#include "smc_cdc.h"
+#include "smc_tx.h"
+
+/***************************** sndbuf producer *******************************/
+
+/* callback implementation for sk.sk_write_space()
+ * to wakeup sndbuf producers that blocked with smc_tx_wait_memory().
+ * called under sk_socket lock.
+ */
+static void smc_tx_write_space(struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+	struct smc_sock *smc = smc_sk(sk);
+	struct socket_wq *wq;
+
+	/* similar to sk_stream_write_space */
+	if (atomic_read(&smc->conn.sndbuf_space) && sock) {
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+		rcu_read_lock();
+		wq = rcu_dereference(sk->sk_wq);
+		if (skwq_has_sleeper(wq))
+			wake_up_interruptible_poll(&wq->wait,
+						   POLLOUT | POLLWRNORM |
+						   POLLWRBAND);
+		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
+			sock_wake_async(wq, SOCK_WAKE_SPACE, POLL_OUT);
+		rcu_read_unlock();
+	}
+}
+
+/* Wakeup sndbuf producers that blocked with smc_tx_wait_memory().
+ * Cf. tcp_data_snd_check()=>tcp_check_space()=>tcp_new_space().
+ */
+void smc_tx_sndbuf_nonfull(struct smc_sock *smc)
+{
+	if (smc->sk.sk_socket &&
+	    test_bit(SOCK_NOSPACE, &smc->sk.sk_socket->flags))
+		smc->sk.sk_write_space(&smc->sk);
+}
+
+/* blocks sndbuf producer until at least one byte of free space available */
+static int smc_tx_wait_memory(struct smc_sock *smc, int flags)
+{
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
+	struct smc_connection *conn = &smc->conn;
+	struct sock *sk = &smc->sk;
+	bool noblock;
+	long timeo;
+	int rc = 0;
+
+	/* similar to sk_stream_wait_memory */
+	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+	noblock = timeo ? false : true;
+	add_wait_queue(sk_sleep(sk), &wait);
+	while (1) {
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
+		if (sk->sk_err ||
+		    (sk->sk_shutdown & SEND_SHUTDOWN) ||
+		    conn->local_tx_ctrl.conn_state_flags.peer_done_writing) {
+			rc = -EPIPE;
+			break;
+		}
+		if (conn->local_rx_ctrl.conn_state_flags.peer_conn_abort) {
+			rc = -ECONNRESET;
+			break;
+		}
+		if (!timeo) {
+			if (noblock)
+				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+			rc = -EAGAIN;
+			break;
+		}
+		if (signal_pending(current)) {
+			rc = sock_intr_errno(timeo);
+			break;
+		}
+		sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
+		if (atomic_read(&conn->sndbuf_space))
+			break; /* at least 1 byte of free space available */
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		sk->sk_write_pending++;
+		sk_wait_event(sk, &timeo,
+			      sk->sk_err ||
+			      (sk->sk_shutdown & SEND_SHUTDOWN) ||
+			      smc_cdc_rxed_any_close_or_senddone(conn) ||
+			      atomic_read(&conn->sndbuf_space),
+			      &wait);
+		sk->sk_write_pending--;
+	}
+	remove_wait_queue(sk_sleep(sk), &wait);
+	return rc;
+}
+
+/* sndbuf producer: main API called by socket layer.
+ * called under sock lock.
+ */
+int smc_tx_sendmsg(struct smc_sock *smc, struct msghdr *msg, size_t len)
+{
+	size_t copylen, send_done = 0, send_remaining = len;
+	size_t chunk_len, chunk_off, chunk_len_sum;
+	struct smc_connection *conn = &smc->conn;
+	union smc_host_cursor prep;
+	struct sock *sk = &smc->sk;
+	char *sndbuf_base;
+	int tx_cnt_prep;
+	int writespace;
+	int rc, chunk;
+
+	/* This should be in poll */
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
+
+	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN)) {
+		rc = -EPIPE;
+		goto out_err;
+	}
+
+	while (msg_data_left(msg)) {
+		if (sk->sk_state == SMC_INIT)
+			return -ENOTCONN;
+		if (smc->sk.sk_shutdown & SEND_SHUTDOWN ||
+		    conn->local_tx_ctrl.conn_state_flags.peer_conn_abort)
+			return -EPIPE;
+		if (smc_cdc_rxed_any_close(conn))
+			return send_done ?: -ECONNRESET;
+
+		if (!atomic_read(&conn->sndbuf_space)) {
+			rc = smc_tx_wait_memory(smc, msg->msg_flags);
+			if (rc) {
+				if (send_done)
+					return send_done;
+				goto out_err;
+			}
+			continue;
+		}
+
+		/* initialize variables for 1st iteration of subsequent loop */
+		/* could be just 1 byte, even after smc_tx_wait_memory above */
+		writespace = atomic_read(&conn->sndbuf_space);
+		/* not more than what user space asked for */
+		copylen = min_t(size_t, send_remaining, writespace);
+		/* determine start of sndbuf */
+		sndbuf_base = conn->sndbuf_desc->cpu_addr;
+		smc_curs_write(&prep,
+			       smc_curs_read(&conn->tx_curs_prep, conn),
+			       conn);
+		tx_cnt_prep = prep.count;
+		/* determine chunks where to write into sndbuf */
+		/* either unwrapped case, or 1st chunk of wrapped case */
+		chunk_len = min_t(size_t,
+				  copylen, conn->sndbuf_size - tx_cnt_prep);
+		chunk_len_sum = chunk_len;
+		chunk_off = tx_cnt_prep;
+		for (chunk = 0; chunk < 2; chunk++) {
+			rc = memcpy_from_msg(sndbuf_base + chunk_off,
+					     msg, chunk_len);
+			if (rc) {
+				if (send_done)
+					return send_done;
+				goto out_err;
+			}
+			send_done += chunk_len;
+			send_remaining -= chunk_len;
+
+			if (chunk_len_sum == copylen)
+				break; /* either on 1st or 2nd iteration */
+			/* prepare next (== 2nd) iteration */
+			chunk_len = copylen - chunk_len; /* remainder */
+			chunk_len_sum += chunk_len;
+			chunk_off = 0; /* modulo offset in send ring buffer */
+		}
+		/* update cursors */
+		smc_curs_add(conn->sndbuf_size, &prep, copylen);
+		smc_curs_write(&conn->tx_curs_prep,
+			       smc_curs_read(&prep, conn),
+			       conn);
+		/* increased in send tasklet smc_cdc_tx_handler() */
+		smp_mb__before_atomic();
+		atomic_sub(copylen, &conn->sndbuf_space);
+		/* guarantee 0 <= sndbuf_space <= sndbuf_size */
+		smp_mb__after_atomic();
+		/* since we just produced more new data into sndbuf,
+		 * trigger sndbuf consumer: RDMA write into peer RMBE and CDC
+		 */
+		smc_tx_sndbuf_nonempty(conn);
+	} /* while (msg_data_left(msg)) */
+
+	return send_done;
+
+out_err:
+	rc = sk_stream_error(sk, msg->msg_flags, rc);
+	/* make sure we wake any epoll edge trigger waiter */
+	if (unlikely(rc == -EAGAIN))
+		sk->sk_write_space(sk);
+	return rc;
+}
+
+/***************************** sndbuf consumer *******************************/
+
+/* sndbuf consumer: actual data transfer of one target chunk with RDMA write */
+static int smc_tx_rdma_write(struct smc_connection *conn, int peer_rmbe_offset,
+			     int num_sges, struct ib_sge sges[])
+{
+	struct smc_link_group *lgr = conn->lgr;
+	struct ib_send_wr *failed_wr = NULL;
+	struct ib_rdma_wr rdma_wr;
+	struct smc_link *link;
+	int rc;
+
+	memset(&rdma_wr, 0, sizeof(rdma_wr));
+	link = &lgr->lnk[SMC_SINGLE_LINK];
+	rdma_wr.wr.wr_id = smc_wr_tx_get_next_wr_id(link);
+	rdma_wr.wr.sg_list = sges;
+	rdma_wr.wr.num_sge = num_sges;
+	rdma_wr.wr.opcode = IB_WR_RDMA_WRITE;
+	rdma_wr.remote_addr =
+		lgr->rtokens[conn->rtoken_idx][SMC_SINGLE_LINK].dma_addr +
+		/* RMBE within RMB */
+		((conn->peer_conn_idx - 1) * conn->peer_rmbe_size) +
+		/* offset within RMBE */
+		peer_rmbe_offset;
+	rdma_wr.rkey = lgr->rtokens[conn->rtoken_idx][SMC_SINGLE_LINK].rkey;
+	rc = ib_post_send(link->roce_qp, &rdma_wr.wr, &failed_wr);
+	if (rc)
+		conn->local_tx_ctrl.conn_state_flags.peer_conn_abort = 1;
+	return rc;
+}
+
+/* sndbuf consumer */
+static inline void smc_tx_advance_cursors(struct smc_connection *conn,
+					  union smc_host_cursor *prod,
+					  union smc_host_cursor *sent,
+					  size_t len)
+{
+	smc_curs_add(conn->peer_rmbe_size, prod, len);
+	/* increased in recv tasklet smc_cdc_msg_rcv() */
+	smp_mb__before_atomic();
+	/* data in flight reduces usable snd_wnd */
+	atomic_sub(len, &conn->peer_rmbe_space);
+	/* guarantee 0 <= peer_rmbe_space <= peer_rmbe_size */
+	smp_mb__after_atomic();
+	smc_curs_add(conn->sndbuf_size, sent, len);
+}
+
+/* sndbuf consumer: prepare all necessary (src&dst) chunks of data transmit;
+ * usable snd_wnd as max transmit
+ */
+static int smc_tx_rdma_writes(struct smc_connection *conn)
+{
+	size_t src_off, src_len, dst_off, dst_len; /* current chunk values */
+	size_t len, dst_len_sum, src_len_sum, dstchunk, srcchunk;
+	union smc_host_cursor sent, prep, prod, cons;
+	struct ib_sge sges[SMC_IB_MAX_SEND_SGE];
+	struct smc_link_group *lgr = conn->lgr;
+	int to_send, rmbespace;
+	struct smc_link *link;
+	int num_sges;
+	int rc;
+
+	/* source: sndbuf */
+	smc_curs_write(&sent, smc_curs_read(&conn->tx_curs_sent, conn), conn);
+	smc_curs_write(&prep, smc_curs_read(&conn->tx_curs_prep, conn), conn);
+	/* cf. wmem_alloc - (snd_max - snd_una) */
+	to_send = smc_curs_diff(conn->sndbuf_size, &sent, &prep);
+	if (to_send <= 0)
+		return 0;
+
+	/* destination: RMBE */
+	/* cf. snd_wnd */
+	rmbespace = atomic_read(&conn->peer_rmbe_space);
+	if (rmbespace <= 0)
+		return 0;
+	smc_curs_write(&prod,
+		       smc_curs_read(&conn->local_tx_ctrl.prod, conn),
+		       conn);
+	smc_curs_write(&cons,
+		       smc_curs_read(&conn->local_rx_ctrl.cons, conn),
+		       conn);
+
+	/* if usable snd_wnd closes ask peer to advertise once it opens again */
+	conn->local_tx_ctrl.prod_flags.write_blocked = (to_send >= rmbespace);
+	/* cf. usable snd_wnd */
+	len = min(to_send, rmbespace);
+
+	/* initialize variables for first iteration of subsequent nested loop */
+	link = &lgr->lnk[SMC_SINGLE_LINK];
+	dst_off = prod.count;
+	if (prod.wrap == cons.wrap) {
+		/* the filled destination area is unwrapped,
+		 * hence the available free destination space is wrapped
+		 * and we need 2 destination chunks of sum len; start with 1st
+		 * which is limited by what's available in sndbuf
+		 */
+		dst_len = min_t(size_t,
+				conn->peer_rmbe_size - prod.count, len);
+	} else {
+		/* the filled destination area is wrapped,
+		 * hence the available free destination space is unwrapped
+		 * and we need a single destination chunk of entire len
+		 */
+		dst_len = len;
+	}
+	dst_len_sum = dst_len;
+	src_off = sent.count;
+	/* dst_len determines the maximum src_len */
+	if (sent.count + dst_len <= conn->sndbuf_size) {
+		/* unwrapped src case: single chunk of entire dst_len */
+		src_len = dst_len;
+	} else {
+		/* wrapped src case: 2 chunks of sum dst_len; start with 1st: */
+		src_len = conn->sndbuf_size - sent.count;
+	}
+	src_len_sum = src_len;
+	for (dstchunk = 0; dstchunk < 2; dstchunk++) {
+		num_sges = 0;
+		for (srcchunk = 0; srcchunk < 2; srcchunk++) {
+			sges[srcchunk].addr =
+				conn->sndbuf_desc->dma_addr[SMC_SINGLE_LINK] +
+				src_off;
+			sges[srcchunk].length = src_len;
+			sges[srcchunk].lkey = link->roce_pd->local_dma_lkey;
+			num_sges++;
+			src_off += src_len;
+			if (src_off >= conn->sndbuf_size)
+				src_off -= conn->sndbuf_size;
+						/* modulo in send ring */
+			if (src_len_sum == dst_len)
+				break; /* either on 1st or 2nd iteration */
+			/* prepare next (== 2nd) iteration */
+			src_len = dst_len - src_len; /* remainder */
+			src_len_sum += src_len;
+		}
+		rc = smc_tx_rdma_write(conn, dst_off, num_sges, sges);
+		if (rc)
+			return rc;
+		if (dst_len_sum == len)
+			break; /* either on 1st or 2nd iteration */
+		/* prepare next (== 2nd) iteration */
+		dst_off = 0; /* modulo offset in RMBE ring buffer */
+		dst_len = len - dst_len; /* remainder */
+		dst_len_sum += dst_len;
+		src_len = min_t(int,
+				dst_len, conn->sndbuf_size - sent.count);
+		src_len_sum = src_len;
+	}
+
+	smc_tx_advance_cursors(conn, &prod, &sent, len);
+	/* update connection's cursors with advanced local cursors */
+	smc_curs_write(&conn->local_tx_ctrl.prod,
+		       smc_curs_read(&prod, conn),
+		       conn);
+							/* dst: peer RMBE */
+	smc_curs_write(&conn->tx_curs_sent,
+		       smc_curs_read(&sent, conn),
+		       conn);
+							/* src: local sndbuf */
+
+	return 0;
+}
+
+/* Wakeup sndbuf consumers from any context (IRQ or process)
+ * since there is more data to transmit; usable snd_wnd as max transmit
+ */
+int smc_tx_sndbuf_nonempty(struct smc_connection *conn)
+{
+	struct smc_cdc_tx_pend *pend;
+	struct smc_wr_buf *wr_buf;
+	int rc;
+
+	spin_lock_bh(&conn->send_lock);
+	rc = smc_cdc_get_free_slot(&conn->lgr->lnk[SMC_SINGLE_LINK], &wr_buf,
+				   &pend);
+	if (rc < 0) {
+		if (rc == -EBUSY) {
+			rc = 0;
+			schedule_work(&conn->tx_work);
+		}
+		goto out_unlock;
+	}
+
+	rc = smc_tx_rdma_writes(conn);
+	if (rc) {
+		smc_wr_tx_put_slot(&conn->lgr->lnk[SMC_SINGLE_LINK],
+				   (struct smc_wr_tx_pend_priv *)pend);
+		goto out_unlock;
+	}
+
+	rc = smc_cdc_msg_send(conn, wr_buf, pend);
+
+out_unlock:
+	spin_unlock_bh(&conn->send_lock);
+	return rc;
+}
+
+/* Wakeup sndbuf consumers from process context
+ * since there is more data to transmit
+ */
+static void smc_tx_work(struct work_struct *work)
+{
+	struct smc_connection *conn = container_of(work,
+						   struct smc_connection,
+						   tx_work);
+	struct smc_sock *smc = container_of(conn, struct smc_sock, conn);
+
+	lock_sock(&smc->sk);
+	smc_tx_sndbuf_nonempty(conn);
+	release_sock(&smc->sk);
+}
+
+/***************************** send initialize *******************************/
+
+/* Initialize send properties on connection establishment. NB: not __init! */
+void smc_tx_init(struct smc_sock *smc)
+{
+	smc->sk.sk_write_space = smc_tx_write_space;
+	INIT_WORK(&smc->conn.tx_work, smc_tx_work);
+	spin_lock_init(&smc->conn.send_lock);
+}
diff --git a/net/smc/smc_tx.h b/net/smc/smc_tx.h
new file mode 100644
index 0000000..931c666
--- /dev/null
+++ b/net/smc/smc_tx.h
@@ -0,0 +1,34 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Manage send buffer
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#ifndef SMC_TX_H
+#define SMC_TX_H
+
+#include <linux/socket.h>
+#include <linux/types.h>
+
+#include "smc.h"
+#include "smc_cdc.h"
+
+static inline int smc_tx_prepared_sends(struct smc_connection *conn)
+{
+	union smc_host_cursor sent, prep;
+
+	smc_curs_write(&sent, smc_curs_read(&conn->tx_curs_sent, conn), conn);
+	smc_curs_write(&prep, smc_curs_read(&conn->tx_curs_prep, conn), conn);
+	return smc_curs_diff(conn->sndbuf_size, &sent, &prep);
+}
+
+void smc_tx_init(struct smc_sock *smc);
+int smc_tx_sendmsg(struct smc_sock *smc, struct msghdr *msg, size_t len);
+int smc_tx_sndbuf_nonempty(struct smc_connection *conn);
+void smc_tx_sndbuf_nonfull(struct smc_sock *smc);
+
+#endif /* SMC_TX_H */
-- 
2.8.4
