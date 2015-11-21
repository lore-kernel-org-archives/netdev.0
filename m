From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/9] cgroup: record ancestor IDs and reimplement cgroup_is_descendant() using it
Date: Sat, 21 Nov 2015 11:13:53 -0500
Message-ID: <1448122441-9335-2-git-send-email-tj@kernel.org>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com, Tejun Heo <tj@kernel.org>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.co
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448122441-9335-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cgroup_is_descendant() currently walks up the hierarchy and compares
each ancestor to the cgroup in question.  While enough for cgroup core
usages, this can't be used in hot paths to test cgroup membership.
This patch adds cgroup->ancestor_ids[] which records the IDs of all
ancestors including self and cgroup->level for the nesting level.

This allows testing whether a given cgroup is a descendant of another
in three finite steps - testing whether the two belong to the same
hierarchy, whether the descendant candidate is at the same or a higher
level than the ancestor and comparing the recorded ancestor_id at the
matching level.  cgroup_is_descendant() is accordingly reimplmented
and made inline.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup-defs.h | 14 ++++++++++++++
 include/linux/cgroup.h      | 18 +++++++++++++++++-
 kernel/cgroup.c             | 32 ++++++++++----------------------
 3 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 60d44b2..504d859 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -235,6 +235,14 @@ struct cgroup {
 	int id;
 
 	/*
+	 * The depth this cgroup is at.  The root is at depth zero and each
+	 * step down the hierarchy increments the level.  This along with
+	 * ancestor_ids[] can determine whether a given cgroup is a
+	 * descendant of another without traversing the hierarchy.
+	 */
+	int level;
+
+	/*
 	 * Each non-empty css_set associated with this cgroup contributes
 	 * one to populated_cnt.  All children with non-zero popuplated_cnt
 	 * of their own contribute one.  The count is zero iff there's no
@@ -289,6 +297,9 @@ struct cgroup {
 
 	/* used to schedule release agent */
 	struct work_struct release_agent_work;
+
+	/* ids of the ancestors at each level including self */
+	int ancestor_ids[];
 };
 
 /*
@@ -308,6 +319,9 @@ struct cgroup_root {
 	/* The root cgroup.  Root is destroyed on its release. */
 	struct cgroup cgrp;
 
+	/* for cgrp->ancestor_ids[0] */
+	int cgrp_ancestor_id_storage;
+
 	/* Number of cgroups in the hierarchy, used only for /proc/cgroups */
 	atomic_t nr_cgrps;
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 22e3754..b5ee2c4 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -81,7 +81,6 @@ struct cgroup_subsys_state *cgroup_get_e_css(struct cgroup *cgroup,
 struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 						       struct cgroup_subsys *ss);
 
-bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
@@ -459,6 +458,23 @@ static inline struct cgroup *task_cgroup(struct task_struct *task,
 	return task_css(task, subsys_id)->cgroup;
 }
 
+/**
+ * cgroup_is_descendant - test ancestry
+ * @cgrp: the cgroup to be tested
+ * @ancestor: possible ancestor of @cgrp
+ *
+ * Test whether @cgrp is a descendant of @ancestor.  It also returns %true
+ * if @cgrp == @ancestor.  This function is safe to call as long as @cgrp
+ * and @ancestor are accessible.
+ */
+static inline bool cgroup_is_descendant(struct cgroup *cgrp,
+					struct cgroup *ancestor)
+{
+	if (cgrp->root != ancestor->root || cgrp->level < ancestor->level)
+		return false;
+	return cgrp->ancestor_ids[ancestor->level] == ancestor->id;
+}
+
 /* no synchronization, the result can only be used as a hint */
 static inline bool cgroup_is_populated(struct cgroup *cgrp)
 {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f1603c1..3190040 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -459,25 +459,6 @@ struct cgroup_subsys_state *of_css(struct kernfs_open_file *of)
 }
 EXPORT_SYMBOL_GPL(of_css);
 
-/**
- * cgroup_is_descendant - test ancestry
- * @cgrp: the cgroup to be tested
- * @ancestor: possible ancestor of @cgrp
- *
- * Test whether @cgrp is a descendant of @ancestor.  It also returns %true
- * if @cgrp == @ancestor.  This function is safe to call as long as @cgrp
- * and @ancestor are accessible.
- */
-bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor)
-{
-	while (cgrp) {
-		if (cgrp == ancestor)
-			return true;
-		cgrp = cgroup_parent(cgrp);
-	}
-	return false;
-}
-
 static int notify_on_release(const struct cgroup *cgrp)
 {
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
@@ -1903,6 +1884,7 @@ static int cgroup_setup_root(struct cgroup_root *root, unsigned long ss_mask)
 	if (ret < 0)
 		goto out;
 	root_cgrp->id = ret;
+	root_cgrp->ancestor_ids[0] = ret;
 
 	ret = percpu_ref_init(&root_cgrp->self.refcnt, css_release, 0,
 			      GFP_KERNEL);
@@ -4846,11 +4828,11 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss,
 static int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name,
 			umode_t mode)
 {
-	struct cgroup *parent, *cgrp;
+	struct cgroup *parent, *cgrp, *tcgrp;
 	struct cgroup_root *root;
 	struct cgroup_subsys *ss;
 	struct kernfs_node *kn;
-	int ssid, ret;
+	int level, ssid, ret;
 
 	/* Do not accept '\n' to prevent making /proc/<pid>/cgroup unparsable.
 	 */
@@ -4861,9 +4843,11 @@ static int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name,
 	if (!parent)
 		return -ENODEV;
 	root = parent->root;
+	level = parent->level + 1;
 
 	/* allocate the cgroup and its ID, 0 is reserved for the root */
-	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
+	cgrp = kzalloc(sizeof(*cgrp) +
+		       sizeof(cgrp->ancestor_ids[0]) * (level + 1), GFP_KERNEL);
 	if (!cgrp) {
 		ret = -ENOMEM;
 		goto out_unlock;
@@ -4887,6 +4871,10 @@ static int cgroup_mkdir(struct kernfs_node *parent_kn, const char *name,
 
 	cgrp->self.parent = &parent->self;
 	cgrp->root = root;
+	cgrp->level = level;
+
+	for (tcgrp = cgrp; tcgrp; tcgrp = cgroup_parent(tcgrp))
+		cgrp->ancestor_ids[tcgrp->level] = tcgrp->id;
 
 	if (notify_on_release(parent))
 		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
-- 
2.5.0
