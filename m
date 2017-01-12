From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: allow b/h/w/dw access for bpf's cb in ctx
Date: Thu, 12 Jan 2017 02:21:33 +0100
Message-ID: <fff467f83e48c6c15053a7637893bf247c9be102.1484182858.git.daniel@iogearbox.net>
References: <cover.1484182858.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45786 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935899AbdALBqR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 20:46:17 -0500
In-Reply-To: <cover.1484182858.git.daniel@iogearbox.net>
In-Reply-To: <cover.1484182858.git.daniel@iogearbox.net>
References: <cover.1484182858.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When structs are used to store temporary state in cb[] buffer that is
used with programs and among tail calls, then the generated code will
not always access the buffer in bpf_w chunks. We can ease programming
of it and let this act more natural by allowing for aligned b/h/w/dw
sized access for cb[] ctx member. Various test cases are attached as
well for the selftest suite. Potentially, this can also be reused for
other program types to pass data around.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       |   8 +-
 net/core/filter.c                           |  41 ++-
 tools/testing/selftests/bpf/test_verifier.c | 442 +++++++++++++++++++++++++++-
 3 files changed, 478 insertions(+), 13 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index df7e472..d60e12c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3165,10 +3165,14 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 	insn = env->prog->insnsi + delta;
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
-		if (insn->code == (BPF_LDX | BPF_MEM | BPF_W) ||
+		if (insn->code == (BPF_LDX | BPF_MEM | BPF_B) ||
+		    insn->code == (BPF_LDX | BPF_MEM | BPF_H) ||
+		    insn->code == (BPF_LDX | BPF_MEM | BPF_W) ||
 		    insn->code == (BPF_LDX | BPF_MEM | BPF_DW))
 			type = BPF_READ;
-		else if (insn->code == (BPF_STX | BPF_MEM | BPF_W) ||
+		else if (insn->code == (BPF_STX | BPF_MEM | BPF_B) ||
+			 insn->code == (BPF_STX | BPF_MEM | BPF_H) ||
+			 insn->code == (BPF_STX | BPF_MEM | BPF_W) ||
 			 insn->code == (BPF_STX | BPF_MEM | BPF_DW))
 			type = BPF_WRITE;
 		else
diff --git a/net/core/filter.c b/net/core/filter.c
index 8cfbdef..9038386 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2776,11 +2776,33 @@ static bool __is_valid_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
 		return false;
+
 	/* The verifier guarantees that size > 0. */
 	if (off % size != 0)
 		return false;
-	if (size != sizeof(__u32))
-		return false;
+
+	switch (off) {
+	case offsetof(struct __sk_buff, cb[0]) ...
+	     offsetof(struct __sk_buff, cb[4]) + sizeof(__u32) - 1:
+		if (size == sizeof(__u16) &&
+		    off > offsetof(struct __sk_buff, cb[4]) + sizeof(__u16))
+			return false;
+		if (size == sizeof(__u32) &&
+		    off > offsetof(struct __sk_buff, cb[4]))
+			return false;
+		if (size == sizeof(__u64) &&
+		    off > offsetof(struct __sk_buff, cb[2]))
+			return false;
+		if (size != sizeof(__u8)  &&
+		    size != sizeof(__u16) &&
+		    size != sizeof(__u32) &&
+		    size != sizeof(__u64))
+			return false;
+		break;
+	default:
+		if (size != sizeof(__u32))
+			return false;
+	}
 
 	return true;
 }
@@ -2799,7 +2821,7 @@ static bool sk_filter_is_valid_access(int off, int size,
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case offsetof(struct __sk_buff, cb[0]) ...
-		     offsetof(struct __sk_buff, cb[4]):
+		     offsetof(struct __sk_buff, cb[4]) + sizeof(__u32) - 1:
 			break;
 		default:
 			return false;
@@ -2823,7 +2845,7 @@ static bool lwt_is_valid_access(int off, int size,
 		case offsetof(struct __sk_buff, mark):
 		case offsetof(struct __sk_buff, priority):
 		case offsetof(struct __sk_buff, cb[0]) ...
-		     offsetof(struct __sk_buff, cb[4]):
+		     offsetof(struct __sk_buff, cb[4]) + sizeof(__u32) - 1:
 			break;
 		default:
 			return false;
@@ -2915,7 +2937,7 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 		case offsetof(struct __sk_buff, tc_index):
 		case offsetof(struct __sk_buff, priority):
 		case offsetof(struct __sk_buff, cb[0]) ...
-		     offsetof(struct __sk_buff, cb[4]):
+		     offsetof(struct __sk_buff, cb[4]) + sizeof(__u32) - 1:
 		case offsetof(struct __sk_buff, tc_classid):
 			break;
 		default:
@@ -3066,8 +3088,11 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type,
 					  si->dst_reg, si->src_reg, insn);
 
 	case offsetof(struct __sk_buff, cb[0]) ...
-	     offsetof(struct __sk_buff, cb[4]):
+	     offsetof(struct __sk_buff, cb[4]) + sizeof(__u32) - 1:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct qdisc_skb_cb, data) < 20);
+		BUILD_BUG_ON((offsetof(struct sk_buff, cb) +
+			      offsetof(struct qdisc_skb_cb, data)) %
+			     sizeof(__u64));
 
 		prog->cb_access = 1;
 		off  = si->off;
@@ -3075,10 +3100,10 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type,
 		off += offsetof(struct sk_buff, cb);
 		off += offsetof(struct qdisc_skb_cb, data);
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg,
+			*insn++ = BPF_STX_MEM(BPF_SIZE(si->code), si->dst_reg,
 					      si->src_reg, off);
 		else
-			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg,
+			*insn++ = BPF_LDX_MEM(BPF_SIZE(si->code), si->dst_reg,
 					      si->src_reg, off);
 		break;
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 9bb4534..f664bed 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -859,15 +859,451 @@ struct test_val {
 		.result = REJECT,
 	},
 	{
-		"check non-u32 access to cb",
+		"check cb access: byte",
 		.insns = {
-			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_1,
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) + 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) + 2),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) + 3),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1]) + 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1]) + 2),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1]) + 3),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2]) + 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2]) + 2),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2]) + 3),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3]) + 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3]) + 2),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3]) + 3),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 2),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) + 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) + 2),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) + 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1]) + 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1]) + 2),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1]) + 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2]) + 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2]) + 2),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2]) + 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3]) + 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3]) + 2),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3]) + 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 2),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 3),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check cb access: byte, oob 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: byte, oob 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) - 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: byte, oob 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: byte, oob 4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) - 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: byte, wrong type",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"check cb access: half",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) + 2),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1]) + 2),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2]) + 2),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3]) + 2),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 2),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) + 2),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1]) + 2),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2]) + 2),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3]) + 2),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 2),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check cb access: half, unaligned",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) + 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: half, oob 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: half, oob 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) - 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: half, oob 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: half, oob 4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) - 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: half, wrong type",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"check cb access: word",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check cb access: word, unaligned 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) + 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: word, unaligned 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: word, unaligned 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: word, unaligned 4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check cb access: double, unaligned 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[1])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, unaligned 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, oob 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, oob 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[4]) + 8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, oob 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0]) - 8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, oob 4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: doulbe, oob 5",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4]) + 8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, oob 6",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) - 8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check cb access: double, wrong type",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
 				    offsetof(struct __sk_buff, cb[0])),
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid bpf_context access",
-		.errstr_unpriv = "R1 leaks addr",
 		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
 	},
 	{
 		"check out of range skb->cb access",
-- 
1.9.3
