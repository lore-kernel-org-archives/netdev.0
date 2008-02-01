From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: fix sysfs link compile problem
Date: Fri, 1 Feb 2008 15:37:42 +0100
Message-ID: <200802011537.42578.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:59379 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbYBAOhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 09:37:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to changes in the struct device_driver there is no direct
access to its kobj any longer. The kobj was used to create
sysfs links between eHEA ethernet devices and the driver.
This patch removes the affected sysfs links to resolve
the build problems.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


---
 drivers/net/ehea/ehea_main.c |   37 -------------------------------------
 1 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 869e160..9a3fd81 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2804,34 +2804,6 @@ static void __devinit logical_port_release(struct device *dev)
 	of_node_put(port->ofdev.node);
 }
 
-static int ehea_driver_sysfs_add(struct device *dev,
-				 struct device_driver *driver)
-{
-	int ret;
-
-	ret = sysfs_create_link(&driver->kobj, &dev->kobj,
-				kobject_name(&dev->kobj));
-	if (ret == 0) {
-		ret = sysfs_create_link(&dev->kobj, &driver->kobj,
-					"driver");
-		if (ret)
-			sysfs_remove_link(&driver->kobj,
-					  kobject_name(&dev->kobj));
-	}
-	return ret;
-}
-
-static void ehea_driver_sysfs_remove(struct device *dev,
-				     struct device_driver *driver)
-{
-	struct device_driver *drv = driver;
-
-	if (drv) {
-		sysfs_remove_link(&drv->kobj, kobject_name(&dev->kobj));
-		sysfs_remove_link(&dev->kobj, "driver");
-	}
-}
-
 static struct device *ehea_register_port(struct ehea_port *port,
 					 struct device_node *dn)
 {
@@ -2856,16 +2828,8 @@ static struct device *ehea_register_port(struct ehea_port *port,
 		goto out_unreg_of_dev;
 	}
 
-	ret = ehea_driver_sysfs_add(&port->ofdev.dev, &ehea_driver.driver);
-	if (ret) {
-		ehea_error("failed to register sysfs driver link");
-		goto out_rem_dev_file;
-	}
-
 	return &port->ofdev.dev;
 
-out_rem_dev_file:
-	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 out_unreg_of_dev:
 	of_device_unregister(&port->ofdev);
 out:
@@ -2874,7 +2838,6 @@ out:
 
 static void ehea_unregister_port(struct ehea_port *port)
 {
-	ehea_driver_sysfs_remove(&port->ofdev.dev, &ehea_driver.driver);
 	device_remove_file(&port->ofdev.dev, &dev_attr_log_port_id);
 	of_device_unregister(&port->ofdev);
 }
-- 
1.5.2

