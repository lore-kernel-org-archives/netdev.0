From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH] [RESENDING] netconsole: register cmdline netconsole configs to configfs
Date: Mon, 11 Feb 2008 18:08:32 +0900
Message-ID: <12027209202884-git-send-email-joonwpark81@gmail.com>
References: <12027209122955-git-send-email-joonwpark81@gmail.com>
 <12027209163465-git-send-email-joonwpark81@gmail.com>
Cc: Joonwoo Park <joonwpark81@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, satyam@infradead.org, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:11370 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbYBKJIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 04:08:41 -0500
Received: by wx-out-0506.google.com with SMTP id h31so4696006wxd.4
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 01:08:41 -0800 (PST)
In-Reply-To: <12027209163465-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch intorduces cmdline netconsole configs to register to configfs
with dynamic netconsole. Satyam Sharma who designed shiny dynamic
reconfiguration for netconsole, mentioned about this issue already.
(http://lkml.org/lkml/2007/7/29/360)
But I think, without separately managing of two kind of netconsole target
objects, it's possible by using config_group instead of
config_item in the netconsole_target and default_groups feature of configfs.

Patch was tested with configuration creation/destruction by kernel and
module.
And it makes possible to enable/disable, modify and review netconsole
target configs from cmdline.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/netconsole.c |   91 ++++++++++++++++++++++++++++++++++++----------
 1 files changed, 72 insertions(+), 19 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 31e047d..63aabbb 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -93,7 +93,7 @@ static DEFINE_SPINLOCK(target_list_lock);
 struct netconsole_target {
 	struct list_head	list;
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
-	struct config_item	item;
+	struct config_group	group;
 #endif
 	int			enabled;
 	struct netpoll		np;
@@ -103,16 +103,49 @@ struct netconsole_target {
 
 static struct configfs_subsystem netconsole_subsys;
 
-static int __init dynamic_netconsole_init(void)
+static void netconsole_target_put(struct netconsole_target *nt);
+static struct config_item_type netconsole_target_type;
+
+static int __init dynamic_netconsole_init(int defaults)
 {
+	int err;
+	unsigned long flags;
 	config_group_init(&netconsole_subsys.su_group);
+
+	if (defaults > 0) {
+		struct list_head *pos;
+		struct config_group **groups;
+		int i = 0;
+
+		groups = kcalloc(defaults, sizeof(struct config_group *),
+				GFP_KERNEL);
+		if (!groups)
+			return -ENOMEM;
+
+		spin_lock_irqsave(&target_list_lock, flags);
+		list_for_each(pos, &target_list) {
+			struct netconsole_target *nt;
+			nt = list_entry(pos, struct netconsole_target, list);
+			groups[i] = &nt->group;
+			i++;
+		}
+		spin_unlock_irqrestore(&target_list_lock, flags);
+		netconsole_subsys.su_group.default_groups = groups;
+	}
+
 	mutex_init(&netconsole_subsys.su_mutex);
-	return configfs_register_subsystem(&netconsole_subsys);
+
+	err = configfs_register_subsystem(&netconsole_subsys);
+	if (err)
+		kfree(netconsole_subsys.su_group.default_groups);
+
+	return err;
 }
 
 static void __exit dynamic_netconsole_exit(void)
 {
 	configfs_unregister_subsystem(&netconsole_subsys);
+	kfree(netconsole_subsys.su_group.default_groups);
 }
 
 /*
@@ -122,14 +155,23 @@ static void __exit dynamic_netconsole_exit(void)
  */
 static void netconsole_target_get(struct netconsole_target *nt)
 {
-	if (config_item_name(&nt->item))
-		config_item_get(&nt->item);
+	if (config_item_name(&nt->group.cg_item))
+		config_item_get(&nt->group.cg_item);
 }
 
 static void netconsole_target_put(struct netconsole_target *nt)
 {
-	if (config_item_name(&nt->item))
-		config_item_put(&nt->item);
+	if (config_item_name(&nt->group.cg_item))
+		config_item_put(&nt->group.cg_item);
+}
+
+static void dynamic_netconsole_init_type_name(struct netconsole_target *nt,
+						int index)
+{
+	char name[16];
+	snprintf(name, sizeof(name), "netcon%d", index);
+	config_item_init_type_name(&nt->group.cg_item, name,
+				&netconsole_target_type);
 }
 
 #else	/* !CONFIG_NETCONSOLE_DYNAMIC */
@@ -155,6 +197,11 @@ static void netconsole_target_put(struct netconsole_target *nt)
 {
 }
 
+static void dynamic_netconsole_init_type_name(struct netconsole_target *nt,
+						int index)
+{
+}
+
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
 /* Allocate new target (from boot/module param) and setup netpoll for it */
@@ -236,8 +283,8 @@ struct netconsole_target_attr {
 static struct netconsole_target *to_target(struct config_item *item)
 {
 	return item ?
-		container_of(item, struct netconsole_target, item) :
-		NULL;
+		container_of(to_config_group(item), struct netconsole_target,
+			group) : NULL;
 }
 
 /*
@@ -370,7 +417,7 @@ static ssize_t store_dev_name(struct netconsole_target *nt,
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
 				"disable to update parameters\n",
-				config_item_name(&nt->item));
+				config_item_name(&nt->group.cg_item));
 		return -EINVAL;
 	}
 
@@ -394,7 +441,7 @@ static ssize_t store_local_port(struct netconsole_target *nt,
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
 				"disable to update parameters\n",
-				config_item_name(&nt->item));
+				config_item_name(&nt->group.cg_item));
 		return -EINVAL;
 	}
 
@@ -417,7 +464,7 @@ static ssize_t store_remote_port(struct netconsole_target *nt,
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
 				"disable to update parameters\n",
-				config_item_name(&nt->item));
+				config_item_name(&nt->group.cg_item));
 		return -EINVAL;
 	}
 
@@ -437,7 +484,7 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
 				"disable to update parameters\n",
-				config_item_name(&nt->item));
+				config_item_name(&nt->group.cg_item));
 		return -EINVAL;
 	}
 
@@ -453,7 +500,7 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
 				"disable to update parameters\n",
-				config_item_name(&nt->item));
+				config_item_name(&nt->group.cg_item));
 		return -EINVAL;
 	}
 
@@ -473,7 +520,7 @@ static ssize_t store_remote_mac(struct netconsole_target *nt,
 	if (nt->enabled) {
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "
 				"disable to update parameters\n",
-				config_item_name(&nt->item));
+				config_item_name(&nt->group.cg_item));
 		return -EINVAL;
 	}
 
@@ -608,14 +655,15 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
 
 	/* Initialize the config_item member */
-	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
+	config_item_init_type_name(&nt->group.cg_item, name,
+				&netconsole_target_type);
 
 	/* Adding, but it is disabled */
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_add(&nt->list, &target_list);
 	spin_unlock_irqrestore(&target_list_lock, flags);
 
-	return &nt->item;
+	return &nt->group.cg_item;
 }
 
 static void drop_netconsole_target(struct config_group *group,
@@ -635,7 +683,7 @@ static void drop_netconsole_target(struct config_group *group,
 	if (nt->enabled)
 		netpoll_cleanup(&nt->np);
 
-	config_item_put(&nt->item);
+	config_item_put(&nt->group.cg_item);
 }
 
 static struct configfs_group_operations netconsole_subsys_group_ops = {
@@ -741,6 +789,7 @@ static int __init init_netconsole(void)
 	unsigned long flags;
 	char *target_config;
 	char *input = config;
+	int i = 0;
 
 	if (strnlen(input, MAX_PARAM_LENGTH)) {
 		while ((target_config = strsep(&input, ";"))) {
@@ -749,9 +798,13 @@ static int __init init_netconsole(void)
 				err = PTR_ERR(nt);
 				goto fail;
 			}
+
+			dynamic_netconsole_init_type_name(nt, i);
+
 			spin_lock_irqsave(&target_list_lock, flags);
 			list_add(&nt->list, &target_list);
 			spin_unlock_irqrestore(&target_list_lock, flags);
+			i++;
 		}
 	}
 
@@ -759,7 +812,7 @@ static int __init init_netconsole(void)
 	if (err)
 		goto fail;
 
-	err = dynamic_netconsole_init();
+	err = dynamic_netconsole_init(i);
 	if (err)
 		goto undonotifier;
 
-- 
1.5.3.rc5

