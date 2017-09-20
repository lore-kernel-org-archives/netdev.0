From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/10] net/smc: introduce a delay
Date: Wed, 20 Sep 2017 13:58:11 +0200
Message-ID: <20170920115813.63745-9-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34876 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751952AbdITL6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:36 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBsYG8028357
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:36 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2d3q46b42e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:35 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:34 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of outstanding work requests is limited. If all work
requests are in use, tx processing is postponed to another scheduling
of the tx worker. Switch to a delayed worker to have a gap for tx
completion queue events before the next retry.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc.h       |  2 +-
 net/smc/smc_close.c | 12 +++++++-----
 net/smc/smc_tx.c    | 12 ++++++++----
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/smc/smc.h b/net/smc/smc.h
index 6e44313e4467..0ccd6fa387ad 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -149,7 +149,7 @@ struct smc_connection {
 	atomic_t		sndbuf_space;	/* remaining space in sndbuf */
 	u16			tx_cdc_seq;	/* sequence # for CDC send */
 	spinlock_t		send_lock;	/* protect wr_sends */
-	struct work_struct	tx_work;	/* retry of smc_cdc_msg_send */
+	struct delayed_work	tx_work;	/* retry of smc_cdc_msg_send */
 
 	struct smc_host_cdc_msg	local_rx_ctrl;	/* filled during event_handl.
 						 * .prod cf. TCP rcv_nxt
diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index 3c2e166b5d22..5201bc103bd8 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -208,7 +208,7 @@ int smc_close_active(struct smc_sock *smc)
 	case SMC_ACTIVE:
 		smc_close_stream_wait(smc, timeout);
 		release_sock(sk);
-		cancel_work_sync(&conn->tx_work);
+		cancel_delayed_work_sync(&conn->tx_work);
 		lock_sock(sk);
 		if (sk->sk_state == SMC_ACTIVE) {
 			/* send close request */
@@ -234,7 +234,7 @@ int smc_close_active(struct smc_sock *smc)
 		if (!smc_cdc_rxed_any_close(conn))
 			smc_close_stream_wait(smc, timeout);
 		release_sock(sk);
-		cancel_work_sync(&conn->tx_work);
+		cancel_delayed_work_sync(&conn->tx_work);
 		lock_sock(sk);
 		if (sk->sk_err != ECONNABORTED) {
 			/* confirm close from peer */
@@ -263,7 +263,9 @@ int smc_close_active(struct smc_sock *smc)
 		/* peer sending PeerConnectionClosed will cause transition */
 		break;
 	case SMC_PROCESSABORT:
-		cancel_work_sync(&conn->tx_work);
+		release_sock(sk);
+		cancel_delayed_work_sync(&conn->tx_work);
+		lock_sock(sk);
 		smc_close_abort(conn);
 		sk->sk_state = SMC_CLOSED;
 		smc_close_wait_tx_pends(smc);
@@ -425,7 +427,7 @@ int smc_close_shutdown_write(struct smc_sock *smc)
 	case SMC_ACTIVE:
 		smc_close_stream_wait(smc, timeout);
 		release_sock(sk);
-		cancel_work_sync(&conn->tx_work);
+		cancel_delayed_work_sync(&conn->tx_work);
 		lock_sock(sk);
 		/* send close wr request */
 		rc = smc_close_wr(conn);
@@ -439,7 +441,7 @@ int smc_close_shutdown_write(struct smc_sock *smc)
 		if (!smc_cdc_rxed_any_close(conn))
 			smc_close_stream_wait(smc, timeout);
 		release_sock(sk);
-		cancel_work_sync(&conn->tx_work);
+		cancel_delayed_work_sync(&conn->tx_work);
 		lock_sock(sk);
 		/* confirm close from peer */
 		rc = smc_close_wr(conn);
diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
index 3c656beb8820..3866573288dd 100644
--- a/net/smc/smc_tx.c
+++ b/net/smc/smc_tx.c
@@ -24,6 +24,8 @@
 #include "smc_cdc.h"
 #include "smc_tx.h"
 
+#define SMC_TX_WORK_DELAY	HZ
+
 /***************************** sndbuf producer *******************************/
 
 /* callback implementation for sk.sk_write_space()
@@ -406,7 +408,8 @@ int smc_tx_sndbuf_nonempty(struct smc_connection *conn)
 				goto out_unlock;
 			}
 			rc = 0;
-			schedule_work(&conn->tx_work);
+			schedule_delayed_work(&conn->tx_work,
+					      SMC_TX_WORK_DELAY);
 		}
 		goto out_unlock;
 	}
@@ -430,7 +433,7 @@ int smc_tx_sndbuf_nonempty(struct smc_connection *conn)
  */
 static void smc_tx_work(struct work_struct *work)
 {
-	struct smc_connection *conn = container_of(work,
+	struct smc_connection *conn = container_of(to_delayed_work(work),
 						   struct smc_connection,
 						   tx_work);
 	struct smc_sock *smc = container_of(conn, struct smc_sock, conn);
@@ -468,7 +471,8 @@ void smc_tx_consumer_update(struct smc_connection *conn)
 		if (!rc)
 			rc = smc_cdc_msg_send(conn, wr_buf, pend);
 		if (rc < 0) {
-			schedule_work(&conn->tx_work);
+			schedule_delayed_work(&conn->tx_work,
+					      SMC_TX_WORK_DELAY);
 			return;
 		}
 		smc_curs_write(&conn->rx_curs_confirmed,
@@ -487,6 +491,6 @@ void smc_tx_consumer_update(struct smc_connection *conn)
 void smc_tx_init(struct smc_sock *smc)
 {
 	smc->sk.sk_write_space = smc_tx_write_space;
-	INIT_WORK(&smc->conn.tx_work, smc_tx_work);
+	INIT_DELAYED_WORK(&smc->conn.tx_work, smc_tx_work);
 	spin_lock_init(&smc->conn.send_lock);
 }
-- 
2.13.5
