From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 09/10] landlock: Handle cgroups
Date: Thu, 25 Aug 2016 12:32:44 +0200
Message-ID: <1472121165-29071-10-git-send-email-mic@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4459-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)
to compare the current process cgroup with a cgroup handle, The handle
can match the current cgroup if it is the same or a child. This allows
to make conditional rules according to the current cgroup.

A cgroup handle is a map entry created from a file descriptor referring
a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case, the
map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.

An unprivileged process can create and manipulate cgroups thanks to
cgroup delegation.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h                |  8 ++++
 include/uapi/linux/bpf.h           | 15 ++++++
 kernel/bpf/arraymap.c              | 30 ++++++++++++
 kernel/bpf/verifier.c              |  6 +++
 security/landlock/Kconfig          |  3 ++
 security/landlock/Makefile         |  2 +-
 security/landlock/checker_cgroup.c | 96 ++++++++++++++++++++++++++++++++++++++
 security/landlock/checker_cgroup.h | 18 +++++++
 security/landlock/lsm.c            |  8 ++++
 9 files changed, 185 insertions(+), 1 deletion(-)
 create mode 100644 security/landlock/checker_cgroup.c
 create mode 100644 security/landlock/checker_cgroup.h

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 79014aedbea4..9e6786e7a40a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -14,6 +14,9 @@
 
 #ifdef CONFIG_SECURITY_LANDLOCK
 #include <linux/fs.h> /* struct file */
+#ifdef CONFIG_CGROUPS
+#include <linux/cgroup-defs.h> /* struct cgroup_subsys_state */
+#endif	/* CONFIG_CGROUPS */
 #endif /* CONFIG_SECURITY_LANDLOCK */
 
 struct bpf_map;
@@ -85,6 +88,7 @@ enum bpf_arg_type {
 	ARG_PTR_TO_STRUCT_FILE,		/* pointer to struct file */
 	ARG_PTR_TO_STRUCT_CRED,		/* pointer to struct cred */
 	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS,	/* pointer to Landlock FS handle */
+	ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP,	/* pointer to Landlock cgroup handle */
 };
 
 /* type of values returned from helper functions */
@@ -148,6 +152,7 @@ enum bpf_reg_type {
 	PTR_TO_STRUCT_FILE,
 	PTR_TO_STRUCT_CRED,
 	CONST_PTR_TO_LANDLOCK_HANDLE_FS,
+	CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP,
 };
 
 struct bpf_prog;
