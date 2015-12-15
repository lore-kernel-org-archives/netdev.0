From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 3/6] bpf: hash: move select_bucket() out of htab's spinlock
Date: Tue, 15 Dec 2015 19:21:01 +0800
Message-ID: <1450178464-27721-4-git-send-email-tom.leiming@gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spinlock is just used for protecting the per-bucket
hlist, so it isn't needed for selecting bucket.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 kernel/bpf/hashtab.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 2615388..d857fcb 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -248,12 +248,11 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	memcpy(l_new->key + round_up(key_size, 8), value, map->value_size);
 
 	l_new->hash = htab_map_hash(l_new->key, key_size);
+	head = select_bucket(htab, l_new->hash);
 
 	/* bpf_map_update_elem() can be called in_irq() */
 	raw_spin_lock_irqsave(&htab->lock, flags);
 
-	head = select_bucket(htab, l_new->hash);
-
 	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
 
 	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
@@ -310,11 +309,10 @@ static int htab_map_delete_elem(struct bpf_map *map, void *key)
 	key_size = map->key_size;
 
 	hash = htab_map_hash(key, key_size);
+	head = select_bucket(htab, hash);
 
 	raw_spin_lock_irqsave(&htab->lock, flags);
 
-	head = select_bucket(htab, hash);
-
 	l = lookup_elem_raw(head, hash, key, key_size);
 
 	if (l) {
-- 
1.9.1
