From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/6] bpf: inline htab_map_lookup_elem()
Date: Wed, 15 Mar 2017 18:26:43 -0700
Message-ID: <1489627604-2288703-6-git-send-email-ast@fb.com>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33882 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750868AbdCPB2e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:28:34 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2G1PPh4030019
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:27:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 297cyx13x1-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:27:05 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 9dd4327209e711e78dc20002c99293a0-f20da9a0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Optimize:
bpf_call
  bpf_map_lookup_elem
    map->ops->map_lookup_elem
      htab_map_lookup_elem
        __htab_map_lookup_elem
into:
bpf_call
  __htab_map_lookup_elem

to improve performance of JITed programs.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/hashtab.c | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index afe5bab376c9..000153acb6d5 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -419,7 +419,11 @@ static struct htab_elem *lookup_nulls_elem_raw(struct hlist_nulls_head *head,
 	return NULL;
 }
 
-/* Called from syscall or from eBPF program */
+/* Called from syscall or from eBPF program directly, so
+ * arguments have to match bpf_map_lookup_elem() exactly.
+ * The return value is adjusted by BPF instructions
+ * in htab_map_gen_lookup().
+ */
 static void *__htab_map_lookup_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
@@ -451,6 +455,30 @@ static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
 	return NULL;
 }
 
+/* inline bpf_map_lookup_elem() call.
+ * Instead of:
+ * bpf_prog
+ *   bpf_map_lookup_elem
+ *     map->ops->map_lookup_elem
+ *       htab_map_lookup_elem
+ *         __htab_map_lookup_elem
+ * do:
+ * bpf_prog
+ *   __htab_map_lookup_elem
+ */
+static u32 htab_map_gen_lookup(struct bpf_map *map, struct bpf_insn *insn_buf)
+{
+	struct bpf_insn *insn = insn_buf;
+	const int ret = BPF_REG_0;
+
+	*insn++ = BPF_EMIT_CALL((u64 (*)(u64, u64, u64, u64, u64))__htab_map_lookup_elem);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 1);
+	*insn++ = BPF_ALU64_IMM(BPF_ADD, ret,
+				offsetof(struct htab_elem, key) +
+				round_up(map->key_size, 8));
+	return insn - insn_buf;
+}
+
 static void *htab_lru_map_lookup_elem(struct bpf_map *map, void *key)
 {
 	struct htab_elem *l = __htab_map_lookup_elem(map, key);
@@ -1062,6 +1090,7 @@ static const struct bpf_map_ops htab_ops = {
 	.map_lookup_elem = htab_map_lookup_elem,
 	.map_update_elem = htab_map_update_elem,
 	.map_delete_elem = htab_map_delete_elem,
+	.map_gen_lookup = htab_map_gen_lookup,
 };
 
 static struct bpf_map_type_list htab_type __ro_after_init = {
-- 
2.8.0
