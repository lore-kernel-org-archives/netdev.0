From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 8/8][ATM]: [lec] use refcnt to protect lec_arp_entries outside lock
Date: Fri, 29 Sep 2006 12:45:26 -0400
Message-ID: <200609291645.k8TGjQ6s025651@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:5853 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161237AbWI2Qpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:45:43 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] use refcnt to protect lec_arp_entries outside lock

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 74391472d01cdd483714b807c9417a0279ed75d5
tree a191d09973b569f0562d9d433c324bbe80a08560
parent 397725689277192a899da4009cd078bab8f6ee2d
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Mon, 25 Sep 2006 22:07:01 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Mon, 25 Sep 2006 22:07:01 -0400

 net/atm/lec.c |   34 ++++++++++++++++++++++++----------
 1 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index c865f68..9e635a0 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -396,7 +396,7 @@ #endif
 			priv->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 		}
-		return 0;
+		goto out;
 	}
 #if DUMP_PACKETS > 0
 	printk("%s:sending to vpi:%d vci:%d\n", dev->name, vcc->vpi, vcc->vci);
@@ -428,6 +428,9 @@ #endif /* DUMP_PACKETS > 0 */
 			netif_wake_queue(dev);
 	}
 
+out:
+	if (entry)
+		lec_arp_put(entry);
 	dev->trans_start = jiffies;
 	return 0;
 }
@@ -1888,6 +1891,7 @@ static void lec_arp_check_expire(void *d
 
 	DPRINTK("lec_arp_check_expire %p\n", priv);
 	now = jiffies;
+restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
@@ -1927,14 +1931,16 @@ static void lec_arp_check_expire(void *d
 				    time_after_eq(now, entry->timestamp +
 						  priv->path_switching_delay)) {
 					struct sk_buff *skb;
+					struct atm_vcc *vcc = entry->vcc;
 
-					while ((skb =
-						skb_dequeue(&entry->tx_wait)) !=
-					       NULL)
-						lec_send(entry->vcc, skb,
-							 entry->priv);
+					lec_arp_hold(entry);
+					spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+					while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
+						lec_send(vcc, skb, entry->priv);
 					entry->last_used = jiffies;
 					entry->status = ESI_FORWARD_DIRECT;
+					lec_arp_put(entry);
+					goto restart;
 				}
 			}
 		}
@@ -1977,6 +1983,7 @@ static struct atm_vcc *lec_arp_resolve(s
 		if (entry->status == ESI_FORWARD_DIRECT) {
 			/* Connection Ok */
 			entry->last_used = jiffies;
+			lec_arp_hold(entry);
 			*ret_entry = entry;
 			found = entry->vcc;
 			goto out;
@@ -2007,6 +2014,7 @@ static struct atm_vcc *lec_arp_resolve(s
 		 * or BUS flood limit was reached for an entry which is
 		 * in ESI_ARP_PENDING or ESI_VC_PENDING state.
 		 */
+		lec_arp_hold(entry);
 		*ret_entry = entry;
 		DPRINTK("lec: entry->status %d entry->vcc %p\n", entry->status,
 			entry->vcc);
@@ -2335,18 +2343,24 @@ static void lec_flush_complete(struct le
 	int i;
 
 	DPRINTK("LEC:lec_flush_complete %lx\n", tran_id);
+restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
 			if (entry->flush_tran_id == tran_id
 			    && entry->status == ESI_FLUSH_PENDING) {
 				struct sk_buff *skb;
+				struct atm_vcc *vcc = entry->vcc;
 
-				while ((skb =
-					skb_dequeue(&entry->tx_wait)) != NULL)
-					lec_send(entry->vcc, skb, entry->priv);
+				lec_arp_hold(entry);
+				spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+				while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
+					lec_send(vcc, skb, entry->priv);
+				entry->last_used = jiffies;
 				entry->status = ESI_FORWARD_DIRECT;
+				lec_arp_put(entry);
 				DPRINTK("LEC_ARP: Flushed\n");
+				goto restart;
 			}
 		}
 	}
