From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 08/10] bpf: Add a Landlock sandbox example
Date: Mon, 21 Aug 2017 02:09:31 +0200
Message-ID: <20170821000933.13024-9-mic@digikod.net>
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
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@k
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a basic sandbox tool to create a process isolated from some part of
the system. This sandbox create a read-only environment. It is only
allowed to write to a character device such as a TTY:

  # :> X
  # echo $?
  0
  # ./samples/bpf/landlock1 /bin/sh -i
  Launching a new sandboxed process.
  # :> Y
  cannot create Y: Operation not permitted

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
* check return value of load_and_attach()
* allow to write on pipes
* rename BPF_PROG_TYPE_LANDLOCK to BPF_PROG_TYPE_LANDLOCK_RULE
* rename Landlock version to ABI to better reflect its purpose
* use const variable (suggested by Kees Cook)
* remove useless definitions (suggested by Kees Cook)
* add detailed explanations (suggested by Kees Cook)

Changes since v5:
* cosmetic fixes
* rebase

Changes since v4:
* write Landlock rule in C and compiled it with LLVM
* remove cgroup handling
* remove path handling: only handle a read-only environment
* remove errno return codes

Changes since v3:
* remove seccomp and origin field: completely free from seccomp programs
* handle more FS-related hooks
* handle inode hooks and directory traversal
* add faked but consistent view thanks to ENOENT
* add /lib64 in the example
* fix spelling
* rename some types and definitions (e.g. SECCOMP_ADD_LANDLOCK_RULE)

Changes since v2:
* use BPF_PROG_ATTACH for cgroup handling
---
 samples/bpf/Makefile         |   4 ++
 samples/bpf/bpf_load.c       |  28 ++++++++++--
 samples/bpf/landlock1_kern.c | 100 +++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/landlock1_user.c | 100 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 229 insertions(+), 3 deletions(-)
 create mode 100644 samples/bpf/landlock1_kern.c
 create mode 100644 samples/bpf/landlock1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index f1010fe759fe..08d5d728e3e0 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -40,6 +40,7 @@ hostprogs-y += load_sock_ops
 hostprogs-y += xdp_redirect
 hostprogs-y += xdp_redirect_map
 hostprogs-y += syscall_tp
+hostprogs-y += landlock1
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -84,6 +85,7 @@ per_socket_stats_example-objs := $(LIBBPF) cookie_uid_helper_example.o
 xdp_redirect-objs := bpf_load.o $(LIBBPF) xdp_redirect_user.o
 xdp_redirect_map-objs := bpf_load.o $(LIBBPF) xdp_redirect_map_user.o
 syscall_tp-objs := bpf_load.o $(LIBBPF) syscall_tp_user.o
+landlock1-objs := bpf_load.o $(LIBBPF) landlock1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -128,6 +130,7 @@ always += tcp_clamp_kern.o
 always += xdp_redirect_kern.o
 always += xdp_redirect_map_kern.o
 always += syscall_tp_kern.o
+always += landlock1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -167,6 +170,7 @@ HOSTLOADLIBES_test_map_in_map += -lelf
 HOSTLOADLIBES_xdp_redirect += -lelf
 HOSTLOADLIBES_xdp_redirect_map += -lelf
 HOSTLOADLIBES_syscall_tp += -lelf
+HOSTLOADLIBES_landlock1 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 01a506f768da..30fcddda8b81 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -31,6 +31,8 @@
 
 static char license[128];
 static int kern_version;
+static union bpf_prog_subtype subtype = {};
+static bool has_subtype;
 static bool processed_sec[128];
 char bpf_log_buf[BPF_LOG_BUF_SIZE];
 int map_fd[MAX_MAPS];
@@ -66,6 +68,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
 	bool is_sockops = strncmp(event, "sockops", 7) == 0;
 	bool is_sk_skb = strncmp(event, "sk_skb", 6) == 0;
+	bool is_landlock = strncmp(event, "landlock", 8) == 0;
 	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
