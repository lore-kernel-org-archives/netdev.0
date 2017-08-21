From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 07/10] landlock: Add ptrace restrictions
Date: Mon, 21 Aug 2017 02:09:30 +0200
Message-ID: <20170821000933.13024-8-mic@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.or
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-9526-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

A landlocked process has less privileges than a non-landlocked process
and must then be subject to additional restrictions when manipulating
processes. To be allowed to use ptrace(2) and related syscalls on a
target process, a landlocked process must have a subset of the target
process' rules.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---

Changes since v6:
* factor out ptrace check
* constify pointers
* cleanup headers
* use the new security_add_hooks()
---
 security/landlock/Makefile       |   2 +-
 security/landlock/hooks_ptrace.c | 123 +++++++++++++++++++++++++++++++++++++++
 security/landlock/hooks_ptrace.h |  11 ++++
 security/landlock/init.c         |   2 +
 4 files changed, 137 insertions(+), 1 deletion(-)
 create mode 100644 security/landlock/hooks_ptrace.c
 create mode 100644 security/landlock/hooks_ptrace.h

diff --git a/security/landlock/Makefile b/security/landlock/Makefile
index 8153b024ffd7..7ff911328e74 100644
--- a/security/landlock/Makefile
+++ b/security/landlock/Makefile
@@ -5,4 +5,4 @@ ccflags-$(CONFIG_SECURITY_LANDLOCK) += -Werror=unused-function
 
 obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
 
-landlock-y := init.o providers.o hooks.o hooks_fs.o
+landlock-y := init.o providers.o hooks.o hooks_ptrace.o hooks_fs.o
diff --git a/security/landlock/hooks_ptrace.c b/security/landlock/hooks_ptrace.c
new file mode 100644
index 000000000000..0f1c13172f54
--- /dev/null
+++ b/security/landlock/hooks_ptrace.c
@@ -0,0 +1,123 @@
+/*
+ * Landlock LSM - ptrace hooks
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <asm/current.h>
+#include <linux/errno.h>
+#include <linux/kernel.h> /* ARRAY_SIZE */
+#include <linux/lsm_hooks.h>
+#include <linux/sched.h> /* struct task_struct */
+#include <linux/seccomp.h>
+
+#include "common.h" /* struct landlock_events */
+#include "hooks.h" /* landlocked() */
+#include "hooks_ptrace.h"
+
+
+static bool landlock_events_are_subset(const struct landlock_events *parent,
+		const struct landlock_events *child)
+{
+	size_t i;
+
+	if (!parent || !child)
+		return false;
+	if (parent == child)
+		return true;
+
+	for (i = 0; i < ARRAY_SIZE(child->rules); i++) {
+		struct landlock_rule *walker;
+		bool found_parent = false;
+
+		if (!parent->rules[i])
+			continue;
+		for (walker = child->rules[i]; walker; walker = walker->prev) {
+			if (walker == parent->rules[i]) {
+				found_parent = true;
+				break;
+			}
+		}
+		if (!found_parent)
+			return false;
+	}
+	return true;
+}
+
+static bool landlock_task_has_subset_events(const struct task_struct *parent,
+		const struct task_struct *child)
+{
+#ifdef CONFIG_SECCOMP_FILTER
+	if (landlock_events_are_subset(parent->seccomp.landlock_events,
+				child->seccomp.landlock_events))
+		/* must be ANDed with other providers (i.e. cgroup) */
+		return true;
+#endif /* CONFIG_SECCOMP_FILTER */
+	return false;
+}
+
+static int landlock_task_ptrace(const struct task_struct *parent,
+		const struct task_struct *child)
+{
+	if (!landlocked(parent))
+		return 0;
+
+	if (!landlocked(child))
+		return -EPERM;
+
+	if (landlock_task_has_subset_events(parent, child))
+		return 0;
+
+	return -EPERM;
+}
+
+/**
+ * landlock_ptrace_access_check - determine whether the current process may
+ *				  access another
+ *
+ * @child: the process to be accessed
+ * @mode: the mode of attachment
+ *
+ * If the current task has Landlock rules, then the child must have at least
+ * the same rules.  Else denied.
+ *
+ * Determine whether a process may access another, returning 0 if permission
+ * granted, -errno if denied.
+ */
+static int landlock_ptrace_access_check(struct task_struct *child,
+		unsigned int mode)
+{
+	return landlock_task_ptrace(current, child);
+}
+
+/**
+ * landlock_ptrace_traceme - determine whether another process may trace the
+ *			     current one
+ *
+ * @parent: the task proposed to be the tracer
+ *
+ * If the parent has Landlock rules, then the current task must have the same
+ * or more rules.
+ * Else denied.
+ *
+ * Determine whether the nominated task is permitted to trace the current
+ * process, returning 0 if permission is granted, -errno if denied.
+ */
+static int landlock_ptrace_traceme(struct task_struct *parent)
+{
+	return landlock_task_ptrace(parent, current);
+}
+
+static struct security_hook_list landlock_hooks[] = {
+	LSM_HOOK_INIT(ptrace_access_check, landlock_ptrace_access_check),
+	LSM_HOOK_INIT(ptrace_traceme, landlock_ptrace_traceme),
+};
+
+__init void landlock_add_hooks_ptrace(void)
+{
+	security_add_hooks(landlock_hooks, ARRAY_SIZE(landlock_hooks), LANDLOCK_NAME);
+}
diff --git a/security/landlock/hooks_ptrace.h b/security/landlock/hooks_ptrace.h
new file mode 100644
index 000000000000..15b1f3479e0e
--- /dev/null
+++ b/security/landlock/hooks_ptrace.h
@@ -0,0 +1,11 @@
+/*
+ * Landlock LSM - ptrace hooks
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+__init void landlock_add_hooks_ptrace(void);
diff --git a/security/landlock/init.c b/security/landlock/init.c
index 81f373f7cc52..424f457b1832 100644
--- a/security/landlock/init.c
+++ b/security/landlock/init.c
@@ -14,6 +14,7 @@
 
 #include "common.h" /* LANDLOCK_* */
 #include "hooks_fs.h"
+#include "hooks_ptrace.h"
 
 
 static inline bool bpf_landlock_is_valid_access(int off, int size,
@@ -122,5 +123,6 @@ void __init landlock_add_hooks(void)
 {
 	pr_info("%s: ABI %u, ready to sandbox with %s\n",
 			LANDLOCK_NAME, LANDLOCK_ABI, "seccomp");
+	landlock_add_hooks_ptrace();
 	landlock_add_hooks_fs();
 }
-- 
2.14.1
