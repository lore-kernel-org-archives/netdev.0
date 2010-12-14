From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 09/22] netconsole: Add pointer to netpoll_targets
Date: Tue, 14 Dec 2010 13:29:43 -0800
Message-ID: <20101214212942.17022.75768.stgit@mike.mtv.corp.google.com>
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

For each netconsole_target, we'd like to get back at the parenting
netpoll_targets structure so that we can access the locking and list
fields.  Add a pointer that points to the netpoll_targets structure.  We
don't have to maintain reference counting because a netpoll_targets will
always out-live their children netconsole_target structures.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |   71 +++++++++++++++++++++++++++++-----------------
 1 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 57451a7..6ab41f8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -107,6 +107,7 @@ static DEFINE_NETPOLL_TARGETS(targets);
  *		remote_mac	(read-write)
  */
 struct netconsole_target {
+	struct netpoll_targets *nts;
 	struct list_head	list;
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
 	struct config_item	item;
@@ -122,21 +123,25 @@ static void netconsole_target_put(struct netconsole_target *nt);
 static void deferred_netpoll_cleanup(struct work_struct *work)
 {
 	struct netconsole_target *nt;
+	struct netpoll_targets *nts;
 	unsigned long flags;
 
 	nt = container_of(work, struct netconsole_target, cleanup_work);
+	nts = nt->nts;
+
 	netpoll_cleanup(&nt->np);
 
-	spin_lock_irqsave(&targets.lock, flags);
+	spin_lock_irqsave(&nts->lock, flags);
 	BUG_ON(nt->np_state != NETPOLL_CLEANING);
 	nt->np_state = NETPOLL_DISABLED;
-	spin_unlock_irqrestore(&targets.lock, flags);
+	spin_unlock_irqrestore(&nts->lock, flags);
 
 	netconsole_target_put(nt);
 }
 
 /* Allocate new target (from boot/module param) and setup netpoll for it */
-static struct netconsole_target *alloc_param_target(char *target_config)
+static struct netconsole_target *alloc_param_target(struct netpoll_targets *nts,
+						    char *target_config)
 {
 	int err = -ENOMEM;
 	struct netconsole_target *nt;
@@ -151,6 +156,7 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 		goto fail;
 	}
 
+	nt->nts = nts;
 	nt->np.name = "netconsole";
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
@@ -308,6 +314,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			     const char *buf,
 			     size_t count)
 {
+	struct netpoll_targets *nts = nt->nts;
 	unsigned long flags;
 	int err;
 	long enabled;
@@ -317,7 +324,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return enabled;
 
 	if (enabled) {	/* 1 */
-		spin_lock_irqsave(&targets.lock, flags);
+		spin_lock_irqsave(&nts->lock, flags);
 		if (nt->np_state != NETPOLL_DISABLED)
 			goto busy;
 		else {
@@ -329,7 +336,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			 * because there is a reference implicitly held by the
 			 * caller of the store operation.
 			 */
-			spin_unlock_irqrestore(&targets.lock, flags);
+			spin_unlock_irqrestore(&nts->lock, flags);
 		}
 
 		/*
@@ -339,34 +346,34 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		netpoll_print_options(&nt->np);
 
 		err = netpoll_setup(&nt->np);
-		spin_lock_irqsave(&targets.lock, flags);
+		spin_lock_irqsave(&nts->lock, flags);
 		if (err)
 			nt->np_state = NETPOLL_DISABLED;
 		else
 			nt->np_state = NETPOLL_ENABLED;
-		spin_unlock_irqrestore(&targets.lock, flags);
+		spin_unlock_irqrestore(&nts->lock, flags);
 		if (err)
 			return err;
 
 		printk(KERN_INFO "netconsole: network logging started\n");
 	} else {	/* 0 */
-		spin_lock_irqsave(&targets.lock, flags);
+		spin_lock_irqsave(&nts->lock, flags);
 		if (nt->np_state == NETPOLL_ENABLED)
 			nt->np_state = NETPOLL_CLEANING;
 		else if (nt->np_state != NETPOLL_DISABLED)
 			goto busy;
-		spin_unlock_irqrestore(&targets.lock, flags);
+		spin_unlock_irqrestore(&nts->lock, flags);
 
 		netpoll_cleanup(&nt->np);
 
-		spin_lock_irqsave(&targets.lock, flags);
+		spin_lock_irqsave(&nts->lock, flags);
 		nt->np_state = NETPOLL_DISABLED;
-		spin_unlock_irqrestore(&targets.lock, flags);
+		spin_unlock_irqrestore(&nts->lock, flags);
 	}
 
 	return strnlen(buf, count);
 busy:
-	spin_unlock_irqrestore(&targets.lock, flags);
+	spin_unlock_irqrestore(&nts->lock, flags);
 	return -EBUSY;
 }
 
