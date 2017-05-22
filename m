From: Djalal Harouni <tixxdz@gmail.com>
Subject: [PATCH v4 next 3/3] modules:capabilities: add a per-task modules auto-load mode
Date: Mon, 22 May 2017 13:57:06 +0200
Message-ID: <1495454226-10027-4-git-send-email-tixxdz@gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Dongsu Park <dpark@posteo.net>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Jonathan Corbet <corbet@lwn.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Zendyani <zendyani@gmail.com>, linux-doc@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ben Hutchings <ben.hutchings@codethink.co.uk>,
        Djalal Harouni <tixxdz@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        kernel-hardening@lists.openwall.com,
        Andy Lutomirski <luto@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36428 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757944AbdEVL6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 07:58:00 -0400
In-Reply-To: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous patches added the global sysctl "modules_autoload_mode". This patch
make it possible to support process trees, containers, and sandboxes by
providing an inherited per-task "modules_autoload_mode" flag that cannot be
re-enabled once disabled. This allows to restrict automatic module loading
without affecting the rest of the system.

Why we need this ?

Usually a request to a kernel feature that is implemented by a module
that is not loaded may trigger automatic module loading feature,
allowing to transparently satisfy userspace, and provide numeours
features as they are needed. In this case an implicit kernel module load
operation happens.

In most cases to load or unload a kernel module, an explicit operation
happens where programs are required to have CAP_SYS_MODULE capability to
perform so. However, in general with implicit module loading, no
capabilities are required as automatic module loading is one of the most
important and transparent operations of Linux.

Recent vulnerabilities showed that automatic module loading can be
abused in order to expose more bugs. Some of these vulnerabilities are:

* DCCP use after free CVE-2017-6074 [1]
  Unprivileged to local root PoC.

* XFRM framework CVE-2017-7184 [2]
  As advertised it seems it was used to break Ubuntu at a security
  contest.

* n_hldc CVE-2017-2636
* L2TPv3 CVE-2016-10200

Currently most of Linux code is in a form of modules, and not all
modules are written or maintained in the same way. In a container or
sandbox world, apps can be moved from one context to another or from
one Linux system to another one, the ability to restrict some of these
apps to load extra kernel modules will prevent exposing some kernel
interfaces that have not been updated withing such systems.

The DCCP vulnerability CVE-2017-6074 that can be triggered by
unprivileged, or CVE-2017-7184 in the XFRM framework are some recent
real examples. CVE-2017-7184 was used to break Ubuntu at a security
contest. Ubuntu is more of desktop distro, using a global switch to
disable automatic module loading will harm users. Actually this design
will always end up being ignored by such kind of systems that need to
offer a competitive and interactive solution for their users.

>From this and from observing how apps are being run, this patch
introduces a per-task "modules_autoload_mode" to restrict automatic
module loading. This offers the following advantages:

1) Automatic module loading is still available to the rest of the
system.

2) It is easy to use in containers and sandboxes. DCCP example could
have been used to escape containers. The XFRM framework CVE-2017-7184
needs CAP_NET_ADMIN, but attackers may start to target CAP_NET_ADMIN,
a per-task flag will make it harder.

3) Suitable for desktop and more interactive Linux systems.

4) Will allow in future to implement a per user policy.
The user database format is old and not extensible, as discussed maybe
with a modern format we may achieve the following:

User=djalal
NewKernelFeatures=yes

Which means that that interactive user will be allowed to load extra
Linux features. Others, volatile accounts or guests can be easily
blocked from doing so.

5) CAP_NET_ADMIN is useful, it handles lot of operations, at same time it
started to look more like CAP_SYS_ADMIN which is overloaded. We need
CAP_NET_ADMIN, containers need it, but at same time maybe we do not
want programs running with it to load 'netdev-%s' modules. Having an
extra per-task flag allow to discharge a bit CAP_NET_ADMIN and clearly
target automatic module loading operations.

Usage:
------

To set the per-task "modules_autoload_mode":

        prctl(PR_SET_MODULES_AUTOLOAD_MODE, mode, 0, 0, 0);

