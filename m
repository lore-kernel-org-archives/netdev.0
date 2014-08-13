From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 24/26] samples: bpf: eBPF example in C
Date: Wed, 13 Aug 2014 00:57:35 -0700
Message-ID: <1407916658-8731-25-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ex1_kern.c - C program which will be compiled into eBPF
to filter netif_receive_skb events on skb->dev->name == "lo"

ex1_user.c - corresponding user space component that
forever reads /sys/.../trace_pipe

Usage:
$ sudo ex1

should see:
writing bpf-4 -> /sys/kernel/debug/tracing/events/net/netif_receive_skb/filter
  ping-25476 [001] ..s3  5639.718218: __netif_receive_skb_core: skb 4d51700 dev b9e6000
  ping-25476 [001] ..s3  5639.718262: __netif_receive_skb_core: skb 4d51400 dev b9e6000

  ping-25476 [002] ..s3  5640.716233: __netif_receive_skb_core: skb 5d06500 dev b9e6000
  ping-25476 [002] ..s3  5640.716272: __netif_receive_skb_core: skb 5d06300 dev b9e6000

Ctrl-C at any time, kernel will auto cleanup

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile   |   15 +++++++++++++--
 samples/bpf/ex1_kern.c |   27 +++++++++++++++++++++++++++
 samples/bpf/ex1_user.c |   24 ++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 2 deletions(-)
 create mode 100644 samples/bpf/ex1_kern.c
 create mode 100644 samples/bpf/ex1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index caf1ab93b37c..c97f408fcd6d 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,12 +2,23 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := sock_example dropmon
+hostprogs-y := sock_example dropmon ex1
 
 sock_example-objs := sock_example.o libbpf.o
 dropmon-objs := dropmon.o libbpf.o
+ex1-objs := bpf_load.o libbpf.o ex1_user.o
 
 # Tell kbuild to always build the programs
-always := $(hostprogs-y)
+always := $(hostprogs-y) ex1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
+
+HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
+HOSTLOADLIBES_ex1 += -lelf
+
+LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
+
+%.o: %.c
+	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+		-O2 -emit-llvm -c $< -o -| $(LLC) -o $@
diff --git a/samples/bpf/ex1_kern.c b/samples/bpf/ex1_kern.c
new file mode 100644
index 000000000000..05a06cccaadb
--- /dev/null
+++ b/samples/bpf/ex1_kern.c
@@ -0,0 +1,27 @@
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include "bpf_helpers.h"
+
+SEC("events/net/netif_receive_skb")
+int bpf_prog1(struct bpf_context *ctx)
+{
+	/*
+	 * attaches to /sys/kernel/debug/tracing/events/net/netif_receive_skb
+	 * prints events for loobpack device only
+	 */
+	char devname[] = "lo";
+	struct net_device *dev;
+	struct sk_buff *skb = 0;
+
+	skb = (struct sk_buff *) ctx->arg1;
+	dev = bpf_fetch_ptr(&skb->dev);
+	if (bpf_memcmp(dev->name, devname, 2) == 0) {
+		char fmt[] = "skb %x dev %x\n";
+		bpf_printk(fmt, sizeof(fmt), skb, dev);
+	}
+	return 0;
+}
+
+char license[] SEC("license") = "GPL";
diff --git a/samples/bpf/ex1_user.c b/samples/bpf/ex1_user.c
new file mode 100644
index 000000000000..e85c1b483f57
--- /dev/null
+++ b/samples/bpf/ex1_user.c
@@ -0,0 +1,24 @@
+#include <stdio.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+int main(int ac, char **argv)
+{
+	FILE *f;
+	char filename[256];
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	f = popen("ping -c5 localhost", "r");
+	(void) f;
+
+	read_trace_pipe();
+
+	return 0;
+}
-- 
1.7.9.5
