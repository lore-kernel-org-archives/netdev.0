From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v2] bpf: grab rcu read lock for bpf_percpu_hash_update
Date: Fri, 19 Feb 2016 13:53:10 -0500
Message-ID: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Sasha Levin <sasha.levin@oracle.com>
To: ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_percpu_hash_update() expects rcu lock to be held and warns if it's not,
which pointed out a missing rcu read lock.

Fixes: 15a07b338 ("bpf: add lookup/update support for per-cpu hash and array maps")
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 kernel/bpf/hashtab.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index fd5db8f..a68e951 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -619,7 +619,13 @@ out:
 int bpf_percpu_hash_update(struct bpf_map *map, void *key, void *value,
 			   u64 map_flags)
 {
-	return __htab_percpu_map_update_elem(map, key, value, map_flags, true);
+	int ret;
+
+	rcu_read_lock();
+	ret = __htab_percpu_map_update_elem(map, key, value, map_flags, true);
+	rcu_read_unlock();
+
+	return ret;
 }
 
 static const struct bpf_map_ops htab_percpu_ops = {
-- 
1.7.10.4
