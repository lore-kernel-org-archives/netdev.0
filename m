From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v3 2/2] bpf: add a test case for syscalls/sys_{enter|exit}_* tracepoints
Date: Thu, 3 Aug 2017 09:29:51 -0700
Message-ID: <20170803162951.1564963-3-yhs@fb.com>
References: <20170803162951.1564963-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47234 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751131AbdHCQ3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:29:54 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v73GRbYq022987
        for <netdev@vger.kernel.org>; Thu, 3 Aug 2017 09:29:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2c44vt8v6b-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 09:29:53 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 fa04d610786811e78807858c2141f014-a8fc4150 for <netdev@vger.kernel.org>;        Thu,
 03 Aug 2017 09:29:52 -0700
In-Reply-To: <20170803162951.1564963-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 samples/bpf/Makefile          |  4 +++
 samples/bpf/syscall_tp_kern.c | 62 +++++++++++++++++++++++++++++++++++++
 samples/bpf/syscall_tp_user.c | 71 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 137 insertions(+)
 create mode 100644 samples/bpf/syscall_tp_kern.c
 create mode 100644 samples/bpf/syscall_tp_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 770d46c..f1010fe 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -39,6 +39,7 @@ hostprogs-y += per_socket_stats_example
 hostprogs-y += load_sock_ops
 hostprogs-y += xdp_redirect
 hostprogs-y += xdp_redirect_map
+hostprogs-y += syscall_tp
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -82,6 +83,7 @@ test_map_in_map-objs := bpf_load.o $(LIBBPF) test_map_in_map_user.o
 per_socket_stats_example-objs := $(LIBBPF) cookie_uid_helper_example.o
 xdp_redirect-objs := bpf_load.o $(LIBBPF) xdp_redirect_user.o
 xdp_redirect_map-objs := bpf_load.o $(LIBBPF) xdp_redirect_map_user.o
+syscall_tp-objs := bpf_load.o $(LIBBPF) syscall_tp_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -125,6 +127,7 @@ always += tcp_iw_kern.o
 always += tcp_clamp_kern.o
 always += xdp_redirect_kern.o
 always += xdp_redirect_map_kern.o
+always += syscall_tp_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -163,6 +166,7 @@ HOSTLOADLIBES_xdp_tx_iptunnel += -lelf
 HOSTLOADLIBES_test_map_in_map += -lelf
 HOSTLOADLIBES_xdp_redirect += -lelf
 HOSTLOADLIBES_xdp_redirect_map += -lelf
+HOSTLOADLIBES_syscall_tp += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/syscall_tp_kern.c b/samples/bpf/syscall_tp_kern.c
new file mode 100644
index 0000000..9149c52
--- /dev/null
+++ b/samples/bpf/syscall_tp_kern.c
@@ -0,0 +1,62 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct syscalls_enter_open_args {
+	unsigned long long unused;
+	long syscall_nr;
+	long filename_ptr;
+	long flags;
+	long mode;
+};
+
+struct syscalls_exit_open_args {
+	unsigned long long unused;
+	long syscall_nr;
+	long ret;
+};
+
+struct bpf_map_def SEC("maps") enter_open_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u32),
+	.max_entries = 1,
+};
+
+struct bpf_map_def SEC("maps") exit_open_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(u32),
+	.max_entries = 1,
+};
+
+static __always_inline void count(void *map)
+{
+	u32 key = 0;
+	u32 *value, init_val = 1;
+
+	value = bpf_map_lookup_elem(map, &key);
+	if (value)
+		*value += 1;
+	else
+		bpf_map_update_elem(map, &key, &init_val, BPF_NOEXIST);
+}
+
+SEC("tracepoint/syscalls/sys_enter_open")
+int trace_enter_open(struct syscalls_enter_open_args *ctx)
+{
+	count((void *)&enter_open_map);
+	return 0;
+}
+
+SEC("tracepoint/syscalls/sys_exit_open")
+int trace_enter_exit(struct syscalls_exit_open_args *ctx)
+{
+	count((void *)&exit_open_map);
+	return 0;
+}
diff --git a/samples/bpf/syscall_tp_user.c b/samples/bpf/syscall_tp_user.c
new file mode 100644
index 0000000..a3cb91e
--- /dev/null
+++ b/samples/bpf/syscall_tp_user.c
@@ -0,0 +1,71 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <linux/bpf.h>
+#include <string.h>
+#include <linux/perf_event.h>
+#include <errno.h>
+#include <assert.h>
+#include <stdbool.h>
+#include <sys/resource.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+/* This program verifies bpf attachment to tracepoint sys_enter_* and sys_exit_*.
+ * This requires kernel CONFIG_FTRACE_SYSCALLS to be set.
+ */
+
+static void verify_map(int map_id)
+{
+	__u32 key = 0;
+	__u32 val;
+
+	if (bpf_map_lookup_elem(map_id, &key, &val) != 0) {
+		fprintf(stderr, "map_lookup failed: %s\n", strerror(errno));
+		return;
+	}
+	if (val == 0)
+		fprintf(stderr, "failed: map #%d returns value 0\n", map_id);
+}
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	char filename[256];
+	int fd;
+
+	setrlimit(RLIMIT_MEMLOCK, &r);
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		fprintf(stderr, "%s", bpf_log_buf);
+		return 1;
+	}
+
+	/* current load_bpf_file has perf_event_open default pid = -1
+	 * and cpu = 0, which permits attached bpf execution on
+	 * all cpus for all pid's. bpf program execution ignores
+	 * cpu affinity.
+	 */
+	/* trigger some "open" operations */
+	fd = open(filename, O_RDONLY);
+	if (fd < 0) {
+		fprintf(stderr, "open failed: %s\n", strerror(errno));
+		return 1;
+	}
+	close(fd);
+
+	/* verify the map */
+	verify_map(map_fd[0]);
+	verify_map(map_fd[1]);
+
+	return 0;
+}
-- 
2.9.4
