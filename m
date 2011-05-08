From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 050/115] sysctl: remove .child from ax25 table
Date: Mon,  9 May 2011 00:39:02 +0200
Message-ID: <1304894407-32201-51-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53450 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446Ab1EHWl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:26 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only compile tested!

I'm sorry but I could not manage to add a ax25 interface.

Some notable changes: before this patch, each time a device switched
to up/down we would unregister everything under /proc/sys/net/ax25/
and then reregister an updated table with all devices in it (BTW, the
table was GFP_ATOMIC!).

Now each state change (up/down) registers it's own table (e.g.
/proc/sys/net/ax25/ax0/). I'm assuming ax25 devices cannot be renamed,
but if that's possible, this can be fixed by making a private copy of
the device name for sysctl, and unregistering/reregistering the table
on device rename (see net/ipv4/devinet.c).

Also added an empty /proc/sys/net/ax25/ root directory. Without it,
the first device added would have been the first to create the
/proc/sys/net/ax25/ sysctl path and all other devices would have
attached to it. If the first device was to be removed before other
ones, we would have gotten a harmless warning form sysctl telling us
we're unregistering the parent before the children.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/ax25.h         |   10 +++---
 net/ax25/af_ax25.c         |   23 ++++++++++++-
 net/ax25/ax25_dev.c        |   10 +-----
 net/ax25/sysctl_net_ax25.c |   76 ++++++++++++++-----------------------------
 4 files changed, 53 insertions(+), 66 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 206d222..79c2d2d 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -215,7 +215,7 @@ typedef struct ax25_dev {
 	struct ax25_dev		*next;
 	struct net_device	*dev;
 	struct net_device	*forward;
-	struct ctl_table	*systable;
+	struct ctl_table_header	*ax25_sysheader;
 	int			values[AX25_MAX_VALUES];
 #if defined(CONFIG_AX25_DAMA_SLAVE) || defined(CONFIG_AX25_DAMA_MASTER)
 	ax25_dama_info		dama;
@@ -441,11 +441,11 @@ extern void ax25_uid_free(void);
 
 /* sysctl_net_ax25.c */
 #ifdef CONFIG_SYSCTL
-extern void ax25_register_sysctl(void);
-extern void ax25_unregister_sysctl(void);
+extern void ax25_register_sysctl(struct ax25_dev *dev);
+extern void ax25_unregister_sysctl(struct ax25_dev *dev);
 #else
-static inline void ax25_register_sysctl(void) {};
-static inline void ax25_unregister_sysctl(void) {};
+static inline void ax25_register_sysctl(struct ax25_dev *dev) {};
+static inline void ax25_unregister_sysctl(struct ax25_dev *dev) {};
 #endif /* CONFIG_SYSCTL */
 
 #endif
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 6da5dae..965662d 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1989,6 +1989,18 @@ static struct notifier_block ax25_dev_notifier = {
 	.notifier_call =ax25_device_event,
 };
 
+
+#ifdef CONFIG_SYSCTL
+static const struct __initdata ctl_path ax25_path[] = {
+	{ .procname = "net" },
+	{ .procname = "ax25" },
+	{ }
+};
+static struct ctl_table empty;
+static struct ctl_table_header *ax25_root_header;
+#endif /* CONFIG_SYSCTL */
+
+
 static int __init ax25_init(void)
 {
 	int rc = proto_register(&ax25_proto, 0);
@@ -1999,7 +2011,11 @@ static int __init ax25_init(void)
 	sock_register(&ax25_family_ops);
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
-	ax25_register_sysctl();
+
+	/* XXX: no error checking done in initializer */
+	#ifdef CONFIG_SYSCTL
+	ax25_root_header = register_sysctl_paths(ax25_path, &empty);
+	#endif
 
 	proc_net_fops_create(&init_net, "ax25_route", S_IRUGO, &ax25_route_fops);
 	proc_net_fops_create(&init_net, "ax25", S_IRUGO, &ax25_info_fops);
@@ -2024,7 +2040,10 @@ static void __exit ax25_exit(void)
 	ax25_uid_free();
 	ax25_dev_free();
 
-	ax25_unregister_sysctl();
+	#ifdef CONFIG_SYSCTL
+	unregister_sysctl_table(ax25_root_header);
+	#endif
+
 	unregister_netdevice_notifier(&ax25_dev_notifier);
 
 	dev_remove_pack(&ax25_packet_type);
diff --git a/net/ax25/ax25_dev.c b/net/ax25/ax25_dev.c
index c1cb982..6ff1853 100644
--- a/net/ax25/ax25_dev.c
+++ b/net/ax25/ax25_dev.c
@@ -60,8 +60,6 @@ void ax25_dev_device_up(struct net_device *dev)
 		return;
 	}
 
-	ax25_unregister_sysctl();
-
 	dev->ax25_ptr     = ax25_dev;
 	ax25_dev->dev     = dev;
 	dev_hold(dev);
@@ -91,7 +89,7 @@ void ax25_dev_device_up(struct net_device *dev)
 	ax25_dev_list  = ax25_dev;
 	spin_unlock_bh(&ax25_dev_lock);
 
-	ax25_register_sysctl();
+	ax25_register_sysctl(ax25_dev);
 }
 
 void ax25_dev_device_down(struct net_device *dev)
