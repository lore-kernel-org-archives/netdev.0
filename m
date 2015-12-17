From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/4] cxgb4: Add API to alloc l2t entry; also update existing ones
Date: Thu, 17 Dec 2015 13:45:08 +0530
Message-ID: <1450340110-30031-3-git-send-email-hariprasad@chelsio.com>
References: <1450340110-30031-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:2519 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750837AbbLQIOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 03:14:05 -0500
In-Reply-To: <1450340110-30031-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Kumar Sanghvi <kumaras@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  10 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        | 125 +++++++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        |   7 +-
 3 files changed, 117 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index edd706e..8490c84 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1181,16 +1181,10 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
 	 */
 	if (f->fs.newdmac || f->fs.newvlan) {
 		/* allocate L2T entry for new filter */
-		f->l2t = t4_l2t_alloc_switching(adapter->l2t);
+		f->l2t = t4_l2t_alloc_switching(adapter, f->fs.vlan,
+						f->fs.eport, f->fs.dmac);
 		if (f->l2t == NULL) {
 			kfree_skb(skb);
-			return -EAGAIN;
-		}
-		if (t4_l2t_set_switching(adapter, f->l2t, f->fs.vlan,
-					f->fs.eport, f->fs.dmac)) {
-			cxgb4_l2t_release(f->l2t);
-			f->l2t = NULL;
-			kfree_skb(skb);
 			return -ENOMEM;
 		}
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 7234b82..d1b3b3a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -305,9 +305,82 @@ found:
 	return e;
 }
 
-/*
- * Called when an L2T entry has no more users.
+static struct l2t_entry *find_or_alloc_l2e(struct l2t_data *d, u16 vlan,
+					   u8 port, u8 *dmac)
+{
+	struct l2t_entry *end, *e, **p;
+	struct l2t_entry *first_free = NULL;
+
+	for (e = &d->l2tab[0], end = &d->l2tab[d->l2t_size]; e != end; ++e) {
+		if (atomic_read(&e->refcnt) == 0) {
+			if (!first_free)
+				first_free = e;
+		} else {
+			if (e->state == L2T_STATE_SWITCHING) {
+				if (ether_addr_equal(e->dmac, dmac) &&
+				    (e->vlan == vlan) && (e->lport == port))
+					goto exists;
+			}
+		}
+	}
+
+	if (first_free) {
+		e = first_free;
+		goto found;
+	}
+
+	return NULL;
+
+found:
+	/* The entry we found may be an inactive entry that is
+	 * presently in the hash table.  We need to remove it.
+	 */
+	if (e->state < L2T_STATE_SWITCHING)
+		for (p = &d->l2tab[e->hash].first; *p; p = &(*p)->next)
+			if (*p == e) {
+				*p = e->next;
+				e->next = NULL;
+				break;
+			}
+	e->state = L2T_STATE_UNUSED;
+
+exists:
+	return e;
+}
+
+/* Called when an L2T entry has no more users.  The entry is left in the hash
+ * table since it is likely to be reused but we also bump nfree to indicate
+ * that the entry can be reallocated for a different neighbor.  We also drop
+ * the existing neighbor reference in case the neighbor is going away and is
+ * waiting on our reference.
+ *
+ * Because entries can be reallocated to other neighbors once their ref count
+ * drops to 0 we need to take the entry's lock to avoid races with a new
+ * incarnation.
  */
