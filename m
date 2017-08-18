From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: inline map in map lookup functions for array and htab
Date: Sat, 19 Aug 2017 01:51:56 +0200
Message-ID: <501683f73390c81a7abaa0683f3675860a79adc7.1503100047.git.daniel@iogearbox.net>
References: <cover.1503100047.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48206 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdHRXwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:52:03 -0400
In-Reply-To: <cover.1503100047.git.daniel@iogearbox.net>
In-Reply-To: <cover.1503100047.git.daniel@iogearbox.net>
References: <cover.1503100047.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two successive functions calls for the map in map lookup, first
is the bpf_map_lookup_elem() helper call, and second the callback via
map->ops->map_lookup_elem() to get to the map in map implementation.
Implementation inlines array and htab flavor for map in map lookups.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/arraymap.c | 26 ++++++++++++++++++++++++++
 kernel/bpf/hashtab.c  | 17 +++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index d771a38..b25d6ce 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -603,6 +603,31 @@ static void *array_of_map_lookup_elem(struct bpf_map *map, void *key)
 	return READ_ONCE(*inner_map);
 }
 
+static u32 array_of_map_gen_lookup(struct bpf_map *map,
+				   struct bpf_insn *insn_buf)
+{
+	u32 elem_size = round_up(map->value_size, 8);
+	struct bpf_insn *insn = insn_buf;
+	const int ret = BPF_REG_0;
+	const int map_ptr = BPF_REG_1;
+	const int index = BPF_REG_2;
+
+	*insn++ = BPF_ALU64_IMM(BPF_ADD, map_ptr, offsetof(struct bpf_array, value));
+	*insn++ = BPF_LDX_MEM(BPF_W, ret, index, 0);
+	*insn++ = BPF_JMP_IMM(BPF_JGE, ret, map->max_entries, 5);
+	if (is_power_of_2(elem_size))
+		*insn++ = BPF_ALU64_IMM(BPF_LSH, ret, ilog2(elem_size));
+	else
+		*insn++ = BPF_ALU64_IMM(BPF_MUL, ret, elem_size);
+	*insn++ = BPF_ALU64_REG(BPF_ADD, ret, map_ptr);
+	*insn++ = BPF_LDX_MEM(BPF_DW, ret, ret, 0);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 1);
+	*insn++ = BPF_JMP_IMM(BPF_JA, 0, 0, 1);
+	*insn++ = BPF_MOV64_IMM(ret, 0);
+
+	return insn - insn_buf;
+}
+
 const struct bpf_map_ops array_of_maps_map_ops = {
 	.map_alloc = array_of_map_alloc,
 	.map_free = array_of_map_free,
@@ -612,4 +637,5 @@ static void *array_of_map_lookup_elem(struct bpf_map *map, void *key)
 	.map_fd_get_ptr = bpf_map_fd_get_ptr,
 	.map_fd_put_ptr = bpf_map_fd_put_ptr,
 	.map_fd_sys_lookup_elem = bpf_map_fd_sys_lookup_elem,
+	.map_gen_lookup = array_of_map_gen_lookup,
 };
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index cabf37b..750261d 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -1317,6 +1317,22 @@ static void *htab_of_map_lookup_elem(struct bpf_map *map, void *key)
 	return READ_ONCE(*inner_map);
 }
 
+static u32 htab_of_map_gen_lookup(struct bpf_map *map,
+				  struct bpf_insn *insn_buf)
+{
+	struct bpf_insn *insn = insn_buf;
+	const int ret = BPF_REG_0;
+
+	*insn++ = BPF_EMIT_CALL(bpf_htab_lookup_helper);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 2);
+	*insn++ = BPF_ALU64_IMM(BPF_ADD, ret,
+				offsetof(struct htab_elem, key) +
+				round_up(map->key_size, 8));
+	*insn++ = BPF_LDX_MEM(BPF_DW, ret, ret, 0);
+
+	return insn - insn_buf;
+}
+
 static void htab_of_map_free(struct bpf_map *map)
 {
 	bpf_map_meta_free(map->inner_map_meta);
@@ -1332,4 +1348,5 @@ static void htab_of_map_free(struct bpf_map *map)
 	.map_fd_get_ptr = bpf_map_fd_get_ptr,
 	.map_fd_put_ptr = bpf_map_fd_put_ptr,
 	.map_fd_sys_lookup_elem = bpf_map_fd_sys_lookup_elem,
+	.map_gen_lookup = htab_of_map_gen_lookup,
 };
-- 
1.9.3