@@ -101,7 +99,7 @@ void ax25_dev_device_down(struct net_device *dev)
 	if ((ax25_dev = ax25_dev_ax25dev(dev)) == NULL)
 		return;
 
-	ax25_unregister_sysctl();
+	ax25_unregister_sysctl(ax25_dev);
 
 	spin_lock_bh(&ax25_dev_lock);
 
@@ -121,7 +119,6 @@ void ax25_dev_device_down(struct net_device *dev)
 		spin_unlock_bh(&ax25_dev_lock);
 		dev_put(dev);
 		kfree(ax25_dev);
-		ax25_register_sysctl();
 		return;
 	}
 
@@ -131,7 +128,6 @@ void ax25_dev_device_down(struct net_device *dev)
 			spin_unlock_bh(&ax25_dev_lock);
 			dev_put(dev);
 			kfree(ax25_dev);
-			ax25_register_sysctl();
 			return;
 		}
 
@@ -139,8 +135,6 @@ void ax25_dev_device_down(struct net_device *dev)
 	}
 	spin_unlock_bh(&ax25_dev_lock);
 	dev->ax25_ptr = NULL;
-
-	ax25_register_sysctl();
 }
 
 int ax25_fwd_ioctl(unsigned int cmd, struct ax25_fwd_struct *fwd)
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index ebe0ef3..b1181bc 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -29,17 +29,6 @@ static int min_proto[1],		max_proto[] = { AX25_PROTO_MAX };
 static int min_ds_timeout[1],		max_ds_timeout[] = {65535000};
 #endif
 
-static struct ctl_table_header *ax25_table_header;
-
-static ctl_table *ax25_table;
-static int ax25_table_size;
-
-static struct ctl_path ax25_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ax25", },
-	{ }
-};
-
 static const ctl_table ax25_param_table[] = {
 	{
 		.procname	= "ip_default_mode",
@@ -159,52 +148,37 @@ static const ctl_table ax25_param_table[] = {
 	{ }	/* that's all, folks! */
 };
 
-void ax25_register_sysctl(void)
+void ax25_register_sysctl(struct ax25_dev *ax25_dev)
 {
-	ax25_dev *ax25_dev;
-	int n, k;
-
-	spin_lock_bh(&ax25_dev_lock);
-	for (ax25_table_size = sizeof(ctl_table), ax25_dev = ax25_dev_list; ax25_dev != NULL; ax25_dev = ax25_dev->next)
-		ax25_table_size += sizeof(ctl_table);
-
-	if ((ax25_table = kzalloc(ax25_table_size, GFP_ATOMIC)) == NULL) {
-		spin_unlock_bh(&ax25_dev_lock);
+	struct ctl_table *ax25_table;
+	int i;
+
+	/* Assuming the name does not change while this sysctl
+	 * is registered. If ax25 supports device renaming
+	 * (SIOCSIFNAME), sysctl will need it's own copy of
+	 * the name */
+	struct ctl_path ax25_path[] = {
+		{ .procname = "net" },
+		{ .procname = "ax25" },
+		{ .procname = ax25_dev->dev->name },
+		{ }
+	};
+
+
+	ax25_table = kmemdup(ax25_param_table, sizeof(ax25_param_table), GFP_KERNEL);
+	if (!ax25_table)
 		return;
-	}
-
-	for (n = 0, ax25_dev = ax25_dev_list; ax25_dev != NULL; ax25_dev = ax25_dev->next) {
-		struct ctl_table *child = kmemdup(ax25_param_table,
-						  sizeof(ax25_param_table),
-						  GFP_ATOMIC);
-		if (!child) {
-			while (n--)
-				kfree(ax25_table[n].child);
-			kfree(ax25_table);
-			spin_unlock_bh(&ax25_dev_lock);
-			return;
-		}
-		ax25_table[n].child = ax25_dev->systable = child;
-		ax25_table[n].procname     = ax25_dev->dev->name;
-		ax25_table[n].mode         = 0555;
-
 
-		for (k = 0; k < AX25_MAX_VALUES; k++)
-			child[k].data = &ax25_dev->values[k];
+	for (i = 0; i < AX25_MAX_VALUES; i++)
+		ax25_table[i].data = &ax25_dev->values[i];
 
-		n++;
-	}
-	spin_unlock_bh(&ax25_dev_lock);
-
-	ax25_table_header = register_sysctl_paths(ax25_path, ax25_table);
+	ax25_dev->ax25_sysheader = register_sysctl_paths(ax25_path, ax25_table);
 }
 
-void ax25_unregister_sysctl(void)
+void ax25_unregister_sysctl(struct ax25_dev *ax25_dev)
 {
-	ctl_table *p;
-	unregister_sysctl_table(ax25_table_header);
-
-	for (p = ax25_table; p->procname; p++)
-		kfree(p->child);
+	struct ctl_table *ax25_table = ax25_dev->ax25_sysheader->ctl_table_arg;
+	unregister_sysctl_table(ax25_dev->ax25_sysheader);
+	ax25_dev->ax25_sysheader = NULL;
 	kfree(ax25_table);
 }
-- 
1.7.5.134.g1c08b

