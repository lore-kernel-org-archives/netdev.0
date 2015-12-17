From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 4/4] cxgb4: Replace arpq_head/arpq_tail with  SKB double link-list code
Date: Thu, 17 Dec 2015 13:45:10 +0530
Message-ID: <1450340110-30031-5-git-send-email-hariprasad@chelsio.com>
References: <1450340110-30031-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:61011 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752048AbbLQIOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 03:14:17 -0500
In-Reply-To: <1450340110-30031-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Michael Werner <werner@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/l2t.c | 61 ++++++++++++--------------------
 drivers/net/ethernet/chelsio/cxgb4/l2t.h |  3 +-
 2 files changed, 24 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 81af78e..5b0f3ef 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -174,14 +174,10 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
  */
 static void send_pending(struct adapter *adap, struct l2t_entry *e)
 {
-	while (e->arpq_head) {
-		struct sk_buff *skb = e->arpq_head;
+	struct sk_buff *skb;
 
-		e->arpq_head = skb->next;
-		skb->next = NULL;
+	while ((skb = __skb_dequeue(&e->arpq)) != NULL)
 		t4_ofld_send(adap, skb);
-	}
-	e->arpq_tail = NULL;
 }
 
 /*
@@ -221,12 +217,7 @@ void do_l2t_write_rpl(struct adapter *adap, const struct cpl_l2t_write_rpl *rpl)
  */
 static inline void arpq_enqueue(struct l2t_entry *e, struct sk_buff *skb)
 {
-	skb->next = NULL;
-	if (e->arpq_head)
-		e->arpq_tail->next = skb;
-	else
-		e->arpq_head = skb;
-	e->arpq_tail = skb;
+	__skb_queue_tail(&e->arpq, skb);
 }
 
 int cxgb4_l2t_send(struct net_device *dev, struct sk_buff *skb,
@@ -258,7 +249,8 @@ again:
 		if (e->state == L2T_STATE_RESOLVING &&
 		    !neigh_event_send(e->neigh, NULL)) {
 			spin_lock_bh(&e->lock);
-			if (e->state == L2T_STATE_RESOLVING && e->arpq_head)
+			if (e->state == L2T_STATE_RESOLVING &&
+			    !skb_queue_empty(&e->arpq))
 				write_l2e(adap, e, 1);
 			spin_unlock_bh(&e->lock);
 		}
@@ -360,19 +352,15 @@ exists:
 static void _t4_l2e_free(struct l2t_entry *e)
 {
 	struct l2t_data *d;
+	struct sk_buff *skb;
 
 	if (atomic_read(&e->refcnt) == 0) {  /* hasn't been recycled */
 		if (e->neigh) {
 			neigh_release(e->neigh);
 			e->neigh = NULL;
 		}
-		while (e->arpq_head) {
-			struct sk_buff *skb = e->arpq_head;
-
-			e->arpq_head = skb->next;
+		while ((skb = __skb_dequeue(&e->arpq)) != NULL)
 			kfree_skb(skb);
-		}
-		e->arpq_tail = NULL;
 	}
 
 	d = container_of(e, struct l2t_data, l2tab[e->idx]);
@@ -383,6 +371,7 @@ static void _t4_l2e_free(struct l2t_entry *e)
 static void t4_l2e_free(struct l2t_entry *e)
 {
 	struct l2t_data *d;
+	struct sk_buff *skb;
 
 	spin_lock_bh(&e->lock);
 	if (atomic_read(&e->refcnt) == 0) {  /* hasn't been recycled */
@@ -390,13 +379,8 @@ static void t4_l2e_free(struct l2t_entry *e)
 			neigh_release(e->neigh);
 			e->neigh = NULL;
 		}
-		while (e->arpq_head) {
-			struct sk_buff *skb = e->arpq_head;
-
-			e->arpq_head = skb->next;
+		while ((skb = __skb_dequeue(&e->arpq)) != NULL)
 			kfree_skb(skb);
-		}
-		e->arpq_tail = NULL;
 	}
 	spin_unlock_bh(&e->lock);
 
@@ -529,18 +513,19 @@ EXPORT_SYMBOL(cxgb4_select_ntuple);
  * on the arpq head.  If a packet specifies a failure handler it is invoked,
  * otherwise the packet is sent to the device.
  */
-static void handle_failed_resolution(struct adapter *adap, struct sk_buff *arpq)
+static void handle_failed_resolution(struct adapter *adap, struct l2t_entry *e)
 {
-	while (arpq) {
-		struct sk_buff *skb = arpq;
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&e->arpq)) != NULL) {
 		const struct l2t_skb_cb *cb = L2T_SKB_CB(skb);
 
-		arpq = skb->next;
-		skb->next = NULL;
+		spin_unlock(&e->lock);
 		if (cb->arp_err_handler)
 			cb->arp_err_handler(cb->handle, skb);
 		else
 			t4_ofld_send(adap, skb);
+		spin_lock(&e->lock);
 	}
 }
 
