From: Joe Perches <joe@perches.com>
Subject: [PATCH 20/20] net/atm/lec.c: Add __lec_arp_check_expire and other cleanups
Date: Mon,  7 Dec 2009 21:57:16 -0800
Message-ID: <f706588f30ade06dc115fb66e259c0f0de9a8b43.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1061 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932696AbZLHF5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:15 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce indentation in lec_arp_check_expire
Indent a case label
Remove != NULL logical tests from while ((skb = foo())) assign and tests

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/lec.c |  153 ++++++++++++++++++++++++++++++---------------------------
 1 files changed, 80 insertions(+), 73 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 92f536c..584b8a5 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -286,7 +286,6 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 
 	/* Make sure we have room for lec_id */
 	if (skb_headroom(skb) < 2) {
-
 		pr_debug("reallocating skb\n");
 		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
 		kfree_skb(skb);
@@ -509,34 +508,31 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 		break;
 	case l_should_bridge:
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-		{
-			pr_debug("%s: bridge zeppelin asks about %pM\n",
-				 dev->name, mesg->content.proxy.mac_addr);
+	{
+		pr_debug("%s: bridge zeppelin asks about %pM\n",
+			 dev->name, mesg->content.proxy.mac_addr);
 
-			if (br_fdb_test_addr_hook == NULL)
-				break;
+		if (br_fdb_test_addr_hook == NULL)
+			break;
 
-			if (br_fdb_test_addr_hook(dev,
-						  mesg->content.proxy.mac_addr)) {
-				/* hit from bridge table, send LE_ARP_RESPONSE */
-				struct sk_buff *skb2;
-				struct sock *sk;
-
-				pr_debug("%s: entry found, responding to zeppelin\n",
-					 dev->name);
-				skb2 = alloc_skb(sizeof(struct atmlec_msg),
-						 GFP_ATOMIC);
-				if (skb2 == NULL)
-					break;
-				skb2->len = sizeof(struct atmlec_msg);
-				skb_copy_to_linear_data(skb2, mesg,
-							sizeof(*mesg));
-				atm_force_charge(priv->lecd, skb2->truesize);
-				sk = sk_atm(priv->lecd);
-				skb_queue_tail(&sk->sk_receive_queue, skb2);
-				sk->sk_data_ready(sk, skb2->len);
-			}
+		if (br_fdb_test_addr_hook(dev, mesg->content.proxy.mac_addr)) {
+			/* hit from bridge table, send LE_ARP_RESPONSE */
+			struct sk_buff *skb2;
+			struct sock *sk;
+
+			pr_debug("%s: entry found, responding to zeppelin\n",
+				 dev->name);
+			skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
+			if (skb2 == NULL)
+				break;
+			skb2->len = sizeof(struct atmlec_msg);
+			skb_copy_to_linear_data(skb2, mesg, sizeof(*mesg));
+			atm_force_charge(priv->lecd, skb2->truesize);
+			sk = sk_atm(priv->lecd);
+			skb_queue_tail(&sk->sk_receive_queue, skb2);
+			sk->sk_data_ready(sk, skb2->len);
 		}
+	}
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
 		break;
 	default:
@@ -562,7 +558,7 @@ static void lec_atm_close(struct atm_vcc *vcc)
 
 	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		pr_info("%s closing with messages pending\n", dev->name);
-	while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue)) != NULL) {
+	while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue))) {
 		atm_return(vcc, skb->truesize);
 		dev_kfree_skb(skb);
 	}
@@ -1756,6 +1752,50 @@ static void lec_arp_expire_vcc(unsigned long data)
 	lec_arp_put(to_remove);
 }
 
