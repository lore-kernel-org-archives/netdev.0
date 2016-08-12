From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v5 3/3] samples/bpf: Add
 test_current_task_under_cgroup test
Date: Fri, 12 Aug 2016 08:57:04 -0700
Message-ID: <20160812155703.GA12893@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net, tj@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37011 "EHLO
	mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbcHLP5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:57:07 -0400
Received: by mail-it0-f54.google.com with SMTP id f6so17512138ith.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:57:06 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This test has a BPF program which writes the last known pid to call the
sync syscall within a given cgroup to a map.

The user mode program creates its own mount namespace, and mounts the
cgroupsv2  hierarchy in there, as on all current test systems
(Ubuntu 16.04, Debian), the cgroupsv2 vfs is unmounted by default.
Once it does this, it proceeds to test.

The test checks for positive and negative condition. It ensures that
when it's part of a given cgroup, its pid is captured in the map,
and that when it leaves the cgroup, this doesn't happen.

It populate a cgroups arraymap prior to execution in userspace. This means
that the program must be run in the same cgroups namespace as the programs
that are being traced.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tejun Heo <tj@kernel.org>
---
 samples/bpf/Makefile                              |   5 +
 samples/bpf/bpf_helpers.h                         |   2 +
 samples/bpf/test_current_task_under_cgroup_kern.c |  43 +++++++
 samples/bpf/test_current_task_under_cgroup_user.c | 145 ++++++++++++++++++++++
 4 files changed, 195 insertions(+)
 create mode 100644 samples/bpf/test_current_task_under_cgroup_kern.c
 create mode 100644 samples/bpf/test_current_task_under_cgroup_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 90ebf7d..eb582c6 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -24,6 +24,7 @@ hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += xdp1
 hostprogs-y += xdp2
+hostprogs-y += test_current_task_under_cgroup
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -49,6 +50,8 @@ test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
+test_current_task_under_cgroup-objs := bpf_load.o libbpf.o \
+				       test_current_task_under_cgroup_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -74,6 +77,7 @@ always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
+always += test_current_task_under_cgroup_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -97,6 +101,7 @@ HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
+HOSTLOADLIBES_test_current_task_under_cgroup += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index cbc52df..5e4c41e 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -45,6 +45,8 @@ static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
 static int (*bpf_probe_write_user)(void *dst, void *src, int size) =
 	(void *) BPF_FUNC_probe_write_user;
