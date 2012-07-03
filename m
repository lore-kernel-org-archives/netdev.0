From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/19] cxgb3: Convert t3_l2t_get() over to
 dst_neigh_lookup().
Date: Tue, 03 Jul 2012 02:46:56 -0700 (PDT)
Message-ID: <20120703.024656.2146388003201411071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab2GCJq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:57 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2149A584122
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This means passing in a suitable destination address.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/cxgb3/iwch_cm.c    |    5 +++--
 drivers/net/ethernet/chelsio/cxgb3/l2t.c |    6 ++++--
 drivers/net/ethernet/chelsio/cxgb3/l2t.h |    2 +-
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c       |    3 ++-
 4 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 740dcc0..77b6b18 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1374,7 +1374,7 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		goto reject;
 	}
 	dst = &rt->dst;
-	l2t = t3_l2t_get(tdev, dst, NULL);
+	l2t = t3_l2t_get(tdev, dst, NULL, &req->peer_ip);
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1942,7 +1942,8 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		goto fail3;
 	}
 	ep->dst = &rt->dst;
-	ep->l2t = t3_l2t_get(ep->com.tdev, ep->dst, NULL);
+	ep->l2t = t3_l2t_get(ep->com.tdev, ep->dst, NULL,
+			     &cm_id->remote_addr.sin_addr.s_addr);
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
index 3fa3c88..8d53438 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
@@ -299,7 +299,7 @@ static inline void reuse_entry(struct l2t_entry *e, struct neighbour *neigh)
 }
 
 struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
-			     struct net_device *dev)
+			     struct net_device *dev, const void *daddr)
 {
 	struct l2t_entry *e = NULL;
 	struct neighbour *neigh;
@@ -311,7 +311,7 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
 	int smt_idx;
 
 	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
+	neigh = dst_neigh_lookup(dst, daddr);
 	if (!neigh)
 		goto done_rcu;
 
@@ -360,6 +360,8 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
 done_unlock:
 	write_unlock_bh(&d->lock);
 done_rcu:
+	if (neigh)
+		neigh_release(neigh);
 	rcu_read_unlock();
 	return e;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.h b/drivers/net/ethernet/chelsio/cxgb3/l2t.h
index c4e8643..8cffcdf 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.h
@@ -110,7 +110,7 @@ static inline void set_arp_failure_handler(struct sk_buff *skb,
 void t3_l2e_free(struct l2t_data *d, struct l2t_entry *e);
 void t3_l2t_update(struct t3cdev *dev, struct neighbour *neigh);
 struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
-			     struct net_device *dev);
+			     struct net_device *dev, const void *daddr);
 int t3_l2t_send_slow(struct t3cdev *dev, struct sk_buff *skb,
 		     struct l2t_entry *e);
 void t3_l2t_send_event(struct t3cdev *dev, struct l2t_entry *e);
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index 36739da..49692a1 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -966,7 +966,8 @@ static int init_act_open(struct cxgbi_sock *csk)
 		csk->saddr.sin_addr.s_addr = chba->ipv4addr;
 
 	csk->rss_qid = 0;
-	csk->l2t = t3_l2t_get(t3dev, dst, ndev);
+	csk->l2t = t3_l2t_get(t3dev, dst, ndev,
+			      &csk->daddr.sin_addr.s_addr);
 	if (!csk->l2t) {
 		pr_err("NO l2t available.\n");
 		return -EINVAL;
-- 
1.7.10