When a module auto-load request is triggered by current task, then the
operation has first to satisfy the per-task access mode before attempting
to implicitly load the module. Once set, this setting is inherited across
fork, clone and execve.

Prior to use, the task must call prctl(PR_SET_NO_NEW_PRIVS, 1) or run with
CAP_SYS_ADMIN privileges in its namespace.  If these are not true, -EACCES
will be returned.  This requirement ensures that unprivileged programs cannot
affect the behaviour or surprise privileged children.

The per-task "modules_autoload_mode" supports the following values:
0       There are no restrictions, usually the default unless set
        by parent.
1       The task must have CAP_SYS_MODULE to be able to trigger a
        module auto-load operation, or CAP_NET_ADMIN for modules with
        a 'netdev-%s' alias.
2       Automatic modules loading is disabled for the current task.

The mode may only be increased, never decreased, thus ensuring that once
applied, processes can never relax their setting. This make it easy for
developers and users to handle.

Note that even if the per-task "modules_autoload_mode" allows to auto-load
the corresponding modules, automatic module loading may still fail due to
the global sysctl "modules_autoload_mode". For more details please see
Documentation/sysctl/kernel.txt, section "modules_autoload_mode".

When a request to a kernel module is denied, the module name with the
corresponding process name and its pid are logged. Administrators can use
such information to explicitly load the appropriate modules.

The original idea of module auto-load restriction comes from
'GRKERNSEC_MODHARDEN' config option.

Testing per-task or per container setup
---------------------------------------

The following tool can be used to test the feature:
https://gist.githubusercontent.com/tixxdz/f6d77e5a45f9f8cfa4bcc0ab526ce5cf/raw/5f12f98e4dfc8a94f76b13dc290f077a153e74d8/pr_modules_autoload_mode_test.c

Example 1)

Before patch:
$ lsmod | grep ipip -
$ sudo ip tunnel add mytun mode ipip remote 10.0.2.100 local 10.0.2.15 ttl 255
$ lsmod | grep ipip -
ipip                   16384  0
tunnel4                16384  1 ipip
ip_tunnel              28672  1 ipip
$ grep Modules /proc/self/status
ModulesAutoloadMode:    0

After patch:
Set task "modules_autoload_mode" to disabled.
$ lsmod | grep ipip -
$ grep Modules /proc/self/status
ModulesAutoloadMode:    0
$ su - root
# ./pr_modules_autoload_mode_test 2
task modules_autoload_mode: 2
# grep Modules /proc/self/status
ModulesAutoloadMode:    2
# ip tunnel add mytun mode ipip remote 10.0.2.100 local 10.0.2.15 ttl 255
add tunnel "tunl0" failed: No such device
...
[  634.954652] module: automatic module loading of netdev-tunl0 by "ip"[1560] was denied
[  634.955775] module: automatic module loading of tunl0 by "ip"[1560] was denied
...

Example 2)

Sample with XFRM tunnel mode.

Before patch:
$ lsmod | grep xfrm -
$ grep Modules /proc/self/status
ModulesAutoloadMode:    0
$ sudo ip xfrm state add src 10.0.2.100 dst 10.0.1.100 proto esp spi $id1 \
> reqid $id2 mode tunnel auth "hmac(sha256)" $key1 enc "cbc(aes)" $key2
$ lsmod | grep xfrm
xfrm4_mode_tunnel      16384  2

After patch:
Set task "modules_autoload_mode" to disabled.
$ lsmod | grep xfrm -
$ grep Modules /proc/self/status
ModulesAutoloadMode:    0
$ su - root
# ./pr_modules_autoload_mode_test 2
task modules_autoload_mode: 2
# grep Modules /proc/self/status
ModulesAutoloadMode:    2
# ip xfrm state add src 10.0.2.100 dst 10.0.1.100 proto esp spi $id1 \
> reqid $id2 mode tunnel auth "hmac(sha256)" $key1 enc "cbc(aes)" $key2
RTNETLINK answers: Protocol not supported
...
[ 3458.139490] module: automatic module loading of xfrm-mode-2-1 by "ip"[1506] was denied
...

Example 3)

Here we use DCCP as an example since the public PoC was against it.

