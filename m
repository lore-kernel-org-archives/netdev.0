From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 09/10] IPoIB batching xmit handler support.
Date: Fri, 20 Jul 2007 12:03:36 +0530
Message-ID: <20070720063336.26341.2955.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, hadi@cyberus.ca,
	netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	xma@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:52606 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbXGTGeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 02:34:12 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6K6Ydc53158262
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:34:40 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6K6bAR3086346
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:37:17 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6K6XDbT003099
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 16:33:34 +1000
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a IPoIB batching xmit handler.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_main.c |  215 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 210 insertions(+), 5 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_main.c new/drivers/infiniband/ulp/ipoib/ipoib_main.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-07-20 07:49:28.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-07-20 08:30:22.000000000 +0530
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
 
@@ -753,6 +755,177 @@ out:
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
+	blist = dev->skb_blist;
+
+	/*
+	 * Send atmost xmit_slots skbs. This also prevents the device getting
+	 * full as ipoib_send modifies the xmit_slots and we use the same
+	 * value to figure how many skbs to send.
+	 */
+	max_skbs = dev->xmit_slots;
+
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
@@ -898,11 +1071,35 @@ int ipoib_dev_init(struct net_device *de
 
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
 
@@ -930,9 +1127,13 @@ void ipoib_dev_cleanup(struct net_device
 
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
@@ -943,6 +1144,7 @@ static void ipoib_setup(struct net_devic
 	dev->stop 		 = ipoib_stop;
 	dev->change_mtu 	 = ipoib_change_mtu;
 	dev->hard_start_xmit 	 = ipoib_start_xmit;
+	dev->hard_start_xmit_batch = ipoib_start_xmit_frames;
 	dev->get_stats 		 = ipoib_get_stats;
 	dev->tx_timeout 	 = ipoib_timeout;
 	dev->hard_header 	 = ipoib_hard_header;
@@ -963,7 +1165,10 @@ static void ipoib_setup(struct net_devic
 	dev->addr_len 		 = INFINIBAND_ALEN;
 	dev->type 		 = ARPHRD_INFINIBAND;
 	dev->tx_queue_len 	 = ipoib_sendq_size * 2;
-	dev->features            = NETIF_F_VLAN_CHALLENGED | NETIF_F_LLTX;
+	dev->features            = NETIF_F_VLAN_CHALLENGED | NETIF_F_LLTX |
+					NETIF_F_BATCH_SKBS;
+
+	dev->xmit_slots		= ipoib_sendq_size;
 
 	/* MTU will be reset when mcast join happens */
 	dev->mtu 		 = IPOIB_PACKET_SIZE - IPOIB_ENCAP_LEN;
