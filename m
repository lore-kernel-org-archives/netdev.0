From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/9] cxgb3: Rework t3_l2t_get to take a dst_entry instead
 of a neighbour.
Date: Fri, 02 Dec 2011 21:52:18 -0500 (EST)
Message-ID: <20111202.215218.1782887284684255091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab1LCCwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This way we consolidate the RCU locking down into the place where it
actually matters, and also we can make the code handle
dst_get_neighbour_noref() returning NULL properly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/cxgb3/iwch_cm.c              |   15 +---------
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/l2t.c           |   27 ++++++++++++++-----
 drivers/net/ethernet/chelsio/cxgb3/l2t.h           |    2 +-
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c                 |    2 +-
 5 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 23686df..740dcc0 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1338,7 +1338,6 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 	struct iwch_ep *child_ep, *parent_ep = ctx;
 	struct cpl_pass_accept_req *req = cplhdr(skb);
 	unsigned int hwtid = GET_TID(req);
-	struct neighbour *neigh;
 	struct dst_entry *dst;
 	struct l2t_entry *l2t;
 	struct rtable *rt;
@@ -1375,10 +1374,7 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		goto reject;
 	}
 	dst = &rt->dst;
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
-	l2t = t3_l2t_get(tdev, neigh, neigh->dev);
-	rcu_read_unlock();
+	l2t = t3_l2t_get(tdev, dst, NULL);
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1889,7 +1885,6 @@ static int is_loopback_dst(struct iw_cm_id *cm_id)
 int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 {
 	struct iwch_dev *h = to_iwch_dev(cm_id->device);
-	struct neighbour *neigh;
 	struct iwch_ep *ep;
 	struct rtable *rt;
 	int err = 0;
@@ -1947,13 +1942,7 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		goto fail3;
 	}
 	ep->dst = &rt->dst;
-
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(ep->dst);
-
-	/* get a l2t entry */
-	ep->l2t = t3_l2t_get(ep->com.tdev, neigh, neigh->dev);
-	rcu_read_unlock();
+	ep->l2t = t3_l2t_get(ep->com.tdev, ep->dst, NULL);
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 6ed9f87..596cfe3 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1132,7 +1132,7 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	}
 
 	/* Add new L2T entry */
-	e = t3_l2t_get(tdev, dst_get_neighbour_noref(new), newdev);
+	e = t3_l2t_get(tdev, new, newdev);
 	if (!e) {
 		printk(KERN_ERR "%s: couldn't allocate new l2t entry!\n",
 		       __func__);
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
index 70fec8b..3fa3c88 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
@@ -298,18 +298,31 @@ static inline void reuse_entry(struct l2t_entry *e, struct neighbour *neigh)
 	spin_unlock(&e->lock);
 }
 
-struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
+struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
 			     struct net_device *dev)
 {
 	struct l2t_entry *e = NULL;
+	struct neighbour *neigh;
+	struct port_info *p;
 	struct l2t_data *d;
 	int hash;
-	u32 addr = *(u32 *) neigh->primary_key;
-	int ifidx = neigh->dev->ifindex;
-	struct port_info *p = netdev_priv(dev);
-	int smt_idx = p->port_id;
+	u32 addr;
+	int ifidx;
+	int smt_idx;
 
 	rcu_read_lock();
+	neigh = dst_get_neighbour_noref(dst);
+	if (!neigh)
+		goto done_rcu;
+
+	addr = *(u32 *) neigh->primary_key;
+	ifidx = neigh->dev->ifindex;
+
+	if (!dev)
+		dev = neigh->dev;
+	p = netdev_priv(dev);
+	smt_idx = p->port_id;
+
 	d = L2DATA(cdev);
 	if (!d)
 		goto done_rcu;
@@ -323,7 +336,7 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
 			l2t_hold(d, e);
 			if (atomic_read(&e->refcnt) == 1)
 				reuse_entry(e, neigh);
-			goto done;
+			goto done_unlock;
 		}
 
 	/* Need to allocate a new entry */
@@ -344,7 +357,7 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
 			e->vlan = VLAN_NONE;
 		spin_unlock(&e->lock);
 	}
-done:
+done_unlock:
 	write_unlock_bh(&d->lock);
 done_rcu:
 	rcu_read_unlock();
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.h b/drivers/net/ethernet/chelsio/cxgb3/l2t.h
index c5f5479..c4e8643 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.h
@@ -109,7 +109,7 @@ static inline void set_arp_failure_handler(struct sk_buff *skb,
 
 void t3_l2e_free(struct l2t_data *d, struct l2t_entry *e);
 void t3_l2t_update(struct t3cdev *dev, struct neighbour *neigh);
-struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
+struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
 			     struct net_device *dev);
 int t3_l2t_send_slow(struct t3cdev *dev, struct sk_buff *skb,
 		     struct l2t_entry *e);
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index 88902d3..36739da 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -966,7 +966,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 		csk->saddr.sin_addr.s_addr = chba->ipv4addr;
 
 	csk->rss_qid = 0;
-	csk->l2t = t3_l2t_get(t3dev, dst_get_neighbour_noref(dst), ndev);
+	csk->l2t = t3_l2t_get(t3dev, dst, ndev);
 	if (!csk->l2t) {
 		pr_err("NO l2t available.\n");
 		return -EINVAL;
-- 
1.7.7.3