DCCP use after free CVE-2017-6074 (unprivileged to local root):
The code path can be triggered by unprivileged, using the trigger.c
program for DCCP use after free [3] and that was fixed by
commit 5edabca9d4cff7f "dccp: fix freeing skb too early for IPV6_RECVPKTINFO".

Before patch:
$ lsmod | grep dccp
$ strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = 3
...
$ lsmod | grep dccp
dccp_ipv6              24576  5
dccp_ipv4              24576  5 dccp_ipv6
dccp                  102400  2 dccp_ipv6,dccp_ipv4
$ grep Modules /proc/self/status
ModulesAutoloadMode:    0

After patch:

Set task "modules_autoload_mode" to 1, privileged mode.
$ lsmod | grep dccp
$ ./pr_set_no_new_privs
$ grep NoNewPrivs /proc/self/status
NoNewPrivs:     1
$ ./pr_modules_autoload_mode_test 1
$ grep Modules /proc/self/status
ModulesAutoloadMode:    1
$ strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = -1 ESOCKTNOSUPPORT (Socket type not supported)
...
$ lsmod | grep dccp
$ dmesg
...
[ 4662.171994] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1759] was denied
[ 4662.177284] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1759] was denied
[ 4662.180181] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1759] was denied
[ 4662.181709] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1759] was denied

Set task "modules_autoload_mode" to 2, disabled mode.
$ lsmod | grep dccp
$ su - root
# ./pr_modules_autoload_mode_test 2
task modules_autoload_mode: 2
# grep Modules /proc/self/status
ModulesAutoloadMode:    2
# strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = -1 ESOCKTNOSUPPORT (Socket type not supported)
...
...
[ 5154.218740] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1873] was denied
[ 5154.219828] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1873] was denied
[ 5154.221814] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1873] was denied
[ 5154.222731] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1873] was denied

As showed, this blocks automatic module loading per-task. This allows to
provide a usable system, where only some sandboxed apps or containers will be
restricted to trigger automatic module loading, other parts of the
system can continue to use the system as it is which is the case of the
desktop.

[1] http://www.openwall.com/lists/oss-security/2017/02/22/3
[2] http://www.openwall.com/lists/oss-security/2017/03/29/2
[3] https://github.com/xairy/kernel-exploits/tree/master/CVE-2017-6074

Cc: Ben Hutchings <ben.hutchings@codethink.co.uk>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Serge Hallyn <serge@hallyn.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Signed-off-by: Djalal Harouni <tixxdz@gmail.com>
---
 Documentation/filesystems/proc.txt                 |   3 +
 Documentation/userspace-api/index.rst              |   1 +
 .../userspace-api/modules_autoload_mode.rst        | 115 +++++++++++++++++++++
 fs/proc/array.c                                    |   6 ++
 include/linux/init_task.h                          |   8 ++
 include/linux/module.h                             |  26 ++++-
 include/linux/sched.h                              |   5 +
 include/uapi/linux/prctl.h                         |   8 ++
 kernel/module.c                                    |  61 ++++++++++-
 security/commoncap.c                               |  38 ++++++-
 10 files changed, 263 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/userspace-api/modules_autoload_mode.rst

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index adba21b..58127f0 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -194,6 +194,7 @@ read the file /proc/PID/status:
   CapBnd: ffffffffffffffff
   NoNewPrivs:     0
   Seccomp:        0
+  ModulesAutoloadMode:    0
   voluntary_ctxt_switches:        0
   nonvoluntary_ctxt_switches:     1
 
@@ -267,6 +268,8 @@ Table 1-2: Contents of the status files (as of 4.8)
  CapBnd                      bitmap of capabilities bounding set
  NoNewPrivs                  no_new_privs, like prctl(PR_GET_NO_NEW_PRIV, ...)
  Seccomp                     seccomp mode, like prctl(PR_GET_SECCOMP, ...)
+ ModulesAutoloadMode         modules auto-load mode, like
+                             prctl(PR_GET_MODULES_AUTOLOAD_MODE, ...)
  Cpus_allowed                mask of CPUs on which this process may run
  Cpus_allowed_list           Same as previous, but in "list format"
  Mems_allowed                mask of memory nodes allowed to this process
