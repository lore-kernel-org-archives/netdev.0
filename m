From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 6/9] s390/qeth: simplify L3 sysfs group management
Date: Mon, 18 Sep 2017 21:18:19 +0200
Message-ID: <20170918191822.65142-7-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:43940 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750921AbdIRTT3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:19:29 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJJJjZ024375
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:28 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2d2ex14u9y-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:28 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:27 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the right helpers to create/remove all attribute groups in one go.

Suggested-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_sys.c | 45 +++++++++++-------------------------------
 1 file changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index e8bcc314cc5f..0ad0f7f4b23f 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -1028,52 +1028,31 @@ static const struct attribute_group qeth_device_rxip_group = {
 	.attrs = qeth_rxip_device_attrs,
 };
 
+static const struct attribute_group *qeth_l3_only_attr_groups[] = {
+	&qeth_l3_device_attr_group,
+	&qeth_device_ipato_group,
+	&qeth_device_vipa_group,
+	&qeth_device_rxip_group,
+	NULL,
+};
+
 int qeth_l3_create_device_attributes(struct device *dev)
 {
-	int ret;
-
-	ret = sysfs_create_group(&dev->kobj, &qeth_l3_device_attr_group);
-	if (ret)
-		return ret;
-
-	ret = sysfs_create_group(&dev->kobj, &qeth_device_ipato_group);
-	if (ret) {
-		sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
-		return ret;
-	}
-
-	ret = sysfs_create_group(&dev->kobj, &qeth_device_vipa_group);
-	if (ret) {
-		sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
-		sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
-		return ret;
-	}
-
-	ret = sysfs_create_group(&dev->kobj, &qeth_device_rxip_group);
-	if (ret) {
-		sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
-		sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
-		sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
-		return ret;
-	}
-	return 0;
+	return sysfs_create_groups(&dev->kobj, qeth_l3_only_attr_groups);
 }
 
 void qeth_l3_remove_device_attributes(struct device *dev)
 {
-	sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
-	sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
-	sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
-	sysfs_remove_group(&dev->kobj, &qeth_device_rxip_group);
+	sysfs_remove_groups(&dev->kobj, qeth_l3_only_attr_groups);
 }
 
 const struct attribute_group *qeth_l3_attr_groups[] = {
 	&qeth_device_attr_group,
 	&qeth_device_blkt_group,
-	/* l3 specific, see l3_{create,remove}_device_attributes(): */
+	/* l3 specific, see qeth_l3_only_attr_groups: */
 	&qeth_l3_device_attr_group,
 	&qeth_device_ipato_group,
 	&qeth_device_vipa_group,
 	&qeth_device_rxip_group,
-NULL,
+	NULL,
 };
-- 
2.13.5
