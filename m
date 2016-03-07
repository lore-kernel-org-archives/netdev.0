From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 8/9] samples/bpf: add bpf map stress test
Date: Sun, 6 Mar 2016 17:58:36 -0800
Message-ID: <1457315917-1970307-9-git-send-email-ast@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this test calls bpf programs from different contexts:
from inside of slub, from rcu, from pretty much everywhere,
since it kprobes all spin_lock functions.
It stresses the bpf hash and percpu map pre-allocation,
deallocation logic and call_rcu mechanisms.
User space part adding more stress by walking and deleting map elements.

Note that due to nature bpf_load.c the earlier kprobe+bpf programs are
already active while loader loads new programs, creates new kprobes and
attaches them.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile        |  4 +++
 samples/bpf/spintest_kern.c | 59 +++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/spintest_user.c | 50 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 113 insertions(+)
 create mode 100644 samples/bpf/spintest_kern.c
 create mode 100644 samples/bpf/spintest_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index c4f8ae0c8afe..75a13e742ab4 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -17,6 +17,7 @@ hostprogs-y += tracex6
 hostprogs-y += trace_output
 hostprogs-y += lathist
 hostprogs-y += offwaketime
+hostprogs-y += spintest
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -34,6 +35,7 @@ tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
 trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
 lathist-objs := bpf_load.o libbpf.o lathist_user.o
 offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
+spintest-objs := bpf_load.o libbpf.o spintest_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -50,6 +52,7 @@ always += trace_output_kern.o
 always += tcbpf1_kern.o
 always += lathist_kern.o
 always += offwaketime_kern.o
+always += spintest_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -67,6 +70,7 @@ HOSTLOADLIBES_tracex6 += -lelf
 HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
 HOSTLOADLIBES_offwaketime += -lelf
+HOSTLOADLIBES_spintest += -lelf
 
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
diff --git a/samples/bpf/spintest_kern.c b/samples/bpf/spintest_kern.c
new file mode 100644
index 000000000000..ef8ac33bb2e9
--- /dev/null
+++ b/samples/bpf/spintest_kern.c
@@ -0,0 +1,59 @@
+/* Copyright (c) 2016, Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(long),
+	.max_entries = 1024,
+};
+struct bpf_map_def SEC("maps") my_map2 = {
+	.type = BPF_MAP_TYPE_PERCPU_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(long),
+	.max_entries = 1024,
+};
+
+#define PROG(foo) \
+int foo(struct pt_regs *ctx) \
+{ \
+	long v = ctx->ip, *val; \
+\
+	val = bpf_map_lookup_elem(&my_map, &v); \
+	bpf_map_update_elem(&my_map, &v, &v, BPF_ANY); \
+	bpf_map_update_elem(&my_map2, &v, &v, BPF_ANY); \
+	bpf_map_delete_elem(&my_map2, &v); \
+	return 0; \
+}
+
+/* add kprobes to all possible *spin* functions */
+SEC("kprobe/spin_unlock")PROG(p1)
+SEC("kprobe/spin_lock")PROG(p2)
+SEC("kprobe/mutex_spin_on_owner")PROG(p3)
+SEC("kprobe/rwsem_spin_on_owner")PROG(p4)
+SEC("kprobe/spin_unlock_irqrestore")PROG(p5)
+SEC("kprobe/_raw_spin_unlock_irqrestore")PROG(p6)
+SEC("kprobe/_raw_spin_unlock_bh")PROG(p7)
+SEC("kprobe/_raw_spin_unlock")PROG(p8)
+SEC("kprobe/_raw_spin_lock_irqsave")PROG(p9)
+SEC("kprobe/_raw_spin_trylock_bh")PROG(p10)
+SEC("kprobe/_raw_spin_lock_irq")PROG(p11)
+SEC("kprobe/_raw_spin_trylock")PROG(p12)
+SEC("kprobe/_raw_spin_lock")PROG(p13)
+SEC("kprobe/_raw_spin_lock_bh")PROG(p14)
+/* and to inner bpf helpers */
+SEC("kprobe/htab_map_update_elem")PROG(p15)
+SEC("kprobe/__htab_percpu_map_update_elem")PROG(p16)
+SEC("kprobe/htab_map_alloc")PROG(p17)
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/spintest_user.c b/samples/bpf/spintest_user.c
new file mode 100644
index 000000000000..311ede532230
--- /dev/null
+++ b/samples/bpf/spintest_user.c
@@ -0,0 +1,50 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include <string.h>
+#include <assert.h>
+#include <sys/resource.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+int main(int ac, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	long key, next_key, value;
+	char filename[256];
+	struct ksym *sym;
+	int i;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
+
+	if (load_kallsyms()) {
+		printf("failed to process /proc/kallsyms\n");
+		return 2;
+	}
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	for (i = 0; i < 5; i++) {
+		key = 0;
+		printf("kprobing funcs:");
+		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_lookup_elem(map_fd[0], &next_key, &value);
+			assert(next_key == value);
+			sym = ksym_search(value);
+			printf(" %s", sym->name);
+			key = next_key;
+		}
+		if (key)
+			printf("\n");
+		key = 0;
+		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0)
+			bpf_delete_elem(map_fd[0], &next_key);
+		sleep(1);
+	}
+
+	return 0;
+}
-- 
2.6.5