diff --git a/Documentation/userspace-api/index.rst b/Documentation/userspace-api/index.rst
index 7b2eb1b..bfd51b7 100644
--- a/Documentation/userspace-api/index.rst
+++ b/Documentation/userspace-api/index.rst
@@ -17,6 +17,7 @@ place where this information is gathered.
    :maxdepth: 2
 
    no_new_privs
+   modules_autoload_mode
    seccomp_filter
    unshare
 
diff --git a/Documentation/userspace-api/modules_autoload_mode.rst b/Documentation/userspace-api/modules_autoload_mode.rst
new file mode 100644
index 0000000..7355b00
--- /dev/null
+++ b/Documentation/userspace-api/modules_autoload_mode.rst
@@ -0,0 +1,115 @@
+======================================
+Per-task module auto-load restrictions
+======================================
+
+
+Introduction
+============
+
+Usually a request to a kernel feature that is implemented by a module
+that is not loaded may trigger automatic module loading feature, allowing
+to transparently satisfy userspace, and provide numerous other features
+as they are needed. In this case an implicit kernel module load
+operation happens.
+
+In most cases to load or unload a kernel module, an explicit operation
+happens where programs are required to have ``CAP_SYS_MODULE`` capability
+to perform so. However, with implicit module loading, no capabilities are
+required, or only ``CAP_NET_ADMIN`` in rare cases where the module has the
+'netdev-%s' alias. Historically this was always the case as automatic
+module loading is one of the most important and transparent operations
+of Linux, users expect that their programs just work, yet, recent cases
+showed that this can be abused by unprivileged users or attackers to load
+modules that were not updated, or modules that contain bugs and
+vulnerabilities.
+
+Currently most of Linux code is in a form of modules, hence, allowing to
+control automatic module loading in some cases is as important as the
+operation itself, especially in the context where Linux is used in
+different appliances.
+
+Restricting automatic module loading allows administratros to have the
+appropriate time to update or deny module autoloading in advance. In a
+container or sandbox world where apps can be moved from one context to
+another, the ability to restrict some containers or apps to load extra
+kernel modules will prevent exposing some kernel interfaces that may not
+receive the same care as some other parts of the core. The DCCP vulnerability
+CVE-2017-6074 that can be triggered by unprivileged, or CVE-2017-7184
+in the XFRM framework are some real examples where users or programs are
+able to expose such kernel interfaces and escape their sandbox.
+
+The per-task ``modules_autoload_mode`` allow to restrict automatic module
+loading per task, preventing the kernel from exposing more of its
+interface. This is particularly useful for containers and sandboxes as
+noted above, they are restricted from affecting the rest of the system
+without affecting its functionality, automatic module loading is still
+available for others.
+
+
+Usage
+=====
+
+When the kernel is compiled with modules support ``CONFIG_MODULES``, then:
+
+``PR_SET_MODULES_AUTOLOAD_MODE``:
+        Set the current task ``modules_autoload_mode``. When a module
+        auto-load request is triggered by current task, then the
+        operation has first to satisfy the per-task access mode before
+        attempting to implicitly load the module. As an example,
+        automatic loading of modules that contain bugs or vulnerabilities
+        can be restricted and unprivileged users can no longer abuse such
+        interfaces. Once set, this setting is inherited across ``fork(2)``,
+        ``clone(2)`` and ``execve(2)``.
+
+        Prior to use, the task must call ``prctl(PR_SET_NO_NEW_PRIVS, 1)``
+        or run with ``CAP_SYS_ADMIN`` privileges in its namespace.  If
+        these are not true, ``-EACCES`` will be returned.  This requirement
+        ensures that unprivileged programs cannot affect the behaviour or
+        surprise privileged children.
+
+        Usage:
+                ``prctl(PR_SET_MODULES_AUTOLOAD_MODE, mode, 0, 0, 0);``
+
+        The 'mode' argument supports the following values:
+        0       There are no restrictions, usually the default unless set
+                by parent.
+        1       The task must have ``CAP_SYS_MODULE`` to be able to trigger a
+                module auto-load operation, or ``CAP_NET_ADMIN`` for modules
+                with a 'netdev-%s' alias.
+        2       Automatic modules loading is disabled for the current task.
+
+        The mode may only be increased, never decreased, thus ensuring
+        that once applied, processes can never relax their setting.
+
+
+        Returned values:
+        0               On success.
+        ``-EINVAL``     If 'mode' is not valid, or the operation is not
+                        supported.
+        ``-EACCES``     If task does not have ``CAP_SYS_ADMIN`` in its namespace
+                        or is not running with ``no_new_privs``.
+        ``-EPERM``      If 'mode' is less strict than current task
+                        ``modules_autoload_mode``.
+
+
+        Note that even if the per-task ``modules_autoload_mode`` allows to
+        auto-load the corresponding modules, automatic module loading
+        may still fail due to the global sysctl ``modules_autoload_mode``.
+        For more details please see Documentation/sysctl/kernel.txt,
+        section "modules_autoload_mode".
+
+
+        When a request to a kernel module is denied, the module name with the
+        corresponding process name and its pid are logged. Administrators can
+        use such information to explicitly load the appropriate modules.
+
+
+``PR_GET_MODULES_AUTOLOAD_MODE``:
+        Return the current task ``modules_autoload_mode``.
+
+        Usage:
+                ``prctl(PR_GET_MODULES_AUTOLOAD_MODE, 0, 0, 0, 0);``
+
+        Returned values:
+        mode            The task's ``modules_autoload_mode``
+        ``-ENOSYS``     If the kernel was compiled without ``CONFIG_MODULES``.
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 88c3555..b2113e9 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -88,6 +88,7 @@
 #include <linux/string_helpers.h>
 #include <linux/user_namespace.h>
 #include <linux/fs_struct.h>
