From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 10/10] samples/landlock: Add sandbox example
Date: Thu, 25 Aug 2016 12:32:45 +0200
Message-ID: <1472121165-29071-11-git-send-email-mic@digikod.net>
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
Return-path: <kernel-hardening-return-4461-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add a basic sandbox tool to create a process isolated from some part of
the system. This can depend of the current cgroup.

Example:

  $ mkdir /sys/fs/cgroup/sandboxed
  $ ls /home
  user1
  $ LANDLOCK_CGROUPS='/sys/fs/cgroup/sandboxed' \
      LANDLOCK_ALLOWED='/bin:/lib:/usr:/tmp:/proc/self/fd/0' \
      ./sandbox /bin/sh -i
  $ ls /home
  user1
  $ echo $$ > /sys/fs/cgroup/sandboxed/cgroup.procs
  $ ls /home
  ls: cannot open directory '/home': Permission denied

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/Makefile            |   2 +-
 samples/landlock/.gitignore |   1 +
 samples/landlock/Makefile   |  16 +++
 samples/landlock/sandbox.c  | 295 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 313 insertions(+), 1 deletion(-)
 create mode 100644 samples/landlock/.gitignore
 create mode 100644 samples/landlock/Makefile
 create mode 100644 samples/landlock/sandbox.c

diff --git a/samples/Makefile b/samples/Makefile
index 2e3b523d7097..42e6a613f728 100644
--- a/samples/Makefile
+++ b/samples/Makefile
@@ -2,4 +2,4 @@
 
 obj-$(CONFIG_SAMPLES)	+= kobject/ kprobes/ trace_events/ livepatch/ \
 			   hw_breakpoint/ kfifo/ kdb/ hidraw/ rpmsg/ seccomp/ \
