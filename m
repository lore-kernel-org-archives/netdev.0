From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Mon, 12 May 2008 03:32:44 -0700 (PDT)
Message-ID: <20080512.033244.153113922.davem@davemloft.net>
References: <20080424.065555.30390704.davem@davemloft.net>
	<m3ve27nfpx.fsf@maximus.localdomain>
	<20080424214457.1d5a1655@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, jeff@garzik.org, paulkf@microgate.com,
	jchapman@katalix.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761601AbYELKcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 06:32:50 -0400
In-Reply-To: <20080424214457.1d5a1655@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 24 Apr 2008 21:44:57 +0100

> > I think it's easier to a) simply remove syncppp.c, b) apply my patch
> > with new PPP, c) blindly port the old drivers to generic HDLC,
> > d) hope for the best, with a bit of luck nobody would notice.
> 
> I would agree with this. There isn't a sane way to sort out the old
> kernel side syncppp (which is useless for todays networks as it doesn't
> do compression, IPv6 or auth protocols) except by going to user space.

Ok, but what we have in the tree should at least not be a crashing
mess that has to be marked BROKEN meanwhile :-)

This patch should address that issue.

Longer term I hope someone works on the infrastructure necessary that
would allow us to delete this and use generic PPP kernel+userspace
over these links.

Scanning over some of these older WAN drivers was truly scary.  No
locking at all over the HDLC protocol list, yikes!

commit 4951704b4e23d71b99ac933d8e6993bc6225ac13
Author: David S. Miller <davem@davemloft.net>
Date:   Mon May 12 03:29:11 2008 -0700

    syncppp: Fix crashes.
    
    The syncppp layer wants a mid-level netdev private pointer.
    
    It was using netdev->priv but that only worked by accident,
    and thus this scheme was broken when the device private
    allocation strategy changed.
    
    Add a proper mid-layer private pointer for uses like this,
    update syncppp and all users, and remove the HDLC_PPP broken
    tag from drivers/net/wan/Kconfig
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 8005dd1..d5140ae 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -150,11 +150,9 @@ config HDLC_FR
 
 config HDLC_PPP
 	tristate "Synchronous Point-to-Point Protocol (PPP) support"
-	depends on HDLC && BROKEN
+	depends on HDLC
 	help
 	  Generic HDLC driver supporting PPP over WAN connections.
-	  This module is currently broken and will cause a kernel panic
-	  when a device configured in PPP mode is activated.
 
 	  It will be replaced by new PPP implementation in Linux 2.6.26.
 
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 45ddfc9..b0fce13 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -629,7 +629,7 @@ static void sppp_channel_init(struct channel_data *chan)
 	d->base_addr = chan->cosa->datareg;
 	d->irq = chan->cosa->irq;
 	d->dma = chan->cosa->dma;
-	d->priv = chan;
+	d->ml_priv = chan;
 	sppp_attach(&chan->pppdev);
 	if (register_netdev(d)) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
