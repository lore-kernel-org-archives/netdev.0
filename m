From: Patrick McHardy <kaber@trash.net>
Subject: [DUMMY 05/18]: Keep dummy devices on list
Date: Wed, 13 Jun 2007 18:50:49 +0200 (MEST)
Message-ID: <20070613165046.7780.400.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35930 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758745AbXFMQuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:50 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[DUMMY]: Keep dummy devices on list

Use a list instead of an array to allow creating new devices.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 18094391f33349687e35eaf0e768b18a71523100
tree 8697434fd6ce5c2d16b4e823482ba9cf7ee8cea2
parent af03e9fd45eb64f27bcc2ac79d0d615e563100a9
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:07 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:30 +0200

 drivers/net/dummy.c |   47 +++++++++++++++++++++++++++++------------------
 1 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 91b474c..2f2cf3c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -34,6 +34,12 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
+#include <linux/rtnetlink.h>
+
+struct dummy_priv {
+	struct net_device *dev;
+	struct list_head list;
+};
 
 static int numdummies = 1;
 
@@ -81,18 +87,20 @@ static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static struct net_device **dummies;
+static LIST_HEAD(dummies);
 
 /* Number of dummy devices to be set up by this module. */
 module_param(numdummies, int, 0);
 MODULE_PARM_DESC(numdummies, "Number of dummy pseudo devices");
 
-static int __init dummy_init_one(int index)
+static int __init dummy_init_one(void)
 {
 	struct net_device *dev_dummy;
+	struct dummy_priv *priv;
 	int err;
 
-	dev_dummy = alloc_netdev(0, "dummy%d", dummy_setup);
+	dev_dummy = alloc_netdev(sizeof(struct dummy_priv), "dummy%d",
+				 dummy_setup);
 
 	if (!dev_dummy)
 		return -ENOMEM;
@@ -101,40 +109,43 @@ static int __init dummy_init_one(int index)
 		free_netdev(dev_dummy);
 		dev_dummy = NULL;
 	} else {
-		dummies[index] = dev_dummy;
+		priv = netdev_priv(dev_dummy);
+		priv->dev = dev_dummy;
+		list_add_tail(&priv->list, &dummies);
 	}
 
 	return err;
 }
 
-static void dummy_free_one(int index)
+static void dummy_free_one(struct net_device *dev)
 {
-	unregister_netdev(dummies[index]);
-	free_netdev(dummies[index]);
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	list_del(&priv->list);
+	unregister_netdev(dev);
+	free_netdev(dev);
 }
 
 static int __init dummy_init_module(void)
 {
+	struct dummy_priv *priv, *next;
 	int i, err = 0;
-	dummies = kmalloc(numdummies * sizeof(void *), GFP_KERNEL);
-	if (!dummies)
-		return -ENOMEM;
+
 	for (i = 0; i < numdummies && !err; i++)
-		err = dummy_init_one(i);
+		err = dummy_init_one();
 	if (err) {
-		i--;
-		while (--i >= 0)
-			dummy_free_one(i);
+		list_for_each_entry_safe(priv, next, &dummies, list)
+			dummy_free_one(priv->dev);
 	}
 	return err;
 }
 
 static void __exit dummy_cleanup_module(void)
 {
-	int i;
-	for (i = 0; i < numdummies; i++)
-		dummy_free_one(i);
-	kfree(dummies);
+	struct dummy_priv *priv, *next;
+
+	list_for_each_entry_safe(priv, next, &dummies, list)
+		dummy_free_one(priv->dev);
 }
 
 module_init(dummy_init_module);
