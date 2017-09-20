From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/10] net/smc: no close wait in case of process shut down
Date: Wed, 20 Sep 2017 13:58:13 +0200
Message-ID: <20170920115813.63745-11-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59792 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751974AbdITL6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:43 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBvXP3090728
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:43 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d3p3gyhh6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:36 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:34 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually socket closing is delayed if there is still data available in
the send buffer to be transmitted. If a process is killed, the delay
should be avoided.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_close.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index 5201bc103bd8..f0d16fb825f7 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -174,15 +174,15 @@ int smc_close_active(struct smc_sock *smc)
 {
 	struct smc_cdc_conn_state_flags *txflags =
 		&smc->conn.local_tx_ctrl.conn_state_flags;
-	long timeout = SMC_MAX_STREAM_WAIT_TIMEOUT;
 	struct smc_connection *conn = &smc->conn;
 	struct sock *sk = &smc->sk;
 	int old_state;
+	long timeout;
 	int rc = 0;
 
-	if (sock_flag(sk, SOCK_LINGER) &&
-	    !(current->flags & PF_EXITING))
-		timeout = sk->sk_lingertime;
+	timeout = current->flags & PF_EXITING ?
+		  0 : sock_flag(sk, SOCK_LINGER) ?
+		      sk->sk_lingertime : SMC_MAX_STREAM_WAIT_TIMEOUT;
 
 again:
 	old_state = sk->sk_state;
@@ -413,13 +413,14 @@ void smc_close_sock_put_work(struct work_struct *work)
 int smc_close_shutdown_write(struct smc_sock *smc)
 {
 	struct smc_connection *conn = &smc->conn;
-	long timeout = SMC_MAX_STREAM_WAIT_TIMEOUT;
 	struct sock *sk = &smc->sk;
 	int old_state;
+	long timeout;
 	int rc = 0;
 
-	if (sock_flag(sk, SOCK_LINGER))
-		timeout = sk->sk_lingertime;
+	timeout = current->flags & PF_EXITING ?
+		  0 : sock_flag(sk, SOCK_LINGER) ?
+		      sk->sk_lingertime : SMC_MAX_STREAM_WAIT_TIMEOUT;
 
 again:
 	old_state = sk->sk_state;
-- 
2.13.5
