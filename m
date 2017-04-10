From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/10] net/smc: guarantee reset of write_blocked for heavy workload
Date: Mon, 10 Apr 2017 14:57:59 +0200
Message-ID: <20170410125805.13653-5-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50209 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753340AbdDJM6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:18 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACsYqF051595
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:17 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r4f01qgg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:17 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:15 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If peer indicates write_blocked, the cursor state of the received data
should be send to the peer immediately (in smc_tx_consumer_update()).
Afterwards the write_blocked indicator is cleared.

If there is no free slot for another write request, sending is postponed
to worker smc_tx_work, and the write_blocked indicator is not cleared.
Therefore another clearing check is needed in smc_tx_work().

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/smc_tx.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
index 69a0013..21ec183 100644
--- a/net/smc/smc_tx.c
+++ b/net/smc/smc_tx.c
@@ -431,9 +431,13 @@ static void smc_tx_work(struct work_struct *work)
 						   struct smc_connection,
 						   tx_work);
 	struct smc_sock *smc = container_of(conn, struct smc_sock, conn);
+	int rc;
 
 	lock_sock(&smc->sk);
-	smc_tx_sndbuf_nonempty(conn);
+	rc = smc_tx_sndbuf_nonempty(conn);
+	if (!rc && conn->local_rx_ctrl.prod_flags.write_blocked &&
+	    !atomic_read(&conn->bytes_to_rcv))
+		conn->local_rx_ctrl.prod_flags.write_blocked = 0;
 	release_sock(&smc->sk);
 }
 
-- 
2.10.2
