From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] qeth: fix qeth_wait_for_threads() deadlock for OSN devices
Date: Tue, 02 Apr 2013 12:56:52 +0200
Message-ID: <20130402105707.222865335@de.ibm.com>
References: <20130402105650.056630101@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:38714 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761240Ab3DBK5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 06:57:12 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 2 Apr 2013 11:55:45 +0100
Content-Disposition: inline; filename=602-qeth-thread-deadlock.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Any recovery thread will deadlock when calling qeth_wait_for_threads(), most
notably when triggering a recovery on an OSN device.
This patch will store the recovery thread's task pointer on recovery
invocation and check in qeth_wait_for_threads() respectively to avoid
deadlocks.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    3 +++
 drivers/s390/net/qeth_core_main.c |   19 +++++++++++++++++++
 drivers/s390/net/qeth_l2_main.c   |    2 ++
 drivers/s390/net/qeth_l3_main.c   |    2 ++
 4 files changed, 26 insertions(+)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -769,6 +769,7 @@ struct qeth_card {
 	unsigned long thread_start_mask;
 	unsigned long thread_allowed_mask;
 	unsigned long thread_running_mask;
+	struct task_struct *recovery_task;
 	spinlock_t ip_lock;
 	struct list_head ip_list;
 	struct list_head *ip_tbd_list;
@@ -862,6 +863,8 @@ extern struct qeth_card_list_struct qeth
 extern struct kmem_cache *qeth_core_header_cache;
 extern struct qeth_dbf_info qeth_dbf[QETH_DBF_INFOS];
 
+void qeth_set_recovery_task(struct qeth_card *);
+void qeth_clear_recovery_task(struct qeth_card *);
 void qeth_set_allowed_threads(struct qeth_card *, unsigned long , int);
 int qeth_threads_running(struct qeth_card *, unsigned long);
 int qeth_wait_for_threads(struct qeth_card *, unsigned long);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -177,6 +177,23 @@ const char *qeth_get_cardname_short(stru
 	return "n/a";
 }
 
+void qeth_set_recovery_task(struct qeth_card *card)
+{
+	card->recovery_task = current;
+}
+EXPORT_SYMBOL_GPL(qeth_set_recovery_task);
+
+void qeth_clear_recovery_task(struct qeth_card *card)
+{
+	card->recovery_task = NULL;
+}
+EXPORT_SYMBOL_GPL(qeth_clear_recovery_task);
+
+static bool qeth_is_recovery_task(struct qeth_card *card)
+{
+	return (card->recovery_task == current);
+}
+
 void qeth_set_allowed_threads(struct qeth_card *card, unsigned long threads,
 			 int clear_start_mask)
 {
@@ -205,6 +222,8 @@ EXPORT_SYMBOL_GPL(qeth_threads_running);
 
 int qeth_wait_for_threads(struct qeth_card *card, unsigned long threads)
 {
+	if (qeth_is_recovery_task(card))
+		return 0;
 	return wait_event_interruptible(card->wait_q,
 			qeth_threads_running(card, threads) == 0);
 }
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1143,6 +1143,7 @@ static int qeth_l2_recover(void *ptr)
 	QETH_CARD_TEXT(card, 2, "recover2");
 	dev_warn(&card->gdev->dev,
 		"A recovery process has been started for the device\n");
+	qeth_set_recovery_task(card);
 	__qeth_l2_set_offline(card->gdev, 1);
 	rc = __qeth_l2_set_online(card->gdev, 1);
 	if (!rc)
@@ -1153,6 +1154,7 @@ static int qeth_l2_recover(void *ptr)
 		dev_warn(&card->gdev->dev, "The qeth device driver "
 				"failed to recover an error on the device\n");
 	}
+	qeth_clear_recovery_task(card);
 	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
 	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
 	return 0;
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3515,6 +3515,7 @@ static int qeth_l3_recover(void *ptr)
 	QETH_CARD_TEXT(card, 2, "recover2");
 	dev_warn(&card->gdev->dev,
 		"A recovery process has been started for the device\n");
+	qeth_set_recovery_task(card);
 	__qeth_l3_set_offline(card->gdev, 1);
 	rc = __qeth_l3_set_online(card->gdev, 1);
 	if (!rc)
@@ -3525,6 +3526,7 @@ static int qeth_l3_recover(void *ptr)
 		dev_warn(&card->gdev->dev, "The qeth device driver "
 				"failed to recover an error on the device\n");
 	}
+	qeth_clear_recovery_task(card);
 	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
 	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
 	return 0;
