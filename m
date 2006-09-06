From: fpavlic@de.ibm.com
Subject: [PATCH 9/9] s390: qeth driver fixes [6/6]
Date: Wed, 6 Sep 2006 17:06:35 +0200
Message-ID: <200609061706.36223.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:31562 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751316AbWIFPFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:05:40 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k86F5d6I023986
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:05:39 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F7jts1376390
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:07:45 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F5cJT005515
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:05:38 +0100
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 9/9] s390: qeth driver fixes [6/6]

From: Frank Pavlic <fpavlic@de.ibm.com>
 - Hipersockets has no IPV6 support, thus prevent issueing
   SETRTG_IPV6 control commands on Hipersockets devices.
 - fixed error handling in qeth_sysfs_(un)register

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |   59 
++++++++++++++++++++++++++++--------------
 1 files changed, 39 insertions(+), 20 deletions(-)

bf4ddb14ce943f8e189655986107eadcc187dc8e
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index a1b2e6f..5613b45 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -7344,6 +7344,8 @@ qeth_setrouting_v6(struct qeth_card *car
  QETH_DBF_TEXT(trace,3,"setrtg6");
 #ifdef CONFIG_QETH_IPV6
 
+ if (!qeth_is_supported(card, IPA_IPV6))
+		return 0;
 	qeth_correct_routing_type(card, &card->options.route6.type,
 				  QETH_PROT_IPV6);
 
@@ -8544,34 +8546,44 @@ qeth_ipv6_uninit(void)
 static void
 qeth_sysfs_unregister(void)
 {
+	s390_root_dev_unregister(qeth_root_dev);
 	qeth_remove_driver_attributes();
 	ccw_driver_unregister(&qeth_ccw_driver);
  ccwgroup_driver_unregister(&qeth_ccwgroup_driver);
-	s390_root_dev_unregister(qeth_root_dev);
 }
+
 /**
  * register qeth at sysfs
  */
 static int
 qeth_sysfs_register(void)
 {
-	int rc=0;
+	int rc;
 
 	rc = ccwgroup_driver_register(&qeth_ccwgroup_driver);
 	if (rc)
-		return rc;
+		goto out;
+
 	rc = ccw_driver_register(&qeth_ccw_driver);
 	if (rc)
-	 	return rc;
+		goto out_ccw_driver;
+
 	rc = qeth_create_driver_attributes();
  if (rc)
-		return rc;
+		goto out_qeth_attr;
+
 	qeth_root_dev = s390_root_dev_register("qeth");
-	if (IS_ERR(qeth_root_dev)) {
-		rc = PTR_ERR(qeth_root_dev);
-		return rc;
-	}
-	return 0;
+	rc = IS_ERR(qeth_root_dev) ? PTR_ERR(qeth_root_dev) : 0;
+	if (!rc)
+		goto out;
+
+	qeth_remove_driver_attributes();
+out_qeth_attr:
+	ccw_driver_unregister(&qeth_ccw_driver);
+out_ccw_driver:
+	ccwgroup_driver_unregister(&qeth_ccwgroup_driver);
+out:
+	return rc;
 }
 
 /***
@@ -8580,7 +8592,7 @@ qeth_sysfs_register(void)
 static int __init
 qeth_init(void)
 {
-	int rc=0;
+	int rc;
 
 	PRINT_INFO("loading %s\n", version);
 
@@ -8589,20 +8601,26 @@ qeth_init(void)
 	spin_lock_init(&qeth_notify_lock);
 	rwlock_init(&qeth_card_list.rwlock);
 
-	if (qeth_register_dbf_views())
+	rc = qeth_register_dbf_views();
+	if (rc)
 		goto out_err;
-	if (qeth_sysfs_register())
-		goto out_sysfs;
+
+	rc = qeth_sysfs_register();
+	if (rc)
+		goto out_dbf;
 
 #ifdef CONFIG_QETH_IPV6
- if (qeth_ipv6_init()) {
-  PRINT_ERR("Out of memory during ipv6 init.\n");
+ rc = qeth_ipv6_init();
+ if (rc) {
+  PRINT_ERR("Out of memory during ipv6 init code = %d\n", rc);
   goto out_sysfs;
  }
 #endif /* QETH_IPV6 */
- if (qeth_register_notifiers())
+ rc = qeth_register_notifiers();
+ if (rc)
   goto out_ipv6;
- if (qeth_create_procfs_entries())
+ rc = qeth_create_procfs_entries();
+ if (rc)
   goto out_notifiers;
 
  return rc;
@@ -8612,12 +8630,13 @@ out_notifiers:
 out_ipv6:
 #ifdef CONFIG_QETH_IPV6
  qeth_ipv6_uninit();
-#endif /* QETH_IPV6 */
 out_sysfs:
+#endif /* QETH_IPV6 */
  qeth_sysfs_unregister();
+out_dbf:
  qeth_unregister_dbf_views();
 out_err:
- PRINT_ERR("Initialization failed");
+ PRINT_ERR("Initialization failed with code %d\n", rc);
  return rc;
 }
 
-- 
1.2.4

