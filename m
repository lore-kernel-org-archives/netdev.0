From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/3] bpf: Inline LRU map lookup
Date: Thu, 31 Aug 2017 23:27:12 -0700
Message-ID: <20170901062713.1842249-3-kafai@fb.com>
References: <20170901062713.1842249-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36474 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751022AbdIAG1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 02:27:15 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v816OnLO009163
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:27:14 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cq180r9r6-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 23:27:14 -0700
In-Reply-To: <20170901062713.1842249-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline the lru map lookup to save the cost in making calls to
bpf_map_lookup_elem() and htab_lru_map_lookup_elem().

Different LRU hash size is tested.  The benefit diminishes when
the cache miss starts to dominate in the bigger LRU hash.
Considering the change is simple, it is still worth to optimize.

First column: Size of the LRU hash
Second column: Number of lookups/s

Before:
> for i in $(seq 9 20); do echo "$((2**i+1)): $(./map_perf_test 1024 1 $((2**i+1)) 10000000 | awk '{print $3}')"; done
513: 1132020
1025: 1056826
2049: 1007024
4097: 853298
8193: 742723
16385: 712600
32769: 688142
65537: 677028
131073: 619437
262145: 498770
524289: 316695
1048577: 260038

After:
> for i in $(seq 9 20); do echo "$((2**i+1)): $(./map_perf_test 1024 1 $((2**i+1)) 10000000 | awk '{print $3}')"; done
513: 1221851
1025: 1144695
2049: 1049902
4097: 884460
8193: 773731
16385: 729673
32769: 721989
65537: 715530
131073: 671665
262145: 516987
524289: 321125
1048577: 260048

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/hashtab.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index d246905f2bb1..682f4543fefa 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -514,6 +514,24 @@ static void *htab_lru_map_lookup_elem(struct bpf_map *map, void *key)
 	return NULL;
 }
 
+static u32 htab_lru_map_gen_lookup(struct bpf_map *map,
+				   struct bpf_insn *insn_buf)
+{
+	struct bpf_insn *insn = insn_buf;
+	const int ret = BPF_REG_0;
+
+	*insn++ = BPF_EMIT_CALL((u64 (*)(u64, u64, u64, u64, u64))__htab_map_lookup_elem);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 2);
+	*insn++ = BPF_ST_MEM(BPF_B, ret,
+			     offsetof(struct htab_elem, lru_node) +
+			     offsetof(struct bpf_lru_node, ref),
+			     1);
+	*insn++ = BPF_ALU64_IMM(BPF_ADD, ret,
+				offsetof(struct htab_elem, key) +
+				round_up(map->key_size, 8));
+	return insn - insn_buf;
+}
+
 /* It is called from the bpf_lru_list when the LRU needs to delete
  * older elements from the htab.
  */
@@ -1137,6 +1155,7 @@ const struct bpf_map_ops htab_lru_map_ops = {
 	.map_lookup_elem = htab_lru_map_lookup_elem,
 	.map_update_elem = htab_lru_map_update_elem,
 	.map_delete_elem = htab_lru_map_delete_elem,
+	.map_gen_lookup = htab_lru_map_gen_lookup,
 };
 
 /* Called from eBPF program */
-- 
2.9.5
