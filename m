From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/3] cgroups: Add an API to attach a task to current task's
 cgroup
Date: Sun, 30 May 2010 22:24:39 +0200
Message-ID: <4C02C987.6020805@kernel.org>
References: <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100530112925.GB27611@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <samudrala.sridhar@gmail.com>

Add a new kernel API to attach a task to current task's cgroup
in all the active hierarchies.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
---
 include/linux/cgroup.h |    1 +
 kernel/cgroup.c        |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

Index: work/include/linux/cgroup.h
===================================================================
--- work.orig/include/linux/cgroup.h
+++ work/include/linux/cgroup.h
@@ -570,6 +570,7 @@ struct task_struct *cgroup_iter_next(str
 void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
+int cgroup_attach_task_current_cg(struct task_struct *);

 /*
  * CSS ID is ID for cgroup_subsys_state structs under subsys. This only works
Index: work/kernel/cgroup.c
===================================================================
--- work.orig/kernel/cgroup.c
+++ work/kernel/cgroup.c
@@ -1788,6 +1788,29 @@ out:
 	return retval;
 }

+/**
+ * cgroup_attach_task_current_cg - attach task 'tsk' to current task's cgroup
+ * @tsk: the task to be attached
+ */
+int cgroup_attach_task_current_cg(struct task_struct *tsk)
+{
+	struct cgroupfs_root *root;
+	struct cgroup *cur_cg;
+	int retval = 0;
+
+	cgroup_lock();
+	for_each_active_root(root) {
+		cur_cg = task_cgroup_from_root(current, root);
+		retval = cgroup_attach_task(cur_cg, tsk);
+		if (retval)
+			break;
+	}
+	cgroup_unlock();
+
+	return retval;
+}
+EXPORT_SYMBOL_GPL(cgroup_attach_task_current_cg);
+
 /*
  * Attach task with pid 'pid' to cgroup 'cgrp'. Call with cgroup_mutex
  * held. May take task_lock of task
