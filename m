From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/19] wan: convert drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:47 -0700
Message-ID: <20090901055129.206974385@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57465 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358AbZIAF6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:54 -0400
Content-Disposition: inline; filename=wan-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/wan/cosa.c         |    7 ++++---
 drivers/net/wan/cycx_x25.c     |    8 ++++----
 drivers/net/wan/dlci.c         |   13 +++++++------
 drivers/net/wan/dscc4.c        |    6 ++++--
 drivers/net/wan/farsync.c      |    2 +-
 drivers/net/wan/hd64570.c      |    4 ++--
 drivers/net/wan/hd64572.c      |    4 ++--
 drivers/net/wan/hdlc.c         |    2 +-
 drivers/net/wan/hdlc_fr.c      |    2 +-
 drivers/net/wan/hdlc_raw_eth.c |    2 +-
 drivers/net/wan/hdlc_x25.c     |    6 +++---
 drivers/net/wan/hostess_sv11.c |    3 ++-
 drivers/net/wan/lapbether.c    |    3 ++-
 drivers/net/wan/lmc/lmc_main.c |    9 +++++----
 drivers/net/wan/sbni.c         |    7 ++++---
 drivers/net/wan/sdla.c         |    5 +++--
 drivers/net/wan/sealevel.c     |    3 ++-
 drivers/net/wan/wanxl.c        |    2 +-
 drivers/net/wan/x25_asy.c      |    3 ++-
 drivers/net/wan/z85230.c       |    9 ++++-----
 drivers/net/wan/z85230.h       |    3 ++-
 21 files changed, 57 insertions(+), 46 deletions(-)

--- a/drivers/net/wan/hdlc.c	2009-08-31 16:17:53.131107761 -0700
+++ b/drivers/net/wan/hdlc.c	2009-08-31 16:27:02.091109721 -0700
@@ -66,7 +66,7 @@ static int hdlc_rcv(struct sk_buff *skb,
 	return hdlc->proto->netif_rx(skb);
 }
 
-int hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 
--- a/drivers/net/wan/hdlc_fr.c	2009-08-31 16:17:53.041107499 -0700
+++ b/drivers/net/wan/hdlc_fr.c	2009-08-31 16:27:02.091109721 -0700
@@ -407,7 +407,7 @@ static int pvc_ioctl(struct net_device *
 	return -EINVAL;
 }
 
-static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	pvc_device *pvc = dev->ml_priv;
 