+#include <linux/module.h>
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -346,10 +347,15 @@ static inline void task_cap(struct seq_file *m, struct task_struct *p)
 
 static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
 {
+	int autoload = task_modules_autoload_mode(p);
+
 	seq_put_decimal_ull(m, "NoNewPrivs:\t", task_no_new_privs(p));
 #ifdef CONFIG_SECCOMP
 	seq_put_decimal_ull(m, "\nSeccomp:\t", p->seccomp.mode);
 #endif
+	if (autoload != -ENOSYS)
+		seq_put_decimal_ull(m, "\nModulesAutoloadMode:\t", autoload);
+
 	seq_putc(m, '\n');
 }
 
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index e049526..97fbb08 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -159,6 +159,13 @@ extern struct cred init_cred;
 # define INIT_CGROUP_SCHED(tsk)
 #endif
 
+#ifdef CONFIG_MODULES
+# define INIT_MODULES_AUTOLOAD_MODE(tsk)				\
+	.modules_autoload_mode = 0,
+#else
+# define INIT_MODULES_AUTOLOAD_MODE(tsk)
+#endif
+
 #ifdef CONFIG_PERF_EVENTS
 # define INIT_PERF_EVENTS(tsk)						\
 	.perf_event_mutex = 						\
@@ -257,6 +264,7 @@ extern struct cred init_cred;
 	.tasks		= LIST_HEAD_INIT(tsk.tasks),			\
 	INIT_PUSHABLE_TASKS(tsk)					\
 	INIT_CGROUP_SCHED(tsk)						\
+	INIT_MODULES_AUTOLOAD_MODE(tsk)					\
 	.ptraced	= LIST_HEAD_INIT(tsk.ptraced),			\
 	.ptrace_entry	= LIST_HEAD_INIT(tsk.ptrace_entry),		\
 	.real_parent	= &tsk,						\
diff --git a/include/linux/module.h b/include/linux/module.h
index 9b64896..9f6ec47 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -13,6 +13,7 @@
 #include <linux/kmod.h>
 #include <linux/init.h>
 #include <linux/elf.h>
+#include <linux/sched.h>
 #include <linux/stringify.h>
 #include <linux/kobject.h>
 #include <linux/moduleparam.h>
