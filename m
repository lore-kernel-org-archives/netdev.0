From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/10] s390/qeth: move gdev shutdown handler to core
Date: Tue, 11 Apr 2017 16:11:12 +0200
Message-ID: <20170411141119.82526-4-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33688 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753262AbdDKOLj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:39 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8wMl025454
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:39 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29ru2t0beq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:38 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:37 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Duplicated code.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  1 -
 drivers/s390/net/qeth_core_main.c |  8 ++++++--
 drivers/s390/net/qeth_l2_main.c   | 12 ------------
 drivers/s390/net/qeth_l3_main.c   | 12 ------------
 4 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 196356e11077..cc1a4baeba55 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -711,7 +711,6 @@ struct qeth_discipline {
 	void (*remove) (struct ccwgroup_device *);
 	int (*set_online) (struct ccwgroup_device *);
 	int (*set_offline) (struct ccwgroup_device *);
-	void (*shutdown)(struct ccwgroup_device *);
 	int (*prepare) (struct ccwgroup_device *);
 	void (*complete) (struct ccwgroup_device *);
 	int (*freeze)(struct ccwgroup_device *);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index b9063eb17436..cf5493e525e8 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5749,8 +5749,12 @@ static int qeth_core_set_offline(struct ccwgroup_device *gdev)
 static void qeth_core_shutdown(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
-	if (card->discipline && card->discipline->shutdown)
-		card->discipline->shutdown(gdev);
+	qeth_set_allowed_threads(card, 0, 1);
+	if ((gdev->state == CCWGROUP_ONLINE) && card->info.hwtrap)
+		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
+	qeth_qdio_clear_card(card, 0);
+	qeth_clear_qdio_buffers(card);
+	qdio_free(CARD_DDEV(card));
 }
 
 static int qeth_core_prepare(struct ccwgroup_device *gdev)
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 572347d65c1d..2ad378b57f9f 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1200,17 +1200,6 @@ static void __exit qeth_l2_exit(void)
 	pr_info("unregister layer 2 discipline\n");
 }
 
-static void qeth_l2_shutdown(struct ccwgroup_device *gdev)
-{
-	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
-	qeth_set_allowed_threads(card, 0, 1);
-	if ((gdev->state == CCWGROUP_ONLINE) && card->info.hwtrap)
-		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
-	qeth_qdio_clear_card(card, 0);
-	qeth_clear_qdio_buffers(card);
-	qdio_free(CARD_DDEV(card));
-}
-
 static int qeth_l2_pm_suspend(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
@@ -1288,7 +1277,6 @@ struct qeth_discipline qeth_l2_discipline = {
 	.remove = qeth_l2_remove_device,
 	.set_online = qeth_l2_set_online,
 	.set_offline = qeth_l2_set_offline,
-	.shutdown = qeth_l2_shutdown,
 	.freeze = qeth_l2_pm_suspend,
 	.thaw = qeth_l2_pm_resume,
 	.restore = qeth_l2_pm_resume,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index bd6ad9be9245..ca21a2065a5d 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3251,17 +3251,6 @@ static int qeth_l3_recover(void *ptr)
 	return 0;
 }
 
-static void qeth_l3_shutdown(struct ccwgroup_device *gdev)
-{
-	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
-	qeth_set_allowed_threads(card, 0, 1);
-	if ((gdev->state == CCWGROUP_ONLINE) && card->info.hwtrap)
-		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
-	qeth_qdio_clear_card(card, 0);
-	qeth_clear_qdio_buffers(card);
-	qdio_free(CARD_DDEV(card));
-}
-
 static int qeth_l3_pm_suspend(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
@@ -3325,7 +3314,6 @@ struct qeth_discipline qeth_l3_discipline = {
 	.remove = qeth_l3_remove_device,
 	.set_online = qeth_l3_set_online,
 	.set_offline = qeth_l3_set_offline,
-	.shutdown = qeth_l3_shutdown,
 	.freeze = qeth_l3_pm_suspend,
 	.thaw = qeth_l3_pm_resume,
 	.restore = qeth_l3_pm_resume,
-- 
2.10.2
