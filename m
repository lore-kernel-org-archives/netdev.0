From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v5 1/3] cgroup: Add task_under_cgroup_hierarchy
 cgroup inline function to headers
Date: Fri, 12 Aug 2016 08:56:40 -0700
Message-ID: <20160812155638.GA12880@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net, tj@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36757 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbcHLP4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:56:43 -0400
Received: by mail-it0-f52.google.com with SMTP id x130so15081494ite.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:56:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds an inline function to cgroup.h to check whether a given
task is under a given cgroup hierarchy. This is to avoid having to put
ifdefs in .c files to gate access to cgroups. When cgroups are disabled
this always returns true.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tejun Heo <tj@kernel.org>
Acked-by: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 984f73b..a4414a1 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -497,6 +497,23 @@ static inline bool cgroup_is_descendant(struct cgroup *cgrp,
 	return cgrp->ancestor_ids[ancestor->level] == ancestor->id;
 }
 
+/**
+ * task_under_cgroup_hierarchy - test task's membership of cgroup ancestry
+ * @task: the task to be tested
+ * @ancestor: possible ancestor of @task's cgroup
+ *
+ * Tests whether @task's default cgroup hierarchy is a descendant of @ancestor.
+ * It follows all the same rules as cgroup_is_descendant, and only applies
+ * to the default hierarchy.
+ */
+static inline bool task_under_cgroup_hierarchy(struct task_struct *task,
+					       struct cgroup *ancestor)
+{
+	struct css_set *cset = task_css_set(task);
+
+	return cgroup_is_descendant(cset->dfl_cgrp, ancestor);
+}
+
 /* no synchronization, the result can only be used as a hint */
 static inline bool cgroup_is_populated(struct cgroup *cgrp)
 {
@@ -557,6 +574,7 @@ static inline void pr_cont_cgroup_path(struct cgroup *cgrp)
 #else /* !CONFIG_CGROUPS */
 
 struct cgroup_subsys_state;
+struct cgroup;
 
 static inline void css_put(struct cgroup_subsys_state *css) {}
 static inline int cgroup_attach_task_all(struct task_struct *from,
@@ -574,6 +592,11 @@ static inline void cgroup_free(struct task_struct *p) {}
 static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
 
+static inline bool task_under_cgroup_hierarchy(struct task_struct *task,
+					       struct cgroup *ancestor)
+{
+	return true;
+}
 #endif /* !CONFIG_CGROUPS */
 
 /*
-- 
2.7.4
