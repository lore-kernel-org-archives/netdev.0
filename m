From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 05/10] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Fri, 24 Aug 2012 16:01:39 +0200
Message-ID: <1345816904-21745-6-git-send-email-wagi@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:40410 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498Ab2HXOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 10:01:50 -0400
In-Reply-To: <1345816904-21745-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

CGROUP_BUILTIN_SUBSYS_COUNT is used as start or stop point
when looping over the subsys array. Since the subsys array is
64 entries long this is a good thing to do. Though we'd like
to reduce the array size considerable but we need to get rid
of CGROUP_BUILTIN_SUBSYS_COUNT to ease up the review process.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/linux/cgroup.h |  1 -
 kernel/cgroup.c        | 75 +++++++++++++++++++++++++++++++-------------------
 2 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c90eaa8..3787872 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -47,7 +47,6 @@ extern const struct file_operations proc_cgroup_operations;
 #define SUBSYS(_x) _x ## _subsys_id,
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
-	CGROUP_BUILTIN_SUBSYS_COUNT
 };
 #undef SUBSYS
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7981850..f9433b4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -88,7 +88,7 @@ static DEFINE_MUTEX(cgroup_root_mutex);
 
 /*
  * Generate an array of cgroup subsystem pointers. At boot time, this is
- * populated up to CGROUP_BUILTIN_SUBSYS_COUNT, and modular subsystems are
+ * populated with the built in subsystems, and modular subsystems are
  * registered after that. The mutable section of this array is protected by
  * cgroup_mutex.
  */
@@ -1291,11 +1291,13 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	 * take duplicate reference counts on a subsystem that's already used,
 	 * but rebind_subsystems handles this case.
 	 */
-	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit = 1UL << i;
 
 		if (!(bit & opts->subsys_bits))
 			continue;
+		if (!subsys[i]->module)
+			continue;
 		if (!try_module_get(subsys[i]->module)) {
 			module_pin_failed = true;
 			break;
@@ -1307,12 +1309,14 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 		 * raced with a module_delete call, and to the user this is
 		 * essentially a "subsystem doesn't exist" case.
 		 */
-		for (i--; i >= CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
+		for (i--; i > 1; i--) {
 			/* drop refcounts only on the ones we took */
 			unsigned long bit = 1UL << i;
 
 			if (!(bit & opts->subsys_bits))
 				continue;
+			if (!subsys[i]->module)
+				continue;
 			module_put(subsys[i]->module);
 		}
 		return -ENOENT;
@@ -1324,11 +1328,13 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 static void drop_parsed_module_refcounts(unsigned long subsys_bits)
 {
 	int i;
-	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit = 1UL << i;
 
 		if (!(bit & subsys_bits))
 			continue;
+		if (!subsys[i]->module)
+			continue;
 		module_put(subsys[i]->module);
 	}
 }
@@ -1401,6 +1407,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	mutex_init(&cgrp->pidlist_mutex);
 	INIT_LIST_HEAD(&cgrp->event_list);
 	spin_lock_init(&cgrp->event_list_lock);
+	memset(cgrp->subsys, 0, sizeof(cgrp->subsys));
 }
 
 static void init_cgroup_root(struct cgroupfs_root *root)
@@ -4321,8 +4328,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 * since cgroup_init_subsys will have already taken care of it.
 	 */
 	if (ss->module == NULL) {
-		/* a few sanity checks */
-		BUG_ON(ss->subsys_id >= CGROUP_BUILTIN_SUBSYS_COUNT);
+		/* a sanity check */
 		BUG_ON(subsys[ss->subsys_id] != ss);
 		return 0;
 	}
@@ -4336,7 +4342,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 */
 	mutex_lock(&cgroup_mutex);
 	/* find the first empty slot in the array */
-	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		if (subsys[i] == NULL)
 			break;
 	}
@@ -4439,7 +4445,6 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 
 	mutex_lock(&cgroup_mutex);
 	/* deassign the subsys_id */
-	BUG_ON(ss->subsys_id < CGROUP_BUILTIN_SUBSYS_COUNT);
 	subsys[ss->subsys_id] = NULL;
 
 	/* remove subsystem from rootnode's list of subsystems */
@@ -4502,10 +4507,13 @@ int __init cgroup_init_early(void)
 	for (i = 0; i < CSS_SET_TABLE_SIZE; i++)
 		INIT_HLIST_HEAD(&css_set_table[i]);
 
-	/* at bootup time, we don't worry about modular subsystems */
-	for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
 
+		/* at bootup time, we don't worry about modular subsystems */
+		if (!ss || (ss && ss->module))
+			continue;
+
 		BUG_ON(!ss->name);
 		BUG_ON(strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN);
 		BUG_ON(!ss->create);
@@ -4538,9 +4546,12 @@ int __init cgroup_init(void)
 	if (err)
 		return err;
 
-	/* at bootup time, we don't worry about modular subsystems */
-	for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
+
+		/* at bootup time, we don't worry about modular subsystems */
+		if (!ss || (ss && ss->module))
+			continue;
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 		if (ss->use_id)
@@ -4735,13 +4746,16 @@ void cgroup_fork_callbacks(struct task_struct *child)
 {
 	if (need_forkexit_callback) {
 		int i;
-		/*
-		 * forkexit callbacks are only supported for builtin
-		 * subsystems, and the builtin section of the subsys array is
-		 * immutable, so we don't need to lock the subsys array here.
-		 */
-		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
+
+			/*
+			 * forkexit callbacks are only supported for
+			 * builtin subsystems.
+			 */
+			if (!ss || (ss && ss->module))
+				continue;
+
 			if (ss->fork)
 				ss->fork(child);
 		}
@@ -4846,12 +4860,13 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	tsk->cgroups = &init_css_set;
 
 	if (run_callbacks && need_forkexit_callback) {
-		/*
-		 * modular subsystems can't use callbacks, so no need to lock
-		 * the subsys array
-		 */
-		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
+
+			/* modular subsystems can't use callbacks */
+			if (!ss || (ss && ss->module))
+				continue;
+
 			if (ss->exit) {
 				struct cgroup *old_cgrp =
 					rcu_dereference_raw(cg->subsys[i])->cgroup;
@@ -5037,13 +5052,17 @@ static int __init cgroup_disable(char *str)
 	while ((token = strsep(&str, ",")) != NULL) {
 		if (!*token)
 			continue;
-		/*
-		 * cgroup_disable, being at boot time, can't know about module
-		 * subsystems, so we don't worry about them.
-		 */
-		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 
+			/*
+			 * cgroup_disable, being at boot time, can't
+			 * know about module subsystems, so we don't
+			 * worry about them.
+			 */
+			if (!ss || (ss && ss->module))
+				continue;
+
 			if (!strcmp(token, ss->name)) {
 				ss->disabled = 1;
 				printk(KERN_INFO "Disabling %s control group"
-- 
1.7.12.rc1.16.g05a20c8
