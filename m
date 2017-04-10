From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/10] net/smc: no socket state changes in tasklet context
Date: Mon, 10 Apr 2017 14:58:01 +0200
Message-ID: <20170410125805.13653-7-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53490 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752941AbdDJM6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:22 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACs921102206
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:22 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r8m1dyq8-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:21 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:19 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several state changes occur during SMC socket closing. Currently
state changes triggered locally occur in process context with
lock_sock() taken while state changes triggered by peer occur in
tasklet context with bh_lock_sock() taken. bh_lock_sock() does not
wait till a lock_sock(() task in process context is finished. This
may lead to races in socket state transitions resulting in dangling
SMC-sockets, or it may lead to duplicate SMC socket freeing.
This patch introduces a closing worker to run all state changes under
lock_sock().

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reported-by: Dave Jones <davej@codemonkey.org.uk>
---
 net/smc/af_smc.c    |  8 ++++++--
 net/smc/smc.h       |  1 +
 net/smc/smc_cdc.c   |  9 +++++++--
 net/smc/smc_close.c | 39 +++++++++++++++++++++++++--------------
 net/smc/smc_close.h |  2 +-
 net/smc/smc_core.c  |  2 +-
 6 files changed, 41 insertions(+), 20 deletions(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 0938037..3b7eda6 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -451,6 +451,9 @@ static int smc_connect_rdma(struct smc_sock *smc)
 		goto decline_rdma_unlock;
 	}
 
+	smc_close_init(smc);
+	smc_rx_init(smc);
+
 	if (local_contact == SMC_FIRST_CONTACT) {
 		rc = smc_ib_ready_link(link);
 		if (rc) {
@@ -477,7 +480,6 @@ static int smc_connect_rdma(struct smc_sock *smc)
 
 	mutex_unlock(&smc_create_lgr_pending);
 	smc_tx_init(smc);
-	smc_rx_init(smc);
 
 out_connected:
 	smc_copy_sock_settings_to_clc(smc);
@@ -800,6 +802,9 @@ static void smc_listen_work(struct work_struct *work)
 		goto decline_rdma;
 	}
 
+	smc_close_init(new_smc);
+	smc_rx_init(new_smc);
+
 	rc = smc_clc_send_accept(new_smc, local_contact);
 	if (rc)
 		goto out_err;
@@ -839,7 +844,6 @@ static void smc_listen_work(struct work_struct *work)
 	}
 
 	smc_tx_init(new_smc);
-	smc_rx_init(new_smc);
 
 out_connected:
 	sk_refcnt_debug_inc(newsmcsk);
diff --git a/net/smc/smc.h b/net/smc/smc.h
index ee5fbea..6e44313e 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -164,6 +164,7 @@ struct smc_connection {
 #ifndef KERNEL_HAS_ATOMIC64
 	spinlock_t		acurs_lock;	/* protect cursors */
 #endif
+	struct work_struct	close_work;	/* peer sent some closing */
 };
 
 struct smc_sock {				/* smc sock container */
diff --git a/net/smc/smc_cdc.c b/net/smc/smc_cdc.c
index 4c9c2f6..a7294ed 100644
--- a/net/smc/smc_cdc.c
+++ b/net/smc/smc_cdc.c
@@ -217,8 +217,13 @@ static void smc_cdc_msg_recv_action(struct smc_sock *smc,
 		smc->sk.sk_err = ECONNRESET;
 		conn->local_tx_ctrl.conn_state_flags.peer_conn_abort = 1;
 	}
-	if (smc_cdc_rxed_any_close_or_senddone(conn))
-		smc_close_passive_received(smc);
+	if (smc_cdc_rxed_any_close_or_senddone(conn)) {
+		smc->sk.sk_shutdown |= RCV_SHUTDOWN;
+		if (smc->clcsock && smc->clcsock->sk)
+			smc->clcsock->sk->sk_shutdown |= RCV_SHUTDOWN;
+		sock_set_flag(&smc->sk, SOCK_DONE);
+		schedule_work(&conn->close_work);
+	}
 
 	/* piggy backed tx info */
 	/* trigger sndbuf consumer: RDMA write into peer RMBE and CDC */
diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index 67a71d1..388503b 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -117,7 +117,6 @@ void smc_close_active_abort(struct smc_sock *smc)
 	struct smc_cdc_conn_state_flags *txflags =
 		&smc->conn.local_tx_ctrl.conn_state_flags;
 
-	bh_lock_sock(&smc->sk);
 	smc->sk.sk_err = ECONNABORTED;
 	if (smc->clcsock && smc->clcsock->sk) {
 		smc->clcsock->sk->sk_err = ECONNABORTED;
@@ -125,6 +124,7 @@ void smc_close_active_abort(struct smc_sock *smc)
 	}
 	switch (smc->sk.sk_state) {
 	case SMC_INIT:
+	case SMC_ACTIVE:
 		smc->sk.sk_state = SMC_PEERABORTWAIT;
 		break;
 	case SMC_APPCLOSEWAIT1:
@@ -161,7 +161,6 @@ void smc_close_active_abort(struct smc_sock *smc)
 	}
 
 	sock_set_flag(&smc->sk, SOCK_DEAD);
-	bh_unlock_sock(&smc->sk);
 	smc->sk.sk_state_change(&smc->sk);
 }
 
@@ -185,7 +184,7 @@ int smc_close_active(struct smc_sock *smc)
 	case SMC_INIT:
 		sk->sk_state = SMC_CLOSED;
 		if (smc->smc_listen_work.func)
-			flush_work(&smc->smc_listen_work);
+			cancel_work_sync(&smc->smc_listen_work);
 		sock_put(sk);
 		break;
 	case SMC_LISTEN:
@@ -198,7 +197,7 @@ int smc_close_active(struct smc_sock *smc)
 		}
 		release_sock(sk);
 		smc_close_cleanup_listen(sk);
