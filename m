From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next v2 v2 2/2] samples/bpf: Add opensnoop example that uses
 current_task_in_cgroup helper
Date: Tue, 9 Aug 2016 17:00:58 -0700
Message-ID: <20160810000056.GA28461@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34471 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcHJABA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 20:01:00 -0400
Received: by mail-io0-f179.google.com with SMTP id q83so26956988iod.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 17:01:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This example adds the trace_opensnoop BPF sample. This example program
prints all activities of files being opened for all programs in the
provided cgroupsv2 cgroup and it's descendants in the cgroupv2 hierarchy.

It populate a cgroups arraymap prior to execution in userspace. This means
that the program must be run in the same cgroups namespace as the programs
that are being traced.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/Makefile               |  4 +++
 samples/bpf/bpf_helpers.h          |  2 ++
 samples/bpf/trace_opensnoop_kern.c | 35 +++++++++++++++++++
 samples/bpf/trace_opensnoop_user.c | 69 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 110 insertions(+)
 create mode 100644 samples/bpf/trace_opensnoop_kern.c
 create mode 100644 samples/bpf/trace_opensnoop_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 90ebf7d..d9c37a4 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -24,6 +24,7 @@ hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += xdp1
 hostprogs-y += xdp2
+hostprogs-y += trace_opensnoop
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -49,6 +50,7 @@ test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
+trace_opensnoop-objs := bpf_load.o libbpf.o trace_opensnoop_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -74,6 +76,7 @@ always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
+always += trace_opensnoop_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -97,6 +100,7 @@ HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
+HOSTLOADLIBES_trace_opensnoop += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 217c8d5..d409cbb 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -43,6 +43,8 @@ static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
 static int (*bpf_probe_write_user)(void *dst, void *src, int size) =
 	(void *) BPF_FUNC_probe_write_user;
+static int (*bpf_current_task_in_cgroup)(void *map, int index) =
+	(void *) BPF_FUNC_current_task_in_cgroup;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/trace_opensnoop_kern.c b/samples/bpf/trace_opensnoop_kern.c
new file mode 100644
index 0000000..dade471
--- /dev/null
+++ b/samples/bpf/trace_opensnoop_kern.c
@@ -0,0 +1,35 @@
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
+
+struct bpf_map_def SEC("maps") cgroup_map = {
+	.type = BPF_MAP_TYPE_CGROUP_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u32),
+	.max_entries = 1,
+};
+
+SEC("kprobe/sys_open")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	const char *filename = (char *)PT_REGS_PARM1(ctx);
+	char fmt[] = "Opening file: %s\n";
+
+	if (!bpf_current_task_in_cgroup(&cgroup_map, 0))
+		return 0;
+
+	bpf_trace_printk(fmt, sizeof(fmt), filename);
+
+	return 1;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/trace_opensnoop_user.c b/samples/bpf/trace_opensnoop_user.c
new file mode 100644
index 0000000..403664e
--- /dev/null
+++ b/samples/bpf/trace_opensnoop_user.c
@@ -0,0 +1,69 @@
+#include <stdio.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <sys/socket.h>
+#include <string.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <linux/bpf.h>
+
+static void usage(char **argv)
+{
+	printf("Usage:	%s [...]\n", argv[0]);
+	printf("Prints the file opening activity of all processes under a given cgroupv2 hierarchy.\n");
+	printf("	-v <value>	Full path of the cgroup2\n");
+	printf("	-h		Display this help\n");
+}
+
+int main(int argc, char **argv)
+{
+	char filename[256];
+	const char *cg2 = NULL;
+	int ret, opt, cg2_fd;
+	int array_index = 0;
+
+	while ((opt = getopt(argc, argv, "v:")) != -1) {
+		switch (opt) {
+		case 'v':
+			cg2 = optarg;
+			break;
+		default:
+			usage(argv);
+			return 1;
+		}
+	}
+
+	if (!cg2) {
+		usage(argv);
+		return 1;
+	}
+
+	cg2_fd = open(cg2, O_RDONLY);
+	if (cg2_fd < 0) {
+		fprintf(stderr, "open(%s,...): %s(%d)\n",
+			cg2, strerror(errno), errno);
+		return 1;
+	}
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	ret = bpf_update_elem(map_fd[0],
+			      &array_index,
+			      &cg2_fd, BPF_ANY);
+	if (ret) {
+		perror("bpf_update_elem");
+		return 1;
+	}
+
+	read_trace_pipe();
+	return 0;
+}
-- 
2.7.4
