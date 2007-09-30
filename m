From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCHES] TX batching
Date: Sun, 30 Sep 2007 15:19:28 -0400
Message-ID: <1191179969.6165.46.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1191178205.6165.25.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Jq4e1OEvNUMs890z7auS"
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191178205.6165.25.camel@localhost>
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


--=-Jq4e1OEvNUMs890z7auS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

And heres a patch that provides a sample of the usage for batching with
tg3. 
Requires patch "[TG3]Some cleanups" i posted earlier. 

cheers,
jamal


--=-Jq4e1OEvNUMs890z7auS
Content-Disposition: attachment; filename=tg3.potoc
Content-Type: text/x-patch; name=tg3.potoc; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5a864bd..9aafb78 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3103,6 +3103,13 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
 		((tp->tx_prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
 }
 
+static inline void tg3_set_win(struct tg3 *tp)
+{
+	tp->dev->xmit_win = tg3_tx_avail(tp) - (MAX_SKB_FRAGS + 1);
+	if (tp->dev->xmit_win < 1)
+		tp->dev->xmit_win = 1;
+}
+
 /* Tigon3 never reports partial packet sends.  So we do not
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
@@ -3165,8 +3172,10 @@ static void tg3_tx(struct tg3 *tp)
 		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
 		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
-		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
+		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))) {
+			tg3_set_win(tp);
 			netif_wake_queue(tp->dev);
+		}
 		netif_tx_unlock(tp->dev);
 	}
 }
@@ -4007,8 +4016,13 @@ void tg3_kick_DMA(struct net_device *dev)
 
 	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) >= TG3_TX_WAKEUP_THRESH(tp))
+		dev->xmit_win = 1;
+		if (tg3_tx_avail(tp) >= TG3_TX_WAKEUP_THRESH(tp)) {
+			tg3_set_win(tp);
 			netif_wake_queue(dev);
+		}
+	} else {
+		tg3_set_win(tp);
 	}
 
 	mmiowb();
@@ -4085,6 +4099,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
+			tp->dev->xmit_win = 1;
 
 			/* This is a hard error, log it. */
 			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
@@ -4100,6 +4115,25 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+static int tg3_start_bxmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			dev->xmit_win = 1;
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
+	}
+
+	return tg3_enqueue(skb, dev);
+}
+
 static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
@@ -4112,9 +4146,11 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 	/* Estimate the number of fragments in the worst case */
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
 		netif_stop_queue(tp->dev);
+		tp->dev->xmit_win = 1;
 		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
 			return NETDEV_TX_BUSY;
 
+		tg3_set_win(tp);
 		netif_wake_queue(tp->dev);
 	}
 
@@ -4267,6 +4303,25 @@ static int tg3_enqueue_buggy(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int tg3_start_bxmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			dev->xmit_win = 1;
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
+	}
+
+	return  tg3_enqueue_buggy(skb, dev);
+}
+
 static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -4283,6 +4338,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
+			dev->xmit_win = 1;
 
 			/* This is a hard error, log it. */
 			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
@@ -11099,15 +11155,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
+	tp->dev->hard_end_xmit = tg3_kick_DMA;
 	/* All chips before 5787 can get confused if TX buffers
 	 * straddle the 4GB address boundary in some cases.
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-		tp->dev->hard_start_xmit = tg3_start_xmit;
-	else
-		tp->dev->hard_start_xmit = tg3_start_xmit_dma_bug;
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		tp->dev->hard_start_xmit = tg3_start_bxmit;
+		tp->dev->hard_prep_xmit = tg3_prep_frame;
+	} else {
+		tp->dev->hard_start_xmit = tg3_start_bxmit_dma_bug;
+		tp->dev->hard_prep_xmit = tg3_prep_bug_frame;
+	}
 
 	tp->rx_offset = 2;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
@@ -11955,6 +12015,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
+	dev->features |= NETIF_F_BTX;
+	dev->xmit_win = tp->tx_pending >> 2;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = tg3_poll_controller;
 #endif

--=-Jq4e1OEvNUMs890z7auS
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-Jq4e1OEvNUMs890z7auS--
