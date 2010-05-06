From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH (v4+)] bridge: update sysfs link names if port device names
 have changed
Date: Thu, 6 May 2010 12:50:40 -0700
Message-ID: <20100506125040.45743200@nehalam>
References: <4BE30B3D.9000600@simon.arlott.org.uk>
	<4BE31218.6010709@simon.arlott.org.uk>
	<20100506121107.1868ad07@nehalam>
	<4BE31A67.4090007@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51053 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757122Ab0EFTvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 15:51:09 -0400
In-Reply-To: <4BE31A67.4090007@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Simon Arlott <simon@fire.lp0.eu>

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
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
Modified to apply to net-next and fix checkpatch warnings -- Stephen

 fs/sysfs/symlink.c       |    1 +
 net/bridge/br_if.c       |    2 +-
 net/bridge/br_notify.c   |    7 +++++++
 net/bridge/br_private.h  |    6 ++++++
 net/bridge/br_sysfs_if.c |   32 +++++++++++++++++++++++++++-----
 5 files changed, 42 insertions(+), 6 deletions(-)

--- a/fs/sysfs/symlink.c	2010-04-20 08:22:12.000000000 -0700
+++ b/fs/sysfs/symlink.c	2010-05-06 12:41:36.488153157 -0700
@@ -261,3 +261,4 @@ const struct inode_operations sysfs_syml
 
 EXPORT_SYMBOL_GPL(sysfs_create_link);
 EXPORT_SYMBOL_GPL(sysfs_remove_link);
+EXPORT_SYMBOL_GPL(sysfs_rename_link);
--- a/net/bridge/br_if.c	2010-05-06 12:24:59.000000000 -0700
+++ b/net/bridge/br_if.c	2010-05-06 12:41:36.488153157 -0700
@@ -133,7 +133,7 @@ static void del_nbp(struct net_bridge_po
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
-	sysfs_remove_link(br->ifobj, dev->name);
+	sysfs_remove_link(br->ifobj, p->sysfs_name);
 
 	dev_set_promiscuity(dev, -1);
 
--- a/net/bridge/br_notify.c	2010-05-06 12:24:30.000000000 -0700
+++ b/net/bridge/br_notify.c	2010-05-06 12:43:27.776801235 -0700
@@ -34,6 +34,7 @@ static int br_device_event(struct notifi
 	struct net_device *dev = ptr;
 	struct net_bridge_port *p = dev->br_port;
 	struct net_bridge *br;
+	int err;
 
 	/* not a port of a bridge */
 	if (p == NULL)
@@ -83,6 +84,12 @@ static int br_device_event(struct notifi
 		br_del_if(br, dev);
 		break;
 
+	case NETDEV_CHANGENAME:
+		err = br_sysfs_renameif(p);
+		if (err)
+			return notifier_from_errno(err);
+		break;
+
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
 		return NOTIFY_BAD;
--- a/net/bridge/br_private.h	2010-05-06 08:43:18.000000000 -0700
+++ b/net/bridge/br_private.h	2010-05-06 12:41:36.488153157 -0700
@@ -139,6 +139,10 @@ struct net_bridge_port
 	struct hlist_head		mglist;
 	struct hlist_node		rlist;
 #endif
+
+#ifdef CONFIG_SYSFS
+	char				sysfs_name[IFNAMSIZ];
+#endif
 };
 
 struct br_cpu_netstats {
@@ -455,6 +459,7 @@ extern void br_ifinfo_notify(int event, 
 /* br_sysfs_if.c */
 extern const struct sysfs_ops brport_sysfs_ops;
 extern int br_sysfs_addif(struct net_bridge_port *p);
+extern int br_sysfs_renameif(struct net_bridge_port *p);
 
 /* br_sysfs_br.c */
 extern int br_sysfs_addbr(struct net_device *dev);
@@ -463,6 +468,7 @@ extern void br_sysfs_delbr(struct net_de
 #else
 
 #define br_sysfs_addif(p)	(0)
+#define br_sysfs_renameif(p)	(0)
 #define br_sysfs_addbr(dev)	(0)
 #define br_sysfs_delbr(dev)	do { } while(0)
 #endif /* CONFIG_SYSFS */
--- a/net/bridge/br_sysfs_if.c	2010-05-06 12:24:30.000000000 -0700
+++ b/net/bridge/br_sysfs_if.c	2010-05-06 12:48:07.747112472 -0700
@@ -246,7 +246,7 @@ const struct sysfs_ops brport_sysfs_ops 
 /*
  * Add sysfs entries to ethernet device added to a bridge.
  * Creates a brport subdirectory with bridge attributes.
- * Puts symlink in bridge's brport subdirectory
+ * Puts symlink in bridge's brif subdirectory
  */
 int br_sysfs_addif(struct net_bridge_port *p)
 {
@@ -257,15 +257,37 @@ int br_sysfs_addif(struct net_bridge_por
 	err = sysfs_create_link(&p->kobj, &br->dev->dev.kobj,
 				SYSFS_BRIDGE_PORT_LINK);
 	if (err)
-		goto out2;
+		return err;
 
 	for (a = brport_attrs; *a; ++a) {
 		err = sysfs_create_file(&p->kobj, &((*a)->attr));
 		if (err)
-			goto out2;
+			return err;
 	}
 
-	err = sysfs_create_link(br->ifobj, &p->kobj, p->dev->name);
-out2:
+	strlcpy(p->sysfs_name, p->dev->name, IFNAMSIZ);
+	return sysfs_create_link(br->ifobj, &p->kobj, p->sysfs_name);
+}
+
+/* Rename bridge's brif symlink */
+int br_sysfs_renameif(struct net_bridge_port *p)
+{
+	struct net_bridge *br = p->br;
+	int err;
+
+	/* If a rename fails, the rollback will cause another
+	 * rename call with the existing name.
+	 */
+	if (!strncmp(p->sysfs_name, p->dev->name, IFNAMSIZ))
+		return 0;
+
+	err = sysfs_rename_link(br->ifobj, &p->kobj,
+				p->sysfs_name, p->dev->name);
+	if (err)
+		netdev_notice(br->dev, "unable to rename link %s to %s",
+			      p->sysfs_name, p->dev->name);
+	else
+		strlcpy(p->sysfs_name, p->dev->name, IFNAMSIZ);
+
 	return err;
 }
