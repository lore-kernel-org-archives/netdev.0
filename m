From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 02/12] sky2: use debugfs rename
Date: Wed, 29 Aug 2007 12:58:11 -0700
Message-ID: <20070829195842.759980631@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59174 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754534AbXH2UB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:01:29 -0400
Content-Disposition: inline; filename=sky2-debugfs-rename.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use debugfs rename to handle device neame changes.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-08-29 11:36:04.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:40:09.000000000 -0700
@@ -3712,42 +3712,34 @@ static int sky2_device_event(struct noti
 			     unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
+	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (dev->open == sky2_up) {
-		struct sky2_port *sky2 = netdev_priv(dev);
+	if (dev->open != sky2_up || !sky2_debug)
+		return NOTIFY_DONE;
 
-		switch(event) {
-		case NETDEV_CHANGENAME:
-			if (!netif_running(dev))
-				break;
-			/* fallthrough */
-		case NETDEV_DOWN:
-		case NETDEV_GOING_DOWN:
-			if (sky2->debugfs) {
-				printk(KERN_DEBUG PFX "%s: remove debugfs\n",
-				       dev->name);
-				debugfs_remove(sky2->debugfs);
-				sky2->debugfs = NULL;
-			}
+	switch(event) {
+	case NETDEV_CHANGENAME:
+		if (sky2->debugfs) {
+			sky2->debugfs = debugfs_rename(sky2_debug, sky2->debugfs,
+						       sky2_debug, dev->name);
+		}
+		break;
 
-			if (event != NETDEV_CHANGENAME)
-				break;
-			/* fallthrough for changename */
-		case NETDEV_UP:
-			if (sky2_debug) {
-				struct dentry *d;
-				d = debugfs_create_file(dev->name, S_IRUGO,
-							sky2_debug, dev,
-							&sky2_debug_fops);
-				if (d == NULL || IS_ERR(d))
-					printk(KERN_INFO PFX
-					       "%s: debugfs create failed\n",
-					       dev->name);
-				else
-					sky2->debugfs = d;
-			}
-			break;
+	case NETDEV_GOING_DOWN:
+		if (sky2->debugfs) {
+			printk(KERN_DEBUG PFX "%s: remove debugfs\n",
+			       dev->name);
+			debugfs_remove(sky2->debugfs);
+			sky2->debugfs = NULL;
 		}
+		break;
+
+	case NETDEV_UP:
+		sky2->debugfs = debugfs_create_file(dev->name, S_IRUGO,
+						    sky2_debug, dev,
+						    &sky2_debug_fops);
+		if (IS_ERR(sky2->debugfs))
+			sky2->debugfs = NULL;
 	}
 
 	return NOTIFY_DONE;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