@@ -507,7 +508,16 @@ bool is_module_percpu_address(unsigned long addr);
 bool is_module_text_address(unsigned long addr);
 
 /* Determine whether a module auto-load operation is permitted. */
-int may_autoload_module(char *kmod_name, int allow_cap);
+int may_autoload_module(struct task_struct *task, char *kmod_name, int allow_cap);
+
+/* Set modules_autoload_mode of current task */
+int task_set_modules_autoload_mode(unsigned long value);
+
+/* Read task's modules_autoload_mode */
+static inline int task_modules_autoload_mode(struct task_struct *task)
+{
+	return task->modules_autoload_mode;
+}
 
 static inline bool within_module_core(unsigned long addr,
 				      const struct module *mod)
@@ -653,11 +663,23 @@ static inline bool is_livepatch_module(struct module *mod)
 
 #else /* !CONFIG_MODULES... */
 
-static inline int may_autoload_module(char *kmod_name, int allow_cap)
+static inline int may_autoload_module(struct task_struct *task, char *kmod_name,
+				      int allow_cap)
 {
 	return -ENOSYS;
 }
 
+int task_set_modules_autoload_mode(unsigned long value)
+{
+	return -ENOSYS;
+}
+
+static inline int task_modules_autoload_mode(struct task_struct *task)
+{
+	return -ENOSYS;
+}
+
+static inline bool within_module_core(unsigned long addr,
 static inline struct module *__module_address(unsigned long addr)
 {
 	return NULL;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c533851..031a369 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -613,6 +613,11 @@ struct task_struct {
 
 	struct restart_block		restart_block;
 
+#ifdef CONFIG_MODULES
+	/* per-task modules auto-load mode */
+	unsigned			modules_autoload_mode:2;
+#endif
+
 	pid_t				pid;
 	pid_t				tgid;
 
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759..bf73607 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,12 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/*
+ * Control the per-task modules auto-load mode
+ *
+ * See Documentation/prctl/modules_autoload_mode.txt for more details.
+ */
+#define PR_SET_MODULES_AUTOLOAD_MODE	48
+#define PR_GET_MODULES_AUTOLOAD_MODE	49
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/module.c b/kernel/module.c
index ce7a146..8739e4c 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -4301,12 +4301,15 @@ EXPORT_SYMBOL_GPL(__module_text_address);
 /**
  * may_autoload_module - Determine whether a module auto-load operation
  * is permitted
+ * @task: The task performing the request
  * @kmod_name: The module name
  * @allow_cap: if positive, may allow to auto-load the module if this capability
  * is set
  *
- * Determine whether a module auto-load operation is allowed or not. The check
- * uses the sysctl "modules_autoload_mode" value.
+ * Determine whether a module auto-load operation is allowed or not. First we
+ * check if the task is allowed to perform the module auto-load request, we
+ * check per-task "modules_autoload_mode", if the access is not denied, then
+ * we check the global sysctl "modules_autoload_mode".
  *
  * This allows to have more control on automatic module loading, and align it
  * with explicit load/unload module operations. The kernel contains several
@@ -4323,11 +4326,14 @@ EXPORT_SYMBOL_GPL(__module_text_address);
  *
  * Returns 0 if the module request is allowed or -EPERM if not.
  */
-int may_autoload_module(char *kmod_name, int allow_cap)
+int may_autoload_module(struct task_struct *task, char *kmod_name, int allow_cap)
 {
-	if (modules_autoload_mode == MODULES_AUTOLOAD_ALLOWED)
+	unsigned int autoload = max_t(unsigned int, modules_autoload_mode,
+				      task->modules_autoload_mode);
+
+	if (autoload == MODULES_AUTOLOAD_ALLOWED)
 		return 0;
-	else if (modules_autoload_mode == MODULES_AUTOLOAD_PRIVILEGED) {
+	else if (autoload == MODULES_AUTOLOAD_PRIVILEGED) {
 		/* Check CAP_SYS_MODULE then allow_cap if valid */
 		if (capable(CAP_SYS_MODULE) ||
 		    (allow_cap > 0 && capable(allow_cap)))
@@ -4338,6 +4344,51 @@ int may_autoload_module(char *kmod_name, int allow_cap)
 	return -EPERM;
 }
 
+/**
+ * task_set_modules_autoload_mode - Set per-task modules auto-load mode
+ * @value: Value to set "modules_autoload_mode" of current task
+ *
+ * Set current task "modules_autoload_mode". The task has to have
+ * CAP_SYS_ADMIN in its namespace or be running with no_new_privs. This
+ * avoids scenarios where unprivileged tasks can affect the behaviour of
+ * privilged children by restricting module features.
+ *
+ * The task's "modules_autoload_mode" may only be increased, never decreased.
+ *
+ * Returns 0 on success, -EINVAL if @value is not valid, -EACCES if task does
+ * not have CAP_SYS_ADMIN in its namespace or is not running with no_new_privs,
+ * and finally -EPERM if @value is less strict than current task
+ * "modules_autoload_mode".
+ *
+ */
+int task_set_modules_autoload_mode(unsigned long value)
+{
+	if (value > MODULES_AUTOLOAD_DISABLED)
+		return -EINVAL;
+
+	/*
+	 * To set task "modules_autoload_mode" requires that the task has
+	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
+	 * This avoids scenarios where unprivileged tasks can affect the
+	 * behaviour of privileged children by restricting module features.
+	 */
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(), current_user_ns(),
+				     CAP_SYS_ADMIN) != 0)
+		return -EACCES;
+
+	/*
+	 * The "modules_autoload_mode" may only be increased, never decreased,
+	 * ensuring that once applied, processes can never relax their settings.
+	 */
+	if (current->modules_autoload_mode > value)
+		return -EPERM;
+	else if (current->modules_autoload_mode < value)
+		current->modules_autoload_mode = value;
+
+	return 0;
+}
+
 /* Don't grab lock, we're oopsing. */
 void print_modules(void)
 {
diff --git a/security/commoncap.c b/security/commoncap.c
index d629d28..dbf0d51 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -886,6 +886,36 @@ static int cap_prctl_drop(unsigned long cap)
 	return commit_creds(new);
 }
 
+/*
+ * Implement PR_SET_MODULES_AUTOLOAD_MODE.
+ *
+ * Returns 0 on success, -ve on error.
+ */
+static int pr_set_modules_autoload_mode(unsigned long arg2, unsigned long arg3,
+					unsigned long arg4, unsigned long arg5)
+{
+	if (arg3 || arg4 || arg5)
+		return -EINVAL;
+
+	return task_set_modules_autoload_mode(arg2);
+}
+
+/*
+ * Implement PR_GET_MODULES_AUTOLOAD_MODE.
+ *
+ * Return current task "modules_autoload_mode", -ve on error.
+ */
+static inline int pr_get_modules_autoload_mode(unsigned long arg2,
+					       unsigned long arg3,
+					       unsigned long arg4,
+					       unsigned long arg5)
+{
+	if (arg3 || arg4 || arg5)
+		return -EINVAL;
+
+	return task_modules_autoload_mode(current);
+}
+
 /**
  * cap_task_prctl - Implement process control functions for this security module
  * @option: The process control function requested
@@ -1016,6 +1046,12 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 			return commit_creds(new);
 		}
 
+	case PR_SET_MODULES_AUTOLOAD_MODE:
+		return pr_set_modules_autoload_mode(arg2, arg3, arg4, arg5);
+
+	case PR_GET_MODULES_AUTOLOAD_MODE:
+		return pr_get_modules_autoload_mode(arg2, arg3, arg4, arg5);
+
 	default:
 		/* No functionality available - continue with default */
 		return -ENOSYS;
@@ -1083,7 +1119,7 @@ int cap_kernel_module_request(char *kmod_name, int allow_cap)
 	int ret;
 	char comm[sizeof(current->comm)];
 
-	ret = may_autoload_module(kmod_name, allow_cap);
+	ret = may_autoload_module(current, kmod_name, allow_cap);
 	if (ret < 0)
 		pr_notice_ratelimited(
 			"module: automatic module loading of %.64s by \"%s\"[%d] was denied\n",
-- 
2.10.2
