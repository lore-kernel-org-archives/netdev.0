From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 2/3 V2] slub,rcu: don't assume the size of struct rcu_head
Date: Thu, 10 Mar 2011 15:22:00 +0800
Message-ID: <4D787C18.3070800@cn.fujitsu.com>
References: <4D6CA843.3090103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Christoph Lameter <cl@linux-foundation.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4D6CA843.3090103@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

The size of struct rcu_head may be changed. When it becomes larger,
it will pollute the page array.

We reserve some some bytes for struct rcu_head when a slab
is allocated in this situation.

Changed from V1:
	use VM_BUG_ON instead BUG_ON

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d3d1767..ebba3eb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1254,21 +1254,38 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__free_pages(page, order);
 }
 
+#define need_reserve_slab_rcu						\
+	(sizeof(((struct page *)NULL)->lru) < sizeof(struct rcu_head))
+
 static void rcu_free_slab(struct rcu_head *h)
 {
 	struct page *page;
 
-	page = container_of((struct list_head *)h, struct page, lru);
+	if (need_reserve_slab_rcu)
+		page = virt_to_head_page(h);
+	else
+		page = container_of((struct list_head *)h, struct page, lru);
+
 	__free_slab(page->slab, page);
 }
 
 static void free_slab(struct kmem_cache *s, struct page *page)
 {
 	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
-		/*
-		 * RCU free overloads the RCU head over the LRU
-		 */
-		struct rcu_head *head = (void *)&page->lru;
+		struct rcu_head *head;
+
+		if (need_reserve_slab_rcu) {
+			int order = compound_order(page);
+			int offset = (PAGE_SIZE << order) - s->reserved;
+
+			VM_BUG_ON(s->reserved != sizeof(*head));
+			head = page_address(page) + offset;
+		} else {
+			/*
+			 * RCU free overloads the RCU head over the LRU
+			 */
+			head = (void *)&page->lru;
+		}
 
 		call_rcu(head, rcu_free_slab);
 	} else
@@ -2356,6 +2373,9 @@ static int kmem_cache_open(struct kmem_cache *s,
 	s->flags = kmem_cache_flags(size, flags, name, ctor);
 	s->reserved = 0;
 
+	if (need_reserve_slab_rcu && (s->flags & SLAB_DESTROY_BY_RCU))
+		s->reserved = sizeof(struct rcu_head);
+
 	if (!calculate_sizes(s, -1))
 		goto error;
 	if (disable_higher_order_debug) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
