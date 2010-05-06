From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] bridge: update sysfs link names if port device names have
 changed
Date: Thu, 06 May 2010 19:32:29 +0100
Message-ID: <4BE30B3D.9000600@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:34337 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759362Ab0EFScd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 14:32:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Links for each port are created in sysfs using the device
name, but this could be changed after being added to the
bridge.

As well as being unable to remove interfaces after this
occurs (because userspace tools don't recognise the new
name, and the kernel won't recognise the old name), adding
another interface with the old name to the bridge will
cause an error trying to create the sysfs link.

This fixes the problem by listening for NETDEV_CHANGENAME
notifications and renaming the link.

https://bugzilla.kernel.org/show_bug.cgi?id=12743

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 fs/sysfs/symlink.c       |    1 +
 net/bridge/br_if.c       |    2 +-
 net/bridge/br_notify.c   |    4 ++++
 net/bridge/br_private.h  |    5 +++++
 net/bridge/br_sysfs_if.c |   19 +++++++++++++++++--
 5 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index b93ec51..942f239 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -261,3 +261,4 @@ const struct inode_operations sysfs_symlink_inode_operations = {
 
 EXPORT_SYMBOL_GPL(sysfs_create_link);
 EXPORT_SYMBOL_GPL(sysfs_remove_link);
+EXPORT_SYMBOL_GPL(sysfs_rename_link);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 0b6b1f2..17175a5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -132,7 +132,7 @@ static void del_nbp(struct net_bridge_port *p)
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
-	sysfs_remove_link(br->ifobj, dev->name);
+	sysfs_remove_link(br->ifobj, p->sysfs_name);
 
 	dev_set_promiscuity(dev, -1);
 
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 763a3ec..9004406 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -82,6 +82,10 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	case NETDEV_UNREGISTER:
 		br_del_if(br, dev);
 		break;
+
+	case NETDEV_CHANGENAME:
+		br_sysfs_renameif(p);
+		break;
 	}
 
 	/* Events that may cause spanning tree to refresh */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 846d7d1..dcbe744 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -96,6 +96,9 @@ struct net_bridge_port
 {
 	struct net_bridge		*br;
 	struct net_device		*dev;
+#ifdef CONFIG_SYSFS
+	char				sysfs_name[IFNAMSIZ];
+#endif
 	struct list_head		list;
 
 	/* STP */
@@ -433,6 +436,7 @@ extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 /* br_sysfs_if.c */
 extern const struct sysfs_ops brport_sysfs_ops;
 extern int br_sysfs_addif(struct net_bridge_port *p);
+extern void br_sysfs_renameif(struct net_bridge_port *p);
 
 /* br_sysfs_br.c */
 extern int br_sysfs_addbr(struct net_device *dev);
@@ -441,6 +445,7 @@ extern void br_sysfs_delbr(struct net_device *dev);
 #else
 
 #define br_sysfs_addif(p)	(0)
+#define br_sysfs_renameif(p)	do { } while(0)
 #define br_sysfs_addbr(dev)	(0)
 #define br_sysfs_delbr(dev)	do { } while(0)
 #endif /* CONFIG_SYSFS */
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 0b99164..6702d7d 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -246,7 +246,7 @@ const struct sysfs_ops brport_sysfs_ops = {
 /*
  * Add sysfs entries to ethernet device added to a bridge.
  * Creates a brport subdirectory with bridge attributes.
- * Puts symlink in bridge's brport subdirectory
+ * Puts symlink in bridge's brif subdirectory
  */
 int br_sysfs_addif(struct net_bridge_port *p)
 {
@@ -265,7 +265,22 @@ int br_sysfs_addif(struct net_bridge_port *p)
 			goto out2;
 	}
 
-	err = sysfs_create_link(br->ifobj, &p->kobj, p->dev->name);
+	strncpy(p->sysfs_name, p->dev->name, IFNAMSIZ);
+	err = sysfs_create_link(br->ifobj, &p->kobj, p->sysfs_name);
 out2:
 	return err;
 }
+
+/* Rename bridge's brif symlink */
+void br_sysfs_renameif(struct net_bridge_port *p)
+{
+	struct net_bridge *br = p->br;
+	int err;
+
+	err = sysfs_rename_link(br->ifobj, &p->kobj,
+		p->sysfs_name, p->dev->name);
+	if (err)
+		printk(KERN_ERR "%s: unable to rename sysfs link %s to %s (%d)",
+			br->dev->name, p->sysfs_name, p->dev->name, err);
+	strncpy(p->sysfs_name, p->dev->name, IFNAMSIZ);
+}
-- 
1.7.0.4

-- 
Simon Arlott
