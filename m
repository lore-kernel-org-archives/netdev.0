From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 12/12 -Rev2] IPoIB xmit internals changes
	(ipoib_ib.c)
Date: Sun, 22 Jul 2007 14:36:59 +0530
Message-ID: <20070722090659.7787.47401.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_main.c rev2/drivers/infiniband/ulp/ipoib/ipoib_main.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-07-20 07:49:28.000000000 +0530
+++ rev2/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-07-22 00:08:28.000000000 +0530
@@ -558,7 +558,8 @@ static void neigh_add_path(struct sk_buf
 				goto err_drop;
 			}
 		} else
-			ipoib_send(dev, skb, path->ah, IPOIB_QPN(skb->dst->neighbour->ha));
+			ipoib_send(dev, skb, path->ah,
+				   IPOIB_QPN(skb->dst->neighbour->ha), 1);
 	} else {
 		neigh->ah  = NULL;
 
@@ -638,7 +639,7 @@ static void unicast_arp_send(struct sk_b
 		ipoib_dbg(priv, "Send unicast ARP to %04x\n",
 			  be16_to_cpu(path->pathrec.dlid));
 
-		ipoib_send(dev, skb, path->ah, IPOIB_QPN(phdr->hwaddr));
+		ipoib_send(dev, skb, path->ah, IPOIB_QPN(phdr->hwaddr), 1);
 	} else if ((path->query || !path_rec_start(dev, path)) &&
 		   skb_queue_len(&path->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
 		/* put pseudoheader back on for next time */
@@ -704,7 +705,8 @@ static int ipoib_start_xmit(struct sk_bu
 				goto out;
 			}
 
-			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(skb->dst->neighbour->ha));
+			ipoib_send(dev, skb, neigh->ah,
+				   IPOIB_QPN(skb->dst->neighbour->ha), 1);
 			goto out;
 		}
 
@@ -753,6 +755,175 @@ out:
 	return NETDEV_TX_OK;
 }
 
+#define	XMIT_QUEUED_SKBS()						\
+	do {								\
+		if (num_skbs) {						\
+			ipoib_send(dev, NULL, old_neigh->ah, old_qpn,	\
+				   num_skbs);				\
+			num_skbs = 0;					\
+		}							\
+	} while (0)
+
+/*
+ * TODO: Merge with ipoib_start_xmit to use the same code and have a
+ * transparent wrapper caller to xmit's, etc.
+ */
+static int ipoib_start_xmit_frames(struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct sk_buff *skb;
+	struct sk_buff_head *blist;
+	int max_skbs, num_skbs = 0, tx_ring_index = -1;
+	u32 qpn, old_qpn = 0;
+	struct ipoib_neigh *neigh, *old_neigh = NULL;
+	unsigned long flags;
+
+	if (unlikely(!spin_trylock_irqsave(&priv->tx_lock, flags)))
+		return NETDEV_TX_LOCKED;
+
+	blist = &dev->skb_blist;
+
+	/*
+	 * Send atmost 'max_skbs' skbs. This also prevents the device getting
+	 * full.
+	 */
+	max_skbs = ipoib_sendq_size - (priv->tx_head - priv->tx_tail);
+	while (max_skbs-- > 0 && (skb = __skb_dequeue(blist)) != NULL) {
+		/*
+		 * From here on, ipoib_send() cannot stop the queue as it
+		 * uses the same initialization as 'max_skbs'. So we can
+		 * optimize to not check for queue stopped for every skb.
+		 */
+		if (likely(skb->dst && skb->dst->neighbour)) {
+			if (unlikely(!*to_ipoib_neigh(skb->dst->neighbour))) {
+				XMIT_QUEUED_SKBS();
+				ipoib_path_lookup(skb, dev);
+				continue;
+			}
+
+			neigh = *to_ipoib_neigh(skb->dst->neighbour);
+
+			if (ipoib_cm_get(neigh)) {
+				if (ipoib_cm_up(neigh)) {
+					XMIT_QUEUED_SKBS();
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
+					XMIT_QUEUED_SKBS();
+					ipoib_path_lookup(skb, dev);
+					continue;
+				}
+
+				qpn = IPOIB_QPN(skb->dst->neighbour->ha);
+				if (neigh != old_neigh || qpn != old_qpn) {
+					/*
+					 * Sending to a different destination
+					 * from earlier skb's - send all
+					 * existing skbs (if any).
+					 */
+					if (tx_ring_index == -1) {
+						/*
+						 * First time, find where to
+						 * store skb.
+						 */
+						tx_ring_index = priv->tx_head &
+							(ipoib_sendq_size - 1);
+					} else {
+						/* Some skbs to send */
+						XMIT_QUEUED_SKBS();
+					}
+					old_neigh = neigh;
+					old_qpn = IPOIB_QPN(skb->dst->neighbour->ha);
+				}
+
+				if (ipoib_process_skb(dev, skb, priv, num_skbs,
+						      tx_ring_index, neigh->ah,
+						      qpn))
+					continue;
+
+				num_skbs++;
+
+				/* Queue'd one skb, get index for next skb */
+				if (max_skbs)
+					tx_ring_index = (tx_ring_index + 1) &
+							(ipoib_sendq_size - 1);
+				continue;
+			}
+
+			if (skb_queue_len(&neigh->queue) <
+			    IPOIB_MAX_PATH_REC_QUEUE) {
+				spin_lock(&priv->lock);
+				__skb_queue_tail(&neigh->queue, skb);
+				spin_unlock(&priv->lock);
+			} else {
+				dev_kfree_skb_any(skb);
+				++priv->stats.tx_dropped;
+				++max_skbs;
+			}
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
+				XMIT_QUEUED_SKBS();
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
+					++max_skbs;
+					continue;
+				}
+				XMIT_QUEUED_SKBS();
+				unicast_arp_send(skb, dev, phdr);
+			}
+		}
+	}
+
+	/* Send out last packets (if any) */
+	XMIT_QUEUED_SKBS();
+
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
+
+	return skb_queue_empty(blist) ? NETDEV_TX_OK : NETDEV_TX_BUSY;
+}
+
 static struct net_device_stats *ipoib_get_stats(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -898,11 +1069,35 @@ int ipoib_dev_init(struct net_device *de
 
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
 
@@ -930,9 +1125,13 @@ void ipoib_dev_cleanup(struct net_device
 
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
@@ -943,6 +1142,7 @@ static void ipoib_setup(struct net_devic
 	dev->stop 		 = ipoib_stop;
 	dev->change_mtu 	 = ipoib_change_mtu;
 	dev->hard_start_xmit 	 = ipoib_start_xmit;
+	dev->hard_start_xmit_batch = ipoib_start_xmit_frames;
 	dev->get_stats 		 = ipoib_get_stats;
 	dev->tx_timeout 	 = ipoib_timeout;
 	dev->hard_header 	 = ipoib_hard_header;
