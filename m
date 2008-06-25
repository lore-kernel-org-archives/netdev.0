From: David Miller <davem@davemloft.net>
Subject: [net-tx-2.6 PATCH]: Push TX lock down into drivers
Date: Wed, 25 Jun 2008 01:33:55 -0700 (PDT)
Message-ID: <20080625.013355.229057310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbYFYId6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 04:33:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 81312C8C1B6
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 01:33:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is the patch I've been crunching on the past few days.

The idea is that, for all non-LLTX drivers, we move the locking
down into the driver so that we can get rid of the generic
netdev TX lock entirely.  This will facilitate per-TX-queue
locking in the drivers, or even more sophisticated lockless
schemes.

The transformation is pretty straightforward:

1) Add tx_lock to driver private struct.

2) Initialize tx_lock when device private is allocated.

3) Grab tx_lock around entirety of ->hard_start_xmit() method.
   The most non-error-prone method to do this is:

	a) Rename x_start_xmit --> __x_start_xmit
	b) Add new x_start_xmit which does:

		struct x_priv *p = netdev_priv(dev);
		int ret;

		spin_lock(&p->tx_lock);
		ret = __x_start_xmit(skb, dev);
		spin_unlock(&p->tx_lock);

		return ret;

It can be proven that this transformation will allow existing
locking semantics to be maintained when netdev->_xmit_lock
is removed.

Of course we have extra locking now in these drivers, but this is an
intermediate step and in the end we'll have the same amount or less
locking than we have now.  And what's more, we'll have tons of
flexibility which currently is not available.

This is a whopper at over 300K, so I'll likely commit this in groups
of drivers.  I really just wanted to have something for people to look
at after putting so much time into the diff.

As mentioned, none of the LLTX drivers were touched.  When we
delete the ->_xmit_lock, the default semantics will be what they
want.  And we therefore will be able to get rid of the LLTX flag
and all of that stuff.

Of the rest of the drivers, here are the ones I did not modify in
this patch and why:

--------------------
drivers/infiniband/hw/amso1100:
drivers/isdn/hysdn:
drivers/net/8139cp.c:
drivers/net/amd8111e.c:
drivers/net/b44.c:
drivers/net/cassini.c:
drivers/net/eepro100.c:
drivers/net/eexpress.c:
drivers/net/eql.c:
drivers/net/fealnx.c:
drivers/net/fec.c:
drivers/net/fec_8xx/fec_main.c:
drivers/net/fs_enet/fs_enet-main.c:
drivers/net/hamradio/6pack.c:
drivers/net/ioc3-eth.c:
drivers/net/korina.c:
drivers/net/lance.c:
drivers/net/macb.c:
drivers/net/meth.c:
drivers/net/mv643xx_eth.c:
drivers/net/netx-eth.c:
drivers/net/pcmcia/3c574_cs.c:
drivers/net/pcmcia/3c589_cs.c:
drivers/net/pcnet32.c:
drivers/net/ps3_gelic_net.c:
drivers/net/ps3_gelic_wireless.c:
drivers/net/rrunner.c:
drivers/net/sb1250-mac.c:
drivers/net/sc92031.c:
drivers/net/sis900.c:
drivers/net/sunbmac.c:
drivers/net/sunhme.c:
drivers/net/sunlance.c:
drivers/net/sunqe.c:
drivers/net/sunvnet.c:
drivers/net/tc35815.c:
drivers/net/tokenring/3c359.c:
drivers/net/tokenring/lanstreamer.c:
drivers/net/tokenring/olympic.c:
drivers/net/tulip/de2104x.c:
drivers/net/tulip/tulip_core.c:
drivers/net/tulip/xircom_cb.c:
drivers/net/ucc_geth.c:
drivers/net/usb/kaweth.c:
drivers/net/via-velocity.c:
drivers/net/wan/lmc/lmc_main.c:
drivers/net/wireless/ipw2100.c:
drivers/net/wireless/ipw2200.c:
drivers/net/wireless/prism54/islpci_dev.c:
drivers/net/wireless/wl3501_cs.c:
drivers/net/xen-netfront.c:

	Holds own ->tx_lock with IRQs disabled over entire
	xmit handler.  Could safely enable LLTX.

drivers/media/dvb/dvb-core/dvb_net.c:
drivers/net/sb1000.c:
drivers/net/wireless/mac80211_hwsim.c:

	Has NOP TX handler, just does dev_kfree_skb(skb)

net/atm/mpc.c:

	Terminally broken, both before and after the TX lock goes
	away.  MPC lists et al. have absolutely no locking
	whatsoever.
--------------------

I have this "git grep -e "->hard_start_xmit" output that I audit
over to make sure I hit every driver necessary.  I used that to
work on this patch and to form the above list.

Patch is against net-tx-2.6, and at least survives allmodconfig on
sparc64 and x86 for me.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 3d47839..d1ac327 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -41,6 +41,7 @@
 #define NETWORK_INTR			8
 
 struct simeth_local {
+	spinlock_t		tx_lock;
 	struct net_device_stats stats;
 	int 			simfd;	 /* descriptor in the simulator */
 };
@@ -209,6 +210,8 @@ simeth_probe1(void)
 	local = dev->priv;
 	local->simfd = fd; /* keep track of underlying file descriptor */
 
+	spin_lock_init(&local->tx_lock);
+
 	dev->open		= simeth_open;
 	dev->stop		= simeth_close;
 	dev->hard_start_xmit	= simeth_tx;
@@ -378,7 +381,7 @@ frame_print(unsigned char *from, unsigned char *frame, int len)
  * going to the simulator.
  */
 static int
-simeth_tx(struct sk_buff *skb, struct net_device *dev)
+__simeth_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct simeth_local *local = dev->priv;
 
@@ -410,6 +413,18 @@ simeth_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int
+simeth_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct simeth_local *local = dev->priv;
+
+	spin_lock(&local->tx_lock);
+	ret = __simeth_tx(skb, dev);
+	spin_unlock(&local->tx_lock);
+
+	return ret;
+}
+
 static inline struct sk_buff *
 make_new_skb(struct net_device *dev)
 {
diff --git a/arch/ppc/8260_io/enet.c b/arch/ppc/8260_io/enet.c
index ec1defe..64ffa48 100644
--- a/arch/ppc/8260_io/enet.c
+++ b/arch/ppc/8260_io/enet.c
@@ -116,6 +116,7 @@ struct scc_enet_private {
 	struct	net_device_stats stats;
 	uint	tx_full;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 static int scc_enet_open(struct net_device *dev);
@@ -163,8 +164,7 @@ scc_enet_open(struct net_device *dev)
 	return 0;					/* Always succeed */
 }
 
-static int
-scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct scc_enet_private *cep = (struct scc_enet_private *)dev->priv;
 	volatile cbd_t	*bdp;
@@ -234,6 +234,18 @@ scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct scc_enet_private *cep = (struct scc_enet_private *)dev->priv;
+	int ret;
+
+	spin_lock(&cap->tx_lock);
+	ret = __scc_enet_start_xmit(skb, dev);
+	spin_unlock(&cap->tx_lock);
+
+	return ret;
+}
+
 static void
 scc_enet_timeout(struct net_device *dev)
 {
@@ -637,6 +649,7 @@ static int __init scc_enet_init(void)
 
 	cep = dev->priv;
 	spin_lock_init(&cep->lock);
+	spin_lock_init(&cep->tx_lock);
 
 	/* Get pointer to SCC area in parameter RAM.
 	*/
diff --git a/arch/ppc/8260_io/fcc_enet.c b/arch/ppc/8260_io/fcc_enet.c
index d38b57e..97addf7 100644
--- a/arch/ppc/8260_io/fcc_enet.c
+++ b/arch/ppc/8260_io/fcc_enet.c
@@ -365,6 +365,7 @@ struct fcc_enet_private {
 	struct	net_device_stats stats;
 	uint	tx_free;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 #ifdef	CONFIG_USE_MDIO
 	uint	phy_id;
@@ -409,8 +410,7 @@ static void	mii_do_cmd(struct net_device *dev, const phy_cmd_t *c);
 #endif	/* CONFIG_USE_MDIO */
 
 
-static int
-fcc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __fcc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fcc_enet_private *cep = (struct fcc_enet_private *)dev->priv;
 	volatile cbd_t	*bdp;
@@ -476,6 +476,17 @@ fcc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int fcc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fcc_enet_private *cep = (struct fcc_enet_private *)dev->priv;
+	int ret;
+
+	spin_lock(&cep->tx_lock);
+	ret = __fcc_enet_start_xmit(skb, dev);
+	spin_unlock(&cep->tx_lock);
+
+	return ret;
+}
 
 static void
 fcc_enet_timeout(struct net_device *dev)
@@ -1709,6 +1720,7 @@ static int __init fec_enet_init(void)
 
 		cep = dev->priv;
 		spin_lock_init(&cep->lock);
+		spin_lock_init(&cep->tx_lock);
 		cep->fip = fip;
 
 		init_fcc_shutdown(fip, cep, immap);
diff --git a/arch/ppc/8xx_io/enet.c b/arch/ppc/8xx_io/enet.c
index 5899aea..f0723da 100644
--- a/arch/ppc/8xx_io/enet.c
+++ b/arch/ppc/8xx_io/enet.c
@@ -144,6 +144,7 @@ struct scc_enet_private {
 	struct	net_device_stats stats;
 	uint	tx_full;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 static int scc_enet_open(struct net_device *dev);
@@ -193,8 +194,7 @@ scc_enet_open(struct net_device *dev)
 	return 0;					/* Always succeed */
 }
 
-static int
-scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct scc_enet_private *cep = (struct scc_enet_private *)dev->priv;
 	volatile cbd_t	*bdp;
@@ -269,6 +269,18 @@ scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int scc_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct scc_enet_private *cep = (struct scc_enet_private *)dev->priv;
+	int ret;
+
+	spin_lock(&cep->tx_lock);
+	ret = __scc_enet_start_xmit(skb, dev);
+	spin_unlock(&cep->tx_lock);
+
+	return ret;
+}
+
 static void
 scc_enet_timeout(struct net_device *dev)
 {
@@ -665,6 +677,7 @@ static int __init scc_enet_init(void)
 
 	cep = dev->priv;
 	spin_lock_init(&cep->lock);
+	spin_lock_init(&cep->tx_lock);
 
 	/* Get pointer to SCC area in parameter RAM.
 	*/
diff --git a/arch/ppc/8xx_io/fec.c b/arch/ppc/8xx_io/fec.c
index 2c604d4..fbc5a2a 100644
--- a/arch/ppc/8xx_io/fec.c
+++ b/arch/ppc/8xx_io/fec.c
@@ -165,6 +165,7 @@ struct fec_enet_private {
 	struct	net_device_stats stats;
 	uint	tx_full;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 #ifdef	CONFIG_USE_MDIO
 	uint	phy_id;
@@ -338,8 +339,7 @@ EXPORT_SYMBOL(fec_unregister_ph);
 
 #endif /* CONFIG_FEC_PACKETHOOK */
 
-static int
-fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fec_enet_private *fep;
 	volatile fec_t	*fecp;
@@ -423,6 +423,18 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fec_enet_private *fep = dev->priv;
+	int ret;
+
+	spin_lock(&fep->tx_lock);
+	ret = __fec_enet_start_xmit(skb, dev);
+	spin_unlock(&fep->tx_lock);
+
+	return ret;
+}
+
 static void
 fec_timeout(struct net_device *dev)
 {
@@ -1601,6 +1613,9 @@ static int __init fec_enet_init(void)
 
 	fep = dev->priv;
 
+	spin_lock_init(&fep->lock);
+	spin_lock_init(&fep->tx_lock);
+
 	fecp = &(immap->im_cpm.cp_fec);
 
 	/* Whack a reset.  We should wait for this.
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 5b4ca8d..fe67e7b 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -211,7 +211,7 @@ static int uml_net_close(struct net_device *dev)
 	return 0;
 }
 
-static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct uml_net_private *lp = dev->priv;
 	unsigned long flags;
@@ -248,6 +248,18 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct uml_net_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __uml_net_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *uml_net_get_stats(struct net_device *dev)
 {
 	struct uml_net_private *lp = dev->priv;
@@ -469,6 +481,7 @@ static void eth_configure(int n, void *init, char *mac,
 
 	init_timer(&lp->tl);
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	lp->tl.function = uml_net_user_timer_expire;
 	memcpy(lp->mac, device->mac, sizeof(lp->mac));
 
diff --git a/arch/um/include/net_kern.h b/arch/um/include/net_kern.h
index d843c79..67bd4ef 100644
--- a/arch/um/include/net_kern.h
+++ b/arch/um/include/net_kern.h
@@ -24,6 +24,7 @@ struct uml_net {
 struct uml_net_private {
 	struct list_head list;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	struct net_device *dev;
 	struct timer_list tl;
 	struct net_device_stats stats;
diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index a2e2522..8af4819 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -72,6 +72,7 @@ struct iss_net_private {
 	struct list_head opened_list;
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	struct net_device *dev;
 	struct platform_device pdev;
 	struct timer_list tl;
@@ -513,7 +514,7 @@ printk("iss_net_close!\n");
 	return 0;
 }
 
-static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct iss_net_private *lp = dev->priv;
 	unsigned long flags;
@@ -548,6 +549,17 @@ static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct iss_net_private *lp = dev->priv;
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __iss_net_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 static struct net_device_stats *iss_net_get_stats(struct net_device *dev)
 {
@@ -640,7 +652,6 @@ static int iss_net_configure(int index, char *init)
 	*lp = ((struct iss_net_private) {
 		.device_list		= LIST_HEAD_INIT(lp->device_list),
 		.opened_list		= LIST_HEAD_INIT(lp->opened_list),
-		.lock			= SPIN_LOCK_UNLOCKED,
 		.dev			= dev,
 		.index			= index,
 		//.fd                   = -1,
@@ -648,6 +659,8 @@ static int iss_net_configure(int index, char *init)
 		.have_mac		= 0,
 		});
 
+	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	/*
 	 * Try all transport protocols.
 	 * Note: more protocols can be added by adding '&& !X_init(lp, eth)'.
diff --git a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
index b166b35..a7310e7 100644
--- a/drivers/ieee1394/eth1394.c
+++ b/drivers/ieee1394/eth1394.c
@@ -609,6 +609,7 @@ static void ether1394_add_host(struct hpsb_host *host)
 	priv = netdev_priv(dev);
 	INIT_LIST_HEAD(&priv->ip_node_list);
 	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->tx_lock);
 	priv->host = host;
 	priv->local_fifo = fifo_addr;
 	INIT_WORK(&priv->wake, ether1394_wake_queue);
@@ -1560,7 +1561,7 @@ static void ether1394_complete_cb(void *__ptask)
 }
 
 /* Transmit a packet (called by kernel) */
-static int ether1394_tx(struct sk_buff *skb, struct net_device *dev)
+static int __ether1394_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct eth1394hdr hdr_buf;
 	struct eth1394_priv *priv = netdev_priv(dev);
@@ -1711,6 +1712,18 @@ fail:
 	return NETDEV_TX_OK;
 }
 
+static int ether1394_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct eth1394_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __ether1394_tx(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void ether1394_get_drvinfo(struct net_device *dev,
 				  struct ethtool_drvinfo *info)
 {
diff --git a/drivers/ieee1394/eth1394.h b/drivers/ieee1394/eth1394.h
index 4f3e2dd..4699741 100644
--- a/drivers/ieee1394/eth1394.h
+++ b/drivers/ieee1394/eth1394.h
@@ -60,6 +60,7 @@ struct eth1394_priv {
 	u8 bc_sspd;			/* Max broadcast speed		 */
 	u64 local_fifo;			/* Local FIFO Address		 */
 	spinlock_t lock;		/* Private lock			 */
+	spinlock_t tx_lock;
 	int broadcast_channel;		/* Async stream Broadcast Channel */
 	enum eth1394_bc_states bc_state; /* broadcast channel state	 */
 	struct hpsb_iso *iso;		/* Async stream recv handle	 */
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index ef1a300..5f57c71 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1164,8 +1164,8 @@ static void isdn_net_tx_timeout(struct net_device * ndev)
  * If this interface isn't connected to a ISDN-Channel, find a free channel,
  * and start dialing.
  */
-static int
-isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __isdn_net_start_xmit(struct sk_buff *skb,
+				 struct net_device *ndev)
 {
 	isdn_net_local *lp = (isdn_net_local *) ndev->priv;
 #ifdef CONFIG_ISDN_X25
@@ -1307,6 +1307,18 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return 1;
 }
 
+static int isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	isdn_net_local *lp = (isdn_net_local *) ndev->priv;
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __isdn_net_start_xmit(skb, ndev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  * Shutdown a net-interface.
  */
@@ -2608,6 +2620,7 @@ isdn_net_new(char *name, struct net_device *master)
 
 	INIT_WORK(&netdev->local->tqueue, isdn_net_softint);
 	spin_lock_init(&netdev->local->xmit_lock);
+	spin_lock_init(&netdev->local->tx_lock);
 
 	/* Put into to netdev-chain */
 	netdev->next = (void *) dev->netdev;
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index 7950fc6..41e16ce 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -99,6 +99,7 @@ struct mpt_lan_priv {
 	int *mpt_txfidx; /* Free Tx Context list */
 	int mpt_txfidx_tail;
 	spinlock_t txfidx_lock;
+	spinlock_t tx_lock;
 
 	int *mpt_rxfidx; /* Free Rx Context list */
 	int mpt_rxfidx_tail;
@@ -699,8 +700,7 @@ out:
 }
 
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
-static int
-mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
+static int __mpt_lan_sdu_send(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mpt_lan_priv *priv = netdev_priv(dev);
 	MPT_ADAPTER *mpt_dev = priv->mpt_dev;
@@ -843,6 +843,18 @@ mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int mpt_lan_sdu_send(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mpt_lan_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __mpt_lan_sdu_send(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
 static void
 mpt_lan_wake_post_buckets_task(struct net_device *dev, int priority)
@@ -1385,6 +1397,7 @@ mpt_register_lan_device (MPT_ADAPTER *mpt_dev, int pnum)
 
 	priv->bucketthresh = priv->max_buckets_out * 2 / 3;
 	spin_lock_init(&priv->txfidx_lock);
+	spin_lock_init(&priv->tx_lock);
 	spin_lock_init(&priv->rxfidx_lock);
 
 	/*  Grab pre-fetched LANPage1 stuff. :-) */
diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 822dc8e..c2a6b2b 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -112,6 +112,7 @@ struct xpnet_pending_msg {
 
 /* driver specific structure pointed to by the device structure */
 struct xpnet_dev_private {
+	spinlock_t tx_lock;
 	struct net_device_stats stats;
 };
 
@@ -436,7 +437,7 @@ xpnet_send_completed(enum xp_retval reason, short partid, int channel,
  * is 0xff, this packet is to broadcast to all partitions.
  */
 static int
-xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+__xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xpnet_pending_msg *queued_msg;
 	enum xp_retval ret;
@@ -577,6 +578,19 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int
+xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct xpnet_dev_private *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __xpnet_dev_hard_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /*
  * Deal with transmit timeouts coming from the network layer.
  */
@@ -594,6 +608,7 @@ xpnet_dev_tx_timeout(struct net_device *dev)
 static int __init
 xpnet_init(void)
 {
+	struct xpnet_dev_private *priv;
 	int i;
 	u32 license_num;
 	int result = -ENOMEM;
@@ -614,6 +629,9 @@ xpnet_init(void)
 
 	netif_carrier_off(xpnet_device);
 
+	priv = netdev_priv(dev);
+	spin_lock_init(&priv->tx_lock);
+
 	xpnet_device->mtu = XPNET_DEF_MTU;
 	xpnet_device->change_mtu = xpnet_dev_change_mtu;
 	xpnet_device->open = xpnet_dev_open;
diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 5ba4bab..db51de6 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -300,6 +300,7 @@ static int __init el1_probe1(struct net_device *dev, int ioaddr)
 	memset(dev->priv, 0, sizeof(struct net_local));
 	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/*
 	 *	The EL1-specific entries in the device structure.
@@ -402,7 +403,7 @@ static void el_timeout(struct net_device *dev)
  * no real choice.
  */
 
-static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -488,6 +489,18 @@ static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	} while (1);
 }
 
+static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __el_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /**
  * el_interrupt:
  * @irq: Interrupt number
diff --git a/drivers/net/3c501.h b/drivers/net/3c501.h
index cfec64e..d2e5bae 100644
--- a/drivers/net/3c501.h
+++ b/drivers/net/3c501.h
@@ -33,6 +33,7 @@ struct net_local
 	int		loading;	/* Spot buffer load collisions */
 	int		txing;		/* True if card is in TX mode */
 	spinlock_t	lock;		/* Serializing lock */
+	spinlock_t	tx_lock;
 };
 
 
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index fdfb2b2..2594111 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -875,6 +875,7 @@ static int elp_open(struct net_device *dev)
 	adapter->rx_backlog.out = 0;
 
 	spin_lock_init(&adapter->lock);
+	spin_lock_init(&adapter->tx_lock);
 
 	/*
 	 * install our interrupt service routine
@@ -1059,7 +1060,7 @@ static void elp_timeout(struct net_device *dev)
  *
  ******************************************************/
 
-static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	elp_device *adapter = dev->priv;
@@ -1096,6 +1097,18 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	elp_device *adapter = dev->priv;
+	int ret;
+
+	spin_lock(&adapter->tx_lock);
+	ret = __elp_start_xmit(skb, dev);
+	spin_unlock(&adapter->tx_lock);
+
+	return ret;
+}
+
 /******************************************************
  *
  * return statistics on the board
diff --git a/drivers/net/3c505.h b/drivers/net/3c505.h
index 04df2a9..f2e36f2 100644
--- a/drivers/net/3c505.h
+++ b/drivers/net/3c505.h
@@ -289,4 +289,5 @@ typedef struct {
 	unsigned int rx_active;  /* number of receive PCBs */
         volatile unsigned char hcr_val;  /* what we think the HCR contains */
         spinlock_t lock;	/* Interrupt v tx lock */
+        spinlock_t tx_lock;
 } elp_device;
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index 030c147..fa8feff 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -126,6 +126,7 @@ struct net_local {
 	ushort tx_reap;
 	ushort tx_pkts_in_ring;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	void __iomem *base;
 };
 
@@ -443,6 +444,7 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 	lp = netdev_priv(dev);
  	memset(lp, 0, sizeof(*lp));
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	lp->base = ioremap(dev->mem_start, RX_BUF_END);
 	if (!lp->base) {
 		printk(KERN_ERR "3c507: unable to remap memory\n");
@@ -505,7 +507,7 @@ static void el16_tx_timeout (struct net_device *dev)
 }
 
 
-static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
+static int __el16_send_packet (struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -536,6 +538,18 @@ static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __el16_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*	The typical workload of the driver:
 	Handle the network interface interrupts. */
 static irqreturn_t el16_interrupt(int irq, void *dev_id)
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index b9d097c..5cbcdb9 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -168,6 +168,7 @@ enum el3_cardtype { EL3_ISA, EL3_PNP, EL3_MCA, EL3_EISA };
 
 struct el3_private {
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	/* skb send-queue */
 	int head, size;
 	struct sk_buff *queue[SKB_QUEUE_SIZE];
@@ -545,6 +546,7 @@ static int __init el3_common_init(struct net_device *dev)
 	const char *if_names[] = {"10baseT", "AUI", "undefined", "BNC"};
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	if (dev->mem_start & 0x05) { /* xcvr codes 1/3/4/12 */
 		dev->if_port = (dev->mem_start & 0x0f);
@@ -809,7 +811,7 @@ el3_tx_timeout (struct net_device *dev)
 
 
 static int
-el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+__el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -887,6 +889,18 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct el3_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __el3_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* The EL3 interrupt handler. */
 static irqreturn_t
 el3_interrupt(int irq, void *dev_id)
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index e4e3241..2af8555 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -322,6 +322,7 @@ struct corkscrew_private {
 		full_bus_master_tx:1, full_bus_master_rx:1,	/* Boomerang  */
 		tx_full:1;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	struct device *dev;
 };
 
@@ -615,6 +616,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	printk(KERN_INFO "%s: 3Com %s at %#3x,", dev->name, vp->product_name, ioaddr);
 
 	spin_lock_init(&vp->lock);
+	spin_lock_init(&vp->tx_lock);
 
 	/* Read the station address from the EEPROM. */
 	EL3WINDOW(0);
@@ -991,8 +993,8 @@ static void corkscrew_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int corkscrew_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+static int __corkscrew_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -1115,6 +1117,19 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 	return 0;
 }
 
+static int corkscrew_start_xmit(struct sk_buff *skb,
+				struct net_device *dev)
+{
+	struct corkscrew_private *vp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&vp->tx_lock);
+	ret = __corkscrew_start_xmit(skb, dev);
+	spin_unlock(&vp->tx_lock);
+
+	return ret;
+}
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index dc6e474..9c5d2ab 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -202,6 +202,7 @@ static void elmc_xmt_int(struct net_device *dev);
 static void elmc_rnr_int(struct net_device *dev);
 
 struct priv {
+	spinlock_t tx_lock;
 	unsigned long base;
 	char *memtop;
 	unsigned long mapped_start;		/* Start of ioremap */
@@ -493,6 +494,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	}
 
 	memset(pr, 0, sizeof(struct priv));
+	spin_lock_init(&pr->tx_lock);
 	pr->slot = slot;
 
 	printk(KERN_INFO "%s: 3Com 3c523 Rev 0x%x at %#lx\n", dev->name, (int) revision,
@@ -1124,7 +1126,7 @@ static void elmc_timeout(struct net_device *dev)
  * send frame
  */
 
-static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int len;
 	int i;
@@ -1196,6 +1198,18 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct priv *p = (struct priv *) dev->priv;
+	int ret;
+
+	spin_lock(&p->tx_lock);
+	ret = __elmc_send_packet(skb, dev);
+	spin_unlock(&p->tx_lock);
+
+	return ret;
+}
+
 /*******************************************
  * Someone wanna have the statistics
  */
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 6aca0c6..d887c7f 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -155,6 +155,7 @@ struct mc32_ring_desc
 /* Information that needs to be kept for each board. */
 struct mc32_local
 {
+	spinlock_t tx_lock;
 	int slot;
 
 	u32 base;
@@ -441,6 +442,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	}
 
 	memset(lp, 0, sizeof(struct mc32_local));
+	spin_lock_init(&lp->tx_lock);
 	lp->slot = slot;
 
 	i=0;
@@ -1016,7 +1018,7 @@ static void mc32_timeout(struct net_device *dev)
  *
  */
 
-static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mc32_local *lp = netdev_priv(dev);
 	u32 head = atomic_read(&lp->tx_ring_head);
@@ -1065,6 +1067,17 @@ static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mc32_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __mc32_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 /**
  *	mc32_update_stats	-	pull off the on board statistics
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 2edda8c..6326c06 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -601,6 +601,7 @@ struct vortex_private {
 	unsigned int cur_rx, cur_tx;		/* The next free ring entry */
 	unsigned int dirty_rx, dirty_tx;	/* The ring entries to be free()ed. */
 	struct vortex_extra_stats xstats;	/* NIC-specific extra stats */
+	spinlock_t tx_lock;
 	struct sk_buff *tx_skb;				/* Packet being eaten by bus master ctrl.  */
 	dma_addr_t tx_skb_dma;				/* Allocated DMA address for bus master ctrl DMA.   */
 
@@ -1118,6 +1119,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	}
 
 	spin_lock_init(&vp->lock);
+	spin_lock_init(&vp->tx_lock);
 	vp->gendev = gendev;
 	vp->mii.dev = dev;
 	vp->mii.mdio_read = mdio_read;
@@ -2009,7 +2011,7 @@ vortex_error(struct net_device *dev, int status)
 }
 
 static int
-vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
+__vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
@@ -2064,7 +2066,20 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static int
-boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
+vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&vp->tx_lock);
+	ret = __vortex_start_xmit(skb, dev);
+	spin_unlock(&vp->tx_lock);
+
+	return ret;
+}
+
+static int
+__boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
@@ -2153,6 +2168,19 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int
+boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&vp->tx_lock);
+	ret = __boomerang_start_xmit(skb, dev);
+	spin_unlock(&vp->tx_lock);
+
+	return ret;
+}
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index ad6b8a5..d09e9ae 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -502,6 +502,7 @@ int lance_open (struct net_device *dev)
 
         res = lance_reset(dev);
 	spin_lock_init(&lp->devlock);
+	spin_lock_init(&lp->tx_lock);
 	netif_start_queue (dev);
 
 	return res;
@@ -533,7 +534,7 @@ void lance_tx_timeout(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(lance_tx_timeout);
 
-int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static int __lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
         struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
@@ -588,6 +589,18 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
         return 0;
 }
+
+int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+        struct lance_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lance_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 EXPORT_SYMBOL_GPL(lance_start_xmit);
 
 /* taken from the depca driver via a2065.c */
diff --git a/drivers/net/7990.h b/drivers/net/7990.h
index 0a5837b..0a41118 100644
--- a/drivers/net/7990.h
+++ b/drivers/net/7990.h
@@ -125,6 +125,7 @@ struct lance_private
         void (*writerdp)(void *, unsigned short);
         unsigned short (*readrdp)(void *);
 	spinlock_t devlock;
+	spinlock_t tx_lock;
 	char tx_full;
 };
 
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index b23a00c..88d6ac8 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -597,6 +597,7 @@ struct rtl8139_private {
 
 	spinlock_t		lock;
 	spinlock_t		rx_lock;
+	spinlock_t		tx_lock;
 
 	chip_t			chipset;
 	u32			rx_config;
@@ -1002,6 +1003,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 		(debug < 0 ? RTL8139_DEF_MSG_ENABLE : ((1 << debug) - 1));
 	spin_lock_init (&tp->lock);
 	spin_lock_init (&tp->rx_lock);
+	spin_lock_init (&tp->tx_lock);
 	INIT_DELAYED_WORK(&tp->thread, rtl8139_thread);
 	tp->mii.dev = dev;
 	tp->mii.mdio_read = mdio_read;
@@ -1691,7 +1693,7 @@ static void rtl8139_tx_timeout (struct net_device *dev)
 	}
 }
 
-static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static int __rtl8139_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1734,6 +1736,17 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rtl8139_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rtl8139_private *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __rtl8139_start_xmit(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
 
 static void rtl8139_tx_interrupt (struct net_device *dev,
 				  struct rtl8139_private *tp,
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index da292e6..3935932 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -332,6 +332,7 @@ struct i596_private {
 	struct i596_tbd tbds[TX_RING_SIZE];
 	int next_tx_cmd;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 static char init_setup[] =
@@ -1056,7 +1057,7 @@ static void i596_tx_timeout (struct net_device *dev)
 }
 
 
-static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct i596_private *lp = dev->priv;
 	struct tx_cmd *tx_cmd;
@@ -1114,6 +1115,18 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct i596_private *lp = dev->priv;
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __i596_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void print_eth(unsigned char *add, char *str)
 {
 	DECLARE_MAC_BUF(mac);
@@ -1262,6 +1275,7 @@ found:
 	lp->scb.cmd = I596_NULL;
 	lp->scb.rfd = I596_NULL;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	err = register_netdev(dev);
 	if (err)
diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index cf020d4..a42843c 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -71,6 +71,7 @@ struct ei_device {
 	unsigned char saved_irq;	/* Original dev->irq value. */
 	u32 *reg_offset;		/* Register mapping table */
 	spinlock_t page_lock;		/* Page register locks */
+	spinlock_t tx_lock;
 	unsigned long priv;		/* Private field to store bus IDs etc. */
 #ifdef AX88796_PLATFORM
 	unsigned char rxcr_base;	/* default value for RXCR */
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index 9c08374..df0d6ec 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -113,6 +113,7 @@ struct lance_private {
 	volatile struct lance_init_block *init_block;	    /* Hosts view */
 	volatile struct lance_init_block *lance_init_block; /* Lance view */
 
+	spinlock_t tx_lock;
 	int rx_new, tx_new;
 	int rx_old, tx_old;
 
@@ -548,7 +549,7 @@ static void lance_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static int __lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
@@ -614,6 +615,18 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	return status;
 }
 
+static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lance_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lance_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* taken from the depca driver */
 static void lance_load_multicast (struct net_device *dev)
 {
@@ -735,6 +748,8 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 
 	priv = netdev_priv(dev);
 
+	spin_lock_init(&priv->tx_lock);
+
 	r1->name = dev->name;
 	r2->name = dev->name;
 
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index e4483de..7553d14 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -468,6 +468,7 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	ap = dev->priv;
+	spin_lock_init(&ap->tx_lock);
 	ap->pdev = pdev;
 	ap->name = pci_name(pdev);
 
@@ -2458,7 +2459,7 @@ ace_load_tx_bd(struct ace_private *ap, struct tx_desc *desc, u64 addr,
 }
 
 
-static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
@@ -2598,6 +2599,17 @@ overflow:
 	return NETDEV_TX_BUSY;
 }
 
+static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ace_private *ap = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ap->tx_lock);
+	ret = __ace_start_xmit(skb, dev);
+	spin_unlock(&ap->tx_lock);
+
+	return ret;
+}
 
 static int ace_change_mtu(struct net_device *dev, int new_mtu)
 {
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 4487f32..a48ad7e 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -642,6 +642,7 @@ struct ace_private
 	/*
 	 * TX elements
 	 */
+	spinlock_t		tx_lock;
 	struct tx_desc		*tx_ring;
 	u32			tx_prd;
 	volatile u32		tx_ret_csm;
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index a0b4c85..43e7728 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -177,6 +177,7 @@ struct cops_local
         unsigned char node_acquire;	/* Node ID when acquired. */
         struct atalk_addr node_addr;	/* Full node address */
 	spinlock_t lock;		/* RX/TX lock */
+	spinlock_t tx_lock;
 };
 
 /* Index to functions, as function prototypes. */
@@ -329,6 +330,7 @@ static int __init cops_probe1(struct net_device *dev, int ioaddr)
 
         lp = netdev_priv(dev);
         spin_lock_init(&lp->lock);
+        spin_lock_init(&lp->tx_lock);
 
 	/* Copy local board variable to lp struct. */
 	lp->board               = board;
@@ -876,7 +878,7 @@ static void cops_timeout(struct net_device *dev)
  *	Make the card transmit a LocalTalk packet.
  */
 
-static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __cops_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
         struct cops_local *lp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
@@ -924,6 +926,18 @@ static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
         return 0;
 }
 
+static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+        struct cops_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __cops_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  *	Dummy function to keep the Appletalk layer happy.
  */
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 1071144..cdc44fa 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -111,10 +111,12 @@ static struct net_device_stats *ipddp_get_stats(struct net_device *dev)
         return dev->priv;
 }
 
