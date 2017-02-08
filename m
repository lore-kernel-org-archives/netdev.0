From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, lpm: fix overflows in trie_alloc checks
Date: Wed,  8 Feb 2017 01:19:43 +0100
Message-ID: <205e6ad77b5863daf0904e02f3cfc9a244e1ee47.1486513105.git.daniel@iogearbox.net>
Cc: ast@kernel.org, daniel@zonque.org, dh.herrmann@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34391 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932115AbdBHATy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 19:19:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cap the maximum (total) value size and bail out if larger than KMALLOC_MAX_SIZE
as otherwise it doesn't make any sense to proceed further, since we're
guaranteed to fail to allocate elements anyway in lpm_trie_node_alloc();
likleyhood of failure is still high for large values, though, similarly
as with htab case in non-prealloc.

Next, make sure that cost vars are really u64 instead of size_t, so that we
don't overflow on 32 bit and charge only tiny map.pages against memlock while
allowing huge max_entries; cap also the max cost like we do with other map
types.

Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/lpm_trie.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 144e976..e0f6a0b 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -394,10 +394,21 @@ static int trie_delete_elem(struct bpf_map *map, void *key)
 	return -ENOSYS;
 }
 
+#define LPM_DATA_SIZE_MAX	256
+#define LPM_DATA_SIZE_MIN	1
+
+#define LPM_VAL_SIZE_MAX	(KMALLOC_MAX_SIZE - LPM_DATA_SIZE_MAX - \
+				 sizeof(struct lpm_trie_node))
+#define LPM_VAL_SIZE_MIN	1
+
+#define LPM_KEY_SIZE(X)		(sizeof(struct bpf_lpm_trie_key) + (X))
+#define LPM_KEY_SIZE_MAX	LPM_KEY_SIZE(LPM_DATA_SIZE_MAX)
+#define LPM_KEY_SIZE_MIN	LPM_KEY_SIZE(LPM_DATA_SIZE_MIN)
+
 static struct bpf_map *trie_alloc(union bpf_attr *attr)
 {
-	size_t cost, cost_per_node;
 	struct lpm_trie *trie;
+	u64 cost = sizeof(*trie), cost_per_node;
 	int ret;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -406,9 +417,10 @@ static struct bpf_map *trie_alloc(union bpf_attr *attr)
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 ||
 	    attr->map_flags != BPF_F_NO_PREALLOC ||
-	    attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
-	    attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
-	    attr->value_size == 0)
+	    attr->key_size < LPM_KEY_SIZE_MIN ||
+	    attr->key_size > LPM_KEY_SIZE_MAX ||
+	    attr->value_size < LPM_VAL_SIZE_MIN ||
+	    attr->value_size > LPM_VAL_SIZE_MAX)
 		return ERR_PTR(-EINVAL);
 
 	trie = kzalloc(sizeof(*trie), GFP_USER | __GFP_NOWARN);
@@ -426,18 +438,24 @@ static struct bpf_map *trie_alloc(union bpf_attr *attr)
 
 	cost_per_node = sizeof(struct lpm_trie_node) +
 			attr->value_size + trie->data_size;
-	cost = sizeof(*trie) + attr->max_entries * cost_per_node;
+	cost += (u64) attr->max_entries * cost_per_node;
+	if (cost >= U32_MAX - PAGE_SIZE) {
+		ret = -E2BIG;
+		goto out_err;
+	}
+
 	trie->map.pages = round_up(cost, PAGE_SIZE) >> PAGE_SHIFT;
 
 	ret = bpf_map_precharge_memlock(trie->map.pages);
-	if (ret) {
-		kfree(trie);
-		return ERR_PTR(ret);
-	}
+	if (ret)
+		goto out_err;
 
 	raw_spin_lock_init(&trie->lock);
 
 	return &trie->map;
+out_err:
+	kfree(trie);
+	return ERR_PTR(ret);
 }
 
 static void trie_free(struct bpf_map *map)
-- 
1.9.3
