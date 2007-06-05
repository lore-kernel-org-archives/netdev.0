From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IFB 08/09]: Keep ifb devices on list
Date: Tue,  5 Jun 2007 16:13:03 +0200 (MEST)
Message-ID: <20070605141303.15650.14542.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63939 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763775AbXFEONF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:13:05 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IFB]: Keep ifb devices on list

Use a list instead of an array to allow creating new devices.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 279921d3d97ab5f310142bdb27b5459742dbba4f
tree b6602b51779ffefeae65a32c80cc92da90a40a6c
parent a86d7c15680b4bbeec06f0194c2ca927648e33dd
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:29 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 15:40:29 +0200

 drivers/net/ifb.c |   36 +++++++++++++++++++++---------------
 1 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 07b4c0d..819945e 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -33,12 +33,15 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
+#include <linux/list.h>
 #include <net/pkt_sched.h>
 
 #define TX_TIMEOUT  (2*HZ)
 
 #define TX_Q_LIMIT    32
 struct ifb_private {
+	struct list_head	list;
+	struct net_device	*dev;
 	struct net_device_stats stats;
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
@@ -197,7 +200,7 @@ static struct net_device_stats *ifb_get_stats(struct net_device *dev)
 	return stats;
 }
 
-static struct net_device **ifbs;
+static LIST_HEAD(ifbs);
 
 /* Number of ifb devices to be set up by this module. */
 module_param(numifbs, int, 0);
@@ -229,6 +232,7 @@ static int ifb_open(struct net_device *dev)
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
+	struct ifb_private *priv;
 	int err;
 
 	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
@@ -241,30 +245,33 @@ static int __init ifb_init_one(int index)
 		free_netdev(dev_ifb);
 		dev_ifb = NULL;
 	} else {
-		ifbs[index] = dev_ifb;
+		priv = netdev_priv(dev_ifb);
+		priv->dev = dev_ifb;
+		list_add_tail(&priv->list, &ifbs);
 	}
 
 	return err;
 }
 
-static void ifb_free_one(int index)
+static void ifb_free_one(struct net_device *dev)
 {
-	unregister_netdev(ifbs[index]);
-	free_netdev(ifbs[index]);
+	struct ifb_private *priv = netdev_priv(dev);
+
+	list_del(&priv->list);
+	unregister_netdev(dev);
+	free_netdev(dev);
 }
 
 static int __init ifb_init_module(void)
 {
+	struct ifb_private *priv, *next;
 	int i, err = 0;
-	ifbs = kmalloc(numifbs * sizeof(void *), GFP_KERNEL);
-	if (!ifbs)
-		return -ENOMEM;
+
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
 	if (err) {
-		i--;
-		while (--i >= 0)
-			ifb_free_one(i);
+		list_for_each_entry_safe(priv, next, &ifbs, list)
+			ifb_free_one(priv->dev);
 	}
 
 	return err;
@@ -272,11 +279,10 @@ static int __init ifb_init_module(void)
 
 static void __exit ifb_cleanup_module(void)
 {
-	int i;
+	struct ifb_private *priv, *next;
 
-	for (i = 0; i < numifbs; i++)
-		ifb_free_one(i);
-	kfree(ifbs);
+	list_for_each_entry_safe(priv, next, &ifbs, list)
+		ifb_free_one(priv->dev);
 }
 
 module_init(ifb_init_module);
