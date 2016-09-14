From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle unprivileged hooks
Date: Wed, 14 Sep 2016 09:24:11 +0200
Message-ID: <20160914072415.26021-19-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new flag CGRP_NO_NEW_PRIVS for each cgroup. This flag is initially
set for all cgroup except the root. The flag is clear when a new process
without the no_new_privs flags is attached to the cgroup.

If a cgroup is landlocked, then any new attempt, from an unprivileged
process, to attach a process without no_new_privs to this cgroup will
be denied.

This allows to safely manage Landlock rules with cgroup delegation as
with seccomp.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup-defs.h |  7 +++++++
 kernel/bpf/syscall.c        |  7 ++++---
 kernel/cgroup.c             | 44 ++++++++++++++++++++++++++++++++++++++++++--
 security/landlock/manager.c |  7 +++++++
 4 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index fe1023bf7b9d..ce0e4c90ae7d 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -59,6 +59,13 @@ enum {
 	 * specified at mount time and thus is implemented here.
 	 */
 	CGRP_CPUSET_CLONE_CHILDREN,
+	/*
+	 * Keep track of the no_new_privs property of processes in the cgroup.
+	 * This is useful to quickly check if all processes in the cgroup have
+	 * their no_new_privs bit on. This flag is initially set to true but
+	 * ANDed with every processes coming in the cgroup.
+	 */
+	CGRP_NO_NEW_PRIVS,
 };
 
 /* cgroup_root->flags */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index f90225dbbb59..ff8b53a8a2a0 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -849,9 +849,10 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 
 	case BPF_CGROUP_LANDLOCK:
 #ifdef CONFIG_SECURITY_LANDLOCK
-		if (!capable(CAP_SYS_ADMIN))
-			return -EPERM;
-
+		/*
+		 * security/capability check done in landlock_cgroup_set_hook()
+		 * called by cgroup_bpf_update()
+		 */
 		prog = bpf_prog_get_type(attr->attach_bpf_fd,
 				BPF_PROG_TYPE_LANDLOCK);
 		break;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3bbaf3f02ed2..913e2d3b6d55 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -62,6 +62,7 @@
 #include <linux/proc_ns.h>
 #include <linux/nsproxy.h>
 #include <linux/file.h>
+#include <linux/bitops.h>
 #include <net/sock.h>
 
 #define CREATE_TRACE_POINTS
@@ -1985,6 +1986,7 @@ static void init_cgroup_root(struct cgroup_root *root,
 		strcpy(root->name, opts->name);
 	if (opts->cpuset_clone_children)
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->cgrp.flags);
+	/* no CGRP_NO_NEW_PRIVS flag for the root */
 }
 
 static int cgroup_setup_root(struct cgroup_root *root, u16 ss_mask)
