From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/1] net/smc: parameter cleanup in smc_cdc_get_free_slot()
Date: Thu, 21 Sep 2017 09:17:34 +0200
Message-ID: <20170921071734.16977-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46266 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751921AbdIUHRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:17:43 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8L7EBXj146033
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:17:43 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d4624q54t-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:17:42 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 21 Sep 2017 08:17:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the smc_connection as first parameter with smc_cdc_get_free_slot().
This is just a small code cleanup, no functional change.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_cdc.c | 7 ++++---
 net/smc/smc_cdc.h | 3 ++-
 net/smc/smc_tx.c  | 6 ++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/smc/smc_cdc.c b/net/smc/smc_cdc.c
index a7294edbc221..5ef97e5a5f78 100644
--- a/net/smc/smc_cdc.c
+++ b/net/smc/smc_cdc.c
@@ -62,10 +62,12 @@ static void smc_cdc_tx_handler(struct smc_wr_tx_pend_priv *pnd_snd,
 	bh_unlock_sock(&smc->sk);
 }
 
-int smc_cdc_get_free_slot(struct smc_link *link,
+int smc_cdc_get_free_slot(struct smc_connection *conn,
 			  struct smc_wr_buf **wr_buf,
 			  struct smc_cdc_tx_pend **pend)
 {
+	struct smc_link *link = &conn->lgr->lnk[SMC_SINGLE_LINK];
+
 	return smc_wr_tx_get_free_slot(link, smc_cdc_tx_handler, wr_buf,
 				       (struct smc_wr_tx_pend_priv **)pend);
 }
@@ -118,8 +120,7 @@ int smc_cdc_get_slot_and_msg_send(struct smc_connection *conn)
 	struct smc_wr_buf *wr_buf;
 	int rc;
 
-	rc = smc_cdc_get_free_slot(&conn->lgr->lnk[SMC_SINGLE_LINK], &wr_buf,
-				   &pend);
+	rc = smc_cdc_get_free_slot(conn, &wr_buf, &pend);
 	if (rc)
 		return rc;
 
diff --git a/net/smc/smc_cdc.h b/net/smc/smc_cdc.h
index 8e1d76f26007..56f883d1159c 100644
--- a/net/smc/smc_cdc.h
+++ b/net/smc/smc_cdc.h
@@ -206,7 +206,8 @@ static inline void smc_cdc_msg_to_host(struct smc_host_cdc_msg *local,
 
 struct smc_cdc_tx_pend;
 
-int smc_cdc_get_free_slot(struct smc_link *link, struct smc_wr_buf **wr_buf,
+int smc_cdc_get_free_slot(struct smc_connection *conn,
+			  struct smc_wr_buf **wr_buf,
 			  struct smc_cdc_tx_pend **pend);
 void smc_cdc_tx_dismiss_slots(struct smc_connection *conn);
 int smc_cdc_msg_send(struct smc_connection *conn, struct smc_wr_buf *wr_buf,
diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
index 3c656beb8820..e2228f6d1c25 100644
--- a/net/smc/smc_tx.c
+++ b/net/smc/smc_tx.c
@@ -394,8 +394,7 @@ int smc_tx_sndbuf_nonempty(struct smc_connection *conn)
 	int rc;
 
 	spin_lock_bh(&conn->send_lock);
-	rc = smc_cdc_get_free_slot(&conn->lgr->lnk[SMC_SINGLE_LINK], &wr_buf,
-				   &pend);
+	rc = smc_cdc_get_free_slot(conn, &wr_buf, &pend);
 	if (rc < 0) {
 		if (rc == -EBUSY) {
 			struct smc_sock *smc =
@@ -463,8 +462,7 @@ void smc_tx_consumer_update(struct smc_connection *conn)
 	    ((to_confirm > conn->rmbe_update_limit) &&
 	     ((to_confirm > (conn->rmbe_size / 2)) ||
 	      conn->local_rx_ctrl.prod_flags.write_blocked))) {
-		rc = smc_cdc_get_free_slot(&conn->lgr->lnk[SMC_SINGLE_LINK],
-					   &wr_buf, &pend);
+		rc = smc_cdc_get_free_slot(conn, &wr_buf, &pend);
 		if (!rc)
 			rc = smc_cdc_msg_send(conn, wr_buf, pend);
 		if (rc < 0) {
-- 
2.13.5
