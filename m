From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] [PATCH] netiucv: cleanup attribute usage
Date: Wed, 25 Jul 2012 10:34:28 +0200
Message-ID: <20120725083446.242385227@de.ibm.com>
References: <20120725083426.704834478@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Sebastian Ott <sebott@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:45652 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803Ab2GYIez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 04:34:55 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 25 Jul 2012 09:34:53 +0100
Content-Disposition: inline; filename=601-netiucv-attr-usage.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let the driver core handle device attribute creation and removal. This
will simplify the code and eliminates races between attribute
availability and userspace notification via uevents.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Acked-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/netiucv.c | 34 ++++++----------------------------
 1 file changed, 6 insertions(+), 28 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 8160591..4ffa66c 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1854,26 +1854,11 @@ static struct attribute_group netiucv_stat_attr_group = {
 	.attrs = netiucv_stat_attrs,
 };
 
-static int netiucv_add_files(struct device *dev)
-{
-	int ret;
-
-	IUCV_DBF_TEXT(trace, 3, __func__);
-	ret = sysfs_create_group(&dev->kobj, &netiucv_attr_group);
-	if (ret)
-		return ret;
-	ret = sysfs_create_group(&dev->kobj, &netiucv_stat_attr_group);
-	if (ret)
-		sysfs_remove_group(&dev->kobj, &netiucv_attr_group);
-	return ret;
-}
-
-static void netiucv_remove_files(struct device *dev)
-{
-	IUCV_DBF_TEXT(trace, 3, __func__);
-	sysfs_remove_group(&dev->kobj, &netiucv_stat_attr_group);
-	sysfs_remove_group(&dev->kobj, &netiucv_attr_group);
-}
+static const struct attribute_group *netiucv_attr_groups[] = {
+	&netiucv_stat_attr_group,
+	&netiucv_attr_group,
+	NULL,
+};
 
 static int netiucv_register_device(struct net_device *ndev)
 {
@@ -1887,6 +1872,7 @@ static int netiucv_register_device(struct net_device *ndev)
 		dev_set_name(dev, "net%s", ndev->name);
 		dev->bus = &iucv_bus;
 		dev->parent = iucv_root;
+		dev->groups = netiucv_attr_groups;
 		/*
 		 * The release function could be called after the
 		 * module has been unloaded. It's _only_ task is to
@@ -1904,22 +1890,14 @@ static int netiucv_register_device(struct net_device *ndev)
 		put_device(dev);
 		return ret;
 	}
-	ret = netiucv_add_files(dev);
-	if (ret)
-		goto out_unreg;
 	priv->dev = dev;
 	dev_set_drvdata(dev, priv);
 	return 0;
-
-out_unreg:
-	device_unregister(dev);
-	return ret;
 }
 
 static void netiucv_unregister_device(struct device *dev)
 {
 	IUCV_DBF_TEXT(trace, 3, __func__);
-	netiucv_remove_files(dev);
 	device_unregister(dev);
 }
 
-- 
1.7.11.3
