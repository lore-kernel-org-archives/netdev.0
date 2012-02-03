From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Fri, 03 Feb 2012 09:09:35 +0100
Message-ID: <4F2B963F.4020504@profihost.ag>
References: <20120201.162157.880976652659067010.davem@davemloft.net>	 <4F2A87B0.6070900@profihost.ag>	 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <20120202.143957.2251106530056768980.davem@davemloft.net>	 <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag> <1328253972.2480.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070906000400070006060408"
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:54077 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab2BCIJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 03:09:06 -0500
In-Reply-To: <1328253972.2480.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070906000400070006060408
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi,

attached you find the patch files applying cleanly to 3.0.X.

>> I've made my own backport of the patch and removed at least 1-2
>> dependencies. Anybody interested?
>>
> 
> If you did the work, post it for review.

Thanks!

Stefan

--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0013-sch_teql-fix-lockdep-splat.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0013-sch_teql-fix-lockdep-splat.patch"

>From 41841451b60d43a4b17cd2473d52c99055d61f54 Mon Sep 17 00:00:00 2001
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2011 04:08:58 +0000
Subject: [PATCH 13/13] sch_teql: fix lockdep splat

[ Upstream commit f7e57044eeb1841847c24aa06766c8290c202583 ]

We need rcu_read_lock() protection before using dst_get_neighbour(), and
we must cache its value (pass it to __teql_resolve())

teql_master_xmit() is called under rcu_read_lock_bh() protection, its
not enough.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 net/sched/sch_teql.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index a3b7120..4f4c52c 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -225,11 +225,11 @@ static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 
 
 static int
-__teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
+__teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res,
+	       struct net_device *dev, struct netdev_queue *txq,
+	       struct neighbour *mn)
 {
-	struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
-	struct teql_sched_data *q = qdisc_priv(dev_queue->qdisc);
-	struct neighbour *mn = dst_get_neighbour(skb_dst(skb));
+	struct teql_sched_data *q = qdisc_priv(txq->qdisc);
 	struct neighbour *n = q->ncache;
 
 	if (mn->tbl == NULL)
@@ -262,17 +262,26 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 }
 
 static inline int teql_resolve(struct sk_buff *skb,
-			       struct sk_buff *skb_res, struct net_device *dev)
+			       struct sk_buff *skb_res,
+			       struct net_device *dev,
+			       struct netdev_queue *txq)
 {
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	struct dst_entry *dst = skb_dst(skb);
+	struct neighbour *mn;
+	int res;
+
 	if (txq->qdisc == &noop_qdisc)
 		return -ENODEV;
 
-	if (dev->header_ops == NULL ||
-	    skb_dst(skb) == NULL ||
-	    dst_get_neighbour(skb_dst(skb)) == NULL)
+	if (!dev->header_ops || !dst)
 		return 0;
-	return __teql_resolve(skb, skb_res, dev);
+
+	rcu_read_lock();
+	mn = dst_get_neighbour(dst);
+	res = mn ? __teql_resolve(skb, skb_res, dev, txq, mn) : 0;
+	rcu_read_unlock();
+
+	return res;
 }
 
 static netdev_tx_t teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -307,7 +316,7 @@ restart:
 			continue;
 		}
 
