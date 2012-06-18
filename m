From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 18/19] batman-adv: fix locking in hash_add()
Date: Mon, 18 Jun 2012 22:39:22 +0200
Message-ID: <1340051963-14836-19-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41795 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab2FRUjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:19 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

To ensure an entry isn't added twice all comparisons have to be protected by the
hash line write spinlock. This doesn't really hurt as the case that it is tried
to add an element already present to the hash shouldn't occur very often, so in
most cases the lock would have have to be taken anyways.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Acked-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hash.h |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 93b3c71..3d67ce4 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -110,26 +110,23 @@ static inline int hash_add(struct hashtable_t *hash,
 	head = &hash->table[index];
 	list_lock = &hash->list_locks[index];
 
-	rcu_read_lock();
-	__hlist_for_each_rcu(node, head) {
+	spin_lock_bh(list_lock);
+
+	hlist_for_each(node, head) {
 		if (!compare(node, data))
 			continue;
 
 		ret = 1;
-		goto err_unlock;
+		goto unlock;
 	}
-	rcu_read_unlock();
 
 	/* no duplicate found in list, add new element */
-	spin_lock_bh(list_lock);
 	hlist_add_head_rcu(data_node, head);
-	spin_unlock_bh(list_lock);
 
 	ret = 0;
-	goto out;
 
-err_unlock:
-	rcu_read_unlock();
+unlock:
+	spin_unlock_bh(list_lock);
 out:
 	return ret;
 }
-- 
1.7.9.4