@@ -2812,14 +2814,35 @@ static int cgroup_attach_task(struct cgroup *dst_cgrp,
 	LIST_HEAD(preloaded_csets);
 	struct task_struct *task;
 	int ret;
+#if defined(CONFIG_CGROUP_BPF) && defined(CONFIG_SECURITY_LANDLOCK)
+	bool no_new_privs;
+#endif /* CONFIG_CGROUP_BPF && CONFIG_SECURITY_LANDLOCK */
 
 	if (!cgroup_may_migrate_to(dst_cgrp))
 		return -EBUSY;
 
+	task = leader;
+#if defined(CONFIG_CGROUP_BPF) && defined(CONFIG_SECURITY_LANDLOCK)
+	no_new_privs = !!(dst_cgrp->flags & BIT_ULL(CGRP_NO_NEW_PRIVS));
+	do {
+		no_new_privs = no_new_privs && task_no_new_privs(task);
+		if (!no_new_privs) {
+			if (dst_cgrp->bpf.pinned[BPF_CGROUP_LANDLOCK].hooks &&
+					security_capable_noaudit(current_cred(),
+						current_user_ns(),
+						CAP_SYS_ADMIN) != 0)
+				return -EPERM;
+			clear_bit(CGRP_NO_NEW_PRIVS, &dst_cgrp->flags);
+			break;
+		}
+		if (!threadgroup)
+			break;
+	} while_each_thread(leader, task);
+#endif /* CONFIG_CGROUP_BPF && CONFIG_SECURITY_LANDLOCK */
+
 	/* look up all src csets */
 	spin_lock_irq(&css_set_lock);
 	rcu_read_lock();
-	task = leader;
 	do {
 		cgroup_migrate_add_src(task_css_set(task), dst_cgrp,
 				       &preloaded_csets);
@@ -4345,9 +4368,22 @@ int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 		return -EBUSY;
 
 	mutex_lock(&cgroup_mutex);
-
 	percpu_down_write(&cgroup_threadgroup_rwsem);
 
+#if defined(CONFIG_CGROUP_BPF) && defined(CONFIG_SECURITY_LANDLOCK)
+	if (!(from->flags & BIT_ULL(CGRP_NO_NEW_PRIVS))) {
+		if (to->bpf.pinned[BPF_CGROUP_LANDLOCK].hooks &&
+				security_capable_noaudit(current_cred(),
+					current_user_ns(), CAP_SYS_ADMIN) != 0) {
+			pr_warn("%s: EPERM\n", __func__);
+			ret = -EPERM;
+			goto out_unlock;
+		}
+		pr_warn("%s: no EPERM\n", __func__);
+		clear_bit(CGRP_NO_NEW_PRIVS, &to->flags);
+	}
+#endif /* CONFIG_CGROUP_BPF && CONFIG_SECURITY_LANDLOCK */
+
 	/* all tasks in @from are being moved, all csets are source */
 	spin_lock_irq(&css_set_lock);
 	list_for_each_entry(link, &from->cset_links, cset_link)
@@ -4378,6 +4414,7 @@ int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 	} while (task && !ret);
 out_err:
 	cgroup_migrate_finish(&preloaded_csets);
+out_unlock:
 	percpu_up_write(&cgroup_threadgroup_rwsem);
 	mutex_unlock(&cgroup_mutex);
 	return ret;
@@ -5241,6 +5278,9 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 
 	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags))
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
+#if defined(CONFIG_CGROUP_BPF) && defined(CONFIG_SECURITY_LANDLOCK)
+	set_bit(CGRP_NO_NEW_PRIVS, &cgrp->flags);
+#endif /* CONFIG_CGROUP_BPF && CONFIG_SECURITY_LANDLOCK */
 
 	cgrp->self.serial_nr = css_serial_nr_next++;
 
diff --git a/security/landlock/manager.c b/security/landlock/manager.c
index 50aa1305d0d1..479f6990aeff 100644
--- a/security/landlock/manager.c
+++ b/security/landlock/manager.c
@@ -11,6 +11,7 @@
 #include <asm/atomic.h> /* atomic_*() */
 #include <asm/page.h> /* PAGE_SIZE */
 #include <asm/uaccess.h> /* copy_from_user() */
+#include <linux/bitops.h> /* BIT_ULL() */
 #include <linux/bpf.h> /* bpf_prog_put() */
 #include <linux/filter.h> /* struct bpf_prog */
 #include <linux/kernel.h> /* round_up() */
@@ -267,6 +268,12 @@ struct landlock_hooks *landlock_cgroup_set_hook(struct cgroup *cgrp,
 	if (!prog)
 		return ERR_PTR(-EINVAL);
 
+	/* check no_new_privs for tasks in the cgroup */
+	if (!(cgrp->flags & BIT_ULL(CGRP_NO_NEW_PRIVS)) &&
+			security_capable_noaudit(current_cred(),
+				current_user_ns(), CAP_SYS_ADMIN) != 0)
+		return ERR_PTR(-EPERM);
+
 	/* copy the inherited hooks and append a new one */
 	return landlock_set_hook(cgrp->bpf.effective[BPF_CGROUP_LANDLOCK].hooks,
 			prog, NULL);
-- 
2.9.3