+static DEFINE_SPINLOCK(ipddp_tx_lock);
+
 /*
  * Transmit LLAP/ELAP frame using aarp_send_ddp.
  */
-static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	__be32 paddr = ((struct rtable*)skb->dst)->rt_gateway;
         struct ddpehdr *ddp;
@@ -179,6 +181,17 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
         return 0;
 }
 
+static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&ipddp_tx_lock);
+	ret = __ipddp_xmit(skb, dev);
+	spin_unlock(&ipddp_tx_lock);
+
+	return ret;
+}
+
 /*
  * Create a routing entry. We first verify that the
  * record does not already exist. If it does we return -EEXIST
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index fef5560..e74a923 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -263,6 +263,7 @@ struct ltpc_private
 {
 	struct net_device_stats stats;
 	struct atalk_addr my_addr;
+	spinlock_t tx_lock;
 };
 
 /* transmit queue element struct */
@@ -898,7 +899,7 @@ static void ltpc_poll(unsigned long l)
 
 /* DDP to LLAP translation */
 
-static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	/* in kernel 1.3.xx, on entry skb->data points to ddp header,
 	 * and skb->len is the length of the ddp data + ddp header
@@ -941,6 +942,18 @@ static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ltpc_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __ltpc_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *ltpc_get_stats(struct net_device *dev)
 {
 	struct net_device_stats *stats = &((struct ltpc_private *) dev->priv)->stats;
@@ -1026,6 +1039,7 @@ static int __init ltpc_probe_dma(int base, int dma)
 
 struct net_device * __init ltpc_probe(void)
 {
+	struct ltpc_private *lp;
 	struct net_device *dev;
 	int err = -ENOMEM;
 	int x=0,y=0;
@@ -1037,6 +1051,9 @@ struct net_device * __init ltpc_probe(void)
 	if (!dev)
 		goto out;
 
+	lp = netdev_priv(dev);
+	spin_lock_init(&lp->tx_lock);
+
 	/* probe for the I/O port address */
 	
 	if (io != 0x240 && request_region(0x220,8,"ltpc")) {
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index bdc4c0b..339b542 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -359,6 +359,7 @@ struct net_device *alloc_arcdev(char *name)
 	if(dev) {
 		struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
 		spin_lock_init(&lp->lock);
+		spin_lock_init(&lp->tx_lock);
 	}
 
 	return dev;
@@ -601,7 +602,7 @@ static int arcnet_rebuild_header(struct sk_buff *skb)
 
 
 /* Called by the kernel in order to transmit a packet. */
-static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct arcnet_local *lp = dev->priv;
 	struct archdr *pkt;
@@ -686,6 +687,17 @@ static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return retval;		/* no need to try again */
 }
 
+static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct arcnet_local *lp = dev->priv;
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __arcnet_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 /*
  * Actually start transmitting a packet that was loaded into a buffer
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index 10f3a19..2f38a87 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -96,6 +96,7 @@ struct ariadne_private {
     volatile struct RDRE *rx_ring[RX_RING_SIZE];
     volatile u_short *tx_buff[TX_RING_SIZE];
     volatile u_short *rx_buff[RX_RING_SIZE];
+    spinlock_t tx_lock;
     int cur_tx, cur_rx;			/* The next free ring entry */
     int dirty_tx;			/* The ring entries to be free()ed. */
     struct net_device_stats stats;
@@ -186,6 +187,8 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
 
     priv = netdev_priv(dev);
 
+    spin_lock_init(&priv->tx_lock);
+
     r1->name = dev->name;
     r2->name = dev->name;
 
@@ -586,7 +589,7 @@ static void ariadne_tx_timeout(struct net_device *dev)
 }
 
 
-static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     struct ariadne_private *priv = netdev_priv(dev);
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
@@ -689,6 +692,17 @@ static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
     return 0;
 }
 
+static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+    struct ariadne_private *priv = netdev_priv(dev);
+    int ret;
+
+    spin_lock(&priv->tx_lock);
+    ret = __ariadne_start_xmit(skb, dev);
+    spin_unlock(&priv->tx_lock);
+
+    return ret;
+}
 
 static int ariadne_rx(struct net_device *dev)
 {
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index a637910..3d3ef15 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -447,8 +447,7 @@ static void am79c961_timeout(struct net_device *dev)
 /*
  * Transmit a packet
  */
-static int
-am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
+static int __am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dev_priv *priv = netdev_priv(dev);
 	unsigned int hdraddr, bufaddr;
@@ -485,6 +484,18 @@ am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dev_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __am79c961_sendpacket(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /*
  * If we have a good packet(s), get it/them out of the buffers.
  */
@@ -726,6 +737,7 @@ static int __init am79c961_probe(struct platform_device *pdev)
 	am79c961_banner();
 
 	spin_lock_init(&priv->chip_lock);
+	spin_lock_init(&priv->tx_lock);
 	init_timer(&priv->timer);
 	priv->timer.data = (unsigned long)dev;
 	priv->timer.function = am79c961_timer;
diff --git a/drivers/net/arm/am79c961a.h b/drivers/net/arm/am79c961a.h
index 483009f..4a1f866 100644
--- a/drivers/net/arm/am79c961a.h
+++ b/drivers/net/arm/am79c961a.h
@@ -140,6 +140,7 @@ struct dev_priv {
     unsigned long	rxhdr;
     unsigned long	txhdr;
     spinlock_t		chip_lock;
+    spinlock_t		tx_lock;
     struct timer_list	timer;
 };
 
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 1e39e78..013cc18 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -809,7 +809,7 @@ static int at91ether_close(struct net_device *dev)
 /*
  * Transmit packet.
  */
-static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
+static int __at91ether_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct at91_private *lp = netdev_priv(dev);
 
@@ -838,6 +838,18 @@ static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct at91_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __at91ether_tx(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  * Update the current statistics from the internal statistics registers.
  */
@@ -1007,6 +1019,7 @@ static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_add
 	platform_set_drvdata(pdev, dev);
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	ether_setup(dev);
 	dev->open = at91ether_open;
diff --git a/drivers/net/arm/at91_ether.h b/drivers/net/arm/at91_ether.h
index a38fd2d..cf0b234 100644
--- a/drivers/net/arm/at91_ether.h
+++ b/drivers/net/arm/at91_ether.h
@@ -92,6 +92,7 @@ struct at91_private
 	/* PHY */
 	unsigned long phy_type;			/* type of PHY (PHY_ID) */
 	spinlock_t lock;			/* lock for MDI interface */
+	spinlock_t tx_lock;
 	short phy_media;			/* media interface type */
 	unsigned short phy_address;		/* 5-bit MDI address of PHY (0..31) */
 	struct timer_list check_timer;		/* Poll link status */
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index ecd8fc6..8be1b82 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -166,6 +166,7 @@ struct ep93xx_priv
 	unsigned int		rx_pointer;
 	unsigned int		tx_clean_pointer;
 	unsigned int		tx_pointer;
+	spinlock_t		tx_lock;
 	spinlock_t		tx_pending_lock;
 	unsigned int		tx_pending;
 
@@ -316,7 +317,7 @@ poll_some_more:
 	return rx;
 }
 
-static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
 	int entry;
@@ -350,6 +351,18 @@ static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ep93xx_priv *ep = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ep->tx_lock);
+	ret = __ep93xx_xmit(skb, dev);
+	spin_unlock(&ep->tx_lock);
+
+	return ret;
+}
+
 static void ep93xx_tx_complete(struct net_device *dev)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
@@ -651,6 +664,7 @@ static int ep93xx_open(struct net_device *dev)
 	ep->rx_pointer = 0;
 	ep->tx_clean_pointer = 0;
 	ep->tx_pointer = 0;
+	spin_lock_init(&ep->tx_lock);
 	spin_lock_init(&ep->tx_pending_lock);
 	ep->tx_pending = 0;
 
diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index 3bb9e29..b9defe8 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -677,8 +677,7 @@ ether1_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int
-ether1_sendpacket (struct sk_buff *skb, struct net_device *dev)
+static int __ether1_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
 	int tmp, tst, nopaddr, txaddr, tbdaddr, dataddr;
 	unsigned long flags;
@@ -751,6 +750,17 @@ ether1_sendpacket (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ether1_sendpacket(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&priv(dev)->tx_lock);
+	ret = __ether1_sendpacket(skb, dev);
+	spin_unlock(&priv(dev)->tx_lock);
+
+	return ret;
+}
+
 static void
 ether1_xmit_done (struct net_device *dev)
 {
@@ -1010,6 +1020,8 @@ ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto release;
 	}
 
+	spin_lock_init(&priv(dev)->tx_lock);
+
 	SET_NETDEV_DEV(dev, &ec->dev);
 
 	dev->irq = ec->irq;
diff --git a/drivers/net/arm/ether1.h b/drivers/net/arm/ether1.h
index c8a4b23..577e049 100644
--- a/drivers/net/arm/ether1.h
+++ b/drivers/net/arm/ether1.h
@@ -39,6 +39,7 @@
 struct ether1_priv {
 	void __iomem *base;
 	struct net_device_stats stats;
+	spinlock_t tx_lock;
 	unsigned int tx_link;
 	unsigned int tx_head;
 	volatile unsigned int tx_tail;
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 67e96ae..7141a8b 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -500,8 +500,7 @@ static void ether3_timeout(struct net_device *dev)
 /*
  * Transmit a packet
  */
-static int
-ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
+static int __ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	unsigned int length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
@@ -565,6 +564,17 @@ ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&priv(dev)->tx_lock);
+	ret = __ether3_sendpacket(skb, dev);
+	spin_unlock(&priv(dev)->tx_lock);
+
+	return ret;
+}
+
 static irqreturn_t
 ether3_interrupt(int irq, void *dev_id)
 {
@@ -790,6 +800,8 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto release;
 	}
 
+	spin_lock_init(&priv(dev)->tx_lock);
+
 	SET_NETDEV_DEV(dev, &ec->dev);
 
 	priv(dev)->base = ecardm_iomap(ec, ECARD_RES_MEMC, 0, 0);
diff --git a/drivers/net/arm/ether3.h b/drivers/net/arm/ether3.h
index 1921a3a..8f6e76b 100644
--- a/drivers/net/arm/ether3.h
+++ b/drivers/net/arm/ether3.h
@@ -161,6 +161,7 @@ struct dev_priv {
 	unsigned int config1;
 	unsigned int config2;
     } regs;
+    spinlock_t tx_lock;
     unsigned char tx_head;		/* buffer nr to insert next packet	 */
     unsigned char tx_tail;		/* buffer nr of transmitting packet	 */
     unsigned int rx_head;		/* address to fetch next packet from	 */
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index c617b64..c9b0d04 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -168,6 +168,7 @@ struct port {
 	struct mii_if_info mii;
 	struct delayed_work mdio_thread;
 	struct eth_plat_info *plat;
+	spinlock_t tx_lock;
 	buffer_t *rx_buff_tab[RX_DESCS], *tx_buff_tab[TX_DESCS];
 	struct desc *desc_tab;	/* coherent */
 	u32 desc_tab_phys;
@@ -660,7 +661,7 @@ static void eth_txdone_irq(void *unused)
 	}
 }
 
-static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
 	unsigned int txreadyq = port->plat->txreadyq;
@@ -747,6 +748,17 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&port->tx_lock);
+	ret = __eth_xmit(skb, dev);
+	spin_unlock(&port->tx_lock);
+
+	return ret;
+}
 
 static struct net_device_stats *eth_stats(struct net_device *dev)
 {
@@ -1133,6 +1145,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	port = netdev_priv(dev);
+	spin_lock_init(&port->tx_lock);
 	port->netdev = dev;
 	port->id = pdev->id;
 
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 7e874d4..764f4c9 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -110,6 +110,7 @@ typedef unsigned char uchar;
 /* Information that need to be kept for each board. */
 struct net_local {
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	unsigned char mc_filter[8];
 	uint jumpered:1;			/* Set iff the board has jumper config. */
 	uint tx_started:1;			/* Packets are on the Tx queue. */
@@ -459,6 +460,7 @@ found:
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	lp->jumpered = is_fmv18x;
 	lp->mca_slot = slot;
@@ -591,7 +593,7 @@ static void net_tx_timeout (struct net_device *dev)
 }
 
 
-static int net_send_packet (struct sk_buff *skb, struct net_device *dev)
+static int __net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -642,6 +644,18 @@ static int net_send_packet (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __net_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* The typical workload of the driver:
    Handle the network interface interrupts. */
 static irqreturn_t net_interrupt(int irq, void *dev_id)
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 0860cc2..e5eca38 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -227,6 +227,7 @@ struct lance_private {
 /* This must be long for set_bit() */
 	long			tx_full;
 	spinlock_t		devlock;
+	spinlock_t		tx_lock;
 };
 
 /* I/O register access macros */
@@ -603,6 +604,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	}
 
 	spin_lock_init(&lp->devlock);
+	spin_lock_init(&lp->tx_lock);
 
 	MEM->init.mode = 0x0000;		/* Disable Rx and Tx. */
 	for( i = 0; i < 6; i++ )
@@ -771,9 +773,9 @@ static void lance_tx_timeout (struct net_device *dev)
 
 /* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
 
-static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+static int __lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lance_private *lp = (struct lance_private *)dev->priv;
 	struct lance_ioreg	 *IO = lp->iobase;
 	int entry, len;
 	struct lance_tx_head *head;
@@ -850,6 +852,18 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	return 0;
 }
 
+static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lance_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lance_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* The LANCE interrupt handler. */
 
 static irqreturn_t lance_interrupt( int irq, void *dev_id )
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 3d44333..225c9c8 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -170,6 +170,7 @@ static char mux_8012[] = { 0xff, 0xf7, 0xff, 0xfb, 0xf3, 0xfb, 0xff, 0xf7,};
 
 struct net_local {
     spinlock_t lock;
+    spinlock_t tx_lock;
     struct net_device *next_module;
     struct timer_list timer;	/* Media selection timer. */
     long last_rx_time;		/* Last Rx, in jiffies, to handle Rx hang. */
@@ -334,6 +335,7 @@ static int __init atp_probe1(long ioaddr)
 	lp->chip_type = RTL8002;
 	lp->addr_mode = CMR2h_Normal;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/* For the ATP adapter the "if_port" is really the data transfer mode. */
 	if (xcvr[0])
@@ -548,7 +550,7 @@ static void tx_timeout(struct net_device *dev)
 	dev->stats.tx_errors++;
 }
 
-static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __atp_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
@@ -586,6 +588,17 @@ static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __atp_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 /* The typical workload of the driver:
    Handle the network interface interrupts. */
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7023d77..bc105c6 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -754,6 +754,7 @@ static struct net_device * au1000_probe(int port_num)
 	}
 
 	spin_lock_init(&aup->lock);
+	spin_lock_init(&aup->tx_lock);
 	dev->base_addr = base;
 	dev->irq = irq;
 	dev->open = au1000_open;
@@ -1077,7 +1078,7 @@ static void au1000_tx_ack(struct net_device *dev)
 /*
  * Au1000 transmit routine.
  */
-static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
+static int __au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
 	struct net_device_stats *ps = &dev->stats;
@@ -1131,6 +1132,18 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	int ret;
+
+	spin_lock(&aup->tx_lock);
+	ret = __au1000_tx(skb, dev);
+	spin_unlock(&aup->tx_lock);
+
+	return ret;
+}
+
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index f3baeaa..76b7f88 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -116,4 +116,5 @@ struct au1000_private {
 	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */
 
 	spinlock_t lock;       /* Serialise access to device */
+	spinlock_t tx_lock;
 };
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 4144343..c957abf 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -603,8 +603,8 @@ adjust_head:
 
 }
 
-static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+static int __bfin_mac_hard_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	unsigned int data;
 
@@ -661,6 +661,19 @@ out:
 	return 0;
 }
 
