From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 6/7] net: Use rcu lookups in inet_twsk_purge.
Date: Thu,  3 Dec 2009 04:29:08 -0800
Message-ID: <1259843349-3810-6-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56949 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbZLCM32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:28 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

While we are looking up entries to free there is no reason to take
the lock in inet_twsk_purge.  We have to drop locks and restart
occassionally anyway so adding a few more in case we get on the
wrong list because of a timewait move is no big deal.  At the
same time not taking the lock for long periods of time is much
more polite to the rest of the users of the hash table.

In my test configuration of killing 4k network namespaces
this change causes 4k back to back runs of inet_twsk_purge on an
empty hash table to go from roughly 20.7s to 3.3s, and the total
time to destroy 4k network namespaces goes from roughly 44s to
3.3s.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/inet_timewait_sock.c |   39 ++++++++++++++++++++++++---------------
 1 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 1f5d508..683ecec 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -427,31 +427,40 @@ void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
 	struct inet_timewait_sock *tw;
 	struct sock *sk;
 	struct hlist_nulls_node *node;
-	int h;
+	unsigned int slot;
 
-	local_bh_disable();
-	for (h = 0; h <= hashinfo->ehash_mask; h++) {
-		struct inet_ehash_bucket *head =
-			inet_ehash_bucket(hashinfo, h);
-		spinlock_t *lock = inet_ehash_lockp(hashinfo, h);
+	for (slot = 0; slot <= hashinfo->ehash_mask; slot++) {
+		struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
+restart_rcu:
+		rcu_read_lock();
 restart:
-		spin_lock(lock);
-		sk_nulls_for_each(sk, node, &head->twchain) {
-
+		sk_nulls_for_each_rcu(sk, node, &head->twchain) {
 			tw = inet_twsk(sk);
 			if (!net_eq(twsk_net(tw), net) ||
 			    tw->tw_family != family)
 				continue;
 
-			atomic_inc(&tw->tw_refcnt);
-			spin_unlock(lock);
+			if (unlikely(!atomic_inc_not_zero(&tw->tw_refcnt)))
+				continue;
+
+			if (unlikely(!net_eq(twsk_net(tw), net) ||
+				     tw->tw_family != family)) {
+				inet_twsk_put(tw);
+				goto restart;
+			}
+			
+			rcu_read_unlock();
 			inet_twsk_deschedule(tw, twdr);
 			inet_twsk_put(tw);
-
-			goto restart;
+			goto restart_rcu;
 		}
-		spin_unlock(lock);
+		/* If the nulls value we got at the end of this lookup is
+		 * not the expected one, we must restart lookup.
+		 * We probably met an item that was moved to another chain.
+		 */
+		if (get_nulls_value(node) != slot)
+			goto restart;
+		rcu_read_unlock();
 	}
-	local_bh_enable();
 }
 EXPORT_SYMBOL_GPL(inet_twsk_purge);
-- 
1.6.5.2.143.g8cc62

