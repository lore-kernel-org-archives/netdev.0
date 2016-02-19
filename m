From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] bpf: grab rcu read lock for bpf_percpu_hash_update
Date: Thu, 18 Feb 2016 21:56:22 -0500
Message-ID: <1455850582-9490-1-git-send-email-sasha.levin@oracle.com>
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
 kernel/bpf/syscall.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c95a753..94324b8 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -348,7 +348,9 @@ static int map_update_elem(union bpf_attr *attr)
 		goto free_value;
 
 	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH) {
+		rcu_read_lock();
 		err = bpf_percpu_hash_update(map, key, value, attr->flags);
+		rcu_read_unlock();
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
 		err = bpf_percpu_array_update(map, key, value, attr->flags);
 	} else {
-- 
1.7.10.4
