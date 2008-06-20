From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 3/8] bridge: Check return of dev_set_promiscuity
Date: Fri, 20 Jun 2008 08:55:00 +0800
Message-ID: <485AFFE4.4000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63162 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754433AbYFTA6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:58:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for promiscuity to get error return.

BTW, I have to add a function to handle cleanup for br_sysfs_addif().
I know Stephen has removed br_sysfs_removeif() to keep kobjects in use
even if not using sysfs.
But here we have a new br_sysfs_removeif() which only cleanup the sysfs
and doesn't touch kobjects.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/bridge/br_if.c       |    7 ++++++-
 net/bridge/br_private.h  |    2 ++
 net/bridge/br_sysfs_if.c |   17 +++++++++++++++++
 3 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c2397f5..49dd433 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -389,7 +389,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
-	dev_set_promiscuity(dev, 1);
+	/* If promiscuity overflow, return error */
+	err = dev_set_promiscuity(dev, 1);
+	if (err)
+		goto err3;
 
 	list_add_rcu(&p->list, &br->port_list);
 
@@ -409,6 +412,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
+err3:
+	br_sysfs_removeif(p);
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c11b554..c1bbfea 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -250,6 +250,7 @@ extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 /* br_sysfs_if.c */
 extern struct sysfs_ops brport_sysfs_ops;
 extern int br_sysfs_addif(struct net_bridge_port *p);
+extern void br_sysfs_removeif(struct net_bridge_port *p);
 
 /* br_sysfs_br.c */
 extern int br_sysfs_addbr(struct net_device *dev);
@@ -258,6 +259,7 @@ extern void br_sysfs_delbr(struct net_device *dev);
 #else
 
 #define br_sysfs_addif(p)	(0)
+#define br_sysfs_removeif(p)	do { } while (0)
 #define br_sysfs_addbr(dev)	(0)
 #define br_sysfs_delbr(dev)	do { } while(0)
 #endif /* CONFIG_SYSFS */
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 02b2d50..7f80462 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -233,3 +233,20 @@ int br_sysfs_addif(struct net_bridge_port *p)
 out2:
 	return err;
 }
+
+/*
+ * Remove sysfs entries of ethernet device added to a bridge.
+ * Revert all the things be done by br_sysfs_addif().
+ */
+void br_sysfs_removeif(struct net_bridge_port *p)
+{
+	struct net_bridge *br = p->br;
+	struct brport_attribute **a;
+
+	sysfs_remove_link(&p->kobj, p->dev->name);
+
+	for (a = brport_attrs; *a; ++a)
+		sysfs_remove_file(&p->kobj, &((*a)->attr));
+
+	sysfs_remove_link(&br->dev->dev.kobj, SYSFS_BRIDGE_PORT_LINK);
+}
-- 
1.5.3.4




