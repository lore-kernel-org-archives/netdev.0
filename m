From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 5/5] [PATCH] ctcm rollback in case of errors
Date: Thu, 15 Oct 2009 10:54:59 +0200
Message-ID: <20091015090750.028618000@linux.vnet.ibm.com>
References: <20091015085454.124154000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Einar Lueck <elelueck@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:33272 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbZJOJIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:08:30 -0400
Content-Disposition: inline; filename=612-ctcm-error-rollback.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

Group device now cleanly reacts to failures during channel start and
implements a clean rollback.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c |   59 ++++++++++++++++++++++++++++++-------------
 1 file changed, 42 insertions(+), 17 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2009-10-15 10:19:32.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2009-10-15 10:19:52.000000000 +0200
@@ -1530,11 +1530,16 @@ static int ctcm_new_device(struct ccwgro
 	struct net_device *dev;
 	struct ccw_device *cdev0;
 	struct ccw_device *cdev1;
+	struct channel *readc;
+	struct channel *writec;
 	int ret;
+	int result;
 
 	priv = dev_get_drvdata(&cgdev->dev);
-	if (!priv)
-		return -ENODEV;
+	if (!priv) {
+		result = -ENODEV;
+		goto out_err_result;
+	}
 
 	cdev0 = cgdev->cdev[0];
 	cdev1 = cgdev->cdev[1];
@@ -1545,31 +1550,40 @@ static int ctcm_new_device(struct ccwgro
 	snprintf(write_id, CTCM_ID_SIZE, "ch-%s", dev_name(&cdev1->dev));
 
 	ret = add_channel(cdev0, type, priv);
-	if (ret)
-		return ret;
+	if (ret) {
+		result = ret;
+		goto out_err_result;
+	}
 	ret = add_channel(cdev1, type, priv);
-	if (ret)
-		return ret;
+	if (ret) {
+		result = ret;
+		goto out_remove_channel1;
+	}
 
 	ret = ccw_device_set_online(cdev0);
 	if (ret != 0) {
-		/* may be ok to fail now - can be done later */
 		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
 			"%s(%s) set_online rc=%d",
 				CTCM_FUNTAIL, read_id, ret);
+		result = -EIO;
+		goto out_remove_channel2;
 	}
 
 	ret = ccw_device_set_online(cdev1);
 	if (ret != 0) {
-		/* may be ok to fail now - can be done later */
 		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
 			"%s(%s) set_online rc=%d",
 				CTCM_FUNTAIL, write_id, ret);
+
+		result = -EIO;
+		goto out_ccw1;
 	}
 
 	dev = ctcm_init_netdevice(priv);
-	if (dev == NULL)
-			goto out;
+	if (dev == NULL) {
+		result = -ENODEV;
+		goto out_ccw2;
+	}
 
 	for (direction = READ; direction <= WRITE; direction++) {
 		priv->channel[direction] =
@@ -1587,12 +1601,14 @@ static int ctcm_new_device(struct ccwgro
 	/* sysfs magic */
 	SET_NETDEV_DEV(dev, &cgdev->dev);
 
-	if (register_netdev(dev))
-			goto out_dev;
+	if (register_netdev(dev)) {
+		result = -ENODEV;
+		goto out_dev;
+	}
 
 	if (ctcm_add_attributes(&cgdev->dev)) {
-		unregister_netdev(dev);
-			goto out_dev;
+		result = -ENODEV;
+		goto out_unregister;
 	}
 
 	strlcpy(priv->fsm->name, dev->name, sizeof(priv->fsm->name));
@@ -1608,13 +1624,22 @@ static int ctcm_new_device(struct ccwgro
 			priv->channel[WRITE]->id, priv->protocol);
 
 	return 0;
+out_unregister:
+	unregister_netdev(dev);
 out_dev:
 	ctcm_free_netdevice(dev);
-out:
+out_ccw2:
 	ccw_device_set_offline(cgdev->cdev[1]);
+out_ccw1:
 	ccw_device_set_offline(cgdev->cdev[0]);
-
-	return -ENODEV;
+out_remove_channel2:
+	readc = channel_get(type, read_id, READ);
+	channel_remove(readc);
+out_remove_channel1:
+	writec = channel_get(type, write_id, WRITE);
+	channel_remove(writec);
+out_err_result:
+	return result;
 }
 
 /**

