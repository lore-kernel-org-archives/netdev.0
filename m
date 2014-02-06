From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC PATCH v2 tip 7/7] tracing filter examples in BPF
Date: Wed,  5 Feb 2014 17:10:46 -0800
Message-ID: <1391649046-4383-8-git-send-email-ast@plumgrid.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:37057 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932257AbaBFBLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 20:11:08 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so1052970pdj.15
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 17:11:07 -0800 (PST)
In-Reply-To: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

filter_check/ - userspace correctness checker of BPF filter
examples/ - BPF filter examples in C

will be compiled by LLVM into .bpf
$cd examples
$make - compile .c into .bpf
$make check - check correctness of *.bpf
$make try - to apply netif_rcv.bpf as a tracing filter

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 tools/bpf/examples/Makefile                 |   71 +++++++++++++++++
 tools/bpf/examples/README.txt               |   59 ++++++++++++++
 tools/bpf/examples/dropmon.c                |   40 ++++++++++
 tools/bpf/examples/netif_rcv.c              |   34 ++++++++
 tools/bpf/filter_check/Makefile             |   32 ++++++++
 tools/bpf/filter_check/README.txt           |    3 +
 tools/bpf/filter_check/trace_filter_check.c |  115 +++++++++++++++++++++++++++
 7 files changed, 354 insertions(+)
 create mode 100644 tools/bpf/examples/Makefile
 create mode 100644 tools/bpf/examples/README.txt
 create mode 100644 tools/bpf/examples/dropmon.c
 create mode 100644 tools/bpf/examples/netif_rcv.c
 create mode 100644 tools/bpf/filter_check/Makefile
 create mode 100644 tools/bpf/filter_check/README.txt
 create mode 100644 tools/bpf/filter_check/trace_filter_check.c