+static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
+{
+	struct bfin_mac_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __bfin_mac_hard_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void bfin_mac_rx(struct net_device *dev)
 {
 	struct sk_buff *skb, *new_skb;
@@ -1045,6 +1058,7 @@ static int __init bfin_mac_probe(struct platform_device *pdev)
 	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/* now, enable interrupts */
 	/* register irq handler */
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index beff510..35c510c 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -59,6 +59,7 @@ struct bfin_mac_local {
 
 	unsigned char Mac[6];	/* MAC address of the board */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	/* MII and PHY stuffs */
 	int old_link;          /* used by bf537_adjust_link */
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index a42bd19..c96b43f 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -82,6 +82,7 @@ struct bmac_data {
 	unsigned short hash_use_count[64];
 	unsigned short hash_table_mask[4];
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 #if 0 /* Move that to ethtool */
@@ -1288,6 +1289,7 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 
 	bp->mdev = mdev;
 	spin_lock_init(&bp->lock);
+	spin_lock_init(&bp->tx_lock);
 
 	if (macio_request_resources(mdev, "bmac")) {
 		printk(KERN_ERR "BMAC: can't request IO resource !\n");
@@ -1484,8 +1486,10 @@ static int
 bmac_output(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bmac_data *bp = netdev_priv(dev);
+	spin_lock(&bp->tx_lock);
 	skb_queue_tail(bp->queue, skb);
 	bmac_start(dev);
+	spin_unlock(&bp->tx_lock);
 	return 0;
 }
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ad61cfd..181c356 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5880,18 +5880,15 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
  * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue().
  */
-static int
-bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			     struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
-	struct bnx2 *bp = netdev_priv(dev);
 	dma_addr_t mapping;
 	struct tx_bd *txbd;
 	struct sw_bd *tx_buf;
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
-	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 
 	if (unlikely(bnx2_tx_avail(bp, txr) <
 	    (skb_shinfo(skb)->nr_frags + 1))) {
@@ -6018,6 +6015,20 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+	int ret;
+
+	spin_lock(&txr->tx_lock);
+	ret = __bnx2_start_xmit(skb, dev, bp, txr);
+	spin_unlock(&txr->tx_lock);
+
+	return ret;
+}
+
 /* Called with rtnl_lock */
 static int
 bnx2_close(struct net_device *dev)
@@ -7582,6 +7593,7 @@ bnx2_init_napi(struct bnx2 *bp)
 
 		netif_napi_add(bp->dev, &bp->bnx2_napi[i].napi, poll, 64);
 		bnapi->bp = bp;
+		spin_lock_init(&bnapi->tx_ring.tx_lock);
 	}
 }
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index efa0ca9..6d76d03 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6595,6 +6595,7 @@ struct bnx2_irq {
 };
 
 struct bnx2_tx_ring_info {
+	spinlock_t		tx_lock;
 	u32			tx_prod_bseq;
 	u16			tx_prod;
 	u32			tx_bidx_addr;
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4bf4f7b..727b1d4 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -729,6 +729,7 @@ struct bnx2x {
 	atomic_t		intr_sem;
 	struct msix_entry	msix_table[MAX_CONTEXT+1];
 
+	spinlock_t		tx_lock;
 	int			tx_ring_size;
 
 #ifdef BCM_VLAN
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0263bef..2b83e84 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9304,7 +9304,7 @@ exit_lbl:
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue()
  */
-static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	struct bnx2x_fastpath *fp;
@@ -9562,6 +9562,18 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&bp->tx_lock);
+	ret = __bnx2x_start_xmit(skb, dev);
+	spin_unlock(&bp->tx_lock);
+
+	return ret;
+}
+
 /* called with rtnl_lock */
 static int bnx2x_open(struct net_device *dev)
 {
@@ -9849,6 +9861,8 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	bp = netdev_priv(dev);
 
+	spin_lock_init(&bp->tx_lock);
+
 	bp->dev = dev;
 	bp->pdev = pdev;
 	bp->flags = 0;
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 103f0f1..fce0ea8 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -67,6 +67,9 @@ static int echo; /* echo testing. Default: 0 (Off) */
 module_param(echo, bool, S_IRUGO);
 MODULE_PARM_DESC(echo, "Echo sent frames (for testing). Default: 0 (Off)");
 
+struct vcan_priv {
+	spinlock_t tx_lock;
+};
 
 static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 {
@@ -83,7 +86,7 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 	netif_rx(skb);
 }
 
-static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
+static int __vcan_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	int loop;
@@ -128,8 +131,24 @@ static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vcan_priv *vp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&vp->tx_lock);
+	ret = __vcan_tx(skb, dev);
+	spin_unlock(&vp->tx_lock);
+
+	return ret;
+}
+
 static void vcan_setup(struct net_device *dev)
 {
+	struct vcan_priv *vp = netdev_priv(dev);
+
+	spin_lock_init(&vp->tx_lock);
+
 	dev->type              = ARPHRD_CAN;
 	dev->mtu               = sizeof(struct can_frame);
 	dev->hard_header_len   = 0;
@@ -147,6 +166,7 @@ static void vcan_setup(struct net_device *dev)
 
 static struct rtnl_link_ops vcan_link_ops __read_mostly = {
        .kind           = "vcan",
+       .priv_size      = sizeof(struct vcan_priv),
        .setup          = vcan_setup,
 };
 
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 7f3f62e..1f5f554 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -196,6 +196,7 @@ struct cpmac_desc {
 struct cpmac_priv {
 	spinlock_t lock;
 	spinlock_t rx_lock;
+	spinlock_t tx_lock;
 	struct cpmac_desc *rx_head;
 	int ring_size;
 	struct cpmac_desc *desc_ring;
@@ -555,7 +556,7 @@ fatal_error:
 
 }
 
-static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int queue, len;
 	struct cpmac_desc *desc;
@@ -605,6 +606,18 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct cpmac_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __cpmac_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void cpmac_end_xmit(struct net_device *dev, int queue)
 {
 	struct cpmac_desc *desc;
@@ -1185,6 +1198,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->rx_lock);
+	spin_lock_init(&priv->tx_lock);
 	priv->dev = dev;
 	priv->ring_size = 64;
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index fba87ab..5f192cd 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -234,6 +234,7 @@ struct net_local {
 	int send_underrun;	/* keep track of how many underruns in a row we get */
 	int force;		/* force various values; see FORCE* above. */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 #if ALLOW_DMA
 	int use_dma;		/* Flag: we're using dma */
 	int dma;		/* DMA channel */
@@ -522,6 +523,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	if (!modular) {
 		memset(lp, 0, sizeof(*lp));
 		spin_lock_init(&lp->lock);
+		spin_lock_init(&lp->tx_lock);
 #ifndef MODULE
 #if ALLOW_DMA
 		if (g_cs89x0_dma) {
@@ -1516,7 +1518,7 @@ static void net_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 
@@ -1569,6 +1571,18 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __net_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* The typical workload of the driver:
    Handle the network interface interrupts. */
 
@@ -1928,6 +1942,7 @@ int __init init_module(void)
 #endif
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
         /* boy, they'd better get these right */
         if (!strcmp(media, "rj45"))
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index cb849b0..ba2736e 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -93,6 +93,7 @@ static volatile int		tx_fifo_out;
 static volatile int		free_tx_pages = TX_PAGES;
 static int			was_down;
 static DEFINE_SPINLOCK(de600_lock);
+static DEFINE_SPINLOCK(de600_tx_lock);
 
 static inline u8 de600_read_status(struct net_device *dev)
 {
@@ -168,7 +169,7 @@ static inline void trigger_interrupt(struct net_device *dev)
  * Start sending.
  */
 
-static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	int	transmit_from;
@@ -241,6 +242,17 @@ static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&de600_tx_lock);
+	ret = __de600_start_xmit(skb, dev);
+	spin_unlock(&de600_tx_lock);
+
+	return ret;
+}
+
 /*
  * The typical workload of the driver:
  * Handle the network interface interrupts.
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 3f5190c..42942e6 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -188,7 +188,8 @@ static int clone = DE620_CLONE;
 
 static unsigned int de620_debug = DE620_DEBUG;
 
-static spinlock_t de620_lock;
+static DEFINE_SPINLOCK(de620_lock);
+static DEFINE_SPINLOCK(de620_tx_lock);
 
 module_param(bnc, int, 0);
 module_param(utp, int, 0);
@@ -521,7 +522,7 @@ static void de620_timeout(struct net_device *dev)
  * Copy a buffer to the adapter transmit page memory.
  * Start sending.
  */
-static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	int len;
@@ -574,6 +575,17 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&de620_tx_lock);
+	ret = __de620_start_xmit(skb, dev);
+	spin_unlock(&de620_tx_lock);
+
+	return ret;
+}
+
 /*****************************************************
  *
  * Handle the network interface interrupts.
@@ -813,8 +825,6 @@ struct net_device * __init de620_probe(int unit)
 	if (!dev)
 		goto out;
 
-	spin_lock_init(&de620_lock);
-
 	/*
 	 * This is where the base_addr and irq gets set.
 	 * Tunable at compile-time and insmod-time
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 3e35064..f400652 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -254,6 +254,7 @@ struct lance_private {
 	volatile struct lance_regs *ll;
 
 	spinlock_t	lock;
+	spinlock_t	tx_lock;
 
 	int rx_new, tx_new;
 	int rx_old, tx_old;
@@ -891,7 +892,7 @@ static void lance_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
@@ -932,6 +933,18 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
  	return 0;
 }
 
+static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lance_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lance_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
@@ -1055,6 +1068,7 @@ static int __init dec_lance_probe(struct device *bdev, const int type)
 	 */
 	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	lp->type = type;
 	switch (type) {
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index c062aac..8b0c751 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -1420,6 +1420,7 @@ static int dfx_open(struct net_device *dev)
 	bp->group_prom		= PI_FSTATE_K_BLOCK;
 
 	spin_lock_init(&bp->lock);
+	spin_lock_init(&bp->tx_lock);
 
 	/* Reset and initialize adapter */
 
@@ -3186,12 +3187,8 @@ static void dfx_rcv_queue_process(
  *   None
  */
 
-static int dfx_xmt_queue_pkt(
-	struct sk_buff	*skb,
-	struct net_device	*dev
-	)
-
-	{
+static int __dfx_xmt_queue_pkt(struct sk_buff *skb, struct net_device *dev)
+{
 	DFX_board_t		*bp = netdev_priv(dev);
 	u8			prod;				/* local transmit producer index */
 	PI_XMT_DESCR		*p_xmt_descr;		/* ptr to transmit descriptor block entry */
@@ -3344,8 +3341,19 @@ static int dfx_xmt_queue_pkt(
 	spin_unlock_irqrestore(&bp->lock, flags);
 	netif_wake_queue(dev);
 	return(0);							/* packet queued to adapter */
-	}
+}
 
+static int dfx_xmt_queue_pkt(struct sk_buff *skb, struct net_device *dev)
+{
+	DFX_board_t *bp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&bp->tx_lock);
+	ret = __dfx_xmt_queue_pkt(skb, dev);
+	spin_unlock(&bp->tx_lock);
+
+	return ret;
+}
 
 /*
  * ================
diff --git a/drivers/net/defxx.h b/drivers/net/defxx.h
index 19a6f64..83e13f0 100644
--- a/drivers/net/defxx.h
+++ b/drivers/net/defxx.h
@@ -1765,6 +1765,7 @@ typedef struct DFX_board_tag
 	/* Transmit spinlocks */
 
 	spinlock_t			lock;
+	spinlock_t			tx_lock;
 
 	/* Store device, bus-specific, and parameter information for this adapter */
 
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index ace39ec..744b1aa 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -486,6 +486,7 @@ struct depca_private {
 	int rx_new, tx_new;	/* The next free ring entry               */
 	int rx_old, tx_old;	/* The ring entries to be free()ed.       */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	struct {		/* Private stats counters                 */
 		u32 bins[DEPCA_PKT_STAT_SZ];
 		u32 unicast;
@@ -669,6 +670,7 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 	}
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	sprintf(lp->adapter_name, "%s (%s)",
 		depca_signature[lp->adapter], device->bus_id);
 	status = -EBUSY;
@@ -922,7 +924,7 @@ static void depca_tx_timeout(struct net_device *dev)
 /*
 ** Writes a socket buffer to TX descriptor ring and starts transmission
 */
-static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct depca_private *lp = (struct depca_private *) dev->priv;
 	u_long ioaddr = dev->base_addr;
@@ -957,6 +959,18 @@ static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return status;
 }
 
+static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct depca_private *lp = (struct depca_private *) dev->priv;
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __depca_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
 ** The DEPCA interrupt handler.
 */
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 8277e89..77ffccb 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -594,8 +594,7 @@ alloc_list (struct net_device *dev)
 	return;
 }
 
-static int
-start_xmit (struct sk_buff *skb, struct net_device *dev)
+static int __start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	struct netdev_desc *txdesc;
@@ -665,6 +664,19 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&np->tx_lock, flags);
+	ret = __start_xmit(skb, dev);
+	spin_unlock_irqrestore(&np->tx_lock, flags);
+
+	return ret;
+}
+
 static irqreturn_t
 rio_interrupt (int irq, void *dev_instance)
 {
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 08a7365..1f4feea 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -121,6 +121,7 @@ typedef struct board_info {
 	struct net_device  *ndev;
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	struct mii_if_info mii;
 	u32 msg_enable;
@@ -553,6 +554,7 @@ dm9000_probe(struct platform_device *pdev)
 	db->ndev = ndev;
 
 	spin_lock_init(&db->lock);
+	spin_lock_init(&db->tx_lock);
 	mutex_init(&db->addr_lock);
 
 	INIT_DELAYED_WORK(&db->phy_poll, dm9000_poll_work);
@@ -835,8 +837,7 @@ dm9000_init_dm9000(struct net_device *dev)
  *  Hardware start transmission.
  *  Send a packet to media from the upper layer.
  */
-static int
-dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	board_info_t *db = (board_info_t *) dev->priv;
@@ -879,6 +880,18 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	board_info_t *db = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&db->tx_lock);
+	ret = __dm9000_start_xmit(skb, dev);
+	spin_unlock(&db->tx_lock);
+
+	return ret;
+}
+
 static void
 dm9000_shutdown(struct net_device *dev)
 {
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 84e14f3..82adf4e 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -35,10 +35,13 @@
 #include <linux/init.h>
 #include <linux/moduleparam.h>
 #include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
 #include <net/rtnetlink.h>
 
 static int numdummies = 1;
 
+static DEFINE_SPINLOCK(dummy_tx_lock);
+
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
 
 static int dummy_set_address(struct net_device *dev, void *p)
@@ -76,10 +79,12 @@ static void dummy_setup(struct net_device *dev)
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	spin_lock(&dummy_tx_lock);
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
 	dev_kfree_skb(skb);
+	spin_unlock(&dummy_tx_lock);
 	return 0;
 }
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index f3cba5e..142f93d 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -542,6 +542,7 @@ struct nic {
 	struct rfd blank_rfd;
 	enum ru_state ru_running;
 
+	spinlock_t tx_lock;
 	spinlock_t cb_lock			____cacheline_aligned;
 	spinlock_t cmd_lock;
 	struct csr __iomem *csr;
@@ -1633,7 +1634,7 @@ static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
 	cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
 }
 
-static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static int __e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
 	int err;
@@ -1666,6 +1667,18 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return 0;
 }
 
+static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct nic *nic = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&nic->tx_lock);
+	ret = __e100_xmit_frame(skb, netdev);
+	spin_unlock(&nic->tx_lock);
+
+	return ret;
+}
+
 static int e100_tx_clean(struct nic *nic)
 {
 	struct net_device *dev = nic->netdev;
@@ -2686,6 +2699,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	e100_get_defaults(nic);
 
 	/* locks must be initialized before calling hw_reset */
+	spin_lock_init(&nic->tx_lock);
 	spin_lock_init(&nic->cb_lock);
 	spin_lock_init(&nic->cmd_lock);
 	spin_lock_init(&nic->mdio_lock);
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 56f5049..025e6aa 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -205,6 +205,7 @@ struct eepro_local {
 	int stepping;
 
 	spinlock_t lock; /* Serializing lock  */
+	spinlock_t tx_lock;
 
 	unsigned rcv_ram;	/* pre-calculated space for rx */
 	unsigned xmt_ram;	/* pre-calculated space for tx */
@@ -784,6 +785,7 @@ static int __init eepro_probe1(struct net_device *dev, int autoprobe)
 	lp->xmt_upper_limit_reg = XMT_UPPER_LIMIT_REG_PRO;
 	lp->eeprom_reg = EEPROM_REG_PRO;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/* Now, get the ethernet hardware address from
 	   the EEPROM */
@@ -1127,7 +1129,7 @@ static void eepro_tx_timeout (struct net_device *dev)
 }
 
 
-static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct eepro_local *lp = netdev_priv(dev);
 	unsigned long flags;
@@ -1175,6 +1177,17 @@ static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct eepro_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __eepro_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 /*	The typical workload of the driver:
 	Handle the network interface interrupts. */
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index c05cb15..010749c 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -60,6 +60,7 @@ struct enc28j60_net {
 	struct net_device *netdev;
 	struct spi_device *spi;
 	struct mutex lock;
+	spinlock_t tx_lock;
 	struct sk_buff *tx_skb;
 	struct work_struct tx_work;
 	struct work_struct irq_work;
@@ -1249,7 +1250,7 @@ static void enc28j60_hw_tx(struct enc28j60_net *priv)
 	locked_reg_bfset(priv, ECON1, ECON1_TXRTS);
 }
 
-static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct enc28j60_net *priv = netdev_priv(dev);
 
@@ -1275,6 +1276,18 @@ static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct enc28j60_net *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __enc28j60_send_packet(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void enc28j60_tx_work_handler(struct work_struct *work)
 {
 	struct enc28j60_net *priv =
@@ -1526,6 +1539,7 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 	}
 	priv = netdev_priv(dev);
 
+	spin_lock_init(&priv->tx_lock);
 	priv->netdev = dev;	/* priv to netdev reference */
 	priv->spi = spi;	/* priv to spi reference */
 	priv->msg_enable = netif_msg_init(debug.msg_enable,
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 76118dd..4b1b4b1 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -266,6 +266,7 @@ struct epic_private {
 
 	/* Ring pointers. */
 	spinlock_t lock;				/* Group with Tx control cache line. */
+	spinlock_t tx_lock;
 	spinlock_t napi_lock;
 	struct napi_struct napi;
 	unsigned int reschedule_in_poll;
@@ -405,6 +406,7 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	dev->irq = irq;
 
 	spin_lock_init(&ep->lock);
+	spin_lock_init(&ep->tx_lock);
 	spin_lock_init(&ep->napi_lock);
 	ep->reschedule_in_poll = 0;
 
@@ -958,7 +960,7 @@ static void epic_init_ring(struct net_device *dev)
 	return;
 }
 
-static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct epic_private *ep = dev->priv;
 	int entry, free_count;
@@ -1013,6 +1015,18 @@ static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct epic_private *ep = dev->priv;
+	int ret;
+
+	spin_lock(&ep->tx_lock);
+	ret = __epic_start_xmit(skb, dev);
+	spin_unlock(&ep->tx_lock);
+
+	return ret;
+}
+
 static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
 			  int status)
 {
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index e3dd8b1..42b5818 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -389,6 +389,7 @@ struct eth16i_local {
 	unsigned long     tx_buffered_bytes;
 	unsigned long     col_16;
 	spinlock_t	  lock;
+	spinlock_t	  tx_lock;
 };
 
 /* Function prototypes */
@@ -557,6 +558,7 @@ static int __init eth16i_probe1(struct net_device *dev, int ioaddr)
 	dev->tx_timeout 	= eth16i_timeout;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	retval = register_netdev(dev);
 	if (retval)
@@ -1047,7 +1049,7 @@ static void eth16i_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
+static int __eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -1123,6 +1125,18 @@ static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct eth16i_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __eth16i_tx(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void eth16i_rx(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index 593a120..b230b6f 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -284,6 +284,7 @@ struct ewrk3_private {
 	void __iomem *mctbl;	/* Pointer to the multicast table */
 	u_char led_mask;	/* Used to reserve LED access for ethtool */
 	spinlock_t hw_lock;
+	spinlock_t tx_lock;
 };
 
 /*
@@ -538,6 +539,7 @@ ewrk3_hw_init(struct net_device *dev, u_long iobase)
 	lp->hard_strapped = hard_strapped;
 	lp->led_mask = CR_LED;
 	spin_lock_init(&lp->hw_lock);
+	spin_lock_init(&lp->tx_lock);
 
 	lp->mPage = 64;
 	if (cmr & CMR_DRAM)
@@ -760,7 +762,7 @@ static void ewrk3_timeout(struct net_device *dev)
 /*
    ** Writes a socket buffer to the free page queue
  */
-static int ewrk3_queue_pkt (struct sk_buff *skb, struct net_device *dev)
+static int __ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
 	u_long iobase = dev->base_addr;
@@ -872,6 +874,18 @@ err_out:
 	return 1;
 }
 
+static int ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ewrk3_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __ewrk3_queue_pkt(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
    ** The EWRK3 interrupt handler.
  */
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 329edd9..419cfb3 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -56,6 +56,7 @@ struct mpc52xx_fec_priv {
 	struct bcom_task *rx_dmatsk;
 	struct bcom_task *tx_dmatsk;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int msg_enable;
 
 	/* MDIO link details */
@@ -375,7 +376,8 @@ static int mpc52xx_fec_close(struct net_device *dev)
  * invariant will hold if you make sure that the netif_*_queue()
  * calls are done at the proper times.
  */
-static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __mpc52xx_fec_hard_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 	struct bcom_fec_bd *bd;
@@ -406,6 +408,19 @@ static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct net_device *d
 	return 0;
 }
 
+static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb,
+				       struct net_device *dev)
+{
+	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __mpc52xx_fec_hard_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /* This handles BestComm transmit task interrupts
  */
 static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
@@ -935,6 +950,7 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
 
 	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->tx_lock);
 
 	/* ioremap the zones */
 	priv->fec = ioremap(mem.start, sizeof(struct mpc52xx_fec));
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index f5591cf..f68f728 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -700,6 +700,7 @@ struct nv_skb_map {
 /* in dev: base, irq */
 struct fe_priv {
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	struct net_device *dev;
 	struct napi_struct napi;
@@ -1995,7 +1996,7 @@ static void nv_gear_backoff_reseed(struct net_device *dev)
  * nv_start_xmit: dev->hard_start_xmit function
  * Called with netif_tx_lock held.
  */
-static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 tx_flags = 0;
@@ -2112,7 +2113,20 @@ static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
+static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __nv_start_xmit(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
+static int __nv_start_xmit_optimized(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 tx_flags = 0;
@@ -2263,6 +2277,19 @@ static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int nv_start_xmit_optimized(struct sk_buff *skb,
+				   struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __nv_start_xmit_optimized(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
 static inline void nv_tx_flip_ownership(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -5343,6 +5370,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->dev = dev;
 	np->pci_dev = pci_dev;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 	SET_NETDEV_DEV(dev, &pci_dev->dev);
 
 	init_timer(&np->oom_kick);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 393a0f1..22464ac 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -215,6 +215,7 @@ static int gfar_probe(struct platform_device *pdev)
 	}
 
 	spin_lock_init(&priv->txlock);
+	spin_lock_init(&priv->tx_lock);
 	spin_lock_init(&priv->rxlock);
 
 	platform_set_drvdata(pdev, dev);
@@ -1026,7 +1027,7 @@ void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
 
 /* This is called by the kernel when a frame is ready for transmission. */
 /* It is pointed to by the dev->hard_start_xmit function pointer */
-static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct txfcb *fcb = NULL;
@@ -1123,6 +1124,18 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __gfar_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /* Stops the kernel queue, and halts the controller */
 static int gfar_close(struct net_device *dev)
 {
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 27f37c8..049096b 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -676,6 +676,7 @@ struct gfar {
 struct gfar_private {
 	/* Fields controlled by TX lock */
 	spinlock_t txlock;
+	spinlock_t tx_lock;
 
 	/* Pointer to the array of skbuffs */
 	struct sk_buff ** tx_skbuff;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 3199526..415f05c 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -497,6 +497,7 @@ struct hamachi_private {
 	struct timer_list timer;		/* Media selection timer. */
 	/* Frequently used and paired value: keep adjacent for cache effect. */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int chip_id;
 	unsigned int cur_rx, dirty_rx;		/* Producer/consumer ring indices */
 	unsigned int cur_tx, dirty_tx;
@@ -636,6 +637,7 @@ static int __devinit hamachi_init_one (struct pci_dev *pdev,
 
 	hmp = netdev_priv(dev);
 	spin_lock_init(&hmp->lock);
+	spin_lock_init(&hmp->tx_lock);
 
 	hmp->mii_if.dev = dev;
 	hmp->mii_if.mdio_read = mdio_read;
@@ -1253,7 +1255,7 @@ do { \
 } while (0)
 #endif
 
-static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct hamachi_private *hmp = netdev_priv(dev);
 	unsigned entry;
@@ -1366,6 +1368,18 @@ static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hamachi_private *hmp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&hmp->tx_lock);
+	ret = __hamachi_start_xmit(skb, dev);
+	spin_unlock(&hmp->tx_lock);
+
+	return ret;
+}
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t hamachi_interrupt(int irq, void *dev_instance)
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 00bc7fb..0d43145 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -193,6 +193,7 @@ struct baycom_state {
 		unsigned char buf[TXBUFFER_SIZE];
         } hdlcrx;
 
+        spinlock_t tx_lock;
         struct {
 		int calibrate;
                 int slotcnt;
@@ -769,7 +770,7 @@ static void epp_bh(struct work_struct *work)
  * ===================== network driver interface =========================
  */
 
-static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct baycom_state *bc = netdev_priv(dev);
 
@@ -790,6 +791,18 @@ static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int baycom_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct baycom_state *bc = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&bc->tx_lock);
+	ret = __baycom_send_packet(skb, dev);
+	spin_unlock(&bc->tx_lock);
+
+	return ret;
+}
+
 /* --------------------------------------------------------------------- */
 
 static int baycom_set_mac_address(struct net_device *dev, void *addr)
@@ -1135,6 +1148,7 @@ static void baycom_probe(struct net_device *dev)
 	 * not a real probe! only initialize data structures
 	 */
 	bc = netdev_priv(dev);
+	spin_lock_init(&bc->tx_lock);
 	/*
 	 * initialize the baycom_state struct
 	 */
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 5f4b4c6..16864f7 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -107,6 +107,7 @@ static struct notifier_block bpq_dev_notifier = {
 
 
 struct bpqdev {
+	spinlock_t tx_lock;
 	struct list_head bpq_list;	/* list of bpq devices chain */
 	struct net_device *ethdev;	/* link to ethernet device */
 	struct net_device *axdev;	/* bpq device (bpq#) */
@@ -234,7 +235,7 @@ drop:
 /*
  * 	Send an AX.25 frame via an ethernet interface
  */
-static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *newskb;
 	unsigned char *ptr;
@@ -295,6 +296,18 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bpqdev *bpq = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&bpq->tx_lock);
+	ret = __bpq_xmit(skb, dev);
+	spin_unlock(&bpq->tx_lock);
+
+	return ret;
+}
+
 /*
  *	Statistics
  */
@@ -509,6 +522,7 @@ static int bpq_new_device(struct net_device *edev)
 
 		
 	bpq = netdev_priv(ndev);
+	spin_lock_init(&bpq->tx_lock);
 	dev_hold(edev);
 	bpq->ethdev = edev;
 	bpq->axdev = ndev;
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 0b94833..1870825 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -215,6 +215,7 @@ struct scc_priv {
 	int rr0;
 	spinlock_t *register_lock;	/* Per scc_info */
 	spinlock_t ring_lock;
+	spinlock_t tx_lock;
 };
 
 struct scc_info {
@@ -559,6 +560,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 		priv->info = info;
 		priv->channel = i;
 		spin_lock_init(&priv->ring_lock);
+		spin_lock_init(&priv->tx_lock);
 		priv->register_lock = &info->register_lock;
 		priv->card_base = card_base;
 		priv->scc_cmd = scc_base + (i ? SCCB_CMD : SCCA_CMD);
@@ -916,7 +918,7 @@ static int scc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 }
 
 
-static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct scc_priv *priv = dev->priv;
 	unsigned long flags;
@@ -960,6 +962,17 @@ static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct scc_priv *priv = dev->priv;
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __scc_send_packet(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
 
 static struct net_device_stats *scc_get_stats(struct net_device *dev)
 {
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index ae9629f..8d6b1c7 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -399,7 +399,7 @@ void hdlcdrv_arbitrate(struct net_device *dev, struct hdlcdrv_state *s)
  * ===================== network driver interface =========================
  */
 
-static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct hdlcdrv_state *sm = netdev_priv(dev);
 
@@ -415,6 +415,18 @@ static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int hdlcdrv_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hdlcdrv_state *sm = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&sm->tx_lock);
+	ret = __hdlcdrv_send_packet(skb, dev);
+	spin_unlock(&sm->tx_lock);
+
+	return ret;
+}
+
 /* --------------------------------------------------------------------- */
 
 static int hdlcdrv_set_mac_address(struct net_device *dev, void *addr)
@@ -717,6 +729,7 @@ struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
 	 * initialize part of the hdlcdrv_state struct
 	 */
 	s = netdev_priv(dev);
+	spin_lock_init(&s->tx_lock);
 	s->magic = HDLCDRV_MAGIC;
 	s->ops = ops;
 	dev->base_addr = baseaddr;
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index b8740e6..53d92c9 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -50,6 +50,7 @@
 struct mkiss {
 	struct tty_struct	*tty;	/* ptr to TTY structure		*/
 	struct net_device	*dev;	/* easy for intr handling	*/
+	spinlock_t		tx_lock;
 
 	/* These are pointers to the malloc()ed frame buffers. */
 	spinlock_t		buflock;/* lock for rbuf and xbuf */
@@ -528,7 +529,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 }
 
 /* Encapsulate an AX.25 packet and kick it into a TTY queue. */
-static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ax_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mkiss *ax = netdev_priv(dev);
 
@@ -566,6 +567,18 @@ static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ax_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mkiss *ax = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ax->tx_lock);
+	ret = __ax_xmit(skb, dev);
+	spin_unlock(&ax->tx_lock);
+
+	return ret;
+}
+
 static int ax_open_dev(struct net_device *dev)
 {
 	struct mkiss *ax = netdev_priv(dev);
@@ -641,6 +654,7 @@ static int ax_open(struct net_device *dev)
 	ax->flags   &= (1 << AXF_INUSE);      /* Clear ESCAPE & ERROR flags */
 
 	spin_lock_init(&ax->buflock);
+	spin_lock_init(&ax->tx_lock);
 
 	return 0;
 
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 45ae9d1..0616595 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1521,6 +1521,7 @@ static int scc_net_alloc(const char *name, struct scc_channel *scc)
 	dev->priv = scc;
 	scc->dev = dev;
 	spin_lock_init(&scc->lock);
+	spin_lock_init(&scc->tx_lock);
 	init_timer(&scc->tx_t);
 	init_timer(&scc->tx_wdog);
 
@@ -1633,7 +1634,7 @@ static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb)
 
 /* ----> transmit frame <---- */
 
-static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
+static int __scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct scc_channel *scc = (struct scc_channel *) dev->priv;
 	unsigned long flags;
@@ -1686,6 +1687,18 @@ static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int scc_net_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct scc_channel *scc = (struct scc_channel *) dev->priv;
+	int ret;
+
+	spin_lock(&scc->tx_lock);
+	ret = __scc_net_tx(skb, dev);
+	spin_unlock(&scc->tx_lock);
+
+	return ret;
+}
+
 /* ----> ioctl functions <---- */
 
 /*
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 1c94286..ffbcb73 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -132,6 +132,7 @@ struct yam_port {
 
 	/* Tx section */
 
+	spinlock_t tx_lock;
 	int tx_state;
 	int tx_count;
 	int slotcnt;
@@ -553,8 +554,10 @@ static int yam_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
 
+	spin_lock(&yp->tx_lock);
 	skb_queue_tail(&yp->send_queue, skb);
 	dev->trans_start = jiffies;
+	spin_unlock(&yp->tx_lock);
 	return 0;
 }
 
@@ -1073,6 +1076,7 @@ static void yam_setup(struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
 
+	spin_lock_init(&yp->tx_lock);
 	yp->magic = YAM_MAGIC;
 	yp->bitrate = DEFAULT_BITRATE;
 	yp->baudrate = DEFAULT_BITRATE * 2;
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 571dd80..5127454 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -150,6 +150,7 @@
 
 struct hp100_private {
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	char id[HP100_SIG_LEN];
 	u_short chip;
 	u_short soft_model;
@@ -636,6 +637,7 @@ static int __devinit hp100_probe1(struct net_device *dev, int ioaddr,
 	lp = netdev_priv(dev);
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	strlcpy(lp->id, eid, HP100_SIG_LEN);
 	lp->chip = chip;
 	lp->mode = local_mode;
@@ -1467,7 +1469,7 @@ static int hp100_check_lan(struct net_device *dev)
  */
 
 /* tx function for busmaster mode */
-static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
+static int __hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	int i, ok_flag;
@@ -1577,6 +1579,17 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hp100_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __hp100_start_xmit_bm(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 /* clean_txring checks if packets have been sent by the card by reading
  * the TX_PDL register from the performance page and comparing it to the
@@ -1620,7 +1633,7 @@ static void hp100_clean_txring(struct net_device *dev)
 }
 
 /* tx function for slave modes */
-static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	int i, ok_flag;
@@ -1745,6 +1758,17 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hp100_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __hp100_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
 
 /*
  * Receive Function (Non-Busmaster mode)
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 03fcd30..302cc81 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1315,7 +1315,7 @@ static inline int emac_xmit_finish(struct emac_instance *dev, int len)
 }
 
 /* Tx lock BH */
-static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct emac_instance *dev = netdev_priv(ndev);
 	unsigned int len = skb->len;
@@ -1343,6 +1343,18 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return emac_xmit_finish(dev, len);
 }
 
+static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct emac_instance *dev = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&dev->tx_lock);
+	ret = __emac_start_xmit(skb, ndev);
+	spin_unlock(&dev->tx_lock);
+
+	return ret;
+}
+
 static inline int emac_xmit_split(struct emac_instance *dev, int slot,
 				  u32 pd, int len, int last, u16 base_ctrl)
 {
@@ -1373,7 +1385,7 @@ static inline int emac_xmit_split(struct emac_instance *dev, int slot,
 }
 
 /* Tx lock BH disabled (SG version for TAH equipped EMACs) */
-static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
+static int __emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct emac_instance *dev = netdev_priv(ndev);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
@@ -1456,6 +1468,18 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 	return 1;
 }
 
+static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct emac_instance *dev = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&dev->tx_lock);
+	ret = __emac_start_xmit_sg(skb, ndev);
+	spin_unlock(&dev->tx_lock);
+
+	return ret;
+}
+
 /* Tx lock BHs */
 static void emac_parse_tx_error(struct emac_instance *dev, u16 ctrl)
 {
@@ -2653,6 +2677,7 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	mutex_init(&dev->mdio_lock);
 	mutex_init(&dev->link_lock);
 	spin_lock_init(&dev->lock);
+	spin_lock_init(&dev->tx_lock);
 	INIT_WORK(&dev->reset_work, emac_reset_work);
 
 	/* Init various config data based on device-tree */
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 1683db9..39670b1 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -266,6 +266,7 @@ struct emac_instance {
 	int				opened;
 	struct work_struct		reset_work;
 	spinlock_t			lock;
+	spinlock_t			tx_lock;
 };
 
 /*
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 95e3464..97d87f8 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -813,7 +813,7 @@ static int ibmlana_close(struct net_device *dev)
 
 /* transmit a block. */
 
-static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
+static int __ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	ibmlana_priv *priv = netdev_priv(dev);
 	int retval = 0, tmplen, addr;
@@ -878,6 +878,18 @@ tx_done:
 	return retval;
 }
 
+static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	ibmlana_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __ibmlana_tx(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /* switch receiver mode. */
 
 static void ibmlana_set_multicast_list(struct net_device *dev)
@@ -955,6 +967,7 @@ static int __devinit ibmlana_init_one(struct device *kdev)
 	priv->realirq = mca_device_transform_irq(mdev, irq);
 	priv->medium = medium;
 	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->tx_lock);
 
 	/* set base + irq for this device (irq not allocated so far) */
 
diff --git a/drivers/net/ibmlana.h b/drivers/net/ibmlana.h
index aa3ddbd..59ae62b 100644
--- a/drivers/net/ibmlana.h
+++ b/drivers/net/ibmlana.h
@@ -38,6 +38,7 @@ typedef struct {
 		txused[TXBUFCNT];	/* busy flags                       */
 	void __iomem *base;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 } ibmlana_priv;
 
 /* this card uses quite a lot of I/O ports...luckily the MCA bus decodes
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index af233b5..9628210 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -55,6 +55,7 @@ struct ifb_private {
 	unsigned long   st_rxq_rsch;
 	struct sk_buff_head     rq;
 	struct sk_buff_head     tq;
+	spinlock_t tx_lock;
 };
 
 static int numifbs = 2;
@@ -138,6 +139,10 @@ resched:
 
 static void ifb_setup(struct net_device *dev)
 {
+	struct ifb_private *dp = netdev_priv(dev);
+
+	spin_lock_init(&dp->tx_lock);
+
 	/* Initialize the device structure. */
 	dev->hard_start_xmit = ifb_xmit;
 	dev->open = &ifb_open;
@@ -153,7 +158,7 @@ static void ifb_setup(struct net_device *dev)
 	random_ether_addr(dev->dev_addr);
 }
 
-static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
@@ -183,6 +188,18 @@ static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ifb_private *dp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&dp->tx_lock);
+	ret = __ifb_xmit(skb, dev);
+	spin_unlock(&dp->tx_lock);
+
+	return ret;
+}
+
 static int ifb_close(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 679a082..282765a 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1867,7 +1867,8 @@ static int ipg_nic_stop(struct net_device *dev)
 	return 0;
 }
 
-static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ipg_nic_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
@@ -1977,6 +1978,18 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&sp->tx_lock);
+	ret = __ipg_nic_hard_start_xmit(skb, dev);
+	spin_unlock(&sp->tx_lock);
+
+	return ret;
+}
+
 static void ipg_set_phy_default_param(unsigned char rev,
 				      struct net_device *dev, int phy_address)
 {
@@ -2238,6 +2251,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 
 	sp = netdev_priv(dev);
 	spin_lock_init(&sp->lock);
+	spin_lock_init(&sp->tx_lock);
 	mutex_init(&sp->mii_mutex);
 
 	/* Declare IPG NIC functions for Ethernet device methods.
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index cda5388..ea32467 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -794,6 +794,7 @@ struct ipg_nic_private {
 	struct net_device *dev;
 	struct net_device_stats stats;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int tenmbpsmode;
 
 	u16 led_mode;
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 083b0dd..cee8594 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -295,6 +295,7 @@ static int ali_ircc_open(int i, chipio_t *info)
 	self = dev->priv;
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
+	spin_lock_init(&self->tx_lock);
    
 	/* Need to store self somewhere */
 	dev_self[i] = self;
@@ -1426,7 +1427,8 @@ static int ali_ircc_net_close(struct net_device *dev)
  *    Transmit the frame
  *
  */
-static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ali_ircc_fir_hard_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct ali_ircc_cb *self;
 	unsigned long flags;
@@ -1571,6 +1573,17 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;	
 }
 
+static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ali_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __ali_ircc_fir_hard_xmit(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
 
 static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 {
@@ -1949,7 +1962,8 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
  *    Transmit the frame!
  *
  */
-static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ali_ircc_sir_hard_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct ali_ircc_cb *self;
 	unsigned long flags;
@@ -2010,6 +2024,17 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;	
 }
 
+static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ali_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __ali_ircc_sir_hard_xmit(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
 
 /*
  * Function ali_ircc_net_ioctl (dev, rq, cmd)
diff --git a/drivers/net/irda/ali-ircc.h b/drivers/net/irda/ali-ircc.h
index 0787657..b411185 100644
--- a/drivers/net/irda/ali-ircc.h
+++ b/drivers/net/irda/ali-ircc.h
@@ -214,6 +214,7 @@ struct ali_ircc_cb {
 	struct timeval now;
 
 	spinlock_t lock;           /* For serializing operations */
+	spinlock_t tx_lock;
 	
 	__u32 new_speed;
 	int index;                 /* Instance index */
diff --git a/drivers/net/irda/au1000_ircc.h b/drivers/net/irda/au1000_ircc.h
index 7a31d46..7cf96a2 100644
--- a/drivers/net/irda/au1000_ircc.h
+++ b/drivers/net/irda/au1000_ircc.h
@@ -122,6 +122,7 @@ struct au1k_private {
 	struct timer_list timer;
 
 	spinlock_t lock;           /* For serializing operations */
+	spinlock_t tx_lock;
         struct pm_dev *dev;
 };
 #endif /* AU1000_IRCC_H */
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index a1e4508..910d977 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -206,6 +206,8 @@ static int au1k_irda_net_init(struct net_device *dev)
 	db_dest_t *pDB, *pDBfree;
 	dma_addr_t temp;
 
+	spin_lock_init(&aup->tx_lock);
+
 	err = au1k_irda_init_iobuf(&aup->rx_buff, 14384);
 	if (err)
 		goto out1;
@@ -476,7 +478,7 @@ static void au1k_tx_ack(struct net_device *dev)
 /*
  * Au1000 transmit routine.
  */
-static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1k_private *aup = netdev_priv(dev);
 	int speed = irda_get_next_speed(skb);
@@ -552,6 +554,17 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct au1k_private *aup = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&aup->tx_lock);
+	ret = __au1k_irda_hard_xmit(skb, dev);
+	spin_unlock(&aup->tx_lock);
+
+	return ret;
+}
 
 static inline void 
 update_rx_stats(struct net_device *dev, u32 status, u32 count)
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 34ad189..faeefca 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -970,8 +970,7 @@ toshoboe_probe (struct toshoboe_cb *self)
 /* Netdev style code */
 
 /* Transmit something */
-static int
-toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
+static int __toshoboe_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
   struct toshoboe_cb *self;
   __s32 speed;
@@ -1146,6 +1145,18 @@ dumpbufs(skb->data,skb->len,'>');
   return 0;
 }
 
+static int toshoboe_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+  struct toshoboe_cb *self = netdev_priv(dev);
+  int ret;
+
+  spin_lock(&self->tx_lock);
+  ret = __toshoboe_hard_xmit(skb, dev);
+  spin_unlock(&self->tx_lock);
+
+  return ret;
+}
+
 /*interrupt handler */
 static irqreturn_t
 toshoboe_interrupt (int irq, void *dev_id)
@@ -1569,6 +1580,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
     }
 
   spin_lock_init(&self->spinlock);
+  spin_lock_init(&self->tx_lock);
 
   irda_init_max_qos_capabilies (&self->qos);
   self->qos.baud_rate.bits = 0;
diff --git a/drivers/net/irda/donauboe.h b/drivers/net/irda/donauboe.h
index 1e67720..f4bbb68 100644
--- a/drivers/net/irda/donauboe.h
+++ b/drivers/net/irda/donauboe.h
@@ -351,6 +351,7 @@ struct toshoboe_cb
  *		spin_unlock_irqrestore(&self->spinlock, flags);
  */
   spinlock_t spinlock;		
+  spinlock_t tx_lock;
   /* Used for the probe and diagnostics code */
   int int_rx;
   int int_tx;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 6f50ed7..7322c64 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -382,7 +382,8 @@ static void speed_bulk_callback(struct urb *urb)
 /*
  * Send an IrDA frame to the USB dongle (for transmission)
  */
-static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __irda_usb_hard_xmit(struct sk_buff *skb,
+				struct net_device *netdev)
 {
 	struct irda_usb_cb *self = netdev->priv;
 	struct urb *urb = self->tx_urb;
@@ -546,6 +547,18 @@ drop:
 	return err;		/* Usually 1 */
 }
 
+static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct irda_usb_cb *self = netdev->priv;
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __irda_usb_hard_xmit(skb, netdev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 /*------------------------------------------------------------------*/
 /*
  * Note : this function will be called only for tx_urb...
@@ -1644,6 +1657,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 	self = net->priv;
 	self->netdev = net;
 	spin_lock_init(&self->lock);
+	spin_lock_init(&self->tx_lock);
 	init_timer(&self->rx_defer_timer);
 
 	self->capability = id->driver_info;
diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index a0ca9c1..eab2e89 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -162,6 +162,7 @@ struct irda_usb_cb {
 	struct timeval now;
 
 	spinlock_t lock;		/* For serializing Tx operations */
+	spinlock_t tx_lock;
 
 	__u16 xbofs;			/* Current xbofs setting */
 	__s16 new_xbofs;		/* xbofs we need to set */
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index 648e54b..1d92974 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -118,6 +118,7 @@ struct kingsun_cb {
 	iobuff_t  	  rx_buff;	/* receive unwrap state machine */
 	struct timeval	  rx_time;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int receiving;
 
 	__u8 ep_in;
@@ -150,7 +151,7 @@ static void kingsun_send_irq(struct urb *urb)
 /*
  * Called from net/core when new frame is available.
  */
-static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct kingsun_cb *kingsun;
 	int wraplen;
@@ -200,6 +201,18 @@ static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return ret;
 }
 
+static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct kingsun_cb *kingsun = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&kingsun->tx_lock);
+	ret = __kingsun_hard_xmit(skb, netdev);
+	spin_unlock(&kingsun->tx_lock);
+
+	return ret;
+}
+
 /* Receive callback function */
 static void kingsun_rcv_irq(struct urb *urb)
 {
@@ -505,6 +518,7 @@ static int kingsun_probe(struct usb_interface *intf,
 	kingsun->rx_buff.skb = NULL;
 	kingsun->receiving = 0;
 	spin_lock_init(&kingsun->lock);
+	spin_lock_init(&kingsun->tx_lock);
 
 	/* Allocate input buffer */
 	kingsun->in_buf = kmalloc(kingsun->max_rx, GFP_KERNEL);
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index 8c257a5..9bced1c 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -198,6 +198,7 @@ struct ks959_cb {
 	unsigned int new_speed;
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int receiving;
 };
 
@@ -386,7 +387,7 @@ static void ks959_send_irq(struct urb *urb)
 /*
  * Called from net/core when new frame is available.
  */
-static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ks959_cb *kingsun;
 	unsigned int wraplen;
@@ -432,6 +433,18 @@ static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return ret;
 }
 
+static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct ks959_cb *kingsun = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&kingsun->tx_lock);
+	ret = __ks959_hard_xmit(skb, netdev);
+	spin_unlock(&kingsun->tx_lock);
+
+	return ret;
+}
+
 /* Receive callback function */
 static void ks959_rcv_irq(struct urb *urb)
 {
@@ -718,6 +731,7 @@ static int ks959_probe(struct usb_interface *intf,
 	kingsun->rx_unwrap_buff.skb = NULL;
 	kingsun->receiving = 0;
 	spin_lock_init(&kingsun->lock);
+	spin_lock_init(&kingsun->tx_lock);
 
 	kingsun->speed_setuprequest = NULL;
 	kingsun->speed_urb = NULL;
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index d01a285..c1d38cb 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -163,6 +163,7 @@ struct ksdazzle_cb {
 	__u8 ep_out;
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int receiving;
 };
 
@@ -299,7 +300,8 @@ static void ksdazzle_send_irq(struct urb *urb)
 /*
  * Called from net/core when new frame is available.
  */
-static int ksdazzle_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __ksdazzle_hard_xmit(struct sk_buff *skb,
+				struct net_device *netdev)
 {
 	struct ksdazzle_cb *kingsun;
 	unsigned int wraplen;
@@ -345,6 +347,18 @@ static int ksdazzle_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return ret;
 }
 
+static int ksdazzle_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct ksdazzle_cb *kingsun = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&kingsun->tx_lock);
+	ret = __ksdazzle_hard_xmit(skb, netdev);
+	spin_unlock(&kingsun->tx_lock);
+
+	return ret;
+}
+
 /* Receive callback function */
 static void ksdazzle_rcv_irq(struct urb *urb)
 {
@@ -649,6 +663,7 @@ static int ksdazzle_probe(struct usb_interface *intf,
 	kingsun->rx_unwrap_buff.skb = NULL;
 	kingsun->receiving = 0;
 	spin_lock_init(&kingsun->lock);
+	spin_lock_init(&kingsun->tx_lock);
 
 	kingsun->speed_setuprequest = NULL;
 	kingsun->speed_urb = NULL;
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index ad92d3f..6e6d863 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -826,7 +826,7 @@ static void mcs_send_irq(struct urb *urb)
 }
 
 /* Transmit callback funtion.  */
-static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	unsigned long flags;
 	struct mcs_cb *mcs;
@@ -882,6 +882,18 @@ static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return ret;
 }
 
