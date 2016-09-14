From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 22/22] samples/landlock: Add sandbox example
Date: Wed, 14 Sep 2016 09:24:15 +0200
Message-ID: <20160914072415.26021-23-mic@digikod.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:45166 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759045AbcINH0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 03:26:21 -0400
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a basic sandbox tool to create a process isolated from some part of
the system. This can depend of the current cgroup.

Example with the current process hierarchy (seccomp):

  $ ls /home
  user1
  $ LANDLOCK_ALLOWED='/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
      ./samples/landlock/sandbox /bin/sh -i
  Launching a new sandboxed process.
  $ ls /home
  ls: cannot open directory '/home': Permission denied

Example with a cgroup:

  $ mkdir /sys/fs/cgroup/sandboxed
  $ ls /home
  user1
  $ LANDLOCK_CGROUPS='/sys/fs/cgroup/sandboxed' \
      LANDLOCK_ALLOWED='/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
      ./samples/landlock/sandbox
  Ready to sandbox with cgroups.
  $ ls /home
  user1
  $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
  $ ls /home
  ls: cannot open directory '/home': Permission denied

Changes since v2:
* use BPF_PROG_ATTACH for cgroup handling

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 samples/Makefile            |   2 +-
 samples/landlock/.gitignore |   1 +
 samples/landlock/Makefile   |  16 +++
 samples/landlock/sandbox.c  | 307 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 325 insertions(+), 1 deletion(-)
 create mode 100644 samples/landlock/.gitignore
 create mode 100644 samples/landlock/Makefile
 create mode 100644 samples/landlock/sandbox.c

diff --git a/samples/Makefile b/samples/Makefile
index 1a20169d85ac..a2dcd57ca7ac 100644
--- a/samples/Makefile
+++ b/samples/Makefile
@@ -2,4 +2,4 @@
 
 obj-$(CONFIG_SAMPLES)	+= kobject/ kprobes/ trace_events/ livepatch/ \
 			   hw_breakpoint/ kfifo/ kdb/ hidraw/ rpmsg/ seccomp/ \
