From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] bpf: fix bpf_tail_call() x64 JIT
Date: Tue, 3 Oct 2017 15:37:20 -0700
Message-ID: <20171003223720.1517246-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47552 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750865AbdJCWhx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:37:53 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v93MWtda001204
        for <netdev@vger.kernel.org>; Tue, 3 Oct 2017 15:37:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dcher8n8v-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 15:37:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- bpf prog_array just like all other types of bpf array accepts 32-bit index.
  Clarify that in the comment.
- fix x64 JIT of bpf_tail_call which was incorrectly loading 8 instead of 4 bytes
- tighten corresponding check in the interpreter to stay consistent

The JIT bug can be triggered after introduction of BPF_F_NUMA_NODE flag
in commit 96eabe7a40aa in 4.14. Before that the map_flags would stay zero and
though JIT code is wrong it will check bounds correctly.
Hence two fixes tags. All other JITs don't have this problem.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Fixes: 96eabe7a40aa ("bpf: Allow selecting numa node during map creation")
Fixes: b52f00e6a715 ("x86: bpf_jit: implement bpf_tail_call() helper")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
Backport to stable would be nice, but not strictly necessary.

 arch/x86/net/bpf_jit_comp.c | 4 ++--
 include/uapi/linux/bpf.h    | 2 +-
 kernel/bpf/core.c           | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 8c9573660d51..0554e8aef4d5 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -284,9 +284,9 @@ static void emit_bpf_tail_call(u8 **pprog)
 	/* if (index >= array->map.max_entries)
 	 *   goto out;
 	 */
-	EMIT4(0x48, 0x8B, 0x46,                   /* mov rax, qword ptr [rsi + 16] */
+	EMIT2(0x89, 0xD2);                        /* mov edx, edx */
+	EMIT3(0x39, 0x56,                         /* cmp dword ptr [rsi + 16], edx */
 	      offsetof(struct bpf_array, map.max_entries));
-	EMIT3(0x48, 0x39, 0xD0);                  /* cmp rax, rdx */
 #define OFFSET1 43 /* number of bytes to jump */
 	EMIT2(X86_JBE, OFFSET1);                  /* jbe out */
 	label1 = cnt;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 43ab5c402f98..f90860d1f897 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -312,7 +312,7 @@ union bpf_attr {
  *     jump into another BPF program
  *     @ctx: context pointer passed to next program
  *     @prog_array_map: pointer to map which type is BPF_MAP_TYPE_PROG_ARRAY
- *     @index: index inside array that selects specific program to run
+ *     @index: 32-bit index inside array that selects specific program to run
  *     Return: 0 on success or negative error
  *
  * int bpf_clone_redirect(skb, ifindex, flags)
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 917cc04a0a94..7b62df86be1d 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1022,7 +1022,7 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 		struct bpf_map *map = (struct bpf_map *) (unsigned long) BPF_R2;
 		struct bpf_array *array = container_of(map, struct bpf_array, map);
 		struct bpf_prog *prog;
-		u64 index = BPF_R3;
+		u32 index = BPF_R3;
 
 		if (unlikely(index >= array->map.max_entries))
 			goto out;
-- 
2.9.5
