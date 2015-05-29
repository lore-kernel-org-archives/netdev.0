From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Thu, 28 May 2015 18:50:34 -0700
Message-ID: <1432864234.7456.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432801700-29300-1-git-send-email-ying.xue@windriver.com>
	 <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5567BF28.6050900@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34718 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320AbbE2Buh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 21:50:37 -0400
Received: by ieczm2 with SMTP id zm2so52290217iec.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 18:50:36 -0700 (PDT)
In-Reply-To: <5567BF28.6050900@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-29 at 09:21 +0800, Ying Xue wrote:
> On 05/28/2015 06:13 PM, Eric Dumazet wrote:
> > This patch is not needed.
> > 
> > You really should read Documentation/RCU , because it looks like you are
> > quite confused.
> > 
> > When we remove an element from a RCU protected list, all the objects in
> > the chain are already ready to be caught by rcu readers.
> > 
> > Therefore, no additional memory barrier is needed before doing *np =
> > n->next;
> > 
> > Please do not add spurious memory barriers. Like atomic operations, we
> > want all of them being required and possibly documented.
> 
> 
> Yes, you are right, thanks for your clear explanation :)
> However, there are still three places where we use rcu_assign_pointer() to
> remove a neigh entry from a RCU-protected list, and the three places are
> neigh_forced_gc(), neigh_flush_dev(), and __neigh_for_each_release()
> respectively. This means it's redundant for us to use rcu_assign_pointer() in
> the three places, right?

I count 5 places of redundancy. 

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3a74df750af4044eba0e7d88ae01ca9b4dac0e72..ac3b69183cc982e722d9683d6de7a39f66b50b64 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -141,9 +141,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
-				rcu_assign_pointer(*np,
-					rcu_dereference_protected(n->next,
-						  lockdep_is_held(&tbl->lock)));
+				*np = n->next;
 				n->dead = 1;
 				shrunk	= 1;
 				write_unlock(&n->lock);
@@ -210,9 +208,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 				np = &n->next;
 				continue;
 			}
-			rcu_assign_pointer(*np,
-				   rcu_dereference_protected(n->next,
-						lockdep_is_held(&tbl->lock)));
+			*np = n->next;
 			write_lock(&n->lock);
 			neigh_del_timer(n);
 			n->dead = 1;
@@ -380,10 +376,8 @@ static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
 			next = rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock));
 
-			rcu_assign_pointer(n->next,
-					   rcu_dereference_protected(
-						new_nht->hash_buckets[hash],
-						lockdep_is_held(&tbl->lock)));
+			n->next = new_nht->hash_buckets[hash];
+
 			rcu_assign_pointer(new_nht->hash_buckets[hash], n);
 		}
 	}
@@ -515,9 +509,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 	n->dead = 0;
 	if (want_ref)
 		neigh_hold(n);
-	rcu_assign_pointer(n->next,
-			   rcu_dereference_protected(nht->hash_buckets[hash_val],
-						     lockdep_is_held(&tbl->lock)));
+	n->next = nht->hash_buckets[hash_val];
 	rcu_assign_pointer(nht->hash_buckets[hash_val], n);
 	write_unlock_bh(&tbl->lock);
 	neigh_dbg(2, "neigh %p is created\n", n);
@@ -2381,9 +2373,7 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 			write_lock(&n->lock);
 			release = cb(n);
 			if (release) {
-				rcu_assign_pointer(*np,
-					rcu_dereference_protected(n->next,
-						lockdep_is_held(&tbl->lock)));
+				*np = n->next;
 				n->dead = 1;
 			} else
 				np = &n->next;