-			   configfs/ connector/ v4l/ trace_printk/
+			   configfs/ connector/ v4l/ trace_printk/ landlock/
diff --git a/samples/landlock/.gitignore b/samples/landlock/.gitignore
new file mode 100644
index 000000000000..f6c6da930a30
--- /dev/null
+++ b/samples/landlock/.gitignore
@@ -0,0 +1 @@
+/sandbox
diff --git a/samples/landlock/Makefile b/samples/landlock/Makefile
new file mode 100644
index 000000000000..d1044b2afd27
--- /dev/null
+++ b/samples/landlock/Makefile
@@ -0,0 +1,16 @@
+# kbuild trick to avoid linker error. Can be omitted if a module is built.
+obj- := dummy.o
+
+hostprogs-$(CONFIG_SECURITY_LANDLOCK) := sandbox
+sandbox-objs := sandbox.o
+
+always := $(hostprogs-y)
+
+HOSTCFLAGS += -I$(objtree)/usr/include
+
+# Trick to allow make to be run from this directory
+all:
+	$(MAKE) -C ../../ $$PWD/
+
+clean:
+	$(MAKE) -C ../../ M=$$PWD clean
diff --git a/samples/landlock/sandbox.c b/samples/landlock/sandbox.c
new file mode 100644
index 000000000000..9d6ac00cdd23
--- /dev/null
+++ b/samples/landlock/sandbox.c
@@ -0,0 +1,307 @@
+/*
+ * Landlock LSM - Sandbox example
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 3, as
+ * published by the Free Software Foundation.
+ */
+
+#define _GNU_SOURCE
+#include <errno.h>
+#include <fcntl.h> /* open() */
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <linux/prctl.h>
+#include <linux/seccomp.h>
+#include <stddef.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/prctl.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+#include "../../tools/include/linux/filter.h"
+
+#include "../bpf/libbpf.c"
+
+#ifndef seccomp
+static int seccomp(unsigned int op, unsigned int flags, void *args)
+{
+	errno = 0;
+	return syscall(__NR_seccomp, op, flags, args);
+}
+#endif
+
+static int landlock_prog_load(const struct bpf_insn *insns, int prog_len,
+		enum landlock_hook_id hook_id, __u64 access)
+{
+	union bpf_attr attr = {
+		.prog_type = BPF_PROG_TYPE_LANDLOCK,
+		.insns = ptr_to_u64((void *) insns),
+		.insn_cnt = prog_len / sizeof(struct bpf_insn),
+		.license = ptr_to_u64((void *) "GPL"),
+		.log_buf = ptr_to_u64(bpf_log_buf),
+		.log_size = LOG_BUF_SIZE,
+		.log_level = 1,
+		.prog_subtype.landlock_hook = {
+			.id = hook_id,
+			.origin = LANDLOCK_FLAG_ORIGIN_SECCOMP |
+				LANDLOCK_FLAG_ORIGIN_SYSCALL |
+				LANDLOCK_FLAG_ORIGIN_INTERRUPT,
+			.access = access,
+		},
+	};
+
+	/* assign one field outside of struct init to make sure any
+	 * padding is zero initialized
+	 */
+	attr.kern_version = 0;
+
+	bpf_log_buf[0] = 0;
+
+	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
+}
+
+#define ARRAY_SIZE(a)	(sizeof(a) / sizeof(a[0]))
+
+static int apply_sandbox(const char **allowed_paths, int path_nb, const char
+		**cgroup_paths, int cgroup_nb)
+{
+	__u32 key;
+	int i, ret = 0, map_fs = -1, offset;
+
+	/* set up the test sandbox */
+	if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
+		perror("prctl(no_new_priv)");
+		return 1;
+	}
+
+	/* register a new syscall filter */
+	struct sock_filter filter0[] = {
+		/* pass a cookie containing 5 to the LSM hook filter */
+		BPF_STMT(BPF_RET|BPF_K, SECCOMP_RET_LANDLOCK | 5),
+	};
+	struct sock_fprog prog0 = {
+		.len = (unsigned short)ARRAY_SIZE(filter0),
+		.filter = filter0,
+	};
+	if (!cgroup_nb) {
+		if (seccomp(SECCOMP_SET_MODE_FILTER, 0, &prog0)) {
+			perror("seccomp(set_filter)");
+			return 1;
+		}
+	}
+
+	if (path_nb) {
+		map_fs = bpf_create_map(BPF_MAP_TYPE_LANDLOCK_ARRAY,
+				sizeof(key), sizeof(struct landlock_handle),
+				10, 0);
+		if (map_fs < 0) {
+			fprintf(stderr, "bpf_create_map(fs): %s\n",
+					strerror(errno));
+			return 1;
+		}
+		for (key = 0; key < path_nb; key++) {
+			int fd = open(allowed_paths[key],
+					O_RDONLY | O_CLOEXEC);
+			if (fd < 0) {
+				fprintf(stderr, "open(fs: \"%s\"): %s\n",
+						allowed_paths[key],
+						strerror(errno));
+				return 1;
+			}
+			struct landlock_handle handle = {
+				.type = BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD,
+				.fd = (__u64)fd,
+			};
+
+			/* register a new LSM handle */
+			if (bpf_update_elem(map_fs, &key, &handle, BPF_ANY)) {
+				fprintf(stderr, "bpf_update_elem(fs: \"%s\"): %s\n",
+						allowed_paths[key],
+						strerror(errno));
+				close(fd);
+				return 1;
+			}
+			close(fd);
+		}
+	}
+
+	/* load a LSM filter hook (eBPF) */
+	struct bpf_insn hook_pre[] = {
+		/* save context */
+		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+
+#if 0
+		/* check our cookie (not used in this example) */
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_6, offsetof(struct
+					landlock_data, cookie)),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 5, 2),
+		BPF_MOV32_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+#endif
+	};
+	struct bpf_insn hook_path[] = {
+		/* specify an option, if any */
+		BPF_MOV32_IMM(BPF_REG_1, 0),
+		/* handles to compare with */
+		BPF_LD_MAP_FD(BPF_REG_2, map_fs),
+		BPF_MOV64_IMM(BPF_REG_3, BPF_MAP_ARRAY_OP_OR),
+		/* hook argument (struct file) */
+		BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_6, offsetof(struct
+					landlock_data, args[0])),
+		/* checker function */
+		BPF_EMIT_CALL(BPF_FUNC_landlock_cmp_fs_beneath_with_struct_file),
+
+		/* if the checked path is beneath the handle */
+		BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 2),
+		BPF_MOV32_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+		/* allow anonymous mapping */
+		BPF_JMP_IMM(BPF_JNE, BPF_REG_0, -ENOENT, 2),
+		BPF_MOV32_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+		/* deny by default, if any error */
+		BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 2),
+		BPF_MOV32_IMM(BPF_REG_0, EACCES),
+		BPF_EXIT_INSN(),
+	};
+	struct bpf_insn hook_post[] = {
+		BPF_MOV32_IMM(BPF_REG_0, EACCES),
+		BPF_EXIT_INSN(),
+	};
+
+	unsigned long hook_size = sizeof(hook_pre) + sizeof(hook_path) *
+		(path_nb ? 1 : 0) + sizeof(hook_post);
+
+	struct bpf_insn *hook0 = malloc(hook_size);
+	if (!hook0) {
+		perror("malloc");
+		ret = 1;
+		goto err_alloc;
+	}
+	memcpy(hook0, hook_pre, sizeof(hook_pre));
+	offset = sizeof(hook_pre) / sizeof(hook0[0]);
+	if (path_nb) {
+		memcpy(hook0 + offset, hook_path, sizeof(hook_path));
+		offset += sizeof(hook_path) / sizeof(hook0[0]);
+	}
+	memcpy(hook0 + offset, hook_post, sizeof(hook_post));
+
+	/* TODO: handle inode_permission hook (e.g. chdir) */
+	enum landlock_hook_id hooks[] = {
+		LANDLOCK_HOOK_FILE_OPEN,
+		LANDLOCK_HOOK_FILE_PERMISSION,
+		LANDLOCK_HOOK_MMAP_FILE,
+	};
+	for (i = 0; i < ARRAY_SIZE(hooks) && !ret; i++) {
+		int bpf0 = landlock_prog_load(hook0, hook_size, hooks[i], 0);
+		if (bpf0 == -1) {
+			perror("prog_load");
+			fprintf(stderr, "%s", bpf_log_buf);
+			ret = 1;
+			break;
+		}
+		if (!cgroup_nb) {
+			if (seccomp(SECCOMP_SET_LANDLOCK_HOOK, 0, &bpf0)) {
+				perror("seccomp(set_hook)");
+				ret = 1;
+			}
+		} else {
+			for (key = 0; key < cgroup_nb && !ret; key++) {
+				int fd = open(cgroup_paths[key],
+						O_DIRECTORY | O_CLOEXEC);
+				if (fd < 0) {
+					fprintf(stderr, "open(cgroup: \"%s\"): %s\n",
+							cgroup_paths[key], strerror(errno));
+					ret = 1;
+					break;
+				}
+				if (bpf_prog_attach(bpf0, fd, BPF_CGROUP_LANDLOCK)) {
+					fprintf(stderr, "bpf_prog_attach(cgroup: \"%s\"): %s\n",
+							cgroup_paths[key], strerror(errno));
+					ret = 1;
+				}
+				close(fd);
+			}
+		}
+		close(bpf0);
+	}
+
+	free(hook0);
+err_alloc:
+	if (path_nb) {
+		close(map_fs);
+	}
+	return ret;
+}
+
+#define ENV_FS_PATH_NAME "LANDLOCK_ALLOWED"
+#define ENV_CGROUP_PATH_NAME "LANDLOCK_CGROUPS"
+#define ENV_PATH_TOKEN ":"
+
+static int parse_path(char *env_path, const char ***path_list)
+{
+	int i, path_nb = 0;
+
+	if (env_path) {
+		path_nb++;
+		for (i = 0; env_path[i]; i++) {
+			if (env_path[i] == ENV_PATH_TOKEN[0]) {
+				path_nb++;
+			}
+		}
+	}
+	*path_list = malloc(path_nb * sizeof(**path_list));
+	for (i = 0; i < path_nb; i++) {
+		(*path_list)[i] = strsep(&env_path, ENV_PATH_TOKEN);
+	}
+
+	return path_nb;
+}
+
+int main(int argc, char * const argv[], char * const *envp)
+{
+	char *cmd_path;
+	char *env_path_allowed, *env_path_cgroup;
+	int path_nb, cgroup_nb;
+	const char **sb_paths = NULL;
+	const char **cg_paths = NULL;
+	char * const *cmd_argv;
+
+	env_path_allowed = getenv(ENV_FS_PATH_NAME);
+	if (env_path_allowed)
+		env_path_allowed = strdup(env_path_allowed);
+	env_path_cgroup = getenv(ENV_CGROUP_PATH_NAME);
+	if (env_path_cgroup)
+		env_path_cgroup = strdup(env_path_cgroup);
+
+	path_nb = parse_path(env_path_allowed, &sb_paths);
+	cgroup_nb = parse_path(env_path_cgroup, &cg_paths);
+	if (argc < 2 && !cgroup_nb) {
+		fprintf(stderr, "usage: %s <cmd> [args]...\n\n", argv[0]);
+		fprintf(stderr, "Environment variables containing paths, each separated by a colon:\n");
+		fprintf(stderr, "* %s (whitelist of allowed files and directories)\n",
+				ENV_FS_PATH_NAME);
+		fprintf(stderr, "* %s (optional cgroup paths for which the sandbox is enabled)\n",
+				ENV_CGROUP_PATH_NAME);
+		fprintf(stderr, "\nexample:\n%s='/bin:/lib:/usr:/tmp:/proc/self/fd/0' %s /bin/sh -i\n",
+				ENV_FS_PATH_NAME, argv[0]);
+		return 1;
+	}
+	if (apply_sandbox(sb_paths, path_nb, cg_paths, cgroup_nb))
+		return 1;
+	if (!cgroup_nb) {
+		cmd_path = argv[1];
+		cmd_argv = argv + 1;
+		fprintf(stderr, "Launching a new sandboxed process.\n");
+		execve(cmd_path, cmd_argv, envp);
+		perror("execve");
+		return 1;
+	}
+	fprintf(stderr, "Ready to sandbox with cgroups.\n");
+	return 0;
+}
-- 
2.9.3
