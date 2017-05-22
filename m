From: Djalal Harouni <tixxdz@gmail.com>
Subject: [PATCH v4 next 2/3] modules:capabilities: automatic module loading restriction
Date: Mon, 22 May 2017 13:57:05 +0200
Message-ID: <1495454226-10027-3-git-send-email-tixxdz@gmail.com>
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
	Zendyani <zendyani@gmail.com>,
	linux-doc@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>,
	Djalal Harouni <tixxdz@gmail.com>
To: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	Andy Lutomirski <luto@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Jessica Yu <jeyu@redhat.com>
Return-path: <kernel-hardening-return-7962-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
List-Id: netdev.vger.kernel.org

Currently, an explicit call to load or unload kernel modules require
CAP_SYS_MODULE capability. However unprivileged users have always been
able to load some modules using the implicit auto-load operation. An
automatic module loading happens when programs request a kernel feature
from a module that is not loaded. In order to satisfy userspace, the
kernel then automatically load all these required modules.

Historically, the kernel was always able to automatically load modules
if they are not blacklisted. This is one of the most important and
transparent operations of Linux, it allows to provide numerous other
features as they are needed which is crucial for a better user experience.
However, as Linux is popular now and used for different appliances some
of these may need to control such operations. For such systems, recent
needs showed that in some cases allowing to control automatic module
loading is as important as the operation itself. Restricting unprivileged
programs or attackers that abuse this feature to load unused modules or
modules that contain bugs is a significant security measure.

This allows administrators or some special programs to have the
appropriate time to update and deny module autoloading in advance, then
blacklist the corresponding ones. Not doing so may affect the global state
of the machine, especially containers where some apps are moved from one
context to another and not having such mechanisms may allow to expose
and exploit the vulnerable parts to escape the container sandbox.

Embedded or IoT devices also started to ship as containers using generic
distros, some vendors do not have the appropriate time to make their own
OS, hence, using base images is getting popular. These setups may include
unnecessary modules that the final applications will not need. Untrusted
access may abuse the module auto-load feature to expose vulnerabilities.

As every code contains bugs or vulnerabilties, the following
vulnerabilities that affected some features that are often compiled as
modules could have been completely blocked, by restricting autoloading
modules if the system does not need them.

Past months:
* DCCP use after free CVE-2017-6074 [1]
  Unprivileged to local root.

* XFRM framework CVE-2017-7184 [2]
  As advertised it seems it was used to break Ubuntu on a security
  contest.

* n_hldc CVE-2017-2636
* L2TPv3 CVE-2016-10200

This is a short list. Fixing this is a high priority.

To improve the current status, this patch introduces "modules_autoload_mode"
kernel sysctl flag. The flag controls modules auto-load feature and
complements "modules_disabled" which apply to all modules operations.
This new flag allows to control only automatic module loading and if it is
allowed or not, aligning in the process the implicit operation with the
explicit one where both now are covered by capabilities checks.

The three modes that "modules_autoload_mode" support allow to provide
restrictions on automatic module loading without breaking user
experience.

The sysctl flag is available at "/proc/sys/kernel/modules_autoload_mode"

When modules_autoload_mode is set to (0), the default, there are no
restrictions.

When modules_autoload_mode is set to (1), processes must have
CAP_SYS_MODULE to be able to trigger a module auto-load operation,
or CAP_NET_ADMIN for modules with a 'netdev-%s' alias.

When modules_autoload_mode is set to (2), automatic module loading is
disabled for all. Once set, this value can not be changed.

Notes on relation between "modules_disabled=0" and
"modules_autoload_mode=2":
1) Restricting automatic module loading does not interfere with
explicit module load or unload operations.

2) New features provided by modules can be made available without
rebooting the system.

3) A bad version of a module can be unloaded and replaced with a
better one without rebooting the system.

The original idea of module auto-load restriction comes from
'GRKERNSEC_MODHARDEN' config option.

Testing
-------

Example 1)

Before:
$ lsmod | grep ipip -
$ sudo ip tunnel add mytun mode ipip remote 10.0.2.100 local 10.0.2.15 ttl 255
$ lsmod | grep ipip -
ipip                   16384  0
tunnel4                16384  1 ipip
ip_tunnel              28672  1 ipip
$ cat /proc/sys/kernel/modules_autoload_mode
0

After:
$ lsmod | grep ipip -
# echo 2 > /proc/sys/kernel/modules_autoload_mode
$ sudo ip tunnel add mytun mode ipip remote 10.0.2.100 local 10.0.2.15 ttl 255
add tunnel "tunl0" failed: No such device
$ dmesg
...
[ 1876.378389] module: automatic module loading of netdev-tunl0 by "ip"[1453] was denied
[ 1876.380994] module: automatic module loading of tunl0 by "ip"[1453] was denied
...
$ lsmod | grep ipip -
$

