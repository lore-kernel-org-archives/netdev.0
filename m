From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/6] bpf: perf_event progs should only use preallocated maps
Date: Fri, 26 Aug 2016 19:31:21 -0700
Message-ID: <1472265084-1767670-4-git-send-email-ast@fb.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure that BPF_PROG_TYPE_PERF_EVENT programs only use
preallocated hash maps, since doing memory allocation
in overflow_handler can crash depending on where nmi got triggered.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c1c9e441f0f5..48c2705db22c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2511,6 +2511,20 @@ process_bpf_exit:
 	return 0;
 }
 
+static int check_map_prog_compatibility(struct bpf_map *map,
+					struct bpf_prog *prog)
+
+{
+	if (prog->type == BPF_PROG_TYPE_PERF_EVENT &&
+	    (map->map_type == BPF_MAP_TYPE_HASH ||
+	     map->map_type == BPF_MAP_TYPE_PERCPU_HASH) &&
+	    (map->map_flags & BPF_F_NO_PREALLOC)) {
+		verbose("perf_event programs can only use preallocated hash map\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
 /* look for pseudo eBPF instructions that access map FDs and
  * replace them with actual map pointers
  */
@@ -2518,7 +2532,7 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 {
 	struct bpf_insn *insn = env->prog->insnsi;
 	int insn_cnt = env->prog->len;
-	int i, j;
+	int i, j, err;
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		if (BPF_CLASS(insn->code) == BPF_LDX &&
@@ -2562,6 +2576,12 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 				return PTR_ERR(map);
 			}
 
+			err = check_map_prog_compatibility(map, env->prog);
+			if (err) {
+				fdput(f);
+				return err;
+			}
+
 			/* store map pointer inside BPF_LD_IMM64 instruction */
 			insn[0].imm = (u32) (unsigned long) map;
 			insn[1].imm = ((u64) (unsigned long) map) >> 32;
-- 
2.8.0