-		flush_work(&smc->tcp_listen_work);
+		cancel_work_sync(&smc->smc_listen_work);
 		lock_sock(sk);
 		break;
 	case SMC_ACTIVE:
@@ -306,22 +305,27 @@ static void smc_close_passive_abort_received(struct smc_sock *smc)
 
 /* Some kind of closing has been received: peer_conn_closed, peer_conn_abort,
  * or peer_done_writing.
- * Called under tasklet context.
  */
-void smc_close_passive_received(struct smc_sock *smc)
+static void smc_close_passive_work(struct work_struct *work)
 {
-	struct smc_cdc_conn_state_flags *rxflags =
-		&smc->conn.local_rx_ctrl.conn_state_flags;
+	struct smc_connection *conn = container_of(work,
+						   struct smc_connection,
+						   close_work);
+	struct smc_sock *smc = container_of(conn, struct smc_sock, conn);
+	struct smc_cdc_conn_state_flags *rxflags;
 	struct sock *sk = &smc->sk;
 	int old_state;
 
-	sk->sk_shutdown |= RCV_SHUTDOWN;
-	if (smc->clcsock && smc->clcsock->sk)
-		smc->clcsock->sk->sk_shutdown |= RCV_SHUTDOWN;
-	sock_set_flag(&smc->sk, SOCK_DONE);
-
+	lock_sock(&smc->sk);
 	old_state = sk->sk_state;
 
+	if (!conn->alert_token_local) {
+		/* abnormal termination */
+		smc_close_active_abort(smc);
+		goto wakeup;
+	}
+
+	rxflags = &smc->conn.local_rx_ctrl.conn_state_flags;
 	if (rxflags->peer_conn_abort) {
 		smc_close_passive_abort_received(smc);
 		goto wakeup;
@@ -373,11 +377,12 @@ void smc_close_passive_received(struct smc_sock *smc)
 	sk->sk_write_space(sk); /* wakeup blocked sndbuf producers */
 
 	if ((sk->sk_state == SMC_CLOSED) &&
-	    (sock_flag(sk, SOCK_DEAD) || (old_state == SMC_INIT))) {
+	    (sock_flag(sk, SOCK_DEAD) || !sk->sk_socket)) {
 		smc_conn_free(&smc->conn);
 		schedule_delayed_work(&smc->sock_put_work,
 				      SMC_CLOSE_SOCK_PUT_DELAY);
 	}
+	release_sock(&smc->sk);
 }
 
 void smc_close_sock_put_work(struct work_struct *work)
@@ -442,3 +447,9 @@ int smc_close_shutdown_write(struct smc_sock *smc)
 		sk->sk_state_change(&smc->sk);
 	return rc;
 }
+
+/* Initialize close properties on connection establishment. */
+void smc_close_init(struct smc_sock *smc)
+{
+	INIT_WORK(&smc->conn.close_work, smc_close_passive_work);
+}
diff --git a/net/smc/smc_close.h b/net/smc/smc_close.h
index bc9a2df..4a3d99a 100644
--- a/net/smc/smc_close.h
+++ b/net/smc/smc_close.h
@@ -21,8 +21,8 @@
 void smc_close_wake_tx_prepared(struct smc_sock *smc);
 void smc_close_active_abort(struct smc_sock *smc);
 int smc_close_active(struct smc_sock *smc);
-void smc_close_passive_received(struct smc_sock *smc);
 void smc_close_sock_put_work(struct work_struct *work);
 int smc_close_shutdown_write(struct smc_sock *smc);
+void smc_close_init(struct smc_sock *smc);
 
 #endif /* SMC_CLOSE_H */
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 0eac633..65020e9 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -316,7 +316,7 @@ void smc_lgr_terminate(struct smc_link_group *lgr)
 		smc = container_of(conn, struct smc_sock, conn);
 		sock_hold(&smc->sk);
 		__smc_lgr_unregister_conn(conn);
-		smc_close_active_abort(smc);
+		schedule_work(&conn->close_work);
 		sock_put(&smc->sk);
 		node = rb_first(&lgr->conns_all);
 	}
-- 
2.10.2
