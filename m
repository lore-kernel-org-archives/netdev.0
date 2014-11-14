From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 7/7] bpf: remove test map scaffolding and user proper types
Date: Thu, 13 Nov 2014 17:36:50 -0800
Message-ID: <1415929010-9361-8-git-send-email-ast@plumgrid.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

proper types and function helpers are ready. Use them in verifier testsuite.
Remove temporary stubs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/test_stub.c      |   56 +++++++------------------------------------
 samples/bpf/test_verifier.c |   14 +++++------
 2 files changed, 16 insertions(+), 54 deletions(-)

diff --git a/kernel/bpf/test_stub.c b/kernel/bpf/test_stub.c
index fcaddff4003e..0ceae1e6e8b5 100644
--- a/kernel/bpf/test_stub.c
+++ b/kernel/bpf/test_stub.c
@@ -18,26 +18,18 @@ struct bpf_context {
 	u64 arg2;
 };
 
-static u64 test_func(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
-{
-	return 0;
-}
-
-static struct bpf_func_proto test_funcs[] = {
-	[BPF_FUNC_unspec] = {
-		.func = test_func,
-		.gpl_only = true,
-		.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
-		.arg1_type = ARG_CONST_MAP_PTR,
-		.arg2_type = ARG_PTR_TO_MAP_KEY,
-	},
-};
-
 static const struct bpf_func_proto *test_func_proto(enum bpf_func_id func_id)
 {
-	if (func_id < 0 || func_id >= ARRAY_SIZE(test_funcs))
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	default:
 		return NULL;
-	return &test_funcs[func_id];
+	}
 }
 
 static const struct bpf_context_access {
@@ -78,38 +70,8 @@ static struct bpf_prog_type_list tl_prog = {
 	.type = BPF_PROG_TYPE_UNSPEC,
 };
 
-static struct bpf_map *test_map_alloc(union bpf_attr *attr)
-{
-	struct bpf_map *map;
-
-	map = kzalloc(sizeof(*map), GFP_USER);
-	if (!map)
-		return ERR_PTR(-ENOMEM);
-
-	map->key_size = attr->key_size;
-	map->value_size = attr->value_size;
-	map->max_entries = attr->max_entries;
-	return map;
-}
-
-static void test_map_free(struct bpf_map *map)
-{
-	kfree(map);
-}
-
-static struct bpf_map_ops test_map_ops = {
-	.map_alloc = test_map_alloc,
-	.map_free = test_map_free,
-};
-
-static struct bpf_map_type_list tl_map = {
-	.ops = &test_map_ops,
-	.type = BPF_MAP_TYPE_UNSPEC,
-};
-
 static int __init register_test_ops(void)
 {
-	bpf_register_map_type(&tl_map);
 	bpf_register_prog_type(&tl_prog);
 	return 0;
 }
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 63402742345e..b96175e90363 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -261,7 +261,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
 			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
 			BPF_EXIT_INSN(),
 		},
 		.fixup = {2},
@@ -417,7 +417,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
 			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_delete_elem),
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "fd 0 is not pointing to valid bpf_map",
@@ -430,7 +430,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
 			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
 			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
 			BPF_EXIT_INSN(),
 		},
@@ -445,7 +445,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
 			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
 			BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
 			BPF_EXIT_INSN(),
@@ -461,7 +461,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
 			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
 			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
 			BPF_EXIT_INSN(),
@@ -548,7 +548,7 @@ static struct bpf_test tests[] = {
 			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -56),
 			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_delete_elem),
 			BPF_EXIT_INSN(),
 		},
 		.fixup = {24},
@@ -659,7 +659,7 @@ static int create_map(void)
 	long long key, value = 0;
 	int map_fd;
 
-	map_fd = bpf_create_map(BPF_MAP_TYPE_UNSPEC, sizeof(key), sizeof(value), 1024);
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 1024);
 	if (map_fd < 0) {
 		printf("failed to create map '%s'\n", strerror(errno));
 	}
-- 
1.7.9.5