@@ -96,6 +99,13 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_SOCK_OPS;
 	} else if (is_sk_skb) {
 		prog_type = BPF_PROG_TYPE_SK_SKB;
+	} else if (is_landlock) {
+		prog_type = BPF_PROG_TYPE_LANDLOCK_RULE;
+		if (!has_subtype) {
+			printf("No subtype\n");
+			return -1;
+		}
+		st = &subtype;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -110,7 +120,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk)
+	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk ||
+	    is_landlock)
 		return 0;
 
 	if (is_socket || is_sockops || is_sk_skb) {
@@ -454,6 +465,7 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 	kern_version = 0;
 	memset(license, 0, sizeof(license));
 	memset(processed_sec, 0, sizeof(processed_sec));
+	has_subtype = false;
 
 	if (elf_version(EV_CURRENT) == EV_NONE)
 		return 1;
@@ -502,6 +514,16 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 			data_maps = data;
 			for (j = 0; j < MAX_MAPS; j++)
 				map_data[j].fd = -1;
+		} else if (strcmp(shname, "subtype") == 0) {
+			processed_sec[i] = true;
+			if (data->d_size != sizeof(union bpf_prog_subtype)) {
+				printf("invalid size of subtype section %zd\n",
+				       data->d_size);
+				return 1;
+			}
+			memcpy(&subtype, data->d_buf,
+			       sizeof(union bpf_prog_subtype));
+			has_subtype = true;
 		} else if (shdr.sh_type == SHT_SYMTAB) {
 			strtabidx = shdr.sh_link;
 			symbols = data;
@@ -562,7 +584,6 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 
 	/* load programs */
 	for (i = 1; i < ehdr.e_shnum; i++) {
-
 		if (processed_sec[i])
 			continue;
 
@@ -577,7 +598,8 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 		    memcmp(shname, "socket", 6) == 0 ||
 		    memcmp(shname, "cgroup/", 7) == 0 ||
 		    memcmp(shname, "sockops", 7) == 0 ||
-		    memcmp(shname, "sk_skb", 6) == 0) {
+		    memcmp(shname, "sk_skb", 6) == 0 ||
+		    memcmp(shname, "landlock", 8) == 0) {
 			ret = load_and_attach(shname, data->d_buf,
 					      data->d_size);
 			if (ret != 0)
diff --git a/samples/bpf/landlock1_kern.c b/samples/bpf/landlock1_kern.c
new file mode 100644
index 000000000000..4ed80d8eee4e
--- /dev/null
+++ b/samples/bpf/landlock1_kern.c
@@ -0,0 +1,100 @@
+/*
+ * Landlock rule - partial read-only filesystem
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+/*
+ * This file contains a function that will be compiled to eBPF bytecode thanks
+ * to LLVM/Clang.
+ *
+ * Each SEC() means that the following function or variable will be part of a
+ * custom ELF section. This sections are then processed by the userspace part
+ * (see landlock1_user.c) to extract eBPF bytecode and take into account
+ * variables describing the eBPF program subtype or its license.
+ */
+
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/stat.h> /* S_ISCHR() */
+#include "bpf_helpers.h"
+
+/*
+ * The function landlock_fs_prog1() is a simple Landlock rule enforced on a set
+ * of processes. This rule will be run for each file-system operations and will
+ * then forbid any write on a file-descriptor except if this file-descriptor
+ * point to a pipe. Hence, it will not be possible to create new files nor to
+ * modify a regular file.
+ *
+ * The argument ctx contains the context of the rule when it is run, which
+ * enable to check which action on which file is requested. This context can
+ * change for each run of the rule.
+ */
+SEC("landlock1")
+static int landlock_fs_prog1(struct landlock_context *ctx)
+{
+	char fmt_error_mode[] = "landlock1: error: get_mode:%lld\n";
+	char fmt_error_access[] = "landlock1: error: access denied\n";
+	long long ret;
+
+	/*
+	 * The argument ctx->arg2 contains bitflags of actions for which the
+	 * rule is run.  The flag LANDLOCK_ACTION_FS_WRITE means that a write
+	 * is requested by one of the userspace processes restricted by this
+	 * rule. The following test allows any actions which does not include a
+	 * write.
+	 */
+	if (!(ctx->arg2 & LANDLOCK_ACTION_FS_WRITE))
+		return 0;
+
+	/*
+	 * The argument ctx->arg1 is a file handle for which the process want
+	 * to access. The function bpf_handle_fs_get_mode() return the mode of
+	 * a file (e.g. S_IFBLK, S_IFDIR, S_IFREG...). If there is an error,
+	 * for example if the argument is not a file handle, then an
+	 * -errno value is returned. Otherwise the caller get the file mode as
+	 *  with stat(2).
+	 */
+	ret = bpf_handle_fs_get_mode((void *)ctx->arg1);
+	if (ret < 0) {
+
+		/*
+		 * The bpf_trace_printk() function enable to write in the
+		 * kernel eBPF debug log, accessible through
+		 * /sys/kernel/debug/tracing/trace_pipe . To be allowed to call
+		 * this function, a Landlock rule must have the
+		 * LANDLOCK_SUBTYPE_ABILITY_DEBUG ability, which is only
+		 * allowed for CAP_SYS_ADMIN.
+		 */
+		bpf_trace_printk(fmt_error_mode, sizeof(fmt_error_mode), ret);
+		return 1;
+	}
+
+	/*
+	 * This check allows the action on the file if it is a directory or a
+	 * pipe. Otherwise, a message is printed to the eBPF log.
+	 */
+	if (S_ISCHR(ret) || S_ISFIFO(ret))
+		return 0;
+	bpf_trace_printk(fmt_error_access, sizeof(fmt_error_access));
+	return 1;
+}
+
+/*
+ * This subtype enable to set the ABI, which ensure that the eBPF context and
+ * program behavior will be compatible with this Landlock rule.
+ */
+SEC("subtype")
+static const union bpf_prog_subtype _subtype = {
+	.landlock_rule = {
+		.abi = 1,
+		.event = LANDLOCK_SUBTYPE_EVENT_FS,
+		.ability = LANDLOCK_SUBTYPE_ABILITY_DEBUG,
+	}
+};
+
+SEC("license")
+static const char _license[] = "GPL";
diff --git a/samples/bpf/landlock1_user.c b/samples/bpf/landlock1_user.c
new file mode 100644
index 000000000000..27435dc4acb1
--- /dev/null
+++ b/samples/bpf/landlock1_user.c
@@ -0,0 +1,100 @@
+/*
+ * Landlock sandbox - partial read-only filesystem
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include "bpf_load.h"
+#include "libbpf.h"
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
+#ifndef seccomp
+static int seccomp(unsigned int op, unsigned int flags, void *args)
+{
+	errno = 0;
+	return syscall(__NR_seccomp, op, flags, args);
+}
+#endif
+
+
+struct landlock_rule {
+	enum landlock_subtype_event event;
+	struct bpf_insn *bpf;
+	size_t size;
+};
+
+static int apply_sandbox(int prog_fd)
+{
+	int ret = 0;
+
+	/* safer to set no_new_privs */
+	if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
+		perror("prctl(no_new_priv)");
+		return 1;
+	}
+	/* set up the test sandbox */
+	if (seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, &prog_fd)) {
+		perror("seccomp(set_hook)");
+		ret = 1;
+	}
+	close(prog_fd);
+
+	return ret;
+}
+
+int main(int argc, char * const argv[], char * const *envp)
+{
+	char filename[256];
+	char *cmd_path;
+	char * const *cmd_argv;
+
+	if (argc < 2) {
+		fprintf(stderr, "usage: %s <cmd> [args]...\n\n", argv[0]);
+		fprintf(stderr, "Launch a command in a read-only environment "
+				"(except for character devices).\n");
+		fprintf(stderr, "Display debug with: "
+				"cat /sys/kernel/debug/tracing/trace_pipe &\n");
+		return 1;
+	}
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+	if (!prog_fd[0]) {
+		if (errno) {
+			printf("load_bpf_file: %s\n", strerror(errno));
+		} else {
+			printf("load_bpf_file: Error\n");
+		}
+		return 1;
+	}
+
+	if (apply_sandbox(prog_fd[0]))
+		return 1;
+	cmd_path = argv[1];
+	cmd_argv = argv + 1;
+	fprintf(stderr, "Launching a new sandboxed process.\n");
+	execve(cmd_path, cmd_argv, envp);
+	perror("execve");
+	return 1;
+}
-- 
2.14.1
