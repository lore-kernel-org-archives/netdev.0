From: Bandan Das <bsd@redhat.com>
Subject: [RFC PATCH 3/4] cgroup: Introduce a function to compare cgroups
Date: Mon, 13 Jul 2015 00:07:34 -0400
Message-ID: <1436760455-5686-4-git-send-email-bsd@redhat.com>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Eyal Moscovici <EYALMO@il.ibm.com>,
	Razya Ladelsky <RAZYA@il.ibm.com>, cgroups@vger.kernel.org,
	jasowang@redhat.com
To: kvm@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436760455-5686-1-git-send-email-bsd@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function takes two tasks and iterates through all
hierarchies to check if they belong to the same cgroups.
It ignores the check for default hierarchies or for
hierarchies with no subsystems attached. This function
will be used by the next patch to add rudimentary cgroup support
with vhost workers.

Signed-off-by: Bandan Das <bsd@redhat.com>
---
 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b9cb94c..606fb5b 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -933,6 +933,7 @@ void css_task_iter_start(struct cgroup_subsys_state *css,
 struct task_struct *css_task_iter_next(struct css_task_iter *it);
 void css_task_iter_end(struct css_task_iter *it);
 
+int cgroup_match_groups(struct task_struct *tsk1, struct task_struct *tsk2);
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 469dd54..ba4121e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2465,6 +2465,46 @@ out_unlock_cgroup:
 }
 
 /**
+ * cgroup_match_groups - check if tsk1 and tsk2 belong to
+ * same cgroups in all hierarchies
+ * Returns 0 on success
+ */
+int cgroup_match_groups(struct task_struct *tsk1, struct task_struct *tsk2)
+{
+	struct cgroup_root *root;
+	int retval = 0;
+
+	WARN_ON(!tsk1 || !tsk2);
+
+	mutex_lock(&cgroup_mutex);
+	for_each_root(root) {
+		struct cgroup *cg_tsk1;
+		struct cgroup *cg_tsk2;
+
+		/* Default hierarchy */
+		if (root == &cgrp_dfl_root)
+			continue;
+		/* No subsystems attached */
+		if (!root->subsys_mask)
+			continue;
+
+		down_read(&css_set_rwsem);
+		cg_tsk1 = task_cgroup_from_root(tsk1, root);
+		cg_tsk2 = task_cgroup_from_root(tsk2, root);
+		up_read(&css_set_rwsem);
+
+		if (cg_tsk1 != cg_tsk2) {
+			retval = 1;
+			break;
+		}
+	}
+	mutex_unlock(&cgroup_mutex);
+
+	return retval;
+}
+EXPORT_SYMBOL_GPL(cgroup_match_groups);
+
+/**
  * cgroup_attach_task_all - attach task 'tsk' to all cgroups of task 'from'
  * @from: attach to all cgroups of a given task
  * @tsk: the task to be attached
-- 
2.4.3
