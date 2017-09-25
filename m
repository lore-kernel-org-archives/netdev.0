From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/6] bpf: improve selftests and add tests for meta pointer
Date: Mon, 25 Sep 2017 02:25:53 +0200
Message-ID: <97e3cec4b4fb82f1759ba0a1ff416d551edf752f.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37225 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933015AbdIYA1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:07 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add various test_verifier selftests, and a simple xdp/tc functional
test that is being attached to veths. Also let new versions of clang
use the recently added -mcpu=probe support [1] for the BPF target,
so that it can probe the underlying kernel for BPF insn set extensions.
We could also just set this options always, where older versions just
ignore it and give a note to the user that the -mcpu value is not
supported, but given emitting the note cannot be turned off from clang
side lets not confuse users running selftests with it, thus fallback
to the default generic one when we see that clang doesn't support it.
Also allow CPU option to be overridden in the Makefile from command
line.

  [1] https://github.com/llvm-mirror/llvm/commit/d7276a40d87b89aed89978dec6457a5b8b3a0db5

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/Makefile         |  21 ++-
 tools/testing/selftests/bpf/bpf_helpers.h    |   2 +
 tools/testing/selftests/bpf/test_verifier.c  | 247 +++++++++++++++++++++++++++
 tools/testing/selftests/bpf/test_xdp_meta.c  |  53 ++++++
 tools/testing/selftests/bpf/test_xdp_meta.sh |  51 ++++++
 5 files changed, 370 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_xdp_meta.c
 create mode 100755 tools/testing/selftests/bpf/test_xdp_meta.sh

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index f4b23d6..924af8d7 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -15,9 +15,10 @@ TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test
 	test_align
 
 TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o test_tcp_estats.o test_obj_id.o \
-	test_pkt_md_access.o test_xdp_redirect.o sockmap_parse_prog.o sockmap_verdict_prog.o
+	test_pkt_md_access.o test_xdp_redirect.o test_xdp_meta.o sockmap_parse_prog.o     \
+	sockmap_verdict_prog.o
 
-TEST_PROGS := test_kmod.sh test_xdp_redirect.sh
+TEST_PROGS := test_kmod.sh test_xdp_redirect.sh test_xdp_meta.sh
 
 include ../lib.mk
 
@@ -34,8 +35,20 @@ $(BPFOBJ): force
 	$(MAKE) -C $(BPFDIR) OUTPUT=$(OUTPUT)/
 
 CLANG ?= clang
+LLC   ?= llc
+
+PROBE := $(shell llc -march=bpf -mcpu=probe -filetype=null /dev/null 2>&1)
+
+# Let newer LLVM versions transparently probe the kernel for availability
+# of full BPF instruction set.
+ifeq ($(PROBE),)
+  CPU ?= probe
+else
+  CPU ?= generic
+endif
 
 %.o: %.c
 	$(CLANG) -I. -I./include/uapi -I../../../include/uapi \
-		-Wno-compare-distinct-pointer-types \
-		-O2 -target bpf -c $< -o $@
+		 -Wno-compare-distinct-pointer-types          \
+		 -O2 -target bpf -emit-llvm -c $< -o - |      \
+	$(LLC) -march=bpf -mcpu=$(CPU) -filetype=obj -o $@
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index 4875395..a56053d 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -62,6 +62,8 @@ static unsigned long long (*bpf_get_prandom_u32)(void) =
 	(void *) BPF_FUNC_get_prandom_u32;
 static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
 	(void *) BPF_FUNC_xdp_adjust_head;
+static int (*bpf_xdp_adjust_meta)(void *ctx, int offset) =
+	(void *) BPF_FUNC_xdp_adjust_meta;
 static int (*bpf_setsockopt)(void *ctx, int level, int optname, void *optval,
 			     int optlen) =
 	(void *) BPF_FUNC_setsockopt;
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 26f3250..a042614 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -6645,6 +6645,253 @@ struct test_val {
 		.errstr = "BPF_END uses reserved fields",
 		.result = REJECT,
 	},