@@ -650,7 +650,7 @@ static void sppp_channel_delete(struct channel_data *chan)
 
 static int cosa_sppp_open(struct net_device *d)
 {
-	struct channel_data *chan = d->priv;
+	struct channel_data *chan = d->ml_priv;
 	int err;
 	unsigned long flags;
 
@@ -690,7 +690,7 @@ static int cosa_sppp_open(struct net_device *d)
 
 static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = dev->ml_priv;
 
 	netif_stop_queue(dev);
 
@@ -701,7 +701,7 @@ static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 
 static void cosa_sppp_timeout(struct net_device *dev)
 {
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = dev->ml_priv;
 
 	if (test_bit(RXBIT, &chan->cosa->rxtx)) {
 		chan->stats.rx_errors++;
@@ -720,7 +720,7 @@ static void cosa_sppp_timeout(struct net_device *dev)
 
 static int cosa_sppp_close(struct net_device *d)
 {
-	struct channel_data *chan = d->priv;
+	struct channel_data *chan = d->ml_priv;
 	unsigned long flags;
 
 	netif_stop_queue(d);
@@ -800,7 +800,7 @@ static int sppp_tx_done(struct channel_data *chan, int size)
 
 static struct net_device_stats *cosa_net_stats(struct net_device *dev)
 {
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = dev->ml_priv;
 	return &chan->stats;
 }
 
@@ -1217,7 +1217,7 @@ static int cosa_sppp_ioctl(struct net_device *dev, struct ifreq *ifr,
 	int cmd)
 {
 	int rv;
-	struct channel_data *chan = dev->priv;
+	struct channel_data *chan = dev->ml_priv;
 	rv = cosa_ioctl_common(chan->cosa, chan, cmd, (unsigned long)ifr->ifr_data);
 	if (rv == -ENOIOCTLCMD) {
 		return sppp_do_ioctl(dev, ifr, cmd);
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 10396d9..0030833 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -45,7 +45,7 @@ static int ppp_open(struct net_device *dev)
 	int (*old_ioctl)(struct net_device *, struct ifreq *, int);
 	int result;
 
-	dev->priv = &state(hdlc)->syncppp_ptr;
+	dev->ml_priv = &state(hdlc)->syncppp_ptr;
 	state(hdlc)->syncppp_ptr = &state(hdlc)->pppdev;
 	state(hdlc)->pppdev.dev = dev;
 
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index 83dbc92..f3065d3 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -75,7 +75,7 @@ static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
  
 static int hostess_open(struct net_device *d)
 {
-	struct sv11_device *sv11=d->priv;
+	struct sv11_device *sv11=d->ml_priv;
 	int err = -1;
 	
 	/*
@@ -128,7 +128,7 @@ static int hostess_open(struct net_device *d)
 
 static int hostess_close(struct net_device *d)
 {
-	struct sv11_device *sv11=d->priv;
+	struct sv11_device *sv11=d->ml_priv;
 	/*
 	 *	Discard new frames
 	 */
@@ -159,14 +159,14 @@ static int hostess_close(struct net_device *d)
 
 static int hostess_ioctl(struct net_device *d, struct ifreq *ifr, int cmd)
 {
-	/* struct sv11_device *sv11=d->priv;
+	/* struct sv11_device *sv11=d->ml_priv;
 	   z8530_ioctl(d,&sv11->sync.chanA,ifr,cmd) */
 	return sppp_do_ioctl(d, ifr,cmd);
 }
 
 static struct net_device_stats *hostess_get_stats(struct net_device *d)
 {
-	struct sv11_device *sv11=d->priv;
+	struct sv11_device *sv11=d->ml_priv;
 	if(sv11)
 		return z8530_get_stats(&sv11->sync.chanA);
 	else
@@ -179,7 +179,7 @@ static struct net_device_stats *hostess_get_stats(struct net_device *d)
  
 static int hostess_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
-	struct sv11_device *sv11=d->priv;
+	struct sv11_device *sv11=d->ml_priv;
 	return z8530_queue_xmit(&sv11->sync.chanA, skb);
 }
 
@@ -325,6 +325,7 @@ static struct sv11_device *sv11_init(int iobase, int irq)
 		/* 
 		 *	Initialise the PPP components
 		 */
+		d->ml_priv = sv;
 		sppp_attach(&sv->netdev);
 		
 		/*
@@ -333,7 +334,6 @@ static struct sv11_device *sv11_init(int iobase, int irq)
 		
 		d->base_addr = iobase;
 		d->irq = irq;
-		d->priv = sv;
 		
 		if(register_netdev(d))
 		{
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 6635ece..62133ce 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -891,6 +891,7 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
 
     /* Initialize the sppp layer */
     /* An ioctl can cause a subsequent detach for raw frame interface */
+    dev->ml_priv = sc;
     sc->if_type = LMC_PPP;
     sc->check = 0xBEAFCAFE;
     dev->base_addr = pci_resource_start(pdev, 0);
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 11276bf..44a89df 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -241,6 +241,7 @@ static inline struct slvl_device *slvl_alloc(int iobase, int irq)
 		return NULL;
 
 	sv = d->priv;
+	d->ml_priv = sv;
 	sv->if_ptr = &sv->pppdev;
 	sv->pppdev.dev = d;
 	d->base_addr = iobase;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7c1d446..7469017 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -715,6 +715,9 @@ struct net_device
 	struct net		*nd_net;
 #endif
 
+	/* mid-layer private */
+	void			*ml_priv;
+
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
 	/* macvlan */
diff --git a/include/net/syncppp.h b/include/net/syncppp.h
index 877efa4..e43f407 100644
--- a/include/net/syncppp.h
+++ b/include/net/syncppp.h
@@ -59,7 +59,7 @@ struct ppp_device
 
 static inline struct sppp *sppp_of(struct net_device *dev) 
 {
-	struct ppp_device **ppp = dev->priv;
+	struct ppp_device **ppp = dev->ml_priv;
 	BUG_ON((*ppp)->dev != dev);
 	return &(*ppp)->sppp;
 }
