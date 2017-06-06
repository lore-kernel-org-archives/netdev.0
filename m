From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 8/9] s390/qeth: add support for early L3 device setup
Date: Tue,  6 Jun 2017 14:33:49 +0200
Message-ID: <20170606123350.13781-9-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47439 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751587AbdFFMeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:20 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXwfh194670
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:10 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2awtnmpph4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:09 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:08 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>

Similar to how qeth currently does early L2 setup of OSM and OSN
devices, add support for early setup of L3-only devices.
This adds a qeth_l3_devtype that contains all core and l3-specific
sysfs attributes, so that they can be created in one go while probing.

This just adds the infrastructure, exploitation of the support happens
in a subsequent patch.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3.h      |  1 +
 drivers/s390/net/qeth_l3_main.c | 18 +++++++++++++-----
 drivers/s390/net/qeth_l3_sys.c  | 11 +++++++++++
 3 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_l3.h b/drivers/s390/net/qeth_l3.h
index 26f79533e62e..9b5e439f18cf 100644
--- a/drivers/s390/net/qeth_l3.h
+++ b/drivers/s390/net/qeth_l3.h
@@ -65,6 +65,7 @@ struct qeth_ipato_entry {
 	int mask_bits;
 };
 
+extern const struct attribute_group *qeth_l3_attr_groups[];
 
 void qeth_l3_ipaddr_to_string(enum qeth_prot_versions, const __u8 *, char *);
 int qeth_l3_string_to_ipaddr(const char *, enum qeth_prot_versions, __u8 *);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index fb4eee2a46ee..37b594231b76 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3005,14 +3005,21 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	return register_netdev(card->dev);
 }
 
+static const struct device_type qeth_l3_devtype = {
+	.name = "qeth_layer3",
+	.groups = qeth_l3_attr_groups,
+};
+
 static int qeth_l3_probe_device(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
 	int rc;
 
-	rc = qeth_l3_create_device_attributes(&gdev->dev);
-	if (rc)
-		return rc;
+	if (gdev->dev.type == &qeth_generic_devtype) {
+		rc = qeth_l3_create_device_attributes(&gdev->dev);
+		if (rc)
+			return rc;
+	}
 	hash_init(card->ip_htable);
 	hash_init(card->ip_mc_htable);
 	card->options.layer2 = 0;
@@ -3024,7 +3031,8 @@ static void qeth_l3_remove_device(struct ccwgroup_device *cgdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
 
-	qeth_l3_remove_device_attributes(&cgdev->dev);
+	if (cgdev->dev.type == &qeth_generic_devtype)
+		qeth_l3_remove_device_attributes(&cgdev->dev);
 
 	qeth_set_allowed_threads(card, 0, 1);
 	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
@@ -3280,7 +3288,7 @@ static int qeth_l3_control_event(struct qeth_card *card,
 }
 
 struct qeth_discipline qeth_l3_discipline = {
-	.devtype = &qeth_generic_devtype,
+	.devtype = &qeth_l3_devtype,
 	.start_poll = qeth_qdio_start_poll,
 	.input_handler = (qdio_handler_t *) qeth_qdio_input_handler,
 	.output_handler = (qdio_handler_t *) qeth_qdio_output_handler,
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index ff29a4b416b4..f2f94f59e0fa 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -1049,3 +1049,14 @@ void qeth_l3_remove_device_attributes(struct device *dev)
 	sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
 	sysfs_remove_group(&dev->kobj, &qeth_device_rxip_group);
 }
+
+const struct attribute_group *qeth_l3_attr_groups[] = {
+	&qeth_device_attr_group,
+	&qeth_device_blkt_group,
+	/* l3 specific, see l3_{create,remove}_device_attributes(): */
+	&qeth_l3_device_attr_group,
+	&qeth_device_ipato_group,
+	&qeth_device_vipa_group,
+	&qeth_device_rxip_group,
+NULL,
+};
-- 
2.11.2
