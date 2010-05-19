From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 09/29] pcmcia: dev_node removal (drivers with
	unregister_netdev check)
Date: Wed, 19 May 2010 08:42:45 +0200
Message-ID: <1274251385-6196-9-git-send-email-linux@dominikbrodowski.net>
References: <20100519064149.GA5755@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Dominik Brodowski <linux@dominikbrodowski.net>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100519064149.GA5755@comet.dominikbrodowski.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

As a third step, remove any usage of dev_node_t from drivers which
only wrote to this typedef/struct, except to determine whether
register_netdev() succeeded previously. However, the function calling
unregister_netdev() was only ever called by the PCMCIA core if
register_netdev() succeeded previously. The lonely exception was
easily fixed.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/3c574_cs.c              |    8 +------
 drivers/net/pcmcia/3c589_cs.c              |    9 +-------
 drivers/net/pcmcia/axnet_cs.c              |    8 +------
 drivers/net/pcmcia/com20020_cs.c           |   21 ++++++-------------
 drivers/net/pcmcia/fmvj18x_cs.c            |    8 +------
 drivers/net/pcmcia/ibmtr_cs.c              |    8 +------
 drivers/net/pcmcia/nmclan_cs.c             |    8 +------
 drivers/net/pcmcia/pcnet_cs.c              |    8 +------
 drivers/net/pcmcia/smc91c92_cs.c           |    9 +-------
 drivers/net/pcmcia/xirc2ps_cs.c            |   29 +---------------------------
 drivers/net/wireless/orinoco/orinoco_cs.c  |   14 +------------
 drivers/net/wireless/orinoco/spectrum_cs.c |   14 +------------
 drivers/net/wireless/ray_cs.c              |    6 +----
 drivers/net/wireless/ray_cs.h              |    1 -
 drivers/net/wireless/wl3501.h              |    1 -
 drivers/net/wireless/wl3501_cs.c           |   15 ++-----------
 16 files changed, 22 insertions(+), 145 deletions(-)

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 1442831..774e41c 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -200,7 +200,6 @@ enum Window4 {		/* Window 4: Xcvr/media bits. */
 
 struct el3_private {
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 	u16 advertising, partner;		/* NWay media advertisement */
 	unsigned char phys;			/* MII device address */
 	unsigned int autoselect:1, default_media:3;	/* Read from the EEPROM/Wn3_Config. */
@@ -309,8 +308,7 @@ static void tc574_detach(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "3c574_detach()\n");
 
-	if (link->dev_node)
-		unregister_netdev(dev);
+	unregister_netdev(dev);
 
 	tc574_release(link);
 
@@ -444,17 +442,13 @@ static int tc574_config(struct pcmcia_device *link)
 		}
 	}
 
-	link->dev_node = &lp->node;
 	SET_NETDEV_DEV(dev, &link->dev);
 
 	if (register_netdev(dev) != 0) {
 		printk(KERN_NOTICE "3c574_cs: register_netdev() failed\n");
-		link->dev_node = NULL;
 		goto failed;
 	}
 
-	strcpy(lp->node.dev_name, dev->name);
-
 	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
 	       "hw_addr %pM.\n",
 	       dev->name, cardname, dev->base_addr, dev->irq,
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 405d772..5ab589d 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -106,7 +106,6 @@ enum RxFilter {
 
 struct el3_private {
 	struct pcmcia_device	*p_dev;
-    dev_node_t 		node;
     /* For transceiver monitoring */
     struct timer_list	media;
     u16			media_status;
@@ -222,8 +221,7 @@ static void tc589_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "3c589_detach\n");
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
     tc589_release(link);
 
@@ -241,7 +239,6 @@ static void tc589_detach(struct pcmcia_device *link)
 static int tc589_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    struct el3_private *lp = netdev_priv(dev);
     __be16 *phys_addr;
     int ret, i, j, multi = 0, fifo;
     unsigned int ioaddr;
@@ -312,17 +309,13 @@ static int tc589_config(struct pcmcia_device *link)
     else
 	printk(KERN_ERR "3c589_cs: invalid if_port requested\n");
     
-    link->dev_node = &lp->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_ERR "3c589_cs: register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto failed;
     }
 
