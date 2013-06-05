From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] ipvs: use cond_resched_rcu() helper when walking connections
Date: Wed,  5 Jun 2013 22:40:28 +0200
Message-ID: <1370464832-4216-8-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57469 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120Ab3FEUlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 16:41:00 -0400
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

This avoids the situation where walking of a large number of connections
may prevent scheduling for a long time while also avoiding excessive
calls to rcu_read_unlock() and rcu_read_lock().

Note that in the case of !CONFIG_PREEMPT_RCU this will
add a call to cond_resched().

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_conn.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a083bda..c8c52a9 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -975,8 +975,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 				return cp;
 			}
 		}
-		rcu_read_unlock();
-		rcu_read_lock();
+		cond_resched_rcu();
 	}
 
 	return NULL;
@@ -1015,8 +1014,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 			iter->l = &ip_vs_conn_tab[idx];
 			return cp;
 		}
-		rcu_read_unlock();
-		rcu_read_lock();
+		cond_resched_rcu();
 	}
 	iter->l = NULL;
 	return NULL;
@@ -1206,17 +1204,13 @@ void ip_vs_random_dropentry(struct net *net)
 	int idx;
 	struct ip_vs_conn *cp, *cp_c;
 
+	rcu_read_lock();
 	/*
 	 * Randomly scan 1/32 of the whole table every second
 	 */
 	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
 		unsigned int hash = net_random() & ip_vs_conn_tab_mask;
 
-		/*
-		 *  Lock is actually needed in this loop.
-		 */
-		rcu_read_lock();
-
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
@@ -1252,8 +1246,9 @@ void ip_vs_random_dropentry(struct net *net)
 				__ip_vs_conn_put(cp);
 			}
 		}
-		rcu_read_unlock();
+		cond_resched_rcu();
 	}
+	rcu_read_unlock();
 }
 
 
@@ -1267,11 +1262,8 @@ static void ip_vs_conn_flush(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 flush_again:
+	rcu_read_lock();
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
-		/*
-		 *  Lock is actually needed in this loop.
-		 */
-		rcu_read_lock();
 
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
 			if (!ip_vs_conn_net_eq(cp, net))
@@ -1286,8 +1278,9 @@ flush_again:
 				__ip_vs_conn_put(cp);
 			}
 		}
-		rcu_read_unlock();
+		cond_resched_rcu();
 	}
+	rcu_read_unlock();
 
 	/* the counter may be not NULL, because maybe some conn entries
 	   are run by slow timer handler or unhashed but still referred */
-- 
1.7.10.4