+static void _t4_l2e_free(struct l2t_entry *e)
+{
+	struct l2t_data *d;
+
+	if (atomic_read(&e->refcnt) == 0) {  /* hasn't been recycled */
+		if (e->neigh) {
+			neigh_release(e->neigh);
+			e->neigh = NULL;
+		}
+		while (e->arpq_head) {
+			struct sk_buff *skb = e->arpq_head;
+
+			e->arpq_head = skb->next;
+			kfree_skb(skb);
+		}
+		e->arpq_tail = NULL;
+	}
+
+	d = container_of(e, struct l2t_data, l2tab[e->idx]);
+	atomic_inc(&d->nfree);
+}
+
+/* Locked version of _t4_l2e_free */
 static void t4_l2e_free(struct l2t_entry *e)
 {
 	struct l2t_data *d;
@@ -529,33 +602,57 @@ void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
  * explicitly freed and while busy they are not on any hash chain, so normal
  * address resolution updates do not see them.
  */
-struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d)
+struct l2t_entry *t4_l2t_alloc_switching(struct adapter *adap, u16 vlan,
+					 u8 port, u8 *eth_addr)
 {
+	struct l2t_data *d = adap->l2t;
 	struct l2t_entry *e;
+	int ret;
 
 	write_lock_bh(&d->lock);
-	e = alloc_l2e(d);
+	e = find_or_alloc_l2e(d, vlan, port, eth_addr);
 	if (e) {
 		spin_lock(&e->lock);          /* avoid race with t4_l2t_free */
-		e->state = L2T_STATE_SWITCHING;
-		atomic_set(&e->refcnt, 1);
+		if (!atomic_read(&e->refcnt)) {
+			e->state = L2T_STATE_SWITCHING;
+			e->vlan = vlan;
+			e->lport = port;
+			ether_addr_copy(e->dmac, eth_addr);
+			atomic_set(&e->refcnt, 1);
+			ret = write_l2e(adap, e, 0);
+			if (ret < 0) {
+				_t4_l2e_free(e);
+				spin_unlock(&e->lock);
+				write_unlock_bh(&d->lock);
+				return NULL;
+			}
+		} else {
+			atomic_inc(&e->refcnt);
+		}
+
 		spin_unlock(&e->lock);
 	}
 	write_unlock_bh(&d->lock);
 	return e;
 }
 
-/* Sets/updates the contents of a switching L2T entry that has been allocated
- * with an earlier call to @t4_l2t_alloc_switching.
+/**
+ * @dev: net_device pointer
+ * @vlan: VLAN Id
+ * @port: Associated port
+ * @dmac: Destination MAC address to add to L2T
+ * Returns pointer to the allocated l2t entry
+ *
+ * Allocates an L2T entry for use by switching rule of a filter
  */
-int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
-		u8 port, u8 *eth_addr)
+struct l2t_entry *cxgb4_l2t_alloc_switching(struct net_device *dev, u16 vlan,
+					    u8 port, u8 *dmac)
 {
-	e->vlan = vlan;
-	e->lport = port;
-	memcpy(e->dmac, eth_addr, ETH_ALEN);
-	return write_l2e(adap, e, 0);
+	struct adapter *adap = netdev2adap(dev);
+
+	return t4_l2t_alloc_switching(adap, vlan, port, dmac);
 }
+EXPORT_SYMBOL(cxgb4_l2t_alloc_switching);
 
 struct l2t_data *t4_init_l2t(unsigned int l2t_start, unsigned int l2t_end)
 {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.h b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
index b38dc52..17803a8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
@@ -114,10 +114,11 @@ struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
 				unsigned int priority);
 u64 cxgb4_select_ntuple(struct net_device *dev,
 			const struct l2t_entry *l2t);
+struct l2t_entry *cxgb4_l2t_alloc_switching(struct net_device *dev, u16 vlan,
+					    u8 port, u8 *dmac);
 void t4_l2t_update(struct adapter *adap, struct neighbour *neigh);
-struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d);
-int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
-			 u8 port, u8 *eth_addr);
+struct l2t_entry *t4_l2t_alloc_switching(struct adapter *adap, u16 vlan,
+					 u8 port, u8 *dmac);
 struct l2t_data *t4_init_l2t(unsigned int l2t_start, unsigned int l2t_end);
 void do_l2t_write_rpl(struct adapter *p, const struct cpl_l2t_write_rpl *rpl);
 
-- 
2.3.4