-    strcpy(lp->node.dev_name, dev->name);
-
     printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, "
 	   "hw_addr %pM\n",
 	   dev->name, (multi ? "562" : "589"), dev->base_addr, dev->irq,
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 967547a..59f6fa3 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -113,7 +113,6 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id);
 
 typedef struct axnet_dev_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t		node;
     caddr_t		base;
     struct timer_list	watchdog;
     int			stale, fast_poll;
@@ -194,8 +193,7 @@ static void axnet_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "axnet_detach(0x%p)\n", link);
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
     axnet_release(link);
 
@@ -392,17 +390,13 @@ static int axnet_config(struct pcmcia_device *link)
     }
 
     info->phy_id = (i < 32) ? i : -1;
-    link->dev_node = &info->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "axnet_cs: register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto failed;
     }
 
-    strcpy(info->node.dev_name, dev->name);
-
     printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, "
 	   "hw_addr %pM\n",
 	   dev->name, ((info->flags & IS_AX88790) ? 7 : 1),
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 278438b..5643f94 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -122,7 +122,6 @@ static void com20020_detach(struct pcmcia_device *p_dev);
 
 typedef struct com20020_dev_t {
     struct net_device       *dev;
-    dev_node_t          node;
 } com20020_dev_t;
 
 /*======================================================================
@@ -195,18 +194,16 @@ static void com20020_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "com20020_detach\n");
 
-    if (link->dev_node) {
-	dev_dbg(&link->dev, "unregister...\n");
+    dev_dbg(&link->dev, "unregister...\n");
 
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
-	/*
-	 * this is necessary because we register our IRQ separately
-	 * from card services.
-	 */
-	if (dev->irq)
+    /*
+     * this is necessary because we register our IRQ separately
+     * from card services.
+     */
+    if (dev->irq)
 	    free_irq(dev->irq, dev);
-    }
 
     com20020_release(link);
 
@@ -297,7 +294,6 @@ static int com20020_config(struct pcmcia_device *link)
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
-    link->dev_node = &info->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     i = com20020_found(dev, 0);	/* calls register_netdev */
@@ -305,12 +301,9 @@ static int com20020_config(struct pcmcia_device *link)
     if (i != 0) {
 	dev_printk(KERN_NOTICE, &link->dev,
 		"com20020_cs: com20020_found() failed\n");
-	link->dev_node = NULL;
 	goto failed;
     }
 
-    strcpy(info->node.dev_name, dev->name);
-
     dev_dbg(&link->dev,KERN_INFO "%s: port %#3lx, irq %d\n",
            dev->name, dev->base_addr, dev->irq);
     return 0;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 31f1a03..6580d78 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -110,7 +110,6 @@ typedef enum { MBH10302, MBH10304, TDK, CONTEC, LA501, UNGERMANN,
 */
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t node;
     long open_time;
     uint tx_started:1;
     uint tx_queue;
@@ -274,8 +273,7 @@ static void fmvj18x_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "fmvj18x_detach\n");
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
     fmvj18x_release(link);
 
@@ -523,17 +521,13 @@ static int fmvj18x_config(struct pcmcia_device *link)
     }
 
     lp->cardtype = cardtype;
-    link->dev_node = &lp->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "fmvj18x_cs: register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto failed;
     }
 