-		switch (teql_resolve(skb, skb_res, slave)) {
+		switch (teql_resolve(skb, skb_res, slave, slave_txq)) {
 		case 0:
 			if (__netif_tx_trylock(slave_txq)) {
 				unsigned int length = qdisc_pkt_len(skb);
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0012-IB-Fix-RCU-lockdep-splats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0012-IB-Fix-RCU-lockdep-splats.patch"

>From 22e5ec757b707216b9b6de7beb4d04928cf9a7f4 Mon Sep 17 00:00:00 2001
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Nov 2011 22:31:23 +0100
Subject: [PATCH 12/13] IB: Fix RCU lockdep splats

commit 580da35a31f91a594f3090b7a2c39b85cb051a12 upstream.

Commit f2c31e32b37 ("net: fix NULL dereferences in check_peer_redir()")
forgot to take care of infiniband uses of dst neighbours.

Many thanks to Marc Aurele who provided a nice bug report and feedback.

Reported-by: Marc Aurele La France <tsi@ualberta.ca>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/infiniband/core/addr.c                 |    9 ++++++---
 drivers/infiniband/hw/cxgb3/iwch_cm.c          |    4 ++++
 drivers/infiniband/hw/cxgb4/cm.c               |    4 ++++
 drivers/infiniband/hw/mlx4/qp.c                |    2 +-
 drivers/infiniband/hw/nes/nes_cm.c             |    6 ++++--
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   24 +++++++++++++++---------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    6 ++++--
 7 files changed, 38 insertions(+), 17 deletions(-)

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
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 2001f20..23c04ff 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1301,7 +1301,7 @@ static int build_mlx_header(struct mlx4_ib_sqp *sqp, struct ib_send_wr *wr,
 	int is_eth;
 	int is_vlan = 0;
 	int is_grh;
-	u16 vlan;
+	u16 vlan = 0;
 
 	send_size = 0;
 	for (i = 0; i < wr->num_sge; ++i)
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 73bc184..a1f74f6 100644
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
index 43f89ba..57caa04 100644
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
@@ -720,11 +722,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct neighbour *n;
 	unsigned long flags;
 
-	n = dst_get_neighbour(skb_dst(skb));
-	if (likely(skb_dst(skb) && n)) {
+	rcu_read_lock();
+	if (likely(skb_dst(skb)))
+		n = dst_get_neighbour(skb_dst(skb));
+
+	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
 			ipoib_path_lookup(skb, dev);
-			return NETDEV_TX_OK;
+			goto unlock;
 		}
 
 		neigh = *to_ipoib_neigh(n);
@@ -747,17 +752,17 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -791,13 +796,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
 
@@ -835,7 +841,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
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
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0011-ipv4-fix-lockdep-splat-in-rt_cache_seq_show.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="rcu_0011-ipv4-fix-lockdep-splat-in-rt_cache_seq_show.patch"

>From 9c24da53c4c647a93d37d0f55a6c9ec0acef9814 Mon Sep 17 00:00:00 2001
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Nov 2011 20:05:55 +0000
Subject: [PATCH 11/13] ipv4: fix lockdep splat in rt_cache_seq_show

[ Upstream commit 218fa90f072e4aeff9003d57e390857f4f35513e ]

After commit f2c31e32b378 (fix NULL dereferences in check_peer_redir()),
dst_get_neighbour() should be guarded by rcu_read_lock() /
rcu_read_unlock() section.

Reported-by: Miles Lane <miles.lane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 net/ipv4/route.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 32eb4a7..5218e4f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -416,10 +416,14 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			   "HHUptod\tSpecDst");
 	else {
 		struct rtable *r = v;
-		// struct neighbour *n;
-		int len;
+		struct neighbour *n;
+		int len, HHUptod;
+
+		rcu_read_lock();
+		n = dst_get_neighbour(&r->dst);
+		HHUptod = (n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0;
+		rcu_read_unlock();
 
-		// n = dst_get_neighbour(&r->dst);
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
 			r->dst.dev ? r->dst.dev->name : "*",
@@ -433,8 +437,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
 			r->dst.hh ? atomic_read(&r->dst.hh->hh_refcnt) : -1,
-			r->dst.hh ? (r->dst.hh->hh_output ==
-				       dev_queue_xmit) : 0,
+			HHUptod,
 			r->rt_spec_dst, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0010-net-fix-potential-neighbour-race-in-dst_ifdown.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="rcu_0010-net-fix-potential-neighbour-race-in-dst_ifdown.patc";
 filename*1="h"

>From 89a8ed567a6d4de8c0e77abf479ece3a9962f40c Mon Sep 17 00:00:00 2001
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 8 Aug 2011 20:56:14 +0000
Subject: [PATCH 10/13] net: fix potential neighbour race in dst_ifdown()

Followup of commit f2c31e32b378a (fix NULL dereferences in
check_peer_redir()).

We need to make sure dst neighbour doesnt change in dst_ifdown().

Fix some sparse errors.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dst.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 62c9b01..8246d47 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -171,7 +171,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst_init_metrics(dst, dst_default_metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
-	dst->_neighbour = NULL;
+	RCU_INIT_POINTER(dst->_neighbour, NULL);
 	dst->hh = NULL;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
@@ -231,7 +231,7 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 	smp_rmb();
 
 again:
-	neigh = dst->_neighbour;
+	neigh = rcu_dereference_protected(dst->_neighbour, 1);
 	hh = dst->hh;
 	child = dst->child;
 
@@ -240,7 +240,7 @@ again:
 		hh_cache_put(hh);
 
 	if (neigh) {
-		dst->_neighbour = NULL;
+		RCU_INIT_POINTER(dst->_neighbour, NULL);
 		neigh_release(neigh);
 	}
 
@@ -367,14 +367,19 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	if (!unregister) {
 		dst->input = dst->output = dst_discard;
 	} else {
+		struct neighbour *neigh;
+
 		dst->dev = dev_net(dst->dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
-		if (dst->_neighbour && dst->_neighbour->dev == dev) {
-			dst->_neighbour->dev = dst->dev;
+		rcu_read_lock();
+		neigh = dst_get_neighbour(dst);
+		if (neigh && neigh->dev == dev) {
+			neigh->dev = dst->dev;
 			dev_hold(dst->dev);
 			dev_put(dev);
 		}
+		rcu_read_unlock();
 	}
 }
 
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0009-net-fix-NULL-dereferences-in-check_peer_redir.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="rcu_0009-net-fix-NULL-dereferences-in-check_peer_redir.patch"

>From 6093c6b4c447c8592e4a593590d7a31e4fdaedd2 Mon Sep 17 00:00:00 2001
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jul 2011 19:00:53 +0000
Subject: [PATCH 09/13] net: fix NULL dereferences in check_peer_redir()

UPSTREAM: f667de2e66ea9b8f99353ff01221bb355faf3f3c backported

Gergely Kalman reported crashes in check_peer_redir().

It appears commit f39925dbde778 (ipv4: Cache learned redirect
information in inetpeer.) added a race, leading to possible NULL ptr
dereference.

Since we can now change dst neighbour, we should make sure a reader can
safely use a neighbour.

Add RCU protection to dst neighbour, and make sure check_peer_redir()
can be called safely by different cpus in parallel.

As neighbours are already freed after one RCU grace period, this patch
should not add typical RCU penalty (cache cold effects)

Many thanks to Gergely for providing a pretty report pointing to the
bug.

Reported-by: Gergely Kalman <synapse@hippy.csoma.elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h     |   17 +++++++++++++----
 net/ipv4/ip_output.c  |   17 +++++++++++++----
 net/ipv4/route.c      |   14 ++++++++------
 net/ipv6/addrconf.c   |    2 +-
 net/ipv6/ip6_fib.c    |    2 +-
 net/ipv6/ip6_output.c |   20 ++++++++++++++++----
 net/ipv6/route.c      |   35 +++++++++++++++++++++++++----------
 7 files changed, 77 insertions(+), 30 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3962b65..3723f1f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -37,7 +37,7 @@ struct dst_entry {
 	unsigned long		_metrics;
 	unsigned long		expires;
 	struct dst_entry	*path;
-	struct neighbour	*_neighbour;
+	struct neighbour __rcu	*_neighbour;
 	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
@@ -88,12 +88,17 @@ struct dst_entry {
 
 static inline struct neighbour *dst_get_neighbour(struct dst_entry *dst)
 {
-	return dst->_neighbour;
+	return rcu_dereference(dst->_neighbour);
+}
+
+static inline struct neighbour *dst_get_neighbour_raw(struct dst_entry *dst)
+{
+	return rcu_dereference_raw(dst->_neighbour);
 }
 
 static inline void dst_set_neighbour(struct dst_entry *dst, struct neighbour *neigh)
 {
-	dst->_neighbour = neigh;
+	rcu_assign_pointer(dst->_neighbour, neigh);
 }
 
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
@@ -382,8 +387,12 @@ static inline void dst_rcu_free(struct rcu_head *head)
 static inline void dst_confirm(struct dst_entry *dst)
 {
 	if (dst) {
-		struct neighbour *n = dst_get_neighbour(dst);
+		struct neighbour *n;
+
+		rcu_read_lock();
+		n = dst_get_neighbour(dst);
 		neigh_confirm(n);
+		rcu_read_unlock();
 	}
 }
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3f994ca..808d0e2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -204,11 +204,20 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		skb = skb2;
 	}
 	
+	rcu_read_lock();
 	neigh = dst_get_neighbour(dst);
-	if (dst->hh)
-		return neigh_hh_output(dst->hh, skb);
-	else if (neigh)
-		return neigh->output(skb);
+	if (dst->hh) {
+		int res = neigh_hh_output(dst->hh, skb);
+
+		rcu_read_unlock();
+		return res;
+	} else if (neigh) {
+		int res = neigh->output(skb);
+
+		rcu_read_unlock();
+		return res;
+	}
+	rcu_read_unlock();
 
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b56e304..32eb4a7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1630,16 +1630,18 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 {
 	struct rtable *rt = (struct rtable *) dst;
 	__be32 orig_gw = rt->rt_gateway;
-	struct neighbour *n;
+	struct neighbour *n, *old_n;
 
 	dst_confirm(&rt->dst);
 
-	neigh_release(dst_get_neighbour(&rt->dst));
-	dst_set_neighbour(&rt->dst, NULL);
-
 	rt->rt_gateway = peer->redirect_learned.a4;
-	rt_bind_neighbour(rt);
-	n = dst_get_neighbour(&rt->dst);
+
+	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	old_n = xchg(&rt->dst._neighbour, n);
+	if (old_n)
+		neigh_release(old_n);
 	if (!n || !(n->nud_state & NUD_VALID)) {
 		if (n)
 			neigh_event_send(n, NULL);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1fa96a0..0f335c6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -656,7 +656,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	 * layer address of our nexhop router
 	 */
 
-	if (dst_get_neighbour(&rt->dst) == NULL)
+	if (dst_get_neighbour_raw(&rt->dst) == NULL)
 		ifa->flags &= ~IFA_F_OPTIMISTIC;
 
 	ifa->idev = idev;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index fb1eb5e..0f9b37a 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1455,7 +1455,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(dst_get_neighbour(&rt->dst)->flags & NTF_ROUTER))) {
+			   (!(dst_get_neighbour_raw(&rt->dst)->flags & NTF_ROUTER))) {
 			RT6_TRACE("purging route %p via non-router but gateway\n",
 				  rt);
 			return -1;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 228d317..6abe5b7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -135,12 +135,20 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
+	rcu_read_lock();
 	neigh = dst_get_neighbour(dst);
-	if (dst->hh)
-		return neigh_hh_output(dst->hh, skb);
-	else if (neigh)
-		return neigh->output(skb);
+	if (dst->hh) {
+		int res = neigh_hh_output(dst->hh, skb);
 
+		rcu_read_unlock();
+		return res;
+	} else if (neigh) {
+		int res = neigh->output(skb);
+
+		rcu_read_unlock();
+		return res;
+	}
+	rcu_read_unlock();
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
@@ -981,12 +989,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry and replace it instead with the
 	 * dst entry of the nexthop router
 	 */
+	rcu_read_lock();
 	n = dst_get_neighbour(*dst);
 	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
 		int redirect;
 
+		rcu_read_unlock();
 		ifp = ipv6_get_ifaddr(net, &fl6->saddr,
 				      (*dst)->dev, 1);
 
@@ -1006,6 +1016,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			if ((err = (*dst)->error))
 				goto out_err_release;
 		}
+	} else {
+		rcu_read_unlock();
 	}
 #endif
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c277429..2b083dd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -363,7 +363,7 @@ out:
 #ifdef CONFIG_IPV6_ROUTER_PREF
 static void rt6_probe(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt ? dst_get_neighbour(&rt->dst) : NULL;
+	struct neighbour *neigh;
 	/*
 	 * Okay, this does not seem to be appropriate
 	 * for now, however, we need to check if it
@@ -372,8 +372,10 @@ static void rt6_probe(struct rt6_info *rt)
 	 * Router Reachability Probe MUST be rate-limited
 	 * to no more than one per minute.
 	 */
+	rcu_read_lock();
+	neigh = rt ? dst_get_neighbour(&rt->dst) : NULL;
 	if (!neigh || (neigh->nud_state & NUD_VALID))
-		return;
+		goto out;
 	read_lock_bh(&neigh->lock);
 	if (!(neigh->nud_state & NUD_VALID) &&
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
@@ -386,8 +388,11 @@ static void rt6_probe(struct rt6_info *rt)
 		target = (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(rt->rt6i_dev, NULL, target, &mcaddr, NULL);
-	} else
+	} else {
 		read_unlock_bh(&neigh->lock);
+	}
+out:
+	rcu_read_unlock();
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
@@ -411,8 +416,11 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 
 static inline int rt6_check_neigh(struct rt6_info *rt)
 {
-	struct neighbour *neigh = dst_get_neighbour(&rt->dst);
+	struct neighbour *neigh;
 	int m;
+
+	rcu_read_lock();
+	neigh = dst_get_neighbour(&rt->dst);
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
 		m = 1;
@@ -429,6 +437,7 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 		read_unlock_bh(&neigh->lock);
 	} else
 		m = 0;
+	rcu_read_unlock();
 	return m;
 }
 
@@ -767,7 +776,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const struct in6_a
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
 		rt->dst.flags |= DST_HOST;
-		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour(&ort->dst)));
+		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_raw(&ort->dst)));
 	}
 	return rt;
 }
@@ -801,7 +810,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!dst_get_neighbour(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!dst_get_neighbour_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1581,7 +1590,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	if (neigh == dst_get_neighbour(&rt->dst))
+	if (neigh == dst_get_neighbour_raw(&rt->dst))
 		goto out;
 
 	nrt = ip6_rt_copy(rt);
@@ -1677,7 +1686,7 @@ again:
 	   1. It is connected route. Action: COW
 	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
 	 */
-	if (!dst_get_neighbour(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!dst_get_neighbour_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, daddr, saddr);
 	else
 		nrt = rt6_alloc_clone(rt, daddr);
@@ -2319,6 +2328,7 @@ static int rt6_fill_node(struct net *net,
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
+	struct neighbour *n;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2407,8 +2417,11 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (dst_get_neighbour(&rt->dst))
-		NLA_PUT(skb, RTA_GATEWAY, 16, &dst_get_neighbour(&rt->dst)->primary_key);
+	rcu_read_lock();
+	n = dst_get_neighbour(&rt->dst);
+	if (n)
+		NLA_PUT(skb, RTA_GATEWAY, 16, &n->primary_key);
+	rcu_read_unlock();
 
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
@@ -2601,12 +2614,14 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
+	rcu_read_lock();
 	n = dst_get_neighbour(&rt->dst);
 	if (n) {
 		seq_printf(m, "%pi6", n->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
+	rcu_read_unlock();
 	seq_printf(m, " %08x %08x %08x %08x %8s\n",
 		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
 		   rt->dst.__use, rt->rt6i_flags,
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0008-net-Add-neigh_lookup-operation-to-dst_ops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0008-net-Add-neigh_lookup-operation-to-dst_ops.patch"

>From 42f7653d8205ba4297ca8f2cc2dfc79d196fd884 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Mon, 18 Jul 2011 00:40:17 -0700
Subject: [PATCH 08/13] net: Add ->neigh_lookup() operation to dst_ops

In the future dst entries will be neigh-less.  In that environment we
need to have an easy transition point for current users of
dst->neighbour outside of the packet output fast path.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h         |    9 ---------
 include/net/dst.h         |    5 +++++
 include/net/dst_ops.h     |    1 +
 net/bridge/br_netfilter.c |    6 ++++++
 net/decnet/dn_route.c     |    7 +++++++
 net/ipv4/route.c          |   26 +++++++++++++++++++-------
 net/ipv6/route.c          |    7 +++++++
 net/xfrm/xfrm_policy.c    |    7 +++++++
 8 files changed, 52 insertions(+), 16 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 5e669e6..4979af8 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -38,15 +38,6 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, str
 	return n;
 }
 
-static inline struct neighbour *ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const __be32 *pkey)
-{
-	struct neighbour *n = __ipv4_neigh_lookup(tbl, dev,
-						  *(__force u32 *)pkey);
-	if (n)
-		return n;
-	return neigh_create(tbl, pkey, dev);
-}
-
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
diff --git a/include/net/dst.h b/include/net/dst.h
index 5938610..3962b65 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -387,6 +387,11 @@ static inline void dst_confirm(struct dst_entry *dst)
 	}
 }
 
+static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return dst->ops->neigh_lookup(dst, daddr);
+}
+
 static inline void dst_link_failure(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index dc07463..9adb998 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -26,6 +26,7 @@ struct dst_ops {
 	void			(*link_failure)(struct sk_buff *);
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
 	int			(*local_out)(struct sk_buff *skb);
+	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst, const void *daddr);
 
 	struct kmem_cache	*kmem_cachep;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 3dc7f54..19e730a 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -109,11 +109,17 @@ static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return NULL;
 }
 
+static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return NULL;
+}
+
 static struct dst_ops fake_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
 	.cow_metrics =		fake_cow_metrics,
+	.neigh_lookup =		fake_neigh_lookup,
 };
 
 /*
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index c9d5bcf..df69e92 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -116,6 +116,7 @@ static void dn_dst_destroy(struct dst_entry *);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
+static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr);
 static int dn_route_input(struct sk_buff *);
 static void dn_run_flush(unsigned long dummy);
 
@@ -139,6 +140,7 @@ static struct dst_ops dn_dst_ops = {
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
+	.neigh_lookup =		dn_dst_neigh_lookup,
 };
 
 static void dn_dst_destroy(struct dst_entry *dst)
@@ -820,6 +822,11 @@ static unsigned int dn_dst_default_mtu(const struct dst_entry *dst)
 	return dst->dev->mtu;
 }
 
+static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return __neigh_lookup_errno(&dn_neigh_table, daddr, dst->dev);
+}
+
 static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ab0cc63..b56e304 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -186,6 +186,8 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr);
+
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
@@ -200,6 +202,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
 	.local_out =		__ip_local_out,
+	.neigh_lookup =		ipv4_neigh_lookup,
 };
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
@@ -1010,22 +1013,30 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
-static int rt_bind_neighbour(struct rtable *rt)
+static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	static const __be32 inaddr_any = 0;
-	struct net_device *dev = rt->dst.dev;
 	struct neigh_table *tbl = &arp_tbl;
-	const __be32 *nexthop;
+	static const __be32 inaddr_any = 0;
+	struct net_device *dev = dst->dev;
+	const __be32 *pkey = daddr;
 	struct neighbour *n;
 
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 	if (dev->type == ARPHRD_ATM)
 		tbl = clip_tbl_hook;
 #endif
-	nexthop = &rt->rt_gateway;
 	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-		nexthop = &inaddr_any;
-	n = ipv4_neigh_lookup(tbl, dev, nexthop);
+		pkey = &inaddr_any;
+
+	n = __ipv4_neigh_lookup(tbl, dev, *(__force u32 *)pkey);
+	if (n)
+		return n;
+	return neigh_create(tbl, pkey, dev);
+}
+
+static int rt_bind_neighbour(struct rtable *rt)
+{
+	struct neighbour *n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
 	dst_set_neighbour(&rt->dst, n);
@@ -2735,6 +2746,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.default_advmss		=	ipv4_default_advmss,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ipv4_rt_blackhole_cow_metrics,
+	.neigh_lookup		=	ipv4_neigh_lookup,
 };
 
 struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e215539..c277429 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -127,6 +127,11 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return __neigh_lookup_errno(&nd_tbl, daddr, dst->dev);
+}
+
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
 	.protocol		=	cpu_to_be16(ETH_P_IPV6),
@@ -142,6 +147,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
 	.local_out		=	__ip6_local_out,
+	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
 static unsigned int ip6_blackhole_default_mtu(const struct dst_entry *dst)
@@ -168,6 +174,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
+	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
 static const u32 ip6_template_metrics[RTAX_MAX] = {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7803eb6..94fdcc7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2385,6 +2385,11 @@ static unsigned int xfrm_default_mtu(const struct dst_entry *dst)
 	return dst_mtu(dst->path);
 }
 
+static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst, const void *daddr)
+{
+	return dst_neigh_lookup(dst->path, daddr);
+}
+
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	struct net *net;
@@ -2410,6 +2415,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->negative_advice = xfrm_negative_advice;
 		if (likely(dst_ops->link_failure == NULL))
 			dst_ops->link_failure = xfrm_link_failure;
+		if (likely(dst_ops->neigh_lookup == NULL))
+			dst_ops->neigh_lookup = xfrm_neigh_lookup;
 		if (likely(afinfo->garbage_collect == NULL))
 			afinfo->garbage_collect = __xfrm_garbage_collect;
 		xfrm_policy_afinfo[afinfo->family] = afinfo;
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0007-added-mising-dst_set_neighbour.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0007-added-mising-dst_set_neighbour.patch"

>From 10fbe983cbda98e89755600070f644e9375a1998 Mon Sep 17 00:00:00 2001
From: Stefan Priebe <s.priebe@profihost.ag>
Date: Mon, 12 Dec 2011 13:16:07 +0100
Subject: [PATCH 07/13] added mising dst_set_neighbour

---
 net/ipv4/route.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8f39909..ab0cc63 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -108,6 +108,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <net/secure_seq.h>
 #include <net/atmclip.h>
 
 #define RT_FL_TOS(oldflp4) \
@@ -1027,7 +1028,7 @@ static int rt_bind_neighbour(struct rtable *rt)
 	n = ipv4_neigh_lookup(tbl, dev, nexthop);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
-	rt->dst.neighbour = n;
+	dst_set_neighbour(&rt->dst, n);
 
 	return 0;
 }
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0006-ipv4-Inline-neigh-binding.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0006-ipv4-Inline-neigh-binding.patch"

>From 4d69a6514131998fe5d5a5f0569fd123403686f7 Mon Sep 17 00:00:00 2001
From: David Miller <davem@davemloft.net>
Date: Mon, 11 Jul 2011 22:44:24 +0000
Subject: [PATCH 06/13] ipv4: Inline neigh binding.

Get rid of all of the useless and costly indirection
by doing the neigh hash table lookup directly inside
of the neighbour binding.

Rename from arp_bind_neighbour to rt_bind_neighbour.

Use new helpers {__,}ipv4_neigh_lookup()

In rt_bind_neighbour() get rid of useless tests which
are never true in the context this function is called,
namely dev is never NULL and the dst->neighbour is
always NULL.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h |   33 ++++++++++++++++++++++++++++++++-
 net/ipv4/arp.c    |   24 ------------------------
 net/ipv4/route.c  |   31 +++++++++++++++++++++++++++----
 3 files changed, 59 insertions(+), 29 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 723bde5..5e669e6 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -15,6 +15,38 @@ static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd
 	return val * hash_rnd;
 }
 
+static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, u32 key)
+{
+	struct neigh_hash_table *nht;
+	struct neighbour *n;
+	u32 hash_val;
+
+	rcu_read_lock_bh();
+	nht = rcu_dereference_bh(tbl->nht);
+	hash_val = arp_hashfn(key, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
+	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
+	     n != NULL;
+	     n = rcu_dereference_bh(n->next)) {
+		if (n->dev == dev && *(u32 *)n->primary_key == key) {
+			if (!atomic_inc_not_zero(&n->refcnt))
+				n = NULL;
+			break;
+		}
+	}
+	rcu_read_unlock_bh();
+
+	return n;
+}
+
+static inline struct neighbour *ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const __be32 *pkey)
+{
+	struct neighbour *n = __ipv4_neigh_lookup(tbl, dev,
+						  *(__force u32 *)pkey);
+	if (n)
+		return n;
+	return neigh_create(tbl, pkey, dev);
+}
+
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
@@ -22,7 +54,6 @@ extern void     arp_send(int type, int ptype, __be32 dest_ip,
 			 struct net_device *dev, __be32 src_ip,
 			 const unsigned char *dest_hw,
 			 const unsigned char *src_hw, const unsigned char *th);
-extern int	arp_bind_neighbour(struct dst_entry *dst);
 extern int	arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir);
 extern void	arp_ifdown(struct net_device *dev);
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f7afb4c..3e55456 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -517,30 +517,6 @@ EXPORT_SYMBOL(arp_find);
 
 /* END OF OBSOLETE FUNCTIONS */
 
