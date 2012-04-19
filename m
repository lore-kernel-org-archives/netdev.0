From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 09/19] net ax25: Simplify and cleanup the ax25 sysctl handling.
Date: Thu, 19 Apr 2012 16:34:18 -0700
Message-ID: <m1sjfzfg91.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47942 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989Ab2DSXaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:30:18 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't register/unregister every ax25 table in a batch.  Instead register
and unregister per device ax25 sysctls as ax25 devices come and go.

This moves ax25 to be a completely modern sysctl user.  Registering the
sysctls in just the initial network namespace, removing the use of
.child entries that are no longer natively supported by the sysctl core
and taking advantage of the fact that there are no longer any ordering
constraints between registering and unregistering different sysctl
tables.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/ax25.h         |   10 +++---
 net/ax25/af_ax25.c         |    2 -
 net/ax25/ax25_dev.c        |   10 +----
 net/ax25/sysctl_net_ax25.c |   82 +++++++++++++++-----------------------------
 4 files changed, 35 insertions(+), 69 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 94e09d3..8a7a122 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -215,7 +215,7 @@ typedef struct ax25_dev {
 	struct ax25_dev		*next;
 	struct net_device	*dev;
 	struct net_device	*forward;
-	struct ctl_table	*systable;
+	struct ctl_table_header *sysheader;
 	int			values[AX25_MAX_VALUES];
 #if defined(CONFIG_AX25_DAMA_SLAVE) || defined(CONFIG_AX25_DAMA_MASTER)
 	ax25_dama_info		dama;
@@ -441,11 +441,11 @@ extern void ax25_uid_free(void);
 
 /* sysctl_net_ax25.c */
 #ifdef CONFIG_SYSCTL
-extern void ax25_register_sysctl(void);
-extern void ax25_unregister_sysctl(void);
+extern int ax25_register_dev_sysctl(ax25_dev *ax25_dev);
+extern void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev);
 #else
-static inline void ax25_register_sysctl(void) {};
-static inline void ax25_unregister_sysctl(void) {};
+static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
+static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
 #endif /* CONFIG_SYSCTL */
 
 #endif
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 9d9a6a3..051f7ab 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1990,7 +1990,6 @@ static int __init ax25_init(void)
 	sock_register(&ax25_family_ops);
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
-	ax25_register_sysctl();
 
 	proc_net_fops_create(&init_net, "ax25_route", S_IRUGO, &ax25_route_fops);
 	proc_net_fops_create(&init_net, "ax25", S_IRUGO, &ax25_info_fops);
@@ -2013,7 +2012,6 @@ static void __exit ax25_exit(void)
 	proc_net_remove(&init_net, "ax25_calls");
 
 	unregister_netdevice_notifier(&ax25_dev_notifier);
-	ax25_unregister_sysctl();
 
 	dev_remove_pack(&ax25_packet_type);
 
diff --git a/net/ax25/ax25_dev.c b/net/ax25/ax25_dev.c
index d0de30e..3d10676 100644
--- a/net/ax25/ax25_dev.c
+++ b/net/ax25/ax25_dev.c
@@ -59,8 +59,6 @@ void ax25_dev_device_up(struct net_device *dev)
 		return;
 	}
 
-	ax25_unregister_sysctl();
-
 	dev->ax25_ptr     = ax25_dev;
 	ax25_dev->dev     = dev;
 	dev_hold(dev);
@@ -90,7 +88,7 @@ void ax25_dev_device_up(struct net_device *dev)
 	ax25_dev_list  = ax25_dev;
 	spin_unlock_bh(&ax25_dev_lock);
 
-	ax25_register_sysctl();
+	ax25_register_dev_sysctl(ax25_dev);
 }
 
 void ax25_dev_device_down(struct net_device *dev)
@@ -100,7 +98,7 @@ void ax25_dev_device_down(struct net_device *dev)
 	if ((ax25_dev = ax25_dev_ax25dev(dev)) == NULL)
 		return;
 
-	ax25_unregister_sysctl();
+	ax25_unregister_dev_sysctl(ax25_dev);
 
 	spin_lock_bh(&ax25_dev_lock);
 
@@ -120,7 +118,6 @@ void ax25_dev_device_down(struct net_device *dev)
 		spin_unlock_bh(&ax25_dev_lock);
 		dev_put(dev);
 		kfree(ax25_dev);
-		ax25_register_sysctl();
 		return;
 	}
 
@@ -130,7 +127,6 @@ void ax25_dev_device_down(struct net_device *dev)
 			spin_unlock_bh(&ax25_dev_lock);
 			dev_put(dev);
 			kfree(ax25_dev);
-			ax25_register_sysctl();
 			return;
 		}
 
@@ -138,8 +134,6 @@ void ax25_dev_device_down(struct net_device *dev)
 	}
 	spin_unlock_bh(&ax25_dev_lock);
 	dev->ax25_ptr = NULL;
-
-	ax25_register_sysctl();
 }
 
 int ax25_fwd_ioctl(unsigned int cmd, struct ax25_fwd_struct *fwd)
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index 7ba381b..d5744b7 100644
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
+int ax25_register_dev_sysctl(ax25_dev *ax25_dev)
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
-		return;
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
-
-		for (k = 0; k < AX25_MAX_VALUES; k++)
-			child[k].data = &ax25_dev->values[k];
-
-		n++;
+	char path[sizeof("net/ax25/") + IFNAMSIZ];
+	int k;
+	struct ctl_table *table;
+
+	table = kmemdup(ax25_param_table, sizeof(ax25_param_table), GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+
+	for (k = 0; k < AX25_MAX_VALUES; k++)
+		table[k].data = &ax25_dev->values[k];
+
+	snprintf(path, sizeof(path), "net/ax25/%s", ax25_dev->dev->name);
+	ax25_dev->sysheader = register_net_sysctl(&init_net, path, table);
+	if (!ax25_dev->sysheader) {
+		kfree(table);
+		return -ENOMEM;
 	}
-	spin_unlock_bh(&ax25_dev_lock);
-
-	ax25_table_header = register_net_sysctl_table(&init_net, ax25_path, ax25_table);
+	return 0;
 }
 
-void ax25_unregister_sysctl(void)
+void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev)
 {
-	ctl_table *p;
-	unregister_net_sysctl_table(ax25_table_header);
-
-	for (p = ax25_table; p->procname; p++)
-		kfree(p->child);
-	kfree(ax25_table);
+	struct ctl_table_header *header = ax25_dev->sysheader;
+	struct ctl_table *table;
+
+	if (header) {
+		ax25_dev->sysheader = NULL;
+		table = header->ctl_table_arg;
+		unregister_net_sysctl_table(header);
+		kfree(table);
+	}
 }
-- 
1.7.2.5
