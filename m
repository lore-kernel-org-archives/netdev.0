From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] net: Abstract dst->neighbour accesses behind helpers.
Date: Mon, 18 Jul 2011 01:25:16 -0700 (PDT)
Message-ID: <20110718.012516.2295551246732567875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab1GRIZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:19 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6I8PHag028327
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 01:25:17 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
 net/bridge/br_netfilter.c                      |    2 +-
 net/core/dst.c                                 |   10 +++---
 net/core/neighbour.c                           |    7 ++--
 net/decnet/dn_neigh.c                          |    2 +-
 net/decnet/dn_route.c                          |   18 ++++++----
 net/ipv4/ip_gre.c                              |    2 +-
 net/ipv4/ip_output.c                           |    2 +-
 net/ipv4/route.c                               |   25 +++++++-------
 net/ipv6/addrconf.c                            |    2 +-
 net/ipv6/ip6_fib.c                             |    2 +-
 net/ipv6/ip6_output.c                          |   16 ++++++---
 net/ipv6/ndisc.c                               |    4 +-
 net/ipv6/route.c                               |   39 +++++++++++-----------
 net/ipv6/sit.c                                 |    4 +-
 net/sched/sch_teql.c                           |    4 +-
 net/xfrm/xfrm_policy.c                         |    2 +-
 29 files changed, 200 insertions(+), 140 deletions(-)

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
index 0a5008f..17bf9d9 100644
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
index 9db9068..fa1b450 100644
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
index fc2cdb6..abc7b12 100644
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
index 0dd7ccb..8147206 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -37,7 +37,7 @@ struct dst_entry {
 	unsigned long		_metrics;
 	unsigned long		expires;
 	struct dst_entry	*path;
-	struct neighbour	*neighbour;
+	struct neighbour	*_neighbour;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
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
index c6cd531..4bc8c67 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -362,33 +362,37 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
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
@@ -405,7 +409,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	}
 	pr_debug("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
-	pr_debug("using neighbour %p, vcc %p\n", skb_dst(skb)->neighbour, vcc);
+	pr_debug("using neighbour %p, vcc %p\n", n, vcc);
 	if (entry->vccs->encap) {
 		void *here;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1fe43fd..b1a5f97 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -350,7 +350,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 	if (!skb->dev)
 		goto free_skb;
 	dst = skb_dst(skb);
-	neigh = dst->neighbour;
+	neigh = dst_get_neighbour(dst);
 	if (neigh->hh.hh_len) {
 		neigh_hh_bridge(&neigh->hh, skb);
 		skb->dev = nf_bridge->physindev;
diff --git a/net/core/dst.c b/net/core/dst.c
index 4aacc14..14b33baf 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -171,7 +171,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst_init_metrics(dst, dst_default_metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
-	dst->neighbour = NULL;
+	dst->_neighbour = NULL;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
 #endif
@@ -229,11 +229,11 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 	smp_rmb();
 
 again:
-	neigh = dst->neighbour;
+	neigh = dst->_neighbour;
 	child = dst->child;
 
 	if (neigh) {
-		dst->neighbour = NULL;
+		dst->_neighbour = NULL;
 		neigh_release(neigh);
 	}
 
@@ -363,8 +363,8 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
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
index cefb8e5..8fab9b0 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1153,11 +1153,12 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 
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
 			n1->output(n1, skb);
 			write_lock_bh(&neigh->lock);
 		}
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 5d61e89..0dc3fe6 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -202,7 +202,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	struct net_device *dev = neigh->dev;
 	char mac_addr[ETH_ALEN];
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 3b6400d..9bd45fc 100644
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
@@ -708,7 +710,7 @@ out:
 static int dn_to_neigh_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *n = dst->neighbour;
+	struct neighbour *n = dst_get_neighbour(dst);
 
 	return n->output(n, skb);
 }
@@ -723,7 +725,7 @@ static int dn_output(struct sk_buff *skb)
 
 	int err = -EINVAL;
 
-	if ((neigh = dst->neighbour) == NULL)
+	if ((neigh = dst_get_neighbour(dst)) == NULL)
 		goto error;
 
 	skb->dev = dev;
@@ -840,11 +842,11 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
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
@@ -1151,7 +1153,7 @@ make_route:
 	rt->rt_dst_map    = fld.daddr;
 	rt->rt_src_map    = fld.saddr;
 
-	rt->dst.neighbour = neigh;
+	dst_set_neighbour(&rt->dst, neigh);
 	neigh = NULL;
 
 	rt->dst.lastuse = jiffies;
@@ -1423,7 +1425,7 @@ make_route:
 	rt->fld.flowidn_iif  = in_dev->ifindex;
 	rt->fld.flowidn_mark = fld.flowidn_mark;
 
-	rt->dst.neighbour = neigh;
+	dst_set_neighbour(&rt->dst, neigh);
 	rt->dst.lastuse = jiffies;
 	rt->dst.output = dn_rt_bug;
 	switch (res.type) {
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
index db296a9..be27e60 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -204,7 +204,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		skb = skb2;
 	}
 
-	neigh = dst->neighbour;
+	neigh = dst_get_neighbour(dst);
 	if (neigh)
 		return neigh_output(neigh, skb);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcf9bb5..1d4cd3b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -412,8 +412,10 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			   "HHUptod\tSpecDst");
 	else {
 		struct rtable *r = v;
+		struct neighbour *n;
 		int len;
 
+		n = dst_get_neighbour(&r->dst);
 		seq_printf(seq, "%s\t%08X\t%08X\t%8X\t%d\t%u\t%d\t"
 			      "%08X\t%d\t%u\t%u\t%02X\t%d\t%1d\t%08X%n",
 			r->dst.dev ? r->dst.dev->name : "*",
@@ -427,9 +429,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
 			-1,
-			(r->dst.neighbour &&
-			 (r->dst.neighbour->nud_state & NUD_CONNECTED)) ?
-			   1 : 0,
+			(n && (n->nud_state & NUD_CONNECTED)) ? 1 : 0,
 			r->rt_spec_dst, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
@@ -1026,7 +1026,7 @@ static int rt_bind_neighbour(struct rtable *rt)
 	n = ipv4_neigh_lookup(tbl, dev, nexthop);
 	if (IS_ERR(n))
 		return PTR_ERR(n);
-	rt->dst.neighbour = n;
+	dst_set_neighbour(&rt->dst, n);
 
 	return 0;
 }
@@ -1617,23 +1617,24 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
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
-	if (rt_bind_neighbour(rt) ||
-	    !(rt->dst.neighbour->nud_state & NUD_VALID)) {
-		if (rt->dst.neighbour)
-			neigh_event_send(rt->dst.neighbour, NULL);
+	rt_bind_neighbour(rt);
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
index 48cd03d..a06c53c 100644
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
index 158df23..54a4678 100644
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
index eb50bb0..8db0e48 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -135,7 +135,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
-	neigh = dst->neighbour;
+	neigh = dst_get_neighbour(dst);
 	if (neigh)
 		return neigh_output(neigh, skb);
 
@@ -385,6 +385,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct net *net = dev_net(dst->dev);
+	struct neighbour *n;
 	u32 mtu;
 
 	if (net->ipv6.devconf_all->forwarding == 0)
@@ -459,11 +460,10 @@ int ip6_forward(struct sk_buff *skb)
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
@@ -920,8 +920,11 @@ out:
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
@@ -947,7 +950,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
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
index a997d41..9da6e02 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1238,7 +1238,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	rt = rt6_get_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev);
 
 	if (rt)
-		neigh = rt->dst.neighbour;
+		neigh = dst_get_neighbour(&rt->dst);
 
 	if (rt && lifetime == 0) {
 		neigh_clone(neigh);
@@ -1259,7 +1259,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			return;
 		}
 
-		neigh = rt->dst.neighbour;
+		neigh = dst_get_neighbour(&rt->dst);
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c1515a3..2998cb5 100644
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
1.7.6