-    strcpy(lp->node.dev_name, dev->name);
-
     /* print current configuration */
     printk(KERN_INFO "%s: %s, sram %s, port %#3lx, irq %d, "
 	   "hw_addr %pM\n",
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 0225cdf..2e42d80 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -104,7 +104,6 @@ static void ibmtr_detach(struct pcmcia_device *p_dev);
 typedef struct ibmtr_dev_t {
 	struct pcmcia_device	*p_dev;
     struct net_device	*dev;
-    dev_node_t          node;
     window_handle_t     sram_win_handle;
     struct tok_info	*ti;
 } ibmtr_dev_t;
@@ -190,8 +189,7 @@ static void ibmtr_detach(struct pcmcia_device *link)
      */
     ti->sram_phys |= 1;
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
     
     del_timer_sync(&(ti->tr_timer));
 
@@ -289,18 +287,14 @@ static int __devinit ibmtr_config(struct pcmcia_device *link)
         Adapters Technical Reference"  SC30-3585 for this info.  */
     ibmtr_hw_setup(dev, mmiobase);
 
-    link->dev_node = &info->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     i = ibmtr_probe_card(dev);
     if (i != 0) {
 	printk(KERN_NOTICE "ibmtr_cs: register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto failed;
     }
 
-    strcpy(info->node.dev_name, dev->name);
-
     printk(KERN_INFO
 	   "%s: port %#3lx, irq %d,  mmio %#5lx, sram %#5lx, hwaddr=%pM\n",
            dev->name, dev->base_addr, dev->irq,
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index b779e3a..d8a3b3c 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -363,7 +363,6 @@ typedef struct _mace_statistics {
 
 typedef struct _mace_private {
 	struct pcmcia_device	*p_dev;
-    dev_node_t node;
     struct net_device_stats linux_stats; /* Linux statistics counters */
     mace_statistics mace_stats; /* MACE chip statistics counters */
 
@@ -491,8 +490,7 @@ static void nmclan_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "nmclan_detach\n");
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
     nmclan_release(link);
 
@@ -696,18 +694,14 @@ static int nmclan_config(struct pcmcia_device *link)
   else
     printk(KERN_NOTICE "nmclan_cs: invalid if_port requested\n");
 
-  link->dev_node = &lp->node;
   SET_NETDEV_DEV(dev, &link->dev);
 
   i = register_netdev(dev);
   if (i != 0) {
     printk(KERN_NOTICE "nmclan_cs: register_netdev() failed\n");
-    link->dev_node = NULL;
     goto failed;
   }
 
-  strcpy(lp->node.dev_name, dev->name);
-
   printk(KERN_INFO "%s: nmclan: port %#3lx, irq %d, %s port,"
 	 " hw_addr %pM\n",
 	 dev->name, dev->base_addr, dev->irq, if_names[dev->if_port],
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index af09be4..6f77a76 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -208,7 +208,6 @@ static hw_info_t dl10022_info = { 0, 0, 0, 0, IS_DL10022|HAS_MII };
 
 typedef struct pcnet_dev_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t		node;
     u_int		flags;
     void		__iomem *base;
     struct timer_list	watchdog;
@@ -287,8 +286,7 @@ static void pcnet_detach(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "pcnet_detach\n");
 
-	if (link->dev_node)
-		unregister_netdev(dev);
+	unregister_netdev(dev);
 
 	pcnet_release(link);
 
@@ -639,17 +637,13 @@ static int pcnet_config(struct pcmcia_device *link)
     if (info->flags & (IS_DL10019|IS_DL10022))
 	mii_phy_probe(dev);
 
-    link->dev_node = &info->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "pcnet_cs: register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto failed;
     }
 
-    strcpy(info->node.dev_name, dev->name);
-
     if (info->flags & (IS_DL10019|IS_DL10022)) {
 	u_char id = inb(dev->base_addr + 0x1a);
 	printk(KERN_INFO "%s: NE2000 (DL100%d rev %02x): ",
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index ad061c7..59796e7 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -103,7 +103,6 @@ struct smc_private {
     u_short			manfid;
     u_short			cardid;
 
-    dev_node_t			node;
     struct sk_buff		*saved_skb;
     int				packets_waiting;
     void			__iomem *base;
@@ -323,7 +322,6 @@ static int smc91c92_probe(struct pcmcia_device *link)
 	return -ENOMEM;
     smc = netdev_priv(dev);
     smc->p_dev = link;
-    link->priv = dev;
 
     spin_lock_init(&smc->lock);
     link->io.NumPorts1 = 16;
@@ -361,8 +359,7 @@ static void smc91c92_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "smc91c92_detach\n");
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
     smc91c92_release(link);
 
@@ -956,17 +953,13 @@ static int smc91c92_config(struct pcmcia_device *link)
 	SMC_SELECT_BANK(0);
     }
 
-    link->dev_node = &smc->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_ERR "smc91c92_cs: register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto config_undo;
     }
 
-    strcpy(smc->node.dev_name, dev->name);
-
     printk(KERN_INFO "%s: smc91c%s rev %d: io %#3lx, irq %d, "
 	   "hw_addr %pM\n",
 	   dev->name, name, (rev & 0x0f), dev->base_addr, dev->irq,
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index c9e7d7d..5e6b62b 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -297,31 +297,9 @@ static void xirc2ps_detach(struct pcmcia_device *p_dev);
 
 static irqreturn_t xirc2ps_interrupt(int irq, void *dev_id);
 
-/****************
- * A linked list of "instances" of the device.  Each actual
- * PCMCIA card corresponds to one device instance, and is described
- * by one struct pcmcia_device structure (defined in ds.h).
- *
- * You may not want to use a linked list for this -- for example, the
- * memory card driver uses an array of struct pcmcia_device pointers, where minor
- * device numbers are used to derive the corresponding array index.
- */
-
-/****************
- * A driver needs to provide a dev_node_t structure for each device
- * on a card.  In some cases, there is only one device per card (for
- * example, ethernet cards, modems).  In other cases, there may be
- * many actual or logical devices (SCSI adapters, memory cards with
- * multiple partitions).  The dev_node_t structures need to be kept
- * in a linked list starting at the 'dev' field of a struct pcmcia_device
- * structure.  We allocate them in the card's private data structure,
- * because they generally can't be allocated dynamically.
- */
-
 typedef struct local_info_t {
 	struct net_device	*dev;
 	struct pcmcia_device	*p_dev;
-    dev_node_t node;
 
     int card_type;
     int probe_port;
@@ -579,8 +557,7 @@ xirc2ps_detach(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "detach\n");
 
-    if (link->dev_node)
-	unregister_netdev(dev);
+    unregister_netdev(dev);
 
     xirc2ps_release(link);
 
@@ -985,17 +962,13 @@ xirc2ps_config(struct pcmcia_device * link)
     if (local->dingo)
 	do_reset(dev, 1); /* a kludge to make the cem56 work */
 
-    link->dev_node = &local->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
     if ((err=register_netdev(dev))) {
 	printk(KNOT_XIRC "register_netdev() failed\n");
-	link->dev_node = NULL;
 	goto config_error;
     }
 
-    strcpy(local->node.dev_name, dev->name);
-
     /* give some infos about the hardware */
     printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr %pM\n",
 	   dev->name, local->manf_str,(u_long)dev->base_addr, (int)dev->irq,
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 5d29b11..03056ab 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -50,7 +50,6 @@ MODULE_PARM_DESC(ignore_cis_vcc, "Allow voltage mismatch between card and socket
  * struct orinoco_private */
 struct orinoco_pccard {
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 
 	/* Used to handle hard reset */
 	/* yuck, we need this hack to work around the insanity of the
@@ -140,8 +139,7 @@ static void orinoco_cs_detach(struct pcmcia_device *link)
 {
 	struct orinoco_private *priv = link->priv;
 
-	if (link->dev_node)
-		orinoco_if_del(priv);
+	orinoco_if_del(priv);
 
 	orinoco_cs_release(link);
 
@@ -226,7 +224,6 @@ static int
 orinoco_cs_config(struct pcmcia_device *link)
 {
 	struct orinoco_private *priv = link->priv;
-	struct orinoco_pccard *card = priv->card;
 	hermes_t *hw = &priv->hw;
 	int ret;
 	void __iomem *mem;
@@ -276,9 +273,6 @@ orinoco_cs_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Ok, we have the configuration, prepare to register the netdev */
-	card->node.major = card->node.minor = 0;
-
 	/* Initialise the main driver */
 	if (orinoco_init(priv) != 0) {
 		printk(KERN_ERR PFX "orinoco_init() failed\n");
@@ -292,12 +286,6 @@ orinoco_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/* At this point, the dev_node_t structure(s) needs to be
-	 * initialized and arranged in a linked list at link->dev_node. */
-	strcpy(card->node.dev_name, priv->ndev->name);
-	link->dev_node = &card->node; /* link->dev_node being non-NULL is also
-				       * used to indicate that the
-				       * net_device has been registered */
 	return 0;
 
  failed:
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 7a8e056..41b9ce4 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -57,7 +57,6 @@ MODULE_PARM_DESC(ignore_cis_vcc, "Allow voltage mismatch between card and socket
  * struct orinoco_private */
 struct orinoco_pccard {
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
 };
 
 /********************************************************************/
@@ -214,8 +213,7 @@ static void spectrum_cs_detach(struct pcmcia_device *link)
 {
 	struct orinoco_private *priv = link->priv;
 
-	if (link->dev_node)
-		orinoco_if_del(priv);
+	orinoco_if_del(priv);
 
 	spectrum_cs_release(link);
 
@@ -300,7 +298,6 @@ static int
 spectrum_cs_config(struct pcmcia_device *link)
 {
 	struct orinoco_private *priv = link->priv;
-	struct orinoco_pccard *card = priv->card;
 	hermes_t *hw = &priv->hw;
 	int ret;
 	void __iomem *mem;
@@ -350,9 +347,6 @@ spectrum_cs_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	/* Ok, we have the configuration, prepare to register the netdev */
-	card->node.major = card->node.minor = 0;
-
 	/* Reset card */
 	if (spectrum_cs_hard_reset(priv) != 0)
 		goto failed;
@@ -370,12 +364,6 @@ spectrum_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	/* At this point, the dev_node_t structure(s) needs to be
-	 * initialized and arranged in a linked list at link->dev_node. */
-	strcpy(card->node.dev_name, priv->ndev->name);
-	link->dev_node = &card->node; /* link->dev_node being non-NULL is also
-				       * used to indicate that the
-				       * net_device has been registered */
 	return 0;
 
  failed:
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index fe4642a..18a93f1 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -379,8 +379,7 @@ static void ray_detach(struct pcmcia_device *link)
 	del_timer(&local->timer);
 
 	if (link->priv) {
-		if (link->dev_node)
-			unregister_netdev(dev);
+		unregister_netdev(dev);
 		free_netdev(dev);
 	}
 	dev_dbg(&link->dev, "ray_cs ray_detach ending\n");
@@ -489,9 +488,6 @@ static int ray_config(struct pcmcia_device *link)
 		return i;
 	}
 
-	strcpy(local->node.dev_name, dev->name);
-	link->dev_node = &local->node;
-
 	printk(KERN_INFO "%s: RayLink, irq %d, hw_addr %pM\n",
 	       dev->name, dev->irq, dev->dev_addr);
 
diff --git a/drivers/net/wireless/ray_cs.h b/drivers/net/wireless/ray_cs.h
index 1e23b7f..9f01ddb 100644
--- a/drivers/net/wireless/ray_cs.h
+++ b/drivers/net/wireless/ray_cs.h
@@ -25,7 +25,6 @@ struct beacon_rx {
 typedef struct ray_dev_t {
     int card_status;
     int authentication_state;
-    dev_node_t  node;
     window_handle_t amem_handle;   /* handle to window for attribute memory  */
     window_handle_t rmem_handle;   /* handle to window for rx buffer on card */
     void __iomem *sram;            /* pointer to beginning of shared RAM     */
diff --git a/drivers/net/wireless/wl3501.h b/drivers/net/wireless/wl3501.h
index 8bce1a5..8816e37 100644
--- a/drivers/net/wireless/wl3501.h
+++ b/drivers/net/wireless/wl3501.h
@@ -610,7 +610,6 @@ struct wl3501_card {
 	struct iw_statistics		wstats;
 	struct iw_spy_data		spy_data;
 	struct iw_public_data		wireless_data;
-	struct dev_node_t		node;
 	struct pcmcia_device		*p_dev;
 };
 #endif
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index c43f05b..5e5d24c 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1451,6 +1451,8 @@ static void wl3501_detach(struct pcmcia_device *link)
 	netif_device_detach(dev);
 	wl3501_release(link);
 
+	unregister_netdev(dev);
+
 	if (link->priv)
 		free_netdev(link->priv);
 
@@ -1977,20 +1979,15 @@ static int wl3501_config(struct pcmcia_device *link)
 	}
 
 	this = netdev_priv(dev);
-	/*
-	 * At this point, the dev_node_t structure(s) should be initialized and
-	 * arranged in a linked list at link->dev_node.
-	 */
-	link->dev_node = &this->node;
 
 	this->base_addr = dev->base_addr;
 
 	if (!wl3501_get_flash_mac_addr(this)) {
 		printk(KERN_WARNING "%s: Cant read MAC addr in flash ROM?\n",
 		       dev->name);
+		unregister_netdev(dev);
 		goto failed;
 	}
-	strcpy(this->node.dev_name, dev->name);
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ((char *)&this->mac_addr)[i];
@@ -2034,12 +2031,6 @@ failed:
  */
 static void wl3501_release(struct pcmcia_device *link)
 {
-	struct net_device *dev = link->priv;
-
-	/* Unlink the device chain */
-	if (link->dev_node)
-		unregister_netdev(dev);
-
 	pcmcia_disable_device(link);
 }
 
-- 
1.6.3.3
