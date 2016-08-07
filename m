From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next 2/2] samples/bpf: Add example using current_in_cgroup
Date: Sat, 6 Aug 2016 21:07:13 -0700
Message-ID: <20160807040711.GA9285@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33072 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcHGEHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 00:07:15 -0400
Received: by mail-io0-f178.google.com with SMTP id 38so332324945iol.0
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 21:07:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a simple trace example that shows programs connecting,
but only if they're in a chosen cgroup.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/Makefile                       |  4 ++
 samples/bpf/bpf_helpers.h                  |  2 +
 samples/bpf/trace_current_in_cgroup_kern.c | 44 ++++++++++++++++++++
 samples/bpf/trace_current_in_cgroup_user.c | 66 ++++++++++++++++++++++++++++++
 4 files changed, 116 insertions(+)
 create mode 100644 samples/bpf/trace_current_in_cgroup_kern.c
 create mode 100644 samples/bpf/trace_current_in_cgroup_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 90ebf7d..61b0534 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -24,6 +24,7 @@ hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += xdp1
 hostprogs-y += xdp2
+hostprogs-y += trace_current_in_cgroup
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -49,6 +50,7 @@ test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
+trace_current_in_cgroup-objs := bpf_load.o libbpf.o trace_current_in_cgroup_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -74,6 +76,7 @@ always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
+always += trace_current_in_cgroup_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -97,6 +100,7 @@ HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
+HOSTLOADLIBES_trace_current_in_cgroup += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 217c8d5..080403c 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -43,6 +43,8 @@ static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
 static int (*bpf_probe_write_user)(void *dst, void *src, int size) =
 	(void *) BPF_FUNC_probe_write_user;
+static int (*bpf_current_in_cgroup)(void *map, int index) =
+	(void *) BPF_FUNC_current_in_cgroup;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/trace_current_in_cgroup_kern.c b/samples/bpf/trace_current_in_cgroup_kern.c
new file mode 100644
index 0000000..7aafb86
--- /dev/null
+++ b/samples/bpf/trace_current_in_cgroup_kern.c
@@ -0,0 +1,44 @@
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
+#include <uapi/linux/in.h>
+
+struct bpf_map_def SEC("maps") test_current_in_cgroup_map = {
+	.type = BPF_MAP_TYPE_CGROUP_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u32),
+	.max_entries = 1,
+};
+
+SEC("kprobe/sys_connect")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	struct sockaddr_in addr = {};
+	void *sockaddr_arg = (void *)PT_REGS_PARM2(ctx);
+	int sockaddr_len = (int)PT_REGS_PARM3(ctx);
+	char fmt[] = "Connection on port %d\n";
+
+	if (!bpf_current_in_cgroup(&test_current_in_cgroup_map, 0))
+		return 0;
+	if (sockaddr_len > sizeof(addr))
+		return 0;
+	if (bpf_probe_read(&addr, sizeof(addr), sockaddr_arg) != 0)
+		return 0;
+	if (addr.sin_family != AF_INET)
+		return 0;
+
+	bpf_trace_printk(fmt, sizeof(fmt), be16_to_cpu(addr.sin_port));
+
+	return 1;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/trace_current_in_cgroup_user.c b/samples/bpf/trace_current_in_cgroup_user.c
new file mode 100644
index 0000000..be717bb
--- /dev/null
+++ b/samples/bpf/trace_current_in_cgroup_user.c
@@ -0,0 +1,66 @@
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
+	printf("	-f <value>	Full path of the cgroup2\n");
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
+	while ((opt = getopt(argc, argv, "f:")) != -1) {
+		switch (opt) {
+		case 'f':
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
+	ret = bpf_update_elem(map_fd[0], &array_index, &cg2_fd, BPF_ANY);
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
