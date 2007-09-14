From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 9/10 REV5] [IPoIB] Implement batching
Date: Fri, 14 Sep 2007 14:34:23 +0530
Message-ID: <20070914090423.17589.77448.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, xma@us.ibm.com, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:42452 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbXINJCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 05:02:23 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E92Not017779
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E92MuW467242
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E92Js3026938
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:22 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPoIB: implement the new batching API.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_main.c |  248 +++++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 168 insertions(+), 80 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_main.c new/drivers/infiniband/ulp/ipoib/ipoib_main.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-09-13 09:10:58.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-09-14 10:25:36.000000000 +0530
@@ -563,7 +563,8 @@ static void neigh_add_path(struct sk_buf
 				goto err_drop;
 			}
 		} else
-			ipoib_send(dev, skb, path->ah, IPOIB_QPN(skb->dst->neighbour->ha));
+			ipoib_send(dev, skb, path->ah,
+				   IPOIB_QPN(skb->dst->neighbour->ha), 1);
 	} else {
 		neigh->ah  = NULL;
 
@@ -643,7 +644,7 @@ static void unicast_arp_send(struct sk_b
 		ipoib_dbg(priv, "Send unicast ARP to %04x\n",
 			  be16_to_cpu(path->pathrec.dlid));
 
-		ipoib_send(dev, skb, path->ah, IPOIB_QPN(phdr->hwaddr));
+		ipoib_send(dev, skb, path->ah, IPOIB_QPN(phdr->hwaddr), 1);
 	} else if ((path->query || !path_rec_start(dev, path)) &&
 		   skb_queue_len(&path->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
 		/* put pseudoheader back on for next time */
@@ -657,105 +658,163 @@ static void unicast_arp_send(struct sk_b
 	spin_unlock(&priv->lock);
 }
 
+#define	XMIT_PROCESSED_SKBS()						\
+	do {								\
+		if (wr_num) {						\
+			ipoib_send(dev, NULL, old_neigh->ah, old_qpn,	\
+				   wr_num);				\
+			wr_num = 0;					\
+		}							\
+	} while (0)
+
 static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
-	struct ipoib_neigh *neigh;
+	struct sk_buff_head *blist;
+	int max_skbs, wr_num = 0;
+	u32 qpn, old_qpn = 0;
+	struct ipoib_neigh *neigh, *old_neigh = NULL;
 	unsigned long flags;
 
 	if (unlikely(!spin_trylock_irqsave(&priv->tx_lock, flags)))
 		return NETDEV_TX_LOCKED;
 
-	/*
-	 * Check if our queue is stopped.  Since we have the LLTX bit
-	 * set, we can't rely on netif_stop_queue() preventing our
-	 * xmit function from being called with a full queue.
-	 */
-	if (unlikely(netif_queue_stopped(dev))) {
-		spin_unlock_irqrestore(&priv->tx_lock, flags);
-		return NETDEV_TX_BUSY;
+	blist = dev->skb_blist;
+	if (!skb || (blist && skb_queue_len(blist))) {
+		/*
+		 * Either batching xmit call, or single skb case but there are
+		 * skbs already in the batch list from previous failure to
+		 * xmit - send the earlier skbs first to avoid out of order.
+		 */
+
+		if (skb)
+			__skb_queue_tail(blist, skb);
+
+		/*
+		 * Figure out how many skbs can be sent. This prevents the
+		 * device getting full and avoids checking for stopped queue
+		 * after each iteration. Now the queue can get stopped atmost
+		 * after xmit of the last skb.
+		 */
+		max_skbs = ipoib_sendq_size - (priv->tx_head - priv->tx_tail);
+		skb = __skb_dequeue(blist);
+	} else {
+		blist = NULL;
+		max_skbs = 1;
 	}
 
-	if (likely(skb->dst && skb->dst->neighbour)) {
-		if (unlikely(!*to_ipoib_neigh(skb->dst->neighbour))) {
-			ipoib_path_lookup(skb, dev);
-			goto out;
-		}
-
-		neigh = *to_ipoib_neigh(skb->dst->neighbour);
-
-		if (ipoib_cm_get(neigh)) {
-			if (ipoib_cm_up(neigh)) {
-				ipoib_cm_send(dev, skb, ipoib_cm_get(neigh));
-				goto out;
-			}
-		} else if (neigh->ah) {
-			if (unlikely(memcmp(&neigh->dgid.raw,
-					    skb->dst->neighbour->ha + 4,
-					    sizeof(union ib_gid)))) {
-				spin_lock(&priv->lock);
-				/*
-				 * It's safe to call ipoib_put_ah() inside
-				 * priv->lock here, because we know that
-				 * path->ah will always hold one more reference,
-				 * so ipoib_put_ah() will never do more than
-				 * decrement the ref count.
-				 */
-				ipoib_put_ah(neigh->ah);
-				list_del(&neigh->list);
-				ipoib_neigh_free(dev, neigh);
-				spin_unlock(&priv->lock);
+	do {
+		if (likely(skb->dst && skb->dst->neighbour)) {
+			if (unlikely(!*to_ipoib_neigh(skb->dst->neighbour))) {
+				XMIT_PROCESSED_SKBS();
 				ipoib_path_lookup(skb, dev);
-				goto out;
+				continue;
 			}
 
-			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(skb->dst->neighbour->ha));
-			goto out;
-		}
-
-		if (skb_queue_len(&neigh->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
-			spin_lock(&priv->lock);
-			__skb_queue_tail(&neigh->queue, skb);
-			spin_unlock(&priv->lock);
-		} else {
-			++priv->stats.tx_dropped;
-			dev_kfree_skb_any(skb);
-		}
-	} else {
-		struct ipoib_pseudoheader *phdr =
-			(struct ipoib_pseudoheader *) skb->data;
-		skb_pull(skb, sizeof *phdr);
+			neigh = *to_ipoib_neigh(skb->dst->neighbour);
 
-		if (phdr->hwaddr[4] == 0xff) {
-			/* Add in the P_Key for multicast*/
-			phdr->hwaddr[8] = (priv->pkey >> 8) & 0xff;
-			phdr->hwaddr[9] = priv->pkey & 0xff;
+			if (ipoib_cm_get(neigh)) {
+				if (ipoib_cm_up(neigh)) {
+					XMIT_PROCESSED_SKBS();
+					ipoib_cm_send(dev, skb,
+						      ipoib_cm_get(neigh));
+					continue;
+				}
+			} else if (neigh->ah) {
+				if (unlikely(memcmp(&neigh->dgid.raw,
+						    skb->dst->neighbour->ha + 4,
+						    sizeof(union ib_gid)))) {
+					spin_lock(&priv->lock);
+					/*
+					 * It's safe to call ipoib_put_ah()
+					 * inside priv->lock here, because we
+					 * know that path->ah will always hold
+					 * one more reference, so ipoib_put_ah()
+					 * will never do more than decrement
+					 * the ref count.
+					 */
+					ipoib_put_ah(neigh->ah);
+					list_del(&neigh->list);
+					ipoib_neigh_free(dev, neigh);
+					spin_unlock(&priv->lock);
+					XMIT_PROCESSED_SKBS();
+					ipoib_path_lookup(skb, dev);
+					continue;
+				}
+
+				qpn = IPOIB_QPN(skb->dst->neighbour->ha);
+				if (neigh != old_neigh || qpn != old_qpn) {
+					/*
+					 * Sending to a different destination
+					 * from earlier skb's (or this is the
+					 * first skb) - send all existing skbs.
+					 */
+					XMIT_PROCESSED_SKBS();
+					old_neigh = neigh;
+					old_qpn = qpn;
+				}
+
+				if (likely(!ipoib_process_skb(dev, skb, priv,
+							      neigh->ah, qpn,
+							      wr_num)))
+					wr_num++;
 
-			ipoib_mcast_send(dev, phdr->hwaddr + 4, skb);
-		} else {
-			/* unicast GID -- should be ARP or RARP reply */
+				continue;
+			}
 
-			if ((be16_to_cpup((__be16 *) skb->data) != ETH_P_ARP) &&
-			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP)) {
-				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x "
-					   IPOIB_GID_FMT "\n",
-					   skb->dst ? "neigh" : "dst",
-					   be16_to_cpup((__be16 *) skb->data),
-					   IPOIB_QPN(phdr->hwaddr),
-					   IPOIB_GID_RAW_ARG(phdr->hwaddr + 4));
+			if (skb_queue_len(&neigh->queue) <
+			    IPOIB_MAX_PATH_REC_QUEUE) {
+				spin_lock(&priv->lock);
+				__skb_queue_tail(&neigh->queue, skb);
+				spin_unlock(&priv->lock);
+			} else {
 				dev_kfree_skb_any(skb);
 				++priv->stats.tx_dropped;
-				goto out;
 			}
-
-			unicast_arp_send(skb, dev, phdr);
+		} else {
+			struct ipoib_pseudoheader *phdr =
+				(struct ipoib_pseudoheader *) skb->data;
+			skb_pull(skb, sizeof *phdr);
+
+			if (phdr->hwaddr[4] == 0xff) {
+				/* Add in the P_Key for multicast*/
+				phdr->hwaddr[8] = (priv->pkey >> 8) & 0xff;
+				phdr->hwaddr[9] = priv->pkey & 0xff;
+
+				XMIT_PROCESSED_SKBS();
+				ipoib_mcast_send(dev, phdr->hwaddr + 4, skb);
+			} else {
+				/* unicast GID -- should be ARP or RARP reply */
+
+				if ((be16_to_cpup((__be16 *) skb->data) !=
+				    ETH_P_ARP) &&
+				    (be16_to_cpup((__be16 *) skb->data) !=
+				    ETH_P_RARP)) {
+					ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x "
+						IPOIB_GID_FMT "\n",
+						skb->dst ? "neigh" : "dst",
+						be16_to_cpup((__be16 *)
+						skb->data),
+						IPOIB_QPN(phdr->hwaddr),
+						IPOIB_GID_RAW_ARG(phdr->hwaddr
+								  + 4));
+					dev_kfree_skb_any(skb);
+					++priv->stats.tx_dropped;
+					continue;
+				}
+				XMIT_PROCESSED_SKBS();
+				unicast_arp_send(skb, dev, phdr);
+			}
 		}
-	}
+	} while (--max_skbs > 0 && (skb = __skb_dequeue(blist)) != NULL);
+
+	/* Send out last packets (if any) */
+	XMIT_PROCESSED_SKBS();
 
-out:
 	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
-	return NETDEV_TX_OK;
+	return (!blist || !skb_queue_len(blist)) ? NETDEV_TX_OK :
+						   NETDEV_TX_BUSY;
 }
 
 static struct net_device_stats *ipoib_get_stats(struct net_device *dev)
@@ -903,11 +962,35 @@ int ipoib_dev_init(struct net_device *de
 
 	/* priv->tx_head & tx_tail are already 0 */
 
-	if (ipoib_ib_dev_init(dev, ca, port))
+	/* Allocate tx_sge */
+	priv->tx_sge = kmalloc(ipoib_sendq_size * sizeof *priv->tx_sge,
+			       GFP_KERNEL);
+	if (!priv->tx_sge) {
+		printk(KERN_WARNING "%s: failed to allocate TX sge (%d entries)\n",
+		       ca->name, ipoib_sendq_size);
 		goto out_tx_ring_cleanup;
+	}
+
+	/* Allocate tx_wr */
+	priv->tx_wr = kmalloc(ipoib_sendq_size * sizeof *priv->tx_wr,
+			      GFP_KERNEL);
+	if (!priv->tx_wr) {
+		printk(KERN_WARNING "%s: failed to allocate TX wr (%d entries)\n",
+		       ca->name, ipoib_sendq_size);
+		goto out_tx_sge_cleanup;
+	}
+
+	if (ipoib_ib_dev_init(dev, ca, port))
+		goto out_tx_wr_cleanup;
 
 	return 0;
 
+out_tx_wr_cleanup:
+	kfree(priv->tx_wr);
+
+out_tx_sge_cleanup:
+	kfree(priv->tx_sge);
+
 out_tx_ring_cleanup:
 	kfree(priv->tx_ring);
 
@@ -935,9 +1018,13 @@ void ipoib_dev_cleanup(struct net_device
 
 	kfree(priv->rx_ring);
 	kfree(priv->tx_ring);
+	kfree(priv->tx_sge);
+	kfree(priv->tx_wr);
 
 	priv->rx_ring = NULL;
 	priv->tx_ring = NULL;
+	priv->tx_sge = NULL;
+	priv->tx_wr = NULL;
 }
 
 static void ipoib_setup(struct net_device *dev)
@@ -968,7 +1055,8 @@ static void ipoib_setup(struct net_devic
 	dev->addr_len 		 = INFINIBAND_ALEN;
 	dev->type 		 = ARPHRD_INFINIBAND;
 	dev->tx_queue_len 	 = ipoib_sendq_size * 2;
-	dev->features            = NETIF_F_VLAN_CHALLENGED | NETIF_F_LLTX;
+	dev->features            = NETIF_F_VLAN_CHALLENGED | NETIF_F_LLTX |
+				   NETIF_F_BATCH_SKBS;
 
 	/* MTU will be reset when mcast join happens */
 	dev->mtu 		 = IPOIB_PACKET_SIZE - IPOIB_ENCAP_LEN;
