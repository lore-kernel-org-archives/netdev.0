From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 06/22] netconsole: Push configfs_subsystem into
	netpoll_targets
Date: Tue, 14 Dec 2010 13:29:26 -0800
Message-ID: <20101214212926.17022.72702.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is a step in the preparation of pushing the target handling
code out of netconsole and into netpoll proper where it can be used by
other clients.

Here, we move the configfs_subsystem bits out of global scope and
package it in the netpoll_targets structure that will maintain a set of
targets.  There is a bit of code that is rearranged due to needing to
provide netconsole_subsys_type in scope much earlier in the file.  This
has the added benefit of folding all of the dynamic target handling code
under a single #ifdef CONFIG_NETCONSOLE_DYNAMIC block.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |  132 ++++++++++++++++++++++------------------------
 1 files changed, 64 insertions(+), 68 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 3aa7151..aa95b91 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -68,6 +68,9 @@ __setup("netconsole=", option_setup);
 struct netpoll_targets {
 	struct list_head list;
 	spinlock_t lock;
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+	struct configfs_subsystem configfs_subsys;
+#endif
 };
 #define DEFINE_NETPOLL_TARGETS(x) struct netpoll_targets x = \
 	{ .list = LIST_HEAD_INIT(x.list), \
@@ -112,63 +115,8 @@ struct netconsole_target {
 	struct work_struct	cleanup_work;
 };
 
-#ifdef	CONFIG_NETCONSOLE_DYNAMIC
-
-static struct configfs_subsystem netconsole_subsys;
-
-static int __init dynamic_netconsole_init(void)
-{
-	config_group_init(&netconsole_subsys.su_group);
-	mutex_init(&netconsole_subsys.su_mutex);
-	return configfs_register_subsystem(&netconsole_subsys);
-}
-
-static void __exit dynamic_netconsole_exit(void)
-{
-	configfs_unregister_subsystem(&netconsole_subsys);
-}
-
-/*
- * Targets that were created by parsing the boot/module option string
- * do not exist in the configfs hierarchy (and have NULL names) and will
- * never go away, so make these a no-op for them.
- */
-static void netconsole_target_get(struct netconsole_target *nt)
-{
-	if (config_item_name(&nt->item))
-		config_item_get(&nt->item);
-}
-
-static void netconsole_target_put(struct netconsole_target *nt)
-{
-	if (config_item_name(&nt->item))
-		config_item_put(&nt->item);
-}
-
-#else	/* !CONFIG_NETCONSOLE_DYNAMIC */
-
-static int __init dynamic_netconsole_init(void)
-{
-	return 0;
-}
-
-static void __exit dynamic_netconsole_exit(void)
-{
-}
-
-/*
- * No danger of targets going away from under us when dynamic
- * reconfigurability is off.
- */
-static void netconsole_target_get(struct netconsole_target *nt)
-{
-}
-
-static void netconsole_target_put(struct netconsole_target *nt)
-{
-}
-
-#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
+static void netconsole_target_get(struct netconsole_target *nt);
+static void netconsole_target_put(struct netconsole_target *nt);
 
 static void deferred_netpoll_cleanup(struct work_struct *work)
 {
@@ -714,15 +662,63 @@ static struct config_item_type netconsole_subsys_type = {
 	.ct_owner	= THIS_MODULE,
 };
 
-/* The netconsole configfs subsystem */
-static struct configfs_subsystem netconsole_subsys = {
-	.su_group	= {
-		.cg_item	= {
-			.ci_namebuf	= "netconsole",
-			.ci_type	= &netconsole_subsys_type,
-		},
-	},
-};
+static int __init dynamic_netpoll_targets_init(struct netpoll_targets *nts)
+{
+	struct configfs_subsystem *subsys = &nts->configfs_subsys;
+
+	config_group_init(&subsys->su_group);
+	mutex_init(&subsys->su_mutex);
+	strncpy((char *)&subsys->su_group.cg_item.ci_namebuf, "netconsole",
+		CONFIGFS_ITEM_NAME_LEN);
+	subsys->su_group.cg_item.ci_type = &netconsole_subsys_type;
+	return configfs_register_subsystem(subsys);
+}
+
+static void __exit dynamic_netpoll_targets_exit(struct netpoll_targets *nts)
+{
+	configfs_unregister_subsystem(&nts->configfs_subsys);
+}
+
+/*
+ * Targets that were created by parsing the boot/module option string
+ * do not exist in the configfs hierarchy (and have NULL names) and will
+ * never go away, so make these a no-op for them.
+ */
+static void netconsole_target_get(struct netconsole_target *nt)
+{
+	if (config_item_name(&nt->item))
+		config_item_get(&nt->item);
+}
+
+static void netconsole_target_put(struct netconsole_target *nt)
+{
+	if (config_item_name(&nt->item))
+		config_item_put(&nt->item);
+}
+
+#else	/* !CONFIG_NETCONSOLE_DYNAMIC */
+
+static int __init dynamic_netpoll_targets_init(const char *subsys_name,
+					       struct netpoll_targets *nts)
+{
+	return 0;
+}
+
+static void __exit dynamic_netpoll_targets_exit(struct netpoll_targets *nts)
+{
+}
+
+/*
+ * No danger of targets going away from under us when dynamic
+ * reconfigurability is off.
+ */
+static void netconsole_target_get(struct netconsole_target *nt)
+{
+}
+
+static void netconsole_target_put(struct netconsole_target *nt)
+{
+}
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
@@ -850,7 +846,7 @@ static int __init init_netconsole(void)
 	if (err)
 		goto fail;
 
-	err = dynamic_netconsole_init();
+	err = dynamic_netpoll_targets_init(&targets);
 	if (err)
 		goto undonotifier;
 
@@ -883,7 +879,7 @@ static void __exit cleanup_netconsole(void)
 	struct netconsole_target *nt, *tmp;
 
 	unregister_console(&netconsole);
-	dynamic_netconsole_exit();
+	dynamic_netpoll_targets_exit(&targets);
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 
 	/*
