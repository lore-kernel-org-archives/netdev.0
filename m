From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use per task frag allocator in
 skb_append_datato_frags
Date: Fri, 28 Dec 2012 08:06:37 -0800
Message-ID: <1356710797.21409.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:45995 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab2L1QGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 11:06:41 -0500
Received: by mail-pb0-f53.google.com with SMTP id jt11so5974167pbb.12
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2012 08:06:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use the new per task frag allocator in skb_append_datato_frags(),
to reduce number of frags and page allocator overhead.

Tested:
 ifconfig lo mtu 16436
 perf record netperf -t UDP_STREAM ; perf report 

before :
 Throughput: 32928 Mbit/s
    51.79%  netperf  [kernel.kallsyms]  [k] copy_user_generic_string
     5.98%  netperf  [kernel.kallsyms]  [k] __alloc_pages_nodemask
     5.58%  netperf  [kernel.kallsyms]  [k] get_page_from_freelist
     5.01%  netperf  [kernel.kallsyms]  [k] __rmqueue
     3.74%  netperf  [kernel.kallsyms]  [k] skb_append_datato_frags
     1.87%  netperf  [kernel.kallsyms]  [k] prep_new_page
     1.42%  netperf  [kernel.kallsyms]  [k] next_zones_zonelist
     1.28%  netperf  [kernel.kallsyms]  [k] __inc_zone_state
     1.26%  netperf  [kernel.kallsyms]  [k] alloc_pages_current
     0.78%  netperf  [kernel.kallsyms]  [k] sock_alloc_send_pskb
     0.74%  netperf  [kernel.kallsyms]  [k] udp_sendmsg
     0.72%  netperf  [kernel.kallsyms]  [k] zone_watermark_ok
     0.68%  netperf  [kernel.kallsyms]  [k] __cpuset_node_allowed_softwall
     0.67%  netperf  [kernel.kallsyms]  [k] fib_table_lookup
     0.60%  netperf  [kernel.kallsyms]  [k] memcpy_fromiovecend
     0.55%  netperf  [kernel.kallsyms]  [k] __udp4_lib_lookup

 after:
  Throughput: 47185 Mbit/s
	61.74%	netperf  [kernel.kallsyms]	[k] copy_user_generic_string
	 2.07%	netperf  [kernel.kallsyms]	[k] prep_new_page
	 1.98%	netperf  [kernel.kallsyms]	[k] skb_append_datato_frags
	 1.02%	netperf  [kernel.kallsyms]	[k] sock_alloc_send_pskb
	 0.97%	netperf  [kernel.kallsyms]	[k] enqueue_task_fair
	 0.97%	netperf  [kernel.kallsyms]	[k] udp_sendmsg
	 0.91%	netperf  [kernel.kallsyms]	[k] __ip_route_output_key
	 0.88%	netperf  [kernel.kallsyms]	[k] __netif_receive_skb
	 0.87%	netperf  [kernel.kallsyms]	[k] fib_table_lookup
	 0.85%	netperf  [kernel.kallsyms]	[k] resched_task
	 0.78%	netperf  [kernel.kallsyms]	[k] __udp4_lib_lookup
	 0.77%	netperf  [kernel.kallsyms]	[k] _raw_spin_lock_irqsave

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   43 ++++++++++++++++---------------------------
 1 file changed, 16 insertions(+), 27 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3ab989b..ec8737e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2686,48 +2686,37 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 					int len, int odd, struct sk_buff *skb),
 			void *from, int length)
 {
-	int frg_cnt = 0;
-	skb_frag_t *frag = NULL;
-	struct page *page = NULL;
-	int copy, left;
+	int frg_cnt = skb_shinfo(skb)->nr_frags;
+	int copy;
 	int offset = 0;
 	int ret;
+	struct page_frag *pfrag = &current->task_frag;
 
 	do {
 		/* Return error if we don't have space for new frag */
-		frg_cnt = skb_shinfo(skb)->nr_frags;
 		if (frg_cnt >= MAX_SKB_FRAGS)
-			return -EFAULT;
-
-		/* allocate a new page for next frag */
-		page = alloc_pages(sk->sk_allocation, 0);
+			return -EMSGSIZE;
 
-		/* If alloc_page fails just return failure and caller will
-		 * free previous allocated pages by doing kfree_skb()
-		 */
-		if (page == NULL)
+		if (!sk_page_frag_refill(sk, pfrag))
 			return -ENOMEM;
 
-		/* initialize the next frag */
-		skb_fill_page_desc(skb, frg_cnt, page, 0, 0);
-		skb->truesize += PAGE_SIZE;
-		atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
-
-		/* get the new initialized frag */
-		frg_cnt = skb_shinfo(skb)->nr_frags;
-		frag = &skb_shinfo(skb)->frags[frg_cnt - 1];
-
 		/* copy the user data to page */
-		left = PAGE_SIZE - frag->page_offset;
-		copy = (length > left)? left : length;
+		copy = min_t(int, length, pfrag->size - pfrag->offset);
 
-		ret = getfrag(from, skb_frag_address(frag) + skb_frag_size(frag),
-			    offset, copy, 0, skb);
+		ret = getfrag(from, page_address(pfrag->page) + pfrag->offset,
+			      offset, copy, 0, skb);
 		if (ret < 0)
 			return -EFAULT;
 
 		/* copy was successful so update the size parameters */
-		skb_frag_size_add(frag, copy);
+		skb_fill_page_desc(skb, frg_cnt, pfrag->page, pfrag->offset,
+				   copy);
+		frg_cnt++;
+		pfrag->offset += copy;
+		get_page(pfrag->page);
+
+		skb->truesize += copy;
+		atomic_add(copy, &sk->sk_wmem_alloc);
 		skb->len += copy;
 		skb->data_len += copy;
 		offset += copy;
