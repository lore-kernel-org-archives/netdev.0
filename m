From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix htab map destruction when extra reserve is in use
Date: Fri,  4 Nov 2016 00:01:19 +0100
Message-ID: <e8a8cc8011d16169eaf604b78583836ab2246f0e.1478213579.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org, dvyukov@google.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44658 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933190AbcKCXBv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:01:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a6ed3ea65d98 ("bpf: restore behavior of bpf_map_update_elem")
added an extra per-cpu reserve to the hash table map to restore old
behaviour from pre prealloc times. When non-prealloc is in use for a
map, then problem is that once a hash table extra element has been
linked into the hash-table, and the hash table is destroyed due to
refcount dropping to zero, then htab_map_free() -> delete_all_elements()
will walk the whole hash table and drop all elements via htab_elem_free().
The problem is that the element from the extra reserve is first fed
to the wrong backend allocator and eventually freed twice.

Fixes: a6ed3ea65d98 ("bpf: restore behavior of bpf_map_update_elem")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/hashtab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 570eeca..ad1bc67 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -687,7 +687,8 @@ static void delete_all_elements(struct bpf_htab *htab)
 
 		hlist_for_each_entry_safe(l, n, head, hash_node) {
 			hlist_del_rcu(&l->hash_node);
-			htab_elem_free(htab, l);
+			if (l->state != HTAB_EXTRA_ELEM_USED)
+				htab_elem_free(htab, l);
 		}
 	}
 }
-- 
1.9.3