+static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct mcs_cb *mcs = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&mcs->tx_lock);
+	ret = __mcs_hard_xmit(skb, ndev);
+	spin_unlock(&mcs->tx_lock);
+
+	return ret;
+}
+
 /*
  * This function is called by the USB subsystem for each new device in the
  * system.  Need to verify the device and if it is, then start handling it.
@@ -912,6 +924,7 @@ static int mcs_probe(struct usb_interface *intf,
 	mcs->usbdev = udev;
 	mcs->netdev = ndev;
 	spin_lock_init(&mcs->lock);
+	spin_lock_init(&mcs->tx_lock);
 
 	/* Initialize QoS for this device */
 	irda_init_max_qos_capabilies(&mcs->qos);
diff --git a/drivers/net/irda/mcs7780.h b/drivers/net/irda/mcs7780.h
index b18148c..c5b2700 100644
--- a/drivers/net/irda/mcs7780.h
+++ b/drivers/net/irda/mcs7780.h
@@ -119,6 +119,7 @@ struct mcs_cb {
 	iobuff_t rx_buff;	/* receive unwrap state machine */
 	struct timeval rx_time;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int receiving;
 
 	__u8 ep_in;
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index a7714da..c3c4767 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -375,6 +375,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 	self = dev->priv;
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
+	spin_lock_init(&self->tx_lock);
    
 	/* Need to store self somewhere */
 	dev_self[chip_index] = self;
@@ -1342,7 +1343,8 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
  *    Transmit the frame!
  *
  */
-static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+static int __nsc_ircc_hard_xmit_sir(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct nsc_ircc_cb *self;
 	unsigned long flags;
@@ -1414,7 +1416,20 @@ static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
+static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nsc_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __nsc_ircc_hard_xmit_sir(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
+static int __nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct nsc_ircc_cb *self;
 	unsigned long flags;
@@ -1544,6 +1559,18 @@ static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nsc_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __nsc_ircc_hard_xmit_fir(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 /*
  * Function nsc_ircc_dma_xmit (self, iobase)
  *
diff --git a/drivers/net/irda/nsc-ircc.h b/drivers/net/irda/nsc-ircc.h
index 29398a4..4ebb7b7 100644
--- a/drivers/net/irda/nsc-ircc.h
+++ b/drivers/net/irda/nsc-ircc.h
@@ -265,6 +265,7 @@ struct nsc_ircc_cb {
 	struct timeval now;
 
 	spinlock_t lock;           /* For serializing operations */
+	spinlock_t tx_lock;
 	
 	__u32 new_speed;
 	int index;                 /* Instance index */
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index d5c2d27..a12e897 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -68,6 +68,7 @@
                 IrSR_XMITIR_IR_MODE)
 
 struct pxa_irda {
+	spinlock_t		tx_lock;
 	int			speed;
 	int			newspeed;
 	unsigned long		last_oscr;
@@ -467,7 +468,7 @@ static irqreturn_t pxa_irda_fir_irq(int irq, void *dev_id)
 }
 
 /* hard_xmit interface of irda device */
-static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct pxa_irda *si = netdev_priv(dev);
 	int speed = irda_get_next_speed(skb);
@@ -527,6 +528,18 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct pxa_irda *si = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&si->tx_lock);
+	ret = __pxa_irda_hard_xmit(skb, dev);
+	spin_unlock(&si->tx_lock);
+
+	return ret;
+}
+
 static int pxa_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 {
 	struct if_irda_req *rq = (struct if_irda_req *)ifreq;
@@ -812,6 +825,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
 		goto err_mem_3;
 
 	si = netdev_priv(dev);
+	spin_lock_init(&si->tx_lock);
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 1bc8518..8709b18 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -45,6 +45,7 @@ static int tx_lpm;
 static int max_rate = 4000000;
 
 struct sa1100_irda {
+	spinlock_t		tx_lock;
 	unsigned char		hscr0;
 	unsigned char		utcr4;
 	unsigned char		power;
@@ -647,7 +648,7 @@ static void sa1100_irda_txdma_irq(void *id)
 	netif_wake_queue(dev);
 }
 
-static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sa1100_irda *si = dev->priv;
 	int speed = irda_get_next_speed(skb);
@@ -720,6 +721,18 @@ static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sa1100_irda *si = dev->priv;
+	int ret;
+
+	spin_lock(&si->tx_lock);
+	ret = __sa1100_irda_hard_xmit(skb, dev);
+	spin_unlock(&si->tx_lock);
+
+	return ret;
+}
+
 static int
 sa1100_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 {
@@ -909,6 +922,7 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 		goto err_mem_4;
 
 	si = dev->priv;
+	spin_lock_init(&si->tx_lock);
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
diff --git a/drivers/net/irda/sir-dev.h b/drivers/net/irda/sir-dev.h
index 2a57bc6..45ee52d 100644
--- a/drivers/net/irda/sir-dev.h
+++ b/drivers/net/irda/sir-dev.h
@@ -172,6 +172,7 @@ struct sir_dev {
 	atomic_t enable_rx;
 	int raw_tx;
 	spinlock_t tx_lock;
+	spinlock_t tx_lock2;
 
 	u32 new_speed;
  	u32 flags;
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 6078e03..9d8ce3c 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -588,7 +588,7 @@ static struct net_device_stats *sirdev_get_stats(struct net_device *ndev)
 	return (dev) ? &dev->stats : NULL;
 }
 
-static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct sir_dev *dev = ndev->priv;
 	unsigned long flags;
@@ -677,6 +677,18 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
+static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct sir_dev *dev = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&dev->tx_lock2);
+	ret = __sirdev_hard_xmit(skb, ndev);
+	spin_unlock(&dev->tx_lock2);
+
+	return ret;
+}
+
 /* called from network layer with rtnl hold */
 
 static int sirdev_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
@@ -908,6 +920,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	dev->tx_skb = NULL;
 
 	spin_lock_init(&dev->tx_lock);
+	spin_lock_init(&dev->tx_lock2);
 	init_MUTEX(&dev->fsm.sem);
 
 	dev->drv = drv;
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 78dc8e7..bbe6cac 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -162,6 +162,7 @@ struct smsc_ircc_cb {
 	struct qos_info qos;       /* QoS capabilities for this device */
 
 	spinlock_t lock;           /* For serializing operations */
+	spinlock_t tx_lock;
 
 	__u32 new_speed;
 	__u32 flags;               /* Interface flags */
@@ -541,6 +542,7 @@ static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u
 	/* Need to store self somewhere */
 	dev_self[dev_count] = self;
 	spin_lock_init(&self->lock);
+	spin_lock_init(&self->tx_lock);
 
 	self->rx_buff.truesize = SMSC_IRCC2_RX_BUFF_TRUESIZE;
 	self->tx_buff.truesize = SMSC_IRCC2_TX_BUFF_TRUESIZE;
@@ -872,7 +874,8 @@ static void smsc_ircc_timeout(struct net_device *dev)
  *    waits until the next transmit interrupt, and continues until the
  *    frame is transmitted.
  */
-int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+static int __smsc_ircc_hard_xmit_sir(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 	unsigned long flags;
@@ -932,6 +935,18 @@ int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smsc_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __smsc_ircc_hard_xmit_sir(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 /*
  * Function smsc_ircc_set_fir_speed (self, baud)
  *
@@ -1180,7 +1195,8 @@ void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
  *    Transmit the frame!
  *
  */
-static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
+static int __smsc_ircc_hard_xmit_fir(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 	unsigned long flags;
@@ -1242,6 +1258,18 @@ static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smsc_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __smsc_ircc_hard_xmit_fir(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 /*
  * Function smsc_ircc_dma_xmit (self, bofs)
  *
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 0519637..aa786e9 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -167,6 +167,7 @@ struct stir_cb {
         struct net_device_stats stats;	/* network statistics */
         struct qos_info   qos;
 	unsigned 	  speed;	/* Current speed */
+	spinlock_t        tx_lock;
 
         struct task_struct *thread;     /* transmit thread */
 
@@ -560,7 +561,7 @@ static int change_speed(struct stir_cb *stir, unsigned speed)
 /*
  * Called from net/core when new frame is available.
  */
-static int stir_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __stir_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct stir_cb *stir = netdev_priv(netdev);
 
@@ -581,6 +582,18 @@ static int stir_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return 0;
 }
 
+static int stir_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct stir_cb *stir = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&stir->tx_lock);
+	ret = __stir_hard_xmit(skb, netdev);
+	spin_unlock(&stir->tx_lock);
+
+	return ret;
+}
+
 /*
  * Wait for the transmit FIFO to have space for next data
  *
@@ -1038,6 +1051,7 @@ static int stir_probe(struct usb_interface *intf,
 
 	SET_NETDEV_DEV(net, &intf->dev);
 	stir = netdev_priv(net);
+	spin_lock_init(&stir->tx_lock);
 	stir->netdev = net;
 	stir->usbdev = dev;
 
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 58e1287..d884422 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -337,6 +337,7 @@ static __devinit int via_ircc_open(int i, chipio_t * info, unsigned int id)
 	self = dev->priv;
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
+	spin_lock_init(&self->tx_lock);
 
 	/* FIXME : We should store our driver instance in the PCI layer,
 	 * using pci_set_drvdata(), not in this array.
@@ -816,8 +817,8 @@ static void via_ircc_change_speed(struct via_ircc_cb *self, __u32 speed)
  *    Transmit the frame!
  *
  */
-static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
-				  struct net_device *dev)
+static int __via_ircc_hard_xmit_sir(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct via_ircc_cb *self;
 	unsigned long flags;
@@ -888,9 +889,22 @@ static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 	return 0;
 }
 
-static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
+static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 				  struct net_device *dev)
 {
+	struct via_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __via_ircc_hard_xmit_sir(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
+static int __via_ircc_hard_xmit_fir(struct sk_buff *skb,
+				    struct net_device *dev)
+{
 	struct via_ircc_cb *self;
 	u16 iobase;
 	__u32 speed;
@@ -937,6 +951,19 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 
 }
 
+static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
+				  struct net_device *dev)
+{
+	struct via_ircc_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __via_ircc_hard_xmit_fir(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase)
 {
 	EnTXDMA(iobase, OFF);
diff --git a/drivers/net/irda/via-ircc.h b/drivers/net/irda/via-ircc.h
index 9d012f0..13b91af 100644
--- a/drivers/net/irda/via-ircc.h
+++ b/drivers/net/irda/via-ircc.h
@@ -112,6 +112,7 @@ struct via_ircc_cb {
 	struct timeval now;
 
 	spinlock_t lock;	/* For serializing operations */
+	spinlock_t tx_lock;
 
 	__u32 flags;		/* Interface flags */
 	__u32 new_speed;
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index d15e00b..b9d285a 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -854,7 +854,8 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 	return ret;
 }
 
-static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __vlsi_hard_start_xmit(struct sk_buff *skb,
+				  struct net_device *ndev)
 {
 	vlsi_irda_dev_t *idev = ndev->priv;
 	struct vlsi_ring	*r = idev->tx_ring;
@@ -1061,6 +1062,18 @@ drop:
 	return 0;
 }
 
+static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&idev->tx_lock);
+	ret = __vlsi_hard_start_xmit(skb, ndev);
+	spin_unlock(&idev->tx_lock);
+
+	return ret;
+}
+
 static void vlsi_tx_interrupt(struct net_device *ndev)
 {
 	vlsi_irda_dev_t *idev = ndev->priv;
@@ -1659,6 +1672,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	idev = ndev->priv;
 
 	spin_lock_init(&idev->lock);
+	spin_lock_init(&idev->tx_lock);
 	mutex_init(&idev->mtx);
 	mutex_lock(&idev->mtx);
 	idev->pdev = pdev;
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index c8b9c74..c534f8c 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -728,6 +728,7 @@ typedef struct vlsi_irda_dev {
 	struct timeval		last_rx;
 
 	spinlock_t		lock;
+	spinlock_t		tx_lock;
 	struct mutex		mtx;
 
 	u8			resume_ok;	
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 9fd2451..c9c3acb 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -180,6 +180,7 @@ int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 
 	self = dev->priv;
 	spin_lock_init(&self->lock);
+	spin_lock_init(&self->tx_lock);
    
 
 	/* Initialize IO */
@@ -489,7 +490,7 @@ void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
  *    Sets up a DMA transfer to send the current frame.
  *
  */
-int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct w83977af_ir *self;
 	__s32 speed;
@@ -578,6 +579,18 @@ int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct w83977af_ir *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __w83977af_hard_xmit(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 /*
  * Function w83977af_dma_write (self, iobase)
  *
diff --git a/drivers/net/irda/w83977af_ir.h b/drivers/net/irda/w83977af_ir.h
index 87c3975..f886dea 100644
--- a/drivers/net/irda/w83977af_ir.h
+++ b/drivers/net/irda/w83977af_ir.h
@@ -187,6 +187,7 @@ struct w83977af_ir {
 	 * will get you started. Check in nsc-ircc.c for a proper
 	 * locking strategy. - Jean II */
 	spinlock_t lock;           /* For serializing operations */
+	spinlock_t tx_lock;
 	
 	__u32 new_speed;
 };
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index d6ff26a..9606de5 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -95,6 +95,7 @@ struct net_local {
 	 * by this lock as well.
 	 */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 /* The station (ethernet) address prefix, used for IDing the board. */
@@ -303,6 +304,7 @@ static int __init netcard_probe1(struct net_device *dev, int ioaddr)
 
 	np = netdev_priv(dev);
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
@@ -403,7 +405,7 @@ net_open(struct net_device *dev)
  * invariant will hold if you make sure that the netif_*_queue()
  * calls are done at the proper times.
  */
-static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *np = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
@@ -465,6 +467,18 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __net_send_packet(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
 #if TX_RING
 /* This handles TX complete events posted by the device
  * via interrupts.
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index b8d0639..7735a3a 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -198,6 +198,7 @@ struct veth_port {
 	struct device *dev;
 	u64 mac_addr;
 	HvLpIndexMap lpar_map;
+	spinlock_t tx_lock;
 
 	/* queue_lock protects the stopped_map and dev's queue. */
 	spinlock_t queue_lock;
@@ -1047,6 +1048,7 @@ static struct net_device *veth_probe_one(int vlan,
 	port = (struct veth_port *) dev->priv;
 
 	spin_lock_init(&port->queue_lock);
+	spin_lock_init(&port->tx_lock);
 	rwlock_init(&port->mcast_gate);
 	port->stopped_map = 0;
 
@@ -1188,7 +1190,7 @@ static void veth_transmit_to_many(struct sk_buff *skb,
 	}
 }
 
-static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned char *frame = skb->data;
 	struct veth_port *port = (struct veth_port *) dev->priv;
@@ -1215,6 +1217,18 @@ static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct veth_port *port = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&port->tx_lock);
+	ret = __veth_start_xmit(skb, dev);
+	spin_unlock(&port->tx_lock);
+
+	return ret;
+}
+
 /* You must hold the connection's lock when you call this function. */
 static void veth_recycle_msg(struct veth_lpar_connection *cnx,
 			     struct veth_msg *msg)
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d981134..1afbce4 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -233,6 +233,7 @@ struct ixgbe_adapter {
 	u16 eitr_high;
 
 	/* TX */
+	spinlock_t tx_lock;
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
 	u64 restart_queue;
 	u64 lsc_int;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0d37c90..74971c4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3229,7 +3229,7 @@ static int ixgbe_maybe_stop_tx(struct net_device *netdev,
 }
 
 
-static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static int __ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
@@ -3299,6 +3299,18 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&adapter->tx_lock);
+	ret = __ixgbe_xmit_frame(skb, netdev);
+	spin_unlock(&adapter->tx_lock);
+
+	return ret;
+}
+
 /**
  * ixgbe_get_stats - Get System Network Statistics
  * @netdev: network interface device structure
@@ -3448,6 +3460,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
 
+	spin_lock_init(&adapter->tx_lock);
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 7111c65..dc2647c 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -37,7 +37,7 @@ static struct ixpdev_tx_desc * const tx_desc =
 static int tx_pointer;
 
 
-static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ixpdev_priv *ip = netdev_priv(dev);
 	struct ixpdev_tx_desc *desc;
@@ -73,6 +73,17 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ixpdev_priv *ip = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ip->tx_lock);
+	ret = __ixpdev_xmit(skb, dev);
+	spin_unlock(&ip->tx_lock);
+
+	return ret;
+}
 
 static int ixpdev_rx(struct net_device *dev, int processed, int budget)
 {
@@ -292,6 +303,7 @@ struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 
 	ip = netdev_priv(dev);
+	spin_lock_init(&ip->tx_lock);
 	ip->dev = dev;
 	netif_napi_add(dev, &ip->napi, ixpdev_poll, 64);
 	ip->channel = channel;
diff --git a/drivers/net/ixp2000/ixpdev.h b/drivers/net/ixp2000/ixpdev.h
index 391ece6..fa1369e 100644
--- a/drivers/net/ixp2000/ixpdev.h
+++ b/drivers/net/ixp2000/ixpdev.h
@@ -16,6 +16,7 @@ struct ixpdev_priv
 {
 	struct net_device *dev;
 	struct napi_struct napi;
+	spinlock_t tx_lock;
 	int	channel;
 	int	tx_queue_entries;
 };
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index b59f442..29b9230 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -325,6 +325,7 @@ struct i596_private {
 	int next_tx_cmd;
 	int options;
 	spinlock_t lock;       /* serialize access to chip */
+	spinlock_t tx_lock;
 	dma_addr_t dma_addr;
 	void __iomem *mpu_port;
 	void __iomem *ca;
@@ -970,7 +971,7 @@ static void i596_tx_timeout (struct net_device *dev)
 }
 
 
-static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct i596_private *lp = netdev_priv(dev);
 	struct tx_cmd *tx_cmd;
@@ -1032,6 +1033,18 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct i596_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __i596_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void print_eth(unsigned char *add, char *str)
 {
 	DECLARE_MAC_BUF(mac);
@@ -1085,6 +1098,7 @@ static int __devinit i82596_probe(struct net_device *dev)
 	dma->scb.cmd = I596_NULL;
 	dma->scb.rfd = I596_NULL;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	DMA_WBACK_INV(dev, dma, sizeof(struct i596_dma));
 
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 00d59ab..1f74549 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -304,7 +304,7 @@ static void ei_tx_timeout(struct net_device *dev)
  * Sends a packet to an 8390 network device.
  */
 
-static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -422,6 +422,18 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ei_local->tx_lock);
+	ret = __ei_start_xmit(skb, dev);
+	spin_unlock(&ei_local->tx_lock);
+
+	return ret;
+}
+
 /**
  * ei_interrupt - handle the interrupts from an 8390
  * @irq: interrupt number
@@ -1023,6 +1035,7 @@ static void ethdev_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	spin_lock_init(&ei_local->page_lock);
+	spin_lock_init(&ei_local->tx_lock);
 }
 
 /**
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 591a7e4..cedce47 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -351,6 +351,7 @@ struct i596_private {		/* aligned to a 16-byte boundary */
 	int cmd_backlog;
 	unsigned long last_cmd;
 	spinlock_t cmd_lock;
+	spinlock_t tx_lock;
 };
 
 static char init_setup[14] = {
@@ -864,7 +865,8 @@ static int i596_open(struct net_device *dev)
 	return 0;			/* Always succeed */
 }
 
-static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
+static int __i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
 	struct tx_cmd *tx_cmd;
 	short length;
 
@@ -910,6 +912,18 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 	return 0;
 }
 
+static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct i596_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __i596_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void
 i596_tx_timeout (struct net_device *dev) {
 	struct i596_private *lp = dev->priv;
@@ -972,6 +986,7 @@ static int __init lp486e_probe(struct net_device *dev) {
 
 	lp = (struct i596_private *) dev->priv;
 	spin_lock_init(&lp->cmd_lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/*
 	 * Do we really have this thing?
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 4ce8afd..39c2f6c 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -113,6 +113,7 @@ static unsigned int net_debug = NET_DEBUG;
 /* Information that need to be kept for each board. */
 struct net_local {
 	struct net_device_stats stats;
+	spinlock_t tx_lock;
 	int chip_type;		/* one of: CS8900, CS8920, CS8920M */
 	char chip_revision;	/* revision letter of the chip ('A'...) */
 	int send_cmd;		/* the propercommand used to send a packet. */
@@ -230,6 +231,8 @@ struct net_device * __init mac89x0_probe(int unit)
 	/* Initialize the net_device structure. */
 	lp = netdev_priv(dev);
 
+	spin_lock_init(&lp->tx_lock);
+
 	/* Fill in the 'dev' fields. */
 	dev->base_addr = ioaddr;
 	dev->mem_start = (unsigned long)
@@ -371,8 +374,7 @@ net_open(struct net_device *dev)
 	return 0;
 }
 
-static int
-net_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
@@ -412,6 +414,18 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __net_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* The typical workload of the driver:
    Handle the network interface interrupts. */
 static irqreturn_t net_interrupt(int irq, void *dev_id)
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 451acdc..dcbfb80 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -63,6 +63,7 @@ struct mace_data {
     int chipid;
     struct macio_dev *mdev;
     spinlock_t lock;
+    spinlock_t tx_lock;
 };
 
 /*
@@ -191,6 +192,7 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 	       (NCMDS_TX*N_TX_RING + N_RX_RING + 2) * sizeof(struct dbdma_cmd));
 	init_timer(&mp->tx_timeout);
 	spin_lock_init(&mp->lock);
+	spin_lock_init(&mp->tx_lock);
 	mp->timeout_active = 0;
 
 	if (port_aaui >= 0)
@@ -524,7 +526,7 @@ static inline void mace_set_timeout(struct net_device *dev)
     mp->timeout_active = 1;
 }
 
-static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
+static int __mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 {
     struct mace_data *mp = (struct mace_data *) dev->priv;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
@@ -632,6 +634,18 @@ static void mace_set_multicast(struct net_device *dev)
     spin_unlock_irqrestore(&mp->lock, flags);
 }
 
+static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mace_data *mp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&mp->tx_lock);
+	ret = __mace_xmit_start(skb, dev);
+	spin_unlock(&mp->tx_lock);
+
+	return ret;
+}
+
 static void mace_handle_misc_intrs(struct mace_data *mp, int intr, struct net_device *dev)
 {
     volatile struct mace __iomem *mb = mp->mace;
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 51ad376..088af0e 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -69,6 +69,7 @@ struct mace_data {
 	int tx_slot, tx_sloti, tx_count;
 	int chipid;
 	struct device *device;
+	spinlock_t tx_lock;
 };
 
 struct mace_frame {
@@ -207,6 +208,7 @@ static int __devinit mace_probe(struct platform_device *pdev)
 
 	mp = netdev_priv(dev);
 
+	spin_lock_init(&mp->tx_lock);
 	mp->device = &pdev->dev;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -450,7 +452,7 @@ static int mace_close(struct net_device *dev)
  * Transmit a frame
  */
 
-static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
+static int __mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mace_data *mp = netdev_priv(dev);
 	unsigned long flags;
@@ -487,6 +489,18 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mace_data *mp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&mp->tx_lock);
+	ret = __mace_xmit_start(skb, dev);
+	spin_unlock(&mp->tx_lock);
+
+	return ret;
+}
+
 static void mace_set_multicast(struct net_device *dev)
 {
 	struct mace_data *mp = netdev_priv(dev);
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c36a03a..6f72747 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -44,6 +44,7 @@ struct macvlan_dev {
 	struct hlist_node	hlist;
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
+	spinlock_t		tx_lock;
 };
 
 
@@ -142,7 +143,8 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	return NULL;
 }
 
-static int macvlan_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __macvlan_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
@@ -161,6 +163,19 @@ static int macvlan_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int macvlan_hard_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&vlan->tx_lock);
+	ret = __macvlan_hard_start_xmit(skb, dev);
+	spin_unlock(&vlan->tx_lock);
+
+	return ret;
+}
+
 static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 			       unsigned short type, const void *daddr,
 			       const void *saddr, unsigned len)
@@ -431,6 +446,7 @@ static int macvlan_newlink(struct net_device *dev,
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
 	vlan->port     = port;
+	spin_lock_init(&vlan->tx_lock);
 
 	err = register_netdevice(dev);
 	if (err < 0)
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 6d343ef..4b4dcc2 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -132,14 +132,18 @@ static inline void mipsnet_put_todevice(struct net_device *dev,
 	dev_kfree_skb(skb);
 }
 
+static DEFINE_SPINLOCK(mipsnet_tx_lock);
+
 static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	/*
 	 * Only one packet at a time. Once TXDONE interrupt is serviced, the
 	 * queue will be restarted.
 	 */
+	spin_lock(&mipsnet_tx_lock);
 	netif_stop_queue(dev);
 	mipsnet_put_todevice(dev, skb);
+	spin_unlock(&mipsnet_tx_lock);
 
 	return 0;
 }
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 83a877f..afe602c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -334,6 +334,7 @@ struct mv643xx_eth_private {
 	int phy_addr;
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	struct mib_counters mib_counters;
 	struct work_struct tx_timeout_task;
@@ -766,7 +767,7 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	txq->tx_desc_count += nr_frags + 1;
 }
 
-static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
@@ -812,6 +813,17 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&mp->tx_lock);
+	ret = __mv643xx_eth_xmit(skb, dev);
+	spin_unlock(&mp->tx_lock);
+
+	return ret;
+}
 
 /* tx rate control **********************************************************/
 /*
@@ -2439,6 +2451,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	set_params(mp, pd);
 
 	spin_lock_init(&mp->lock);
+	spin_lock_init(&mp->tx_lock);
 
 	mib_counters_clear(mp);
 	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 9a68d2e..275654f 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -173,6 +173,7 @@ struct myri10ge_slice_netstats {
 };
 
 struct myri10ge_slice_state {
+	spinlock_t tx_lock;
 	struct myri10ge_tx_buf tx;	/* transmit ring        */
 	struct myri10ge_rx_buf rx_small;
 	struct myri10ge_rx_buf rx_big;
@@ -2597,7 +2598,7 @@ myri10ge_submit_req_wc(struct myri10ge_tx_buf *tx,
  * it and try again.
  */
 
-static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_slice_state *ss;
@@ -2881,6 +2882,19 @@ drop:
 
 }
 
+static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct myri10ge_priv *mgp = netdev_priv(dev);
+	struct myri10ge_slice_state *ss = mgp->ss;
+	int ret;
+
+	spin_lock(&ss->tx_lock);
+	ret = __myri10ge_xmit(skb, dev);
+	spin_unlock(&ss->tx_lock);
+
+	return ret;
+}
+
 static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *segs, *curr;
@@ -3557,6 +3571,7 @@ static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
 			goto abort;
 		ss->mgp = mgp;
 		ss->dev = mgp->dev;
+		spin_lock_init(&ss->tx_lock);
 		netif_napi_add(ss->dev, &ss->napi, myri10ge_poll,
 			       myri10ge_napi_weight);
 	}
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 656a260..7af704d 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -595,7 +595,7 @@ static void myri_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct myri_eth *mp = (struct myri_eth *) dev->priv;
 	struct sendq __iomem *sq = mp->sq;
@@ -671,6 +671,18 @@ static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct myri_eth *mp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&mp->tx_lock);
+	ret = __myri_start_xmit(skb, dev);
+	spin_unlock(&mp->tx_lock);
+
+	return ret;
+}
+
 /* Create the MyriNet MAC header for an arbitrary protocol layer
  *
  * saddr=NULL	means use device source address
@@ -914,6 +926,7 @@ static int __devinit myri_ether_init(struct sbus_dev *sdev)
 
 	mp = (struct myri_eth *) dev->priv;
 	spin_lock_init(&mp->irq_lock);
+	spin_lock_init(&mp->tx_lock);
 	mp->myri_sdev = sdev;
 
 	/* Clean out skb arrays. */
diff --git a/drivers/net/myri_sbus.h b/drivers/net/myri_sbus.h
index 5d93fcc..cce3270 100644
--- a/drivers/net/myri_sbus.h
+++ b/drivers/net/myri_sbus.h
@@ -270,6 +270,7 @@ struct myri_eth {
 	 * to obtain good cache hit rates.
 	 */
 	spinlock_t			irq_lock;
+	spinlock_t			tx_lock;
 	struct myri_shmem __iomem	*shmem;		/* Shared data structures.    */
 	void __iomem			*cregs;		/* Control register space.    */
 	struct recvq __iomem		*rqack;		/* Where we ack rx's.         */
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index b238ed0..74bb133 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -590,6 +590,7 @@ struct netdev_private {
 	u16 advertising;
 	unsigned int iosize;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	u32 msg_enable;
 	/* EEPROM data */
 	int eeprom_size;
@@ -857,6 +858,7 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	pci_set_drvdata(pdev, dev);
 	np->iosize = iosize;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 	np->msg_enable = (debug >= 0) ? (1<<debug)-1 : NATSEMI_DEF_MSG;
 	np->hands_off = 0;
 	np->intr_status = 0;
@@ -2075,7 +2077,7 @@ static void reinit_ring(struct net_device *dev)
 	reinit_rx(dev);
 }
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static int __start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
@@ -2124,6 +2126,18 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __start_tx(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
 static void netdev_tx_done(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index da4c4fb..966ea5d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -870,6 +870,7 @@ struct netxen_adapter {
 
 	u32 curr_window;
 
+	spinlock_t tx_lock;
 	u32 cmd_producer;
 	__le32 *cmd_consumer;
 	u32 last_cmd_consumer;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6797ed0..8c3cbce 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -330,6 +330,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter = netdev->priv;
 
+	spin_lock_init(&adapter->tx_lock);
 	adapter->ahw.pdev = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
 
@@ -907,7 +908,8 @@ static int netxen_nic_close(struct net_device *netdev)
 	return 0;
 }
 
-static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static int __netxen_nic_xmit_frame(struct sk_buff *skb,
+				   struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netxen_hardware_context *hw = &adapter->ahw;
@@ -1082,6 +1084,18 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&adapter->tx_lock);
+	ret = __netxen_nic_xmit_frame(skb, netdev);
+	spin_unlock(&adapter->tx_lock);
+
+	return ret;
+}
+
 static void netxen_watchdog(unsigned long v)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index a20005c..515ae22 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -91,6 +91,7 @@ static unsigned int ports[] __initdata =
 struct ni5010_local {
 	int o_pkt_size;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 /* Index to functions, as function prototypes. */
@@ -306,6 +307,7 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
 	lp = netdev_priv(dev);
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	PRINTK2((KERN_DEBUG "%s: I/O #10 passed!\n", dev->name));
 
@@ -461,6 +463,18 @@ static int ni5010_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ni5010_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+		struct ni5010_local *lp = netdev_priv(dev);
+		int ret;
+
+		spin_lock(&lp->tx_lock);
+		ret = __ni5010_send_packet(skb, dev);
+		spin_unlock(&lp->tx_lock);
+
+		return ret;
+}
+
 /*
  * The typical workload of the driver:
  * Handle the network interface interrupts.
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index a316dcc..1c0b00d 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -193,6 +193,7 @@ struct priv {
 	char __iomem *mapped;
 	char __iomem *memtop;
 	spinlock_t spinlock;
+	spinlock_t tx_lock;
 	int reset;
 	struct rfd_struct __iomem *rfd_last, *rfd_top, *rfd_first;
 	struct scp_struct __iomem *scp;
@@ -454,6 +455,7 @@ static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 	dev->mem_end = memend;
 
 	spin_lock_init(&priv->spinlock);
+	spin_lock_init(&priv->tx_lock);
 
 	if (!request_region(ioaddr, NI52_TOTAL_SIZE, DRV_NAME))
 		return -EBUSY;
@@ -1171,7 +1173,7 @@ static void ni52_timeout(struct net_device *dev)
  * send frame
  */
 
-static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int len, i;
 #ifndef NO_NOPCOMMANDS
@@ -1268,6 +1270,18 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct priv *p = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&p->tx_lock);
+	ret = __ni52_send_packet(skb, dev);
+	spin_unlock(&p->tx_lock);
+
+	return ret;
+}
+
 /*******************************************
  * Someone wanna have the statistics
  */
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 3edc971..6e36e56 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -245,6 +245,7 @@ struct priv
 	int cardno;
 	int features;
 	spinlock_t ring_lock;
