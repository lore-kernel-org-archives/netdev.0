From: Ben Blum <bblum@andrew.cmu.edu>
Subject: [RFC] [PATCH 4/5] cgroups: subsystem module unloading
Date: Fri, 4 Dec 2009 03:58:16 -0500
Message-ID: <20091204085816.GD18912@andrew.cmu.edu>
References: <20091204085349.GA18867@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, lizf@cn.fujitsu.com,
	akpm@linux-foundation.org, menage@google.com, bblum@andrew.cmu.edu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932072AbZLDI7I@vger.kernel.org>
Content-Disposition: attachment; filename="cgroups-subsys-unloading.patch"
In-Reply-To: <20091204085349.GA18867@andrew.cmu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provides support for unloading modular subsystems.

From: Ben Blum <bblum@andrew.cmu.edu>

This patch adds a new function cgroup_unload_subsys which is to be used for
removing a loaded subsystem during module deletion. Reference counting of the
subsystems' modules is moved from once (at load time) to once per attached
hierarchy (in rebind_subsystems) (i.e., 0 or 1).

It also adds a proper module_delete call in net/sched/cls_cgroup.c.

Signed-off-by: Ben Blum <bblum@andrew.cmu.edu>
---

 Documentation/cgroups/cgroups.txt |    3 +
 include/linux/cgroup.h            |    4 +-
 kernel/cgroup.c                   |   92 ++++++++++++++++++++++++++++++++-----
 net/sched/cls_cgroup.c            |    3 -
 4 files changed, 86 insertions(+), 16 deletions(-)


diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index dd0d6f1..110228e 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -493,7 +493,8 @@ Each subsystem should:
 - define a cgroup_subsys object called <name>_subsys
 
 If a subsystem can be compiled as a module, it should also have in its