-			   configfs/ connector/ v4l/
+			   configfs/ connector/ v4l/ landlock/
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
index 000000000000..86604963c30c
--- /dev/null
+++ b/samples/landlock/sandbox.c
@@ -0,0 +1,295 @@
+/*
+ * Landlock LSM - Sandbox Example
+ *
+ * Copyright (C) 2016  Mickaël Salaün <mic@digikod.net>
+ *
+ * The code may be used by anyone for any purpose, and can serve as a starting
+ * point for developing a sandbox.
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
+#define ARRAY_SIZE(a)	(sizeof(a) / sizeof(a[0]))
+
+static int apply_sandbox(const char **allowed_paths, int path_nb, const char **cgroup_paths, int cgroup_nb)
+{
+	__u32 key;
+	int i, ret = 0, map_fs = -1, map_cg = -1, offset;
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
+	if (seccomp(SECCOMP_SET_MODE_FILTER, 0, &prog0)) {
+		perror("seccomp(set_filter)");
+		return 1;
+	}
+
+	if (path_nb) {
+		map_fs = bpf_create_map(BPF_MAP_TYPE_LANDLOCK_ARRAY, sizeof(key), sizeof(struct landlock_handle), 10, 0);
+		if (map_fs < 0) {
+			fprintf(stderr, "bpf_create_map(fs");
+			perror(")");
+			return 1;
+		}
+		for (key = 0; key < path_nb; key++) {
+			int fd = open(allowed_paths[key], O_RDONLY | O_CLOEXEC);
+			if (fd < 0) {
+				fprintf(stderr, "open(fs: \"%s\"", allowed_paths[key]);
+				perror(")");
+				return 1;
+			}
+			struct landlock_handle handle = {
+				.type = BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD,
+				.fd = (__u64)fd,
+			};
+
+			/* register a new LSM handle */
+			if (bpf_update_elem(map_fs, &key, &handle, BPF_ANY)) {
+				fprintf(stderr, "bpf_update_elem(fs: \"%s\"", allowed_paths[key]);
+				perror(")");
+				close(fd);
+				return 1;
+			}
+			close(fd);
+		}
+	}
+	if (cgroup_nb) {
+		map_cg = bpf_create_map(BPF_MAP_TYPE_LANDLOCK_ARRAY, sizeof(key), sizeof(struct landlock_handle), 10, 0);
+		if (map_cg < 0) {
+			fprintf(stderr, "bpf_create_map(cgroup");
+			perror(")");
+			ret = 1;
+			goto err_map_cgroup;
+		}
+		for (key = 0; key < cgroup_nb; key++) {
+			int fd = open(cgroup_paths[key], O_RDONLY | O_CLOEXEC);
+			if (fd < 0) {
+				fprintf(stderr, "open(cgroup: \"%s\"", cgroup_paths[key]);
+				perror(")");
+				return 1;
+			}
+			struct landlock_handle handle = {
+				.type = BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD,
+				.fd = (__u64)fd,
+			};
+
+			/* register a new LSM handle */
+			if (bpf_update_elem(map_cg, &key, &handle, BPF_ANY)) {
+				fprintf(stderr, "bpf_update_elem(cgroup: \"%s\"", cgroup_paths[key]);
+				perror(")");
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
+		/* check our cookie (not used in this example) */
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_6, offsetof(struct landlock_data, cookie)),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 5, 2),
+		BPF_MOV32_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+	};
+	struct bpf_insn hook_path[] = {
+		/* specify an option, if any */
+		BPF_MOV32_IMM(BPF_REG_1, 0),
+		/* handles to compare with */
+		BPF_LD_MAP_FD(BPF_REG_2, map_fs),
+		BPF_MOV64_IMM(BPF_REG_3, BPF_MAP_ARRAY_OP_OR),
+		/* hook argument (struct file) */
+		BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_6, offsetof(struct landlock_data, args[0])),
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
+	struct bpf_insn hook_cgroup[] = {
+		/* specify an option, if any */
+		BPF_MOV32_IMM(BPF_REG_1, 0),
+		/* handles to compare with */
+		BPF_LD_MAP_FD(BPF_REG_2, map_cg),
+		BPF_MOV64_IMM(BPF_REG_3, BPF_MAP_ARRAY_OP_OR),
+		/* checker function */
+		BPF_EMIT_CALL(BPF_FUNC_landlock_cmp_cgroup_beneath),
+
+		/* if the current process is in a blacklisted cgroup */
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 1, 2),
+		BPF_MOV32_IMM(BPF_REG_0, EACCES),
+		BPF_EXIT_INSN(),
+	};
+	struct bpf_insn hook_post[] = {
+		BPF_MOV32_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+	};
+	/* deny all processes if no cgroup is specified */
+	if (cgroup_nb == 0) {
+		hook_post[0] = BPF_MOV32_IMM(BPF_REG_0, EACCES);
+	}
+
+	unsigned long hook_size = sizeof(hook_pre) + sizeof(hook_path) * (path_nb ? 1 : 0) +
+		sizeof(hook_cgroup) * (cgroup_nb ? 1 : 0) + sizeof(hook_post);
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
+	if (cgroup_nb) {
+		memcpy(hook0 + offset, hook_cgroup, sizeof(hook_cgroup));
+		offset += sizeof(hook_cgroup) / sizeof(hook0[0]);
+	}
+	memcpy(hook0 + offset, hook_post, sizeof(hook_post));
+
+	/* TODO: handle inode_permission hook (e.g. chdir) */
+	enum bpf_prog_type hook_types[] = {
+		BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
+		BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
+		BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
+	};
+	for (i = 0; i < ARRAY_SIZE(hook_types); i++) {
+		int bpf0 = bpf_prog_load(hook_types[i],
+				hook0, hook_size, "GPL", 0);
+		if (bpf0 == -1) {
+			perror("bpf");
+			fprintf(stderr, "%s", bpf_log_buf);
+			ret = 1;
+			break;
+		}
+		if (seccomp(SECCOMP_SET_LANDLOCK_HOOK, 0, &bpf0)) {
+			perror("seccomp(set_hook)");
+			ret = 1;
+			close(bpf0);
+			break;
+		}
+		close(bpf0);
+	}
+
+	free(hook0);
+err_alloc:
+	if (cgroup_nb) {
+		close(map_cg);
+	}
+err_map_cgroup:
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
+static int parse_path(char *env_path, const char ***path_list) {
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
+	if (argc < 2) {
+		fprintf(stderr, "usage: %s <cmd> [args]...\n\n", argv[0]);
+		fprintf(stderr, "Environment variables containing paths, each separated by a colon:\n");
+		fprintf(stderr, "* %s (whitelist of allowed files and directories)\n", ENV_FS_PATH_NAME);
+		fprintf(stderr, "* %s (optional cgroups for which the sandbox is enabled)\n", ENV_CGROUP_PATH_NAME);
+		fprintf(stderr, "\nexample:\n%s='/sys/fs/cgroup/sandboxed' %s='/bin:/lib:/usr:/tmp:/proc/self/fd/0' %s /bin/sh -i\n", ENV_CGROUP_PATH_NAME, ENV_FS_PATH_NAME, argv[0]);
+		return 1;
+	}
+	path_nb = parse_path(env_path_allowed, &sb_paths);
+	cgroup_nb = parse_path(env_path_cgroup, &cg_paths);
+	cmd_path = argv[1];
+	cmd_argv = argv + 1;
+	if (apply_sandbox(sb_paths, path_nb, cg_paths, cgroup_nb))
+		return 1;
+	execve(cmd_path, cmd_argv, envp);
+	perror("execve");
+	return 1;
+}
-- 
2.8.1
