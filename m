From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 3/3] bpf: Only set node->ref = 1 if it has not been set
Date: Thu, 31 Aug 2017 23:27:13 -0700
Message-ID: <20170901062713.1842249-4-kafai@fb.com>
References: <20170901062713.1842249-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59520 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751022AbdIAG1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 02:27:17 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v816RHPD024820
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:27:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cq17wr9sy-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:27:17 -0700
In-Reply-To: <20170901062713.1842249-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch writes 'node->ref = 1' only if node->ref is 0.
The number of lookups/s for a ~1M entries LRU map increased by
~30% (260097 to 343313).

Other writes on 'node->ref = 0' is not changed.  In those cases, the
same cache line has to be changed anyway.

First column: Size of the LRU hash
Second column: Number of lookups/s

Before:
> echo "$((2**20+1)): $(./map_perf_test 1024 1 $((2**20+1)) 10000000 | awk '{print $3}')"
1048577: 260097

After:
> echo "$((2**20+1)): $(./map_perf_test 1024 1 $((2**20+1)) 10000000 | awk '{print $3}')"
1048577: 343313

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/bpf_lru_list.h | 3 ++-
 kernel/bpf/hashtab.c      | 7 ++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/bpf_lru_list.h b/kernel/bpf/bpf_lru_list.h
index 5c35a98d02bf..7d4f89b7cb84 100644
--- a/kernel/bpf/bpf_lru_list.h
+++ b/kernel/bpf/bpf_lru_list.h
@@ -69,7 +69,8 @@ static inline void bpf_lru_node_set_ref(struct bpf_lru_node *node)
 	/* ref is an approximation on access frequency.  It does not
 	 * have to be very accurate.  Hence, no protection is used.
 	 */
-	node->ref = 1;
+	if (!node->ref)
+		node->ref = 1;
 }
 
 int bpf_lru_init(struct bpf_lru *lru, bool percpu, u32 hash_offset,
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 682f4543fefa..431126f31ea3 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -519,9 +519,14 @@ static u32 htab_lru_map_gen_lookup(struct bpf_map *map,
 {
 	struct bpf_insn *insn = insn_buf;
 	const int ret = BPF_REG_0;
+	const int ref_reg = BPF_REG_1;
 
 	*insn++ = BPF_EMIT_CALL((u64 (*)(u64, u64, u64, u64, u64))__htab_map_lookup_elem);
-	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 2);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 4);
+	*insn++ = BPF_LDX_MEM(BPF_B, ref_reg, ret,
+			      offsetof(struct htab_elem, lru_node) +
+			      offsetof(struct bpf_lru_node, ref));
+	*insn++ = BPF_JMP_IMM(BPF_JNE, ref_reg, 0, 1);
 	*insn++ = BPF_ST_MEM(BPF_B, ret,
 			     offsetof(struct htab_elem, lru_node) +
 			     offsetof(struct bpf_lru_node, ref),
-- 
2.9.5