diff --git a/tools/bpf/examples/Makefile b/tools/bpf/examples/Makefile
new file mode 100644
index 0000000..1da6fd5
--- /dev/null
+++ b/tools/bpf/examples/Makefile
@@ -0,0 +1,71 @@
+KOBJ := $(PWD)/../../..
+
+VERSION_FILE := $(KOBJ)/include/generated/uapi/linux/version.h
+
+ifeq (,$(wildcard $(VERSION_FILE)))
+  $(error Linux kernel source not configured - missing version.h)
+endif
+
+BLD=$(PWD)
+LLC=$(BLD)/../llvm/bld/Debug+Asserts/bin/llc
+CHK=$(BLD)/../filter_check/trace_filter_check
+
+EXTRA_CFLAGS=
+
+ifeq ($(NESTED),1)
+# to get NOSTDINC_FLAGS and LINUXINCLUDE from kernel build
+# have to trick top Makefile
+# pretend that we're building a module
+KBUILD_EXTMOD=$(PWD)
+# and include main kernel Makefile
+include Makefile
+
+# cannot have other targets (like all, clean) here
+# since they will conflict
+%.bpf: %.c
+	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+	  -D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+	  -O2 -emit-llvm -c $< -o -| $(LLC) -o $@
+
+else
+
+SRCS := $(notdir $(wildcard *.c))
+BPFS = $(patsubst %.c,$(BLD)/%.bpf,$(SRCS))
+
+all: $(LLC)
+# invoke make recursively with current Makefile, but
+# for specific .bpf targets
+	$(MAKE) -C $(KOBJ) -f $(BLD)/Makefile NESTED=1 $(BPFS)
+
+$(LLC):
+	$(MAKE) -C ../llvm/bld -j4
+
+$(CHK):
+	$(MAKE) -C ../filter_check
+
+check: $(CHK)
+	@$(foreach bpf,$(patsubst %.c,%.bpf,$(SRCS)),echo Checking $(bpf) ...;$(CHK) $(bpf);)
+
+try:
+	@echo --- BPF filter for static tracepoint net:netif_receive_skb ---
+	@echo | sudo tee /sys/kernel/debug/tracing/trace > /dev/null
+	@cat netif_rcv.bpf | sudo tee /sys/kernel/debug/tracing/events/net/netif_receive_skb/filter > /dev/null
+	@echo 1 | sudo tee /sys/kernel/debug/tracing/events/net/netif_receive_skb/enable > /dev/null
+	ping -c1 localhost | grep req
+	sudo cat /sys/kernel/debug/tracing/trace
+	@echo 0 | sudo tee /sys/kernel/debug/tracing/events/net/netif_receive_skb/enable > /dev/null
+	@echo 0 | sudo tee /sys/kernel/debug/tracing/events/net/netif_receive_skb/filter > /dev/null
+	@echo | sudo tee /sys/kernel/debug/tracing/trace
+	@echo --- BPF filter for dynamic kprobe __netif_receive_skb ---
+	@echo "p:my __netif_receive_skb" | sudo tee /sys/kernel/debug/tracing/kprobe_events > /dev/null
+	@cat netif_rcv.bpf | sudo tee /sys/kernel/debug/tracing/events/kprobes/my/filter > /dev/null
+	@echo 1 | sudo tee /sys/kernel/debug/tracing/events/kprobes/my/enable > /dev/null
+	ping -c1 localhost | grep req
+	sudo cat /sys/kernel/debug/tracing/trace
+	@echo 0 | sudo tee /sys/kernel/debug/tracing/events/kprobes/my/filter > /dev/null
+	@echo 0 | sudo tee /sys/kernel/debug/tracing/events/kprobes/my/enable > /dev/null
+	@echo | sudo tee /sys/kernel/debug/tracing/kprobe_events > /dev/null
+
+clean:
+	rm -f *.bpf
+endif
diff --git a/tools/bpf/examples/README.txt b/tools/bpf/examples/README.txt
new file mode 100644
index 0000000..0768ae1
--- /dev/null
+++ b/tools/bpf/examples/README.txt
@@ -0,0 +1,59 @@
+Tracing filter examples
+
+netif_rcv: tracing filter example that prints events for loobpack device only
+
+$ cat netif_rcv.bpf > /sys/kernel/debug/tracing/events/net/netif_receive_skb/filter
+$ echo 1 > /sys/kernel/debug/tracing/events/net/netif_receive_skb/enable
+$ ping -c1 localhost
+$ cat /sys/kernel/debug/tracing/trace
+            ping-5913  [003] ..s2  3779.285726: __netif_receive_skb_core: skb ffff880808e3a300 dev ffff88080bbf8000
+            ping-5913  [003] ..s2  3779.285744: __netif_receive_skb_core: skb ffff880808e3a900 dev ffff88080bbf8000
+
+Alternatively do:
+
+$make - compile .c into .bpf
+
+$make check - check correctness of *.bpf
+
+$make try - to apply netif_rcv.bpf as a tracing filter
+
+Should see output like:
+
+--- BPF filter for static tracepoint net:netif_receive_skb ---
+ping -c1 localhost | grep req
+64 bytes from localhost (127.0.0.1): icmp_req=1 ttl=64 time=0.040 ms
+sudo cat /sys/kernel/debug/tracing/trace
+# tracer: nop
+#
+# entries-in-buffer/entries-written: 2/2   #P:4
+#
+#                              _-----=> irqs-off
+#                             / _----=> need-resched
+#                            | / _---=> hardirq/softirq
+#                            || / _--=> preempt-depth
+#                            ||| /     delay
+#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
+#              | |       |   ||||       |         |
+            ping-5023  [001] ..s2  3554.532361: __netif_receive_skb_core: skb ffff8807f88bcc00 dev ffff88080b4d0000
+            ping-5023  [001] ..s2  3554.532378: __netif_receive_skb_core: skb ffff8807f88bcd00 dev ffff88080b4d0000
+
+--- BPF filter for dynamic kprobe __netif_receive_skb ---
+ping -c1 localhost | grep req
+64 bytes from localhost (127.0.0.1): icmp_req=1 ttl=64 time=0.061 ms
+sudo cat /sys/kernel/debug/tracing/trace
+# tracer: nop
+#
+# entries-in-buffer/entries-written: 2/2   #P:4
+#
+#                              _-----=> irqs-off
+#                             / _----=> need-resched
+#                            | / _---=> hardirq/softirq
+#                            || / _--=> preempt-depth
+#                            ||| /     delay
+#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
+#              | |       |   ||||       |         |
+            ping-5053  [002] d.s2  3554.902215: kprobe_ftrace_handler: skb ffff8807ae6f7700 dev ffff88080b4d0000
+            ping-5053  [002] d.s2  3554.902236: kprobe_ftrace_handler: skb ffff8807ae6f7200 dev ffff88080b4d0000
+
+dropmon: faster version of tools/perf/scripts/python/net_dropmonitor.py
+work in progress
diff --git a/tools/bpf/examples/dropmon.c b/tools/bpf/examples/dropmon.c
new file mode 100644
index 0000000..3ed3f41
--- /dev/null
+++ b/tools/bpf/examples/dropmon.c
@@ -0,0 +1,40 @@
+/*
+ * drop monitor in BPF, faster version of
+ * tools/perf/scripts/python/net_dropmonitor.py
+ */
+#include <linux/bpf.h>
+#include <trace/bpf_trace.h>
+
+#define DESC(NAME) __attribute__((section(NAME), used))
+
+DESC("e skb:kfree_skb")
+/* attaches to /sys/kernel/debug/tracing/events/skb/kfree_skb */
+void dropmon(struct bpf_context *ctx)
+{
+	void *loc;
+	uint64_t *drop_cnt;
+
+	/*
+	 * skb:kfree_skb is defined as:
+	 * TRACE_EVENT(kfree_skb,
+	 *         TP_PROTO(struct sk_buff *skb, void *location),
+	 * so ctx->arg2 is 'location'
+	 */
+	loc = (void *)ctx->arg2;
+
+	drop_cnt = bpf_table_lookup(ctx, 0, &loc);
+	if (drop_cnt) {
+		__sync_fetch_and_add(drop_cnt, 1);
+	} else {
+		uint64_t init = 0;
+		bpf_table_update(ctx, 0, &loc, &init);
+	}
+}
+
+struct bpf_table t[] DESC("bpftables") = {
+	{BPF_TABLE_HASH, sizeof(void *), sizeof(uint64_t), 4096, 0}
+};
+
+/* filter code license: */
+char l[] DESC("license") = "GPL v2";
+
diff --git a/tools/bpf/examples/netif_rcv.c b/tools/bpf/examples/netif_rcv.c
new file mode 100644
index 0000000..cd69f5c
--- /dev/null
+++ b/tools/bpf/examples/netif_rcv.c
@@ -0,0 +1,34 @@
+/*
+ * tracing filter example
+ * attaches to /sys/kernel/debug/tracing/events/net/netif_receive_skb
+ * prints events for loobpack device only
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/bpf.h>
+#include <trace/bpf_trace.h>
+
+#define DESC(NAME) __attribute__((section(NAME), used))
+
+DESC("e net:netif_receive_skb")
+void my_filter(struct bpf_context *ctx)
+{
+	char devname[4] = "lo";
+	struct net_device *dev;
+	struct sk_buff *skb = 0;
+
+	/*
+	 * for tracepoints arg1 is the 1st arg of TP_ARGS() macro
+	 * defined in include/trace/events/.h
+	 * for kprobe events arg1 is the 1st arg of probed function
+	 */
+	skb = (struct sk_buff *)ctx->arg1;
+	dev = bpf_load_pointer(&skb->dev);
+	if (bpf_memcmp(dev->name, devname, 2) == 0) {
+		char fmt[] = "skb %p dev %p \n";
+		bpf_trace_printk(fmt, sizeof(fmt), (long)skb, (long)dev, 0);
+	}
+}
+
+/* filter code license: */
+char license[] DESC("license") = "GPL";
diff --git a/tools/bpf/filter_check/Makefile b/tools/bpf/filter_check/Makefile
new file mode 100644
index 0000000..b0ac7aa
--- /dev/null
+++ b/tools/bpf/filter_check/Makefile
@@ -0,0 +1,32 @@
+CC = gcc
+
+all: trace_filter_check
+
+srctree=../../..
+src-perf=../../perf
+ARCH=x86
+
+CFLAGS += -I$(src-perf)/util/include
+CFLAGS += -I$(src-perf)/arch/$(ARCH)/include
+CFLAGS += -I$(srctree)/arch/$(ARCH)/include/uapi
+CFLAGS += -I$(srctree)/arch/$(ARCH)/include
+CFLAGS += -I$(srctree)/include/uapi
+CFLAGS += -I$(srctree)/include
+CFLAGS += -O2 -w
+
+$(srctree)/kernel/bpf_jit/bpf_check.o: $(srctree)/kernel/bpf_jit/bpf_check.c
+	$(MAKE) -C $(srctree) kernel/bpf_jit/bpf_check.o
+$(srctree)/kernel/bpf_jit/bpf_run.o: $(srctree)/kernel/bpf_jit/bpf_run.c
+	$(MAKE) -C $(srctree) kernel/bpf_jit/bpf_run.o
+$(srctree)/kernel/trace/bpf_trace_callbacks.o: $(srctree)/kernel/trace/bpf_trace_callbacks.c
+	$(MAKE) -C $(srctree) kernel/trace/bpf_trace_callbacks.o
+
+trace_filter_check: LDLIBS = -Wl,--unresolved-symbols=ignore-all
+trace_filter_check: trace_filter_check.o \
+	$(srctree)/kernel/bpf_jit/bpf_check.o \
+	$(srctree)/kernel/bpf_jit/bpf_run.o \
+	$(srctree)/kernel/trace/bpf_trace_callbacks.o
+
+clean:
+	rm -rf *.o trace_filter_check
+
diff --git a/tools/bpf/filter_check/README.txt b/tools/bpf/filter_check/README.txt
new file mode 100644
index 0000000..f5badcd
--- /dev/null
+++ b/tools/bpf/filter_check/README.txt
@@ -0,0 +1,3 @@
+To pre-check correctness of the filter do:
+$ trace_filter_check filter_ex1.bpf
+(final filter check always happens in kernel)
diff --git a/tools/bpf/filter_check/trace_filter_check.c b/tools/bpf/filter_check/trace_filter_check.c
new file mode 100644
index 0000000..32ac7ff
--- /dev/null
+++ b/tools/bpf/filter_check/trace_filter_check.c
@@ -0,0 +1,115 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdarg.h>
+#include <errno.h>
+
+/* for i386 use kernel ABI, this attr ignored by gcc in 64-bit */
+#define REGPARM __attribute__((regparm(3)))
+
+REGPARM
+void *__kmalloc(size_t size, int flags)
+{
+	return calloc(size, 1);
+}
+
+REGPARM
+void kfree(void *objp)
+{
+	free(objp);
+}
+
+int kmalloc_caches[128];
+REGPARM
+void *kmem_cache_alloc_trace(void *caches, int flags, size_t size)
+{
+	return calloc(size, 1);
+}
+
+void bpf_compile(void *prog)
+{
+}
+
+void __bpf_free(void *prog)
+{
+}
+
+REGPARM
+int memcmp(char *p1, char *p2, int len)
+{
+	int i;
+	for (i = 0; i < len; i++)
+		if (*p1++ != *p2++)
+			return 1;
+	return 0;
+}
+
+REGPARM
+int memcpy(char *p1, char *p2, int len)
+{
+	int i;
+	for (i = 0; i < len; i++)
+		*p1++ = *p2++;
+	return 0;
+}
+
+REGPARM
+int strcmp(char *p1, char *p2)
+{
+	return memcmp(p1, p2, strlen(p1));
+}
+
+
+REGPARM
+int printk(const char *fmt, ...)
+{
+	int ret;
+	va_list ap;
+
+	va_start(ap, fmt);
+	ret = vprintf(fmt, ap);
+	va_end(ap);
+	return ret;
+}
+
+char buf[16000];
+REGPARM
+int bpf_load_image(const char *image, int image_len, struct bpf_callbacks *cb,
+		   void **p_prog);
+
+int main(int ac, char **av)
+{
+	FILE *f;
+	int size, err;
+	void *prog;
+
+	if (ac < 2) {
+		printf("Usage: %s bpf_binary_image\n", av[0]);
+		return 1;
+	}
+
+	f = fopen(av[1], "r");
+	if (!f) {
+		printf("fopen %s\n", strerror(errno));
+		return 2;
+	}
+	size = fread(buf, 1, sizeof(buf), f);
+	if (size <= 0) {
+		printf("fread %s\n", strerror(errno));
+		return 3;
+	}
+	err = bpf_load_image(buf, size, &bpf_trace_cb, &prog);
+	if (!err)
+		printf("OK\n");
+	else
+		printf("err %s\n", strerror(-err));
+	fclose(f);
+	return 0;
+}
-- 
1.7.9.5
