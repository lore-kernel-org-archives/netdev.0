From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 1/2] rhashtable: Fix use-after-free in rhashtable_walk_stop
Date: Sun, 15 Mar 2015 21:12:04 +1100
Message-ID: <E1YX5We-0005Zr-Ei@gondolin.me.apana.org.au>
References: <20150315101004.GA21383@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40700 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbbCOKMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit c4db8848af6af92f90462258603be844baeab44d ("rhashtable:
Move future_tbl into struct bucket_table") introduced a use-after-
free bug in rhashtable_walk_stop because it dereferences tbl after
droping the RCU read lock.

This patch fixes it by moving the RCU read unlock down to the bottom
of rhashtable_walk_stop.  In fact this was how I had it originally
but it got dropped while rearranging patches because this one
depended on the async freeing of bucket_table.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 9d53a46..b916679 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -854,10 +854,8 @@ void rhashtable_walk_stop(struct rhashtable_iter *iter)
 	struct rhashtable *ht;
 	struct bucket_table *tbl = iter->walker->tbl;
 
-	rcu_read_unlock();
-
 	if (!tbl)
-		return;
+		goto out;
 
 	ht = iter->ht;
 
@@ -869,6 +867,9 @@ void rhashtable_walk_stop(struct rhashtable_iter *iter)
 	mutex_unlock(&ht->mutex);
 
 	iter->p = NULL;
+
+out:
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
 
