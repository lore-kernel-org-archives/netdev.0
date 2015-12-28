From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH v1 1/3] bpf: hash: use atomic count
Date: Mon, 28 Dec 2015 20:55:24 +0800
Message-ID: <1451307326-12807-2-git-send-email-tom.leiming@gmail.com>
References: <1451307326-12807-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451307326-12807-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Preparing for removing global per-hashtable lock, so
the counter need to be defined as aotmic_t first.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/hashtab.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 34777b3..2615388 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -18,7 +18,7 @@ struct bpf_htab {
 	struct bpf_map map;
 	struct hlist_head *buckets;
 	raw_spinlock_t lock;
-	u32 count;	/* number of elements in this hashtable */
+	atomic_t count;	/* number of elements in this hashtable */
 	u32 n_buckets;	/* number of hash buckets */
 	u32 elem_size;	/* size of each element in bytes */
 };
@@ -106,7 +106,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		INIT_HLIST_HEAD(&htab->buckets[i]);
 
 	raw_spin_lock_init(&htab->lock);
-	htab->count = 0;
+	atomic_set(&htab->count, 0);
 
 	return &htab->map;
 
@@ -256,7 +256,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 
 	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
 
-	if (!l_old && unlikely(htab->count >= map->max_entries)) {
+	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
 		/* if elem with this 'key' doesn't exist and we've reached
 		 * max_entries limit, fail insertion of new elem
 		 */
@@ -284,7 +284,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 		hlist_del_rcu(&l_old->hash_node);
 		kfree_rcu(l_old, rcu);
 	} else {
-		htab->count++;
+		atomic_inc(&htab->count);
 	}
 	raw_spin_unlock_irqrestore(&htab->lock, flags);
 
@@ -319,7 +319,7 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 
 	if (l) {
 		hlist_del_rcu(&l->hash_node);
-		htab->count--;
+		atomic_dec(&htab->count);
 		kfree_rcu(l, rcu);
 		ret = 0;
 	}
@@ -339,7 +339,7 @@ static void delete_all_elements(struct bpf_htab *htab)
 
 		hlist_for_each_entry_safe(l, n, head, hash_node) {
 			hlist_del_rcu(&l->hash_node);
-			htab->count--;
+			atomic_dec(&htab->count);
 			kfree(l);
 		}
 	}
-- 
1.9.1