-module initcall a call to cgroup_load_subsys().
+module initcall a call to cgroup_load_subsys(), and in its exitcall a
+call to cgroup_unload_subsys().
 
 Each subsystem may export the following methods. The only mandatory
 methods are create/destroy. Any others that are null are presumed to
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c8474c4..1cbb07f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -39,6 +39,7 @@ extern void cgroup_fork_failed(struct task_struct *p, int run_callbacks,
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
 extern int cgroup_load_subsys(struct cgroup_subsys *ss);
+extern void cgroup_unload_subsys(struct cgroup_subsys *ss);
 
 extern struct file_operations proc_cgroup_operations;
 
@@ -264,7 +265,8 @@ struct css_set {
 	/*
 	 * Set of subsystem states, one for each subsystem. This array
 	 * is immutable after creation apart from the init_css_set
-	 * during subsystem registration (at boot time).
+	 * during subsystem registration (at boot time) and modular subsystem
+	 * loading/unloading.
 	 */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 858a786..c2c7681 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -883,7 +883,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 {
 	unsigned long added_bits, removed_bits;
 	struct cgroup *cgrp = &root->top_cgroup;
-	int i;
+	int i, module_pin_failed = 0;
 
 	BUG_ON(!rwsem_is_locked(&subsys_mutex));
 
@@ -914,6 +914,27 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	if (root->number_of_cgroups > 1)
 		return -EBUSY;
 
+	/* pin the modules for all subsystems that will stop being free. we
+	 * don't drop refcounts on removed subsystems until later, since there
+	 * are failure cases here. */
+	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+		unsigned long bit = 1UL << i;
+		if (!(bit & added_bits))
+			continue;
+		if (!try_module_get(subsys[i]->module)) {
+			module_pin_failed = 1;
+			break;
+		}
+	}
+	if (module_pin_failed) {
+		/* oops, one of the modules was going away. this means that we
+		 * raced with a module_delete call, and to the user this is
+		 * essentially a "subsystem doesn't exist" case. */
+		for (i--; i >= CGROUP_BUILTIN_SUBSYS_COUNT; i--)
+			module_put(subsys[i]->module);
+		return -ENOENT;
+	}
+
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
@@ -932,8 +953,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			if (ss->bind)
 				ss->bind(ss, cgrp);
 			mutex_unlock(&ss->hierarchy_mutex);
-			/* TODO: If subsystem unloading support, need to take
-			 * a reference on the subsystem here. */
+			/* we already got the reference for this subsystem. */
 		} else if (bit & removed_bits) {
 			/* We're removing this subsystem */
 			BUG_ON(ss == NULL);
@@ -947,8 +967,8 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			subsys[i]->root = &rootnode;
 			list_move(&ss->sibling, &rootnode.subsys_list);
 			mutex_unlock(&ss->hierarchy_mutex);
-			/* TODO: If subsystem unloading support, drop refcount
-			 * here. */
+			/* subsystem is now free - drop reference on module */
+			module_put(ss->module);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
 			BUG_ON(ss == NULL);
@@ -1395,7 +1415,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		}
 
 		ret = rebind_subsystems(root, root->subsys_bits);
-		if (ret == -EBUSY) {
+		if (ret == -EBUSY || ret == -ENOENT) {
 			mutex_unlock(&cgroup_mutex);
 			mutex_unlock(&inode->i_mutex);
 			free_cg_links(&tmp_cg_links);
@@ -1404,7 +1424,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		/* done with subsys stuff and no other failure case */
 		up_read(&subsys_mutex);
 
-		/* EBUSY should be the only error here */
+		/* EBUSY and ENOENT should be the only errors here */
 		BUG_ON(ret);
 
 		list_add(&root->root_list, &roots);
@@ -3760,11 +3780,6 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
 	ss->active = 1;
 
-	/* pin the subsystem's module so it doesn't go away. this shouldn't
-	 * fail, since the module's initcall calls us.
-	 * TODO: with module unloading, move this elsewhere */
-	BUG_ON(!try_module_get(ss->module));
-
 	/* success! */
 	mutex_unlock(&cgroup_mutex);
 	up_write(&subsys_mutex);
@@ -3773,6 +3788,59 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 EXPORT_SYMBOL_GPL(cgroup_load_subsys);
 
 /**
+ * cgroup_unload_subsys: unload a modular subsystem
+ * @ss: the subsystem to unload
+ *
+ * This function should be called in a modular subsystem's exitcall. When this
+ * function is invoked, the refcount on the subsystem's module will be 0, so
+ * the subsystem will not be attached to any hierarchy.
+ */
+void cgroup_unload_subsys(struct cgroup_subsys *ss)
+{
+	struct cg_cgroup_link *link;
+	struct hlist_head *hhead;
+
+	BUG_ON(ss->module == NULL);
+
+	/* we shouldn't be called if the subsystem is in use, and the use of
+	 * try_module_get in rebind_subsystems should ensure that it doesn't
+	 * start being used while we're killing it off. */
+	BUG_ON(ss->root != &rootnode);
+
+	down_write(&subsys_mutex);
+	/* deassign the subsys_id */
+	BUG_ON(ss->subsys_id < CGROUP_BUILTIN_SUBSYS_COUNT);
+	subsys[ss->subsys_id] = NULL;
+
+	mutex_lock(&cgroup_mutex);
+	/* remove subsystem from rootnode's list of subsystems */
+	list_del(&ss->sibling);
+
+	/* disentangle the css from all css_sets attached to the dummytop. as
+	 * in loading, we need to pay our respects to the hashtable gods. */
+	write_lock(&css_set_lock);
+	list_for_each_entry(link, &dummytop->css_sets, cgrp_link_list) {
+		struct css_set *cg = link->cg;
+		hlist_del(&cg->hlist);
+		BUG_ON(!cg->subsys[ss->subsys_id]);
+		cg->subsys[ss->subsys_id] = NULL;
+		hhead = css_set_hash(cg->subsys);
+		hlist_add_head(&cg->hlist, hhead);
+	}
+	write_unlock(&css_set_lock);
+
+	/* remove subsystem's css from the dummytop and free it - need to free
+	 * before marking as null because ss->destroy needs the cgrp->subsys
+	 * pointer to find their state. */
+	ss->destroy(ss, dummytop);
+	dummytop->subsys[ss->subsys_id] = NULL;
+
+	mutex_unlock(&cgroup_mutex);
+	up_write(&subsys_mutex);
+}
+EXPORT_SYMBOL_GPL(cgroup_unload_subsys);
+
+/**
  * cgroup_init_early - cgroup initialization at system boot
  *
  * Initialize cgroups at system boot, and initialize any
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index df9723b..7f27d2c 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -300,8 +300,7 @@ static int __init init_cgroup_cls(void)
 static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
-	/* TODO: unload subsystem. for now, the try_module_get in load_subsys
-	 * prevents us from getting here. */
+	cgroup_unload_subsys(&net_cls_subsys);
 }
 
 module_init(init_cgroup_cls);
