From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/10] net/smc: guarantee ConnClosed send after shutdown SHUT_WR
Date: Mon, 10 Apr 2017 14:58:02 +0200
Message-ID: <20170410125805.13653-8-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34190 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753386AbdDJM6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:23 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACsGQ2144056
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:23 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r5s5mjrk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:22 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:19 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

State SMC_CLOSED should be reached only, if ConnClosed has been sent to
the peer. If ConnClosed is received from the peer, a socket with
shutdown SHUT_WR done, switches errorneously to state SMC_CLOSED, which
means the peer socket is dangling. The local SMC socket is supposed to
switch to state APPFINCLOSEWAIT to make sure smc_close_final() is called
during socket close.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/smc_close.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index 388503b..9070720b 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -164,6 +164,12 @@ void smc_close_active_abort(struct smc_sock *smc)
 	smc->sk.sk_state_change(&smc->sk);
 }
 
+static inline bool smc_close_sent_any_close(struct smc_connection *conn)
+{
+	return conn->local_tx_ctrl.conn_state_flags.peer_conn_abort ||
+	       conn->local_tx_ctrl.conn_state_flags.peer_conn_closed;
+}
+
 int smc_close_active(struct smc_sock *smc)
 {
 	struct smc_cdc_conn_state_flags *txflags =
@@ -217,7 +223,7 @@ int smc_close_active(struct smc_sock *smc)
 	case SMC_APPFINCLOSEWAIT:
 		/* socket already shutdown wr or both (active close) */
 		if (txflags->peer_done_writing &&
-		    !txflags->peer_conn_closed) {
+		    !smc_close_sent_any_close(conn)) {
 			/* just shutdown wr done, send close request */
 			rc = smc_close_final(conn);
 		}
@@ -247,6 +253,13 @@ int smc_close_active(struct smc_sock *smc)
 		break;
 	case SMC_PEERCLOSEWAIT1:
 	case SMC_PEERCLOSEWAIT2:
+		if (txflags->peer_done_writing &&
+		    !smc_close_sent_any_close(conn)) {
+			/* just shutdown wr done, send close request */
+			rc = smc_close_final(conn);
+		}
+		/* peer sending PeerConnectionClosed will cause transition */
+		break;
 	case SMC_PEERFINCLOSEWAIT:
 		/* peer sending PeerConnectionClosed will cause transition */
 		break;
@@ -284,7 +297,7 @@ static void smc_close_passive_abort_received(struct smc_sock *smc)
 	case SMC_PEERCLOSEWAIT1:
 	case SMC_PEERCLOSEWAIT2:
 		if (txflags->peer_done_writing &&
-		    !txflags->peer_conn_closed) {
+		    !smc_close_sent_any_close(&smc->conn)) {
 			/* just shutdown, but not yet closed locally */
 			smc_close_abort(&smc->conn);
 			sk->sk_state = SMC_PROCESSABORT;
@@ -335,7 +348,7 @@ static void smc_close_passive_work(struct work_struct *work)
 	case SMC_INIT:
 		if (atomic_read(&smc->conn.bytes_to_rcv) ||
 		    (rxflags->peer_done_writing &&
-		     !rxflags->peer_conn_closed))
+		     !smc_cdc_rxed_any_close(conn)))
 			sk->sk_state = SMC_APPCLOSEWAIT1;
 		else
 			sk->sk_state = SMC_CLOSED;
@@ -352,7 +365,7 @@ static void smc_close_passive_work(struct work_struct *work)
 		if (!smc_cdc_rxed_any_close(&smc->conn))
 			break;
 		if (sock_flag(sk, SOCK_DEAD) &&
-		    (sk->sk_shutdown == SHUTDOWN_MASK)) {
+		    smc_close_sent_any_close(conn)) {
 			/* smc_release has already been called locally */
 			sk->sk_state = SMC_CLOSED;
 		} else {
@@ -371,16 +384,17 @@ static void smc_close_passive_work(struct work_struct *work)
 	}
 
 wakeup:
-	if (old_state != sk->sk_state)
-		sk->sk_state_change(sk);
 	sk->sk_data_ready(sk); /* wakeup blocked rcvbuf consumers */
 	sk->sk_write_space(sk); /* wakeup blocked sndbuf producers */
 
-	if ((sk->sk_state == SMC_CLOSED) &&
-	    (sock_flag(sk, SOCK_DEAD) || !sk->sk_socket)) {
-		smc_conn_free(&smc->conn);
-		schedule_delayed_work(&smc->sock_put_work,
-				      SMC_CLOSE_SOCK_PUT_DELAY);
+	if (old_state != sk->sk_state) {
+		sk->sk_state_change(sk);
+		if ((sk->sk_state == SMC_CLOSED) &&
+		    (sock_flag(sk, SOCK_DEAD) || !sk->sk_socket)) {
+			smc_conn_free(&smc->conn);
+			schedule_delayed_work(&smc->sock_put_work,
+					      SMC_CLOSE_SOCK_PUT_DELAY);
+		}
 	}
 	release_sock(&smc->sk);
 }
-- 
2.10.2
