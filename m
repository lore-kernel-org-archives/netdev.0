From: Patrick McHardy <kaber@trash.net>
Subject: IPVS 01/03: ip_vs_lblcr: use list headA
Date: Fri, 26 Feb 2010 18:15:22 +0100 (MET)
Message-ID: <20100226171522.30040.76445.sendpatchset@x2.localnet>
References: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59976 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965421Ab0BZRPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 12:15:23 -0500
In-Reply-To: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 51f0bc78680edccb6574ef56bd32f9e2939c8a5a
Author: Simon Horman <horms@verge.net.au>
Date:   Fri Feb 26 17:45:14 2010 +0100

    IPVS: ip_vs_lblcr: use list headA
    
    Use list_head rather than a custom list implementation.
    
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index f7476b9..caa58fa 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -45,6 +45,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/jiffies.h>
+#include <linux/list.h>
 
 /* for sysctl */
 #include <linux/fs.h>
@@ -85,25 +86,25 @@ static int sysctl_ip_vs_lblcr_expiration = 24*60*60*HZ;
 /*
  *      IPVS destination set structure and operations
  */
-struct ip_vs_dest_list {
-	struct ip_vs_dest_list  *next;          /* list link */
+struct ip_vs_dest_set_elem {
+	struct list_head	list;          /* list link */
 	struct ip_vs_dest       *dest;          /* destination server */
 };
 
 struct ip_vs_dest_set {
 	atomic_t                size;           /* set size */
 	unsigned long           lastmod;        /* last modified time */
-	struct ip_vs_dest_list  *list;          /* destination list */
+	struct list_head	list;           /* destination list */
 	rwlock_t	        lock;           /* lock for this list */
 };
 
 
-static struct ip_vs_dest_list *
+static struct ip_vs_dest_set_elem *
 ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 {
-	struct ip_vs_dest_list *e;
+	struct ip_vs_dest_set_elem *e;
 
-	for (e=set->list; e!=NULL; e=e->next) {
+	list_for_each_entry(e, &set->list, list) {
 		if (e->dest == dest)
 			/* already existed */
 			return NULL;
@@ -118,9 +119,7 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 	atomic_inc(&dest->refcnt);
 	e->dest = dest;
 
-	/* link it to the list */
-	e->next = set->list;
-	set->list = e;
+	list_add(&e->list, &set->list);
 	atomic_inc(&set->size);
 
 	set->lastmod = jiffies;
@@ -130,34 +129,33 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 static void
 ip_vs_dest_set_erase(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 {
-	struct ip_vs_dest_list *e, **ep;
+	struct ip_vs_dest_set_elem *e;
 
-	for (ep=&set->list, e=*ep; e!=NULL; e=*ep) {
+	list_for_each_entry(e, &set->list, list) {
 		if (e->dest == dest) {
 			/* HIT */
-			*ep = e->next;
 			atomic_dec(&set->size);
 			set->lastmod = jiffies;
 			atomic_dec(&e->dest->refcnt);
+			list_del(&e->list);
 			kfree(e);
 			break;
 		}
-		ep = &e->next;
 	}
 }
 
 static void ip_vs_dest_set_eraseall(struct ip_vs_dest_set *set)
 {
-	struct ip_vs_dest_list *e, **ep;
+	struct ip_vs_dest_set_elem *e, *ep;
 
 	write_lock(&set->lock);
-	for (ep=&set->list, e=*ep; e!=NULL; e=*ep) {
-		*ep = e->next;
+	list_for_each_entry_safe(e, ep, &set->list, list) {
 		/*
 		 * We don't kfree dest because it is refered either
 		 * by its service or by the trash dest list.
 		 */
 		atomic_dec(&e->dest->refcnt);
+		list_del(&e->list);
 		kfree(e);
 	}
 	write_unlock(&set->lock);
@@ -166,7 +164,7 @@ static void ip_vs_dest_set_eraseall(struct ip_vs_dest_set *set)
 /* get weighted least-connection node in the destination set */
 static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 {
-	register struct ip_vs_dest_list *e;
+	register struct ip_vs_dest_set_elem *e;
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
 
@@ -174,7 +172,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		return NULL;
 
 	/* select the first destination server, whose weight > 0 */
-	for (e=set->list; e!=NULL; e=e->next) {
+	list_for_each_entry(e, &set->list, list) {
 		least = e->dest;
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
@@ -190,7 +188,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 
 	/* find the destination with the weighted least load */
   nextstage:
-	for (e=e->next; e!=NULL; e=e->next) {
+	list_for_each_entry(e, &set->list, list) {
 		dest = e->dest;
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
@@ -220,7 +218,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 /* get weighted most-connection node in the destination set */
 static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 {
-	register struct ip_vs_dest_list *e;
+	register struct ip_vs_dest_set_elem *e;
 	struct ip_vs_dest *dest, *most;
 	int moh, doh;
 
@@ -228,7 +226,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 		return NULL;
 
 	/* select the first destination server, whose weight > 0 */
-	for (e=set->list; e!=NULL; e=e->next) {
+	list_for_each_entry(e, &set->list, list) {
 		most = e->dest;
 		if (atomic_read(&most->weight) > 0) {
 			moh = atomic_read(&most->activeconns) * 50
@@ -240,7 +238,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 
 	/* find the destination with the weighted most load */
   nextstage:
-	for (e=e->next; e!=NULL; e=e->next) {
+	list_for_each_entry(e, &set->list, list) {
 		dest = e->dest;
 		doh = atomic_read(&dest->activeconns) * 50
 			+ atomic_read(&dest->inactconns);
@@ -389,7 +387,7 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 
 		/* initilize its dest set */
 		atomic_set(&(en->set.size), 0);
-		en->set.list = NULL;
+		INIT_LIST_HEAD(&en->set.list);
 		rwlock_init(&en->set.lock);
 
 		ip_vs_lblcr_hash(tbl, en);
