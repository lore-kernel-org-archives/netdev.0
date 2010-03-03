From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 02 Mar 2010 16:46:40 -0800
Message-ID: <m1ocj6qljj.fsf@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43714 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904Ab0CCAqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 19:46:48 -0500
In-Reply-To: <20100303000743.GA13744@us.ibm.com> (Sukadev Bhattiprolu's message of "Tue\, 2 Mar 2010 16\:07\:43 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:

> Eric W. Biederman [ebiederm@xmission.com] wrote:
> | 
> | I think replacing a struct pid for another struct pid allocated in
> | descendant pid_namespace (but has all of the same struct upid values
> | as the first struct pid) is a disastrous idea.  It destroys the
>
> True. Sorry, I did not mean we would need a new 'struct pid' for an
> existing process. I think we talked earlier of finding a way of attaching
> additional pid numbers to the same struct pid.

I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
to be that you become the idle task aka pid 0, and not the init task pid 1 the
implementation is trivial.

Eric
----

 arch/powerpc/platforms/cell/spufs/sched.c |    2 +-
 arch/um/drivers/mconsole_kern.c           |    2 +-
 fs/proc/root.c                            |    2 +-
 init/main.c                               |    9 ---------
 kernel/cgroup.c                           |    2 +-
 kernel/fork.c                             |   16 +++++++++++++---
 kernel/nsproxy.c                          |    2 +-
 kernel/perf_event.c                       |    2 +-
 kernel/pid.c                              |    8 ++++----
 kernel/signal.c                           |    9 ++++-----
 kernel/sysctl_binary.c                    |    2 +-
 11 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index 4678078..b7f2026 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -1094,7 +1094,7 @@ static int show_spu_loadavg(struct seq_file *s, void *private)
 		LOAD_INT(c), LOAD_FRAC(c),
 		count_active_contexts(),
 		atomic_read(&nr_spu_contexts),
-		current->nsproxy->pid_ns->last_pid);
+		task_active_pid_ns(current)->last_pid);
 	return 0;
 }
 
