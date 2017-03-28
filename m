From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v6 08/11] bpf: Add a Landlock sandbox example
Date: Wed, 29 Mar 2017 01:46:47 +0200
Message-ID: <20170328234650.19695-9-mic@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
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
Return-path: <kernel-hardening-return-7140-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170328234650.19695-1-mic@digikod.net>
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

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
---
 samples/bpf/Makefile         |   4 ++
 samples/bpf/bpf_load.c       |  31 +++++++++++--
 samples/bpf/landlock1_kern.c |  46 +++++++++++++++++++
 samples/bpf/landlock1_user.c | 102 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 179 insertions(+), 4 deletions(-)
 create mode 100644 samples/bpf/landlock1_kern.c
 create mode 100644 samples/bpf/landlock1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index d42b495b0992..4743674a3fa3 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -36,6 +36,7 @@ hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 hostprogs-y += test_map_in_map
 hostprogs-y += per_socket_stats_example
+hostprogs-y += landlock1
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -76,6 +77,7 @@ lwt_len_hist-objs := bpf_load.o $(LIBBPF) lwt_len_hist_user.o
 xdp_tx_iptunnel-objs := bpf_load.o $(LIBBPF) xdp_tx_iptunnel_user.o
 test_map_in_map-objs := bpf_load.o $(LIBBPF) test_map_in_map_user.o
 per_socket_stats_example-objs := $(LIBBPF) cookie_uid_helper_example.o
+landlock1-objs := bpf_load.o $(LIBBPF) landlock1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -111,6 +113,7 @@ always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
 always += test_map_in_map_kern.o
 always += cookie_uid_helper_example.o
+always += landlock1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -146,6 +149,7 @@ HOSTLOADLIBES_tc_l2_redirect += -l elf
 HOSTLOADLIBES_lwt_len_hist += -l elf
 HOSTLOADLIBES_xdp_tx_iptunnel += -lelf
 HOSTLOADLIBES_test_map_in_map += -lelf
+HOSTLOADLIBES_landlock1 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 4a3460d7c01f..3713e5e2e998 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -29,6 +29,8 @@
 
 static char license[128];
 static int kern_version;
+static union bpf_prog_subtype subtype = {};
+static bool has_subtype;
 static bool processed_sec[128];
 char bpf_log_buf[BPF_LOG_BUF_SIZE];
 int map_fd[MAX_MAPS];
@@ -68,6 +70,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
 	bool is_cgroup_skb = strncmp(event, "cgroup/skb", 10) == 0;
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
+	bool is_landlock = strncmp(event, "landlock", 8) == 0;
 	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
@@ -94,6 +97,13 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_CGROUP_SKB;
 	} else if (is_cgroup_sk) {
 		prog_type = BPF_PROG_TYPE_CGROUP_SOCK;
+	} else if (is_landlock) {
+		prog_type = BPF_PROG_TYPE_LANDLOCK;
+		if (!has_subtype) {
+			printf("No subtype\n");
+			return -1;
+		}
+		st = &subtype;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -108,7 +118,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk)
+	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk ||
+	    is_landlock)
 		return 0;
 
 	if (is_socket) {
@@ -294,6 +305,7 @@ int load_bpf_file(char *path)
 	kern_version = 0;
 	memset(license, 0, sizeof(license));
 	memset(processed_sec, 0, sizeof(processed_sec));
+	has_subtype = false;
 
 	if (elf_version(EV_CURRENT) == EV_NONE)
 		return 1;
@@ -339,6 +351,16 @@ int load_bpf_file(char *path)
 			processed_sec[i] = true;
 			if (load_maps(data->d_buf, data->d_size))
 				return 1;
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
 			symbols = data;
 		}
@@ -376,14 +398,14 @@ int load_bpf_file(char *path)
 			    memcmp(shname_prog, "xdp", 3) == 0 ||
 			    memcmp(shname_prog, "perf_event", 10) == 0 ||
 			    memcmp(shname_prog, "socket", 6) == 0 ||
-			    memcmp(shname_prog, "cgroup/", 7) == 0)
+			    memcmp(shname_prog, "cgroup/", 7) == 0 ||
+			    memcmp(shname_prog, "landlock", 8) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
 	}
 
 	/* load programs that don't use maps */
 	for (i = 1; i < ehdr.e_shnum; i++) {
-
 		if (processed_sec[i])
 			continue;
 
@@ -396,7 +418,8 @@ int load_bpf_file(char *path)
 		    memcmp(shname, "xdp", 3) == 0 ||
 		    memcmp(shname, "perf_event", 10) == 0 ||
 		    memcmp(shname, "socket", 6) == 0 ||
-		    memcmp(shname, "cgroup/", 7) == 0)
+		    memcmp(shname, "cgroup/", 7) == 0 ||
+		    memcmp(shname, "landlock", 8) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
 
diff --git a/samples/bpf/landlock1_kern.c b/samples/bpf/landlock1_kern.c
new file mode 100644
index 000000000000..b8a9b0ca84c9
--- /dev/null
+++ b/samples/bpf/landlock1_kern.c
@@ -0,0 +1,46 @@
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
+#define KBUILD_MODNAME "foo"
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/stat.h> /* S_ISCHR() */
+#include "bpf_helpers.h"
+
+SEC("landlock1")
+static int landlock_fs_prog1(struct landlock_context *ctx)
+{
+	char fmt_error[] = "landlock1: error: get_mode:%lld\n";
+	char fmt_name[] = "landlock1: syscall:%d\n";
+	long long ret;
+
+	if (!(ctx->arg2 & LANDLOCK_ACTION_FS_WRITE))
+		return 0;
+	ret = bpf_handle_fs_get_mode((void *)ctx->arg1);
+	if (ret < 0) {
+		bpf_trace_printk(fmt_error, sizeof(fmt_error), ret);
+		return 1;
+	}
+	if (S_ISCHR(ret))
+		return 0;
+	bpf_trace_printk(fmt_name, sizeof(fmt_name), ctx->syscall_nr);
+	return 1;
+}
+
+SEC("subtype")
+static union bpf_prog_subtype _subtype = {
+	.landlock_rule = {
+		.version = 1,
+		.event = LANDLOCK_SUBTYPE_EVENT_FS,
+		.ability = LANDLOCK_SUBTYPE_ABILITY_DEBUG,
+	}
+};
+
+SEC("license")
+static const char _license[] = "GPL";
diff --git a/samples/bpf/landlock1_user.c b/samples/bpf/landlock1_user.c
new file mode 100644
index 000000000000..6f79eb0ee6db
--- /dev/null
+++ b/samples/bpf/landlock1_user.c
@@ -0,0 +1,102 @@
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
+#define ARRAY_SIZE(a)	(sizeof(a) / sizeof(a[0]))
+#define MAX_ERRNO	4095
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
+	/* set up the test sandbox */
+	if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
+		perror("prctl(no_new_priv)");
+		return 1;
+	}
+	if (seccomp(SECCOMP_APPEND_LANDLOCK_RULE, 0, &prog_fd)) {
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
2.11.0