@@ -212,6 +217,9 @@ struct map_landlock_handle {
 	u32 type; /* e.g. BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD */
 	union {
 		struct file *file;
+#ifdef CONFIG_CGROUPS
+		struct cgroup_subsys_state *css;
+#endif	/* CONFIG_CGROUPS */
 	};
 };
 #endif /* CONFIG_SECURITY_LANDLOCK */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 88af79dd668c..7f60b9fdb35c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -90,12 +90,14 @@ enum bpf_map_type {
 enum bpf_map_array_type {
 	BPF_MAP_ARRAY_TYPE_UNSPEC,
 	BPF_MAP_ARRAY_TYPE_LANDLOCK_FS,
+	BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP,
 };
 
 enum bpf_map_handle_type {
 	BPF_MAP_HANDLE_TYPE_UNSPEC,
 	BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD,
 	BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB,
+	BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD,
 };
 
 enum bpf_map_array_op {
@@ -364,6 +366,19 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file,
 
+	/**
+	 * bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)
+	 * Check if the current process is a leaf of cgroup handles
+	 *
+	 * @opt: check options (e.g. LANDLOCK_FLAG_OPT_REVERSE)
+	 * @map: handles to compare against
+	 * @map_op: which elements of the map to use (e.g. BPF_MAP_ARRAY_OP_OR)
+	 *
+	 * Return: 0 if the current cgroup is the sam or beneath the handle,
+	 * 1 otherwise, or a negative value if an error occurred.
+	 */
+	BPF_FUNC_landlock_cmp_cgroup_beneath,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 6804dafd8355..050b3d8d88c8 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -19,6 +19,12 @@
 #include <linux/file.h> /* fput() */
 #include <linux/fs.h> /* struct file */
 
+#ifdef CONFIG_SECURITY_LANDLOCK
+#ifdef CONFIG_CGROUPS
+#include <linux/cgroup-defs.h> /* struct cgroup_subsys_state */
+#endif	/* CONFIG_CGROUPS */
+#endif /* CONFIG_SECURITY_LANDLOCK */
+
 static void bpf_array_free_percpu(struct bpf_array *array)
 {
 	int i;
@@ -514,6 +520,12 @@ static void landlock_put_handle(struct map_landlock_handle *handle)
 		else
 			WARN_ON(1);
 		break;
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD:
+		if (likely(handle->css))
+			css_put(handle->css);
+		else
+			WARN_ON(1);
+		break;
 	default:
 		WARN_ON(1);
 	}
@@ -541,6 +553,10 @@ static enum bpf_map_array_type landlock_get_array_type(
 	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
 	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_GLOB:
 		return BPF_MAP_ARRAY_TYPE_LANDLOCK_FS;
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD:
+#ifdef CONFIG_CGROUPS
+		return BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP;
+#endif	/* CONFIG_CGROUPS */
 	case BPF_MAP_HANDLE_TYPE_UNSPEC:
 	default:
 		return -EINVAL;
@@ -557,6 +573,9 @@ static inline long landlock_store_handle(struct map_landlock_handle *dst,
 		struct landlock_handle *khandle)
 {
 	struct path kpath;
+#ifdef CONFIG_CGROUPS
+	struct cgroup_subsys_state *css;
+#endif	/* CONFIG_CGROUPS */
 	struct file *handle_file;
 
 	if (unlikely(!khandle))
@@ -569,6 +588,17 @@ static inline long landlock_store_handle(struct map_landlock_handle *dst,
 		FGET_OR_RET(handle_file, khandle->fd);
 		dst->file = handle_file;
 		break;
+#ifdef CONFIG_CGROUPS
+	case BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD:
+		FGET_OR_RET(handle_file, khandle->fd);
+		css = css_tryget_online_from_dir(file_dentry(handle_file), NULL);
+		fput(handle_file);
+		/* NULL css check done by css_tryget_online_from_dir() */
+		if (IS_ERR(css))
+			return PTR_ERR(css);
+		dst->css = css;
+		break;
+#endif	/* CONFIG_CGROUPS */
 	default:
 		WARN_ON(1);
 		path_put(&kpath);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b182c88d5c13..b4e5c3bbc520 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -247,6 +247,7 @@ static const char * const reg_type_str[] = {
 	[PTR_TO_STRUCT_FILE]	= "struct_file",
 	[PTR_TO_STRUCT_CRED]	= "struct_cred",
 	[CONST_PTR_TO_LANDLOCK_HANDLE_FS] = "landlock_handle_fs",
+	[CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP] = "landlock_handle_cgroup",
 };
 
 static void print_verifier_state(struct verifier_state *state)
@@ -560,6 +561,7 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 	case PTR_TO_STRUCT_FILE:
 	case PTR_TO_STRUCT_CRED:
 	case CONST_PTR_TO_LANDLOCK_HANDLE_FS:
+	case CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP:
 		return true;
 	default:
 		return false;
@@ -955,6 +957,8 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = PTR_TO_STRUCT_CRED;
 	} else if (arg_type == ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS) {
 		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_FS;
+	} else if (arg_type == ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP) {
+		expected_type = CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
@@ -1733,6 +1737,8 @@ static inline enum bpf_reg_type bpf_reg_type_from_map(struct bpf_map *map)
 	switch (map->map_array_type) {
 	case BPF_MAP_ARRAY_TYPE_LANDLOCK_FS:
 		return CONST_PTR_TO_LANDLOCK_HANDLE_FS;
+	case BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP:
+		return CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP;
 	case BPF_MAP_ARRAY_TYPE_UNSPEC:
 	default:
 		return CONST_PTR_TO_MAP;
diff --git a/security/landlock/Kconfig b/security/landlock/Kconfig
index dc8328d216d7..414eb047e50e 100644
--- a/security/landlock/Kconfig
+++ b/security/landlock/Kconfig
@@ -10,6 +10,9 @@ config SECURITY_LANDLOCK
 	  of stacked eBPF programs for some LSM hooks. Each program can do some
 	  access comparison to check if an access request is legitimate.
 
+	  It is recommended to enable cgroups to be able to match a policy
+	  according to a group of processes.
+
 	  Further information about eBPF can be found in
 	  Documentation/networking/filter.txt
 
diff --git a/security/landlock/Makefile b/security/landlock/Makefile
index 27f359a8cfaa..cdaaa152b849 100644
--- a/security/landlock/Makefile
+++ b/security/landlock/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_SECURITY_LANDLOCK) := landlock.o
 
-landlock-y := lsm.o checker_fs.o
+landlock-y := lsm.o checker_fs.o checker_cgroup.o
diff --git a/security/landlock/checker_cgroup.c b/security/landlock/checker_cgroup.c
new file mode 100644
index 000000000000..97f29ac64188
--- /dev/null
+++ b/security/landlock/checker_cgroup.c
@@ -0,0 +1,96 @@
+/*
+ * Landlock LSM - cgroup Checkers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef CONFIG_CGROUPS
+
+#include <asm/current.h>
+#include <linux/bpf.h> /* enum bpf_map_array_op */
+#include <linux/cgroup-defs.h> /* struct cgroup_subsys_state */
+#include <linux/cgroup.h> /* cgroup_is_descendant(), task_css_set() */
+#include <linux/errno.h>
+
+#include "checker_cgroup.h"
+
+
+/*
+ * bpf_landlock_cmp_cgroup_beneath
+ *
+ * Cf. include/uapi/linux/bpf.h
+ */
+static inline u64 bpf_landlock_cmp_cgroup_beneath(u64 r1_option, u64 r2_map,
+		u64 r3_map_op, u64 r4, u64 r5)
+{
+	u8 option = (u8) r1_option;
+	struct bpf_map *map = (struct bpf_map *) (unsigned long) r2_map;
+	enum bpf_map_array_op map_op = r3_map_op;
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct cgroup *cg1, *cg2;
+	struct map_landlock_handle *handle;
+	int i;
+
+	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP is an arraymap */
+	if (unlikely(!map)) {
+		WARN_ON(1);
+		return -EFAULT;
+	}
+	if (unlikely((option | _LANDLOCK_FLAG_OPT_MASK) != _LANDLOCK_FLAG_OPT_MASK))
+		return -EINVAL;
+
+	/* for now, only handle OP_OR */
+	switch (map_op) {
+	case BPF_MAP_ARRAY_OP_OR:
+		break;
+	case BPF_MAP_ARRAY_OP_UNSPEC:
+	case BPF_MAP_ARRAY_OP_AND:
+	case BPF_MAP_ARRAY_OP_XOR:
+	default:
+		return -EINVAL;
+	}
+
+	synchronize_rcu();
+
+	for (i = 0; i < array->n_entries; i++) {
+		handle = (struct map_landlock_handle *)
+				(array->value + array->elem_size * i);
+
+		/* protected by the proto types, should not happen */
+		if (unlikely(handle->type != BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD)) {
+			WARN_ON(1);
+			return -EFAULT;
+		}
+		if (unlikely(!handle->css)) {
+			WARN_ON(1);
+			return -EFAULT;
+		}
+
+		if (option & LANDLOCK_FLAG_OPT_REVERSE) {
+			cg1 = handle->css->cgroup;
+			cg2 = task_css_set(current)->dfl_cgrp;
+		} else {
+			cg1 = task_css_set(current)->dfl_cgrp;
+			cg2 = handle->css->cgroup;
+		}
+
+		if (cgroup_is_descendant(cg1, cg2))
+			return 0;
+	}
+	return 1;
+}
+
+const struct bpf_func_proto bpf_landlock_cmp_cgroup_beneath_proto = {
+	.func		= bpf_landlock_cmp_cgroup_beneath,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP,
+	.arg3_type	= ARG_ANYTHING,
+};
+
+#endif	/* CONFIG_CGROUPS */
diff --git a/security/landlock/checker_cgroup.h b/security/landlock/checker_cgroup.h
new file mode 100644
index 000000000000..497cad7c2bb8
--- /dev/null
+++ b/security/landlock/checker_cgroup.h
@@ -0,0 +1,18 @@
+/*
+ * Landlock LSM - cgroup Checkers
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#ifdef CONFIG_CGROUPS
+#ifndef _SECURITY_LANDLOCK_CHECKER_CGROUP_H
+#define _SECURITY_LANDLOCK_CHECKER_CGROUP_H
+
+extern const struct bpf_func_proto bpf_landlock_cmp_cgroup_beneath_proto;
+
+#endif /* _SECURITY_LANDLOCK_CHECKER_CGROUP_H */
+#endif /* CONFIG_CGROUPS */
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index 8645743243b6..cc4759f4e6c5 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -18,6 +18,10 @@
 
 #include "checker_fs.h"
 
+#ifdef CONFIG_CGROUPS
+#include "checker_cgroup.h"
+#endif /* CONFIG_CGROUPS */
+
 #define LANDLOCK_HOOK_INIT(NAME) LSM_HOOK_INIT(NAME, landlock_hook_##NAME)
 
 #define LANDLOCK_HOOKx(X, NAME, CNAME, ...)				\
@@ -124,6 +128,10 @@ static const struct bpf_func_proto *bpf_landlock_func_proto(
 		return &bpf_landlock_cmp_fs_prop_with_struct_file_proto;
 	case BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file:
 		return &bpf_landlock_cmp_fs_beneath_with_struct_file_proto;
+	case BPF_FUNC_landlock_cmp_cgroup_beneath:
+#ifdef CONFIG_CGROUPS
+		return &bpf_landlock_cmp_cgroup_beneath_proto;
+#endif	/* CONFIG_CGROUPS */
 	default:
 		return NULL;
 	}
-- 
2.8.1
