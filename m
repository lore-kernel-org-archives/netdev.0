From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v3 net-next 3/3] samples: bpf: eBPF dropmon example in C
Date: Mon, 21 Jul 2014 20:45:23 -0700
Message-ID: <1406000723-4872-4-git-send-email-ast@plumgrid.com>
References: <1406000723-4872-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33851 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbaGVDpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 23:45:44 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so8783137pdj.26
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 20:45:43 -0700 (PDT)
In-Reply-To: <1406000723-4872-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

semantically this example is the same as dropmon.c which has eBPF in assembler.

In this example both eBPF and user space are in C:

ex2_kern.c - C code that will compile into eBPF and will
  be attached to kfree_skb event
ex2_user.c - corresponding user space part that iterates the map
  populated by in-kernel eBPF code

Usage:
$ sudo ex2 ex2_kern.o

Should see:
writing bpf-5 -> /sys/kernel/debug/tracing/events/skb/kfree_skb/filter
location 0xffffffff816efc67 count 1

location 0xffffffff815d8030 count 1
location 0xffffffff816efc67 count 3

location 0xffffffff815d8030 count 4
location 0xffffffff816efc67 count 9

location 0xffffffff815d8030 count 7
location 0xffffffff816efc67 count 15

location 0xffffffff815d8030 count 10
location 0xffffffff816efc67 count 23

location 0xffffffff815d8030 count 13
location 0xffffffff816efc67 count 29

Ctrl-C at any time. Kernel will auto cleanup maps and programs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile   |    6 ++++--
 samples/bpf/ex2_kern.c |   29 +++++++++++++++++++++++++++++
 samples/bpf/ex2_user.c |   28 ++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 2 deletions(-)
 create mode 100644 samples/bpf/ex2_kern.c
 create mode 100644 samples/bpf/ex2_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index c97f408fcd6d..b865a5df5c60 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,19 +2,21 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := sock_example dropmon ex1
+hostprogs-y := sock_example dropmon ex1 ex2
 
 sock_example-objs := sock_example.o libbpf.o
 dropmon-objs := dropmon.o libbpf.o
 ex1-objs := bpf_load.o libbpf.o ex1_user.o
+ex2-objs := bpf_load.o libbpf.o ex2_user.o
 
 # Tell kbuild to always build the programs
-always := $(hostprogs-y) ex1_kern.o
+always := $(hostprogs-y) ex1_kern.o ex2_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_ex1 += -lelf
+HOSTLOADLIBES_ex2 += -lelf
 
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
 
diff --git a/samples/bpf/ex2_kern.c b/samples/bpf/ex2_kern.c
new file mode 100644
index 000000000000..b4a8e73a3f9d
--- /dev/null
+++ b/samples/bpf/ex2_kern.c
@@ -0,0 +1,29 @@
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(long),
+	.value_size = sizeof(long),
+	.max_entries = 1024,
+};
+
+SEC("events/skb/kfree_skb")
+int bpf_prog2(struct bpf_context *ctx)
+{
+	long loc = ctx->arg2;
+	long init_val = 1;
+	void *value;
+
+	value = bpf_map_lookup_elem(&my_map, &loc);
+	if (value)
+		(*(long *) value) += 1;
+	else
+		bpf_map_update_elem(&my_map, &loc, &init_val);
+	return 0;
+}
+
+char license[] SEC("license") = "GPL";
diff --git a/samples/bpf/ex2_user.c b/samples/bpf/ex2_user.c
new file mode 100644
index 000000000000..8b0fc91f83ca
--- /dev/null
+++ b/samples/bpf/ex2_user.c
@@ -0,0 +1,28 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+int main(int ac, char **argv)
+{
+	long key, next_key, value;
+	int i;
+
+	if (load_bpf_file(argv[1]))
+		return 1;
+
+	for (i = 0; i < 10; i++) {
+		key = 0;
+		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_lookup_elem(map_fd[0], &next_key, &value);
+			printf("location 0x%lx count %ld\n", next_key, value);
+			key = next_key;
+		}
+		if (key)
+			printf("\n");
+		sleep(1);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
