From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v7 tip 8/8] samples: bpf: kmem_alloc/free tracker
Date: Mon, 16 Mar 2015 14:49:44 -0700
Message-ID: <1426542584-9406-9-git-send-email-ast@plumgrid.com>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33272 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934305AbbCPVuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 17:50:03 -0400
Received: by pagr17 with SMTP id r17so76634196pag.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 14:50:02 -0700 (PDT)
In-Reply-To: <1426542584-9406-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One bpf program attaches to kmem_cache_alloc_node() and remembers all allocated
objects in the map.
Another program attaches to kmem_cache_free() and deletes corresponding
object from the map.

User space walks the map every second and prints any objects which are
older than 1 second.

Usage:
$ sudo tracex4

Then start few long living processes. The tracex4 will print:

obj 0xffff880465928000 is 13sec old was allocated at ip ffffffff8105dc32
obj 0xffff88043181c280 is 13sec old was allocated at ip ffffffff8105dc32
obj 0xffff880465848000 is  8sec old was allocated at ip ffffffff8105dc32
obj 0xffff8804338bc280 is 15sec old was allocated at ip ffffffff8105dc32

$ addr2line -fispe vmlinux ffffffff8105dc32
do_fork at fork.c:1665

As soon as processes exit the memory is reclaimed and tracex4 prints nothing.

Similar experiment can be done with __kmalloc/kfree pair.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |    4 +++
 samples/bpf/tracex4_kern.c |   54 ++++++++++++++++++++++++++++++++++
 samples/bpf/tracex4_user.c |   69 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 127 insertions(+)
 create mode 100644 samples/bpf/tracex4_kern.c
 create mode 100644 samples/bpf/tracex4_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index dcd850546d52..fe98fb226e6e 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -9,6 +9,7 @@ hostprogs-y += sockex2
 hostprogs-y += tracex1
 hostprogs-y += tracex2
 hostprogs-y += tracex3
+hostprogs-y += tracex4
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -18,6 +19,7 @@ sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
 tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
 tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
+tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -26,6 +28,7 @@ always += sockex2_kern.o
 always += tracex1_kern.o
 always += tracex2_kern.o
 always += tracex3_kern.o
+always += tracex4_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -35,6 +38,7 @@ HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_tracex1 += -lelf
 HOSTLOADLIBES_tracex2 += -lelf
 HOSTLOADLIBES_tracex3 += -lelf
+HOSTLOADLIBES_tracex4 += -lelf -lrt
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/tracex4_kern.c b/samples/bpf/tracex4_kern.c
new file mode 100644
index 000000000000..5754e21caf3b
--- /dev/null
+++ b/samples/bpf/tracex4_kern.c
@@ -0,0 +1,54 @@
+/* Copyright (c) 2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/ptrace.h>
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct pair {
+	u64 val;
+	u64 ip;
+};
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(struct pair),
+	.max_entries = 1000000,
+};
+
+/* kprobe is NOT a stable ABI
+ * This bpf+kprobe example can stop working any time.
+ */
+SEC("kprobe/kmem_cache_free")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	long ptr = ctx->si;
+
+	bpf_map_delete_elem(&my_map, &ptr);
+	return 0;
+}
+
+SEC("kretprobe/kmem_cache_alloc_node")
+int bpf_prog2(struct pt_regs *ctx)
+{
+	long ptr = ctx->ax;
+	long ip = 0;
+
+	/* get ip address of kmem_cache_alloc_node() caller */
+	bpf_probe_read(&ip, sizeof(ip), (void *)(ctx->bp + sizeof(ip)));
+
+	struct pair v = {
+		.val = bpf_ktime_get_ns(),
+		.ip = ip,
+	};
+
+	bpf_map_update_elem(&my_map, &ptr, &v, BPF_ANY);
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex4_user.c b/samples/bpf/tracex4_user.c
new file mode 100644
index 000000000000..bc4a3bdea6ed
--- /dev/null
+++ b/samples/bpf/tracex4_user.c
@@ -0,0 +1,69 @@
+/* Copyright (c) 2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <unistd.h>
+#include <stdbool.h>
+#include <string.h>
+#include <time.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+struct pair {
+	long long val;
+	__u64 ip;
+};
+
+static __u64 time_get_ns(void)
+{
+	struct timespec ts;
+
+	clock_gettime(CLOCK_MONOTONIC, &ts);
+	return ts.tv_sec * 1000000000ull + ts.tv_nsec;
+}
+
+static void print_old_objects(int fd)
+{
+	long long val = time_get_ns();
+	__u64 key, next_key;
+	struct pair v;
+
+	key = write(1, "\e[1;1H\e[2J", 12); /* clear screen */
+
+	key = -1;
+	while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
+		bpf_lookup_elem(map_fd[0], &next_key, &v);
+		key = next_key;
+		if (val - v.val < 1000000000ll)
+			/* object was allocated more then 1 sec ago */
+			continue;
+		printf("obj 0x%llx is %2lldsec old was allocated at ip %llx\n",
+		       next_key, (val - v.val) / 1000000000ll, v.ip);
+	}
+}
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	int i;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	for (i = 0; ; i++) {
+		print_old_objects(map_fd[1]);
+		sleep(1);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
