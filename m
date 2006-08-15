From: akpm@osdl.org
Subject: [patch 13/13] net/ipv6/ip6_fib.c: make code static
Date: Mon, 14 Aug 2006 23:03:46 -0700
Message-ID: <200608150603.k7F63lgI012963@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9365 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965175AbWHOGHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:07:03 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

Make the following needlessly global code static:
- fib6_walker_lock
- struct fib6_walker_list
- fib6_walk_continue()
- fib6_walk()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/net/ip6_fib.h |   25 -------------------------
 net/ipv6/ip6_fib.c    |   29 ++++++++++++++++++++++++-----
 2 files changed, 24 insertions(+), 30 deletions(-)

diff -puN include/net/ip6_fib.h~net-ipv6-ip6_fibc-make-code-static include/net/ip6_fib.h
--- a/include/net/ip6_fib.h~net-ipv6-ip6_fibc-make-code-static
+++ a/include/net/ip6_fib.h
@@ -92,28 +92,6 @@ struct fib6_walker_t
 	void *args;
 };
 
-extern struct fib6_walker_t fib6_walker_list;
-extern rwlock_t fib6_walker_lock;
-
-static inline void fib6_walker_link(struct fib6_walker_t *w)
-{
-	write_lock_bh(&fib6_walker_lock);
-	w->next = fib6_walker_list.next;
-	w->prev = &fib6_walker_list;
-	w->next->prev = w;
-	w->prev->next = w;
-	write_unlock_bh(&fib6_walker_lock);
-}
-
-static inline void fib6_walker_unlink(struct fib6_walker_t *w)
-{
-	write_lock_bh(&fib6_walker_lock);
-	w->next->prev = w->prev;
-	w->prev->next = w->next;
-	w->prev = w->next = w;
-	write_unlock_bh(&fib6_walker_lock);
-}
-
 struct rt6_statistics {
 	__u32		fib_nodes;
 	__u32		fib_route_nodes;
@@ -195,9 +173,6 @@ struct fib6_node		*fib6_locate(struct fi
 extern void			fib6_clean_all(int (*func)(struct rt6_info *, void *arg),
 					       int prune, void *arg);
 
-extern int			fib6_walk(struct fib6_walker_t *w);
-extern int			fib6_walk_continue(struct fib6_walker_t *w);
-
 extern int			fib6_add(struct fib6_node *root,
 					 struct rt6_info *rt,
 					 struct nlmsghdr *nlh,
diff -puN net/ipv6/ip6_fib.c~net-ipv6-ip6_fibc-make-code-static net/ipv6/ip6_fib.c
--- a/net/ipv6/ip6_fib.c~net-ipv6-ip6_fibc-make-code-static
+++ a/net/ipv6/ip6_fib.c
@@ -69,8 +69,7 @@ struct fib6_cleaner_t
 	void *arg;
 };
 
-DEFINE_RWLOCK(fib6_walker_lock);
-
+static DEFINE_RWLOCK(fib6_walker_lock);
 
 #ifdef CONFIG_IPV6_SUBTREES
 #define FWS_INIT FWS_S
@@ -82,6 +81,8 @@ DEFINE_RWLOCK(fib6_walker_lock);
 
 static void fib6_prune_clones(struct fib6_node *fn, struct rt6_info *rt);
 static struct fib6_node * fib6_repair_tree(struct fib6_node *fn);
+static int fib6_walk(struct fib6_walker_t *w);
+static int fib6_walk_continue(struct fib6_walker_t *w);
 
 /*
  *	A routing update causes an increase of the serial number on the
@@ -94,13 +95,31 @@ static __u32 rt_sernum;
 
 static DEFINE_TIMER(ip6_fib_timer, fib6_run_gc, 0, 0);
 
-struct fib6_walker_t fib6_walker_list = {
+static struct fib6_walker_t fib6_walker_list = {
 	.prev	= &fib6_walker_list,
 	.next	= &fib6_walker_list, 
 };
 
 #define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
 
+static inline void fib6_walker_link(struct fib6_walker_t *w)
+{
+	write_lock_bh(&fib6_walker_lock);
+	w->next = fib6_walker_list.next;
+	w->prev = &fib6_walker_list;
+	w->next->prev = w;
+	w->prev->next = w;
+	write_unlock_bh(&fib6_walker_lock);
+}
+
+static inline void fib6_walker_unlink(struct fib6_walker_t *w)
+{
+	write_lock_bh(&fib6_walker_lock);
+	w->next->prev = w->prev;
+	w->prev->next = w->next;
+	w->prev = w->next = w;
+	write_unlock_bh(&fib6_walker_lock);
+}
 static __inline__ u32 fib6_new_sernum(void)
 {
 	u32 n = ++rt_sernum;
@@ -1173,7 +1192,7 @@ int fib6_del(struct rt6_info *rt, struct
  *	<0  -> walk is terminated by an error.
  */
 
-int fib6_walk_continue(struct fib6_walker_t *w)
+static int fib6_walk_continue(struct fib6_walker_t *w)
 {
 	struct fib6_node *fn, *pn;
 
@@ -1247,7 +1266,7 @@ int fib6_walk_continue(struct fib6_walke
 	}
 }
 
-int fib6_walk(struct fib6_walker_t *w)
+static int fib6_walk(struct fib6_walker_t *w)
 {
 	int res;
 
_