diff --git a/arch/um/drivers/mconsole_kern.c b/arch/um/drivers/mconsole_kern.c
index 3b3c366..4e6985e 100644
--- a/arch/um/drivers/mconsole_kern.c
+++ b/arch/um/drivers/mconsole_kern.c
@@ -125,7 +125,7 @@ void mconsole_log(struct mc_request *req)
 void mconsole_proc(struct mc_request *req)
 {
 	struct nameidata nd;
-	struct vfsmount *mnt = current->nsproxy->pid_ns->proc_mnt;
+	struct vfsmount *mnt = task_active_pid_ns(current)->proc_mnt;
 	struct file *file;
 	int n, err;
 	char *ptr = req->request.data, *buf;
diff --git a/fs/proc/root.c b/fs/proc/root.c
index b080b79..fbcd3f8 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -57,7 +57,7 @@ static int proc_get_sb(struct file_system_type *fs_type,
 	if (flags & MS_KERNMOUNT)
 		ns = (struct pid_namespace *)data;
 	else
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 
 	sb = sget(fs_type, proc_test_super, proc_set_super, ns);
 	if (IS_ERR(sb))
diff --git a/init/main.c b/init/main.c
index 4cb47a1..67e40fc 100644
--- a/init/main.c
+++ b/init/main.c
@@ -851,15 +851,6 @@ static int __init kernel_init(void * unused)
 	 * init can run on any cpu.
 	 */
 	set_cpus_allowed_ptr(current, cpu_all_mask);
-	/*
-	 * Tell the world that we're going to be the grim
-	 * reaper of innocent orphaned children.
-	 *
-	 * We don't want people to have to make incorrect
-	 * assumptions about where in the task array this
-	 * can be found.
-	 */
-	init_pid_ns.child_reaper = current;
 
 	cad_pid = task_pid(current);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index aa3bee5..737d2eb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2453,7 +2453,7 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 {
 	struct cgroup_pidlist *l;
 	/* don't need task_nsproxy() if we're looking at ourself */
-	struct pid_namespace *ns = get_pid_ns(current->nsproxy->pid_ns);
+	struct pid_namespace *ns = get_pid_ns(task_active_pid_ns(current));
 	/*
 	 * We can't drop the pidlist_mutex before taking the l->mutex in case
 	 * the last ref-holder is trying to remove l from the list at the same
diff --git a/kernel/fork.c b/kernel/fork.c
index f88bd98..832c035 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1172,7 +1172,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		if (!pid)
 			goto bad_fork_cleanup_io;
 
-		if (clone_flags & CLONE_NEWPID) {
+		if (pid->numbers[pid->level].nr == 1) {
 			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
 			if (retval < 0)
 				goto bad_fork_free_pid;
@@ -1279,7 +1279,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		tracehook_finish_clone(p, clone_flags, trace);
 
 		if (thread_group_leader(p)) {
-			if (clone_flags & CLONE_NEWPID)
+			if (pid->numbers[pid->level].nr == 1)
 				p->nsproxy->pid_ns->child_reaper = p;
 
 			p->signal->leader_pid = pid;
@@ -1539,10 +1539,19 @@ static void check_unshare_flags(unsigned long *flags_ptr)
 		*flags_ptr |= CLONE_THREAD;
 
 	/*
+	 * If unsharing the pid namespace and the task was created
+	 * using CLONE_THREAD, then must unshare the thread.
+	 */
+	if ((*flags_ptr & CLONE_NEWPID) &&
+	    (atomic_read(&current->signal->count) > 1))
+		*flags_ptr |= CLONE_THREAD;
+
+	/*
 	 * If unsharing namespace, must also unshare filesystem information.
 	 */
 	if (*flags_ptr & CLONE_NEWNS)
 		*flags_ptr |= CLONE_FS;
+
 }
 
 /*
@@ -1647,7 +1656,8 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	err = -EINVAL;
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
+				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET|
+				CLONE_NEWPID))
 		goto bad_unshare_out;
 
 	/*
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index e3be4ef..1d023d5 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -173,7 +173,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	int err = 0;
 
 	if (!(unshare_flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-			       CLONE_NEWNET)))
+			       CLONE_NEWNET | CLONE_NEWPID)))
 		return 0;
 
 	if (!capable(CAP_SYS_ADMIN))
diff --git a/kernel/perf_event.c b/kernel/perf_event.c
index 2ae7409..74865cd 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -4436,7 +4436,7 @@ perf_event_alloc(struct perf_event_attr *attr,
 
 	event->parent		= parent_event;
 
-	event->ns		= get_pid_ns(current->nsproxy->pid_ns);
+	event->ns		= get_pid_ns(task_active_pid_ns(current));
 	event->id		= atomic64_inc_return(&perf_event_id);
 
 	event->state		= PERF_EVENT_STATE_INACTIVE;
diff --git a/kernel/pid.c b/kernel/pid.c
index 2e17c9c..6b64a82 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -305,7 +305,7 @@ EXPORT_SYMBOL_GPL(find_pid_ns);
 
 struct pid *find_vpid(int nr)
 {
-	return find_pid_ns(nr, current->nsproxy->pid_ns);
+	return find_pid_ns(nr, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(find_vpid);
 
@@ -385,7 +385,7 @@ struct task_struct *find_task_by_pid_ns(pid_t nr, struct pid_namespace *ns)
 
 struct task_struct *find_task_by_vpid(pid_t vnr)
 {
-	return find_task_by_pid_ns(vnr, current->nsproxy->pid_ns);
+	return find_task_by_pid_ns(vnr, task_active_pid_ns(current));
 }
 
 struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
@@ -437,7 +437,7 @@ pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
 
 pid_t pid_vnr(struct pid *pid)
 {
-	return pid_nr_ns(pid, current->nsproxy->pid_ns);
+	return pid_nr_ns(pid, task_active_pid_ns(current));
 }
 EXPORT_SYMBOL_GPL(pid_vnr);
 
@@ -448,7 +448,7 @@ pid_t __task_pid_nr_ns(struct task_struct *task, enum pid_type type,
 
 	rcu_read_lock();
 	if (!ns)
-		ns = current->nsproxy->pid_ns;
+		ns = task_active_pid_ns(current);
 	if (likely(pid_alive(task))) {
 		if (type != PIDTYPE_PID)
 			task = task->group_leader;
diff --git a/kernel/signal.c b/kernel/signal.c
index 934ae5e..885b699 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1438,16 +1438,15 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 	 * we are under tasklist_lock here so our parent is tied to
 	 * us and cannot exit and release its namespace.
 	 *
-	 * the only it can is to switch its nsproxy with sys_unshare,
-	 * bu uncharing pid namespaces is not allowed, so we'll always
-	 * see relevant namespace
+	 * The only it can is to switch its nsproxy with sys_unshare,
+	 * but we use the pid_namespace for task_pid which never changes.
 	 *
 	 * write_lock() currently calls preempt_disable() which is the
 	 * same as rcu_read_lock(), but according to Oleg, this is not
 	 * correct to rely on this
 	 */
 	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
+	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(tsk->parent));
 	info.si_uid = __task_cred(tsk)->uid;
 	rcu_read_unlock();
 
@@ -1518,7 +1517,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
 	 * see comment in do_notify_parent() abot the following 3 lines
 	 */
 	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
+	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(parent));
 	info.si_uid = __task_cred(tsk)->uid;
 	rcu_read_unlock();
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 8f5d16e..1e4da59 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -1356,7 +1356,7 @@ static ssize_t binary_sysctl(const int *name, int nlen,
 		goto out_putname;
 	}
 
-	mnt = current->nsproxy->pid_ns->proc_mnt;
+	mnt = task_active_pid_ns(current)->proc_mnt;
 	result = vfs_path_lookup(mnt->mnt_root, mnt, pathname, 0, &nd);
 	if (result)
 		goto out_putname;
