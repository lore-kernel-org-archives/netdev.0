From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 7/8][ATM]: [lec] add reference counting to lec_arp entries
Date: Fri, 29 Sep 2006 12:45:01 -0400
Message-ID: <200609291645.k8TGj1pc025637@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:4061 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161229AbWI2QpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:45:19 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] add reference counting to lec_arp entries

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 397725689277192a899da4009cd078bab8f6ee2d
tree 3bba44e1549229947ed332bb6263c704cabd55c7
parent 0152dcfb9d42e203ff26d1619158c9664cfbf2d9
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Mon, 25 Sep 2006 07:28:18 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Mon, 25 Sep 2006 07:28:18 -0400

 net/atm/lec.c      |   42 ++++++++++++++++++++++++++++--------------
 net/atm/lec_arpc.h |    1 +
 2 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 8a9f9ab..c865f68 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -107,6 +107,19 @@ static void lec_vcc_added(struct lec_pri
 					    struct sk_buff *skb));
 static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc);
 
+/* must be done under lec_arp_lock */
+static inline void lec_arp_hold(struct lec_arp_table *entry)
+{
+	atomic_inc(&entry->usage);
+}
+
+static inline void lec_arp_put(struct lec_arp_table *entry)
+{
+	if (atomic_dec_and_test(&entry->usage))
+		kfree(entry);
+}
+
+
 static struct lane2_ops lane2_ops = {
 	lane2_resolve,		/* resolve,             spec 3.1.3 */
 	lane2_associate_req,	/* associate_req,       spec 3.1.4 */
@@ -795,7 +808,7 @@ #endif
 			entry = lec_arp_find(priv, src);
 			if (entry && entry->vcc != vcc) {
 				lec_arp_remove(priv, entry);
-				kfree(entry);
+				lec_arp_put(entry);
 			}
 		}
 		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
@@ -1726,7 +1739,7 @@ static void lec_arp_destroy(struct lec_p
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
 			lec_arp_remove(priv, entry);
-			kfree(entry);
+			lec_arp_put(entry);
 		}
 		INIT_HLIST_HEAD(&priv->lec_arp_tables[i]);
 	}
@@ -1735,7 +1748,7 @@ static void lec_arp_destroy(struct lec_p
 		del_timer_sync(&entry->timer);
 		lec_arp_clear_vccs(entry);
 		hlist_del(&entry->next);
-		kfree(entry);
+		lec_arp_put(entry);
 	}
 	INIT_HLIST_HEAD(&priv->lec_arp_empty_ones);
 	
@@ -1743,7 +1756,7 @@ static void lec_arp_destroy(struct lec_p
 		del_timer_sync(&entry->timer);
 		lec_arp_clear_vccs(entry);
 		hlist_del(&entry->next);
-		kfree(entry);
+		lec_arp_put(entry);
 	}
 	INIT_HLIST_HEAD(&priv->lec_no_forward);
 
@@ -1751,7 +1764,7 @@ static void lec_arp_destroy(struct lec_p
 		/* No timer, LANEv2 7.1.20 and 2.3.5.3 */
 		lec_arp_clear_vccs(entry);
 		hlist_del(&entry->next);
-		kfree(entry);
+		lec_arp_put(entry);
 	}
 	INIT_HLIST_HEAD(&priv->mcast_fwds);
 	priv->mcast_vcc = NULL;
@@ -1799,6 +1812,7 @@ static struct lec_arp_table *make_entry(
 	to_return->last_used = jiffies;
 	to_return->priv = priv;
 	skb_queue_head_init(&to_return->tx_wait);
+	atomic_set(&to_return->usage, 1);
 	return to_return;
 }
 
@@ -1843,7 +1857,7 @@ static void lec_arp_expire_vcc(unsigned 
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
 	lec_arp_clear_vccs(to_remove);
-	kfree(to_remove);
+	lec_arp_put(to_remove);
 }
 
 /*
@@ -1891,7 +1905,7 @@ static void lec_arp_check_expire(void *d
 				/* Remove entry */
 				DPRINTK("LEC:Entry timed out\n");
 				lec_arp_remove(priv, entry);
-				kfree(entry);
+				lec_arp_put(entry);
 			} else {
 				/* Something else */
 				if ((entry->status == ESI_VC_PENDING ||
@@ -2045,7 +2059,7 @@ lec_addr_delete(struct lec_priv *priv, u
 			    && (permanent ||
 				!(entry->flags & LEC_PERMANENT_FLAG))) {
 				lec_arp_remove(priv, entry);
-				kfree(entry);
+				lec_arp_put(entry);
 			}
 			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 			return 0;
@@ -2094,7 +2108,7 @@ lec_arp_update(struct lec_priv *priv, un
 					tmp->old_push = entry->old_push;
 					tmp->last_used = jiffies;
 					del_timer(&entry->timer);
-					kfree(entry);
+					lec_arp_put(entry);
 					entry = tmp;
 				} else {
 					entry->status = ESI_FORWARD_DIRECT;
@@ -2414,7 +2428,7 @@ static void lec_vcc_close(struct lec_pri
 		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
 			if (vcc == entry->vcc) {
 				lec_arp_remove(priv, entry);
-				kfree(entry);
+				lec_arp_put(entry);
 				if (priv->mcast_vcc == vcc) {
 					priv->mcast_vcc = NULL;
 				}
@@ -2427,7 +2441,7 @@ static void lec_vcc_close(struct lec_pri
 			lec_arp_clear_vccs(entry);
 			del_timer(&entry->timer);
 			hlist_del(&entry->next);
-			kfree(entry);
+			lec_arp_put(entry);
 		}
 	}
 
@@ -2436,7 +2450,7 @@ static void lec_vcc_close(struct lec_pri
 			lec_arp_clear_vccs(entry);
 			del_timer(&entry->timer);
 			hlist_del(&entry->next);
-			kfree(entry);
+			lec_arp_put(entry);
 		}
 	}
 
@@ -2445,7 +2459,7 @@ static void lec_vcc_close(struct lec_pri
 			lec_arp_clear_vccs(entry);
 			/* No timer, LANEv2 7.1.20 and 2.3.5.3 */
 			hlist_del(&entry->next);
-			kfree(entry);
+			lec_arp_put(entry);
 		}
 	}
 
@@ -2481,7 +2495,7 @@ #endif
 			/* We might have got an entry */
 			if ((tmp = lec_arp_find(priv, src))) {
 				lec_arp_remove(priv, tmp);
-				kfree(tmp);
+				lec_arp_put(tmp);
 			}
 			hlist_del(&entry->next);
 			lec_arp_add(priv, entry);
diff --git a/net/atm/lec_arpc.h b/net/atm/lec_arpc.h
index 69aeb07..c9c9d8f 100644
--- a/net/atm/lec_arpc.h
+++ b/net/atm/lec_arpc.h
@@ -47,6 +47,7 @@ struct lec_arp_table {
 					 * the length of the tlvs array
 					 */
 	struct sk_buff_head tx_wait;	/* wait queue for outgoing packets */
+	atomic_t usage;			/* usage count */
 };
 
 /*