+static int (*bpf_current_task_under_cgroup)(void *map, int index) =
+	(void *) BPF_FUNC_current_task_under_cgroup;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/test_current_task_under_cgroup_kern.c b/samples/bpf/test_current_task_under_cgroup_kern.c
new file mode 100644
index 0000000..86b28d7
--- /dev/null
+++ b/samples/bpf/test_current_task_under_cgroup_kern.c
@@ -0,0 +1,43 @@
+/* Copyright (c) 2016 Sargun Dhillon <sargun@sargun.me>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+
+#include <linux/ptrace.h>
+#include <uapi/linux/bpf.h>
+#include <linux/version.h>
+#include "bpf_helpers.h"
+#include <uapi/linux/utsname.h>
+
+struct bpf_map_def SEC("maps") cgroup_map = {
+	.type			= BPF_MAP_TYPE_CGROUP_ARRAY,
+	.key_size		= sizeof(u32),
+	.value_size		= sizeof(u32),
+	.max_entries	= 1,
+};
+
+struct bpf_map_def SEC("maps") perf_map = {
+	.type			= BPF_MAP_TYPE_ARRAY,
+	.key_size		= sizeof(u32),
+	.value_size		= sizeof(u64),
+	.max_entries	= 1,
+};
+
+/* Writes the last PID that called sync to a map at index 0 */
+SEC("kprobe/sys_sync")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	u64 pid = bpf_get_current_pid_tgid();
+	int idx = 0;
+
+	if (!bpf_current_task_under_cgroup(&cgroup_map, 0))
+		return 0;
+
+	bpf_map_update_elem(&perf_map, &idx, &pid, BPF_ANY);
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/test_current_task_under_cgroup_user.c b/samples/bpf/test_current_task_under_cgroup_user.c
new file mode 100644
index 0000000..30b0bce
--- /dev/null
+++ b/samples/bpf/test_current_task_under_cgroup_user.c
@@ -0,0 +1,145 @@
+/* Copyright (c) 2016 Sargun Dhillon <sargun@sargun.me>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <string.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <linux/bpf.h>
+#include <sched.h>
+#include <sys/mount.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <linux/limits.h>
+
+#define CGROUP_MOUNT_PATH	"/mnt"
+#define CGROUP_PATH		"/mnt/my-cgroup"
+
+#define clean_errno() (errno == 0 ? "None" : strerror(errno))
+#define log_err(MSG, ...) fprintf(stderr, "(%s:%d: errno: %s) " MSG "\n", \
+	__FILE__, __LINE__, clean_errno(), ##__VA_ARGS__)
+
+static int join_cgroup(char *path)
+{
+	int fd, rc = 0;
+	pid_t pid = getpid();
+	char cgroup_path[PATH_MAX + 1];
+
+	snprintf(cgroup_path, sizeof(cgroup_path), "%s/cgroup.procs", path);
+
+	fd = open(cgroup_path, O_WRONLY);
+	if (fd < 0) {
+		log_err("Opening Cgroup");
+		return 1;
+	}
+
+	if (dprintf(fd, "%d\n", pid) < 0) {
+		log_err("Joining Cgroup");
+		rc = 1;
+	}
+	close(fd);
+	return rc;
+}
+
+int main(int argc, char **argv)
+{
+	char filename[256];
+	int cg2, idx = 0;
+	pid_t remote_pid, local_pid = getpid();
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	/*
+	 * This is to avoid interfering with existing cgroups. Unfortunately,
+	 * most people don't have cgroupv2 enabled at this point in time.
+	 * It's easier to create our own mount namespace and manage it
+	 * ourselves.
+	 */
+	if (unshare(CLONE_NEWNS)) {
+		log_err("unshare");
+		return 1;
+	}
+
+	if (mount("none", "/", NULL, MS_REC | MS_PRIVATE, NULL)) {
+		log_err("mount fakeroot");
+		return 1;
+	}
+
+	if (mount("none", CGROUP_MOUNT_PATH, "cgroup2", 0, NULL)) {
+		log_err("mount cgroup2");
+		return 1;
+	}
+
+	if (mkdir(CGROUP_PATH, 0777) && errno != EEXIST) {
+		log_err("mkdir cgroup");
+		return 1;
+	}
+
+	cg2 = open(CGROUP_PATH, O_RDONLY);
+	if (cg2 < 0) {
+		log_err("opening target cgroup");
+		goto cleanup_cgroup_err;
+	}
+
+	if (bpf_update_elem(map_fd[0], &idx, &cg2, BPF_ANY)) {
+		log_err("Adding target cgroup to map");
+		goto cleanup_cgroup_err;
+	}
+	if (join_cgroup("/mnt/my-cgroup")) {
+		log_err("Leaving target cgroup");
+		goto cleanup_cgroup_err;
+	}
+
+	/*
+	 * The installed helper program catched the sync call, and should
+	 * write it to the map.
+	 */
+
+	sync();
+	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
+
+	if (local_pid != remote_pid) {
+		fprintf(stderr,
+			"BPF Helper didn't write correct PID to map, but: %d\n",
+			remote_pid);
+		goto leave_cgroup_err;
+	}
+
+	/* Verify the negative scenario; leave the cgroup */
+	if (join_cgroup(CGROUP_MOUNT_PATH))
+		goto leave_cgroup_err;
+
+	remote_pid = 0;
+	bpf_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
+
+	sync();
+	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
+
+	if (local_pid == remote_pid) {
+		fprintf(stderr, "BPF cgroup negative test did not work\n");
+		goto cleanup_cgroup_err;
+	}
+
+	rmdir(CGROUP_PATH);
+	return 0;
+
+	/* Error condition, cleanup */
+leave_cgroup_err:
+	join_cgroup(CGROUP_MOUNT_PATH);
+cleanup_cgroup_err:
+	rmdir(CGROUP_PATH);
+	return 1;
+}
-- 
2.7.4
