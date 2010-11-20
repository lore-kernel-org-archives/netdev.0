From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] net: allow GFP_HIGHMEM in __vmalloc()
Date: Sat, 20 Nov 2010 18:46:35 +0100
Message-ID: <1290275195.2756.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44480 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab0KTRqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 12:46:45 -0500
Received: by wyb28 with SMTP id 28so5593146wyb.19
        for <netdev@vger.kernel.org>; Sat, 20 Nov 2010 09:46:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We forgot to use __GFP_HIGHMEM in several __vmalloc() calls.

In ceph, add the missing flag.

In fib_trie.c, xfrm_hash.c and request_sock.c, using vzalloc() is
cleaner and allows using HIGHMEM pages as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ceph/buffer.c       |    2 +-
 net/core/request_sock.c |    4 +---
 net/ipv4/fib_trie.c     |    2 +-
 net/xfrm/xfrm_hash.c    |    2 +-
 4 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ceph/buffer.c b/net/ceph/buffer.c
index 53d8abf..bf3e6a1 100644
--- a/net/ceph/buffer.c
+++ b/net/ceph/buffer.c
@@ -19,7 +19,7 @@ struct ceph_buffer *ceph_buffer_new(size_t len, gfp_t gfp)
 	if (b->vec.iov_base) {
 		b->is_vmalloc = false;
 	} else {
-		b->vec.iov_base = __vmalloc(len, gfp, PAGE_KERNEL);
+		b->vec.iov_base = __vmalloc(len, gfp | __GFP_HIGHMEM, PAGE_KERNEL);
 		if (!b->vec.iov_base) {
 			kfree(b);
 			return NULL;
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 7552495..fceeb37 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -45,9 +45,7 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
 	lopt_size += nr_table_entries * sizeof(struct request_sock *);
 	if (lopt_size > PAGE_SIZE)
-		lopt = __vmalloc(lopt_size,
-			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
-			PAGE_KERNEL);
+		lopt = vzalloc(lopt_size);
 	else
 		lopt = kzalloc(lopt_size, GFP_KERNEL);
 	if (lopt == NULL)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 200eb53..0f28034 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -365,7 +365,7 @@ static struct tnode *tnode_alloc(size_t size)
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
 	else
-		return __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+		return vzalloc(size);
 }
 
 static void __tnode_vfree(struct work_struct *arg)
diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
index a2023ec..1e98bc0 100644
--- a/net/xfrm/xfrm_hash.c
+++ b/net/xfrm/xfrm_hash.c
@@ -19,7 +19,7 @@ struct hlist_head *xfrm_hash_alloc(unsigned int sz)
 	if (sz <= PAGE_SIZE)
 		n = kzalloc(sz, GFP_KERNEL);
 	else if (hashdist)
-		n = __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
+		n = vzalloc(sz);
 	else
 		n = (struct hlist_head *)
 			__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,


