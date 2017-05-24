From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 4/5] bpf: fix wrong exposure of map_flags into fdinfo for lpm
Date: Thu, 25 May 2017 01:05:08 +0200
Message-ID: <8f0acdc7d80d3c3247ac82945ae6d51ad67960de.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40347 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033610AbdEXXFl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 19:05:41 -0400
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

trie_alloc() always needs to have BPF_F_NO_PREALLOC passed in via
attr->map_flags, since it does not support preallocation yet. We
check the flag, but we never copy the flag into trie->map.map_flags,
which is later on exposed into fdinfo and used by loaders such as
iproute2. Latter uses this in bpf_map_selfcheck_pinned() to test
whether a pinned map has the same spec as the one from the BPF obj
file and if not, bails out, which is currently the case for lpm
since it exposes always 0 as flags.

Also copy over flags in array_map_alloc() and stack_map_alloc().
They always have to be 0 right now, but we should make sure to not
miss to copy them over at a later point in time when we add actual
flags for them to use.

Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
Reported-by: Jarno Rajahalme <jarno@covalent.io>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/arraymap.c | 1 +
 kernel/bpf/lpm_trie.c | 1 +
 kernel/bpf/stackmap.c | 1 +
 3 files changed, 3 insertions(+)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 5e00b23..172dc8e 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -86,6 +86,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	array->map.key_size = attr->key_size;
 	array->map.value_size = attr->value_size;
 	array->map.max_entries = attr->max_entries;
+	array->map.map_flags = attr->map_flags;
 	array->elem_size = elem_size;
 
 	if (!percpu)
diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 39cfafd..b09185f 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -432,6 +432,7 @@ static struct bpf_map *trie_alloc(union bpf_attr *attr)
 	trie->map.key_size = attr->key_size;
 	trie->map.value_size = attr->value_size;
 	trie->map.max_entries = attr->max_entries;
+	trie->map.map_flags = attr->map_flags;
 	trie->data_size = attr->key_size -
 			  offsetof(struct bpf_lpm_trie_key, data);
 	trie->max_prefixlen = trie->data_size * 8;
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 4dfd6f2..31147d7 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -88,6 +88,7 @@ static struct bpf_map *stack_map_alloc(union bpf_attr *attr)
 	smap->map.key_size = attr->key_size;
 	smap->map.value_size = value_size;
 	smap->map.max_entries = attr->max_entries;
+	smap->map.map_flags = attr->map_flags;
 	smap->n_buckets = n_buckets;
 	smap->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
 
-- 
1.9.3