+	{
+		"meta access, test1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test2",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_SUB, BPF_REG_0, 8),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet, off=-8",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test3",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test4",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test5",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_4, 3),
+			BPF_MOV64_IMM(BPF_REG_2, -8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_xdp_adjust_meta),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R3 !read_ok",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test6",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_0, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test7",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test8",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xFFFF),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test9",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xFFFF),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test10",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_IMM(BPF_REG_5, 42),
+			BPF_MOV64_IMM(BPF_REG_6, 24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_5, -8),
+			BPF_STX_XADD(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_5, BPF_REG_10, -8),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_5, 100, 6),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_5),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_6, BPF_REG_5, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test11",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_MOV64_IMM(BPF_REG_5, 42),
+			BPF_MOV64_IMM(BPF_REG_6, 24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_5, -8),
+			BPF_STX_XADD(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_5, BPF_REG_10, -8),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_5, 100, 6),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_2, BPF_REG_5),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_6, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_5, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"meta access, test12",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data_meta)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 16),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_4, 5),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 0),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 16),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
diff --git a/tools/testing/selftests/bpf/test_xdp_meta.c b/tools/testing/selftests/bpf/test_xdp_meta.c
new file mode 100644
index 0000000..8d01826
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_xdp_meta.c
@@ -0,0 +1,53 @@
+#include <linux/bpf.h>
+#include <linux/if_ether.h>
+#include <linux/pkt_cls.h>
+
+#include "bpf_helpers.h"
+
+#define __round_mask(x, y) ((__typeof__(x))((y) - 1))
+#define round_up(x, y) ((((x) - 1) | __round_mask(x, y)) + 1)
+#define ctx_ptr(ctx, mem) (void *)(unsigned long)ctx->mem
+
+SEC("t")
+int ing_cls(struct __sk_buff *ctx)
+{
+	__u8 *data, *data_meta, *data_end;
+	__u32 diff = 0;
+
+	data_meta = ctx_ptr(ctx, data_meta);
+	data_end  = ctx_ptr(ctx, data_end);
+	data      = ctx_ptr(ctx, data);
+
+	if (data + ETH_ALEN > data_end ||
+	    data_meta + round_up(ETH_ALEN, 4) > data)
+		return TC_ACT_SHOT;
+
+	diff |= ((__u32 *)data_meta)[0] ^ ((__u32 *)data)[0];
+	diff |= ((__u16 *)data_meta)[2] ^ ((__u16 *)data)[2];
+
+	return diff ? TC_ACT_SHOT : TC_ACT_OK;
+}
+
+SEC("x")
+int ing_xdp(struct xdp_md *ctx)
+{
+	__u8 *data, *data_meta, *data_end;
+	int ret;
+
+	ret = bpf_xdp_adjust_meta(ctx, -round_up(ETH_ALEN, 4));
+	if (ret < 0)
+		return XDP_DROP;
+
+	data_meta = ctx_ptr(ctx, data_meta);
+	data_end  = ctx_ptr(ctx, data_end);
+	data      = ctx_ptr(ctx, data);
+
+	if (data + ETH_ALEN > data_end ||
+	    data_meta + round_up(ETH_ALEN, 4) > data)
+		return XDP_DROP;
+
+	__builtin_memcpy(data_meta, data, ETH_ALEN);
+	return XDP_PASS;
+}
+
+char _license[] SEC("license") = "GPL";
diff --git a/tools/testing/selftests/bpf/test_xdp_meta.sh b/tools/testing/selftests/bpf/test_xdp_meta.sh
new file mode 100755
index 0000000..307aa85
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_xdp_meta.sh
@@ -0,0 +1,51 @@
+#!/bin/sh
+
+cleanup()
+{
+	if [ "$?" = "0" ]; then
+		echo "selftests: test_xdp_meta [PASS]";
+	else
+		echo "selftests: test_xdp_meta [FAILED]";
+	fi
+
+	set +e
+	ip netns del ns1 2> /dev/null
+	ip netns del ns2 2> /dev/null
+}
+
+ip link set dev lo xdp off 2>/dev/null > /dev/null
+if [ $? -ne 0 ];then
+	echo "selftests: [SKIP] Could not run test without the ip xdp support"
+	exit 0
+fi
+set -e
+
+ip netns add ns1
+ip netns add ns2
+
+trap cleanup 0 2 3 6 9
+
+ip link add veth1 type veth peer name veth2
+
+ip link set veth1 netns ns1
+ip link set veth2 netns ns2
+
+ip netns exec ns1 ip addr add 10.1.1.11/24 dev veth1
+ip netns exec ns2 ip addr add 10.1.1.22/24 dev veth2
+
+ip netns exec ns1 tc qdisc add dev veth1 clsact
+ip netns exec ns2 tc qdisc add dev veth2 clsact
+
+ip netns exec ns1 tc filter add dev veth1 ingress bpf da obj test_xdp_meta.o sec t
+ip netns exec ns2 tc filter add dev veth2 ingress bpf da obj test_xdp_meta.o sec t
+
+ip netns exec ns1 ip link set dev veth1 xdp obj test_xdp_meta.o sec x
+ip netns exec ns2 ip link set dev veth2 xdp obj test_xdp_meta.o sec x
+
+ip netns exec ns1 ip link set dev veth1 up
+ip netns exec ns2 ip link set dev veth2 up
+
+ip netns exec ns1 ping -c 1 10.1.1.22
+ip netns exec ns2 ping -c 1 10.1.1.11
+
+exit 0
-- 
1.9.3
