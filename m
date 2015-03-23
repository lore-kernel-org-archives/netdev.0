From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: warnings caused by "rhashtable: Fix use-after-free
 in rhashtable_walk_stop"
Date: Tue, 24 Mar 2015 09:53:17 +1100
Message-ID: <20150323225317.GA20707@gondor.apana.org.au>
References: <55105B2E.1070409@oracle.com>
 <20150323215513.GA20128@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46631 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbbCWWxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:53:24 -0400
Content-Disposition: inline
In-Reply-To: <20150323215513.GA20128@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 08:55:13AM +1100, Herbert Xu wrote:
> On Mon, Mar 23, 2015 at 02:27:58PM -0400, Sasha Levin wrote:
> > 
> > Commit 963ecbd41a ("rhashtable: Fix use-after-free in rhashtable_walk_stop") is causing
> > RCU warnings since the code now locks a mutex (which might sleep) within an RCU critical
> > section within rhashtable_walk_stop().
> 
> OK I will add a spin lock to bucket_table for this.

---8<---
rhashtable: Fix sleeping inside RCU critical section in walk_stop

The commit 963ecbd41a1026d99ec7537c050867428c397b89 ("rhashtable:
Fix use-after-free in rhashtable_walk_stop") fixed a real bug
but created another one because we may end up sleeping inside an
RCU critical section.

This patch fixes it properly by replacing the mutex with a spin
lock that specifically protects the walker lists.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 57af1e9..14db673 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -133,6 +133,7 @@ struct rhashtable_params {
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
+ * @lock: Spin lock to protect walker list
  * @being_destroyed: True if table is set up for destruction
  */
 struct rhashtable {
@@ -144,6 +145,7 @@ struct rhashtable {
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
+	spinlock_t			lock;
 };
 
 /**
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 7686c1e..e96ad1a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -256,8 +256,10 @@ static int rhashtable_rehash_table(struct rhashtable *ht)
 	/* Publish the new table pointer. */
 	rcu_assign_pointer(ht->tbl, new_tbl);
 
+	spin_lock(&ht->lock);
 	list_for_each_entry(walker, &old_tbl->walkers, list)
 		walker->tbl = NULL;
+	spin_unlock(&ht->lock);
 
 	/* Wait for readers. All new readers will see the new
 	 * table, and thus no references to the old table will
@@ -635,12 +637,12 @@ void rhashtable_walk_stop(struct rhashtable_iter *iter)
 
 	ht = iter->ht;
 
-	mutex_lock(&ht->mutex);
+	spin_lock(&ht->lock);
 	if (tbl->rehash < tbl->size)
 		list_add(&iter->walker->list, &tbl->walkers);
 	else
 		iter->walker->tbl = NULL;
-	mutex_unlock(&ht->mutex);
+	spin_unlock(&ht->lock);
 
 	iter->p = NULL;
 
@@ -723,6 +725,7 @@ int rhashtable_init(struct rhashtable *ht,
 
 	memset(ht, 0, sizeof(*ht));
 	mutex_init(&ht->mutex);
+	spin_lock_init(&ht->lock);
 	memcpy(&ht->p, params, sizeof(*params));
 
 	if (params->min_size)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
