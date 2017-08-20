From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: fix double free from dev_map_notification()
Date: Mon, 21 Aug 2017 01:48:12 +0200
Message-ID: <22ff5f74079470a06e11940f40e05b2db74ca21f.1503272633.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52150 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753394AbdHTXsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 19:48:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current code, dev_map_free() can still race with dev_map_notification().
In dev_map_free(), we remove dtab from the list of dtabs after we purged
all entries from it. However, we don't do xchg() with NULL or the like,
so the entry at that point is still pointing to the device. If a unregister
notification comes in at the same time, we therefore risk a double-free,
since the pointer is still present in the map, and then pushed again to
__dev_map_entry_free().

All this is completely unnecessary. Just remove the dtab from the list
right before the synchronize_rcu(), so all outstanding readers from the
notifier list have finished by then, thus we don't need to deal with this
corner case anymore and also wouldn't need to nullify dev entires. This is
fine because we iterate over the map releasing all entries and therefore
dev references anyway.

Fixes: 4cc7b9544b9a ("bpf: devmap fix mutex in rcu critical section")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/devmap.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 67f4f00..fa08181 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -148,6 +148,11 @@ static void dev_map_free(struct bpf_map *map)
 	 * no further reads against netdev_map. It does __not__ ensure pending
 	 * flush operations (if any) are complete.
 	 */
+
+	spin_lock(&dev_map_lock);
+	list_del_rcu(&dtab->list);
+	spin_unlock(&dev_map_lock);
+
 	synchronize_rcu();
 
 	/* To ensure all pending flush operations have completed wait for flush
@@ -162,10 +167,6 @@ static void dev_map_free(struct bpf_map *map)
 			cpu_relax();
 	}
 
-	/* Although we should no longer have datapath or bpf syscall operations
-	 * at this point we we can still race with netdev notifier, hence the
-	 * lock.
-	 */
 	for (i = 0; i < dtab->map.max_entries; i++) {
 		struct bpf_dtab_netdev *dev;
 
@@ -180,9 +181,6 @@ static void dev_map_free(struct bpf_map *map)
 	/* At this point bpf program is detached and all pending operations
 	 * _must_ be complete
 	 */
-	spin_lock(&dev_map_lock);
-	list_del_rcu(&dtab->list);
-	spin_unlock(&dev_map_lock);
 	free_percpu(dtab->flush_needed);
 	bpf_map_area_free(dtab->netdev_map);
 	kfree(dtab);
-- 
1.9.3