--- a/drivers/net/wan/cosa.c	2009-08-31 16:17:53.041107499 -0700
+++ b/drivers/net/wan/cosa.c	2009-08-31 16:27:02.091109721 -0700
@@ -279,7 +279,7 @@ static int cosa_net_attach(struct net_de
 static int cosa_net_open(struct net_device *d);
 static int cosa_net_close(struct net_device *d);
 static void cosa_net_timeout(struct net_device *d);
-static int cosa_net_tx(struct sk_buff *skb, struct net_device *d);
+static netdev_tx_t cosa_net_tx(struct sk_buff *skb, struct net_device *d);
 static char *cosa_net_setup_rx(struct channel_data *channel, int size);
 static int cosa_net_rx_done(struct channel_data *channel);
 static int cosa_net_tx_done(struct channel_data *channel, int size);
@@ -672,7 +672,8 @@ static int cosa_net_open(struct net_devi
 	return 0;
 }
 
-static int cosa_net_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t cosa_net_tx(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct channel_data *chan = dev_to_chan(dev);
 
@@ -680,7 +681,7 @@ static int cosa_net_tx(struct sk_buff *s
 
 	chan->tx_skb = skb;
 	cosa_start_tx(chan, skb->data, skb->len);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void cosa_net_timeout(struct net_device *dev)
--- a/drivers/net/wan/dscc4.c	2009-08-31 16:17:53.081083527 -0700
+++ b/drivers/net/wan/dscc4.c	2009-08-31 16:27:02.091109721 -0700
@@ -359,7 +359,8 @@ static void dscc4_tx_irq(struct dscc4_pc
 static int dscc4_found1(struct pci_dev *, void __iomem *ioaddr);
 static int dscc4_init_one(struct pci_dev *, const struct pci_device_id *ent);
 static int dscc4_open(struct net_device *);
-static int dscc4_start_xmit(struct sk_buff *, struct net_device *);
+static netdev_tx_t dscc4_start_xmit(struct sk_buff *,
+					  struct net_device *);
 static int dscc4_close(struct net_device *);
 static int dscc4_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int dscc4_init_ring(struct net_device *);
@@ -1148,7 +1149,8 @@ static int dscc4_tx_poll(struct dscc4_de
 }
 #endif /* DSCC4_POLLING */
 
-static int dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t dscc4_start_xmit(struct sk_buff *skb,
+					  struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
 	struct dscc4_pci_priv *ppriv = dpriv->pci_priv;
--- a/drivers/net/wan/farsync.c	2009-08-31 16:17:53.051086769 -0700
+++ b/drivers/net/wan/farsync.c	2009-08-31 16:27:02.091109721 -0700
@@ -2274,7 +2274,7 @@ fst_tx_timeout(struct net_device *dev)
 	port->start = 0;
 }
 
-static int
+static netdev_tx_t
 fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fst_card_info *card;
--- a/drivers/net/wan/hd64570.c	2009-08-31 16:17:53.011106130 -0700
+++ b/drivers/net/wan/hd64570.c	2009-08-31 16:27:02.101108828 -0700
@@ -620,7 +620,7 @@ static void sca_dump_rings(struct net_de
 #endif /* DEBUG_RINGS */
 
 
-static int sca_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	port_t *port = dev_to_port(dev);
 	card_t *card = port_to_card(port);
@@ -674,7 +674,7 @@ static int sca_xmit(struct sk_buff *skb,
 	spin_unlock_irq(&port->lock);
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
--- a/drivers/net/wan/hdlc_raw_eth.c	2009-08-31 16:17:53.101091935 -0700
+++ b/drivers/net/wan/hdlc_raw_eth.c	2009-08-31 16:27:02.101108828 -0700
@@ -25,7 +25,7 @@
 
 static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr);
 
-static int eth_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t eth_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	int pad = ETH_ZLEN - skb->len;
 	if (pad > 0) {		/* Pad the frame with zeros */
--- a/drivers/net/wan/hdlc_x25.c	2009-08-31 16:17:53.141108055 -0700
+++ b/drivers/net/wan/hdlc_x25.c	2009-08-31 16:27:02.101108828 -0700
@@ -87,7 +87,7 @@ static void x25_data_transmit(struct net
 
 
 
-static int x25_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t x25_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int result;
 
@@ -98,7 +98,7 @@ static int x25_xmit(struct sk_buff *skb,
 		skb_pull(skb, 1);
 		if ((result = lapb_data_request(dev, skb)) != LAPB_OK)
 			dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 
 	case 1:
 		if ((result = lapb_connect_request(dev))!= LAPB_OK) {
@@ -129,7 +129,7 @@ static int x25_xmit(struct sk_buff *skb,
 	}
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
--- a/drivers/net/wan/hostess_sv11.c	2009-08-31 16:17:53.071106841 -0700
+++ b/drivers/net/wan/hostess_sv11.c	2009-08-31 16:27:02.101108828 -0700
@@ -156,7 +156,8 @@ static int hostess_ioctl(struct net_devi
  *	Passed network frames, fire them downwind.
  */
 
-static int hostess_queue_xmit(struct sk_buff *skb, struct net_device *d)
+static netdev_tx_t hostess_queue_xmit(struct sk_buff *skb,
+					    struct net_device *d)
 {
 	return z8530_queue_xmit(&dev_to_sv(d)->chanA, skb);
 }
--- a/drivers/net/wan/lmc/lmc_main.c	2009-08-31 16:17:53.111106337 -0700
+++ b/drivers/net/wan/lmc/lmc_main.c	2009-08-31 16:27:02.101108828 -0700
@@ -89,7 +89,8 @@ MODULE_DEVICE_TABLE(pci, lmc_pci_tbl);
 MODULE_LICENSE("GPL v2");
 
 
-static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t lmc_start_xmit(struct sk_buff *skb,
+					struct net_device *dev);
 static int lmc_rx (struct net_device *dev);
 static int lmc_open(struct net_device *dev);
 static int lmc_close(struct net_device *dev);
@@ -1423,12 +1424,12 @@ lmc_int_fail_out:
     return IRQ_RETVAL(handled);
 }
 
-static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t lmc_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
 {
     lmc_softc_t *sc = dev_to_sc(dev);
     u32 flag;
     int entry;
-    int ret = NETDEV_TX_OK;
     unsigned long flags;
 
     lmc_trace(dev, "lmc_start_xmit in");
@@ -1510,7 +1511,7 @@ static int lmc_start_xmit(struct sk_buff
     spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
     lmc_trace(dev, "lmc_start_xmit_out");
-    return ret;
+    return NETDEV_TX_OK;
 }
 
 
--- a/drivers/net/wan/sealevel.c	2009-08-31 16:17:53.121081138 -0700
+++ b/drivers/net/wan/sealevel.c	2009-08-31 16:27:02.101108828 -0700
@@ -156,7 +156,8 @@ static int sealevel_ioctl(struct net_dev
  *	Passed network frames, fire them downwind.
  */
 
-static int sealevel_queue_xmit(struct sk_buff *skb, struct net_device *d)
+static netdev_tx_t sealevel_queue_xmit(struct sk_buff *skb,
+					     struct net_device *d)
 {
 	return z8530_queue_xmit(dev_to_chan(d)->chan, skb);
 }
--- a/drivers/net/wan/wanxl.c	2009-08-31 16:17:53.071106841 -0700
+++ b/drivers/net/wan/wanxl.c	2009-08-31 16:27:02.101108828 -0700
@@ -268,7 +268,7 @@ static irqreturn_t wanxl_intr(int irq, v
 
 
 
-static int wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
         port_t *port = dev_to_port(dev);
 	desc_t *desc;
--- a/drivers/net/wan/z85230.c	2009-08-31 16:17:53.091107078 -0700
+++ b/drivers/net/wan/z85230.c	2009-08-31 16:27:02.101108828 -0700
@@ -1727,15 +1727,14 @@ static inline int spans_boundary(struct 
  *	point.
  */
 
-int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb)
+netdev_tx_t z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb)
 {
 	unsigned long flags;
 	
 	netif_stop_queue(c->netdevice);
 	if(c->tx_next_skb)
-	{
-		return 1;
-	}
+		return NETDEV_TX_BUSY;
+
 	
 	/* PC SPECIFIC - DMA limits */
 	
@@ -1767,7 +1766,7 @@ int z8530_queue_xmit(struct z8530_channe
 	z8530_tx_begin(c);
 	spin_unlock_irqrestore(c->lock, flags);
 	
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 EXPORT_SYMBOL(z8530_queue_xmit);
--- a/drivers/net/wan/cycx_x25.c	2009-08-31 16:17:53.061081056 -0700
+++ b/drivers/net/wan/cycx_x25.c	2009-08-31 16:27:02.101108828 -0700
@@ -139,8 +139,8 @@ static int cycx_netdevice_hard_header(st
 				      const void *daddr, const void *saddr,
 				      unsigned len);
 static int cycx_netdevice_rebuild_header(struct sk_buff *skb);
-static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
-					  struct net_device *dev);
+static netdev_tx_t cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
+							struct net_device *dev);
 
 static struct net_device_stats *
 			cycx_netdevice_get_stats(struct net_device *dev);
@@ -593,8 +593,8 @@ static int cycx_netdevice_rebuild_header
  *    bottom half" (with interrupts enabled).
  * 2. Setting tbusy flag will inhibit further transmit requests from the
  *    protocol stack and can be used for flow control with protocol layer. */
-static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
-					  struct net_device *dev)
+static netdev_tx_t cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
+							struct net_device *dev)
 {
 	struct cycx_x25_channel *chan = netdev_priv(dev);
 	struct cycx_device *card = chan->card;
--- a/drivers/net/wan/dlci.c	2009-08-31 16:17:53.021089173 -0700
+++ b/drivers/net/wan/dlci.c	2009-08-31 16:27:02.101108828 -0700
@@ -186,12 +186,11 @@ static void dlci_receive(struct sk_buff 
 		dev_kfree_skb(skb);
 }
 
-static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t dlci_transmit(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	struct dlci_local *dlp;
-	int					ret;
-
-	ret = 0;
+	netdev_tx_t ret;
 
 	if (!skb || !dev)
 		return NETDEV_TX_OK;
@@ -200,6 +199,8 @@ static int dlci_transmit(struct sk_buff 
 
 	netif_stop_queue(dev);
 	
+	/* This is hackish, overloads driver specific return values
+	   on top of normal transmit return! */
 	ret = dlp->slave->netdev_ops->ndo_start_xmit(skb, dlp->slave);
 	switch (ret)
 	{
@@ -207,11 +208,11 @@ static int dlci_transmit(struct sk_buff 
 			dev->stats.tx_packets++;
 			ret = NETDEV_TX_OK;
 			break;
-			case DLCI_RET_ERR:
+		case DLCI_RET_ERR:
 			dev->stats.tx_errors++;
 			ret = NETDEV_TX_OK;
 			break;
-			case DLCI_RET_DROP:
+		case DLCI_RET_DROP:
 			dev->stats.tx_dropped++;
 			ret = NETDEV_TX_BUSY;
 			break;
--- a/drivers/net/wan/lapbether.c	2009-08-31 16:17:53.031081364 -0700
+++ b/drivers/net/wan/lapbether.c	2009-08-31 16:27:02.101108828 -0700
@@ -147,7 +147,8 @@ static int lapbeth_data_indication(struc
 /*
  *	Send a LAPB frame via an ethernet interface
  */
-static int lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t lapbeth_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	int err;
 
--- a/drivers/net/wan/sbni.c	2009-08-31 16:17:53.021089173 -0700
+++ b/drivers/net/wan/sbni.c	2009-08-31 16:27:02.101108828 -0700
@@ -114,7 +114,8 @@ static int  sbni_pci_probe( struct net_d
 static struct net_device  *sbni_probe1(struct net_device *, unsigned long, int);
 static int  sbni_open( struct net_device * );
 static int  sbni_close( struct net_device * );
-static int  sbni_start_xmit( struct sk_buff *, struct net_device * );
+static netdev_tx_t sbni_start_xmit(struct sk_buff *,
+					 struct net_device * );
 static int  sbni_ioctl( struct net_device *, struct ifreq *, int );
 static void  set_multicast_list( struct net_device * );
 
@@ -444,7 +445,7 @@ sbni_probe1( struct net_device  *dev,  u
 
 #ifdef CONFIG_SBNI_MULTILINE
 
-static int
+static netdev_tx_t
 sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 {
 	struct net_device  *p;
@@ -472,7 +473,7 @@ sbni_start_xmit( struct sk_buff  *skb,  
 
 #else	/* CONFIG_SBNI_MULTILINE */
 
-static int
+static netdev_tx_t
 sbni_start_xmit( struct sk_buff  *skb,  struct net_device  *dev )
 {
 	struct net_local  *nl  = netdev_priv(dev);
--- a/drivers/net/wan/sdla.c	2009-08-31 16:17:53.081083527 -0700
+++ b/drivers/net/wan/sdla.c	2009-08-31 16:27:02.101108828 -0700
@@ -651,7 +651,8 @@ static int sdla_dlci_conf(struct net_dev
  **************************/
 
 /* NOTE: the DLCI driver deals with freeing the SKB!! */
-static int sdla_transmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sdla_transmit(struct sk_buff *skb,
+				       struct net_device *dev)
 {
 	struct frad_local *flp;
 	int               ret, addr, accept, i;
@@ -737,7 +738,7 @@ static int sdla_transmit(struct sk_buff 
 		if(flp->master[i]!=NULL)
 			netif_wake_queue(flp->master[i]);
 	}		
-	return(ret);
+	return NETDEV_TX_OK;
 }
 
 static void sdla_receive(struct net_device *dev)
--- a/drivers/net/wan/x25_asy.c	2009-08-31 16:17:53.131107761 -0700
+++ b/drivers/net/wan/x25_asy.c	2009-08-31 16:27:02.101108828 -0700
@@ -299,7 +299,8 @@ static void x25_asy_timeout(struct net_d
 
 /* Encapsulate an IP datagram and kick it into a TTY queue. */
 
-static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t x25_asy_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct x25_asy *sl = netdev_priv(dev);
 	int err;
--- a/drivers/net/wan/z85230.h	2009-08-31 16:17:53.061081056 -0700
+++ b/drivers/net/wan/z85230.h	2009-08-31 16:27:02.101108828 -0700
@@ -406,7 +406,8 @@ extern int z8530_sync_dma_close(struct n
 extern int z8530_sync_txdma_open(struct net_device *, struct z8530_channel *);
 extern int z8530_sync_txdma_close(struct net_device *, struct z8530_channel *);
 extern int z8530_channel_load(struct z8530_channel *, u8 *);
-extern int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb);
+extern netdev_tx_t z8530_queue_xmit(struct z8530_channel *c,
+					  struct sk_buff *skb);
 extern void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb);
 
 
--- a/drivers/net/wan/hd64572.c	2009-08-31 16:17:53.111106337 -0700
+++ b/drivers/net/wan/hd64572.c	2009-08-31 16:27:02.111107585 -0700
@@ -562,7 +562,7 @@ static void sca_dump_rings(struct net_de
 #endif /* DEBUG_RINGS */
 
 
-static int sca_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	port_t *port = dev_to_port(dev);
 	card_t *card = port->card;
@@ -601,7 +601,7 @@ static int sca_xmit(struct sk_buff *skb,
 	spin_unlock_irq(&port->lock);
 
 	dev_kfree_skb(skb);
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 

-- 