+	spinlock_t tx_lock;
 };
 
 static int  ni65_probe1(struct net_device *dev,int);
@@ -448,6 +449,7 @@ static int __init ni65_probe1(struct net_device *dev,int ioaddr)
 	p->cmdr_addr = ioaddr + cards[i].cmd_offset;
 	p->cardno = i;
 	spin_lock_init(&p->ring_lock);
+	spin_lock_init(&p->tx_lock);
 
 	printk(KERN_INFO "%s: %s found at %#3x, ", dev->name, cards[p->cardno].cardname , ioaddr);
 
@@ -1155,7 +1157,7 @@ static void ni65_timeout(struct net_device *dev)
  *	Send a packet
  */
 
-static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct priv *p = (struct priv *) dev->priv;
 
@@ -1217,6 +1219,18 @@ static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct priv *p = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&p->tx_lock);
+	ret = __ni65_send_packet(skb, dev);
+	spin_unlock(&p->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *ni65_get_stats(struct net_device *dev)
 {
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 52f48cd..4763c9d 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6285,7 +6285,7 @@ static void __niu_tx_queue_backlog(struct niu *np, struct tx_ring_info *rp,
 		__niu_xmit_backlog(np, rp);
 }
 
-static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 	struct tx_ring_info *rp;
@@ -6302,6 +6302,18 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct niu *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __niu_start_xmit(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
 static int niu_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct niu *np = netdev_priv(dev);
@@ -8465,6 +8477,7 @@ static struct net_device * __devinit niu_alloc_and_init(
 	np->msg_enable = niu_debug;
 
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 	INIT_WORK(&np->reset_task, niu_reset_task);
 
 	np->port = port;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index f7d6ffc..633384e 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3267,6 +3267,7 @@ struct niu {
 
 	/* Protects hw programming, and ring state.  */
 	spinlock_t			lock;
+	spinlock_t			tx_lock;
 
 	const struct niu_ops		*ops;
 	struct net_device_stats		net_stats;
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index ff44961..fdbca3e 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -449,6 +449,7 @@ struct ns83820 {
 	unsigned		linkstate;
 
 	spinlock_t	tx_lock;
+	spinlock_t	tx_lock2;
 
 	u16		tx_done_idx;
 	u16		tx_idx;
@@ -1078,7 +1079,8 @@ static void ns83820_cleanup_tx(struct ns83820 *dev)
  * while trying to track down a bug in either the zero copy code or
  * the tx fifo (hence the MAX_FRAG_LEN).
  */
-static int ns83820_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __ns83820_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	u32 free_idx, cmdsts, extsts;
@@ -1210,6 +1212,18 @@ again:
 	return 0;
 }
 
+static int ns83820_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct ns83820 *dev = PRIV(ndev);
+	int ret;
+
+	spin_lock(&dev->tx_lock2);
+	ret = __ns83820_hard_start_xmit(skb, ndev);
+	spin_unlock(&dev->tx_lock2);
+
+	return ret;
+}
+
 static void ns83820_update_stats(struct ns83820 *dev)
 {
 	u8 __iomem *base = dev->base;
@@ -1979,6 +1993,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev, const struct pci_
 
 	spin_lock_init(&dev->rx_info.lock);
 	spin_lock_init(&dev->tx_lock);
+	spin_lock_init(&dev->tx_lock2);
 	spin_lock_init(&dev->misc_lock);
 	dev->pci_dev = pci_dev;
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index fffc49b..a6b0f07 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -478,6 +478,7 @@ struct netdrv_private {
 	unsigned int medialock:1;	/* Don't sense media type. */
 	unsigned int mediasense:1;	/* Media sensing in progress. */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	chip_t chipset;
 };
 
@@ -792,6 +793,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 	tp->board = ent->driver_data;
 	tp->mmio_addr = ioaddr;
 	spin_lock_init(&tp->lock);
+	spin_lock_init(&tp->tx_lock);
 
 	pci_set_drvdata(pdev, dev);
 
@@ -1324,7 +1326,7 @@ static void netdrv_tx_timeout (struct net_device *dev)
 
 
 
-static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
+static int __netdrv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
@@ -1355,6 +1357,17 @@ static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int netdrv_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdrv_private *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __netdrv_start_xmit(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
 
 static void netdrv_tx_interrupt (struct net_device *dev,
 				  struct netdrv_private *tp,
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index d7018ff..76dd1b7 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1058,7 +1058,7 @@ static void ei_tx_timeout(struct net_device *dev)
  * Sends a packet to an 8390 network device.
  */
  
-static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -1175,6 +1175,18 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ei_device *ei_local = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ei_local->tx_lock);
+	ret = __ei_start_xmit(skb, dev);
+	spin_unlock(&ei_local->tx_lock);
+
+	return ret;
+}
+
 /**
  * ax_interrupt - handle the interrupts from an 8390
  * @irq: interrupt number
@@ -1724,6 +1736,7 @@ static void axdev_setup(struct net_device *dev)
     
 	ei_local = (struct ei_device *)netdev_priv(dev);
 	spin_lock_init(&ei_local->page_lock);
+	spin_lock_init(&ei_local->tx_lock);
     
 	dev->hard_start_xmit = &ei_start_xmit;
 	dev->get_stats	= get_stats;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index a550c9b..cda41b7 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -125,6 +125,7 @@ typedef struct local_info_t {
     u_short tx_queue_len;
     cardtype_t cardtype;
     u_short sent;
+    spinlock_t tx_lock;
 } local_info_t;
 
 #define MC_FILTERBREAK 64
@@ -240,6 +241,7 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     if (!dev)
 	return -ENOMEM;
     lp = netdev_priv(dev);
+    spin_lock_init(&lp->tx_lock);
     link->priv = dev;
     lp->p_dev = link;
 
@@ -819,7 +821,7 @@ static void fjn_tx_timeout(struct net_device *dev)
     netif_wake_queue(dev);
 }
 
-static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     struct local_info_t *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
@@ -890,6 +892,18 @@ static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
     return 0;
 } /* fjn_start_xmit */
 
+static int fjn_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+    struct local_info_t *lp = netdev_priv(dev);
+    int ret;
+
+    spin_lock(&lp->tx_lock);
+    ret = __fjn_start_xmit(skb, dev);
+    spin_unlock(&lp->tx_lock);
+
+    return ret;
+}
+
 /*====================================================================*/
 
 static void fjn_reset(struct net_device *dev)
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index cfcbea9..ea1df98 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -375,6 +375,7 @@ typedef struct _mace_private {
     char tx_irq_disabled; /* MACE TX interrupt disabled */
     
     spinlock_t bank_lock; /* Must be held if you step off bank 0 */
+    spinlock_t tx_lock;
 } mace_private;
 
 /* ----------------------------------------------------------------------------
@@ -460,6 +461,7 @@ static int nmclan_probe(struct pcmcia_device *link)
     link->priv = dev;
     
     spin_lock_init(&lp->bank_lock);
+    spin_lock_init(&lp->tx_lock);
     link->io.NumPorts1 = 32;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 5;
@@ -933,7 +935,7 @@ static void mace_tx_timeout(struct net_device *dev)
   netif_wake_queue(dev);
 }
 
-static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
   mace_private *lp = netdev_priv(dev);
   unsigned int ioaddr = dev->base_addr;
@@ -989,6 +991,18 @@ static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
   return 0;
 } /* mace_start_xmit */
 
+static int mace_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+  mace_private *lp = netdev_priv(dev);
+  int ret;
+
+  spin_lock(&lp->tx_lock);
+  ret = __mace_start_xmit(skb, dev);
+  spin_unlock(&lp->tx_lock);
+
+  return ret;
+}
+
 /* ----------------------------------------------------------------------------
 mace_interrupt
 	The interrupt handler.
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 250eb19..51d982a 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -106,6 +106,7 @@ static const char *version =
 struct smc_private {
 	struct pcmcia_device	*p_dev;
     spinlock_t			lock;
+    spinlock_t			tx_lock;
     u_short			manfid;
     u_short			cardid;
     struct net_device_stats	stats;
@@ -325,6 +326,7 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->priv = dev;
 
     spin_lock_init(&smc->lock);
+    spin_lock_init(&smc->tx_lock);
     link->io.NumPorts1 = 16;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
     link->io.IOAddrLines = 4;
@@ -1369,7 +1371,7 @@ static void smc_tx_timeout(struct net_device *dev)
     netif_wake_queue(dev);
 }
 
-static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     struct smc_private *smc = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
@@ -1433,6 +1435,18 @@ static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
     return 0;
 }
 
+static int smc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+    struct smc_private *smc = netdev_priv(dev);
+    int ret;
+
+    spin_lock(&smc->tx_lock);
+    ret = __smc_start_xmit(skb, dev);
+    spin_unlock(&smc->tx_lock);
+
+    return ret;
+}
+
 /*======================================================================
 
     Handle a Tx anomolous event.  Entered while in Window 2.
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index f6c4698..dba0116 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -347,6 +347,7 @@ typedef struct local_info_t {
     unsigned last_ptr_value; /* last packets transmitted value */
     const char *manf_str;
     struct work_struct tx_timeout_task;
+    spinlock_t tx_lock;
 } local_info_t;
 
 /****************
@@ -569,6 +570,7 @@ xirc2ps_probe(struct pcmcia_device *link)
     if (!dev)
 	    return -ENOMEM;
     local = netdev_priv(dev);
+    spin_lock_init(&local->tx_lock);
     local->dev = dev;
     local->p_dev = link;
     link->priv = dev;
@@ -1343,8 +1345,7 @@ do_tx_timeout(struct net_device *dev)
     schedule_work(&lp->tx_timeout_task);
 }
 
-static int
-do_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __do_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     local_info_t *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
@@ -1399,6 +1400,18 @@ do_start_xmit(struct sk_buff *skb, struct net_device *dev)
     return 0;
 }
 
+static int do_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+    local_info_t *lp = netdev_priv(dev);
+    int ret;
+
+    spin_lock(&lp->tx_lock);
+    ret = __do_start_xmit(skb, dev);
+    spin_unlock(&lp->tx_lock);
+
+    return ret;
+}
+
 static struct net_device_stats *
 do_get_stats(struct net_device *dev)
 {
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 1e96542..ec589f5 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -220,6 +220,7 @@ struct net_local {
 	int port_owner;
 	int should_relinquish;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	atomic_t kill_timer;
 	struct completion killed_timer_cmp;
 };
@@ -306,6 +307,7 @@ plip_init_netdev(struct net_device *dev)
 		INIT_DELAYED_WORK(&nl->timer, plip_timer_bh);
 
 	spin_lock_init(&nl->lock);
+	spin_lock_init(&nl->tx_lock);
 }
 
 /* Bottom half handler for the delayed request.
@@ -946,8 +948,7 @@ plip_interrupt(void *dev_id)
 	spin_unlock_irqrestore(&nl->lock, flags);
 }
 
-static int
-plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
+static int __plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *nl = netdev_priv(dev);
 	struct plip_local *snd = &nl->snd_data;
@@ -988,6 +989,18 @@ plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *nl = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&nl->tx_lock);
+	ret = __plip_tx_packet(skb, dev);
+	spin_unlock(&nl->tx_lock);
+
+	return ret;
+}
+
 static void
 plip_rewrite_address(const struct net_device *dev, struct ethhdr *eth)
 {
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index c926bf0..8ca5034 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -115,6 +115,7 @@ struct ppp {
 	unsigned long	last_xmit;	/* jiffies when last pkt sent 9c */
 	unsigned long	last_recv;	/* jiffies when last pkt rcvd a0 */
 	struct net_device *dev;		/* network interface device a4 */
+	spinlock_t	tx_lock;
 #ifdef CONFIG_PPP_MULTILINK
 	int		nxchan;		/* next channel to send something on */
 	u32		nxseq;		/* next sequence number to send */
@@ -880,8 +881,7 @@ out_chrdev:
 /*
  * Network interface unit routines.
  */
-static int
-ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ppp *ppp = (struct ppp *) dev->priv;
 	int npi, proto;
@@ -925,6 +925,18 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ppp *ppp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ppp->tx_lock);
+	ret = __ppp_start_xmit(skb, dev);
+	spin_unlock(&ppp->tx_lock);
+
+	return ret;
+}
+
 static int
 ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -2427,6 +2439,7 @@ ppp_create_interface(int unit, int *retp)
 	INIT_LIST_HEAD(&ppp->channels);
 	spin_lock_init(&ppp->rlock);
 	spin_lock_init(&ppp->wlock);
+	spin_lock_init(&ppp->tx_lock);
 #ifdef CONFIG_PPP_MULTILINK
 	ppp->minseq = -1;
 	skb_queue_head_init(&ppp->mrq);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 5f60878..11d3dcc 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2584,7 +2584,7 @@ map_error:
  * The IOCB is always the top of the chain followed by one or more
  * OALs (when necessary).
  */
-static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
+static int __ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
@@ -2638,6 +2638,18 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 	return NETDEV_TX_OK;
 }
 
+static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct ql3_adapter *qdev = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&qdev->tx_lock);
+	ret = __ql3xxx_send(skb, ndev);
+	spin_unlock(&qdev->tx_lock);
+
+	return ret;
+}
+
 static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
 	qdev->req_q_size =
@@ -4000,6 +4012,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	spin_lock_init(&qdev->adapter_lock);
 	spin_lock_init(&qdev->hw_lock);
