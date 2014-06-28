From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next 14/14] samples: bpf: example of tracing filters with eBPF
Date: Fri, 27 Jun 2014 17:06:06 -0700
Message-ID: <1403913966-4927-15-git-send-email-ast@plumgrid.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34496 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726AbaF1AGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 20:06:55 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so5259575pad.35
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 17:06:54 -0700 (PDT)
In-Reply-To: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

simple packet drop monitor:
- in-kernel eBPF program attaches to kfree_skb() event and records number
  of packet drops at given location
- userspace iterates over the map every second and prints stats

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile  |    4 +-
 samples/bpf/dropmon.c |  127 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 130 insertions(+), 1 deletion(-)
 create mode 100644 samples/bpf/dropmon.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 95c990151644..8e3dfa0c25e4 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,12 +2,14 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := sock_example
+hostprogs-y := sock_example dropmon
 
 sock_example-objs := sock_example.o libbpf.o
+dropmon-objs := dropmon.o libbpf.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 
 HOSTCFLAGS_libbpf.o += -I$(objtree)/usr/include
 HOSTCFLAGS_sock_example.o += -I$(objtree)/usr/include
+HOSTCFLAGS_dropmon.o += -I$(objtree)/usr/include
diff --git a/samples/bpf/dropmon.c b/samples/bpf/dropmon.c
new file mode 100644
index 000000000000..80d80066f518
--- /dev/null
+++ b/samples/bpf/dropmon.c
@@ -0,0 +1,127 @@
+/* simple packet drop monitor:
+ * - in-kernel eBPF program attaches to kfree_skb() event and records number
+ *   of packet drops at given location
+ * - userspace iterates over the map every second and prints stats
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <asm-generic/socket.h>
+#include <linux/netlink.h>
+#include <net/ethernet.h>
+#include <net/if.h>
+#include <linux/sockios.h>
+#include <linux/if_packet.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+#include <linux/unistd.h>
+#include <string.h>
+#include <linux/filter.h>
+#include <stdlib.h>
+#include <arpa/inet.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include "libbpf.h"
+
+#define MAP_ID 1
+
+#define TRACEPOINT "/sys/kernel/debug/tracing/events/skb/kfree_skb/"
+
+static void write_to_file(const char *file, const char *str)
+{
+	int fd, err;
+
+	fd = open(file, O_WRONLY);
+	err = write(fd, str, strlen(str));
+	(void) err;
+	close(fd);
+}
+
+static int dropmon(void)
+{
+	/* the following eBPF program is equivalent to C:
+	 * void filter(struct bpf_context *ctx)
+	 * {
+	 *   long loc = ctx->arg2;
+	 *   long init_val = 1;
+	 *   void *value;
+	 *
+	 *   value = bpf_map_lookup_elem(MAP_ID, &loc);
+	 *   if (value) {
+	 *      (*(long *) value) += 1;
+	 *   } else {
+	 *      bpf_map_update_elem(MAP_ID, &loc, &init_val);
+	 *   }
+	 * }
+	 */
+	static struct sock_filter_int prog[] = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, 8), /* r2 = *(u64 *)(r1 + 8) */
+		BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8), /* *(u64 *)(fp - 8) = r2 */
+		BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+		BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, MAP_ID), /* r1 = MAP_ID */
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+		BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1), /* r1 = 1 */
+		BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+		BPF_EXIT_INSN(),
+		BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, 1), /* *(u64 *)(fp - 16) = 1 */
+		BPF_ALU64_REG(BPF_MOV, BPF_REG_3, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -16), /* r3 = fp - 16 */
+		BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+		BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, MAP_ID), /* r1 = MAP_ID */
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+		BPF_EXIT_INSN(),
+	};
+
+	int prog_id = 1, i;
+	long long key, next_key, value = 0;
+	char fmt[32];
+
+	if (bpf_create_map(MAP_ID, sizeof(key), sizeof(value), 1024) < 0) {
+		printf("failed to create map '%s'\n", strerror(errno));
+		goto cleanup;
+	}
+
+	prog_id = bpf_prog_load(prog_id, BPF_PROG_TYPE_TRACING_FILTER, prog, sizeof(prog), "GPL");
+	if (prog_id < 0) {
+		printf("failed to load prog '%s'\n", strerror(errno));
+		return -1;
+	}
+
+	sprintf(fmt, "bpf_%d", prog_id);
+
+	write_to_file(TRACEPOINT "filter", fmt);
+	write_to_file(TRACEPOINT "enable", "1");
+
+	for (i = 0; i < 10; i++) {
+		key = 0;
+		while (bpf_get_next_key(MAP_ID, &key, &next_key) == 0) {
+			bpf_lookup_elem(MAP_ID, &next_key, &value);
+			printf("location 0x%llx count %lld\n", next_key, value);
+			key = next_key;
+		}
+		if (key)
+			printf("\n");
+		sleep(1);
+	}
+
+cleanup:
+	bpf_prog_unload(prog_id);
+
+	bpf_delete_map(MAP_ID);
+
+	write_to_file(TRACEPOINT "enable", "0");
+	write_to_file(TRACEPOINT "filter", "0");
+
+	return 0;
+}
+
+int main(void)
+{
+	dropmon();
+	return 0;
+}
-- 
1.7.9.5
