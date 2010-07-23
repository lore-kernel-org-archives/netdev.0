From: frank.blaschka@de.ibm.com
Subject: [patch 3/8] [PATCH] qeth: serialize sysfs-triggered device configurations
Date: Fri, 23 Jul 2010 11:15:05 +0200
Message-ID: <20100723091550.006465000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:47428 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=614-qeth-serialize-sysfs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

This patch serializes device removal and other sysfs-triggered
configurations by moving removal of sysfs-attributes to the beginning
of the remove functions. And it serializes online/offline setting
and discipline-switching (causing reestablishing of the net_device)
by making use of a new discipline mutex.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 +
 drivers/s390/net/qeth_core_main.c |   11 +++++++----
 drivers/s390/net/qeth_core_sys.c  |    4 ++--
 drivers/s390/net/qeth_l2_main.c   |    5 +++++
 drivers/s390/net/qeth_l3_main.c   |    8 +++++++-
 5 files changed, 22 insertions(+), 7 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-07-22 10:22:34.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-07-22 10:22:35.000000000 +0200
@@ -747,6 +747,7 @@ struct qeth_card {
 	struct qdio_ssqd_desc ssqd;
 	debug_info_t *debug;
 	struct mutex conf_mutex;
+	struct mutex discipline_mutex;
 };
 
 struct qeth_card_list_struct {
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:34.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:35.000000000 +0200
@@ -1084,6 +1084,7 @@ static int qeth_setup_card(struct qeth_c
 	spin_lock_init(&card->ip_lock);
 	spin_lock_init(&card->thread_mask_lock);
 	mutex_init(&card->conf_mutex);
+	mutex_init(&card->discipline_mutex);
 	card->thread_start_mask = 0;
 	card->thread_allowed_mask = 0;
 	card->thread_running_mask = 0;
@@ -4348,16 +4349,18 @@ static void qeth_core_remove_device(stru
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
 
 	QETH_DBF_TEXT(SETUP, 2, "removedv");
-	if (card->discipline.ccwgdriver) {
-		card->discipline.ccwgdriver->remove(gdev);
-		qeth_core_free_discipline(card);
-	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN) {
 		qeth_core_remove_osn_attributes(&gdev->dev);
 	} else {
 		qeth_core_remove_device_attributes(&gdev->dev);
 	}
+
+	if (card->discipline.ccwgdriver) {
+		card->discipline.ccwgdriver->remove(gdev);
+		qeth_core_free_discipline(card);
+	}
+
 	debug_unregister(card->debug);
 	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_del(&card->list);
diff -urpN linux-2.6/drivers/s390/net/qeth_core_sys.c linux-2.6-patched/drivers/s390/net/qeth_core_sys.c
--- linux-2.6/drivers/s390/net/qeth_core_sys.c	2010-07-22 10:22:35.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_sys.c	2010-07-22 10:22:35.000000000 +0200
@@ -411,7 +411,7 @@ static ssize_t qeth_dev_layer2_store(str
 	if (!card)
 		return -EINVAL;
 
-	mutex_lock(&card->conf_mutex);
+	mutex_lock(&card->discipline_mutex);
 	if (card->state != CARD_STATE_DOWN) {
 		rc = -EPERM;
 		goto out;
@@ -446,7 +446,7 @@ static ssize_t qeth_dev_layer2_store(str
 
 	rc = card->discipline.ccwgdriver->probe(card->gdev);
 out:
-	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return rc ? rc : count;
 }
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2010-07-22 10:22:33.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2010-07-22 10:22:35.000000000 +0200
@@ -935,6 +935,7 @@ static int __qeth_l2_set_online(struct c
 	enum qeth_card_states recover_flag;
 
 	BUG_ON(!card);
+	mutex_lock(&card->discipline_mutex);
 	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
@@ -1012,6 +1013,7 @@ static int __qeth_l2_set_online(struct c
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
 out:
 	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return 0;
 
 out_remove:
@@ -1025,6 +1027,7 @@ out_remove:
 	else
 		card->state = CARD_STATE_DOWN;
 	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return rc;
 }
 
@@ -1040,6 +1043,7 @@ static int __qeth_l2_set_offline(struct 
 	int rc = 0, rc2 = 0, rc3 = 0;
 	enum qeth_card_states recover_flag;
 
+	mutex_lock(&card->discipline_mutex);
 	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 3, "setoffl");
 	QETH_DBF_HEX(SETUP, 3, &card, sizeof(void *));
@@ -1060,6 +1064,7 @@ static int __qeth_l2_set_offline(struct 
 	/* let user_space know that device is offline */
 	kobject_uevent(&cgdev->dev.kobj, KOBJ_CHANGE);
 	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return 0;
 }
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2010-07-22 10:22:34.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2010-07-22 10:22:35.000000000 +0200
@@ -3354,6 +3354,8 @@ static void qeth_l3_remove_device(struct
 {
 	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
 
+	qeth_l3_remove_device_attributes(&cgdev->dev);
+
 	qeth_set_allowed_threads(card, 0, 1);
 	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
@@ -3367,7 +3369,6 @@ static void qeth_l3_remove_device(struct
 		card->dev = NULL;
 	}
 
-	qeth_l3_remove_device_attributes(&cgdev->dev);
 	qeth_l3_clear_ip_list(card, 0, 0);
 	qeth_l3_clear_ipato_list(card);
 	return;
@@ -3380,6 +3381,7 @@ static int __qeth_l3_set_online(struct c
 	enum qeth_card_states recover_flag;
 
 	BUG_ON(!card);
+	mutex_lock(&card->discipline_mutex);
 	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 2, "setonlin");
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
@@ -3461,6 +3463,7 @@ static int __qeth_l3_set_online(struct c
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
 out:
 	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return 0;
 out_remove:
 	card->use_hard_stop = 1;
@@ -3473,6 +3476,7 @@ out_remove:
 	else
 		card->state = CARD_STATE_DOWN;
 	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return rc;
 }
 
@@ -3488,6 +3492,7 @@ static int __qeth_l3_set_offline(struct 
 	int rc = 0, rc2 = 0, rc3 = 0;
 	enum qeth_card_states recover_flag;
 
+	mutex_lock(&card->discipline_mutex);
 	mutex_lock(&card->conf_mutex);
 	QETH_DBF_TEXT(SETUP, 3, "setoffl");
 	QETH_DBF_HEX(SETUP, 3, &card, sizeof(void *));
@@ -3508,6 +3513,7 @@ static int __qeth_l3_set_offline(struct 
 	/* let user_space know that device is offline */
 	kobject_uevent(&cgdev->dev.kobj, KOBJ_CHANGE);
 	mutex_unlock(&card->conf_mutex);
+	mutex_unlock(&card->discipline_mutex);
 	return 0;
 }
 

