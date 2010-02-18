From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipv6: use standard lists for FIB walks
Date: Thu, 18 Feb 2010 20:13:30 +0200
Message-ID: <20100218181330.GB21184@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:40792 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349Ab0BRSN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:13:29 -0500
Received: by fxm20 with SMTP id 20so9316547fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 10:13:28 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/ip6_fib.h |    2 +-
 net/ipv6/ip6_fib.c    |   17 ++++-------------
 2 files changed, 5 insertions(+), 14 deletions(-)

--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -124,7 +124,7 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 }
 
 struct fib6_walker_t {
-	struct fib6_walker_t *prev, *next;
+	struct list_head lh;
 	struct fib6_node *root, *node;
 	struct rt6_info *leaf;
 	unsigned char state;
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -93,29 +93,20 @@ static __u32 rt_sernum;
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
-static struct fib6_walker_t fib6_walker_list = {
-	.prev	= &fib6_walker_list,
-	.next	= &fib6_walker_list,
-};
-
-#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
+static LIST_HEAD(fib6_walkers);
+#define FOR_WALKERS(w) list_for_each_entry(w, &fib6_walkers, lh)
 
 static inline void fib6_walker_link(struct fib6_walker_t *w)
 {
 	write_lock_bh(&fib6_walker_lock);
-	w->next = fib6_walker_list.next;
-	w->prev = &fib6_walker_list;
-	w->next->prev = w;
-	w->prev->next = w;
+	list_add(&w->lh, &fib6_walkers);
 	write_unlock_bh(&fib6_walker_lock);
 }
 
 static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 {
 	write_lock_bh(&fib6_walker_lock);
-	w->next->prev = w->prev;
-	w->prev->next = w->next;
-	w->prev = w->next = w;
+	list_del(&w->lh);
 	write_unlock_bh(&fib6_walker_lock);
 }
 static __inline__ u32 fib6_new_sernum(void)
