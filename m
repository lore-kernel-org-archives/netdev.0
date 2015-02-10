From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 linux-trace 3/8] samples: bpf: simple tracing example in eBPF assembler
Date: Mon,  9 Feb 2015 19:45:56 -0800
Message-ID: <1423539961-21792-4-git-send-email-ast@plumgrid.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

simple packet drop monitor:
- in-kernel eBPF program attaches to skb:kfree_skb event and records number
  of packet drops at given location
- userspace iterates over the map every second and prints stats

Usage:
$ sudo dropmon
location 0xffffffff81695995 count 1
location 0xffffffff816d0da9 count 2

location 0xffffffff81695995 count 2
location 0xffffffff816d0da9 count 2

location 0xffffffff81695995 count 3
location 0xffffffff816d0da9 count 2

$ addr2line -ape ./bld_x64/vmlinux 0xffffffff81695995 0xffffffff816d0da9
0xffffffff81695995: ./bld_x64/../net/ipv4/icmp.c:1038
0xffffffff816d0da9: ./bld_x64/../net/unix/af_unix.c:1231

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile  |    2 +
 samples/bpf/dropmon.c |  143 +++++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.c  |    7 +++
 samples/bpf/libbpf.h  |    4 ++
 4 files changed, 156 insertions(+)
 create mode 100644 samples/bpf/dropmon.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index b5b3600dcdf5..789691374562 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -6,7 +6,9 @@ hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
 hostprogs-y += sockex1
 hostprogs-y += sockex2
+hostprogs-y += dropmon
 
+dropmon-objs := dropmon.o libbpf.o
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
diff --git a/samples/bpf/dropmon.c b/samples/bpf/dropmon.c
new file mode 100644
index 000000000000..515504f68506
--- /dev/null
+++ b/samples/bpf/dropmon.c
@@ -0,0 +1,143 @@
+/* simple packet drop monitor:
+ * - in-kernel eBPF program attaches to kfree_skb() event and records number
+ *   of packet drops at given location
+ * - userspace iterates over the map every second and prints stats
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <linux/unistd.h>
+#include <string.h>
+#include <linux/filter.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <stdbool.h>
+#include <linux/perf_event.h>
+#include <sys/syscall.h>
+#include <sys/ioctl.h>
+#include "libbpf.h"
+
+#define TRACEPOINT "/sys/kernel/debug/tracing/events/skb/kfree_skb/id"
+
+static int dropmon(void)
+{
+	long long key, next_key, value = 0;
+	int prog_fd, map_fd, i, event_fd, efd, err;
+	char buf[32];
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 1024);
+	if (map_fd < 0) {
+		printf("failed to create map '%s'\n", strerror(errno));
+		goto cleanup;
+	}
+
+	/* the following eBPF program is equivalent to C:
+	 * int filter(struct bpf_context *ctx)
+	 * {
+	 *   long loc = ctx->arg2;
+	 *   long init_val = 1;
+	 *   long *value;
+	 *
+	 *   value = bpf_map_lookup_elem(MAP_ID, &loc);
+	 *   if (value) {
+	 *      __sync_fetch_and_add(value, 1);
+	 *   } else {
+	 *      bpf_map_update_elem(MAP_ID, &loc, &init_val, BPF_ANY);
+	 *   }
+	 *   return 0;
+	 * }
+	 */
+	struct bpf_insn prog[] = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, 8), /* r2 = *(u64 *)(r1 + 8) */
+		BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8), /* *(u64 *)(fp - 8) = r2 */
+		BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+		BPF_LD_MAP_FD(BPF_REG_1, map_fd),
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+		BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+		BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+		BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
+		BPF_EXIT_INSN(),
+		BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, 1), /* *(u64 *)(fp - 16) = 1 */
+		BPF_MOV64_IMM(BPF_REG_4, BPF_ANY),
+		BPF_MOV64_REG(BPF_REG_3, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -16), /* r3 = fp - 16 */
+		BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+		BPF_LD_MAP_FD(BPF_REG_1, map_fd),
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+		BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
+		BPF_EXIT_INSN(),
+	};
+
+	prog_fd = bpf_prog_load(BPF_PROG_TYPE_TRACEPOINT, prog,
+				sizeof(prog), "GPL");
+	if (prog_fd < 0) {
+		printf("failed to load prog '%s'\n%s",
+		       strerror(errno), bpf_log_buf);
+		return -1;
+	}
+
+
+	event_fd = open(TRACEPOINT, O_RDONLY, 0);
+	if (event_fd < 0) {
+		printf("failed to open event %s\n", TRACEPOINT);
+		return -1;
+	}
+
+	err = read(event_fd, buf, sizeof(buf));
+	if (err < 0 || err >= sizeof(buf)) {
+		printf("read from '%s' failed '%s'\n",
+		       TRACEPOINT, strerror(errno));
+		return -1;
+	}
+
+	close(event_fd);
+
+	buf[err] = 0;
+
+	struct perf_event_attr attr = {.type = PERF_TYPE_TRACEPOINT};
+	attr.config = atoi(buf);
+
+	efd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
+	if (efd < 0) {
+		printf("event %lld fd %d err %s\n",
+		       attr.config, efd, strerror(errno));
+		return -1;
+	}
+	ioctl(efd, PERF_EVENT_IOC_ENABLE, 0);
+	ioctl(efd, PERF_EVENT_IOC_SET_BPF, prog_fd);
+
+	for (i = 0; i < 10; i++) {
+		key = 0;
+		while (bpf_get_next_key(map_fd, &key, &next_key) == 0) {
+			bpf_lookup_elem(map_fd, &next_key, &value);
+			printf("location 0x%llx count %lld\n", next_key, value);
+			key = next_key;
+		}
+		if (key)
+			printf("\n");
+		sleep(1);
+	}
+
+cleanup:
+	/* maps, programs, tracepoint filters will auto cleanup on process exit */
+
+	return 0;
+}
+
+int main(void)
+{
+	FILE *f;
+
+	/* start ping in the background to get some kfree_skb events */
+	f = popen("ping -c5 localhost", "r");
+	(void) f;
+
+	dropmon();
+	return 0;
+}
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 46d50b7ddf79..f4f428149a7d 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -121,3 +121,10 @@ int open_raw_sock(const char *name)
 
 	return sock;
 }
+
+int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
+		    int group_fd, unsigned long flags)
+{
+	return syscall(__NR_perf_event_open, attr, pid, cpu,
+		       group_fd, flags);
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 58c5fe1bdba1..92ff824eaed5 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -182,4 +182,8 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 /* create RAW socket and bind to interface 'name' */
 int open_raw_sock(const char *name);
 
+struct perf_event_attr;
+int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
+		    int group_fd, unsigned long flags);
+
 #endif
-- 
1.7.9.5