-int arp_bind_neighbour(struct dst_entry *dst)
-{
-	struct net_device *dev = dst->dev;
-	struct neighbour *n = dst_get_neighbour(dst);
-
-	if (dev == NULL)
-		return -EINVAL;
-	if (n == NULL) {
-		__be32 nexthop = ((struct rtable *)dst)->rt_gateway;
-		if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-			nexthop = 0;
-		n = __neigh_lookup_errno(
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-					 dev->type == ARPHRD_ATM ?
-					 clip_tbl_hook :
-#endif
-					 &arp_tbl, &nexthop, dev);
-		if (IS_ERR(n))
-			return PTR_ERR(n);
-		dst_set_neighbour(dst, n);
-	}
-	return 0;
-}
-
 /*
  * Check if we can use proxy ARP for this path
  */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e3a45cd..8f39909 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -108,7 +108,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
-#include <net/secure_seq.h>
+#include <net/atmclip.h>
 
 #define RT_FL_TOS(oldflp4) \
     ((u32)(oldflp4->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
@@ -1009,6 +1009,29 @@ static int slow_chain_length(const struct rtable *head)
 	return length >> FRACT_BITS;
 }
 
+static int rt_bind_neighbour(struct rtable *rt)
+{
+	static const __be32 inaddr_any = 0;
+	struct net_device *dev = rt->dst.dev;
+	struct neigh_table *tbl = &arp_tbl;
+	const __be32 *nexthop;
+	struct neighbour *n;
+
+#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+	if (dev->type == ARPHRD_ATM)
+		tbl = clip_tbl_hook;
+#endif
+	nexthop = &rt->rt_gateway;
+	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
+		nexthop = &inaddr_any;
+	n = ipv4_neigh_lookup(tbl, dev, nexthop);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	rt->dst.neighbour = n;
+
+	return 0;
+}
+
 static struct rtable *rt_intern_hash(unsigned hash, struct rtable *rt,
 				     struct sk_buff *skb, int ifindex)
 {
@@ -1045,7 +1068,7 @@ restart:
 
 		rt->dst.flags |= DST_NOCACHE;
 		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-			int err = arp_bind_neighbour(&rt->dst);
+			int err = rt_bind_neighbour(rt);
 			if (err) {
 				if (net_ratelimit())
 					printk(KERN_WARNING
@@ -1141,7 +1164,7 @@ restart:
 	   route or unicast forwarding path.
 	 */
 	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-		int err = arp_bind_neighbour(&rt->dst);
+		int err = rt_bind_neighbour(rt);
 		if (err) {
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
@@ -1603,7 +1626,7 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	dst_set_neighbour(&rt->dst, NULL);
 
 	rt->rt_gateway = peer->redirect_learned.a4;
-	arp_bind_neighbour(&rt->dst);
+	rt_bind_neighbour(rt);
 	n = dst_get_neighbour(&rt->dst);
 	if (!n || !(n->nud_state & NUD_VALID)) {
 		if (n)
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0005-ipv4-Use-universal-hash-for-ARP.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0005-ipv4-Use-universal-hash-for-ARP.patch"

>From 4fad2467644857ccd9833340792a9717b51ee573 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Mon, 11 Jul 2011 01:37:28 -0700
Subject: [PATCH 05/13] ipv4: Use universal hash for ARP.

We need to make sure the multiplier is odd.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h    |    7 +++++++
 net/core/neighbour.c |    1 +
 net/ipv4/arp.c       |    3 +--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 91f0568..723bde5 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -8,6 +8,13 @@
 
 extern struct neigh_table arp_tbl;
 
+static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
+{
+	u32 val = key ^ dev->ifindex;
+
+	return val * hash_rnd;
+}
+
 extern void	arp_init(void);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60e2249..2d02723 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -334,6 +334,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int shift)
 	ret->hash_buckets = buckets;
 	ret->hash_shift = shift;
 	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
+	ret->hash_rnd |= 1;
 	return ret;
 }
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c098239..f7afb4c 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -97,7 +97,6 @@
 #include <linux/init.h>
 #include <linux/net.h>
 #include <linux/rcupdate.h>
-#include <linux/jhash.h>
 #include <linux/slab.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
@@ -232,7 +231,7 @@ static u32 arp_hash(const void *pkey,
 		    const struct net_device *dev,
 		    __u32 hash_rnd)
 {
-	return jhash_2words(*(u32 *)pkey, dev->ifindex, hash_rnd);
+	return arp_hashfn(*(u32 *)pkey, dev, hash_rnd);
 }
 
 static int arp_constructor(struct neighbour *neigh)
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0004-neigh-Store-hash-shift-instead-of-mask.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0004-neigh-Store-hash-shift-instead-of-mask.patch"

>From ea91e3d47d06167ce74055a43cbc68a04ea25bca Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Mon, 11 Jul 2011 01:28:12 -0700
Subject: [PATCH 04/13] neigh: Store hash shift instead of mask.

And mask the hash function result by simply shifting
down the "->hash_shift" most significant bits.

Currently which bits we use is arbitrary since jhash
produces entropy evenly across the whole hash function
result.

But soon we'll be using universal hashing functions,
and in those cases more entropy exists in the higher
bits than the lower bits, because they use multiplies.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    2 +-
 net/core/neighbour.c    |   47 +++++++++++++++++++++++------------------------
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 4014b62..6fe8c2c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -142,7 +142,7 @@ struct pneigh_entry {
 
 struct neigh_hash_table {
 	struct neighbour __rcu	**hash_buckets;
-	unsigned int		hash_mask;
+	unsigned int		hash_shift;
 	__u32			hash_rnd;
 	struct rcu_head		rcu;
 };
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8c54aff..60e2249 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -137,7 +137,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
 	write_lock_bh(&tbl->lock);
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
-	for (i = 0; i <= nht->hash_mask; i++) {
+	for (i = 0; i < (1 << nht->hash_shift); i++) {
 		struct neighbour *n;
 		struct neighbour __rcu **np;
 
@@ -210,7 +210,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
-	for (i = 0; i <= nht->hash_mask; i++) {
+	for (i = 0; i < (1 << nht->hash_shift); i++) {
 		struct neighbour *n;
 		struct neighbour __rcu **np = &nht->hash_buckets[i];
 
@@ -312,9 +312,9 @@ out_entries:
 	goto out;
 }
 
-static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
+static struct neigh_hash_table *neigh_hash_alloc(unsigned int shift)
 {
-	size_t size = entries * sizeof(struct neighbour *);
+	size_t size = (1 << shift) * sizeof(struct neighbour *);
 	struct neigh_hash_table *ret;
 	struct neighbour __rcu **buckets;
 
@@ -332,7 +332,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
 		return NULL;
 	}
 	ret->hash_buckets = buckets;
-	ret->hash_mask = entries - 1;
+	ret->hash_shift = shift;
 	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
 	return ret;
 }
@@ -342,7 +342,7 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
 	struct neigh_hash_table *nht = container_of(head,
 						    struct neigh_hash_table,
 						    rcu);
-	size_t size = (nht->hash_mask + 1) * sizeof(struct neighbour *);
+	size_t size = (1 << nht->hash_shift) * sizeof(struct neighbour *);
 	struct neighbour __rcu **buckets = nht->hash_buckets;
 
 	if (size <= PAGE_SIZE)
@@ -353,21 +353,20 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
 }
 
 static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
-						unsigned long new_entries)
+						unsigned long new_shift)
 {
 	unsigned int i, hash;
 	struct neigh_hash_table *new_nht, *old_nht;
 
 	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
 
-	BUG_ON(!is_power_of_2(new_entries));
 	old_nht = rcu_dereference_protected(tbl->nht,
 					    lockdep_is_held(&tbl->lock));
-	new_nht = neigh_hash_alloc(new_entries);
+	new_nht = neigh_hash_alloc(new_shift);
 	if (!new_nht)
 		return old_nht;
 
-	for (i = 0; i <= old_nht->hash_mask; i++) {
+	for (i = 0; i < (1 << old_nht->hash_shift); i++) {
 		struct neighbour *n, *next;
 
 		for (n = rcu_dereference_protected(old_nht->hash_buckets[i],
@@ -377,7 +376,7 @@ static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
 			hash = tbl->hash(n->primary_key, n->dev,
 					 new_nht->hash_rnd);
 
-			hash &= new_nht->hash_mask;
+			hash >>= (32 - new_nht->hash_shift);
 			next = rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock));
 
@@ -406,7 +405,7 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
-	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
+	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
@@ -436,7 +435,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
-	hash_val = tbl->hash(pkey, NULL, nht->hash_rnd) & nht->hash_mask;
+	hash_val = tbl->hash(pkey, NULL, nht->hash_rnd) >> (32 - nht->hash_shift);
 
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
@@ -492,10 +491,10 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
-	if (atomic_read(&tbl->entries) > (nht->hash_mask + 1))
-		nht = neigh_hash_grow(tbl, (nht->hash_mask + 1) << 1);
+	if (atomic_read(&tbl->entries) > (1 << nht->hash_shift))
+		nht = neigh_hash_grow(tbl, nht->hash_shift + 1);
 
-	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) & nht->hash_mask;
+	hash_val = tbl->hash(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 
 	if (n->parms->dead) {
 		rc = ERR_PTR(-EINVAL);
@@ -784,7 +783,7 @@ static void neigh_periodic_work(struct work_struct *work)
 				neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	for (i = 0 ; i <= nht->hash_mask; i++) {
+	for (i = 0 ; i < (1 << nht->hash_shift); i++) {
 		np = &nht->hash_buckets[i];
 
 		while ((n = rcu_dereference_protected(*np,
@@ -1549,7 +1548,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 		panic("cannot create neighbour proc dir entry");
 #endif
 
-	RCU_INIT_POINTER(tbl->nht, neigh_hash_alloc(8));
+	RCU_INIT_POINTER(tbl->nht, neigh_hash_alloc(3));
 
 	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
 	tbl->phash_buckets = kzalloc(phsize, GFP_KERNEL);
@@ -1866,7 +1865,7 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 		rcu_read_lock_bh();
 		nht = rcu_dereference_bh(tbl->nht);
 		ndc.ndtc_hash_rnd = nht->hash_rnd;
-		ndc.ndtc_hash_mask = nht->hash_mask;
+		ndc.ndtc_hash_mask = ((1 << nht->hash_shift) - 1);
 		rcu_read_unlock_bh();
 
 		NLA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
@@ -2209,7 +2208,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 
-	for (h = 0; h <= nht->hash_mask; h++) {
+	for (h = 0; h < (1 << nht->hash_shift); h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
@@ -2273,7 +2272,7 @@ void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void
 	nht = rcu_dereference_bh(tbl->nht);
 
 	read_lock(&tbl->lock); /* avoid resizes */
-	for (chain = 0; chain <= nht->hash_mask; chain++) {
+	for (chain = 0; chain < (1 << nht->hash_shift); chain++) {
 		struct neighbour *n;
 
 		for (n = rcu_dereference_bh(nht->hash_buckets[chain]);
@@ -2295,7 +2294,7 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
-	for (chain = 0; chain <= nht->hash_mask; chain++) {
+	for (chain = 0; chain < (1 << nht->hash_shift); chain++) {
 		struct neighbour *n;
 		struct neighbour __rcu **np;
 
@@ -2332,7 +2331,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 	int bucket = state->bucket;
 
 	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
-	for (bucket = 0; bucket <= nht->hash_mask; bucket++) {
+	for (bucket = 0; bucket < (1 << nht->hash_shift); bucket++) {
 		n = rcu_dereference_bh(nht->hash_buckets[bucket]);
 
 		while (n) {
@@ -2399,7 +2398,7 @@ next:
 		if (n)
 			break;
 
-		if (++state->bucket > nht->hash_mask)
+		if (++state->bucket >= (1 << nht->hash_shift))
 			break;
 
 		n = rcu_dereference_bh(nht->hash_buckets[state->bucket]);
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0003-neigh-fix-rcu-splat-in-neigh_update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0003-neigh-fix-rcu-splat-in-neigh_update.patch"

>From 7a150a1cf3de046ab6aa864fa4f479f343da4f7f Mon Sep 17 00:00:00 2001
From: roy.qing.li@gmail.com <roy.qing.li@gmail.com>
Date: Mon, 17 Oct 2011 22:32:42 +0000
Subject: [PATCH 03/13] neigh: fix rcu splat in neigh_update()

when use dst_get_neighbour to get neighbour, we need
rcu_read_lock to protect, since dst_get_neighbour uses
rcu_dereference.

The bug was reported by Ari Savolainen <ari.m.savolainen@gmail.com>

[  105.612095]
[  105.612096] ===================================================
[  105.612100] [ INFO: suspicious rcu_dereference_check() usage. ]
[  105.612101] ---------------------------------------------------
[  105.612103] include/net/dst.h:91 invoked rcu_dereference_check()
without protection!
[  105.612105]
[  105.612106] other info that might help us debug this:
[  105.612106]
[  105.612108]
[  105.612108] rcu_scheduler_active = 1, debug_locks = 0
[  105.612110] 1 lock held by dnsmasq/2618:
[  105.612111]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815df8c7>]
rtnl_lock+0x17/0x20
[  105.612120]
[  105.612121] stack backtrace:
[  105.612123] Pid: 2618, comm: dnsmasq Not tainted 3.1.0-rc1 #41
[  105.612125] Call Trace:
[  105.612129]  [<ffffffff810ccdcb>] lockdep_rcu_dereference+0xbb/0xc0
[  105.612132]  [<ffffffff815dc5a9>] neigh_update+0x4f9/0x5f0
[  105.612135]  [<ffffffff815da001>] ? neigh_lookup+0xe1/0x220
[  105.612139]  [<ffffffff81639298>] arp_req_set+0xb8/0x230
[  105.612142]  [<ffffffff8163a59f>] arp_ioctl+0x1bf/0x310
[  105.612146]  [<ffffffff810baa40>] ? lock_hrtimer_base.isra.26+0x30/0x60
[  105.612150]  [<ffffffff8163fb75>] inet_ioctl+0x85/0x90
[  105.612154]  [<ffffffff815b5520>] sock_do_ioctl+0x30/0x70
[  105.612157]  [<ffffffff815b55d3>] sock_ioctl+0x73/0x280
[  105.612162]  [<ffffffff811b7698>] do_vfs_ioctl+0x98/0x570
[  105.612165]  [<ffffffff811a5c40>] ? fget_light+0x340/0x3a0
[  105.612168]  [<ffffffff811b7bbf>] sys_ioctl+0x4f/0x80
[  105.612172]  [<ffffffff816fdcab>] system_call_fastpath+0x16/0x1b

Reported-by: Ari Savolainen <ari.m.savolainen@gmail.com>
Signed-off-by: RongQing <roy.qing.li@gmail.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/neighbour.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8767f9f..8c54aff 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1176,10 +1176,14 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 			struct dst_entry *dst = skb_dst(skb);
 			struct neighbour *n2, *n1 = neigh;
 			write_unlock_bh(&neigh->lock);
+
+			rcu_read_lock();
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
 			if (dst && (n2 = dst_get_neighbour(dst)) != NULL)
 				n1 = n2;
 			n1->output(skb);
+			rcu_read_unlock();
+
 			write_lock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0002-net-Abstract-dst-neighbour-accesses-behind-helpers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="rcu_0002-net-Abstract-dst-neighbour-accesses-behind-helpers.";
 filename*1="patch"

>From 2dc95005cd884544cdc7b0a83b18d81ae75c3870 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Sun, 17 Jul 2011 23:09:49 -0700
Subject: [PATCH 02/13] net: Abstract dst->neighbour accesses behind helpers.

Upstream: 69cce1d1404968f78b177a0314f5822d5afdbbfb
+ some add. fixes to make this patch compatible with 3.0.X

dst_{get,set}_neighbour()

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/addr.c                 |    7 ++--
 drivers/infiniband/hw/cxgb3/iwch_cm.c          |   12 ++++--
 drivers/infiniband/hw/cxgb4/cm.c               |   42 ++++++++++++------------
 drivers/infiniband/hw/nes/nes_cm.c             |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   41 +++++++++++++++--------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   20 +++++++----
 drivers/net/cxgb3/cxgb3_offload.c              |    8 ++--
 drivers/s390/net/qeth_l3_main.c                |   25 ++++++++++----
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c             |    2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c             |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c                  |    4 +-
 include/net/dst.h                              |   18 ++++++++--
 net/atm/clip.c                                 |   16 ++++++---
 net/bridge/br_netfilter.c                      |    6 ++-
 net/core/dst.c                                 |   10 +++---
 net/core/neighbour.c                           |   15 ++++----
 net/decnet/dn_neigh.c                          |    2 +-
 net/decnet/dn_route.c                          |   16 +++++----
 net/ipv4/arp.c                                 |    4 +-
 net/ipv4/ip_gre.c                              |    2 +-
 net/ipv4/ip_output.c                           |    8 +++--
 net/ipv4/route.c                               |   19 ++++++----
 net/ipv6/addrconf.c                            |    2 +-
 net/ipv6/ip6_fib.c                             |    2 +-
 net/ipv6/ip6_output.c                          |   20 +++++++----
 net/ipv6/ndisc.c                               |    4 +-
 net/ipv6/route.c                               |   39 +++++++++++-----------
 net/ipv6/sit.c                                 |    4 +-
 net/sched/sch_teql.c                           |    4 +-
 net/xfrm/xfrm_policy.c                         |    2 +-
 30 files changed, 213 insertions(+), 145 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 8e21d45..236ad9a 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -215,7 +215,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 
 	neigh = neigh_lookup(&arp_tbl, &rt->rt_gateway, rt->dst.dev);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
-		neigh_event_send(rt->dst.neighbour, NULL);
+		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
 		ret = -ENODATA;
 		if (neigh)
 			goto release;
@@ -273,9 +273,10 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 		goto put;
 	}
 
-	neigh = dst->neighbour;
+	neigh = dst_get_neighbour(dst);
 	if (!neigh || !(neigh->nud_state & NUD_VALID)) {
-		neigh_event_send(dst->neighbour, NULL);
+		if (neigh)
+			neigh_event_send(neigh, NULL);
 		ret = -ENODATA;
 		goto put;
 	}
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 2332dc2..6cd642a 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1328,6 +1328,7 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 	struct iwch_ep *child_ep, *parent_ep = ctx;
 	struct cpl_pass_accept_req *req = cplhdr(skb);
 	unsigned int hwtid = GET_TID(req);
+	struct neighbour *neigh;
 	struct dst_entry *dst;
 	struct l2t_entry *l2t;
 	struct rtable *rt;
@@ -1364,7 +1365,8 @@ static int pass_accept_req(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 		goto reject;
 	}
 	dst = &rt->dst;
-	l2t = t3_l2t_get(tdev, dst->neighbour, dst->neighbour->dev);
+	neigh = dst_get_neighbour(dst);
+	l2t = t3_l2t_get(tdev, neigh, neigh->dev);
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -1874,10 +1876,11 @@ static int is_loopback_dst(struct iw_cm_id *cm_id)
 
 int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 {
-	int err = 0;
 	struct iwch_dev *h = to_iwch_dev(cm_id->device);
+	struct neighbour *neigh;
 	struct iwch_ep *ep;
 	struct rtable *rt;
+	int err = 0;
 
 	if (is_loopback_dst(cm_id)) {
 		err = -ENOSYS;
@@ -1933,9 +1936,10 @@ int iwch_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 
+	neigh = dst_get_neighbour(ep->dst);
+
 	/* get a l2t entry */
-	ep->l2t = t3_l2t_get(ep->com.tdev, ep->dst->neighbour,
-			     ep->dst->neighbour->dev);
+	ep->l2t = t3_l2t_get(ep->com.tdev, neigh, neigh->dev);
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		err = -ENOMEM;
diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 31fb440..77f769d 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1325,6 +1325,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	unsigned int stid = GET_POPEN_TID(ntohl(req->tos_stid));
 	struct tid_info *t = dev->rdev.lldi.tids;
 	unsigned int hwtid = GET_TID(req);
+	struct neighbour *neigh;
 	struct dst_entry *dst;
 	struct l2t_entry *l2t;
 	struct rtable *rt;
@@ -1357,11 +1358,11 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 	dst = &rt->dst;
-	if (dst->neighbour->dev->flags & IFF_LOOPBACK) {
+	neigh = dst_get_neighbour(dst);
+	if (neigh->dev->flags & IFF_LOOPBACK) {
 		pdev = ip_dev_find(&init_net, peer_ip);
 		BUG_ON(!pdev);
-		l2t = cxgb4_l2t_get(dev->rdev.lldi.l2t, dst->neighbour,
-				    pdev, 0);
+		l2t = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh, pdev, 0);
 		mtu = pdev->mtu;
 		tx_chan = cxgb4_port_chan(pdev);
 		smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
@@ -1372,17 +1373,16 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		rss_qid = dev->rdev.lldi.rxq_ids[cxgb4_port_idx(pdev) * step];
 		dev_put(pdev);
 	} else {
-		l2t = cxgb4_l2t_get(dev->rdev.lldi.l2t, dst->neighbour,
-					dst->neighbour->dev, 0);
+		l2t = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh, neigh->dev, 0);
 		mtu = dst_mtu(dst);
-		tx_chan = cxgb4_port_chan(dst->neighbour->dev);
-		smac_idx = (cxgb4_port_viid(dst->neighbour->dev) & 0x7F) << 1;
+		tx_chan = cxgb4_port_chan(neigh->dev);
+		smac_idx = (cxgb4_port_viid(neigh->dev) & 0x7F) << 1;
 		step = dev->rdev.lldi.ntxq / dev->rdev.lldi.nchan;
-		txq_idx = cxgb4_port_idx(dst->neighbour->dev) * step;
-		ctrlq_idx = cxgb4_port_idx(dst->neighbour->dev);
+		txq_idx = cxgb4_port_idx(neigh->dev) * step;
+		ctrlq_idx = cxgb4_port_idx(neigh->dev);
 		step = dev->rdev.lldi.nrxq / dev->rdev.lldi.nchan;
 		rss_qid = dev->rdev.lldi.rxq_ids[
-			  cxgb4_port_idx(dst->neighbour->dev) * step];
+			  cxgb4_port_idx(neigh->dev) * step];
 	}
 	if (!l2t) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
@@ -1847,6 +1847,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	struct c4iw_ep *ep;
 	struct rtable *rt;
 	struct net_device *pdev;
+	struct neighbour *neigh;
 	int step;
 
 	if ((conn_param->ord > c4iw_max_read_depth) ||
@@ -1908,14 +1909,15 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 
+	neigh = dst_get_neighbour(ep->dst);
+
 	/* get a l2t entry */
-	if (ep->dst->neighbour->dev->flags & IFF_LOOPBACK) {
+	if (neigh->dev->flags & IFF_LOOPBACK) {
 		PDBG("%s LOOPBACK\n", __func__);
 		pdev = ip_dev_find(&init_net,
 				   cm_id->remote_addr.sin_addr.s_addr);
 		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-					ep->dst->neighbour,
-					pdev, 0);
+					neigh, pdev, 0);
 		ep->mtu = pdev->mtu;
 		ep->tx_chan = cxgb4_port_chan(pdev);
 		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
@@ -1930,20 +1932,18 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		dev_put(pdev);
 	} else {
 		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-					ep->dst->neighbour,
-					ep->dst->neighbour->dev, 0);
+					neigh, neigh->dev, 0);
 		ep->mtu = dst_mtu(ep->dst);
-		ep->tx_chan = cxgb4_port_chan(ep->dst->neighbour->dev);
-		ep->smac_idx = (cxgb4_port_viid(ep->dst->neighbour->dev) &
-				0x7F) << 1;
+		ep->tx_chan = cxgb4_port_chan(neigh->dev);
+		ep->smac_idx = (cxgb4_port_viid(neigh->dev) & 0x7F) << 1;
 		step = ep->com.dev->rdev.lldi.ntxq /
 		       ep->com.dev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(ep->dst->neighbour->dev) * step;
-		ep->ctrlq_idx = cxgb4_port_idx(ep->dst->neighbour->dev);
+		ep->txq_idx = cxgb4_port_idx(neigh->dev) * step;
+		ep->ctrlq_idx = cxgb4_port_idx(neigh->dev);
 		step = ep->com.dev->rdev.lldi.nrxq /
 		       ep->com.dev->rdev.lldi.nchan;
 		ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[
-			      cxgb4_port_idx(ep->dst->neighbour->dev) * step];
+			      cxgb4_port_idx(neigh->dev) * step];
 	}
 	if (!ep->l2t) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index e74cdf9..73bc184 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -1151,7 +1151,7 @@ static int nes_addr_resolve_neigh(struct nes_vnic *nesvnic, u32 dst_ip, int arpi
 	}
 
 	if ((neigh == NULL) || (!(neigh->nud_state & NUD_VALID)))
-		neigh_event_send(rt->dst.neighbour, NULL);
+		neigh_event_send(dst_get_neighbour(&rt->dst), NULL);
 
 	ip_rt_put(rt);
 	return rc;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 86addca..43f89ba 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -560,9 +560,11 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
+	struct neighbour *n;
 	unsigned long flags;
 
-	neigh = ipoib_neigh_alloc(skb_dst(skb)->neighbour, skb->dev);
+	n = dst_get_neighbour(skb_dst(skb));
+	neigh = ipoib_neigh_alloc(n, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
@@ -571,9 +573,9 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	path = __path_find(dev, skb_dst(skb)->neighbour->ha + 4);
+	path = __path_find(dev, n->ha + 4);
 	if (!path) {
-		path = path_rec_create(dev, skb_dst(skb)->neighbour->ha + 4);
+		path = path_rec_create(dev, n->ha + 4);
 		if (!path)
 			goto err_path;
 
@@ -607,7 +609,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 			}
 		} else {
 			spin_unlock_irqrestore(&priv->lock, flags);
-			ipoib_send(dev, skb, path->ah, IPOIB_QPN(skb_dst(skb)->neighbour->ha));
+			ipoib_send(dev, skb, path->ah, IPOIB_QPN(n->ha));
 			return;
 		}
 	} else {
@@ -637,17 +639,20 @@ err_drop:
 static void ipoib_path_lookup(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(skb->dev);
+	struct dst_entry *dst = skb_dst(skb);
+	struct neighbour *n;
 
 	/* Look up path record for unicasts */
-	if (skb_dst(skb)->neighbour->ha[4] != 0xff) {
+	n = dst_get_neighbour(dst);
+	if (n->ha[4] != 0xff) {
 		neigh_add_path(skb, dev);
 		return;
 	}
 
 	/* Add in the P_Key for multicasts */
-	skb_dst(skb)->neighbour->ha[8] = (priv->pkey >> 8) & 0xff;
-	skb_dst(skb)->neighbour->ha[9] = priv->pkey & 0xff;
-	ipoib_mcast_send(dev, skb_dst(skb)->neighbour->ha + 4, skb);
+	n->ha[8] = (priv->pkey >> 8) & 0xff;
+	n->ha[9] = priv->pkey & 0xff;
+	ipoib_mcast_send(dev, n->ha + 4, skb);
 }
 
 static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
@@ -712,18 +717,20 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
+	struct neighbour *n;
 	unsigned long flags;
 
-	if (likely(skb_dst(skb) && skb_dst(skb)->neighbour)) {
-		if (unlikely(!*to_ipoib_neigh(skb_dst(skb)->neighbour))) {
+	n = dst_get_neighbour(skb_dst(skb));
+	if (likely(skb_dst(skb) && n)) {
+		if (unlikely(!*to_ipoib_neigh(n))) {
 			ipoib_path_lookup(skb, dev);
 			return NETDEV_TX_OK;
 		}
 
-		neigh = *to_ipoib_neigh(skb_dst(skb)->neighbour);
+		neigh = *to_ipoib_neigh(n);
 
 		if (unlikely((memcmp(&neigh->dgid.raw,
-				     skb_dst(skb)->neighbour->ha + 4,
+				     n->ha + 4,
 				     sizeof(union ib_gid))) ||
 			     (neigh->dev != dev))) {
 			spin_lock_irqsave(&priv->lock, flags);
@@ -749,7 +756,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				return NETDEV_TX_OK;
 			}
 		} else if (neigh->ah) {
-			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(skb_dst(skb)->neighbour->ha));
+			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(n->ha));
 			return NETDEV_TX_OK;
 		}
 
@@ -812,6 +819,8 @@ static int ipoib_hard_header(struct sk_buff *skb,
 			     const void *daddr, const void *saddr, unsigned len)
 {
 	struct ipoib_header *header;
+	struct dst_entry *dst;
+	struct neighbour *n;
 
 	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
 
@@ -823,7 +832,11 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	 * destination address onto the front of the skb so we can
 	 * figure out where to send the packet later.
 	 */
-	if ((!skb_dst(skb) || !skb_dst(skb)->neighbour) && daddr) {
+	dst = skb_dst(skb);
+	n = NULL;
+	if (dst)
+		n = dst_get_neighbour(dst);
+	if ((!dst || !n) && daddr) {
 		struct ipoib_pseudoheader *phdr =
 			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
 		memcpy(phdr->hwaddr, daddr, INFINIBAND_ALEN);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 3871ac6..ecea4fe 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -258,11 +258,15 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 	netif_tx_lock_bh(dev);
 	while (!skb_queue_empty(&mcast->pkt_queue)) {
 		struct sk_buff *skb = skb_dequeue(&mcast->pkt_queue);
+		struct dst_entry *dst = skb_dst(skb);
+		struct neighbour *n = NULL;
+
 		netif_tx_unlock_bh(dev);
 
 		skb->dev = dev;
-
-		if (!skb_dst(skb) || !skb_dst(skb)->neighbour) {
+		if (dst)
+			n = dst_get_neighbour(dst);
+		if (!dst || !n) {
 			/* put pseudoheader back on for next time */
 			skb_push(skb, sizeof (struct ipoib_pseudoheader));
 		}
@@ -715,11 +719,13 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 
 out:
 	if (mcast && mcast->ah) {
-		if (skb_dst(skb)		&&
-		    skb_dst(skb)->neighbour &&
-		    !*to_ipoib_neigh(skb_dst(skb)->neighbour)) {
-			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb_dst(skb)->neighbour,
-									skb->dev);
+		struct dst_entry *dst = skb_dst(skb);
+		struct neighbour *n = NULL;
+		if (dst)
+			n = dst_get_neighbour(dst);
+		if (n && !*to_ipoib_neigh(n)) {
+			struct ipoib_neigh *neigh = ipoib_neigh_alloc(n,
+								      skb->dev);
 
 			if (neigh) {
 				kref_get(&mcast->ah->ref);
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 3f2e12c..015b515 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -971,7 +971,7 @@ static int nb_callback(struct notifier_block *self, unsigned long event,
 	case (NETEVENT_REDIRECT):{
 		struct netevent_redirect *nr = ctx;
 		cxgb_redirect(nr->old, nr->new);
-		cxgb_neigh_update(nr->new->neighbour);
+		cxgb_neigh_update(dst_get_neighbour(nr->new));
 		break;
 	}
 	default:
@@ -1116,8 +1116,8 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	struct l2t_entry *e;
 	struct t3c_tid_entry *te;
 
-	olddev = old->neighbour->dev;
-	newdev = new->neighbour->dev;
+	olddev = dst_get_neighbour(old)->dev;
+	newdev = dst_get_neighbour(new)->dev;
 	if (!is_offloading(olddev))
 		return;
 	if (!is_offloading(newdev)) {
@@ -1134,7 +1134,7 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	}
 
 	/* Add new L2T entry */
-	e = t3_l2t_get(tdev, new->neighbour, newdev);
+	e = t3_l2t_get(tdev, dst_get_neighbour(new), newdev);
 	if (!e) {
 		printk(KERN_ERR "%s: couldn't allocate new l2t entry!\n",
 		       __func__);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index fd69da3..e2c9ac5 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2742,9 +2742,14 @@ static int qeth_l3_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 {
 	int cast_type = RTN_UNSPEC;
-
-	if (skb_dst(skb) && skb_dst(skb)->neighbour) {
-		cast_type = skb_dst(skb)->neighbour->type;
+	struct neighbour *n = NULL;
+	struct dst_entry *dst;
+
+	dst = skb_dst(skb);
+	if (dst)
+		n = dst_get_neighbour(dst);
+	if (n) {
+		cast_type = n->type;
 		if ((cast_type == RTN_BROADCAST) ||
 		    (cast_type == RTN_MULTICAST) ||
 		    (cast_type == RTN_ANYCAST))
@@ -2787,6 +2792,9 @@ int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		struct sk_buff *skb, int ipv, int cast_type)
 {
+	struct neighbour *n = NULL;
+	struct dst_entry *dst;
+
 	memset(hdr, 0, sizeof(struct qeth_hdr));
 	hdr->hdr.l3.id = QETH_HEADER_TYPE_LAYER3;
 	hdr->hdr.l3.ext_flags = 0;
@@ -2804,13 +2812,16 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	}
 
 	hdr->hdr.l3.length = skb->len - sizeof(struct qeth_hdr);
+	dst = skb_dst(skb);
+	if (dst)
+		n = dst_get_neighbour(dst);
 	if (ipv == 4) {
 		/* IPv4 */
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags4(cast_type);
 		memset(hdr->hdr.l3.dest_addr, 0, 12);
-		if ((skb_dst(skb)) && (skb_dst(skb)->neighbour)) {
+		if (n) {
 			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
-			    *((u32 *) skb_dst(skb)->neighbour->primary_key);
+			    *((u32 *) n->primary_key);
 		} else {
 			/* fill in destination address used in ip header */
 			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
@@ -2821,9 +2832,9 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags6(cast_type);
 		if (card->info.type == QETH_CARD_TYPE_IQD)
 			hdr->hdr.l3.flags &= ~QETH_HDR_PASSTHRU;
-		if ((skb_dst(skb)) && (skb_dst(skb)->neighbour)) {
+		if (n) {
 			memcpy(hdr->hdr.l3.dest_addr,
-			       skb_dst(skb)->neighbour->primary_key, 16);
+			       n->primary_key, 16);
 		} else {
 			/* fill in destination address used in ip header */
 			memcpy(hdr->hdr.l3.dest_addr,
diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index b2d6611..143f268 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -985,7 +985,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 		csk->saddr.sin_addr.s_addr = chba->ipv4addr;
 
 	csk->rss_qid = 0;
-	csk->l2t = t3_l2t_get(t3dev, dst->neighbour, ndev);
+	csk->l2t = t3_l2t_get(t3dev, dst_get_neighbour(dst), ndev);
 	if (!csk->l2t) {
 		pr_err("NO l2t available.\n");
 		return -EINVAL;
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index f3a4cd7..ae13c49 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1160,7 +1160,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	csk->l2t = cxgb4_l2t_get(lldi->l2t, csk->dst->neighbour, ndev, 0);
+	csk->l2t = cxgb4_l2t_get(lldi->l2t, dst_get_neighbour(csk->dst), ndev, 0);
 	if (!csk->l2t) {
 		pr_err("%s, cannot alloc l2t.\n", ndev->name);
 		goto rel_resource;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index a2a9c7c..77ac217 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -492,7 +492,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		goto err_out;
 	}
 	dst = &rt->dst;
-	ndev = dst->neighbour->dev;
+	ndev = dst_get_neighbour(dst)->dev;
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
 		pr_info("multi-cast route %pI4, port %u, dev %s.\n",
@@ -506,7 +506,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 		ndev = ip_dev_find(&init_net, daddr->sin_addr.s_addr);
 		mtu = ndev->mtu;
 		pr_info("rt dev %s, loopback -> %s, mtu %u.\n",
-			dst->neighbour->dev->name, ndev->name, mtu);
+			dst_get_neighbour(dst)->dev->name, ndev->name, mtu);
 	}
 
 	cdev = cxgbi_device_find_by_netdev(ndev, &port);
diff --git a/include/net/dst.h b/include/net/dst.h
index e12ddfb..5938610 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -37,7 +37,7 @@ struct dst_entry {
 	unsigned long		_metrics;
 	unsigned long		expires;
 	struct dst_entry	*path;
-	struct neighbour	*neighbour;
+	struct neighbour	*_neighbour;
 	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
@@ -86,6 +86,16 @@ struct dst_entry {
 	};
 };
 
+static inline struct neighbour *dst_get_neighbour(struct dst_entry *dst)
+{
+	return dst->_neighbour;
+}
+
+static inline void dst_set_neighbour(struct dst_entry *dst, struct neighbour *neigh)
+{
+	dst->_neighbour = neigh;
+}
+
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
 extern const u32 dst_default_metrics[RTAX_MAX];
 
@@ -371,8 +381,10 @@ static inline void dst_rcu_free(struct rcu_head *head)
 
 static inline void dst_confirm(struct dst_entry *dst)
 {
-	if (dst)
-		neigh_confirm(dst->neighbour);
+	if (dst) {
+		struct neighbour *n = dst_get_neighbour(dst);
+		neigh_confirm(n);
+	}
 }
 
 static inline void dst_link_failure(struct sk_buff *skb)
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 1d4be60..5889074 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -364,33 +364,37 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 				   struct net_device *dev)
 {
 	struct clip_priv *clip_priv = PRIV(dev);
+	struct dst_entry *dst = skb_dst(skb);
 	struct atmarp_entry *entry;
+	struct neighbour *n;
 	struct atm_vcc *vcc;
 	int old;
 	unsigned long flags;
 
 	pr_debug("(skb %p)\n", skb);
-	if (!skb_dst(skb)) {
+	if (!dst) {
 		pr_err("skb_dst(skb) == NULL\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
-	if (!skb_dst(skb)->neighbour) {
+	n = dst_get_neighbour(dst);
+	if (!n) {
 #if 0
-		skb_dst(skb)->neighbour = clip_find_neighbour(skb_dst(skb), 1);
-		if (!skb_dst(skb)->neighbour) {
+		n = clip_find_neighbour(skb_dst(skb), 1);
+		if (!n) {
 			dev_kfree_skb(skb);	/* lost that one */
 			dev->stats.tx_dropped++;
 			return 0;
 		}
+		dst_set_neighbour(dst, n);
 #endif
 		pr_err("NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
-	entry = NEIGH2ENTRY(skb_dst(skb)->neighbour);
+	entry = NEIGH2ENTRY(n);
 	if (!entry->vccs) {
 		if (time_after(jiffies, entry->expires)) {
 			/* should be resolved */
@@ -407,7 +411,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	}
 	pr_debug("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
-	pr_debug("using neighbour %p, vcc %p\n", skb_dst(skb)->neighbour, vcc);
+	pr_debug("using neighbour %p, vcc %p\n", n, vcc);
 	if (entry->vccs->encap) {
 		void *here;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 56149ec..3dc7f54 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -343,24 +343,26 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct neighbour *neigh;
 	struct dst_entry *dst;
 
 	skb->dev = bridge_parent(skb->dev);
 	if (!skb->dev)
 		goto free_skb;
 	dst = skb_dst(skb);
+	neigh = dst_get_neighbour(dst);
 	if (dst->hh) {
 		neigh_hh_bridge(dst->hh, skb);
 		skb->dev = nf_bridge->physindev;
 		return br_handle_frame_finish(skb);
-	} else if (dst->neighbour) {
+	} else if (neigh) {
 		/* the neighbour function below overwrites the complete
 		 * MAC header, so we save the Ethernet source address and
 		 * protocol number. */
 		skb_copy_from_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN), skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
 		/* tell br_dev_xmit to continue with forwarding */
 		nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-		return dst->neighbour->output(skb);
+		return neigh->output(skb);
 	}
 free_skb:
 	kfree_skb(skb);
diff --git a/net/core/dst.c b/net/core/dst.c
index 6135f36..62c9b01 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -171,7 +171,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst_init_metrics(dst, dst_default_metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
-	dst->neighbour = NULL;
+	dst->_neighbour = NULL;
 	dst->hh = NULL;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
@@ -231,7 +231,7 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 	smp_rmb();
 
 again:
-	neigh = dst->neighbour;
+	neigh = dst->_neighbour;
 	hh = dst->hh;
 	child = dst->child;
 
@@ -240,7 +240,7 @@ again:
 		hh_cache_put(hh);
 
 	if (neigh) {
-		dst->neighbour = NULL;
+		dst->_neighbour = NULL;
 		neigh_release(neigh);
 	}
 
@@ -370,8 +370,8 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 		dst->dev = dev_net(dst->dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
-		if (dst->neighbour && dst->neighbour->dev == dev) {
-			dst->neighbour->dev = dst->dev;
+		if (dst->_neighbour && dst->_neighbour->dev == dev) {
+			dst->_neighbour->dev = dst->dev;
 			dev_hold(dst->dev);
 			dev_put(dev);
 		}
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 16db887..8767f9f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1173,11 +1173,12 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 
 		while (neigh->nud_state & NUD_VALID &&
 		       (skb = __skb_dequeue(&neigh->arp_queue)) != NULL) {
-			struct neighbour *n1 = neigh;
+			struct dst_entry *dst = skb_dst(skb);
+			struct neighbour *n2, *n1 = neigh;
 			write_unlock_bh(&neigh->lock);
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
-			if (skb_dst(skb) && skb_dst(skb)->neighbour)
-				n1 = skb_dst(skb)->neighbour;
+			if (dst && (n2 = dst_get_neighbour(dst)) != NULL)
+				n1 = n2;
 			n1->output(skb);
 			write_lock_bh(&neigh->lock);
 		}
@@ -1300,10 +1301,10 @@ EXPORT_SYMBOL(neigh_compat_output);
 int neigh_resolve_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	int rc = 0;
 
-	if (!dst || !(neigh = dst->neighbour))
+	if (!dst)
 		goto discard;
 
 	__skb_pull(skb, skb_network_offset(skb));
@@ -1333,7 +1334,7 @@ out:
 	return rc;
 discard:
 	NEIGH_PRINTK1("neigh_resolve_output: dst=%p neigh=%p\n",
-		      dst, dst ? dst->neighbour : NULL);
+		      dst, neigh);
 out_kfree_skb:
 	rc = -EINVAL;
 	kfree_skb(skb);
@@ -1347,7 +1348,7 @@ int neigh_connected_output(struct sk_buff *skb)
 {
 	int err;
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	struct net_device *dev = neigh->dev;
 	unsigned int seq;
 
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 602dade..2a90341 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -208,7 +208,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	struct net_device *dev = neigh->dev;
 	char mac_addr[ETH_ALEN];
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 74544bc..c9d5bcf 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -241,9 +241,11 @@ static int dn_dst_gc(struct dst_ops *ops)
  */
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
+	struct neighbour *n = dst_get_neighbour(dst);
 	u32 min_mtu = 230;
-	struct dn_dev *dn = dst->neighbour ?
-			    rcu_dereference_raw(dst->neighbour->dev->dn_ptr) : NULL;
+	struct dn_dev *dn;
+
+	dn = n ? rcu_dereference_raw(n->dev->dn_ptr) : NULL;
 
 	if (dn && dn->use_long == 0)
 		min_mtu -= 6;
@@ -715,7 +717,7 @@ static int dn_output(struct sk_buff *skb)
 
 	int err = -EINVAL;
 
-	if ((neigh = dst->neighbour) == NULL)
+	if ((neigh = dst_get_neighbour(dst)) == NULL)
 		goto error;
 
 	skb->dev = dev;
@@ -833,11 +835,11 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 	}
 	rt->rt_type = res->type;
 
-	if (dev != NULL && rt->dst.neighbour == NULL) {
+	if (dev != NULL && dst_get_neighbour(&rt->dst) == NULL) {
 		n = __neigh_lookup_errno(&dn_neigh_table, &rt->rt_gateway, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
-		rt->dst.neighbour = n;
+		dst_set_neighbour(&rt->dst, n);
 	}
 
 	if (dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
@@ -1144,7 +1146,7 @@ make_route:
 	rt->rt_dst_map    = fld.daddr;
 	rt->rt_src_map    = fld.saddr;
 
-	rt->dst.neighbour = neigh;
+	dst_set_neighbour(&rt->dst, neigh);
 	neigh = NULL;
 
 	rt->dst.lastuse = jiffies;
@@ -1416,7 +1418,7 @@ make_route:
 	rt->fld.flowidn_iif  = in_dev->ifindex;
 	rt->fld.flowidn_mark = fld.flowidn_mark;
 
-	rt->dst.neighbour = neigh;
+	dst_set_neighbour(&rt->dst, neigh);
 	rt->dst.lastuse = jiffies;
 	rt->dst.output = dn_rt_bug;
 	switch(res.type) {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1b74d3b..c098239 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -521,7 +521,7 @@ EXPORT_SYMBOL(arp_find);
 int arp_bind_neighbour(struct dst_entry *dst)
 {
 	struct net_device *dev = dst->dev;
-	struct neighbour *n = dst->neighbour;
+	struct neighbour *n = dst_get_neighbour(dst);
 
 	if (dev == NULL)
 		return -EINVAL;
@@ -537,7 +537,7 @@ int arp_bind_neighbour(struct dst_entry *dst)
 					 &arp_tbl, &nexthop, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
-		dst->neighbour = n;
+		dst_set_neighbour(dst, n);
 	}
 	return 0;
 }
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8871067..d7bb94c 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -731,9 +731,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
+			struct neighbour *neigh = dst_get_neighbour(skb_dst(skb));
 			const struct in6_addr *addr6;
 			int addr_type;
-			struct neighbour *neigh = skb_dst(skb)->neighbour;
 
 			if (neigh == NULL)
 				goto tx_error;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0c99db4..3f994ca 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -182,6 +182,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
+	struct neighbour *neigh;
 
 	if (rt->rt_type == RTN_MULTICAST) {
 		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTMCAST, skb->len);
@@ -202,11 +203,12 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		kfree_skb(skb);
 		skb = skb2;
 	}
-
+	
+	neigh = dst_get_neighbour(dst);
 	if (dst->hh)
 		return neigh_hh_output(dst->hh, skb);
-	else if (dst->neighbour)
-		return dst->neighbour->output(skb);
+	else if (neigh)
+		return neigh->output(skb);
 
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 75ef66f..e3a45cd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -412,8 +412,10 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			   "HHUptod\tSpecDst");
 	else {
 		struct rtable *r = v;
+		// struct neighbour *n;
 		int len;
 
+		// n = dst_get_neighbour(&r->dst);
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
 			r->dst.dev ? r->dst.dev->name : "*",
@@ -1593,23 +1595,24 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 {
 	struct rtable *rt = (struct rtable *) dst;
 	__be32 orig_gw = rt->rt_gateway;
+	struct neighbour *n;
 
 	dst_confirm(&rt->dst);
 
-	neigh_release(rt->dst.neighbour);
-	rt->dst.neighbour = NULL;
+	neigh_release(dst_get_neighbour(&rt->dst));
+	dst_set_neighbour(&rt->dst, NULL);
 
 	rt->rt_gateway = peer->redirect_learned.a4;
-	if (arp_bind_neighbour(&rt->dst) ||
-	    !(rt->dst.neighbour->nud_state & NUD_VALID)) {
-		if (rt->dst.neighbour)
-			neigh_event_send(rt->dst.neighbour, NULL);
+	arp_bind_neighbour(&rt->dst);
+	n = dst_get_neighbour(&rt->dst);
+	if (!n || !(n->nud_state & NUD_VALID)) {
+		if (n)
+			neigh_event_send(n, NULL);
 		rt->rt_gateway = orig_gw;
 		return -EAGAIN;
 	} else {
 		rt->rt_flags |= RTCF_REDIRECTED;
-		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE,
-					rt->dst.neighbour);
+		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 	}
 	return 0;
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index bcd7aed..1fa96a0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -656,7 +656,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	 * layer address of our nexhop router
 	 */
 
-	if (rt->dst.neighbour == NULL)
+	if (dst_get_neighbour(&rt->dst) == NULL)
 		ifa->flags &= ~IFA_F_OPTIMISTIC;
 
 	ifa->idev = idev;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 098dc76..fb1eb5e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1455,7 +1455,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(rt->dst.neighbour->flags & NTF_ROUTER))) {
+			   (!(dst_get_neighbour(&rt->dst)->flags & NTF_ROUTER))) {
 			RT6_TRACE("purging route %p via non-router but gateway\n",
 				  rt);
 			return -1;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e17596b..228d317 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -100,6 +100,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
+	struct neighbour *neigh;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
@@ -134,10 +135,11 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
+	neigh = dst_get_neighbour(dst);
 	if (dst->hh)
 		return neigh_hh_output(dst->hh, skb);
-	else if (dst->neighbour)
-		return dst->neighbour->output(skb);
+	else if (neigh)
+		return neigh->output(skb);
 
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
@@ -385,6 +387,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct net *net = dev_net(dst->dev);
+	struct neighbour *n;
 	u32 mtu;
 
 	if (net->ipv6.devconf_all->forwarding == 0)
@@ -459,11 +462,10 @@ int ip6_forward(struct sk_buff *skb)
 	   send redirects to source routed frames.
 	   We don't send redirects to frames decapsulated from IPsec.
 	 */
-	if (skb->dev == dst->dev && dst->neighbour && opt->srcrt == 0 &&
-	    !skb_sec_path(skb)) {
+	n = dst_get_neighbour(dst);
+	if (skb->dev == dst->dev && n && opt->srcrt == 0 && !skb_sec_path(skb)) {
 		struct in6_addr *target = NULL;
 		struct rt6_info *rt;
-		struct neighbour *n = dst->neighbour;
 
 		/*
 		 *	incoming and outgoing devices are the same
@@ -949,8 +951,11 @@ out:
 static int ip6_dst_lookup_tail(struct sock *sk,
 			       struct dst_entry **dst, struct flowi6 *fl6)
 {
-	int err;
 	struct net *net = sock_net(sk);
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	struct neighbour *n;
+#endif
+	int err;
 
 	if (*dst == NULL)
 		*dst = ip6_route_output(net, sk, fl6);
@@ -976,7 +981,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry and replace it instead with the
 	 * dst entry of the nexthop router
 	 */
-	if ((*dst)->neighbour && !((*dst)->neighbour->nud_state & NUD_VALID)) {
+	n = dst_get_neighbour(*dst);
+	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
 		int redirect;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index dee1a19..10a8d41 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1244,7 +1244,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	rt = rt6_get_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev);
 
 	if (rt)
-		neigh = rt->dst.neighbour;
+		neigh = dst_get_neighbour(&rt->dst);
 
 	if (rt && lifetime == 0) {
 		neigh_clone(neigh);
@@ -1265,7 +1265,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			return;
 		}
 
-		neigh = rt->dst.neighbour;
+		neigh = dst_get_neighbour(&rt->dst);
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6ee9307..e215539 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -356,7 +356,7 @@ out:
 #ifdef CONFIG_IPV6_ROUTER_PREF
 static void rt6_probe(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt ? rt->dst.neighbour : NULL;
+	struct neighbour *neigh = rt ? dst_get_neighbour(&rt->dst) : NULL;
 	/*
 	 * Okay, this does not seem to be appropriate
 	 * for now, however, we need to check if it
@@ -404,7 +404,7 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 
 static inline int rt6_check_neigh(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt->dst.neighbour;
+	struct neighbour *neigh = dst_get_neighbour(&rt->dst);
 	int m;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
@@ -745,7 +745,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, const struct in6_add
 			dst_free(&rt->dst);
 			return NULL;
 		}
-		rt->dst.neighbour = neigh;
+		dst_set_neighbour(&rt->dst, neigh);
 
 	}
 
@@ -760,7 +760,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const struct in6_a
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
 		rt->dst.flags |= DST_HOST;
-		rt->dst.neighbour = neigh_clone(ort->dst.neighbour);
+		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour(&ort->dst)));
 	}
 	return rt;
 }
@@ -794,7 +794,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!rt->dst.neighbour && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!dst_get_neighbour(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1058,7 +1058,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	}
 
 	rt->rt6i_idev     = idev;
-	rt->dst.neighbour  = neigh;
+	dst_set_neighbour(&rt->dst, neigh);
 	atomic_set(&rt->dst.__refcnt, 1);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
 	rt->dst.output  = ip6_output;
@@ -1338,12 +1338,12 @@ int ip6_route_add(struct fib6_config *cfg)
 		rt->rt6i_prefsrc.plen = 0;
 
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
-		rt->dst.neighbour = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
-		if (IS_ERR(rt->dst.neighbour)) {
-			err = PTR_ERR(rt->dst.neighbour);
-			rt->dst.neighbour = NULL;
+		struct neighbour *n = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
+		if (IS_ERR(n)) {
+			err = PTR_ERR(n);
 			goto out;
 		}
+		dst_set_neighbour(&rt->dst, n);
 	}
 
 	rt->rt6i_flags = cfg->fc_flags;
@@ -1574,7 +1574,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	if (neigh == rt->dst.neighbour)
+	if (neigh == dst_get_neighbour(&rt->dst))
 		goto out;
 
 	nrt = ip6_rt_copy(rt);
@@ -1590,7 +1590,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	nrt->dst.flags |= DST_HOST;
 
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
-	nrt->dst.neighbour = neigh_clone(neigh);
+	dst_set_neighbour(&nrt->dst, neigh_clone(neigh));
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -1670,7 +1670,7 @@ again:
 	   1. It is connected route. Action: COW
 	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
 	 */
-	if (!rt->dst.neighbour && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!dst_get_neighbour(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, daddr, saddr);
 	else
 		nrt = rt6_alloc_clone(rt, daddr);
@@ -2035,7 +2035,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 
 		return ERR_CAST(neigh);
 	}
-	rt->dst.neighbour = neigh;
+	dst_set_neighbour(&rt->dst, neigh);
 
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
@@ -2400,8 +2400,8 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (rt->dst.neighbour)
-		NLA_PUT(skb, RTA_GATEWAY, 16, &rt->dst.neighbour->primary_key);
+	if (dst_get_neighbour(&rt->dst))
+		NLA_PUT(skb, RTA_GATEWAY, 16, &dst_get_neighbour(&rt->dst)->primary_key);
 
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
@@ -2585,6 +2585,7 @@ struct rt6_proc_arg
 static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
 	struct seq_file *m = p_arg;
+	struct neighbour *n;
 
 	seq_printf(m, "%pi6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
 
@@ -2593,9 +2594,9 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
-
-	if (rt->dst.neighbour) {
-		seq_printf(m, "%pi6", rt->dst.neighbour->primary_key);
+	n = dst_get_neighbour(&rt->dst);
+	if (n) {
+		seq_printf(m, "%pi6", n->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1cca576..07bf108 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -677,7 +677,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		struct neighbour *neigh = NULL;
 
 		if (skb_dst(skb))
-			neigh = skb_dst(skb)->neighbour;
+			neigh = dst_get_neighbour(skb_dst(skb));
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
@@ -702,7 +702,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		struct neighbour *neigh = NULL;
 
 		if (skb_dst(skb))
-			neigh = skb_dst(skb)->neighbour;
+			neigh = dst_get_neighbour(skb_dst(skb));
 
 		if (neigh == NULL) {
 			if (net_ratelimit())
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 45cd300..a3b7120 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -229,7 +229,7 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 {
 	struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
 	struct teql_sched_data *q = qdisc_priv(dev_queue->qdisc);
-	struct neighbour *mn = skb_dst(skb)->neighbour;
+	struct neighbour *mn = dst_get_neighbour(skb_dst(skb));
 	struct neighbour *n = q->ncache;
 
 	if (mn->tbl == NULL)
@@ -270,7 +270,7 @@ static inline int teql_resolve(struct sk_buff *skb,
 
 	if (dev->header_ops == NULL ||
 	    skb_dst(skb) == NULL ||
-	    skb_dst(skb)->neighbour == NULL)
+	    dst_get_neighbour(skb_dst(skb)) == NULL)
 		return 0;
 	return __teql_resolve(skb, skb_res, dev);
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5ce74a3..7803eb6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1497,7 +1497,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		goto free_dst;
 
 	/* Copy neighbour for reachability confirmation */
-	dst0->neighbour = neigh_clone(dst->neighbour);
+	dst_set_neighbour(dst0, neigh_clone(dst_get_neighbour(dst)));
 
 	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
 	xfrm_init_pmtu(dst_prev);
-- 
1.7.1


--------------070906000400070006060408
Content-Type: text/x-patch;
 name="rcu_0001-ipv6-Get-rid-of-rt6i_nexthop-macro.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rcu_0001-ipv6-Get-rid-of-rt6i_nexthop-macro.patch"

>From 103f10c1235673d1d0dc7fec8b5254cb104d4a0a Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@davemloft.net>
Date: Sun, 17 Jul 2011 20:06:13 -0700
Subject: [PATCH 01/13] ipv6: Get rid of rt6i_nexthop macro.

It just makes it harder to see 1) what the code is doing
and 2) grep for all users of dst{->,.}neighbour

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_fib.h |    1 -
 net/ipv6/addrconf.c   |    2 +-
 net/ipv6/ip6_fib.c    |    2 +-
 net/ipv6/ndisc.c      |    4 ++--
 net/ipv6/route.c      |   30 +++++++++++++++---------------
 5 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 477ef75..5735a0f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -87,7 +87,6 @@ struct rt6_info {
 	struct dst_entry		dst;
 
 #define rt6i_dev			dst.dev
-#define rt6i_nexthop			dst.neighbour
 #define rt6i_expires			dst.expires
 
 	/*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 498b927..bcd7aed 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -656,7 +656,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	 * layer address of our nexhop router
 	 */
 
-	if (rt->rt6i_nexthop == NULL)
+	if (rt->dst.neighbour == NULL)
 		ifa->flags &= ~IFA_F_OPTIMISTIC;
 
 	ifa->idev = idev;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 4076a0b..098dc76 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1455,7 +1455,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(rt->rt6i_nexthop->flags & NTF_ROUTER))) {
+			   (!(rt->dst.neighbour->flags & NTF_ROUTER))) {
 			RT6_TRACE("purging route %p via non-router but gateway\n",
 				  rt);
 			return -1;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7596f07..dee1a19 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1244,7 +1244,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	rt = rt6_get_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev);
 
 	if (rt)
-		neigh = rt->rt6i_nexthop;
+		neigh = rt->dst.neighbour;
 
 	if (rt && lifetime == 0) {
 		neigh_clone(neigh);
@@ -1265,7 +1265,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			return;
 		}
 
-		neigh = rt->rt6i_nexthop;
+		neigh = rt->dst.neighbour;
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0ef1f08..6ee9307 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -356,7 +356,7 @@ out:
 #ifdef CONFIG_IPV6_ROUTER_PREF
 static void rt6_probe(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt ? rt->rt6i_nexthop : NULL;
+	struct neighbour *neigh = rt ? rt->dst.neighbour : NULL;
 	/*
 	 * Okay, this does not seem to be appropriate
 	 * for now, however, we need to check if it
@@ -404,7 +404,7 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 
 static inline int rt6_check_neigh(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt->rt6i_nexthop;
+	struct neighbour *neigh = rt->dst.neighbour;
 	int m;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
@@ -745,7 +745,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, const struct in6_add
 			dst_free(&rt->dst);
 			return NULL;
 		}
-		rt->rt6i_nexthop = neigh;
+		rt->dst.neighbour = neigh;
 
 	}
 
@@ -760,7 +760,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const struct in6_a
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
 		rt->dst.flags |= DST_HOST;
-		rt->rt6i_nexthop = neigh_clone(ort->rt6i_nexthop);
+		rt->dst.neighbour = neigh_clone(ort->dst.neighbour);
 	}
 	return rt;
 }
@@ -794,7 +794,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->dst.neighbour && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1058,7 +1058,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	}
 
 	rt->rt6i_idev     = idev;
-	rt->rt6i_nexthop  = neigh;
+	rt->dst.neighbour  = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
 	rt->dst.output  = ip6_output;
@@ -1338,10 +1338,10 @@ int ip6_route_add(struct fib6_config *cfg)
 		rt->rt6i_prefsrc.plen = 0;
 
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
-		rt->rt6i_nexthop = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
-		if (IS_ERR(rt->rt6i_nexthop)) {
-			err = PTR_ERR(rt->rt6i_nexthop);
-			rt->rt6i_nexthop = NULL;
+		rt->dst.neighbour = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
+		if (IS_ERR(rt->dst.neighbour)) {
+			err = PTR_ERR(rt->dst.neighbour);
+			rt->dst.neighbour = NULL;
 			goto out;
 		}
 	}
@@ -1590,7 +1590,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	nrt->dst.flags |= DST_HOST;
 
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
-	nrt->rt6i_nexthop = neigh_clone(neigh);
+	nrt->dst.neighbour = neigh_clone(neigh);
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -1670,7 +1670,7 @@ again:
 	   1. It is connected route. Action: COW
 	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
 	 */
-	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->dst.neighbour && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, daddr, saddr);
 	else
 		nrt = rt6_alloc_clone(rt, daddr);
@@ -2035,7 +2035,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 
 		return ERR_CAST(neigh);
 	}
-	rt->rt6i_nexthop = neigh;
+	rt->dst.neighbour = neigh;
 
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
@@ -2594,8 +2594,8 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 
-	if (rt->rt6i_nexthop) {
-		seq_printf(m, "%pi6", rt->rt6i_nexthop->primary_key);
+	if (rt->dst.neighbour) {
+		seq_printf(m, "%pi6", rt->dst.neighbour->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
-- 
1.7.1


--------------070906000400070006060408--
