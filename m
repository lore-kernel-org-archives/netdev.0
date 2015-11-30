From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: [PATCH net] bpf: fix allocation warnings in bpf maps and integer
 overflow
Date: Sun, 29 Nov 2015 16:59:35 -0800
Message-ID: <20151130005934.GA95228@ast-mbp.thefacebook.com>
References: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Sasha Levin <sasha.levin@oracle.com>, daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33404 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbK3A7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 19:59:42 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+b1k7Ofvn6xa=qWv9xP6BbteWOnZsJMXLZ=GOby-ajF=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@kernel.org>

For large map->value_size the user space can trigger memory allocation warnings like:
WARNING: CPU: 2 PID: 11122 at mm/page_alloc.c:2989
__alloc_pages_nodemask+0x695/0x14e0()
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82743b56>] dump_stack+0x68/0x92 lib/dump_stack.c:50
 [<ffffffff81244ec9>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:460
 [<ffffffff812450f9>] warn_slowpath_null+0x29/0x30 kernel/panic.c:493
 [<     inline     >] __alloc_pages_slowpath mm/page_alloc.c:2989
 [<ffffffff81554e95>] __alloc_pages_nodemask+0x695/0x14e0 mm/page_alloc.c:3235
 [<ffffffff816188fe>] alloc_pages_current+0xee/0x340 mm/mempolicy.c:2055
 [<     inline     >] alloc_pages include/linux/gfp.h:451
 [<ffffffff81550706>] alloc_kmem_pages+0x16/0xf0 mm/page_alloc.c:3414
 [<ffffffff815a1c89>] kmalloc_order+0x19/0x60 mm/slab_common.c:1007
 [<ffffffff815a1cef>] kmalloc_order_trace+0x1f/0xa0 mm/slab_common.c:1018
 [<     inline     >] kmalloc_large include/linux/slab.h:390
 [<ffffffff81627784>] __kmalloc+0x234/0x250 mm/slub.c:3525
 [<     inline     >] kmalloc include/linux/slab.h:463
 [<     inline     >] map_update_elem kernel/bpf/syscall.c:288
 [<     inline     >] SYSC_bpf kernel/bpf/syscall.c:744

To avoid never succeeding kmalloc with order >= MAX_ORDER check that
elem->value_size and computed elem_size are within limits for both hash and
array type maps.
Also add __GFP_NOWARN to kmalloc(value_size | elem_size) to avoid OOM warnings.
Note kmalloc(key_size) is highly unlikely to trigger OOM, since key_size <= 512,
so keep those kmalloc-s as-is.

Large value_size can cause integer overflows in elem_size and map.pages
formulas, so check for that as well.

Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
The bug is serious in 4.4 where unprivileged bpf was introduced.
Also would be great to back port further all the way to the beginning of maps:
commit 0f8e4bd8a1fc ("bpf: add hashtable type of eBPF maps").
Only hunk about htab->map.pages is not applicable.
---
 kernel/bpf/arraymap.c |  8 +++++++-
 kernel/bpf/hashtab.c  | 34 +++++++++++++++++++++++++---------
 kernel/bpf/syscall.c  |  4 ++--
 3 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 3f4c99e06c6b..b1e53b79c586 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -28,11 +28,17 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	    attr->value_size == 0)
 		return ERR_PTR(-EINVAL);
 
+	if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
+		/* if value_size is bigger, the user space won't be able to
+		 * access the elements.
+		 */
+		return ERR_PTR(-E2BIG);
+
 	elem_size = round_up(attr->value_size, 8);
 
 	/* check round_up into zero and u32 overflow */
 	if (elem_size == 0 ||
-	    attr->max_entries > (U32_MAX - sizeof(*array)) / elem_size)
+	    attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) / elem_size)
 		return ERR_PTR(-ENOMEM);
 
 	array_size = sizeof(*array) + attr->max_entries * elem_size;
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 19909b22b4f8..34777b3746fa 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -64,12 +64,35 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
-	err = -ENOMEM;
+	if (htab->map.value_size >= (1 << (KMALLOC_SHIFT_MAX - 1)) -
+	    MAX_BPF_STACK - sizeof(struct htab_elem))
+		/* if value_size is bigger, the user space won't be able to
+		 * access the elements via bpf syscall. This check also makes
+		 * sure that the elem_size doesn't overflow and it's
+		 * kmalloc-able later in htab_map_update_elem()
+		 */
+		goto free_htab;
+
+	htab->elem_size = sizeof(struct htab_elem) +
+			  round_up(htab->map.key_size, 8) +
+			  htab->map.value_size;
+
 	/* prevent zero size kmalloc and check for u32 overflow */
 	if (htab->n_buckets == 0 ||
 	    htab->n_buckets > U32_MAX / sizeof(struct hlist_head))
 		goto free_htab;
 
+	if ((u64) htab->n_buckets * sizeof(struct hlist_head) +
+	    (u64) htab->elem_size * htab->map.max_entries >=
+	    U32_MAX - PAGE_SIZE)
+		/* make sure page count doesn't overflow */
+		goto free_htab;
+
+	htab->map.pages = round_up(htab->n_buckets * sizeof(struct hlist_head) +
+				   htab->elem_size * htab->map.max_entries,
+				   PAGE_SIZE) >> PAGE_SHIFT;
+
+	err = -ENOMEM;
 	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct hlist_head),
 				      GFP_USER | __GFP_NOWARN);
 
@@ -85,13 +108,6 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	raw_spin_lock_init(&htab->lock);
 	htab->count = 0;
 
-	htab->elem_size = sizeof(struct htab_elem) +
-			  round_up(htab->map.key_size, 8) +
-			  htab->map.value_size;
-
-	htab->map.pages = round_up(htab->n_buckets * sizeof(struct hlist_head) +
-				   htab->elem_size * htab->map.max_entries,
-				   PAGE_SIZE) >> PAGE_SHIFT;
 	return &htab->map;
 
 free_htab:
@@ -222,7 +238,7 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
 	/* allocate new element outside of lock */
-	l_new = kmalloc(htab->elem_size, GFP_ATOMIC);
+	l_new = kmalloc(htab->elem_size, GFP_ATOMIC | __GFP_NOWARN);
 	if (!l_new)
 		return -ENOMEM;
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 4a8f3c1d7da6..3b39550d8485 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -240,7 +240,7 @@ static int map_lookup_elem(union bpf_attr *attr)
 		goto free_key;
 
 	err = -ENOMEM;
-	value = kmalloc(map->value_size, GFP_USER);
+	value = kmalloc(map->value_size, GFP_USER | __GFP_NOWARN);
 	if (!value)
 		goto free_key;
 
@@ -299,7 +299,7 @@ static int map_update_elem(union bpf_attr *attr)
 		goto free_key;
 
 	err = -ENOMEM;
-	value = kmalloc(map->value_size, GFP_USER);
+	value = kmalloc(map->value_size, GFP_USER | __GFP_NOWARN);
 	if (!value)
 		goto free_key;
 
-- 
2.4.6