+	spin_lock_init(&qdev->tx_lock);
 
 	/* Set driver entry points */
 	ndev->open = ql3xxx_open;
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 58a086f..9a1c817 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1187,6 +1187,7 @@ struct ql3_adapter {
 
 	spinlock_t adapter_lock;
 	spinlock_t hw_lock;
+	spinlock_t tx_lock;
 
 	/* PCI Bus Relative Register Addresses */
 	u8 __iomem *mmap_virt_base;	/* stores return value from ioremap() */
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 858b191..08fb506 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -157,6 +157,7 @@ struct r6040_descriptor {
 
 struct r6040_private {
 	spinlock_t lock;		/* driver lock */
+	spinlock_t tx_lock;
 	struct timer_list timer;
 	struct pci_dev *pdev;
 	struct r6040_descriptor *rx_insert_ptr;
@@ -796,7 +797,7 @@ static int r6040_open(struct net_device *dev)
 	return 0;
 }
 
-static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	struct r6040_descriptor *descptr;
@@ -844,6 +845,18 @@ static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __r6040_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void r6040_multicast_list(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
@@ -1037,6 +1050,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	pci_set_drvdata(pdev, dev);
 
 	/* Set MAC address */
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6572425..5526f9e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -398,6 +398,7 @@ struct rtl8169_private {
 	struct napi_struct napi;
 #endif
 	spinlock_t lock;		/* spin lock flag */
+	spinlock_t tx_lock;
 	u32 msg_enable;
 	int chipset;
 	int mac_version;
@@ -1789,6 +1790,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->timer.function = rtl8169_phy_timer;
 
 	spin_lock_init(&tp->lock);
+	spin_lock_init(&tp->tx_lock);
 
 	rc = register_netdev(dev);
 	if (rc < 0)
@@ -2533,7 +2535,7 @@ static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
@@ -2613,6 +2615,18 @@ err_update_stats:
 	goto out;
 }
 
+static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __rtl8169_start_xmit(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
+
 static void rtl8169_pcierr_interrupt(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 5694e89..4ee201f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4110,7 +4110,7 @@ static int s2io_close(struct net_device *dev)
  *  0 on success & 1 on failure.
  */
 
-static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct s2io_nic *sp = dev->priv;
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
@@ -4344,6 +4344,18 @@ pci_map_failed:
 	return 0;
 }
 
+static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct s2io_nic *sp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&sp->tx_lock);
+	ret = __s2io_xmit(skb, dev);
+	spin_unlock(&sp->tx_lock);
+
+	return ret;
+}
+
 static void
 s2io_alarm_handle(unsigned long data)
 {
@@ -7814,6 +7826,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	/*  Private member variable initialized to s2io NIC structure */
 	sp = dev->priv;
 	memset(sp, 0, sizeof(struct s2io_nic));
+	spin_lock_init(&sp->tx_lock);
 	sp->dev = dev;
 	sp->pdev = pdev;
 	sp->high_dma_flag = dma_flag;
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index d0a84ba..6183c52 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -882,6 +882,7 @@ struct s2io_nic {
 	 */
 	int pkts_to_process;
 	struct net_device *dev;
+	spinlock_t tx_lock;
 	struct mac_info mac_control;
 	struct config_param config;
 	struct pci_dev *pdev;
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index c65199d..ebb0e8a 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -867,8 +867,8 @@ static void lan_saa9730_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int lan_saa9730_start_xmit(struct sk_buff *skb,
-				  struct net_device *dev)
+static int __lan_saa9730_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct lan_saa9730_private *lp = netdev_priv(dev);
 	unsigned long flags;
@@ -903,6 +903,19 @@ static int lan_saa9730_start_xmit(struct sk_buff *skb,
 	return 0;
 }
 
+static int lan_saa9730_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
+{
+	struct lan_saa9730_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lan_saa9730_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static int lan_saa9730_close(struct net_device *dev)
 {
 	struct lan_saa9730_private *lp = netdev_priv(dev);
@@ -1033,6 +1046,7 @@ static int lan_saa9730_init(struct net_device *dev, struct pci_dev *pdev,
 		goto out_free_consistent;
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	dev->open = lan_saa9730_open;
 	dev->hard_start_xmit = lan_saa9730_start_xmit;
diff --git a/drivers/net/saa9730.h b/drivers/net/saa9730.h
index 010a120..819e6f3 100644
--- a/drivers/net/saa9730.h
+++ b/drivers/net/saa9730.h
@@ -379,6 +379,7 @@ struct lan_saa9730_private {
 	unsigned char PhysicalAddress[LAN_SAA9730_CAM_ENTRIES][6];
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 };
 
 #endif /* _SAA9730_H */
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index 48c64fb..89ebadb 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -67,6 +67,7 @@ static unsigned int net_debug = NET_DEBUG;
 
 /* Information that need to be kept for each board. */
 struct net_local {
+	spinlock_t tx_lock;
 	unsigned short receive_ptr;		/* What address in packet memory do we expect a recv_pkt_header? */
 	long open_time;				/* Useless example local info. */
 };
@@ -105,12 +106,16 @@ static int irq = 10;
 struct net_device * __init seeq8005_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	struct net_local *lp;
 	unsigned *port;
 	int err = 0;
 
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
+	lp = netdev_priv(dev);
+	spin_lock_init(&lp->tx_lock);
+
 	if (unit >= 0) {
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
@@ -388,7 +393,7 @@ static void seeq8005_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	short length = skb->len;
 	unsigned char *buf;
@@ -412,6 +417,18 @@ static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+		struct net_local *lp = netdev_priv(dev);
+		int ret;
+
+		spin_lock(&lp->tx_lock);
+		ret = __seeq8005_send_packet(skb, dev);
+		spin_unlock(&lp->tx_lock);
+
+		return ret;
+}
+
 /*
  * wait_for_buffer
  *
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7b2015f..9e37f62 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1837,6 +1837,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 
 	/* Initialise common structures */
 	memset(efx, 0, sizeof(*efx));
+	spin_lock_init(&efx->tx_lock);
 	spin_lock_init(&efx->biu_lock);
 	spin_lock_init(&efx->phy_lock);
 	INIT_WORK(&efx->reset_work, efx_reset_work);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index d803b86..cb797b5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -697,6 +697,7 @@ struct efx_nic {
 	enum nic_state state;
 	enum reset_type reset_pending;
 
+	spinlock_t tx_lock;
 	struct efx_tx_queue tx_queue[EFX_MAX_TX_QUEUES];
 	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
 	struct efx_channel channel[EFX_MAX_CHANNELS];
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 5cdd082..8690de6 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -368,7 +368,13 @@ inline int efx_xmit(struct efx_nic *efx,
 int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
 	struct efx_nic *efx = net_dev->priv;
-	return efx_xmit(efx, &efx->tx_queue[0], skb);
+	int ret;
+
+	spin_lock(&efx->tx_lock);
+	ret = efx_xmit(efx, &efx->tx_queue[0], skb);
+	spin_unlock(&efx->tx_lock);
+
+	return ret;
 }
 
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 6261201..44949cc 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -594,8 +594,10 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Setup... */
 	len = skb->len;
 	if (len < ETH_ZLEN) {
-		if (skb_padto(skb, ETH_ZLEN))
+		if (skb_padto(skb, ETH_ZLEN)) {
+			spin_unlock_irqrestore(&sp->tx_lock, flags);
 			return 0;
+		}
 		len = ETH_ZLEN;
 	}
 
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index f64d987..ba0c88f 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -788,7 +788,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 }
 
 /* Packet transmit function */
-static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+static int __sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_txdesc *txdesc;
@@ -831,6 +831,18 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return 0;
 }
 
+static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret;
+
+	spin_lock(&mdp->tx_lock);
+	ret = __sh_eth_start_xmit(skb, dev);
+	spin_unlock(&mdp->tx_lock);
+
+	return ret;
+}
+
 /* device close function */
 static int sh_eth_close(struct net_device *ndev)
 {
@@ -1070,6 +1082,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	mdp = netdev_priv(ndev);
 	spin_lock_init(&mdp->lock);
+	spin_lock_init(&mdp->tx_lock);
 
 	/* get PHY ID */
 	mdp->phy_id = (int)pdev->dev.platform_data;
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index ca2db6b..debddb2 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -434,6 +434,7 @@ struct sh_eth_private {
 	struct net_device_stats stats;
 	struct timer_list timer;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	u32 cur_rx, dirty_rx;	/* Producer/consumer ring indices */
 	u32 cur_tx, dirty_tx;
 	u32 rx_buf_sz;		/* Based on MTU+slack. */
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 3fe0176..717b06a 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -277,6 +277,7 @@ struct sis190_private {
 	struct pci_dev *pci_dev;
 	struct net_device *dev;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	u32 rx_buf_sz;
 	u32 cur_rx;
 	u32 cur_tx;
@@ -1154,7 +1155,7 @@ static int sis190_close(struct net_device *dev)
 	return 0;
 }
 
-static int sis190_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __sis190_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1217,6 +1218,18 @@ out:
 	return NETDEV_TX_OK;
 }
 
+static int sis190_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sis190_private *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __sis190_start_xmit(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
+
 static void sis190_free_phy(struct list_head *first_phy)
 {
 	struct sis190_phy *cur, *next;
@@ -1831,6 +1844,7 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 	dev->base_addr = (unsigned long) 0xdead;
 
 	spin_lock_init(&tp->lock);
+	spin_lock_init(&tp->tx_lock);
 
 	rc = sis190_mii_probe(dev);
 	if (rc < 0)
diff --git a/drivers/net/skfp/h/targetos.h b/drivers/net/skfp/h/targetos.h
index 5d940e7..e1a48af 100644
--- a/drivers/net/skfp/h/targetos.h
+++ b/drivers/net/skfp/h/targetos.h
@@ -157,6 +157,7 @@ struct s_smt_os {
 	
 	// For SMP-savety
 	spinlock_t DriverLock;
+	spinlock_t tx_lock;
 	
 };
 
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index a2b092b..abe4a18 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -396,6 +396,7 @@ static  int skfp_driver_init(struct net_device *dev)
 	smc->hw.irq = dev->irq;
 
 	spin_lock_init(&bp->DriverLock);
+	spin_lock_init(&bp->tx_lock);
 	
 	// Allocate invalid frame
 	bp->LocalRxBuffer = pci_alloc_consistent(&bp->pdev, MAX_FRAME_SIZE, &bp->LocalRxBufferDMA);
@@ -1060,7 +1061,7 @@ static int skfp_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  * Side Effects:
  *   None
  */
-static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
+static int __skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 {
 	struct s_smc *smc = netdev_priv(dev);
 	skfddi_priv *bp = &smc->os;
@@ -1099,6 +1100,18 @@ static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
 
 }				// skfp_send_pkt
 
+static int skfp_send_pkt(struct sk_buff *skb, struct net_device *dev)
+{
+	struct s_smc *smc = netdev_priv(dev);
+	skfddi_priv *bp = &smc->os;
+	int ret;
+
+	spin_lock(&bp->tx_lock);
+	ret = __skfp_send_pkt(skb, dev);
+	spin_unlock(&bp->tx_lock);
+
+	return ret;
+}
 
 /*
  * =======================
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 2e26dce..d0783ef 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2745,7 +2745,7 @@ static inline int skge_avail(const struct skge_ring *ring)
 		+ (ring->to_clean - ring->to_use) - 1;
 }
 
-static int skge_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+static int __skge_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
@@ -2841,6 +2841,18 @@ static int skge_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int skge_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct skge_hw *hw = skge->hw;
+	int ret;
+
+	spin_lock(&hw->tx_lock);
+	ret = __skge_xmit_frame(skb, dev);
+	spin_unlock(&hw->tx_lock);
+
+	return ret;
+}
 
 /* Free resources associated with this reing element */
 static void skge_tx_free(struct skge_port *skge, struct skge_element *e,
@@ -3932,6 +3944,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 
 	hw->pdev = pdev;
 	spin_lock_init(&hw->hw_lock);
+	spin_lock_init(&hw->tx_lock);
 	spin_lock_init(&hw->phy_lock);
 	tasklet_init(&hw->phy_task, &skge_extirq, (unsigned long) hw);
 
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index 17caccb..f8658bd 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -2409,6 +2409,7 @@ struct skge_hw {
 	void __iomem  	     *regs;
 	struct pci_dev	     *pdev;
 	spinlock_t	     hw_lock;
+	spinlock_t	     tx_lock;
 	u32		     intr_mask;
 	struct net_device    *dev[2];
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 711e4a8..dc1c5b6 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1612,7 +1612,7 @@ static unsigned tx_le_req(const struct sk_buff *skb)
  * the number of ring elements will probably be less than the number
  * of list elements used.
  */
-static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+static int __sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
@@ -1749,6 +1749,18 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&sky2->tx_lock);
+	ret = __sky2_xmit_frame(skb, dev);
+	spin_unlock(&sky2->tx_lock);
+
+	return ret;
+}
+
 /*
  * Free ring elements from starting at tx_cons until "done"
  *
@@ -4158,6 +4170,7 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
+	spin_lock_init(&sky2->tx_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
 	sky2->rx_pending = RX_DEF_PENDING;
 
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 4d9c4a1..582d28f 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2010,6 +2010,7 @@ struct sky2_port {
 	u32		     msg_enable;
 	spinlock_t	     phy_lock;
 
+	spinlock_t	     tx_lock;
 	struct tx_ring_info  *tx_ring;
 	struct sky2_tx_le    *tx_le;
 	u16		     tx_cons;		/* next le to check */
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index c587162..71ef884 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -517,7 +517,7 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
  * now, or set the card to generates an interrupt when ready
  * for the packet.
  */
-static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int free;
@@ -585,6 +585,18 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smc911x_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __smc911x_hard_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  * This handles a TX status interrupt, which is only called when:
  * - a TX error occurred, or
@@ -1906,6 +1918,7 @@ static int __init smc911x_probe(struct net_device *dev)
 		lp->tx_fifo_size, lp->rx_fifo_size, lp->afc_cfg);
 
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/* Get the MAC address */
 	SMC_GET_MAC_ADDR(lp, dev->dev_addr);
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 76c17c2..60f46da 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -82,6 +82,7 @@ struct smc911x_local {
 
 	int tx_throttle;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	struct net_device *netdev;
 
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index de67744..25e5db2 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -190,6 +190,7 @@ static struct devlist smc_devlist[] __initdata = {
 
 /* store this information for the driver.. */
 struct smc_local {
+	spinlock_t tx_lock;
 	/*
 	   If I have to wait until memory is available to send
 	   a packet, I will store the skbuff here, until I get the
@@ -487,7 +488,8 @@ static void smc_setmulticast( int ioaddr, int count, struct dev_mc_list * addrs
  . o 	(NO): Enable interrupts and let the interrupt handler deal with it.
  . o	(YES):Send it now.
 */
-static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * dev )
+static int __smc_wait_to_send_packet(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	unsigned int ioaddr 	= dev->base_addr;
@@ -579,6 +581,19 @@ static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * de
 	return 0;
 }
 
+static int smc_wait_to_send_packet(struct sk_buff *skb,
+				   struct net_device *dev)
+{
+	struct smc_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __smc_wait_to_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  . Function:  smc_hardware_send_packet(struct net_device * )
  . Purpose:
@@ -719,11 +734,15 @@ struct net_device * __init smc_init(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct smc_local));
 	struct devlist *smcdev = smc_devlist;
+	struct smc_local *lp;
 	int err = 0;
 
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
+	lp = netdev_priv(dev);
+	spin_lock_init(&lp->tx_lock);
+
 	if (unit >= 0) {
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index f2051b2..7ddabdb 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -656,7 +656,7 @@ done:	if (!THROTTLE_TX_PKTS)
  * now, or set the card to generates an interrupt when ready
  * for the packet.
  */
-static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
@@ -723,6 +723,18 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smc_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __smc_hard_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  * This handles a TX interrupt, which is only called when:
  * - a TX error occurred, or
@@ -1846,6 +1858,7 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	lp->base = ioaddr;
 	lp->version = revision_register & 0xff;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 
 	/* Get the MAC address */
 	SMC_SELECT_BANK(lp, 1);
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 8606818..1d636e9 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -492,6 +492,7 @@ struct smc_local {
 	int	work_pending;
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 #ifdef SMC_USE_PXA_DMA
 	/* DMA needs the physical address of the chip */
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index 8069f3e..3ab56ef 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -198,7 +198,7 @@ static void sonic_tx_timeout(struct net_device *dev)
  * MIPS Jazz machines and m68k Macs were all uni-processor machines.
  */
 
-static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	dma_addr_t laddr;
@@ -268,6 +268,18 @@ static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int sonic_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sonic_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __sonic_send_packet(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*
  * The typical workload of the driver:
  * Handle the network interface interrupts.
@@ -579,6 +591,8 @@ static int sonic_init(struct net_device *dev)
 	struct sonic_local *lp = netdev_priv(dev);
 	int i;
 
+	spin_lock_init(&lp->tx_lock);
+
 	/*
 	 * put the Sonic into software-reset mode and
 	 * disable all interrupts
diff --git a/drivers/net/sonic.h b/drivers/net/sonic.h
index 7db13e4..c1c8d79 100644
--- a/drivers/net/sonic.h
+++ b/drivers/net/sonic.h
@@ -286,6 +286,7 @@
 
 /* Information that need to be kept for each board. */
 struct sonic_local {
+	spinlock_t tx_lock;
 	/* Bus size.  0 == 16 bits, 1 == 32 bits. */
 	int dma_bitmode;
 	/* Register offset within the longword (independent of endianness,
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 00aa0b1..fb3d586 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -911,8 +911,7 @@ out:
  *
  * returns 0 on success, !0 on failure
  */
-static int
-spider_net_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __spider_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	int cnt;
 	struct spider_net_card *card = netdev_priv(netdev);
@@ -931,6 +930,18 @@ spider_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+static int spider_net_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct spider_net_card *card = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&card->tx_lock);
+	ret = __spider_net_xmit(skb, netdev);
+	spin_unlock(&card->tx_lock);
+
+	return ret;
+}
+
 /**
  * spider_net_cleanup_tx_ring - cleans up the TX ring
  * @card: card structure
@@ -2315,6 +2326,8 @@ spider_net_setup_netdev(struct spider_net_card *card)
 
 	pci_set_drvdata(card->pdev, netdev);
 
+	spin_lock_init(&card->tx_lock);
+
 	init_timer(&card->tx_timer);
 	card->tx_timer.function =
 		(void (*)(unsigned long)) spider_net_cleanup_tx_ring;
diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
index 05f74cb..c73382e 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/spider_net.h
@@ -466,6 +466,7 @@ struct spider_net_card {
 	struct mii_phy phy;
 
 	struct napi_struct napi;
+	spinlock_t tx_lock;
 
 	int medium;
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 7b7b171..3604909 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -609,6 +609,7 @@ struct netdev_private {
 
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
 	unsigned int cur_tx, dirty_tx, reap_tx;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
@@ -793,6 +794,7 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	np->dev = dev;
 	np->base = base;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 	pci_set_drvdata(pdev, dev);
 
 	np->pci_dev = pdev;
@@ -1214,7 +1216,7 @@ static void init_ring(struct net_device *dev)
 }
 
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static int __start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	unsigned int entry;
@@ -1305,6 +1307,17 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __start_tx(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
 
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 9b2a7f7..0fa1da1 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -147,6 +147,7 @@ struct priv
 	unsigned long base;
 	char *memtop;
 	long int lock;
+	spinlock_t tx_lock;
 	int reseted;
 	volatile struct rfd_struct	*rfd_last,*rfd_top,*rfd_first;
 	volatile struct scp_struct	*scp;	/* volatile is important */
@@ -334,6 +335,10 @@ out:
 static int __init sun3_82586_probe1(struct net_device *dev,int ioaddr)
 {
 	int i, size, retval;
+	struct priv *priv;
+
+	priv = netdev_priv(dev);
+	spin_lock_init(&priv->tx_lock);
 
 	if (!request_region(ioaddr, SUN3_82586_TOTAL_SIZE, DRV_NAME))
 		return -EBUSY;
@@ -996,7 +1001,8 @@ static void sun3_82586_timeout(struct net_device *dev)
  * send frame
  */
 
-static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __sun3_82586_send_packet(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	int len,i;
 #ifndef NO_NOPCOMMANDS
@@ -1105,6 +1111,18 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct priv *p = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&p->tx_lock);
+	ret = __sun3_82586_send_packet(skb, dev);
+	spin_unlock(&p->tx_lock);
+
+	return ret;
+}
+
 /*******************************************
  * Someone wanna have the statistics
  */
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 359452a..fcd19d2 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -155,6 +155,7 @@ struct lance_private {
 /* These two must be longs for set_bit() */
 	long	    tx_full;
 	long	    lock;
+	spinlock_t  tx_lock;
 };
 
 /* I/O register access macros */
@@ -335,6 +336,8 @@ static int __init lance_probe( struct net_device *dev)
 
 	lp = netdev_priv(dev);
 
+	spin_lock_init(&lp->tx_lock);
+
 	/* XXX - leak? */
 	MEM = dvma_malloc_align(sizeof(struct lance_memory), 0x10000);
 	if (MEM == NULL) {
@@ -508,7 +511,7 @@ static void lance_init_ring( struct net_device *dev )
 }
 
 
-static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
+static int __lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	int entry, len;
@@ -647,6 +650,18 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	return 0;
 }
 
+static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lance_private *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lance_start_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /* The LANCE interrupt handler. */
 
 static irqreturn_t lance_interrupt( int irq, void *dev_id)
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 7d5561b..831bbfa 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -373,6 +373,7 @@ struct netdev_private {
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
 	spinlock_t rx_lock;			/* Group with Tx control cache line. */
+	spinlock_t tx_lock;
 	int msg_enable;
 	int chip_id;
 	unsigned int cur_rx, dirty_rx;		/* Producer/consumer ring indices */
@@ -508,6 +509,7 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 	np->chip_id = chip_idx;
 	np->msg_enable = (1 << debug) - 1;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 	tasklet_init(&np->rx_tasklet, rx_poll, (unsigned long)dev);
 	tasklet_init(&np->tx_tasklet, tx_poll, (unsigned long)dev);
 
@@ -1028,8 +1030,7 @@ static void tx_poll (unsigned long data)
 	return;
 }
 
-static int
-start_tx (struct sk_buff *skb, struct net_device *dev)
+static int __start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	struct netdev_desc *txdesc;
@@ -1069,6 +1070,18 @@ start_tx (struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __start_tx(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
 /* Reset hardware tx and free all of tx buffers */
 static int
 reset_tx (struct net_device *dev)
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9c8f177..184b6e0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5015,7 +5015,7 @@ static void __tg3_tx_queue_backlog(struct tg3 *tp, struct sk_buff *skb)
 		__tg3_xmit_backlog(tp);
 }
 
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
@@ -5028,6 +5028,18 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __tg3_start_xmit(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
+
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 			       int new_mtu)
 {
@@ -13348,6 +13360,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->grc_mode |= GRC_MODE_BSWAP_NONFRM_DATA;
 #endif
 	spin_lock_init(&tp->lock);
+	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task);
 	skb_queue_head_init(&tp->tx_backlog);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 1792d47..5c17907 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2367,6 +2367,7 @@ struct tg3 {
 	 *                with IRQ disabling.
 	 */
 	spinlock_t			lock;
+	spinlock_t			tx_lock;
 	spinlock_t			indirect_lock;
 
 	u32				(*read32) (struct tg3 *, u32);
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 85246ed..3d15537 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -559,6 +559,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 	priv = netdev_priv(dev);
 
+	spin_lock_init(&priv->tx_lock);
 	priv->pciDev = pdev;
 	priv->dev = dev;
 
@@ -1090,7 +1091,7 @@ static void TLan_tx_timeout_work(struct work_struct *work)
 	 *
 	 **************************************************************/
 
-static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
+static int __TLan_StartTx(struct sk_buff *skb, struct net_device *dev)
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	TLanList	*tail_list;
@@ -1168,7 +1169,17 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 } /* TLan_StartTx */
 
+static int TLan_StartTx(struct sk_buff *skb, struct net_device *dev)
+{
+	TLanPrivateInfo *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __TLan_StartTx(skb, dev);
+	spin_unlock(&priv->tx_lock);
 
+	return ret;
+}
 
 
 	/***************************************************************
diff --git a/drivers/net/tlan.h b/drivers/net/tlan.h
index 4b82f28..540d366 100644
--- a/drivers/net/tlan.h
+++ b/drivers/net/tlan.h
@@ -182,6 +182,7 @@ typedef struct tlan_private_tag {
 	u32                     rxHead;
 	u32                     rxTail;
 	u32			rxEocCount;
+	spinlock_t		tx_lock;
 	TLanList                *txList;
 	dma_addr_t		txListDMA;
 	u8			*txBuffer;
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index e494c63..a329d33 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -882,6 +882,7 @@ static int tok_open(struct net_device *dev)
 	ti->sram_phys &= ~1; /* to reverse what we do in tok_close */
 	/* init the spinlock */
 	spin_lock_init(&ti->lock);
+	spin_lock_init(&ti->tx_lock);
 	init_timer(&ti->tr_timer);
 	
 	i = tok_init_card(dev);
@@ -1022,7 +1023,7 @@ static void tok_set_multicast_list(struct net_device *dev)
 
 #define STATION_ID_OFST 4
 
-static int tok_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __tok_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tok_info *ti;
 	unsigned long flags;
@@ -1044,6 +1045,18 @@ static int tok_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int tok_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tok_info *ti = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ti->tx_lock);
+	ret = __tok_send_packet(skb, dev);
+	spin_unlock(&ti->tx_lock);
+
+	return ret;
+}
+
 /*****************************************************************************/
 
 static int tok_close(struct net_device *dev)
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 5f1c507..c4f923a 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3631,6 +3631,7 @@ static int __init smctr_probe1(struct net_device *dev, int ioaddr)
                 printk(version);
 
         spin_lock_init(&tp->lock);
+        spin_lock_init(&tp->tx_lock);
         dev->base_addr = ioaddr;
 
 	/* Actually detect an adapter now. */
@@ -4583,7 +4584,7 @@ static void smctr_timeout(struct net_device *dev)
 /*
  * Gets skb from system, queues it and checks if it can be sent
  */
-static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
         struct net_local *tp = netdev_priv(dev);
 
@@ -4608,6 +4609,18 @@ static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
         return (0);
 }
 
+static int smctr_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+        struct net_local *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __smctr_send_packet(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
+
 static int smctr_send_lobe_media_test(struct net_device *dev)
 {
         struct net_local *tp = netdev_priv(dev);
diff --git a/drivers/net/tokenring/smctr.h b/drivers/net/tokenring/smctr.h
index 88dfa2e..5e6b5af 100644
--- a/drivers/net/tokenring/smctr.h
+++ b/drivers/net/tokenring/smctr.h
@@ -1052,6 +1052,7 @@ typedef struct net_local {
 	struct tr_statistics MacStat;   /* MAC statistics structure */
 	
 	spinlock_t	lock;
+	spinlock_t	tx_lock;
 } NET_LOCAL;
 
 /************************************
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index d07c452..f8752e6 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -595,7 +595,7 @@ static void tms380tr_timeout(struct net_device *dev)
 /*
  * Gets skb from system, queues it and checks if it can be sent
  */
-static int tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *tp = netdev_priv(dev);
 	int err;
@@ -606,6 +606,18 @@ static int tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return (err);
 }
 
+static int tms380tr_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __tms380tr_send_packet(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
+
 /*
  * Move frames into adapter tx queue
  */
@@ -2333,6 +2345,7 @@ int tmsdev_init(struct net_device *dev, struct device *pdev)
 
 	memset(dev->priv, 0, sizeof(struct net_local));
 	tms_local = netdev_priv(dev);
+	spin_lock_init(&tms_local->tx_lock);
 	init_waitqueue_head(&tms_local->wait_for_tok_int);
 	if (pdev->dma_mask)
 		tms_local->dmalimit = *pdev->dma_mask;
diff --git a/drivers/net/tokenring/tms380tr.h b/drivers/net/tokenring/tms380tr.h
index 7af76d7..a440e9a 100644
--- a/drivers/net/tokenring/tms380tr.h
+++ b/drivers/net/tokenring/tms380tr.h
@@ -1080,6 +1080,7 @@ typedef struct net_local {
 	unsigned char ProductID[PROD_ID_SIZE + 1]; /* Product ID */
 #pragma pack()
 
+	spinlock_t tx_lock;
 	TPL Tpl[TPL_NUM];
 	TPL *TplFree;
 	TPL *TplBusy;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index febfaee..92beeab 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -125,7 +125,7 @@ struct tsi108_prv_data {
 
 	/* txlock nests in misclock and phy_lock */
 
-	spinlock_t txlock, misclock;
+	spinlock_t txlock, tx_lock, misclock;
 
 	/* stats is used to hold the upper bits of each hardware counter,
 	 * and tmpstats is used to hold the full values for returning
@@ -651,7 +651,7 @@ static void tsi108_complete_tx(struct net_device *dev)
 	}
 }
 
-static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
+static int __tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
 	int frags = skb_shinfo(skb)->nr_frags + 1;
@@ -746,6 +746,18 @@ static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int tsi108_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tsi108_prv_data *data = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&data->tx_lock);
+	ret = __tsi08_send_packet(skb, dev);
+	spin_unlock(&data->tx_lock);
+
+	return ret;
+}
+
 static int tsi108_complete_rx(struct net_device *dev, int budget)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
@@ -1640,6 +1652,7 @@ tsi108_init_one(struct platform_device *pdev)
 	dev->features = NETIF_F_HIGHDMA;
 
 	spin_lock_init(&data->txlock);
+	spin_lock_init(&data->tx_lock);
 	spin_lock_init(&data->misclock);
 
 	tsi108_reset_ether(data);
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index bc30c6e..e990205 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -795,6 +795,7 @@ struct de4x5_private {
     char setup_frame[SETUP_FRAME_LEN];      /* Holds MCA and PA info.       */
     char frame[64];                         /* Min sized packet for loopback*/
     spinlock_t lock;                        /* Adapter specific spinlock    */
+    spinlock_t tx_lock;
     struct net_device_stats stats;          /* Public stats                 */
     struct pkt_stats pktStats;	            /* Private stats counters	    */
     char rxRingSize;
@@ -1135,6 +1136,7 @@ de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 	lp->timeout = -1;
 	lp->gendev = gendev;
 	spin_lock_init(&lp->lock);
+	spin_lock_init(&lp->tx_lock);
 	init_timer(&lp->timer);
 	lp->timer.function = (void (*)(unsigned long))de4x5_ast;
 	lp->timer.data = (unsigned long)dev;
@@ -1449,8 +1451,7 @@ de4x5_sw_reset(struct net_device *dev)
 /*
 ** Writes a socket buffer address to the next available transmit descriptor.
 */
-static int
-de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
+static int __de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
@@ -1517,6 +1518,18 @@ de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
     return status;
 }
 
+static int de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
+{
+    struct de4x5_private *lp = netdev_priv(dev);
+    int ret;
+
+    spin_lock(&lp->tx_lock);
+    ret = __de4x5_queue_pkt(skb, dev);
+    spin_unlock(&lp->tx_lock);
+
+    return ret;
+}
+
 /*
 ** The DE4X5 interrupt handler.
 **
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 6562004..951f83c 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -210,6 +210,7 @@ struct dmfe_board_info {
 	struct DEVICE *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	long ioaddr;			/* I/O base address */
 	u32 cr0_data;
@@ -450,6 +451,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	netif_carrier_off(dev);
 	spin_lock_init(&db->lock);
+	spin_lock_init(&db->tx_lock);
 
 	pci_read_config_dword(pdev, 0x50, &pci_pmr);
 	pci_pmr &= 0x70000;
@@ -651,7 +653,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
  *	Send a packet to media from the upper layer.
  */
 
-static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
+static int __dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	struct tx_desc *txptr;
@@ -715,6 +717,17 @@ static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 	return 0;
 }
 
+static int dmfe_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dmfe_board_info *db = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&db->tx_lock);
+	ret = __dmfe_start_xmit(skb, dev);
+	spin_unlock(&db->tx_lock);
+
+	return ret;
+}
 
 /*
  *	Stop the interface.
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index e9e6286..7ecd0a4 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -128,6 +128,7 @@ struct uli526x_board_info {
 	struct net_device *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	long ioaddr;			/* I/O base address */
 	u32 cr0_data;
@@ -346,6 +347,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	dev->poll_controller = &uli526x_poll;
 #endif
 	spin_lock_init(&db->lock);
+	spin_lock_init(&db->tx_lock);
 
 
 	/* read 64 word srom data */
@@ -565,7 +567,7 @@ static void uli526x_init(struct net_device *dev)
  *	Send a packet to media from the upper layer.
  */
 
-static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
 	struct tx_desc *txptr;
@@ -625,6 +627,17 @@ static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct uli526x_board_info *db = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&db->tx_lock);
+	ret = __uli526x_start_xmit(skb, dev);
+	spin_unlock(&db->tx_lock);
+
+	return ret;
+}
 
 /*
  *	Stop the interface.
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 5006819..d1a7b56 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -303,6 +303,7 @@ struct netdev_private {
 	struct timer_list timer;	/* Media monitoring timer. */
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int chip_id, drv_flags;
 	struct pci_dev *pci_dev;
 	int csr6;
@@ -396,6 +397,7 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	np->chip_id = chip_idx;
 	np->drv_flags = pci_id_tbl[chip_idx].drv_flags;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 	np->mii_if.dev = dev;
 	np->mii_if.mdio_read = mdio_read;
 	np->mii_if.mdio_write = mdio_write;
@@ -992,7 +994,7 @@ static void free_ringdesc(struct netdev_private *np)
 
 }
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static int __start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	unsigned entry;
@@ -1056,6 +1058,18 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&np->tx_lock);
+	ret = __start_tx(skb, dev);
+	spin_unlock(&np->tx_lock);
+
+	return ret;
+}
+
 static void netdev_tx_done(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 00238fd..a672902 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -90,6 +90,7 @@ struct tun_struct {
 	gid_t			group;
 
 	wait_queue_head_t	read_wait;
+	spinlock_t		tx_lock;
 	struct sk_buff_head	readq;
 
 	struct net_device	*dev;
@@ -130,7 +131,7 @@ static int tun_net_close(struct net_device *dev)
 }
 
 /* Net device start xmit */
-static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
@@ -173,6 +174,18 @@ drop:
 	return 0;
 }
 
+static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tun->tx_lock);
+	ret = __tun_net_xmit(skb, dev);
+	spin_unlock(&tun->tx_lock);
+
+	return ret;
+}
+
 /** Add the specified Ethernet address to this multicast filter. */
 static void
 add_multi(u32* filter, const u8* addr)
@@ -481,6 +494,7 @@ static void tun_setup(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
+	spin_lock_init(&tun->tx_lock);
 	skb_queue_head_init(&tun->readq);
 	init_waitqueue_head(&tun->read_wait);
 
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index c0dd25b..ec34360 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -286,6 +286,7 @@ struct typhoon {
 	struct net_device *	dev;
 	struct napi_struct	napi;
 	spinlock_t		state_lock;
+	spinlock_t		tx_lock;
 	struct vlan_group *	vlgrp;
 	struct basic_ring	rxHiRing;
 	struct basic_ring	rxBuffRing;
@@ -763,8 +764,7 @@ typhoon_tso_fill(struct sk_buff *skb, struct transmit_ring *txRing,
 	tcpd->status = 0;
 }
 
-static int
-typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
+static int __typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct typhoon *tp = netdev_priv(dev);
 	struct transmit_ring *txRing;
@@ -913,6 +913,18 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct typhoon *tp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tp->tx_lock);
+	ret = __typhoon_start_tx(skb, dev);
+	spin_unlock(&tp->tx_lock);
+
+	return ret;
+}
+
 static void
 typhoon_set_rx_mode(struct net_device *dev)
 {
@@ -1328,6 +1340,7 @@ typhoon_init_interface(struct typhoon *tp)
 
 	spin_lock_init(&tp->command_lock);
 	spin_lock_init(&tp->state_lock);
+	spin_lock_init(&tp->tx_lock);
 }
 
 static void
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 22c17bb..4bbce12 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -168,7 +168,7 @@ struct catc {
 
 	unsigned int tx_ptr, tx_idx;
 	unsigned int ctrl_head, ctrl_tail;
-	spinlock_t tx_lock, ctrl_lock;
+	spinlock_t tx_lock, tx_lock2, ctrl_lock;
 
 	u8 tx_buf[2][TX_MAX_BURST * (PKT_SZ + 2)];
 	u8 rx_buf[RX_MAX_BURST * (PKT_SZ + 2)];
@@ -412,7 +412,8 @@ static void catc_tx_done(struct urb *urb)
 	spin_unlock_irqrestore(&catc->tx_lock, flags);
 }
 
-static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __catc_hard_start_xmit(struct sk_buff *skb,
+				  struct net_device *netdev)
 {
 	struct catc *catc = netdev_priv(netdev);
 	unsigned long flags;
@@ -452,6 +453,18 @@ static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return 0;
 }
 
+static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct catc *catc = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&catc->tx_lock2);
+	ret = __catc_hard_start_xmit(skb, netdev);
+	spin_unlock(&catc->tx_lock2);
+
+	return ret;
+}
+
 static void catc_tx_timeout(struct net_device *netdev)
 {
 	struct catc *catc = netdev_priv(netdev);
@@ -786,6 +799,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	catc->netdev = netdev;
 
 	spin_lock_init(&catc->tx_lock);
+	spin_lock_init(&catc->tx_lock2);
 	spin_lock_init(&catc->ctrl_lock);
 
 	init_timer(&catc->timer);
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 031d07b..e1ca943 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -167,6 +167,7 @@ struct hso_net {
 
 	enum pkt_parse_state rx_parse_state;
 	spinlock_t net_lock;
+	spinlock_t tx_lock;
 
 	unsigned short rx_buf_size;
 	unsigned short rx_buf_missing;
@@ -686,7 +687,7 @@ static void write_bulk_callback(struct urb *urb)
 }
 
 /* called by kernel when we need to transmit a packet */
-static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
+static int __hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct hso_net *odev = netdev_priv(net);
 	int result;
@@ -734,6 +735,18 @@ static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
 	return result;
 }
 
+static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	struct hso_net *odev = netdev_priv(net);
+	int ret;
+
+	spin_lock(&odev->tx_lock);
+	ret = __hso_net_start_xmit(skb, net);
+	spin_unlock(&odev->tx_lock);
+
+	return ret;
+}
+
 static void hso_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 {
 	struct hso_net *odev = netdev_priv(net);
@@ -1996,6 +2009,7 @@ static void hso_net_init(struct net_device *net)
 
 	/* and initialize the semaphore */
 	spin_lock_init(&hso_net->net_lock);
+	spin_lock_init(&hso_net->tx_lock);
 }
 
 /* Adds a network device in the network device table */
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index b588c89..0185cbb 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -871,7 +871,7 @@ static void pegasus_tx_timeout(struct net_device *net)
 	pegasus->stats.tx_errors++;
 }
 
-static int pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
+static int __pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	pegasus_t *pegasus = netdev_priv(net);
 	int count = ((skb->len + 2) & 0x3f) ? skb->len + 2 : skb->len + 3;
@@ -911,6 +911,18 @@ static int pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
 	return 0;
 }
 
+static int pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	pegasus_t *pegasus = netdev_priv(net);
+	int ret;
+
+	spin_lock(&pegasus->tx_lock);
+	ret = __pegasus_start_xmit(skb, net);
+	spin_unlock(&pegasus->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *pegasus_netdev_stats(struct net_device *dev)
 {
 	return &((pegasus_t *) netdev_priv(dev))->stats;
@@ -1333,6 +1345,7 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->mii.phy_id_mask = 0x1f;
 	pegasus->mii.reg_num_mask = 0x1f;
 	spin_lock_init(&pegasus->rx_pool_lock);
+	spin_lock_init(&pegasus->tx_lock);
 	pegasus->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
 				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
 
diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
index c746782..9731ef1 100644
--- a/drivers/net/usb/pegasus.h
+++ b/drivers/net/usb/pegasus.h
@@ -102,6 +102,7 @@ typedef struct pegasus {
 	struct usb_ctrlrequest	dr;
 	wait_queue_head_t	ctrl_wait;
 	spinlock_t		rx_pool_lock;
+	spinlock_t		tx_lock;
 	int			chip;
 	unsigned char		intr_buff[8];
 	__u8			tx_buff[PEGASUS_MTU];
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index df56a51..fe49caf 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -161,6 +161,7 @@ struct rtl8150 {
 	struct sk_buff *tx_skb, *rx_skb;
 	struct sk_buff *rx_skb_pool[RX_SKB_POOL_SIZE];
 	spinlock_t rx_pool_lock;
+	spinlock_t tx_lock;
 	struct usb_ctrlrequest dr;
 	int intr_interval;
 	__le16 rx_creg;
@@ -724,7 +725,7 @@ static void rtl8150_set_multicast(struct net_device *netdev)
 	netif_wake_queue(netdev);
 }
 
-static int rtl8150_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int __rtl8150_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
 	int count, res;
@@ -753,6 +754,17 @@ static int rtl8150_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return 0;
 }
 
+static int rtl8150_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	rtl8150_t *dev = netdev_priv(netdev);
+	int ret;
+
+	spin_lock(&dev->tx_lock);
+	ret = __rtl8150_start_xmit(skb, netdev);
+	spin_unlock(&dev->tx_lock);
+
+	return ret;
+}
 
 static void set_carrier(struct net_device *netdev)
 {
@@ -914,6 +926,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 
 	tasklet_init(&dev->tl, rx_fixup, (unsigned long)dev);
 	spin_lock_init(&dev->rx_pool_lock);
+	spin_lock_init(&dev->tx_lock);
 	
 	dev->udev = udev;
 	dev->netdev = netdev;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8463efb..0c96490 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -921,7 +921,7 @@ static void usbnet_tx_timeout (struct net_device *net)
 
 /*-------------------------------------------------------------------------*/
 
-static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
+static int __usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			length;
@@ -1005,6 +1005,17 @@ drop:
 	return retval;
 }
 
+static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	int ret;
+
+	spin_lock(&dev->tx_lock);
+	ret = __usbnet_start_xmit(skb, net);
+	spin_unlock(&dev->tx_lock);
+
+	return ret;
+}
 
 /*-------------------------------------------------------------------------*/
 
@@ -1149,6 +1160,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	}
 
 	dev = netdev_priv(net);
+	spin_lock_init(&dev->tx_lock);
 	dev->udev = xdev;
 	dev->intf = udev;
 	dev->driver_info = info;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8c9d6ae..b5951c8 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -393,6 +393,7 @@ struct rhine_private {
 	struct napi_struct napi;
 	struct net_device_stats stats;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
@@ -765,6 +766,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
+	spin_lock_init(&rp->tx_lock);
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
 	rp->mii_if.mdio_write = mdio_write;
@@ -1217,7 +1219,7 @@ static void rhine_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
+static int __rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
@@ -1293,6 +1295,18 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&rp->tx_lock);
+	ret = __rhine_start_tx(skb, dev);
+	spin_unlock(&rp->tx_lock);
+
+	return ret;
+}
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4452306..ca36953 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -40,6 +40,7 @@ struct virtnet_info
 	struct virtqueue *rvq, *svq;
 	struct net_device *dev;
 	struct napi_struct napi;
+	spinlock_t tx_lock;
 
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
@@ -326,7 +327,7 @@ static void xmit_tasklet(unsigned long data)
 	netif_tx_unlock_bh(vi->dev);
 }
 
-static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
@@ -373,6 +374,18 @@ stop_queue:
 	goto done;
 }
 
+static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&vi->tx_lock);
+	ret = __start_xmit(skb, dev);
+	spin_unlock(&vi->tx_lock);
+
+	return ret;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void virtnet_netpoll(struct net_device *dev)
 {
@@ -458,6 +471,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
+	spin_lock_init(&vi->tx_lock);
 	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index b0fce13..824495c 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -139,6 +139,7 @@ struct channel_data {
 	struct ppp_device pppdev;
 	struct sk_buff *rx_skb, *tx_skb;
 	struct net_device_stats stats;
+	spinlock_t tx_lock;
 };
 
 /* cosa->firmware_status bits */
@@ -581,6 +582,7 @@ static int cosa_probe(int base, int irq, int dma)
 	for (i=0; i<cosa->nchannels; i++) {
 		cosa->chan[i].cosa = cosa;
 		cosa->chan[i].num = i;
+		spin_lock_init(&cosa->chan[i].tx_lock);
 		channel_init(cosa->chan+i);
 	}
 
@@ -692,10 +694,13 @@ static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct channel_data *chan = dev->ml_priv;
 
+	spin_lock(&chan->tx_lock);
 	netif_stop_queue(dev);
 
 	chan->tx_skb = skb;
 	cosa_start_tx(chan, skb->data, skb->len);
+	spin_unlock(&chan->tx_lock);
+
 	return 0;
 }
 
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index d3b28b0..f41c168 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -110,6 +110,7 @@ struct cycx_x25_channel {
 	char addr[WAN_ADDRESS_SZ+1];	/* media address, ASCIIZ */
 	char *local_addr;		/* local media address, ASCIIZ -
 					   svc thru crossover cable */
+	spinlock_t tx_lock;
 	s16 lcn;			/* logical channel number/conn.req.key*/
 	u8 link;
 	struct timer_list timer;	/* timer used for svc channel disc. */
@@ -488,6 +489,8 @@ static int cycx_netdevice_init(struct net_device *dev)
 	struct cycx_device *card = chan->card;
 	struct wan_device *wandev = &card->wandev;
 
+	spin_lock_init(&chan->tx_lock);
+
 	/* Initialize device driver entry points */
 	dev->open		= cycx_netdevice_open;
 	dev->stop		= cycx_netdevice_stop;
@@ -593,8 +596,8 @@ static int cycx_netdevice_rebuild_header(struct sk_buff *skb)
  *    bottom half" (with interrupts enabled).
  * 2. Setting tbusy flag will inhibit further transmit requests from the
  *    protocol stack and can be used for flow control with protocol layer. */
-static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
-					  struct net_device *dev)
+static int __cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct cycx_x25_channel *chan = dev->priv;
 	struct cycx_device *card = chan->card;
@@ -666,6 +669,19 @@ free_packet:
 	return 0;
 }
 
+static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
+					  struct net_device *dev)
+{
+	struct cycx_x25_channel *chan = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&chan->tx_lock);
+	ret = __cycx_netdevice_hard_start_xmit(skb, dev);
+	spin_unlock(&chan->tx_lock);
+
+	return ret;
+}
+
 /* Get Ethernet-style interface statistics.
  * Return a pointer to struct net_device_stats */
 static struct net_device_stats *cycx_netdevice_get_stats(struct net_device *dev)
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index b142427..1ab90bc 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -187,7 +187,7 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 }
 
-static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
+static int __dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dlci_local *dlp;
 	int					ret;
@@ -228,6 +228,18 @@ static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	return(ret);
 }
 
