From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/13 net-3.1-stable] IB: Fix RCU lockdep splats
Date: Tue, 06 Dec 2011 16:33:17 -0500 (EST)
Message-ID: <20111206.163317.1384394207097362838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429Ab1LFVdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Eric Dumazet <eric.dumazet@gmail.com>

[ Upstream commit 580da35a31f91a594f3090b7a2c39b85cb051a12 ]

Commit f2c31e32b37 ("net: fix NULL dereferences in check_peer_redir()")
forgot to take care of infiniband uses of dst neighbours.

Many thanks to Marc Aurele who provided a nice bug report and feedback.

Reported-by: Marc Aurele La France <tsi@ualberta.ca>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: <stable@kernel.org>
Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/infiniband/core/addr.c                 |    9 ++++++---
 drivers/infiniband/hw/cxgb3/iwch_cm.c          |    4 ++++
 drivers/infiniband/hw/cxgb4/cm.c               |    4 ++++
 drivers/infiniband/hw/nes/nes_cm.c             |    6 ++++--
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   18 +++++++++++-------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    6 ++++--
 6 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 236ad9a..f2a84c6 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -215,7 +215,9 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 
 	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
+		rcu_read_lock();
 		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
+		rcu_read_unlock();
 		ret = -ENODATA;
 		if (neigh)
 			goto release;
@@ -273,15 +275,16 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 		goto put;
 	}
 
+	rcu_read_lock();
 	neigh = dst_get_neighbour(dst);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
 		if (neigh)
 			neigh_event_send(neigh, NULL);
 		ret = -ENODATA;
-		goto put;
+	} else {
+		ret = rdma_copy_addr(addr, dst->dev, neigh->ha);
 	}
-
-	ret = rdma_copy_addr(addr, dst->dev, neigh->ha);
+	rcu_read_unlock();
 put:
 	dst_release(dst);
 	return ret;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 6cd642a..e55ce7a 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1365,8 +1365,10 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		goto reject;
 	}
 	dst = &rt->dst;
+	rcu_read_lock();
 	neigh = dst_get_neighbour(dst);
 	l2t = t3_l2t_get(tdev, neigh, neigh->dev);
+	rcu_read_unlock();
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1936,10 +1938,12 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 
+	rcu_read_lock();
 	neigh = dst_get_neighbour(ep->dst);
 
 	/* get a l2t entry */
 	ep->l2t = t3_l2t_get(ep->com.tdev, neigh, neigh->dev);
+	rcu_read_unlock();
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err = -ENOMEM;
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 77f769d..daa93e9 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1358,6 +1358,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 	dst = &rt->dst;
+	rcu_read_lock();
 	neigh = dst_get_neighbour(dst);
 	if (neigh->dev->flags & IFF_LOOPBACK) {
 		pdev = ip_dev_find(&init_net, peer_ip);
@@ -1384,6 +1385,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		rss_qid = dev->rdev.lldi.rxq_ids[
 			  cxgb4_port_idx(neigh->dev) * step];
 	}
+	rcu_read_unlock();
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1909,6 +1911,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 
+	rcu_read_lock();
 	neigh = dst_get_neighbour(ep->dst);
 
 	/* get a l2t entry */
@@ -1945,6 +1948,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[
 			      cxgb4_port_idx(neigh->dev) * step];
 	}
+	rcu_read_unlock();
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err = -ENOMEM;
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index c118663..a237547 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1150,9 +1150,11 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 		neigh_release(neigh);
 	}
 
-	if ((neigh == NULL) || (!(neigh->nud_state & NUD_VALID)))
+	if ((neigh == NULL) || (!(neigh->nud_state & NUD_VALID))) {
+		rcu_read_lock();
 		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
-
+		rcu_read_unlock();
+	}
 	ip_rt_put(rt);
 	return rc;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index fe89c46..a98c414 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -555,6 +555,7 @@ static int path_rec_start(struct net_device *dev,
 	return 0;
 }
 
+/* called with rcu_read_lock */
 static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -636,6 +637,7 @@ err_drop:
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
+/* called with rcu_read_lock */
 static void ipoib_path_lookup(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(skb->dev);
@@ -720,13 +722,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct neighbour *n = NULL;
 	unsigned long flags;
 
+	rcu_read_lock();
 	if (likely(skb_dst(skb)))
 		n = dst_get_neighbour(skb_dst(skb));
 
 	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
 			ipoib_path_lookup(skb, dev);
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
 
 		neigh = *to_ipoib_neigh(n);
@@ -749,17 +752,17 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			ipoib_neigh_free(dev, neigh);
 			spin_unlock_irqrestore(&priv->lock, flags);
 			ipoib_path_lookup(skb, dev);
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
 
 		if (ipoib_cm_get(neigh)) {
 			if (ipoib_cm_up(neigh)) {
 				ipoib_cm_send(dev, skb, ipoib_cm_get(neigh));
-				return NETDEV_TX_OK;
+				goto unlock;
 			}
 		} else if (neigh->ah) {
 			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(n->ha));
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
 
 		if (skb_queue_len(&neigh->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
@@ -793,13 +796,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					   phdr->hwaddr + 4);
 				dev_kfree_skb_any(skb);
 				++dev->stats.tx_dropped;
-				return NETDEV_TX_OK;
+				goto unlock;
 			}
 
 			unicast_arp_send(skb, dev, phdr);
 		}
 	}
-
+unlock:
+	rcu_read_unlock();
 	return NETDEV_TX_OK;
 }
 
@@ -837,7 +841,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	dst = skb_dst(skb);
 	n = NULL;
 	if (dst)
-		n = dst_get_neighbour(dst);
+		n = dst_get_neighbour_raw(dst);
 	if ((!dst || !n) && daddr) {
 		struct ipoib_pseudoheader *phdr =
 			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index ecea4fe..a8d2a89 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -265,7 +265,7 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 
 		skb->dev = dev;
 		if (dst)
-			n = dst_get_neighbour(dst);
+			n = dst_get_neighbour_raw(dst);
 		if (!dst || !n) {
 			/* put pseudoheader back on for next time */
 			skb_push(skb, sizeof (struct ipoib_pseudoheader));
@@ -721,6 +721,8 @@ out:
 	if (mcast && mcast->ah) {
 		struct dst_entry *dst = skb_dst(skb);
 		struct neighbour *n = NULL;
+
+		rcu_read_lock();
 		if (dst)
 			n = dst_get_neighbour(dst);
 		if (n && !*to_ipoib_neigh(n)) {
@@ -733,7 +735,7 @@ out:
 				list_add_tail(&neigh->list, &mcast->neigh_list);
 			}
 		}
-
+		rcu_read_unlock();
 		spin_unlock_irqrestore(&priv->lock, flags);
 		ipoib_send(dev, skb, mcast->ah, IB_MULTICAST_QPN);
 		return;
-- 
1.7.7.3
