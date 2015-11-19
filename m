From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/7] cgroup: implement cgroup_get_from_path() and expose cgroup_put()
Date: Thu, 19 Nov 2015 13:52:47 -0500
Message-ID: <1447959171-20749-4-git-send-email-tj@kernel.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, Tejun Heo <tj@kernel.org>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447959171-20749-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement cgroup_get_from_path() using kernfs_walk_and_get() which
obtains a default hierarchy cgroup from its path.  This will be used
to allow cgroup path based matching from outside cgroup proper -
e.g. networking and perf.

v2: Add EXPORT_SYMBOL_GPL(cgroup_get_from_path).

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup.h |  7 +++++++
 kernel/cgroup.c        | 39 ++++++++++++++++++++++++++++++++++-----
 2 files changed, 41 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b5ee2c4..4c3ffab 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -81,6 +81,8 @@ struct cgroup_subsys_state *cgroup_get_e_css(struct cgroup *cgroup,
 struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 						       struct cgroup_subsys *ss);
 
+struct cgroup *cgroup_get_from_path(const char *path);
+
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
@@ -351,6 +353,11 @@ static inline void css_put_many(struct cgroup_subsys_state *css, unsigned int n)
 		percpu_ref_put_many(&css->refcnt, n);
 }
 
+static inline void cgroup_put(struct cgroup *cgrp)
+{
+	css_put(&cgrp->self);
+}
+
 /**
  * task_css_set_check - obtain a task's css_set with extra access conditions
  * @task: the task to obtain css_set for
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3190040..3db5e8f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -434,11 +434,6 @@ static bool cgroup_tryget(struct cgroup *cgrp)
 	return css_tryget(&cgrp->self);
 }
 
-static void cgroup_put(struct cgroup *cgrp)
-{
-	css_put(&cgrp->self);
-}
-
 struct cgroup_subsys_state *of_css(struct kernfs_open_file *of)
 {
 	struct cgroup *cgrp = of->kn->parent->priv;
@@ -5753,6 +5748,40 @@ struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
 	return id > 0 ? idr_find(&ss->css_idr, id) : NULL;
 }
 
+/**
+ * cgroup_get_from_path - lookup and get a cgroup from its default hierarchy path
+ * @path: path on the default hierarchy
+ *
+ * Find the cgroup at @path on the default hierarchy, increment its
+ * reference count and return it.  Returns pointer to the found cgroup on
+ * success, ERR_PTR(-ENOENT) if @path doens't exist and ERR_PTR(-ENOTDIR)
+ * if @path points to a non-directory.
+ */
+struct cgroup *cgroup_get_from_path(const char *path)
+{
+	struct kernfs_node *kn;
+	struct cgroup *cgrp;
+
+	mutex_lock(&cgroup_mutex);
+
+	kn = kernfs_walk_and_get(cgrp_dfl_root.cgrp.kn, path);
+	if (kn) {
+		if (kernfs_type(kn) == KERNFS_DIR) {
+			cgrp = kn->priv;
+			cgroup_get(cgrp);
+		} else {
+			cgrp = ERR_PTR(-ENOTDIR);
+		}
+		kernfs_put(kn);
+	} else {
+		cgrp = ERR_PTR(-ENOENT);
+	}
+
+	mutex_unlock(&cgroup_mutex);
+	return cgrp;
+}
+EXPORT_SYMBOL_GPL(cgroup_get_from_path);
+
 #ifdef CONFIG_CGROUP_DEBUG
 static struct cgroup_subsys_state *
 debug_css_alloc(struct cgroup_subsys_state *parent_css)
-- 
2.5.0
