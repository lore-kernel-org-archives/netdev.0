From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ptr_ring: use kmalloc_array()
Date: Wed, 16 Aug 2017 10:36:47 -0700
Message-ID: <1502905007.4936.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36077 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752636AbdHPRgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:36:49 -0400
Received: by mail-pf0-f195.google.com with SMTP id t83so1896209pfj.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 10:36:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As found by syzkaller, malicious users can set whatever tx_queue_len
on a tun device and eventually crash the kernel.

Lets remove the ALIGN(XXX, SMP_CACHE_BYTES) thing since a small
ring buffer is not fast anyway.

Fixes: 2e0ab8ca83c1 ("ptr_ring: array based FIFO for pointers")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
---
 include/linux/ptr_ring.h  |    9 +++++----
 include/linux/skb_array.h |    3 ++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index d8c97ec8a8e6..37b4bb2545b3 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -436,9 +436,9 @@ static inline int ptr_ring_consume_batched_bh(struct ptr_ring *r,
 	__PTR_RING_PEEK_CALL_v; \
 })
 
-static inline void **__ptr_ring_init_queue_alloc(int size, gfp_t gfp)
+static inline void **__ptr_ring_init_queue_alloc(unsigned int size, gfp_t gfp)
 {
-	return kzalloc(ALIGN(size * sizeof(void *), SMP_CACHE_BYTES), gfp);
+	return kcalloc(size, sizeof(void *), gfp);
 }
 
 static inline void __ptr_ring_set_size(struct ptr_ring *r, int size)
@@ -582,7 +582,8 @@ static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
  * In particular if you consume ring in interrupt or BH context, you must
  * disable interrupts/BH when doing so.
  */
-static inline int ptr_ring_resize_multiple(struct ptr_ring **rings, int nrings,
+static inline int ptr_ring_resize_multiple(struct ptr_ring **rings,
+					   unsigned int nrings,
 					   int size,
 					   gfp_t gfp, void (*destroy)(void *))
 {
@@ -590,7 +591,7 @@ static inline int ptr_ring_resize_multiple(struct ptr_ring **rings, int nrings,
 	void ***queues;
 	int i;
 
-	queues = kmalloc(nrings * sizeof *queues, gfp);
+	queues = kmalloc_array(nrings, sizeof(*queues), gfp);
 	if (!queues)
 		goto noqueues;
 
diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index 35226cd4efb0..8621ffdeecbf 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -193,7 +193,8 @@ static inline int skb_array_resize(struct skb_array *a, int size, gfp_t gfp)
 }
 
 static inline int skb_array_resize_multiple(struct skb_array **rings,
-					    int nrings, int size, gfp_t gfp)
+					    int nrings, unsigned int size,
+					    gfp_t gfp)
 {
 	BUILD_BUG_ON(offsetof(struct skb_array, ring));
 	return ptr_ring_resize_multiple((struct ptr_ring **)rings,