+static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dlci_local *dlp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&dlp->tx_lock);
+	ret = __dlci_transmit(skb, dev);
+	spin_unlock(&dlp->tx_lock);
+
+	return ret;
+}
+
 static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, int get)
 {
 	struct dlci_conf	config;
@@ -493,6 +505,7 @@ static void dlci_setup(struct net_device *dev)
 {
 	struct dlci_local *dlp = dev->priv;
 
+	spin_lock_init(&dlp->tx_lock);
 	dev->flags		= 0;
 	dev->open		= dlci_open;
 	dev->stop		= dlci_close;
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index c6f26e2..b68770d 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -197,6 +197,7 @@ struct dscc4_dev_priv {
         struct sk_buff *rx_skbuff[RX_RING_SIZE];
         struct sk_buff *tx_skbuff[TX_RING_SIZE];
 
+        spinlock_t tx_lock;
         struct RxFD *rx_fd;
         struct TxFD *tx_fd;
         __le32 *iqrx;
@@ -783,6 +784,11 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 
 	rc = -ENOMEM;
 
+	for (i = 0; i < dev_per_card; i++) {
+		dpriv = priv->root + i;
+		spin_lock_init(&dpriv->tx_lock);
+	}
+
 	/*
 	 * SCC 0-3 private rx/tx irq structures
 	 * IQRX/TXi needs to be set soon. Learned it the hard way...
@@ -1148,7 +1154,7 @@ static int dscc4_tx_poll(struct dscc4_dev_priv *dpriv, struct net_device *dev)
 }
 #endif /* DSCC4_POLLING */
 
-static int dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
 	struct dscc4_pci_priv *ppriv = dpriv->pci_priv;
@@ -1185,6 +1191,18 @@ static int dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
+	int ret;
+
+	spin_lock(&dpriv->tx_lock);
+	ret = __dscc4_start_xmit(skb, dev);
+	spin_unlock(&dpriv->tx_lock);
+
+	return ret;
+}
+
 static int dscc4_close(struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 547368e..24bf627 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -453,6 +453,7 @@ struct fst_card_info {
 	unsigned int type;	/* Type index of card */
 	unsigned int state;	/* State of card */
 	spinlock_t card_lock;	/* Lock for SMP access */
+	spinlock_t tx_lock;
 	unsigned short pci_conf;	/* PCI card config in I/O space */
 	/* Per port info */
 	struct fst_port_info ports[FST_MAX_PORTS];
@@ -2307,8 +2308,7 @@ fst_tx_timeout(struct net_device *dev)
 	port->start = 0;
 }
 
-static int
-fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fst_card_info *card;
 	struct fst_port_info *port;
@@ -2391,6 +2391,19 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fst_port_info *port = dev_to_port(dev);
+	struct fst_card_info *card = port->card;
+	int ret;
+
+	spin_lock(&card->tx_lock);
+	ret = __fst_start_xmit(skb, dev);
+	spin_unlock(&card->tx_lock);
+
+	return ret;
+}
+
 /*
  *      Card setup having checked hardware resources.
  *      Should be pretty bizarre if we get an error here (kernel memory
@@ -2545,6 +2558,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	card->state = FST_UNINIT;
         spin_lock_init ( &card->card_lock );
+        spin_lock_init(&card->tx_lock);
 
         for ( i = 0 ; i < card->nports ; i++ ) {
 		struct net_device *dev = alloc_hdlcdev(&card->ports[i]);
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 7f98489..ebeb2f9 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -253,6 +253,7 @@ static void hdlc_setup(struct net_device *dev)
 	hdlc->carrier = 1;
 	hdlc->open = 0;
 	spin_lock_init(&hdlc->state_lock);
+	spin_lock_init(&hdlc->tx_lock);
 }
 
 struct net_device *alloc_hdlcdev(void *priv)
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 520bb0b..5574ae2 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -123,6 +123,7 @@ typedef struct pvc_device_struct {
 	struct pvc_device_struct *next;	/* Sorted in ascending DLCI order */
 	int dlci;
 	int open_count;
+	spinlock_t tx_lock;
 
 	struct {
 		unsigned int new: 1;
@@ -225,6 +226,7 @@ static pvc_device* add_pvc(struct net_device *dev, u16 dlci)
 	if (!pvc)
 		return NULL;
 
+	spin_lock_init(&pvc->tx_lock);
 	pvc->dlci = dlci;
 	pvc->frad = dev;
 	pvc->next = *pvc_p;	/* Put it in the chain */
@@ -422,7 +424,7 @@ static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EINVAL;
 }
 
-static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 	struct net_device_stats *stats = pvc_get_stats(dev);
@@ -460,7 +462,17 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
+	int ret;
+
+	spin_lock(&pvc->tx_lock);
+	ret = __pvc_xmit(skb, dev);
+	spin_unlock(&pvc->tx_lock);
 
+	return ret;
+}
 
 static int pvc_change_mtu(struct net_device *dev, int new_mtu)
 {
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index d20c685..e891542 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -28,7 +28,9 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr);
 
 static int eth_tx(struct sk_buff *skb, struct net_device *dev)
 {
+	hdlc_device *hdlc = dev_to_hdlc(dev);
 	int pad = ETH_ZLEN - skb->len;
+	int ret;
 	if (pad > 0) {		/* Pad the frame with zeros */
 		int len = skb->len;
 		if (skb_tailroom(skb) < pad)
@@ -40,7 +42,11 @@ static int eth_tx(struct sk_buff *skb, struct net_device *dev)
 		skb_put(skb, pad);
 		memset(skb->data + len, 0, pad);
 	}
-	return dev_to_hdlc(dev)->xmit(skb, dev);
+	spin_lock(&hdlc->tx_lock);
+	ret = dev_to_hdlc(dev)->xmit(skb, dev);
+	spin_unlock(&hdlc->tx_lock);
+
+	return ret;
 }
 
 
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index c15cc11..ffe5357 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -88,7 +88,7 @@ static void x25_data_transmit(struct net_device *dev, struct sk_buff *skb)
 
 
 
-static int x25_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __x25_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int result;
 
@@ -133,7 +133,17 @@ static int x25_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int x25_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	int ret;
+
+	spin_lock(&hdlc->tx_lock);
+	ret = __x25_xmit(skb, dev);
+	spin_unlock(&hdlc->tx_lock);
 
+	return ret;
+}
 
 static int x25_open(struct net_device *dev)
 {
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index f3065d3..b30a647 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -40,6 +40,7 @@ static int dma;
 
 struct sv11_device
 {
+	spinlock_t tx_lock;
 	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	struct z8530_dev sync;
 	struct ppp_device netdev;
@@ -180,7 +181,13 @@ static struct net_device_stats *hostess_get_stats(struct net_device *d)
 static int hostess_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
 	struct sv11_device *sv11=d->ml_priv;
-	return z8530_queue_xmit(&sv11->sync.chanA, skb);
+	int ret;
+
+	spin_lock(&sv11->tx_lock);
+	ret = z8530_queue_xmit(&sv11->sync.chanA, skb);
+	spin_unlock(&sv11->tx_lock);
+
+	return ret;
 }
 
 static int hostess_neigh_setup(struct neighbour *n)
@@ -235,6 +242,7 @@ static struct sv11_device *sv11_init(int iobase, int irq)
 	if(!sv)
 		goto fail3;
 			
+	spin_lock_init(&sv->tx_lock);
 	sv->if_ptr=&sv->netdev;
 	
 	sv->netdev.dev = alloc_netdev(0, "hdlc%d", sv11_setup);
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 24fd613..d3b124b 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -52,6 +52,7 @@ static char bcast_addr[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 #define MAXLAPBDEV 100
 
 struct lapbethdev {
+	spinlock_t		tx_lock;
 	struct list_head	node;
 	struct net_device	*ethdev;	/* link to ethernet device */
 	struct net_device	*axdev;		/* lapbeth device (lapb#) */
@@ -150,7 +151,7 @@ static int lapbeth_data_indication(struct net_device *dev, struct sk_buff *skb)
 /*
  *	Send a LAPB frame via an ethernet interface
  */
-static int lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int err = -ENODEV;
 
@@ -197,6 +198,18 @@ drop:
 	goto out;
 }
 
+static int lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lapbethdev *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __lapbeth_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 static void lapbeth_data_transmit(struct net_device *ndev, struct sk_buff *skb)
 {
 	struct lapbethdev *lapbeth = netdev_priv(ndev);
@@ -348,6 +361,7 @@ static int lapbeth_new_device(struct net_device *dev)
 		goto out;
 
 	lapbeth = netdev_priv(ndev);
+	spin_lock_init(&lapbeth->tx_lock);
 	lapbeth->axdev = ndev;
 
 	dev_hold(dev);
diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 63e9fcf..039b407 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -403,6 +403,7 @@ typedef struct pc300 {
 	pc300ch_t chan[PC300_MAXCHAN];
 #ifdef __KERNEL__
 	spinlock_t card_lock;
+	spinlock_t tx_lock;
 #endif /* __KERNEL__ */
 } pc300_t;
 
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 57914fb..ea4d7f5 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1798,7 +1798,7 @@ static void cpc_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
@@ -1881,6 +1881,20 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
+	pc300ch_t *chan = (pc300ch_t *) d->chan;
+	pc300_t *card = (pc300_t *) chan->card;
+	int ret;
+
+	spin_lock(&card->tx_lock);
+	ret = __cpc_queue_xmit(skb, dev);
+	spin_unlock(&card->tx_lock);
+
+	return ret;
+}
+
 static void cpc_net_rx(struct net_device *dev)
 {
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
@@ -3433,6 +3447,7 @@ static void cpc_init_card(pc300_t * card)
 		}
 	}
 	spin_lock_init(&card->card_lock);
+	spin_lock_init(&card->tx_lock);
 
 	board_nbr++;
 }
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index e59255a..c3907db 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -72,6 +72,7 @@ struct net_local {
 	struct timer_list	watchdog;
 
 	spinlock_t	lock;
+	spinlock_t	tx_lock;
 	struct sk_buff  *rx_buf_p;		/* receive buffer ptr */
 	struct sk_buff  *tx_buf_p;		/* transmit buffer ptr */
 	
@@ -389,6 +390,7 @@ sbni_probe1( struct net_device  *dev,  unsigned long  ioaddr,  int  irq )
 	dev->priv = nl;
 	memset( nl, 0, sizeof(struct net_local) );
 	spin_lock_init( &nl->lock );
+	spin_lock_init(&nl->tx_lock);
 
 	/* store MAC address (generate if that isn't known) */
 	*(__be16 *)dev->dev_addr = htons( 0x00ff );
@@ -439,7 +441,7 @@ sbni_probe1( struct net_device  *dev,  unsigned long  ioaddr,  int  irq )
 #ifdef CONFIG_SBNI_MULTILINE
 
 static int
-sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
+__sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 {
 	struct net_device  *p;
 
@@ -467,7 +469,7 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 #else	/* CONFIG_SBNI_MULTILINE */
 
 static int
-sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
+__sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 {
 	struct net_local  *nl  = (struct net_local *) dev->priv;
 
@@ -482,6 +484,18 @@ sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 
 #endif	/* CONFIG_SBNI_MULTILINE */
 
+static int sbni_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_local *nl  = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&nl->tx_lock);
+	ret = __sbni_start_xmit(skb, dev);
+	spin_unlock(&nl->tx_lock);
+
+	return ret;
+}
+
 /* -------------------------------------------------------------------------- */
 
 /* interrupt handler */
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 73e2f27..6604543 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -651,7 +651,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
  **************************/
 
 /* NOTE: the DLCI driver deals with freeing the SKB!! */
-static int sdla_transmit(struct sk_buff *skb, struct net_device *dev)
+static int __sdla_transmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct frad_local *flp;
 	int               ret, addr, accept, i;
@@ -740,6 +740,18 @@ static int sdla_transmit(struct sk_buff *skb, struct net_device *dev)
 	return(ret);
 }
 
+static int sdla_transmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct frad_local *fp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&fp->tx_lock);
+	ret = __sdla_transmit(skb, dev);
+	spin_unlock(&fp->tx_lock);
+
+	return ret;
+}
+
 static void sdla_receive(struct net_device *dev)
 {
 	struct net_device	  *master;
@@ -1634,6 +1646,7 @@ static struct net_device *sdla;
 
 static int __init init_sdla(void)
 {
+	struct frad_local *fp;
 	int err;
 
 	printk("%s.\n", version);
@@ -1642,6 +1655,9 @@ static int __init init_sdla(void)
 	if (!sdla) 
 		return -ENOMEM;
 
+	fp = netdev_priv(sdla);
+	spin_lock_init(&fp->tx_lock);
+
 	err = register_netdev(sdla);
 	if (err) 
 		free_netdev(sdla);
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 44a89df..3843113 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -33,6 +33,7 @@
 
 struct slvl_device
 {
+	spinlock_t tx_lock;
 	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	struct z8530_channel *chan;
 	struct ppp_device pppdev;
@@ -180,7 +181,13 @@ static struct net_device_stats *sealevel_get_stats(struct net_device *d)
 static int sealevel_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
 	struct slvl_device *slvl=d->priv;
-	return z8530_queue_xmit(slvl->chan, skb);
+	int ret;
+
+	spin_lock(&slvl->tx_lock);
+	ret = z8530_queue_xmit(slvl->chan, skb);
+	spin_unlock(&slvl->tx_lock);
+
+	return ret;
 }
 
 static int sealevel_neigh_setup(struct neighbour *n)
@@ -241,6 +248,7 @@ static inline struct slvl_device *slvl_alloc(int iobase, int irq)
 		return NULL;
 
 	sv = d->priv;
+	spin_lock_init(&sv->tx_lock);
 	d->ml_priv = sv;
 	sv->if_ptr = &sv->pppdev;
 	sv->pppdev.dev = d;
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 249e180..686e551 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -298,7 +298,7 @@ static void x25_asy_timeout(struct net_device *dev)
 
 /* Encapsulate an IP datagram and kick it into a TTY queue. */
 
-static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct x25_asy *sl = dev->priv;
 	int err;
@@ -348,6 +348,17 @@ static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct x25_asy *sl = dev->priv;
+	int ret;
+
+	spin_lock(&sl->tx_lock);
+	ret = __x25_asy_xmit(skb, dev);
+	spin_unlock(&sl->tx_lock);
+
+	return ret;
+}
 
 /*
  *	LAPB interface boilerplate
@@ -728,6 +739,7 @@ static void x25_asy_setup(struct net_device *dev)
 	sl->magic  = X25_ASY_MAGIC;
 	sl->dev	   = dev;
 	spin_lock_init(&sl->lock);
+	spin_lock_init(&sl->tx_lock);
 	set_bit(SLF_INUSE, &sl->flags);
 
 	/*
diff --git a/drivers/net/wan/x25_asy.h b/drivers/net/wan/x25_asy.h
index 4177020..3aa3b99 100644
--- a/drivers/net/wan/x25_asy.h
+++ b/drivers/net/wan/x25_asy.h
@@ -19,6 +19,7 @@ struct x25_asy {
 
   /* Various fields. */
   spinlock_t		lock;
+  spinlock_t		tx_lock;
   struct tty_struct	*tty;		/* ptr to TTY structure		*/
   struct net_device	*dev;		/* easy for intr handling	*/
 
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index e30f8b7..2ff77ea 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1150,6 +1150,7 @@ static void airo_networks_free(struct airo_info *ai);
 struct airo_info {
 	struct net_device             *dev;
 	struct list_head              dev_list;
+	spinlock_t                    tx_lock;
 	/* Note, we can have MAX_FIDS outstanding.  FIDs are 16-bits, so we
 	   use the high bit to mark whether it is in use. */
 #define MAX_FIDS 6
@@ -1909,7 +1910,8 @@ static int airo_open(struct net_device *dev) {
 	return 0;
 }
 
-static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
+static int __mpi_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
 	int npacks, pending;
 	unsigned long flags;
 	struct airo_info *ai = dev->priv;
@@ -1943,6 +1945,18 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	return 0;
 }
 
+static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct airo_info *ai = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ai->tx_lock);
+	ret = __mpi_start_xmit(skb, dev);
+	spin_unlock(&ai->tx_lock);
+
+	return ret;
+}
+
 /*
  * @mpi_send_packet
  *
@@ -2108,7 +2122,8 @@ static void airo_end_xmit(struct net_device *dev) {
 	dev_kfree_skb(skb);
 }
 
-static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
+static int __airo_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
 	s16 len;
 	int i, j;
 	struct airo_info *priv = dev->priv;
@@ -2147,6 +2162,18 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	return 0;
 }
 
+static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct airo_info *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __airo_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void airo_end_xmit11(struct net_device *dev) {
 	u16 status;
 	int i;
@@ -2173,7 +2200,8 @@ static void airo_end_xmit11(struct net_device *dev) {
 	dev_kfree_skb(skb);
 }
 
-static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
+static int __airo_start_xmit11(struct sk_buff *skb, struct net_device *dev)
+{
 	s16 len;
 	int i, j;
 	struct airo_info *priv = dev->priv;
@@ -2218,6 +2246,18 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 	return 0;
 }
 
+static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev)
+{
+	struct airo_info *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __airo_start_xmit11(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void airo_read_stats(struct net_device *dev)
 {
 	struct airo_info *ai = dev->priv;
@@ -2767,6 +2807,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	}
 
 	ai = dev->priv;
+	spin_lock_init(&ai->tx_lock);
 	ai->wifidev = NULL;
 	ai->flags = 1 << FLAG_RADIO_DOWN;
 	ai->jobs = 0;
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index dec5e87..d791155 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1052,6 +1052,7 @@ static int __init arlan_setup_device(struct net_device *dev, int num)
 	dev->tx_timeout = arlan_tx_timeout;
 	dev->watchdog_timeo = 3*HZ;
 	
+	spin_lock_init(&ap->tx_lock);
 	ap->irq_test_done = 0;
 	ap->Conf = &arlan_conf[num];
 
@@ -1166,7 +1167,7 @@ static void arlan_tx_timeout (struct net_device *dev)
 }
 
 
-static int arlan_tx(struct sk_buff *skb, struct net_device *dev)
+static int __arlan_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	short length;
 	unsigned char *buf;
@@ -1200,6 +1201,18 @@ bad_end:
 }
 
 
+static int arlan_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct arlan_private *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __arlan_tx(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static inline int DoNotReTransmitCrap(struct net_device *dev)
 {
 	struct arlan_private *priv = netdev_priv(dev);
diff --git a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
index fb3ad51..5be5eac 100644
--- a/drivers/net/wireless/arlan.h
+++ b/drivers/net/wireless/arlan.h
@@ -346,6 +346,7 @@ struct arlan_private {
       int reRegisterExp;
       int irq_test_done;
 
+      spinlock_t tx_lock;
       struct TxParam txRing[TX_RING_SIZE];
       char reTransmitBuff[0x800];
       int txLast;
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 7bb2646..35573f5 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -433,7 +433,7 @@ struct atmel_private {
 	struct net_device *dev;
 	struct device *sys_dev;
 	struct iw_statistics wstats;
-	spinlock_t irqlock, timerlock;	// spinlocks
+	spinlock_t irqlock, tx_lock, timerlock; // spinlocks
 	enum { BUS_TYPE_PCCARD, BUS_TYPE_PCI } bus_type;
 	enum {
 		CARD_TYPE_PARALLEL_FLASH,
@@ -781,7 +781,7 @@ static void tx_update_descriptor(struct atmel_private *priv, int is_bcast,
 	priv->tx_free_mem -= len;
 }
 
-static int start_tx(struct sk_buff *skb, struct net_device *dev)
+static int __start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	static const u8 SNAP_RFC1024[6] = { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
 	struct atmel_private *priv = netdev_priv(dev);
@@ -859,6 +859,18 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int start_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct atmel_private *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __start_tx(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void atmel_transmit_management_frame(struct atmel_private *priv,
 					    struct ieee80211_hdr_4addr *header,
 					    u8 *body, int body_len)
@@ -1550,6 +1562,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 
 	init_timer(&priv->management_timer);
 	spin_lock_init(&priv->irqlock);
+	spin_lock_init(&priv->tx_lock);
 	spin_lock_init(&priv->timerlock);
 	priv->management_timer.function = atmel_management_timer;
 	priv->management_timer.data = (unsigned long) dev;
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 921c984..3c8314d 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -53,7 +53,8 @@ void hostap_dump_tx_80211(const char *name, struct sk_buff *skb)
 /* hard_start_xmit function for data interfaces (wlan#, wlan#wds#, wlan#sta)
  * Convert Ethernet header into a suitable IEEE 802.11 header depending on
  * device configuration. */
-int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __hostap_data_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -259,9 +260,21 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&iface->tx_lock);
+	ret = __hostap_data_start_xmit(skb, dev);
+	spin_unlock(&iface->tx_lock);
+
+	return ret;
+}
 
 /* hard_start_xmit function for hostapd wlan#ap interfaces */
-int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __hostap_mgmt_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -304,6 +317,17 @@ int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+int hostap_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&iface->tx_lock);
+	ret = __hostap_mgmt_start_xmit(skb, dev);
+	spin_unlock(&iface->tx_lock);
+
+	return ret;
+}
 
 /* Called only from software IRQ */
 static struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
@@ -377,7 +401,8 @@ static struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
 /* hard_start_xmit function for master radio interface wifi#.
  * AP processing (TX rate control, power save buffering, etc.).
  * Use hardware TX function to send the frame. */
-int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __hostap_master_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
@@ -545,5 +570,16 @@ int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+int hostap_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&iface->tx_lock);
+	ret = __hostap_master_start_xmit(skb, dev);
+	spin_unlock(&iface->tx_lock);
+
+	return ret;
+}
 
 EXPORT_SYMBOL(hostap_master_start_xmit);
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index f7aec93..2fcb6d5 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -877,6 +877,7 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 		 * the main_dev. This could be fixed. Jean II */
 		iface->wireless_data.spy_data = &iface->spy_data;
 		dev->wireless_data = &iface->wireless_data;
+		spin_lock_init(&iface->tx_lock);
 	}
 	dev->wireless_handlers =
 		(struct iw_handler_def *) &hostap_iw_handler_def;
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 15445bc..2d3a727 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -885,6 +885,7 @@ struct hostap_interface {
 	struct net_device_stats stats;
 	struct iw_spy_data spy_data; /* iwspy support */
 	struct iw_public_data wireless_data;
+	spinlock_t tx_lock;
 
 	enum {
 		HOSTAP_INTERFACE_MASTER,
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index f5bb40c..ec1c613 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -201,6 +201,7 @@ struct lbs_private {
 
 	/** spin locks */
 	spinlock_t driver_lock;
+	spinlock_t tx_lock;
 
 	/** Timers */
 	struct timer_list command_timer;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 14d5d61..82c7da7 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1059,6 +1059,7 @@ static int lbs_init_adapter(struct lbs_private *priv)
 	INIT_LIST_HEAD(&priv->cmdpendingq);
 
 	spin_lock_init(&priv->driver_lock);
+	spin_lock_init(&priv->tx_lock);
 	init_waitqueue_head(&priv->cmd_pending);
 
 	/* Allocate the command buffers */
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index a4972fe..f4d77c9 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -57,7 +57,7 @@ static u32 convert_radiotap_rate_to_mv(u8 rate)
  *  @param skb     A pointer to skb which includes TX packet
  *  @return 	   0 or -1
  */
-int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
 	struct lbs_private *priv = dev->priv;
@@ -170,6 +170,18 @@ int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lbs_private *priv = dev->priv;
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __lbs_hard_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /**
  *  @brief This function sends to the host the last transmitted packet,
  *  filling the radiotap headers with transmission information.
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index f479c1a..de31d32 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -277,6 +277,7 @@ typedef struct netwave_private {
     struct site_survey     nss;
     struct net_device_stats stats;
     struct iw_statistics   iw_stats;    /* Wireless stats */
+    spinlock_t tx_lock;
 } netwave_private;
 
 #ifdef NETWAVE_STATS
@@ -387,6 +388,7 @@ static int netwave_probe(struct pcmcia_device *link)
     if (!dev)
 	return -ENOMEM;
     priv = netdev_priv(dev);
+    spin_lock_init(&priv->tx_lock);
     priv->p_dev = link;
     link->priv = dev;
 
@@ -1029,7 +1031,8 @@ static int netwave_hw_xmit(unsigned char* data, int len,
     return 0;
 }
 
-static int netwave_start_xmit(struct sk_buff *skb, struct net_device *dev) {
+static int __netwave_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
 	/* This flag indicate that the hardware can't perform a transmission.
 	 * Theoritically, NET3 check it before sending a packet to the driver,
 	 * but in fact it never do that and pool continuously.
@@ -1053,6 +1056,18 @@ static int netwave_start_xmit(struct sk_buff *skb, struct net_device *dev) {
     return 0;
 } /* netwave_start_xmit */
 
+static int netwave_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netwave_private *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __netwave_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /*
  * Function netwave_interrupt (irq, dev_id)
  *
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 6d13a0d..fc22fd8 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -445,7 +445,7 @@ static int orinoco_change_mtu(struct net_device *dev, int new_mtu)
 /* Tx path                                                          */
 /********************************************************************/
 
-static int orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
@@ -573,6 +573,18 @@ static int orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_BUSY;
 }
 
+static int orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __orinoco_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 static void __orinoco_ev_alloc(struct net_device *dev, hermes_t *hw)
 {
 	struct orinoco_private *priv = netdev_priv(dev);
@@ -2579,6 +2591,7 @@ struct net_device *alloc_orinocodev(int sizeof_card,
 	priv->hard_reset = hard_reset;
 
 	spin_lock_init(&priv->lock);
+	spin_lock_init(&priv->tx_lock);
 	priv->open = 0;
 	priv->hw_unavailable = 1; /* orinoco_init() must clear this
 				   * before anything else touches the
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
index c6b1858..8aa9c5a 100644
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -48,6 +48,7 @@ struct orinoco_private {
 
 	/* Synchronisation stuff */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	int hw_unavailable;
 	struct work_struct reset_work;
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 963960d..2f5c816 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -317,6 +317,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	    goto fail_alloc_dev;
 
     local = netdev_priv(dev);
+    spin_lock_init(&local->tx_lock);
     local->finder = p_dev;
 
     /* The io structure describes IO port mapping. None used here */
@@ -880,7 +881,7 @@ static int ray_dev_config(struct net_device *dev, struct ifmap *map)
     return 0;
 }
 /*===========================================================================*/
-static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     ray_dev_t *local = netdev_priv(dev);
     struct pcmcia_device *link = local->finder;
@@ -921,6 +922,19 @@ static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
     }
     return 0;
 } /* ray_dev_start_xmit */
+
+static int ray_dev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+    ray_dev_t *local = netdev_priv(dev);
+    int ret;
+
+    spin_lock(&local->tx_lock);
+    ret = __ray_dev_start_xmit(skb, dev);
+    spin_unlock(&local->tx_lock);
+
+    return ret;
+}
+
 /*===========================================================================*/
 static int ray_hw_xmit(unsigned char* data, int len, struct net_device* dev, 
                 UCHAR msg_type)
diff --git a/drivers/net/wireless/ray_cs.h b/drivers/net/wireless/ray_cs.h
index 1e23b7f..c79ce0b 100644
--- a/drivers/net/wireless/ray_cs.h
+++ b/drivers/net/wireless/ray_cs.h
@@ -23,6 +23,7 @@ struct beacon_rx {
 #define ECARDGONE (-3)
 
 typedef struct ray_dev_t {
+    spinlock_t tx_lock;
     int card_status;
     int authentication_state;
     dev_node_t  node;
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 883af89..7932ddb 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -438,6 +438,7 @@ static const long LongTime = 0x7FFFFFFF;
 
 static LIST_HEAD(strip_list);
 static DEFINE_SPINLOCK(strip_lock);
+static DEFINE_SPINLOCK(strip_tx_lock);
 
 /************************************************************************/
 /* Macros								*/
@@ -1532,7 +1533,7 @@ static void strip_send(struct strip *strip_info, struct sk_buff *skb)
 }
 
 /* Encapsulate a datagram and kick it into a TTY queue. */
-static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __strip_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct strip *strip_info = netdev_priv(dev);
 
@@ -1584,6 +1585,17 @@ static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int strip_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&strip_tx_lock);
+	ret = __strip_xmit(skb, dev);
+	spin_unlock(&strip_tx_lock);
+
+	return ret;
+}
+
 /*
  * IdleTask periodically calls strip_xmit, so even when we have no IP packets
  * to send for an extended period of time, the watchdog processing still gets
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 49ae970..1f9de86 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2870,7 +2870,7 @@ static int wv_packet_write(struct net_device * dev, void *buf, short length)
  * the packet.  We also prevent reentrance.  Then we call the function
  * to send the packet.
  */
-static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
+static int __wavelan_packet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	net_local *lp = (net_local *) dev->priv;
 	unsigned long flags;
@@ -2927,6 +2927,18 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 	return 0;
 }
 
+static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	net_local *lp = (net_local *) dev->priv;
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __wavelan_packet_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /*********************** HARDWARE CONFIGURATION ***********************/
 /*
  * This part does the real job of starting and configuring the hardware.
@@ -4148,6 +4160,7 @@ static int __init wavelan_config(struct net_device *dev, unsigned short ioaddr)
 
 	/* Init spinlock */
 	spin_lock_init(&lp->spinlock);
+	spin_lock_init(&lp->tx_lock);
 
 	dev->open = wavelan_open;
 	dev->stop = wavelan_close;
diff --git a/drivers/net/wireless/wavelan.p.h b/drivers/net/wireless/wavelan.p.h
index b33ac47..191398d 100644
--- a/drivers/net/wireless/wavelan.p.h
+++ b/drivers/net/wireless/wavelan.p.h
@@ -483,6 +483,7 @@ struct net_local
   net_local *	next;		/* linked list of the devices */
   struct net_device *	dev;		/* reverse link */
   spinlock_t	spinlock;	/* Serialize access to the hardware (SMP) */
+  spinlock_t	tx_lock;
   en_stats	stats;		/* Ethernet interface statistics */
   int		nresets;	/* number of hardware resets */
   u_char	reconfig_82586;	/* We need to reconfigure the controller. */
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index b584c0e..73767a0 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3115,9 +3115,7 @@ wv_packet_write(struct net_device *	dev,
  * the packet. We also prevent reentrance. Then, we call the function
  * to send the packet...
  */
-static int
-wavelan_packet_xmit(struct sk_buff *	skb,
-		    struct net_device *		dev)
+static int __wavelan_packet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
   net_local *		lp = netdev_priv(dev);
   unsigned long		flags;
@@ -3167,6 +3165,18 @@ wavelan_packet_xmit(struct sk_buff *	skb,
   return(0);
 }
 
+static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	net_local *lp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&lp->tx_lock);
+	ret = __wavelan_packet_xmit(skb, dev);
+	spin_unlock(&lp->tx_lock);
+
+	return ret;
+}
+
 /********************** HARDWARE CONFIGURATION **********************/
 /*
  * This part do the real job of starting and configuring the hardware.
@@ -4530,6 +4540,7 @@ wavelan_probe(struct pcmcia_device *p_dev)
 
   /* Init spinlock */
   spin_lock_init(&lp->spinlock);
+  spin_lock_init(&lp->tx_lock);
 
   /* back links */
   lp->dev = dev;
diff --git a/drivers/net/wireless/wavelan_cs.p.h b/drivers/net/wireless/wavelan_cs.p.h
index 628192d..d2a5c59 100644
--- a/drivers/net/wireless/wavelan_cs.p.h
+++ b/drivers/net/wireless/wavelan_cs.p.h
@@ -600,6 +600,7 @@ struct net_local
   dev_node_t 	node;		/* ???? What is this stuff ???? */
   struct net_device *	dev;		/* Reverse link... */
   spinlock_t	spinlock;	/* Serialize access to the hardware (SMP) */
+  spinlock_t	tx_lock;
   struct pcmcia_device *	link;		/* pcmcia structure */
   en_stats	stats;		/* Ethernet interface statistics */
   int		nresets;	/* Number of hw resets */
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index d5c0c66..70c57bf 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -781,7 +781,8 @@ static int zd1201_net_stop(struct net_device *dev)
 				(llc+snap+type+payload)
 		zd		1 null byte, zd1201 packet type
  */