Example 2)

DCCP use after free CVE-2017-6074:
The code path can be triggered by unprivileged, using the trigger.c
program for DCCP use after free [3] and that was fixed by
commit 5edabca9d4cff7f "dccp: fix freeing skb too early for IPV6_RECVPKTINFO".

Before:
$ lsmod | grep dccp
$ strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = 3
...
$ lsmod | grep dccp
dccp_ipv6              24576  5
dccp_ipv4              24576  5 dccp_ipv6
dccp                  102400  2 dccp_ipv6,dccp_ipv4

After:
Only privileged:
# echo 1 > /proc/sys/kernel/modules_autoload_mode
$ lsmod | grep dccp
$ strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = -1 ESOCKTNOSUPPORT (Socket type not supported)
...
$ lsmod | grep dccp
$ dmesg
...
[  175.945063] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1390] was denied
[  175.947952] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1390] was denied
[  175.956061] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1390] was denied
[  175.959733] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1390] was denied

$ sudo strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = 3
...
$ lsmod | grep dccp
dccp_ipv6              24576  6
dccp_ipv4              24576  5 dccp_ipv6
dccp                  102400  2 dccp_ipv6,dccp_ipv4

Disable automatic module loading:
$ lsmod | grep dccp
$ su - root
# echo 2 > /proc/sys/kernel/modules_autoload_mode
# strace ./dccp_trigger
...
socket(AF_INET6, SOCK_DCCP, IPPROTO_IP) = -1 ESOCKTNOSUPPORT (Socket type not supported)
...
$ lsmod | grep dccp
$ dmesg
...
[  126.596545] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1291] was denied
[  126.598800] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1291] was denied
[  126.601264] module: automatic module loading of net-pf-10-proto-0-type-6 by "dccp_trigger"[1291] was denied
[  126.602839] module: automatic module loading of net-pf-10-proto-0 by "dccp_trigger"[1291] was denied

As an example, this blocks abuses, DCCP still can be explicilty loaded by
an administrator using modprobe, at same time automatic module loading is
disabled forever.

[1] http://www.openwall.com/lists/oss-security/2017/02/22/3
[2] http://www.openwall.com/lists/oss-security/2017/03/29/2
[3] https://github.com/xairy/kernel-exploits/tree/master/CVE-2017-6074

Cc: Ben Hutchings <ben.hutchings@codethink.co.uk>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Serge Hallyn <serge@hallyn.com>
Cc: Andy Lutomirski <luto@kernel.org>
Suggested-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Djalal Harouni <tixxdz@gmail.com>
---
 Documentation/sysctl/kernel.txt | 51 +++++++++++++++++++++++++++++++++++++++++
 include/linux/module.h          | 19 ++++++++++++++-
 include/linux/security.h        |  3 ++-
 kernel/module.c                 | 42 +++++++++++++++++++++++++++++++++
 kernel/sysctl.c                 | 40 ++++++++++++++++++++++++++++++++
 security/commoncap.c            | 24 +++++++++++++++++++
 6 files changed, 177 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index bac23c1..3cc6592 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -43,6 +43,7 @@ show up in /proc/sys/kernel:
 - l2cr                        [ PPC only ]
 - modprobe                    ==> Documentation/debugging-modules.txt
 - modules_disabled
+- modules_autoload_mode
 - msg_next_id		      [ sysv ipc ]
 - msgmax
 - msgmnb
@@ -411,6 +412,56 @@ to false.  Generally used with the "kexec_load_disabled" toggle.
 
 ==============================================================
 
+modules_autoload_mode:
+
+A sysctl to control if modules auto-load feature is allowed or not.
+This sysctl complements "modules_disabled" which is for all module
+operations where this flag applies only to automatic module loading.
+Automatic module loading happens when programs request a kernel
+feature that is implemented by an unloaded module, the kernel
+automatically runs the program pointed by "modprobe" sysctl in order
+to load the corresponding module.
+
+Historically, the kernel was always able to automatically load modules
+if they are not blacklisted. This is one of the most important and
+transparent operations of Linux, it allows to provide numerous other
+features as they are needed which is crucial for a better user experience.
+However, as Linux is popular now and used for different appliances some
+of these may need to control such operations. For such systems, recent
+needs showed that in some cases allowing to control automatic module
+loading is as important as the operation itself. Restricting unprivileged
+programs or attackers that abuse this feature to load unused modules or
+modules that contain bugs is a significant security measure.
+
+The three modes that "modules_autoload_mode" support allow to provide
+restrictions on automatic module loading without breaking user
+experience.
+
+When modules_autoload_mode is set to (0), the default, there are no
+restrictions.
+
+When modules_autoload_mode is set to (1), processes must have
+CAP_SYS_MODULE to be able to trigger a module auto-load operation,
+or CAP_NET_ADMIN for modules with a 'netdev-%s' alias.
+
+When modules_autoload_mode is set to (2), automatic module loading is
+disabled for all. Once set, this value can not be changed.
+
+
+Notes on relation between "modules_disabled=0" and
+"modules_autoload_mode=2":
+1) Restricting automatic module loading does not interfere with
+explicit module load or unload operations.
+2) New features provided by modules can be made available without
+rebooting the system.
+3) A bad version of a module can be unloaded and replaced with a
+better one without rebooting the system.
+
+The original idea of module auto-load restriction comes from
+grsecurity 'GRKERNSEC_MODHARDEN' config option.
+
+==============================================================
+
 msg_next_id, sem_next_id, and shm_next_id:
 
 These three toggles allows to specify desired id for next allocated IPC