@@ -551,7 +536,7 @@ static void handle_failed_resolution(struct adapter *adap, struct sk_buff *arpq)
 void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
 {
 	struct l2t_entry *e;
-	struct sk_buff *arpq = NULL;
+	struct sk_buff_head *arpq = NULL;
 	struct l2t_data *d = adap->l2t;
 	int addr_len = neigh->tbl->key_len;
 	u32 *addr = (u32 *) neigh->primary_key;
@@ -578,10 +563,9 @@ void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
 
 	if (e->state == L2T_STATE_RESOLVING) {
 		if (neigh->nud_state & NUD_FAILED) {
-			arpq = e->arpq_head;
-			e->arpq_head = e->arpq_tail = NULL;
+			arpq = &e->arpq;
 		} else if ((neigh->nud_state & (NUD_CONNECTED | NUD_STALE)) &&
-			   e->arpq_head) {
+			   !skb_queue_empty(&e->arpq)) {
 			write_l2e(adap, e, 1);
 		}
 	} else {
@@ -591,10 +575,9 @@ void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
 			write_l2e(adap, e, 0);
 	}
 
-	spin_unlock_bh(&e->lock);
-
 	if (arpq)
-		handle_failed_resolution(adap, arpq);
+		handle_failed_resolution(adap, e);
+	spin_unlock_bh(&e->lock);
 }
 
 /* Allocate an L2T entry for use by a switching rule.  Such need to be
@@ -681,6 +664,7 @@ struct l2t_data *t4_init_l2t(unsigned int l2t_start, unsigned int l2t_end)
 		d->l2tab[i].state = L2T_STATE_UNUSED;
 		spin_lock_init(&d->l2tab[i].lock);
 		atomic_set(&d->l2tab[i].refcnt, 0);
+		skb_queue_head_init(&d->l2tab[i].arpq);
 	}
 	return d;
 }
@@ -715,7 +699,8 @@ static char l2e_state(const struct l2t_entry *e)
 	case L2T_STATE_VALID: return 'V';
 	case L2T_STATE_STALE: return 'S';
 	case L2T_STATE_SYNC_WRITE: return 'W';
-	case L2T_STATE_RESOLVING: return e->arpq_head ? 'A' : 'R';
+	case L2T_STATE_RESOLVING:
+		return skb_queue_empty(&e->arpq) ? 'R' : 'A';
 	case L2T_STATE_SWITCHING: return 'X';
 	default:
 		return 'U';
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.h b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
index 17803a8..4e2d47a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
@@ -76,8 +76,7 @@ struct l2t_entry {
 	struct neighbour *neigh;    /* associated neighbour */
 	struct l2t_entry *first;    /* start of hash chain */
 	struct l2t_entry *next;     /* next l2t_entry on chain */
-	struct sk_buff *arpq_head;  /* queue of packets awaiting resolution */
-	struct sk_buff *arpq_tail;
+	struct sk_buff_head arpq;   /* packet queue awaiting resolution */
 	spinlock_t lock;
 	atomic_t refcnt;            /* entry reference count */
 	u16 hash;                   /* hash bucket the entry is on */
-- 
2.3.4
