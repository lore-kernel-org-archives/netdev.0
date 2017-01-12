From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 11/12] s390/qeth: issue STARTLAN as first IPA command
Date: Thu, 12 Jan 2017 15:48:42 +0100
Message-ID: <20170112144843.33463-12-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40410 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750803AbdALOtH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:07 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmmJr019223
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:06 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27xb1ct98k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:06 -0500
Received: from localhost
        by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:49:04 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

STARTLAN needs to be the first IPA command after MPC initialization
completes.
So move the qeth_send_startlan() call from the layer disciplines
into the core path, right after the MPC handshake.
While at it, replace the magic LAN OFFLINE return code
with the existing enum.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  1 -
 drivers/s390/net/qeth_core_main.c | 21 +++++++++++++++++----
 drivers/s390/net/qeth_l2_main.c   | 15 ---------------
 drivers/s390/net/qeth_l3_main.c   | 15 ---------------
 4 files changed, 17 insertions(+), 35 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 774ae51..e7addea 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -913,7 +913,6 @@ void qeth_clear_thread_running_bit(struct qeth_card *, unsigned long);
 int qeth_core_hardsetup_card(struct qeth_card *);
 void qeth_print_status_message(struct qeth_card *);
 int qeth_init_qdio_queues(struct qeth_card *);
-int qeth_send_startlan(struct qeth_card *);
 int qeth_send_ipa_cmd(struct qeth_card *, struct qeth_cmd_buffer *,
 		  int (*reply_cb)
 		  (struct qeth_card *, struct qeth_reply *, unsigned long),
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index ca8309f..315d8a2 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2944,7 +2944,7 @@ int qeth_send_ipa_cmd(struct qeth_card *card, struct qeth_cmd_buffer *iob,
 }
 EXPORT_SYMBOL_GPL(qeth_send_ipa_cmd);
 
-int qeth_send_startlan(struct qeth_card *card)
+static int qeth_send_startlan(struct qeth_card *card)
 {
 	int rc;
 	struct qeth_cmd_buffer *iob;
@@ -2957,7 +2957,6 @@ int qeth_send_startlan(struct qeth_card *card)
 	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
 	return rc;
 }
-EXPORT_SYMBOL_GPL(qeth_send_startlan);
 
 static int qeth_default_setadapterparms_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
@@ -5087,6 +5086,20 @@ int qeth_core_hardsetup_card(struct qeth_card *card)
 		goto out;
 	}
 
+	rc = qeth_send_startlan(card);
+	if (rc) {
+		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
+		if (rc == IPA_RC_LAN_OFFLINE) {
+			dev_warn(&card->gdev->dev,
+				"The LAN is offline\n");
+			card->lan_online = 0;
+		} else {
+			rc = -ENODEV;
+			goto out;
+		}
+	} else
+		card->lan_online = 1;
+
 	card->options.ipa4.supported_funcs = 0;
 	card->options.ipa6.supported_funcs = 0;
 	card->options.adp.supported_funcs = 0;
@@ -5098,14 +5111,14 @@ int qeth_core_hardsetup_card(struct qeth_card *card)
 	if (qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
 		rc = qeth_query_setadapterparms(card);
 		if (rc < 0) {
-			QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "7err%d", rc);
 			goto out;
 		}
 	}
 	if (qeth_adp_supported(card, IPA_SETADP_SET_DIAG_ASSIST)) {
 		rc = qeth_query_setdiagass(card);
 		if (rc < 0) {
-			QETH_DBF_TEXT_(SETUP, 2, "7err%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "8err%d", rc);
 			goto out;
 		}
 	}
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index c298759c..bea4833 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1177,21 +1177,6 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	/* softsetup */
 	QETH_DBF_TEXT(SETUP, 2, "softsetp");
 
-	rc = qeth_send_startlan(card);
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		if (rc == 0xe080) {
-			dev_warn(&card->gdev->dev,
-				"The LAN is offline\n");
-			card->lan_online = 0;
-			goto contin;
-		}
-		rc = -ENODEV;
-		goto out_remove;
-	} else
-		card->lan_online = 1;
-
-contin:
 	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
 	    (card->info.type == QETH_CARD_TYPE_OSX)) {
 		rc = qeth_l2_start_ipassists(card);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index ac37d05..06d0add 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3227,21 +3227,6 @@ static int __qeth_l3_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	/* softsetup */
 	QETH_DBF_TEXT(SETUP, 2, "softsetp");
 
-	rc = qeth_send_startlan(card);
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		if (rc == 0xe080) {
-			dev_warn(&card->gdev->dev,
-				"The LAN is offline\n");
-			card->lan_online = 0;
-			goto contin;
-		}
-		rc = -ENODEV;
-		goto out_remove;
-	} else
-		card->lan_online = 1;
-
-contin:
 	rc = qeth_l3_setadapter_parms(card);
 	if (rc)
 		QETH_DBF_TEXT_(SETUP, 2, "2err%04x", rc);
-- 
2.8.4