@@ -481,29 +488,31 @@ static ssize_t store_locked_##_name(struct netconsole_target *nt,	\
 				    const char *buf,			\
 				    size_t count)			\
 {									\
+	struct netpoll_targets *nts = nt->nts;				\
 	unsigned long flags;						\
 	ssize_t ret;							\
-	spin_lock_irqsave(&targets.lock, flags);			\
+	spin_lock_irqsave(&nts->lock, flags);				\
 	if (nt->np_state != NETPOLL_DISABLED) {				\
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "	\
 				"disable to update parameters\n",	\
 				config_item_name(&nt->item));		\
-		spin_unlock_irqrestore(&targets.lock, flags);		\
+		spin_unlock_irqrestore(&nts->lock, flags);		\
 		return -EBUSY;						\
 	}								\
 	ret = store_##_name(nt, buf, count);				\
-	spin_unlock_irqrestore(&targets.lock, flags);			\
+	spin_unlock_irqrestore(&nts->lock, flags);			\
 	return ret;							\
 }
 
 #define NETCONSOLE_WRAP_ATTR_SHOW(_name)				\
 static ssize_t show_locked_##_name(struct netconsole_target *nt, char *buf) \
 {									\
+	struct netpoll_targets *nts = nt->nts;				\
 	unsigned long flags;						\
 	ssize_t ret;							\
-	spin_lock_irqsave(&targets.lock, flags);			\
+	spin_lock_irqsave(&nts->lock, flags);				\
 	ret = show_##_name(nt, buf);					\
-	spin_unlock_irqrestore(&targets.lock, flags);			\
+	spin_unlock_irqrestore(&nts->lock, flags);			\
 	return ret;							\
 }
 
@@ -589,6 +598,13 @@ static struct config_item_type netconsole_target_type = {
 	.ct_owner		= THIS_MODULE,
 };
 
+static struct netpoll_targets *group_to_targets(struct config_group *group)
+{
+	struct configfs_subsystem *subsys;
+	subsys = container_of(group, struct configfs_subsystem, su_group);
+	return container_of(subsys, struct netpoll_targets, configfs_subsys);
+}
+
 /*
  * Group operations and type for netconsole_subsys.
  */
@@ -596,8 +612,9 @@ static struct config_item_type netconsole_target_type = {
 static struct config_item *make_netconsole_target(struct config_group *group,
 						  const char *name)
 {
-	unsigned long flags;
+	struct netpoll_targets *nts = group_to_targets(group);
 	struct netconsole_target *nt;
+	unsigned long flags;
 
 	/*
 	 * Allocate and initialize with defaults.
@@ -609,6 +626,7 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	nt->nts = nts;
 	nt->np.name = "netconsole";
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
@@ -620,9 +638,9 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
 
 	/* Adding, but it is disabled */
-	spin_lock_irqsave(&targets.lock, flags);
-	list_add(&nt->list, &targets.list);
-	spin_unlock_irqrestore(&targets.lock, flags);
+	spin_lock_irqsave(&nts->lock, flags);
+	list_add(&nt->list, &nts->list);
+	spin_unlock_irqrestore(&nts->lock, flags);
 
 	return &nt->item;
 }
@@ -630,12 +648,13 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 static void drop_netconsole_target(struct config_group *group,
 				   struct config_item *item)
 {
-	unsigned long flags;
+	struct netpoll_targets *nts = group_to_targets(group);
 	struct netconsole_target *nt = to_target(item);
+	unsigned long flags;
 
-	spin_lock_irqsave(&targets.lock, flags);
+	spin_lock_irqsave(&nts->lock, flags);
 	list_del(&nt->list);
-	spin_unlock_irqrestore(&targets.lock, flags);
+	spin_unlock_irqrestore(&nts->lock, flags);
 
 	/*
 	 * The target may have never been disabled, or was disabled due
@@ -726,7 +745,7 @@ static void netconsole_target_put(struct netconsole_target *nt)
 
 /*
  * Call netpoll_cleanup on this target asynchronously.
- * targets.lock is required.
+ * nts->lock is required.
  */
 static void defer_netpoll_cleanup(struct netconsole_target *nt)
 {
@@ -830,7 +849,7 @@ static int __init register_netpoll_targets(const char *subsys_name,
 
 	if (strnlen(input, MAX_PARAM_LENGTH)) {
 		while ((target_config = strsep(&input, ";"))) {
-			nt = alloc_param_target(target_config);
+			nt = alloc_param_target(nts, target_config);
 			if (IS_ERR(nt)) {
 				err = PTR_ERR(nt);
 				goto fail;
