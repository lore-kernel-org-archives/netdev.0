From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: [PATCH v5 07/10] bpf: Add a Landlock sandbox example
Date: Wed, 22 Feb 2017 02:26:29 +0100
Message-ID: <20170222012632.4196-8-mic@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj@k
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170222012632.4196-1-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Signed-off-by: Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
---
 samples/bpf/.gitignore       |  32 ++++++++++++++
 samples/bpf/Makefile         |   4 ++
 samples/bpf/bpf_load.c       |  26 +++++++++--
 samples/bpf/landlock1_kern.c |  46 +++++++++++++++++++
 samples/bpf/landlock1_user.c | 102 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 206 insertions(+), 4 deletions(-)
 create mode 100644 samples/bpf/.gitignore
 create mode 100644 samples/bpf/landlock1_kern.c
 create mode 100644 samples/bpf/landlock1_user.c

diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
new file mode 100644
index 000000000000..a7562a5ef4c2
--- /dev/null
+++ b/samples/bpf/.gitignore
@@ -0,0 +1,32 @@
+fds_example
+lathist
+lwt_len_hist
+map_perf_test
+offwaketime
+sampleip
+sockex1
+sockex2
+sockex3
+sock_example
+spintest
+tc_l2_redirect
+test_cgrp2_array_pin
+test_cgrp2_attach
+test_cgrp2_attach2
+test_cgrp2_sock
+test_cgrp2_sock2
+test_current_task_under_cgroup
+test_lru_dist
+test_overhead
+test_probe_write_user
+trace_event
+trace_output
+tracex1
+tracex2
+tracex3
+tracex4
+tracex5
+tracex6
+xdp1
+xdp2
+xdp_tx_iptunnel
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 09e9d535bd74..3d3afd709635 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -34,6 +34,7 @@ hostprogs-y += sampleip
 hostprogs-y += tc_l2_redirect
 hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
+hostprogs-y += landlock1
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -72,6 +73,7 @@ sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
 tc_l2_redirect-objs := bpf_load.o $(LIBBPF) tc_l2_redirect_user.o
 lwt_len_hist-objs := bpf_load.o $(LIBBPF) lwt_len_hist_user.o
 xdp_tx_iptunnel-objs := bpf_load.o $(LIBBPF) xdp_tx_iptunnel_user.o
+landlock1-objs := bpf_load.o $(LIBBPF) landlock1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -105,6 +107,7 @@ always += trace_event_kern.o
 always += sampleip_kern.o
 always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
+always += landlock1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -139,6 +142,7 @@ HOSTLOADLIBES_sampleip += -lelf
 HOSTLOADLIBES_tc_l2_redirect += -l elf
 HOSTLOADLIBES_lwt_len_hist += -l elf
 HOSTLOADLIBES_xdp_tx_iptunnel += -lelf
+HOSTLOADLIBES_landlock1 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index d23dc13ab0f2..78df39cf8b2f 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -68,6 +68,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
 	bool is_cgroup_skb = strncmp(event, "cgroup/skb", 10) == 0;
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
+	bool is_landlock = strncmp(event, "landlock", 8) == 0;
 	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
@@ -93,6 +94,12 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_CGROUP_SKB;
 	} else if (is_cgroup_sk) {
 		prog_type = BPF_PROG_TYPE_CGROUP_SOCK;
+	} else if (is_landlock) {
+		prog_type = BPF_PROG_TYPE_LANDLOCK;
+		if (!subtype.landlock_rule.event) {
+			printf("No subtype\n");
+			return -1;
+		}
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -107,7 +114,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk)
+	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk || is_landlock)
 		return 0;
 
 	if (is_socket) {
@@ -278,6 +285,8 @@ int load_bpf_file(char *path)
 	Elf_Data *data, *data_prog, *symbols = NULL;
 	char *shname, *shname_prog;
 
+	subtype.landlock_rule.event = 0;
+
 	if (elf_version(EV_CURRENT) == EV_NONE)
 		return 1;
 
@@ -322,6 +331,14 @@ int load_bpf_file(char *path)
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
+			memcpy(&subtype, data->d_buf, sizeof(union bpf_prog_subtype));
 		} else if (shdr.sh_type == SHT_SYMTAB) {
 			symbols = data;
 		}
@@ -357,14 +374,14 @@ int load_bpf_file(char *path)
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
 
@@ -377,7 +394,8 @@ int load_bpf_file(char *path)
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
index 000000000000..ff23061e6324
--- /dev/null
+++ b/samples/bpf/landlock1_kern.c
@@ -0,0 +1,46 @@
+/*
+ * Landlock LSM - Sample 1 (BPF program)
+ *
+ * Copyright © 2017 Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
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
+static char _license[] = "GPL";
diff --git a/samples/bpf/landlock1_user.c b/samples/bpf/landlock1_user.c
new file mode 100644
index 000000000000..5feb660caed4
--- /dev/null
+++ b/samples/bpf/landlock1_user.c
@@ -0,0 +1,102 @@
+/*
+ * Landlock LSM - Sample 1 (userland)
+ *
+ * Copyright © 2017 Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
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
+	if (seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, &prog_fd)) {
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
