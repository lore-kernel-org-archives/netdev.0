From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] [PATCH] qeth: Recognize return codes of ccw_device_set_online
Date: Thu, 12 Nov 2009 11:11:43 +0100
Message-ID: <20091112101300.996534000@de.ibm.com>
References: <20091112101140.882313000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:60260 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbZKLKM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 05:12:56 -0500
Content-Disposition: inline; filename=608-qeth-set_online-rc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Setting a qeth device online requires to call function
ccw_device_set_online() for read-, write-, and data-subchannel.
Failures should be detected immediately without an attempt to
invoke follow-on activity qeth_qdio_clear_card().,

In addition, ccw_device_set_online calls are consolidated in
qeth_core_main.c only.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   26 ++++++++++++++++----------
 drivers/s390/net/qeth_l2_main.c   |   26 ++++++++------------------
 drivers/s390/net/qeth_l3_main.c   |   25 +++++++------------------
 3 files changed, 31 insertions(+), 46 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core_main.c
+++ git_net-next/drivers/s390/net/qeth_core_main.c
@@ -3883,30 +3883,36 @@ static int qeth_core_driver_group(const 
 int qeth_core_hardsetup_card(struct qeth_card *card)
 {
 	struct qdio_ssqd_desc *ssqd;
-	int retries = 3;
+	int retries = 0;
 	int mpno = 0;
 	int rc;
 
 	QETH_DBF_TEXT(SETUP, 2, "hrdsetup");
 	atomic_set(&card->force_alloc_skb, 0);
 retry:
-	if (retries < 3) {
+	if (retries)
 		QETH_DBF_MESSAGE(2, "%s Retrying to do IDX activates.\n",
 			dev_name(&card->gdev->dev));
-		ccw_device_set_offline(CARD_DDEV(card));
-		ccw_device_set_offline(CARD_WDEV(card));
-		ccw_device_set_offline(CARD_RDEV(card));
-		ccw_device_set_online(CARD_RDEV(card));
-		ccw_device_set_online(CARD_WDEV(card));
-		ccw_device_set_online(CARD_DDEV(card));
-	}
+	ccw_device_set_offline(CARD_DDEV(card));
+	ccw_device_set_offline(CARD_WDEV(card));
+	ccw_device_set_offline(CARD_RDEV(card));
+	rc = ccw_device_set_online(CARD_RDEV(card));
+	if (rc)
+		goto retriable;
+	rc = ccw_device_set_online(CARD_WDEV(card));
+	if (rc)
+		goto retriable;
+	rc = ccw_device_set_online(CARD_DDEV(card));
+	if (rc)
+		goto retriable;
 	rc = qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
+retriable:
 	if (rc == -ERESTARTSYS) {
 		QETH_DBF_TEXT(SETUP, 2, "break1");
 		return rc;
 	} else if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		if (--retries < 0)
+		if (++retries > 3)
 			goto out;
 		else
 			goto retry;
Index: git_net-next/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l2_main.c
+++ git_net-next/drivers/s390/net/qeth_l2_main.c
@@ -940,30 +940,17 @@ static int __qeth_l2_set_online(struct c
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
 	recover_flag = card->state;
-	rc = ccw_device_set_online(CARD_RDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		return -EIO;
-	}
-	rc = ccw_device_set_online(CARD_WDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		return -EIO;
-	}
-	rc = ccw_device_set_online(CARD_DDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		return -EIO;
-	}
-
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
+		rc = -ENODEV;
 		goto out_remove;
 	}
 
-	if (!card->dev && qeth_l2_setup_netdev(card))
+	if (!card->dev && qeth_l2_setup_netdev(card)) {
+		rc = -ENODEV;
 		goto out_remove;
+	}
 
 	if (card->info.type != QETH_CARD_TYPE_OSN)
 		qeth_l2_send_setmac(card, &card->dev->dev_addr[0]);
@@ -983,6 +970,7 @@ static int __qeth_l2_set_online(struct c
 			card->lan_online = 0;
 			return 0;
 		}
+		rc = -ENODEV;
 		goto out_remove;
 	} else
 		card->lan_online = 1;
@@ -999,6 +987,7 @@ static int __qeth_l2_set_online(struct c
 	rc = qeth_init_qdio_queues(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
+		rc = -ENODEV;
 		goto out_remove;
 	}
 	card->state = CARD_STATE_SOFTSETUP;
@@ -1020,6 +1009,7 @@ static int __qeth_l2_set_online(struct c
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
 	return 0;
+
 out_remove:
 	card->use_hard_stop = 1;
 	qeth_l2_stop_card(card, 0);
@@ -1030,7 +1020,7 @@ out_remove:
 		card->state = CARD_STATE_RECOVER;
 	else
 		card->state = CARD_STATE_DOWN;
-	return -ENODEV;
+	return rc;
 }
 
 static int qeth_l2_set_online(struct ccwgroup_device *gdev)
Index: git_net-next/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_main.c
+++ git_net-next/drivers/s390/net/qeth_l3_main.c
@@ -3156,32 +3156,19 @@ static int __qeth_l3_set_online(struct c
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
 
 	recover_flag = card->state;
-	rc = ccw_device_set_online(CARD_RDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		return -EIO;
-	}
-	rc = ccw_device_set_online(CARD_WDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		return -EIO;
-	}
-	rc = ccw_device_set_online(CARD_DDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		return -EIO;
-	}
-
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
+		rc = -ENODEV;
 		goto out_remove;
 	}
 
 	qeth_l3_query_ipassists(card, QETH_PROT_IPV4);
 
-	if (!card->dev && qeth_l3_setup_netdev(card))
+	if (!card->dev && qeth_l3_setup_netdev(card)) {
+		rc = -ENODEV;
 		goto out_remove;
+	}
 
 	card->state = CARD_STATE_HARDSETUP;
 	qeth_print_status_message(card);
@@ -3198,6 +3185,7 @@ static int __qeth_l3_set_online(struct c
 			card->lan_online = 0;
 			return 0;
 		}
+		rc = -ENODEV;
 		goto out_remove;
 	} else
 		card->lan_online = 1;
@@ -3220,6 +3208,7 @@ static int __qeth_l3_set_online(struct c
 	rc = qeth_init_qdio_queues(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
+		rc = -ENODEV;
 		goto out_remove;
 	}
 	card->state = CARD_STATE_SOFTSETUP;
@@ -3250,7 +3239,7 @@ out_remove:
 		card->state = CARD_STATE_RECOVER;
 	else
 		card->state = CARD_STATE_DOWN;
-	return -ENODEV;
+	return rc;
 }
 
 static int qeth_l3_set_online(struct ccwgroup_device *gdev)

