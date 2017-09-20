From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/10] net/smc: terminate link group if out-of-sync is received
Date: Wed, 20 Sep 2017 13:58:10 +0200
Message-ID: <20170920115813.63745-8-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40974 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751933AbdITL6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:33 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBsaOg143252
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:33 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d3pkrvxcv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:33 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:31 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An out-of-sync condition can just be detected by the client.
If the server receives a CLC DECLINE message indicating an out-of-sync
condition for the link groups, the server must clean up the out-of-sync
link group.
There is no need for an extra third parameter in smc_clc_send_decline().

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/af_smc.c  |  6 ++----
 net/smc/smc_clc.c | 10 +++++-----
 net/smc/smc_clc.h |  3 +--
 3 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 2e8d2dabac0c..745f145d4c4d 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -513,7 +513,7 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	/* RDMA setup failed, switch back to TCP */
 	smc->use_fallback = true;
 	if (reason_code && (reason_code != SMC_CLC_DECL_REPLY)) {
-		rc = smc_clc_send_decline(smc, reason_code, 0);
+		rc = smc_clc_send_decline(smc, reason_code);
 		if (rc < sizeof(struct smc_clc_msg_decline))
 			goto out_err;
 	}
@@ -808,8 +808,6 @@ static void smc_listen_work(struct work_struct *work)
 		rc = local_contact;
 		if (rc == -ENOMEM)
 			reason_code = SMC_CLC_DECL_MEM;/* insufficient memory*/
-		else if (rc == -ENOLINK)
-			reason_code = SMC_CLC_DECL_SYNCERR; /* synchr. error */
 		goto decline_rdma;
 	}
 	link = &new_smc->conn.lgr->lnk[SMC_SINGLE_LINK];
@@ -903,7 +901,7 @@ static void smc_listen_work(struct work_struct *work)
 	smc_conn_free(&new_smc->conn);
 	new_smc->use_fallback = true;
 	if (reason_code && (reason_code != SMC_CLC_DECL_REPLY)) {
-		rc = smc_clc_send_decline(new_smc, reason_code, 0);
+		rc = smc_clc_send_decline(new_smc, reason_code);
 		if (rc < sizeof(struct smc_clc_msg_decline))
 			goto out_err;
 	}
diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
index 3934913ab835..b7dd2743fb5c 100644
--- a/net/smc/smc_clc.c
+++ b/net/smc/smc_clc.c
@@ -95,9 +95,10 @@ int smc_clc_wait_msg(struct smc_sock *smc, void *buf, int buflen,
 	}
 	if (clcm->type == SMC_CLC_DECLINE) {
 		reason_code = SMC_CLC_DECL_REPLY;
-		if (ntohl(((struct smc_clc_msg_decline *)buf)->peer_diagnosis)
-			== SMC_CLC_DECL_SYNCERR)
+		if (((struct smc_clc_msg_decline *)buf)->hdr.flag) {
 			smc->conn.lgr->sync_err = true;
+			smc_lgr_terminate(smc->conn.lgr);
+		}
 	}
 
 out:
@@ -105,8 +106,7 @@ int smc_clc_wait_msg(struct smc_sock *smc, void *buf, int buflen,
 }
 
 /* send CLC DECLINE message across internal TCP socket */
-int smc_clc_send_decline(struct smc_sock *smc, u32 peer_diag_info,
-			 u8 out_of_sync)
+int smc_clc_send_decline(struct smc_sock *smc, u32 peer_diag_info)
 {
 	struct smc_clc_msg_decline dclc;
 	struct msghdr msg;
@@ -118,7 +118,7 @@ int smc_clc_send_decline(struct smc_sock *smc, u32 peer_diag_info,
 	dclc.hdr.type = SMC_CLC_DECLINE;
 	dclc.hdr.length = htons(sizeof(struct smc_clc_msg_decline));
 	dclc.hdr.version = SMC_CLC_V1;
-	dclc.hdr.flag = out_of_sync ? 1 : 0;
+	dclc.hdr.flag = (peer_diag_info == SMC_CLC_DECL_SYNCERR) ? 1 : 0;
 	memcpy(dclc.id_for_peer, local_systemid, sizeof(local_systemid));
 	dclc.peer_diagnosis = htonl(peer_diag_info);
 	memcpy(dclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
diff --git a/net/smc/smc_clc.h b/net/smc/smc_clc.h
index 13db8ce177c9..1c55414041d4 100644
--- a/net/smc/smc_clc.h
+++ b/net/smc/smc_clc.h
@@ -106,8 +106,7 @@ struct smc_ib_device;
 
 int smc_clc_wait_msg(struct smc_sock *smc, void *buf, int buflen,
 		     u8 expected_type);
-int smc_clc_send_decline(struct smc_sock *smc, u32 peer_diag_info,
-			 u8 out_of_sync);
+int smc_clc_send_decline(struct smc_sock *smc, u32 peer_diag_info);
 int smc_clc_send_proposal(struct smc_sock *smc, struct smc_ib_device *smcibdev,
 			  u8 ibport);
 int smc_clc_send_confirm(struct smc_sock *smc);
-- 
2.13.5
