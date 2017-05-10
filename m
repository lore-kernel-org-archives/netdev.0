From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net 1/4] s390/qeth: handle sysfs error during initialization
Date: Wed, 10 May 2017 19:07:51 +0200
Message-ID: <20170510170754.53922-2-jwi@linux.vnet.ibm.com>
References: <20170510170754.53922-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39895 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753853AbdEJRIU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 13:08:20 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4AH3cbJ136213
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:08:20 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ac5r6ux3a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:08:19 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 10 May 2017 18:08:16 +0100
In-Reply-To: <20170510170754.53922-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>

When setting up the device from within the layer discipline's
probe routine, creating the layer-specific sysfs attributes can fail.
Report this error back to the caller, and handle it by
releasing the layer discipline.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
[jwi: updated commit msg, moved an OSN change to a subsequent patch]
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 4 +++-
 drivers/s390/net/qeth_core_sys.c  | 2 ++
 drivers/s390/net/qeth_l2_main.c   | 5 ++++-
 drivers/s390/net/qeth_l3_main.c   | 5 ++++-
 4 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 38114a8d56e0..5bfd7c15d6a9 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5731,8 +5731,10 @@ static int qeth_core_set_online(struct ccwgroup_device *gdev)
 		if (rc)
 			goto err;
 		rc = card->discipline->setup(card->gdev);
-		if (rc)
+		if (rc) {
+			qeth_core_free_discipline(card);
 			goto err;
+		}
 	}
 	rc = card->discipline->set_online(gdev);
 err:
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 75b29fd2fcf4..412ff61891ac 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -426,6 +426,8 @@ static ssize_t qeth_dev_layer2_store(struct device *dev,
 		goto out;
 
 	rc = card->discipline->setup(card->gdev);
+	if (rc)
+		qeth_core_free_discipline(card);
 out:
 	mutex_unlock(&card->discipline_mutex);
 	return rc ? rc : count;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 1b07f382d74c..2d2623182abf 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -883,8 +883,11 @@ static int qeth_l2_stop(struct net_device *dev)
 static int qeth_l2_probe_device(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	int rc;
 
-	qeth_l2_create_device_attributes(&gdev->dev);
+	rc = qeth_l2_create_device_attributes(&gdev->dev);
+	if (rc)
+		return rc;
 	INIT_LIST_HEAD(&card->vid_list);
 	hash_init(card->mac_htable);
 	card->options.layer2 = 1;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 6e0354ef4b86..ae70daf33bd5 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3039,8 +3039,11 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 static int qeth_l3_probe_device(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	int rc;
 
-	qeth_l3_create_device_attributes(&gdev->dev);
+	rc = qeth_l3_create_device_attributes(&gdev->dev);
+	if (rc)
+		return rc;
 	card->options.layer2 = 0;
 	card->info.hwtrap = 0;
 	return 0;
-- 
2.10.2