diff --git a/include/linux/module.h b/include/linux/module.h
index 21f5639..9b64896 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -261,7 +261,16 @@ struct notifier_block;
 
 #ifdef CONFIG_MODULES
 
-extern int modules_disabled; /* for sysctl */
+enum {
+	MODULES_AUTOLOAD_ALLOWED	= 0,
+	MODULES_AUTOLOAD_PRIVILEGED	= 1,
+	MODULES_AUTOLOAD_DISABLED	= 2,
+};
+
+extern int modules_disabled; /* sysctl for explicit module load/unload */
+extern int modules_autoload_mode; /* sysctl for automatic module loading */
+extern const int modules_autoload_max; /* max value for modules_autoload_mode */
+
 /* Get/put a kernel symbol (calls must be symmetric) */
 void *__symbol_get(const char *symbol);
 void *__symbol_get_gpl(const char *symbol);
@@ -497,6 +506,9 @@ bool __is_module_percpu_address(unsigned long addr, unsigned long *can_addr);
 bool is_module_percpu_address(unsigned long addr);
 bool is_module_text_address(unsigned long addr);
 
+/* Determine whether a module auto-load operation is permitted. */
+int may_autoload_module(char *kmod_name, int allow_cap);
+
 static inline bool within_module_core(unsigned long addr,
 				      const struct module *mod)
 {
@@ -641,6 +653,11 @@ static inline bool is_livepatch_module(struct module *mod)
 
 #else /* !CONFIG_MODULES... */
 
+static inline int may_autoload_module(char *kmod_name, int allow_cap)
+{
+	return -ENOSYS;
+}
+
 static inline struct module *__module_address(unsigned long addr)
 {
 	return NULL;
diff --git a/include/linux/security.h b/include/linux/security.h
index 2f4c9d3..90fe0cb 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -101,6 +101,7 @@ extern int cap_task_setscheduler(struct task_struct *p);
 extern int cap_task_setioprio(struct task_struct *p, int ioprio);
 extern int cap_task_setnice(struct task_struct *p, int nice);
 extern int cap_vm_enough_memory(struct mm_struct *mm, long pages);
+extern int cap_kernel_module_request(char *kmod_name, int allow_cap);
 
 struct msghdr;
 struct sk_buff;
@@ -928,7 +929,7 @@ static inline int security_kernel_create_files_as(struct cred *cred,
 
 static inline int security_kernel_module_request(char *kmod_name, int allow_cap)
 {
-	return 0;
+	return cap_kernel_module_request(kmod_name, allow_cap);
 }
 
 static inline int security_kernel_read_file(struct file *file,
diff --git a/kernel/module.c b/kernel/module.c
index 4a3665f..ce7a146 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -282,6 +282,8 @@ module_param(sig_enforce, bool_enable_only, 0644);
 
 /* Block module loading/unloading? */
 int modules_disabled = 0;
+int modules_autoload_mode = MODULES_AUTOLOAD_ALLOWED;
+const int modules_autoload_max = MODULES_AUTOLOAD_DISABLED;
 core_param(nomodule, modules_disabled, bint, 0);
 
 /* Waiting for a module to finish initializing? */
@@ -4296,6 +4298,46 @@ struct module *__module_text_address(unsigned long addr)
 }
 EXPORT_SYMBOL_GPL(__module_text_address);
 
+/**
+ * may_autoload_module - Determine whether a module auto-load operation
+ * is permitted
+ * @kmod_name: The module name
+ * @allow_cap: if positive, may allow to auto-load the module if this capability
+ * is set
+ *
+ * Determine whether a module auto-load operation is allowed or not. The check
+ * uses the sysctl "modules_autoload_mode" value.
+ *
+ * This allows to have more control on automatic module loading, and align it
+ * with explicit load/unload module operations. The kernel contains several
+ * modules, some of them are not updated often and may contain bugs and
+ * vulnerabilities.
+ *
+ * The "allow_cap" is passed by callers to explicitly note that the module has
+ * the appropriate alias and that the "allow_cap" capability is set. This is
+ * for backward compatibility, the aim is to have a clear picture where:
+ *
+ * 1) Implicit module loading is allowed
+ * 2) Implicit module loading as with the explicit one requires CAP_SYS_MODULE.
+ * 3) Implicit module loading as with the explicit one can be disabled.
+ *
+ * Returns 0 if the module request is allowed or -EPERM if not.
+ */
+int may_autoload_module(char *kmod_name, int allow_cap)
+{
+	if (modules_autoload_mode == MODULES_AUTOLOAD_ALLOWED)
+		return 0;
+	else if (modules_autoload_mode == MODULES_AUTOLOAD_PRIVILEGED) {
+		/* Check CAP_SYS_MODULE then allow_cap if valid */
+		if (capable(CAP_SYS_MODULE) ||
+		    (allow_cap > 0 && capable(allow_cap)))
+		       return 0;
+	}
+
+	/* MODULES_AUTOLOAD_DISABLED or not enough caps */
+	return -EPERM;
+}
+
 /* Don't grab lock, we're oopsing. */
 void print_modules(void)
 {
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4dfba1a..727c6a7 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -186,6 +186,11 @@ static int proc_taint(struct ctl_table *table, int write,
 			       void __user *buffer, size_t *lenp, loff_t *ppos);
 #endif
 
+#ifdef CONFIG_MODULES
+static int modules_autoload_dointvec_minmax(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos);
+#endif
+
 #ifdef CONFIG_PRINTK
 static int proc_dointvec_minmax_sysadmin(struct ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos);
@@ -661,6 +666,16 @@ static struct ctl_table kern_table[] = {
 		.extra1		= &one,
 		.extra2		= &one,
 	},
+	{
+		.procname	= "modules_autoload_mode",
+		.data		= &modules_autoload_mode,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		/* Handle pinning to max value */
+		.proc_handler	= modules_autoload_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= (void *)&modules_autoload_max,
+	},
 #endif
 #ifdef CONFIG_UEVENT_HELPER
 	{
@@ -2334,6 +2349,31 @@ static int proc_dointvec_minmax_sysadmin(struct ctl_table *table, int write,
 }
 #endif
 
+#ifdef CONFIG_MODULES
+static int modules_autoload_dointvec_minmax(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table t;
+
+	/*
+	 * Only CAP_SYS_MODULE in init user namespace are allowed to change this
+	 */
+	if (write && !capable(CAP_SYS_MODULE))
+		return -EPERM;
+
+	t = *table;
+	/*
+	 * If "modules_autoload_mode" already equals max value
+	 * MODULES_AUTOLOAD_DISABLED, then modules autoload is disabled
+	 * and can not be changed anymore.
+	 */
+	if (modules_autoload_mode == modules_autoload_max)
+		t.extra1 = t.extra2;
+
+	return proc_dointvec_minmax(&t, write, buffer, lenp, ppos);
+}
+#endif
+
 struct do_proc_dointvec_minmax_conv_param {
 	int *min;
 	int *max;
diff --git a/security/commoncap.c b/security/commoncap.c
index 7abebd7..d629d28 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -1069,6 +1069,29 @@ int cap_mmap_file(struct file *file, unsigned long reqprot,
 	return 0;
 }
 
+/**
+ * cap_kernel_module_request - Determine whether a module auto-load is permitted
+ * @kmod_name: The module name
+ * @allow_cap: if positive, may allow to auto-load the module if this capability
+ * is set
+ *
+ * Determine whether a module should be automatically loaded.
+ * Returns 0 if the module request should be allowed, -EPERM if not.
+ */
+int cap_kernel_module_request(char *kmod_name, int allow_cap)
+{
+	int ret;
+	char comm[sizeof(current->comm)];
+
+	ret = may_autoload_module(kmod_name, allow_cap);
+	if (ret < 0)
+		pr_notice_ratelimited(
+			"module: automatic module loading of %.64s by \"%s\"[%d] was denied\n",
+			kmod_name, get_task_comm(comm, current), current->pid);
+
+	return ret;
+}
+
 #ifdef CONFIG_SECURITY
 
 struct security_hook_list capability_hooks[] __lsm_ro_after_init = {
@@ -1090,6 +1113,7 @@ struct security_hook_list capability_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(task_setioprio, cap_task_setioprio),
 	LSM_HOOK_INIT(task_setnice, cap_task_setnice),
 	LSM_HOOK_INIT(vm_enough_memory, cap_vm_enough_memory),
+	LSM_HOOK_INIT(kernel_module_request, cap_kernel_module_request),
 };
 
 void __init capability_add_hooks(void)
-- 
2.10.2
