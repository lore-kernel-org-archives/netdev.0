From: Domen Puncer <domen@coderock.org>
Subject: Re: [patch 01/26] list_for_each: net-ipv6-ip6_fib.c
Date: Sun, 6 Mar 2005 23:11:01 +0100
Message-ID: <20050306221101.GB32564@nd47.coderock.org>
References: <20050306103238.86F181E46E@trashy.coderock.org> <20050307.014040.48352532.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, janitor@sternwelten.at
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050307.014040.48352532.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07/03/05 01:40 +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> In article <20050306103238.86F181E46E@trashy.coderock.org> (at Sun, 06 Mar 2005 11:32:38 +0100), domen@coderock.org says:
> 
> > s/for/list_for_each/
> > Compile tested.
> :
> > +++ kj-domen/net/ipv6/ip6_fib.c	2005-03-05 16:09:09.000000000 +0100
> > @@ -99,7 +99,7 @@ struct fib6_walker_t fib6_walker_list = 
> >  	.next	= &fib6_walker_list, 
> >  };
> >  
> > -#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
> > +#define FOR_WALKERS(w) list_for_each((w), &fib6_walker_list)
> >  
> >  static __inline__ u32 fib6_new_sernum(void)
> >  {
> 
> Please don't. fib6_walker_list is not for fib6_walker_t but list_head.
> (Or, why don't you convert fib6_walker_t to use list_head families?)

Makes sense.
How about this compile tested patch:


Convert to use lists from list.h.

Signed-off-by: Domen Puncer <domen@coderock.org>

diff -purNX dontdiff c/net/ipv6/ip6_fib.c a/net/ipv6/ip6_fib.c
--- c/net/ipv6/ip6_fib.c	2005-03-02 10:32:13.000000000 +0100
+++ a/net/ipv6/ip6_fib.c	2005-03-06 23:02:54.000000000 +0100
@@ -95,12 +95,9 @@ static __u32 rt_sernum;
 static struct timer_list ip6_fib_timer = TIMER_INITIALIZER(fib6_run_gc, 0, 0);
 
 struct fib6_walker_t fib6_walker_list = {
-	.prev	= &fib6_walker_list,
-	.next	= &fib6_walker_list, 
+	.head	= LIST_HEAD_INIT(fib6_walker_list.head),
 };
 
-#define FOR_WALKERS(w) for ((w)=fib6_walker_list.next; (w) != &fib6_walker_list; (w)=(w)->next)
-
 static __inline__ u32 fib6_new_sernum(void)
 {
 	u32 n = ++rt_sernum;
@@ -849,7 +846,7 @@ static struct fib6_node * fib6_repair_tr
 #endif
 
 		read_lock(&fib6_walker_lock);
-		FOR_WALKERS(w) {
+		list_for_each_entry(w, &fib6_walker_list.head, head) {
 			if (child == NULL) {
 				if (w->root == fn) {
 					w->root = w->node = NULL;
@@ -904,7 +901,7 @@ static void fib6_del_route(struct fib6_n
 
 	/* Adjust walkers */
 	read_lock(&fib6_walker_lock);
-	FOR_WALKERS(w) {
+	list_for_each_entry(w, &fib6_walker_list.head, head) {
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
 			w->leaf = rt->u.next;
diff -purNX dontdiff c/include/net/ip6_fib.h a/include/net/ip6_fib.h
--- c/include/net/ip6_fib.h	2005-01-22 02:48:35.000000000 +0100
+++ a/include/net/ip6_fib.h	2005-03-06 23:03:14.000000000 +0100
@@ -21,6 +21,7 @@
 #include <net/flow.h>
 #include <linux/rtnetlink.h>
 #include <linux/spinlock.h>
+#include <linux/list.h>
 
 struct rt6_info;
 
@@ -80,7 +81,7 @@ struct rt6_info
 
 struct fib6_walker_t
 {
-	struct fib6_walker_t *prev, *next;
+	struct list_head head;
 	struct fib6_node *root, *node;
 	struct rt6_info *leaf;
 	unsigned char state;
@@ -95,19 +96,14 @@ extern rwlock_t fib6_walker_lock;
 static inline void fib6_walker_link(struct fib6_walker_t *w)
 {
 	write_lock_bh(&fib6_walker_lock);
-	w->next = fib6_walker_list.next;
-	w->prev = &fib6_walker_list;
-	w->next->prev = w;
-	w->prev->next = w;
+	list_add(&w->head, &fib6_walker_list.head);
 	write_unlock_bh(&fib6_walker_lock);
 }
 
 static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 {
 	write_lock_bh(&fib6_walker_lock);
-	w->next->prev = w->prev;
-	w->prev->next = w->next;
-	w->prev = w->next = w;
+	list_del_init(&w->head);
 	write_unlock_bh(&fib6_walker_lock);
 }
 