+static bool __lec_arp_check_expire(struct lec_arp_table *entry,
+				   unsigned long now,
+				   struct lec_priv *priv)
+{
+	unsigned long time_to_check;
+
+	if ((entry->flags) & LEC_REMOTE_FLAG && priv->topology_change)
+		time_to_check = priv->forward_delay_time;
+	else
+		time_to_check = priv->aging_time;
+
+	pr_debug("About to expire: %lx - %lx > %lx\n",
+		 now, entry->last_used, time_to_check);
+	if (time_after(now, entry->last_used + time_to_check) &&
+	    !(entry->flags & LEC_PERMANENT_FLAG) &&
+	    !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
+		/* Remove entry */
+		pr_debug("Entry timed out\n");
+		lec_arp_remove(priv, entry);
+		lec_arp_put(entry);
+	} else {
+		/* Something else */
+		if ((entry->status == ESI_VC_PENDING ||
+		     entry->status == ESI_ARP_PENDING) &&
+		    time_after_eq(now, entry->timestamp +
+				       priv->max_unknown_frame_time)) {
+			entry->timestamp = jiffies;
+			entry->packets_flooded = 0;
+			if (entry->status == ESI_VC_PENDING)
+				send_to_lecd(priv, l_svc_setup,
+					     entry->mac_addr,
+					     entry->atm_addr,
+					     NULL);
+		}
+		if (entry->status == ESI_FLUSH_PENDING &&
+		    time_after_eq(now, entry->timestamp +
+				       priv->path_switching_delay)) {
+			lec_arp_hold(entry);
+			return true;
+		}
+	}
+
+	return false;
+}
 /*
  * Expire entries.
  * 1. Re-set timer
@@ -1780,7 +1820,6 @@ static void lec_arp_check_expire(struct work_struct *work)
 	struct hlist_node *node, *next;
 	struct lec_arp_table *entry;
 	unsigned long now;
-	unsigned long time_to_check;
 	int i;
 
 	pr_debug("%p\n", priv);
@@ -1790,51 +1829,19 @@ restart:
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry_safe(entry, node, next,
 					  &priv->lec_arp_tables[i], next) {
-			if ((entry->flags) & LEC_REMOTE_FLAG &&
-			    priv->topology_change)
-				time_to_check = priv->forward_delay_time;
-			else
-				time_to_check = priv->aging_time;
-
-			pr_debug("About to expire: %lx - %lx > %lx\n",
-				 now, entry->last_used, time_to_check);
-			if (time_after(now, entry->last_used + time_to_check) &&
-			    !(entry->flags & LEC_PERMANENT_FLAG) &&
-			    !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
-				/* Remove entry */
-				pr_debug("Entry timed out\n");
-				lec_arp_remove(priv, entry);
+			if (__lec_arp_check_expire(entry, now, priv)) {
+				struct sk_buff *skb;
+				struct atm_vcc *vcc = entry->vcc;
+
+				spin_unlock_irqrestore(&priv->lec_arp_lock,
+						       flags);
+				while ((skb = skb_dequeue(&entry->tx_wait)))
+					lec_send(vcc, skb);
+				entry->last_used = jiffies;
+				entry->status = ESI_FORWARD_DIRECT;
 				lec_arp_put(entry);
-			} else {
-				/* Something else */
-				if ((entry->status == ESI_VC_PENDING ||
-				     entry->status == ESI_ARP_PENDING) &&
-				    time_after_eq(now,
-						  entry->timestamp +
-						  priv->max_unknown_frame_time)) {
-					entry->timestamp = jiffies;
-					entry->packets_flooded = 0;
-					if (entry->status == ESI_VC_PENDING)
-						send_to_lecd(priv, l_svc_setup,
-							     entry->mac_addr,
-							     entry->atm_addr,
-							     NULL);
-				}
-				if (entry->status == ESI_FLUSH_PENDING &&
-				    time_after_eq(now, entry->timestamp +
-						  priv->path_switching_delay)) {
-					struct sk_buff *skb;
-					struct atm_vcc *vcc = entry->vcc;
-
-					lec_arp_hold(entry);
-					spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-					while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
-						lec_send(vcc, skb);
-					entry->last_used = jiffies;
-					entry->status = ESI_FORWARD_DIRECT;
-					lec_arp_put(entry);
-					goto restart;
-				}
+
+				goto restart;
 			}
 		}
 	}
@@ -2245,7 +2252,7 @@ restart:
 				lec_arp_hold(entry);
 				spin_unlock_irqrestore(&priv->lec_arp_lock,
 						       flags);
-				while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
+				while ((skb = skb_dequeue(&entry->tx_wait)))
 					lec_send(vcc, skb);
 				entry->last_used = jiffies;
 				entry->status = ESI_FORWARD_DIRECT;
-- 
1.6.6.rc0.57.gad7a

