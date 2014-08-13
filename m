From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 26/26] bpf: verifier test
Date: Wed, 13 Aug 2014 00:57:37 -0700
Message-ID: <1407916658-8731-27-git-send-email-ast@plumgrid.com>
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

simple verifier test from user space. Tests valid and invalid programs
and expects predefined error log messages from kernel

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile        |    3 +-
 samples/bpf/test_verifier.c |  354 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 356 insertions(+), 1 deletion(-)
 create mode 100644 samples/bpf/test_verifier.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index b865a5df5c60..e39cb4f13be9 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,12 +2,13 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := sock_example dropmon ex1 ex2
+hostprogs-y := sock_example dropmon ex1 ex2 test_verifier
 
 sock_example-objs := sock_example.o libbpf.o
 dropmon-objs := dropmon.o libbpf.o
 ex1-objs := bpf_load.o libbpf.o ex1_user.o
 ex2-objs := bpf_load.o libbpf.o ex2_user.o
+test_verifier-objs := test_verifier.o libbpf.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y) ex1_kern.o ex2_kern.o
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
new file mode 100644
index 000000000000..46cef16425e4
--- /dev/null
+++ b/samples/bpf/test_verifier.c
@@ -0,0 +1,354 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <linux/unistd.h>
+#include <string.h>
+#include <linux/filter.h>
+#include "libbpf.h"
+
+#define MAX_INSNS 512
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+
+struct bpf_test {
+	const char *descr;
+	struct bpf_insn	insns[MAX_INSNS];
+	int fixup[32];
+	const char *errstr;
+	enum {
+		ACCEPT,
+		REJECT
+	} result;
+};
+
+static struct bpf_test tests[] = {
+	{
+		"add+sub+mul",
+		.insns = {
+			BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 2),
+			BPF_ALU64_IMM(BPF_MOV, BPF_REG_2, 3),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -1),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_1, 3),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"dropmon",
+		.insns = {
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, 8), /* r2 = *(u64 *)(r1 + 8) */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8), /* *(u64 *)(fp - 8) = r2 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+			BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, 1), /* *(u64 *)(fp - 16) = 1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -16), /* r3 = fp - 16 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {4, 16},
+		.result = ACCEPT,
+	},
+	{
+		"dropmon2",
+		.insns = {
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, 8), /* r2 = *(u64 *)(r1 + 8) */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8), /* *(u64 *)(fp - 8) = r2 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+			BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, 1), /* *(u64 *)(fp - 16) = 1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -16), /* r3 = fp - 16 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -10),
+		},
+		.fixup = {4, 16},
+		.result = ACCEPT,
+	},
+	{
+		"unreachable",
+		.insns = {
+			BPF_EXIT_INSN(),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"unreachable2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"out of range jump",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"out of range jump2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"no bpf_exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"loop (back-edge)",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"loop2 (back-edge)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"conditional loop",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, -3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"read uninitialized register",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"program doesn't init R0 before exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"stack out of bounds",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {2},
+		.errstr = "invalid indirect read from stack",
+		.result = REJECT,
+	},
+	{
+		"invalid map_fd for function call",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "fd 0 is not pointing to valid bpf_map",
+		.result = REJECT,
+	},
+	{
+		"don't check return value before access",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "R0 invalid mem access 'map_value_or_null'",
+		.result = REJECT,
+	},
+	{
+		"access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"sometimes access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "R0 invalid mem access",
+		.result = REJECT,
+	},
+};
+
+static int probe_filter_length(struct bpf_insn *fp)
+{
+	int len = 0;
+
+	for (len = MAX_INSNS - 1; len > 0; --len)
+		if (fp[len].code != 0)
+			break;
+
+	return len + 1;
+}
+
+static int create_map(void)
+{
+	long long key, value = 0;
+	int map_fd;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 1024);
+	if (map_fd < 0) {
+		printf("failed to create map '%s'\n", strerror(errno));
+	}
+
+	return map_fd;
+}
+
+static int test(void)
+{
+	int prog_fd, i;
+
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		struct bpf_insn *prog = tests[i].insns;
+		int prog_len = probe_filter_length(prog);
+		int *fixup = tests[i].fixup;
+		int map_fd = -1;
+
+		if (*fixup) {
+
+			map_fd = create_map();
+
+			do {
+				prog[*fixup].imm = map_fd;
+				fixup++;
+			} while (*fixup);
+		}
+		printf("#%d %s ", i, tests[i].descr);
+
+		prog_fd = bpf_prog_load(BPF_PROG_TYPE_TRACING_FILTER, prog,
+					prog_len * sizeof(struct bpf_insn),
+					"GPL");
+
+		if (tests[i].result == ACCEPT) {
+			if (prog_fd < 0) {
+				printf("FAIL\nfailed to load prog '%s'\n",
+				       strerror(errno));
+				printf("%s", bpf_log_buf);
+				goto fail;
+			}
+		} else {
+			if (prog_fd >= 0) {
+				printf("FAIL\nunexpected success to load\n");
+				printf("%s", bpf_log_buf);
+				goto fail;
+			}
+			if (strstr(bpf_log_buf, tests[i].errstr) == 0) {
+				printf("FAIL\nunexpected error message: %s",
+				       bpf_log_buf);
+				goto fail;
+			}
+		}
+
+		printf("OK\n");
+fail:
+		if (map_fd >= 0)
+			close(map_fd);
+		close(prog_fd);
+
+	}
+
+	return 0;
+}
+
+int main(void)
+{
+	return test();
+}
-- 
1.7.9.5