-static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __zd1201_hard_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
 {
 	struct zd1201 *zd = (struct zd1201 *)dev->priv;
 	unsigned char *txbuf = zd->txdata;
@@ -831,6 +832,18 @@ static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct zd1201 *zd = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&zd->tx_lock);
+	ret = __zd1201_hard_start_xmit(skb, dev);
+	spin_unlock(&zd->tx_lock);
+
+	return ret;
+}
+
 static void zd1201_tx_timeout(struct net_device *dev)
 {
 	struct zd1201 *zd = (struct zd1201 *)dev->priv;
@@ -1736,6 +1749,7 @@ static int zd1201_probe(struct usb_interface *interface,
 	zd = kzalloc(sizeof(struct zd1201), GFP_KERNEL);
 	if (!zd)
 		return -ENOMEM;
+	spin_lock_init(&zd->tx_lock);
 	zd->ap = ap;
 	zd->usb = usb;
 	zd->removed = 0;
diff --git a/drivers/net/wireless/zd1201.h b/drivers/net/wireless/zd1201.h
index 235f0ee..fa28fc6 100644
--- a/drivers/net/wireless/zd1201.h
+++ b/drivers/net/wireless/zd1201.h
@@ -29,6 +29,7 @@ struct zd1201 {
 	struct net_device_stats stats;
 	struct iw_statistics	iwstats;
 
+	spinlock_t		tx_lock;
 	int			endp_in;
 	int			endp_out;
 	int			endp_out2;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 57e1f49..d864ecf 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -314,6 +314,7 @@ struct yellowfin_private {
 	dma_addr_t rx_ring_dma;
 	dma_addr_t tx_ring_dma;
 
+	spinlock_t tx_lock;
 	struct tx_status_words *tx_status;
 	dma_addr_t tx_status_dma;
 
@@ -423,6 +424,7 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, dev);
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->tx_lock);
 
 	np->pci_dev = pdev;
 	np->chip_id = chip_idx;
@@ -800,7 +802,7 @@ static void yellowfin_init_ring(struct net_device *dev)
 	return;
 }
 
-static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
 	unsigned entry;
@@ -880,6 +882,18 @@ static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct yellowfin_private *yp = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&yp->tx_lock);
+	ret = __yellowfin_start_xmit(skb, dev);
+	spin_unlock(&yp->tx_lock);
+
+	return ret;
+}
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index a86c022..13f46aa 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -129,6 +129,7 @@ MODULE_LICENSE("GPL");
 struct znet_private {
 	int rx_dma, tx_dma;
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	short sia_base, sia_size, io_size;
 	struct i82593_conf_block i593_init;
 	/* The starting, current, and end pointers for the packet buffers. */
@@ -418,6 +419,7 @@ static int __init znet_probe (void)
 	znet->rx_dma = netinfo->dma1;
 	znet->tx_dma = netinfo->dma2;
 	spin_lock_init(&znet->lock);
+	spin_lock_init(&znet->tx_lock);
 	znet->sia_base = 0xe6;	/* Magic address for the 82501 SIA */
 	znet->sia_size = 2;
 	/* maz: Despite the '593 being advertised above as using a
@@ -528,7 +530,7 @@ static void znet_tx_timeout (struct net_device *dev)
 	netif_wake_queue (dev);
 }
 
-static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
+static int __znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 	struct znet_private *znet = dev->priv;
@@ -597,6 +599,18 @@ static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
+{
+	struct znet_private *znet = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&znet->tx_lock);
+	ret = __znet_send_packet(skb, dev);
+	spin_unlock(&znet->tx_lock);
+
+	return ret;
+}
+
 /* The ZNET interrupt handler. */
 static irqreturn_t znet_interrupt(int irq, void *dev_id)
 {
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 04a1d7b..23400d5 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -362,8 +362,7 @@ claw_probe(struct ccwgroup_device *cgdev)
  *   claw_tx                                                         *
  *-------------------------------------------------------------------*/
 
-static int
-claw_tx(struct sk_buff *skb, struct net_device *dev)
+static int __claw_tx(struct sk_buff *skb, struct net_device *dev)
 {
         int             rc;
         struct claw_privbk *privptr=dev->priv;
@@ -404,6 +403,18 @@ claw_tx(struct sk_buff *skb, struct net_device *dev)
         return rc;
 }   /*  end of claw_tx */
 
+static int claw_tx(struct sk_buff *skb, struct net_device *dev)
+{
+        struct claw_privbk *privptr = dev->priv;
+	int ret;
+
+	spin_lock(&privptr->tx_lock);
+	ret = __claw_tx(skb, dev);
+	spin_unlock(&privptr->tx_lock);
+
+	return ret;
+}
+
 /*------------------------------------------------------------------*
  *  pack the collect queue into an skb and return it                *
  *   If not packing just return the top skb from the queue          *
@@ -3960,6 +3971,7 @@ claw_new_device(struct ccwgroup_device *cgdev)
 	cgdev->cdev[WRITE]->dev.driver_data = privptr;
 	if (!privptr)
 		return -ENODEV;
+	spin_lock_init(&privptr->tx_lock);
 	p_env = privptr->p_env;
 	ccw_device_get_id(cgdev->cdev[READ], &dev_id);
 	p_env->devno[READ] = dev_id.devno;
diff --git a/drivers/s390/net/claw.h b/drivers/s390/net/claw.h
index 1a89d98..d86760c 100644
--- a/drivers/s390/net/claw.h
+++ b/drivers/s390/net/claw.h
@@ -329,7 +329,7 @@ struct claw_privbk {
 	__u8      buffs_alloc;
         struct endccw  end_ccw;
         unsigned long  tbusy;
-
+	spinlock_t tx_lock;
 };
 
 
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index d52843d..5b2938c 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -886,7 +886,7 @@ done:
  *               the generic network layer.
  */
 /* first merge version - leaving both functions separated */
-static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
+static int __ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	int rc = 0;
 	struct ctcm_priv *priv;
@@ -929,8 +929,20 @@ static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 	return rc;
 }
 
+static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ctcm_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __ctcm_tx(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /* unmerged MPC variant of ctcm_tx */
-static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
+static int __ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	int len = 0;
 	struct ctcm_priv *priv = NULL;
@@ -1037,6 +1049,17 @@ done:
 	return 0;	/* handle freeing of skb here */
 }
 
+static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ctcm_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __ctcmpc_tx(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
 
 /**
  * Sets MTU of an interface.
@@ -1338,6 +1361,7 @@ static int ctcm_probe_device(struct ccwgroup_device *cgdev)
 		put_device(&cgdev->dev);
 		return rc;
 	}
+	spin_lock_init(&priv->tx_lock);
 	priv->buffer_size = CTCM_BUFSIZE_DEFAULT;
 	cgdev->cdev[0]->handler = ctcm_irq_handler;
 	cgdev->cdev[1]->handler = ctcm_irq_handler;
diff --git a/drivers/s390/net/ctcm_main.h b/drivers/s390/net/ctcm_main.h
index 95b0c0b..d14aed6 100644
--- a/drivers/s390/net/ctcm_main.h
+++ b/drivers/s390/net/ctcm_main.h
@@ -167,6 +167,7 @@ struct channel {
 
 struct ctcm_priv {
 	struct net_device_stats	stats;
+	spinlock_t tx_lock;
 	unsigned long	tbusy;
 
 	/* The MPC group struct of this interface */
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index dd22f4b..4662a33 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -434,6 +434,7 @@ lcs_setup_card(struct lcs_card *card)
 
 	init_waitqueue_head(&card->wait_q);
 	spin_lock_init(&card->lock);
+	spin_lock_init(&card->tx_lock);
 	spin_lock_init(&card->ipm_lock);
 	spin_lock_init(&card->mask_lock);
 #ifdef CONFIG_IP_MULTICAST
@@ -1602,7 +1603,9 @@ lcs_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	LCS_DBF_TEXT(5, trace, "pktxmit");
 	card = (struct lcs_card *) dev->priv;
+	spin_lock(&card->tx_lock);
 	rc = __lcs_start_xmit(card, skb, dev);
+	spin_unlock(&card->tx_lock);
 	return rc;
 }
 
diff --git a/drivers/s390/net/lcs.h b/drivers/s390/net/lcs.h
index d58fea5..f291682 100644
--- a/drivers/s390/net/lcs.h
+++ b/drivers/s390/net/lcs.h
@@ -287,6 +287,7 @@ struct lcs_channel {
  */
 struct lcs_card {
 	spinlock_t lock;
+	spinlock_t tx_lock;
 	spinlock_t ipm_lock;
 	enum lcs_dev_states state;
 	struct net_device *dev;
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index e4ba6a0..a0b162a 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -226,6 +226,7 @@ struct iucv_event {
  */
 struct netiucv_priv {
 	struct net_device_stats stats;
+	spinlock_t		tx_lock;
 	unsigned long           tbusy;
 	fsm_instance            *fsm;
         struct iucv_connection  *conn;
@@ -1283,7 +1284,7 @@ static int netiucv_close(struct net_device *dev)
  *         Note: If we return !0, then the packet is free'd by
  *               the generic network layer.
  */
-static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
+static int __netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netiucv_priv *privptr = netdev_priv(dev);
 	int rc;
@@ -1330,6 +1331,18 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 	return rc;
 }
 
+static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct netiucv_priv *privptr = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&privptr->tx_lock);
+	ret = __netiucv_tx(skb, dev);
+	spin_unlock(&privptr->tx_lock);
+
+	return ret;
+}
+
 /**
  * netiucv_stats
  * @dev: Pointer to interface struct.
@@ -1930,6 +1943,7 @@ static struct net_device *netiucv_init_netdevice(char *username)
 		goto out_netdev;
 
 	privptr = netdev_priv(dev);
+	spin_lock_init(&privptr->tx_lock);
 	privptr->fsm = init_fsm("netiucvdev", dev_state_names,
 				dev_event_names, NR_DEV_STATES, NR_DEV_EVENTS,
 				dev_fsm, DEV_FSM_LEN, GFP_KERNEL);
diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 699ac11..883e83b 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -736,6 +736,7 @@ struct qeth_card {
 	struct qeth_osn_info osn_info;
 	struct qeth_discipline discipline;
 	atomic_t force_alloc_skb;
+	spinlock_t tx_lock;
 };
 
 struct qeth_card_list_struct {
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 9a71dae..4f1a2f5 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1106,6 +1106,7 @@ static int qeth_setup_card(struct qeth_card *card)
 	spin_lock_init(&card->lock);
 	spin_lock_init(&card->ip_lock);
 	spin_lock_init(&card->thread_mask_lock);
+	spin_lock_init(&card->tx_lock);
 	card->thread_start_mask = 0;
 	card->thread_allowed_mask = 0;
 	card->thread_running_mask = 0;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index f682f7b..a2189aa 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -607,7 +607,8 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 	qeth_setadp_promisc_mode(card);
 }
 
-static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __qeth_l2_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	int rc;
 	struct qeth_hdr *hdr = NULL;
@@ -725,6 +726,18 @@ tx_drop:
 	return NETDEV_TX_OK;
 }
 
+static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&card->tx_lock);
+	ret = __qeth_l2_hard_start_xmit(skb, dev);
+	spin_unlock(&card->tx_lock);
+
+	return ret;
+}
+
 static void qeth_l2_qdio_input_handler(struct ccw_device *ccwdev,
 			unsigned int status, unsigned int qdio_err,
 			unsigned int siga_err, unsigned int queue,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 999552c..234258f 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2596,7 +2596,8 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	}
 }
 
-static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __qeth_l3_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	int rc;
 	u16 *tag;
@@ -2768,6 +2769,18 @@ tx_drop:
 	return NETDEV_TX_OK;
 }
 
+static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&card->tx_lock);
+	ret = __qeth_l3_hard_start_xmit(skb, dev);
+	spin_unlock(&card->tx_lock);
+
+	return ret;
+}
+
 static int qeth_l3_open(struct net_device *dev)
 {
 	struct qeth_card *card = netdev_priv(dev);
diff --git a/drivers/usb/gadget/ether.c b/drivers/usb/gadget/ether.c
index 8d61ea6..7e56272 100644
--- a/drivers/usb/gadget/ether.c
+++ b/drivers/usb/gadget/ether.c
@@ -94,6 +94,7 @@ static const char driver_desc [] = DRIVER_DESC;
 
 struct eth_dev {
 	spinlock_t		lock;
+	spinlock_t		tx_lock;
 	struct usb_gadget	*gadget;
 	struct usb_request	*req;		/* for control responses */
 	struct usb_request	*stat_req;	/* for cdc & rndis status */
@@ -1927,7 +1928,7 @@ static inline int eth_is_promisc (struct eth_dev *dev)
 	return dev->cdc_filter & USB_CDC_PACKET_TYPE_PROMISCUOUS;
 }
 
-static int eth_start_xmit (struct sk_buff *skb, struct net_device *net)
+static int __eth_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct eth_dev		*dev = netdev_priv(net);
 	int			length = skb->len;
@@ -2036,6 +2037,18 @@ drop:
 	return 0;
 }
 
+static int eth_start_xmit(struct sk_buff *skb, struct net_device *net)
+{
+	struct eth_dev *dev = netdev_priv(net);
+	int ret;
+
+	spin_lock(&dev->tx_lock);
+	ret = __eth_start_xmit(skb, net);
+	spin_unlock(&dev->tx_lock);
+
+	return ret;
+}
+
 /*-------------------------------------------------------------------------*/
 
 #ifdef CONFIG_USB_ETH_RNDIS
@@ -2458,6 +2471,7 @@ autoconf_fail:
 		return status;
 	dev = netdev_priv(net);
 	spin_lock_init (&dev->lock);
+	spin_lock_init (&dev->tx_lock);
 	spin_lock_init (&dev->req_lock);
 	INIT_WORK (&dev->work, eth_work);
 	INIT_LIST_HEAD (&dev->tx_reqs);
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index a191607..c4ad7c7 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -259,6 +259,7 @@ struct arcnet_local {
 
 	/* On preemtive and SMB a lock is needed */
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	/*
 	 * Buffer management: an ARCnet card has 4 x 512-byte buffers, each of
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index 6115545..855b8da 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -58,6 +58,7 @@ typedef struct hdlc_device {
 	int carrier;
 	int open;
 	spinlock_t state_lock;
+	spinlock_t tx_lock;
 	void *state;
 	void *priv;
 }hdlc_device;
diff --git a/include/linux/hdlcdrv.h b/include/linux/hdlcdrv.h
index bf6302f..557b36a 100644
--- a/include/linux/hdlcdrv.h
+++ b/include/linux/hdlcdrv.h
@@ -213,6 +213,7 @@ struct hdlcdrv_state {
 		unsigned char buffer[HDLCDRV_MAXFLEN+2];
 	} hdlcrx;
 
+	spinlock_t tx_lock;
 	struct hdlcdrv_hdlctx {
 		struct hdlcdrv_hdlcbuffer hbuf;
 		long in_hdlc_tx;
diff --git a/include/linux/ibmtr.h b/include/linux/ibmtr.h
index 1c7a0dd..9b6af6c 100644
--- a/include/linux/ibmtr.h
+++ b/include/linux/ibmtr.h
@@ -218,6 +218,7 @@ struct tok_info {
         struct timer_list tr_timer;
 	unsigned char ring_speed;
 	spinlock_t lock;		/* SMP protection */
+	spinlock_t tx_lock;
 };
 
 /* token ring adapter commands */
diff --git a/include/linux/if_frad.h b/include/linux/if_frad.h
index 5c34240..7bbe9ae 100644
--- a/include/linux/if_frad.h
+++ b/include/linux/if_frad.h
@@ -159,6 +159,7 @@ struct dlci_local
    struct dlci_conf       config;
    int                    configured;
    struct list_head	  list;
+   spinlock_t tx_lock;
 
    /* callback function */
    void              (*receive)(struct sk_buff *skb, struct net_device *);
@@ -167,6 +168,7 @@ struct dlci_local
 struct frad_local
 {
    struct net_device_stats stats;
+   spinlock_t tx_lock;
 
    /* devices which this FRAD is slaved to */
    struct net_device     *master[CONFIG_DLCI_MAX];
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 15ace02..f869f4a 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -126,6 +126,7 @@ struct vlan_dev_info {
 	unsigned int nr_ingress_mappings;
 	u32 ingress_priority_map[8];
 
+	spinlock_t tx_lock;
 	unsigned int nr_egress_mappings;
 	struct vlan_priority_tci_mapping *egress_priority_map[16]; /* hash table */
 
diff --git a/include/linux/isdn.h b/include/linux/isdn.h
index 44cd663..2ca56b9 100644
--- a/include/linux/isdn.h
+++ b/include/linux/isdn.h
@@ -366,6 +366,7 @@ typedef struct isdn_net_local_s {
   char cisco_debserint;			/* debugging flag of cisco hdlc with slarp */
   struct timer_list cisco_timer;
   struct work_struct tqueue;
+  spinlock_t tx_lock;
 } isdn_net_local;
 
 /* the interface itself */
diff --git a/include/linux/scc.h b/include/linux/scc.h
index 3495bd9..1d6074b 100644
--- a/include/linux/scc.h
+++ b/include/linux/scc.h
@@ -246,6 +246,7 @@ struct scc_channel {
 	
 	/* Channel lock */
 	spinlock_t	lock;		/* Channel guard lock */
+	spinlock_t	tx_lock;
 };
 
 #endif /* defined(__KERNEL__) */
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..e4032ec 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -52,6 +52,7 @@ struct usbnet {
 
 	/* various kinds of pending driver work */
 	struct sk_buff_head	rxq;
+	spinlock_t		tx_lock;
 	struct sk_buff_head	txq;
 	struct sk_buff_head	done;
 	struct urb		*interrupt;
diff --git a/include/net/atmclip.h b/include/net/atmclip.h
index b5a51a7..feffddc 100644
--- a/include/net/atmclip.h
+++ b/include/net/atmclip.h
@@ -50,6 +50,7 @@ struct atmarp_entry {
 struct clip_priv {
 	int number;			/* for convenience ... */
 	spinlock_t xoff_lock;		/* ensures that pop is atomic (SMP) */
+	spinlock_t tx_lock;
 	struct net_device_stats stats;
 	struct net_device *next;	/* next CLIP interface */
 };
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index b31399e..e573e65 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1021,6 +1021,7 @@ struct ieee80211_device {
 	struct iw_spy_data spy_data;	/* iwspy support */
 
 	spinlock_t lock;
+	spinlock_t tx_lock;
 
 	int tx_headroom;	/* Set to size of any additional room needed at front
 				 * of allocated Tx SKBs */
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 83b4e00..b55aad6 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -15,6 +15,7 @@
 struct ip6_tnl {
 	struct ip6_tnl *next;	/* next tunnel in list */
 	struct net_device *dev;	/* virtual device associated with tunnel */
+	spinlock_t tx_lock;
 	int recursion;		/* depth of hard_start_xmit recursion */
 	struct ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
diff --git a/include/net/ipip.h b/include/net/ipip.h
index a85bda6..0c32521 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -12,6 +12,7 @@ struct ip_tunnel
 	struct ip_tunnel	*next;
 	struct net_device	*dev;
 
+	spinlock_t		tx_lock;
 	int			recursion;	/* Depth of hard_start_xmit recursion */
 	int			err_count;	/* Number of arrived ICMP errors */
 	unsigned long		err_time;	/* Time when the last ICMP error arrived */
diff --git a/include/net/irda/irlan_common.h b/include/net/irda/irlan_common.h
index 73cacb3..a151c9b 100644
--- a/include/net/irda/irlan_common.h
+++ b/include/net/irda/irlan_common.h
@@ -172,6 +172,7 @@ struct irlan_cb {
 	struct list_head  dev_list;
 	struct net_device *dev;        /* Ethernet device structure*/
 	struct net_device_stats stats;
+	spinlock_t tx_lock;
 
 	__u32 saddr;               /* Source device address */
 	__u32 daddr;               /* Destination device address */
diff --git a/include/net/netrom.h b/include/net/netrom.h
index f06852b..1cd07e4 100644
--- a/include/net/netrom.h
+++ b/include/net/netrom.h
@@ -61,6 +61,7 @@ enum {
 
 struct nr_private {
 	struct net_device_stats	stats;
+	spinlock_t tx_lock;
 };
 
 struct nr_sock {
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..b8ab165 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -359,7 +359,8 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return rc;
 }
 
-static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __vlan_dev_hard_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
@@ -418,8 +419,20 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev)
+static int vlan_dev_hard_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&vlan_dev_info(dev)->tx_lock);
+	ret = __vlan_dev_hard_start_xmit(skb, dev);
+	spin_unlock(&vlan_dev_info(dev)->tx_lock);
+
+	return ret;
+}
+
+static int __vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
+					      struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	unsigned short veth_TCI;
@@ -443,6 +456,18 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	return 0;
 }
 
+static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&vlan_dev_info(dev)->tx_lock);
+	ret = __vlan_dev_hwaccel_hard_start_xmit(skb, dev);
+	spin_unlock(&vlan_dev_info(dev)->tx_lock);
+
+	return ret;
+}
+
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* TODO: gotta make sure the underlying layer can handle it,
@@ -709,6 +734,8 @@ void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
+	spin_lock_init(&vlan_dev_info(dev)->tx_lock);
+
 	dev->priv_flags		|= IFF_802_1Q_VLAN;
 	dev->tx_queue_len	= 0;
 
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 8d9a6f1..4ca6c72 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -80,6 +80,7 @@ struct br2684_vcc {
 
 struct br2684_dev {
 	struct net_device *net_dev;
+	spinlock_t tx_lock;
 	struct list_head br2684_devs;
 	int number;
 	struct list_head brvccs;	/* one device <=> one vcc (before xmas) */
@@ -223,7 +224,7 @@ static inline struct br2684_vcc *pick_outgoing_vcc(const struct sk_buff *skb,
 	return list_empty(&brdev->brvccs) ? NULL : list_entry_brvcc(brdev->brvccs.next);	/* 1 vcc/dev right now */
 }
 
-static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct br2684_dev *brdev = BRPRIV(dev);
 	struct br2684_vcc *brvcc;
@@ -255,6 +256,18 @@ static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct br2684_dev *brdev = BRPRIV(dev);
+	int ret;
+
+	spin_lock(&brdev->tx_lock);
+	ret = __br2684_start_xmit(skb, dev);
+	spin_unlock(&brdev->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *br2684_get_stats(struct net_device *dev)
 {
 	pr_debug("br2684_get_stats\n");
@@ -610,6 +623,8 @@ static int br2684_create(void __user * arg)
 
 	brdev = BRPRIV(netdev);
 
+	spin_lock_init(&brdev->tx_lock);
+
 	pr_debug("registered netdev %s\n", netdev->name);
 	/* open, stop, do_ioctl ? */
 	err = register_netdev(netdev);
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 6f8223e..c54e482 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -360,7 +360,7 @@ static int clip_encap(struct atm_vcc *vcc, int mode)
 	return 0;
 }
 
-static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct clip_priv *clip_priv = PRIV(dev);
 	struct atmarp_entry *entry;
@@ -443,6 +443,18 @@ static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct clip_priv *clip_priv = PRIV(dev);
+	int ret;
+
+	spin_lock(&clip_priv->tx_lock);
+	ret = __clip_start_xmit(skb, dev);
+	spin_unlock(&clip_priv->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *clip_get_stats(struct net_device *dev)
 {
 	return &PRIV(dev)->stats;
@@ -595,6 +607,7 @@ static int clip_create(int number)
 	clip_priv = PRIV(dev);
 	sprintf(dev->name, "atm%d", number);
 	spin_lock_init(&clip_priv->xoff_lock);
+	spin_lock_init(&clip_priv->tx_lock);
 	clip_priv->number = number;
 	error = register_netdev(dev);
 	if (error) {
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 5799fb5..e4ba1ca 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -249,7 +249,7 @@ static void lec_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *skb2;
 	struct lec_priv *priv = (struct lec_priv *)dev->priv;
@@ -429,6 +429,18 @@ out:
 	return 0;
 }
 
+static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct lec_priv *priv = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&priv->tx_lock);
+	ret = __lec_start_xmit(skb, dev);
+	spin_unlock(&priv->tx_lock);
+
+	return ret;
+}
+
 /* The inverse routine to net_open(). */
 static int lec_close(struct net_device *dev)
 {
@@ -1446,6 +1458,7 @@ static void lec_arp_init(struct lec_priv *priv)
 	INIT_HLIST_HEAD(&priv->lec_no_forward);
 	INIT_HLIST_HEAD(&priv->mcast_fwds);
 	spin_lock_init(&priv->lec_arp_lock);
+	spin_lock_init(&priv->tx_lock);
 	INIT_DELAYED_WORK(&priv->lec_arp_work, lec_arp_check_expire);
 	schedule_delayed_work(&priv->lec_arp_work, LEC_ARP_REFRESH_INTERVAL);
 }
diff --git a/net/atm/lec.h b/net/atm/lec.h
index 0d37668..46f8594 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -70,6 +70,7 @@ struct lane2_ops {
 
 struct lec_priv {
 	struct net_device_stats stats;
+	spinlock_t tx_lock;
 	unsigned short lecid;			/* Lecid of this client */
 	struct hlist_head lec_arp_empty_ones;
 						/* Used for storing VCC's that don't have a MAC address attached yet */
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index d9fa0ab..ac353fd 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -181,7 +181,7 @@ static inline int bnep_net_proto_filter(struct sk_buff *skb, struct bnep_session
 }
 #endif
 
-static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnep_session *s = dev->priv;
 	struct sock *sk = s->sock->sk;
@@ -222,6 +222,19 @@ static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static DEFINE_SPINLOCK(bnep_tx_lock);
+
+static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&bnep_tx_lock);
+	ret = __bnep_net_xmit(skb, dev);
+	spin_unlock(&bnep_tx_lock);
+
+	return ret;
+}
+
 void bnep_net_setup(struct net_device *dev)
 {
 
diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
index 3bca97f..b83be76 100644
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -186,6 +186,7 @@ struct net_device *alloc_ieee80211(int sizeof_priv)
 	ieee->crypt_quiesced = 0;
 
 	spin_lock_init(&ieee->lock);
+	spin_lock_init(&ieee->tx_lock);
 
 	ieee->wpa_enabled = 0;
 	ieee->drop_unencrypted = 0;
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index d996547..10946d0 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -251,7 +251,7 @@ static int ieee80211_classify(struct sk_buff *skb)
 
 /* Incoming skb is converted to a txb which consists of
  * a block of 802.11 fragment packets (stored as skbs) */
-int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ieee80211_device *ieee = netdev_priv(dev);
 	struct ieee80211_txb *txb = NULL;
@@ -542,4 +542,16 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 1;
 }
 
+int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&ieee->tx_lock);
+	ret = __ieee80211_xmit(skb, dev);
+	spin_unlock(&ieee->tx_lock);
+
+	return ret;
+}
+
 EXPORT_SYMBOL(ieee80211_txb_free);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2a61158..74077e8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -539,7 +539,7 @@ drop_nolock:
 	return(0);
 }
 
-static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &tunnel->dev->stats;
@@ -773,6 +773,18 @@ tx_error:
 	return 0;
 }
 
+static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tunnel->tx_lock);
+	ret = __ipgre_tunnel_xmit(skb, dev);
+	spin_unlock(&tunnel->tx_lock);
+
+	return ret;
+}
+
 static void ipgre_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
@@ -1101,6 +1113,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
 
+	spin_lock_init(&tunnel->tx_lock);
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
 
@@ -1132,6 +1145,7 @@ static int ipgre_fb_tunnel_init(struct net_device *dev)
 	struct iphdr *iph = &tunnel->parms.iph;
 	struct ipgre_net *ign = net_generic(dev_net(dev), ipgre_net_id);
 
+	spin_lock_init(&tunnel->tx_lock);
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 4c6d2ca..55c4a0a 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -387,7 +387,7 @@ static int ipip_rcv(struct sk_buff *skb)
  *	and that skb is filled properly by that function.
  */
 
-static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &tunnel->dev->stats;
@@ -534,6 +534,18 @@ tx_error:
 	return 0;
 }
 
+static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tunnel->tx_lock);
+	ret = __ipip_tunnel_xmit(skb, dev);
+	spin_unlock(&tunnel->tx_lock);
+
+	return ret;
+}
+
 static void ipip_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
@@ -714,6 +726,7 @@ static int ipip_tunnel_init(struct net_device *dev)
 
 	tunnel = netdev_priv(dev);
 
+	spin_lock_init(&tunnel->tx_lock);
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
 
@@ -731,6 +744,7 @@ static int ipip_fb_tunnel_init(struct net_device *dev)
 	struct iphdr *iph = &tunnel->parms.iph;
 	struct ipip_net *ipn = net_generic(dev_net(dev), ipip_net_id);
 
+	spin_lock_init(&tunnel->tx_lock);
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 300ab0c..f956051 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -176,14 +176,18 @@ failure:
 
 static int reg_vif_num = -1;
 
+static DEFINE_SPINLOCK(vif_tx_lock);
+
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	spin_lock(&vif_tx_lock);
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
 	ipmr_cache_report(skb, reg_vif_num, IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
+	spin_unlock(&vif_tx_lock);
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 17c7b09..c15fa47 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1037,8 +1037,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static int
-ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->dev->stats;
@@ -1074,6 +1073,18 @@ tx_err:
 	return 0;
 }
 
+static int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&t->tx_lock);
+	ret = __ip6_tnl_xmit(skb, dev);
+	spin_unlock(&t->tx_lock);
+
+	return ret;
+}
+
 static void ip6_tnl_set_cap(struct ip6_tnl *t)
 {
 	struct ip6_tnl_parm *p = &t->parms;
@@ -1340,6 +1351,7 @@ static inline void
 ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
+	spin_lock_init(&t->tx_lock);
 	t->dev = dev;
 	strcpy(t->parms.name, dev->name);
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 90e7630..a105323 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -406,14 +406,18 @@ static struct inet6_protocol pim6_protocol = {
 
 /* Service routines creating virtual interfaces: PIMREG */
 
+static DEFINE_SPINLOCK(vif_tx_lock);
+
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	spin_lock(&vif_tx_lock);
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
 	ip6mr_cache_report(skb, reg_vif_num, MRT6MSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
+	spin_unlock(&vif_tx_lock);
 	return 0;
 }
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b7a50e9..afad078 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -534,7 +534,7 @@ static inline __be32 try_6to4(struct in6_addr *v6dst)
  *	and that skb is filled properly by that function.
  */
 
-static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &tunnel->dev->stats;
@@ -729,6 +729,18 @@ tx_error:
 	return 0;
 }
 
+static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&tunnel->tx_lock);
+	ret = __ipip6_tunnel_xmit(skb, dev);
+	spin_unlock(&tunnel->tx_lock);
+
+	return ret;
+}
+
 static void ipip6_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
@@ -949,6 +961,7 @@ static int ipip6_tunnel_init(struct net_device *dev)
 
 	tunnel = netdev_priv(dev);
 
+	spin_lock_init(&tunnel->tx_lock);
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
 
@@ -967,6 +980,7 @@ static int ipip6_fb_tunnel_init(struct net_device *dev)
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
+	spin_lock_init(&tunnel->tx_lock);
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
 
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 05112be..1ef1969 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -89,8 +89,16 @@ static void irlan_eth_setup(struct net_device *dev)
  */
 struct net_device *alloc_irlandev(const char *name)
 {
-	return alloc_netdev(sizeof(struct irlan_cb), name,
-			    irlan_eth_setup);
+	struct net_device *dev;
+
+	dev = alloc_netdev(sizeof(struct irlan_cb), name,
+			   irlan_eth_setup);
+	if (dev) {
+		struct irlan_cb *self = netdev_priv(dev);
+
+		spin_lock_init(&self->tx_lock);
+	}
+	return dev;
 }
 
 /*
@@ -155,7 +163,7 @@ static int irlan_eth_close(struct net_device *dev)
  *    Transmits ethernet frames over IrDA link.
  *
  */
-static int irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 	int ret;
@@ -205,6 +213,18 @@ static int irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int irlan_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct irlan_cb *self = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&self->tx_lock);
+	ret = __irlan_eth_xmit(skb, dev);
+	spin_unlock(&self->tx_lock);
+
+	return ret;
+}
+
 /*
  * Function irlan_eth_receive (handle, skb)
  *
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 14fccf1..82322df 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -549,6 +549,8 @@ struct ieee80211_local {
 
 	const struct ieee80211_ops *ops;
 
+	spinlock_t tx_lock;
+
 	struct net_device *mdev; /* wmaster# - "master" 802.11 device */
 	int open_count;
 	int monitors, cooked_mntrs;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 3041924..a189acc 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1559,6 +1559,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	wiphy->privid = mac80211_wiphy_privid;
 
 	local = wiphy_priv(wiphy);
+	spin_lock_init(&local->tx_lock);
 	local->hw.wiphy = wiphy;
 
 	local->hw.priv = (char *)local +
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index ce06e79..3f627b3 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1253,8 +1253,8 @@ static int ieee80211_skb_resize(struct ieee80211_local *local,
 	return 0;
 }
 
-int ieee80211_master_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+static int __ieee80211_master_start_xmit(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct net_device *odev = NULL;
@@ -1301,8 +1301,21 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
-int ieee80211_monitor_start_xmit(struct sk_buff *skb,
-				 struct net_device *dev)
+int ieee80211_master_start_xmit(struct sk_buff *skb,
+				struct net_device *dev)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	int ret;
+
+	spin_lock(&local->tx_lock);
+	ret = __ieee80211_master_start_xmit(skb, dev);
+	spin_unlock(&local->tx_lock);
+
+	return ret;
+}
+
+static int __ieee80211_monitor_start_xmit(struct sk_buff *skb,
+					  struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
@@ -1357,6 +1370,19 @@ fail:
 	return NETDEV_TX_OK; /* meaning, we dealt with the skb */
 }
 
+int ieee80211_monitor_start_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	int ret;
+
+	spin_lock(&local->tx_lock);
+	ret = __ieee80211_monitor_start_xmit(skb, dev);
+	spin_unlock(&local->tx_lock);
+
+	return ret;
+}
+
 /**
  * ieee80211_subif_start_xmit - netif start_xmit function for Ethernet-type
  * subinterfaces (wlan#, WDS, and VLAN interfaces)
@@ -1372,8 +1398,8 @@ fail:
  * encapsulated packet will then be passed to master interface, wlan#.11, for
  * transmission (through low-level driver).
  */
-int ieee80211_subif_start_xmit(struct sk_buff *skb,
-			       struct net_device *dev)
+static int __ieee80211_subif_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_tx_info *info;
@@ -1635,6 +1661,18 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
+int ieee80211_subif_start_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	int ret;
+
+	spin_lock(&local->tx_lock);
+	ret = __ieee80211_subif_start_xmit(skb, dev);
+	spin_unlock(&local->tx_lock);
+
+	return ret;
+}
 
 /*
  * ieee80211_clear_tx_pending may not be called in a context where
diff --git a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
index 6caf459..2014a65 100644
--- a/net/netrom/nr_dev.c
+++ b/net/netrom/nr_dev.c
@@ -169,7 +169,7 @@ static int nr_close(struct net_device *dev)
 	return 0;
 }
 
-static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __nr_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct nr_private *nr = netdev_priv(dev);
 	struct net_device_stats *stats = &nr->stats;
@@ -187,6 +187,18 @@ static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nr_private *nr = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&nr->tx_lock);
+	ret = __nr_xmit(skb, dev);
+	spin_unlock(&nr->tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *nr_get_stats(struct net_device *dev)
 {
 	struct nr_private *nr = netdev_priv(dev);
@@ -202,6 +214,10 @@ static const struct header_ops nr_header_ops = {
 
 void nr_setup(struct net_device *dev)
 {
+	struct nr_private *nr = netdev_priv(dev);
+
+	spin_lock_init(&nr->tx_lock);
+
 	dev->mtu		= NR_MAX_PACKET_SIZE;
 	dev->hard_start_xmit	= nr_xmit;
 	dev->open		= nr_open;
diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 12cfcf0..407192d 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -131,7 +131,7 @@ static int rose_close(struct net_device *dev)
 	return 0;
 }
 
-static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __rose_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = netdev_priv(dev);
 
@@ -144,6 +144,19 @@ static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static DEFINE_SPINLOCK(rose_tx_lock);
+
+static int rose_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&rose_tx_lock);
+	ret = __rose_xmit(skb, dev);
+	spin_unlock(&rose_tx_lock);
+
+	return ret;
+}
+
 static struct net_device_stats *rose_get_stats(struct net_device *dev)
 {
 	return netdev_priv(dev);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 0444fd0..53f5484 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -56,6 +56,7 @@ struct teql_master
 {
 	struct Qdisc_ops qops;
 	struct net_device *dev;
+	spinlock_t tx_lock;
 	struct Qdisc *slaves;
 	struct list_head master_list;
 	struct net_device_stats stats;
@@ -262,7 +263,7 @@ static inline int teql_resolve(struct sk_buff *skb,
 	return __teql_resolve(skb, skb_res, dev);
 }
 
-static int teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
+static int __teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct teql_master *master = netdev_priv(dev);
 	struct Qdisc *start, *q;
@@ -338,6 +339,18 @@ drop:
 	return 0;
 }
 
+static int teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct teql_master *master = netdev_priv(dev);
+	int ret;
+
+	spin_lock(&master->tx_lock);
+	ret = __teql_master_xmit(skb, dev);
+	spin_unlock(&master->tx_lock);
+
+	return ret;
+}
+
 static int teql_master_open(struct net_device *dev)
 {
 	struct Qdisc * q;
@@ -468,6 +481,7 @@ static int __init teql_init(void)
 
 		master = netdev_priv(dev);
 
+		spin_lock_init(&master->tx_lock);
 		strlcpy(master->qops.id, dev->name, IFNAMSIZ);
 		err = register_qdisc(&master->qops);
 
