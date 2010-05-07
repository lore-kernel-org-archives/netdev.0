From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] ibmveth: Add suspend/resume support
Date: Fri, 07 May 2010 13:56:08 -0500
Message-ID: <201005071156.o47BuCYM007062@d03av03.boulder.ibm.com>
Cc: brking@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:43328 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab0EGS4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 14:56:25 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o47IskWL000922
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 12:54:46 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o47IuGX8082744
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 12:56:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o47BuCt4007091
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 05:56:13 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Adds support for resuming from suspend for IBM virtual ethernet devices.
We may have lost an interrupt over the suspend, so we just kick the
interrupt handler to process anything that is outstanding.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 drivers/net/ibmveth.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff -puN drivers/net/ibmveth.c~ibmveth_suspend drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_suspend	2010-05-07 13:49:19.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2010-05-07 13:49:19.000000000 -0500
@@ -45,6 +45,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
+#include <linux/pm.h>
 #include <linux/ethtool.h>
 #include <linux/proc_fs.h>
 #include <linux/in.h>
@@ -1589,6 +1590,12 @@ static struct kobj_type ktype_veth_pool
 	.default_attrs  = veth_pool_attrs,
 };
 
+static int ibmveth_resume(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	ibmveth_interrupt(netdev->irq, netdev);
+	return 0;
+}
 
 static struct vio_device_id ibmveth_device_table[] __devinitdata= {
 	{ "network", "IBM,l-lan"},
@@ -1596,6 +1603,10 @@ static struct vio_device_id ibmveth_devi
 };
 MODULE_DEVICE_TABLE(vio, ibmveth_device_table);
 
+static struct dev_pm_ops ibmveth_pm_ops = {
+	.resume = ibmveth_resume
+};
+
 static struct vio_driver ibmveth_driver = {
 	.id_table	= ibmveth_device_table,
 	.probe		= ibmveth_probe,
@@ -1604,6 +1615,7 @@ static struct vio_driver ibmveth_driver
 	.driver		= {
 		.name	= ibmveth_driver_name,
 		.owner	= THIS_MODULE,
+		.pm = &ibmveth_pm_ops,
 	}
 };
 
_
