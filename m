From: David Miller <davem@davemloft.net>
Subject: [PATCH] inetpeer: Don't disable BH for initial fast RCU lookup.
Date: Tue, 08 Mar 2011 14:59:54 -0800 (PST)
Message-ID: <20110308.145954.59682618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755297Ab1CHW7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 17:59:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If modifications on other cpus are ok, then modifications to
the tree during lookup done by the local cpu are ok too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inetpeer.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index f604ffd..6442c35 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -206,16 +206,16 @@ static int addr_compare(const struct inetpeer_addr *a,
 })
 
 /*
- * Called with rcu_read_lock_bh()
+ * Called with rcu_read_lock()
  * Because we hold no lock against a writer, its quite possible we fall
  * in an endless loop.
  * But every pointer we follow is guaranteed to be valid thanks to RCU.
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
-static struct inet_peer *lookup_rcu_bh(const struct inetpeer_addr *daddr,
-				       struct inet_peer_base *base)
+static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
+				    struct inet_peer_base *base)
 {
-	struct inet_peer *u = rcu_dereference_bh(base->root);
+	struct inet_peer *u = rcu_dereference(base->root);
 	int count = 0;
 
 	while (u != peer_avl_empty) {
@@ -231,9 +231,9 @@ static struct inet_peer *lookup_rcu_bh(const struct inetpeer_addr *daddr,
 			return u;
 		}
 		if (cmp == -1)
-			u = rcu_dereference_bh(u->avl_left);
+			u = rcu_dereference(u->avl_left);
 		else
-			u = rcu_dereference_bh(u->avl_right);
+			u = rcu_dereference(u->avl_right);
 		if (unlikely(++count == PEER_MAXDEPTH))
 			break;
 	}
@@ -470,11 +470,11 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 	/* Look up for the address quickly, lockless.
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
-	rcu_read_lock_bh();
+	rcu_read_lock();
 	sequence = read_seqbegin(&base->lock);
-	p = lookup_rcu_bh(daddr, base);
+	p = lookup_rcu(daddr, base);
 	invalidated = read_seqretry(&base->lock, sequence);
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	if (p) {
 		/* The existing node has been found.
-- 
1.7.4.1

