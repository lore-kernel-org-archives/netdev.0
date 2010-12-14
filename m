From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 11/22] netconsole: Abstract away the subsystem name
Date: Tue, 14 Dec 2010 13:29:54 -0800
Message-ID: <20101214212953.17022.62869.stgit@mike.mtv.corp.google.com>
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

Remove any hardcoded instances of "netconsole" and keep a new copy in
netpoll_targets.  We could perhaps use the copy that is stored in the
configfs group's name, but that isn't always available depending on
build config options,and maintaining the extra string is just easier.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |   50 +++++++++++++++++++++++++++++-----------------
 1 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 2f6282d..5c8701f 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -72,6 +72,7 @@ struct netpoll_targets {
 	struct configfs_subsystem configfs_subsys;
 #endif
 	struct notifier_block netdev_notifier;
+	char *subsys_name;
 };
 #define DEFINE_NETPOLL_TARGETS(x) struct netpoll_targets x = \
 	{ .list = LIST_HEAD_INIT(x.list), \
@@ -152,12 +153,13 @@ static struct netpoll_target *alloc_param_target(struct netpoll_targets *nts,
 	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
 	if (!nt) {
-		printk(KERN_ERR "netconsole: failed to allocate memory\n");
+		printk(KERN_ERR "%s: failed to allocate memory\n",
+		       nts->subsys_name);
 		goto fail;
 	}
 
 	nt->nts = nts;
-	nt->np.name = "netconsole";
+	nt->np.name = nts->subsys_name;
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
@@ -196,7 +198,7 @@ static void free_param_target(struct netpoll_target *nt)
 /*
  * Our subsystem hierarchy is:
  *
- * /sys/kernel/config/netconsole/
+ * /sys/kernel/config/<subsys_name>/
  *				|
  *				<target>/
  *				|	enabled
@@ -232,7 +234,8 @@ static struct netpoll_target *to_target(struct config_item *item)
  * We return (signed) long only because we may want to return errors.
  * Do not use this to convert numbers that are allowed to be negative.
  */
-static long strtol10_check_range(const char *cp, long min, long max)
+static long strtol10_check_range(struct netpoll_targets *nts,
+				 const char *cp, long min, long max)
 {
 	long ret;
 	char *p = (char *) cp;
@@ -243,12 +246,12 @@ static long strtol10_check_range(const char *cp, long min, long max)
 	ret = simple_strtol(p, &p, 10);
 
 	if (*p && (*p != '\n')) {
-		printk(KERN_ERR "netconsole: invalid input\n");
+		printk(KERN_ERR "%s: invalid input\n", nts->subsys_name);
 		return -EINVAL;
 	}
 	if ((ret < min) || (ret > max)) {
-		printk(KERN_ERR "netconsole: input %ld must be between "
-				"%ld and %ld\n", ret, min, max);
+		printk(KERN_ERR "%s: input %ld must be between %ld and %ld\n",
+		       nts->subsys_name, ret, min, max);
 		return -EINVAL;
 	}
 
@@ -319,7 +322,7 @@ static ssize_t store_enabled(struct netpoll_target *nt,
 	int err;
 	long enabled;
 
-	enabled = strtol10_check_range(buf, 0, 1);
+	enabled = strtol10_check_range(nts, buf, 0, 1);
 	if (enabled < 0)
 		return enabled;
 
@@ -355,7 +358,8 @@ static ssize_t store_enabled(struct netpoll_target *nt,
 		if (err)
 			return err;
 
-		printk(KERN_INFO "netconsole: network logging started\n");
+		printk(KERN_INFO "%s: network logging started\n",
+		       nts->subsys_name);
 	} else {	/* 0 */
 		spin_lock_irqsave(&nts->lock, flags);
 		if (nt->np_state == NETPOLL_ENABLED)
@@ -400,7 +404,7 @@ static ssize_t store_local_port(struct netpoll_target *nt,
 	long local_port;
 #define __U16_MAX	((__u16) ~0U)
 
-	local_port = strtol10_check_range(buf, 0, __U16_MAX);
+	local_port = strtol10_check_range(nt->nts, buf, 0, __U16_MAX);
 	if (local_port < 0)
 		return local_port;
 
@@ -416,7 +420,7 @@ static ssize_t store_remote_port(struct netpoll_target *nt,
 	long remote_port;
 #define __U16_MAX	((__u16) ~0U)
 
-	remote_port = strtol10_check_range(buf, 0, __U16_MAX);
+	remote_port = strtol10_check_range(nt->nts, buf, 0, __U16_MAX);
 	if (remote_port < 0)
 		return remote_port;
 
@@ -466,7 +470,7 @@ static ssize_t store_remote_mac(struct netpoll_target *nt,
 	return strnlen(buf, count);
 
 invalid:
-	printk(KERN_ERR "netconsole: invalid input\n");
+	printk(KERN_ERR "%s: invalid input\n", nt->nts->subsys_name);
 	return -EINVAL;
 }
 
@@ -493,8 +497,9 @@ static ssize_t store_locked_##_name(struct netpoll_target *nt,		\
 	ssize_t ret;							\
 	spin_lock_irqsave(&nts->lock, flags);				\
 	if (nt->np_state != NETPOLL_DISABLED) {				\
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "	\
+		printk(KERN_ERR "%s: target (%s) is enabled, "		\
 				"disable to update parameters\n",	\
+				nts->subsys_name,			\
 				config_item_name(&nt->item));		\
 		spin_unlock_irqrestore(&nts->lock, flags);		\
 		return -EBUSY;						\
@@ -622,12 +627,13 @@ static struct config_item *make_netpoll_target(struct config_group *group,
 	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
 	if (!nt) {
-		printk(KERN_ERR "netconsole: failed to allocate memory\n");
+		printk(KERN_ERR "%s: failed to allocate memory\n",
+		       nts->subsys_name);
 		return ERR_PTR(-ENOMEM);
 	}
 
 	nt->nts = nts;
-	nt->np.name = "netconsole";
+	nt->np.name = nts->subsys_name;
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
@@ -790,8 +796,8 @@ static int netpoll_targets_netdev_event(struct notifier_block *this,
 	}
 	spin_unlock_irqrestore(&nts->lock, flags);
 	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
-		printk(KERN_INFO "netconsole: network logging stopped, "
-			"interface %s %s\n",  dev->name,
+		printk(KERN_INFO "%s: network logging stopped, "
+			"interface %s %s\n", nts->subsys_name, dev->name,
 			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
 
 done:
@@ -866,12 +872,19 @@ static int __init register_netpoll_targets(const char *subsys_name,
 	if (err)
 		goto fail;
 
+	nts->subsys_name = kstrdup(subsys_name, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!nts->subsys_name)
+		goto undonotifier;
+
 	err = dynamic_netpoll_targets_init(subsys_name, nts);
 	if (err)
-		goto undonotifier;
+		goto free_subsys_name;
 
 	return 0;
 
+free_subsys_name:
+	kfree(nts->subsys_name);
 undonotifier:
 	unregister_netdevice_notifier(&nts->netdev_notifier);
 fail:
@@ -907,6 +920,7 @@ static void __exit unregister_netpoll_targets(struct netpoll_targets *nts)
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
+	kfree(nts->subsys_name);
 }
 
 static int __init init_netconsole(void)
