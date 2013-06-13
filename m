From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH] netiucv: Hold rtnl between name allocation and device registration.
Date: Thu, 13 Jun 2013 09:09:47 -0400
Message-ID: <1371128987-3723-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, Ursula Braun <ursula.braun@de.ibm.com>,
	linux390@de.ibm.com, Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-kernel@vger.kernel.org
To: linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:34075 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720Ab3FMNKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 09:10:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fixes a race condition between concurrent initializations of netiucv devices
that try to use the same name.

sysfs: cannot create duplicate filename '/devices/iucv/netiucv2'
[...]
Call Trace:
([<00000000002edea4>] sysfs_add_one+0xb0/0xdc)
 [<00000000002eecd4>] create_dir+0x80/0xfc
 [<00000000002eee38>] sysfs_create_dir+0xe8/0x118
 [<00000000003835a8>] kobject_add_internal+0x120/0x2d0
 [<00000000003839d6>] kobject_add+0x62/0x9c
 [<00000000003d9564>] device_add+0xcc/0x510
 [<000003e00212c7b4>] netiucv_register_device+0xc0/0x1ec [netiucv]

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
Tested-by: Ursula Braun <braunu@de.ibm.com>
---
 drivers/s390/net/netiucv.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 4ffa66c..9ca3996 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -2040,6 +2040,7 @@ static struct net_device *netiucv_init_netdevice(char *username, char *userdata)
 			   netiucv_setup_netdevice);
 	if (!dev)
 		return NULL;
+	rtnl_lock();
 	if (dev_alloc_name(dev, dev->name) < 0)
 		goto out_netdev;
 
@@ -2061,6 +2062,7 @@ static struct net_device *netiucv_init_netdevice(char *username, char *userdata)
 out_fsm:
 	kfree_fsm(privptr->fsm);
 out_netdev:
+	rtnl_unlock();
 	free_netdev(dev);
 	return NULL;
 }
@@ -2100,6 +2102,7 @@ static ssize_t conn_write(struct device_driver *drv,
 
 	rc = netiucv_register_device(dev);
 	if (rc) {
+		rtnl_unlock();
 		IUCV_DBF_TEXT_(setup, 2,
 			"ret %d from netiucv_register_device\n", rc);
 		goto out_free_ndev;
@@ -2109,7 +2112,8 @@ static ssize_t conn_write(struct device_driver *drv,
 	priv = netdev_priv(dev);
 	SET_NETDEV_DEV(dev, priv->dev);
 
-	rc = register_netdev(dev);
+	rc = register_netdevice(dev);
+	rtnl_unlock();
 	if (rc)
 		goto out_unreg;
 
-- 
1.7.10.4
