From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 08/29] pcmcia: dev_node removal (drivers with updated printk
	call)
Date: Wed, 19 May 2010 08:42:44 +0200
Message-ID: <1274251385-6196-8-git-send-email-linux@dominikbrodowski.net>
References: <20100519064149.GA5755@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Harald Welte <laforge@gnumonks.org>, linux-ide@vger.kernel.org,
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

As a second step, remove any usage of dev_node_t from drivers which
only wrote to this typedef/struct, except one printk() which can
easily be replaced by a dev_info()/dev_warn() call.

CC: Harald Welte <laforge@gnumonks.org>
CC: linux-ide@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: netdev@vger.kernel.org
CC: linux-usb@vger.kernel.org
Acked-by: Karsten Keil  <isdn@linux-pingi.de>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/cm4000_cs.c    |    9 +-----
 drivers/char/pcmcia/synclink_cs.c  |   10 +-----
 drivers/ide/ide-cs.c               |   12 ++-----
 drivers/isdn/hardware/avm/avm_cs.c |   60 +++---------------------------------
 drivers/isdn/hisax/elsa_cs.c       |   27 +---------------
 drivers/isdn/hisax/sedlbauer_cs.c  |   37 +---------------------
 drivers/isdn/hisax/teles_cs.c      |   37 +---------------------
 drivers/net/wireless/airo_cs.c     |   47 +---------------------------
 drivers/usb/host/sl811_cs.c        |   10 +-----
 9 files changed, 22 insertions(+), 227 deletions(-)

diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index 90b199f..e7956ac 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -106,7 +106,6 @@ static int major;		/* major number we get from the kernel */
 
 struct cm4000_dev {
 	struct pcmcia_device *p_dev;
-	dev_node_t node;		/* OS node (major,minor) */
 
 	unsigned char atr[MAX_ATR];
 	unsigned char rbuf[512];
@@ -884,8 +883,7 @@ static void monitor_card(unsigned long p)
 		/* slow down warning, but prompt immediately after insertion */
 		if (dev->cwarn == 0 || dev->cwarn == 10) {
 			set_bit(IS_BAD_CARD, &dev->flags);
-			printk(KERN_WARNING MODULE_NAME ": device %s: ",
-			       dev->node.dev_name);
+			dev_warn(&dev->p_dev->dev, MODULE_NAME ": ");
 			if (test_bit(IS_BAD_CSUM, &dev->flags)) {
 				DEBUGP(4, dev, "ATR checksum (0x%.2x, should "
 				       "be zero) failed\n", dev->atr_csum);
@@ -1781,11 +1779,6 @@ static int cm4000_config(struct pcmcia_device * link, int devno)
 		goto cs_release;
 
 	dev = link->priv;
-	sprintf(dev->node.dev_name, DEVICE_NAME "%d", devno);
-	dev->node.major = major;
-	dev->node.minor = devno;
-	dev->node.next = NULL;
-	link->dev_node = &dev->node;
 
 	return 0;
 
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 027690b..308903e 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -220,7 +220,6 @@ typedef struct _mgslpc_info {
 
 	/* PCMCIA support */
 	struct pcmcia_device	*p_dev;
-	dev_node_t	      node;
 	int		      stop;
 
 	/* SPPP/Cisco HDLC device parts */
@@ -614,13 +613,8 @@ static int mgslpc_config(struct pcmcia_device *link)
     info->io_base = link->io.BasePort1;
     info->irq_level = link->irq;
 
-    /* add to linked list of devices */
-    sprintf(info->node.dev_name, "mgslpc0");
-    info->node.major = info->node.minor = 0;
-    link->dev_node = &info->node;
-
-    printk(KERN_INFO "%s: index 0x%02x:",
-	   info->node.dev_name, link->conf.ConfigIndex);
+    dev_info(&link->dev, "index 0x%02x:",
+	    link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	    printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 17ad91e..0b7815d 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -65,8 +65,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 typedef struct ide_info_t {
 	struct pcmcia_device	*p_dev;
 	struct ide_host		*host;
-    int		ndev;
-    dev_node_t	node;
+	int			ndev;
 } ide_info_t;
 
 static void ide_release(struct pcmcia_device *);
@@ -308,13 +307,10 @@ static int ide_config(struct pcmcia_device *link)
 	goto failed;
 
     info->ndev = 1;
-    sprintf(info->node.dev_name, "hd%c", 'a' + host->ports[0]->index * 2);
-    info->node.major = host->ports[0]->major;
-    info->node.minor = 0;
     info->host = host;
-    link->dev_node = &info->node;
-    printk(KERN_INFO "ide-cs: %s: Vpp = %d.%d\n",
-	   info->node.dev_name, link->conf.Vpp / 10, link->conf.Vpp % 10);
+    dev_info(&link->dev, "ide-cs: hd%c: Vpp = %d.%d\n",
+	    'a' + host->ports[0]->index * 2,
+	    link->conf.Vpp / 10, link->conf.Vpp % 10);
 
     kfree(stk);
     return 0;
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 0d485f6..8bbc452 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -61,31 +61,6 @@ static void avmcs_release(struct pcmcia_device *link);
 
 static void avmcs_detach(struct pcmcia_device *p_dev);
 
-/*
-   A linked list of "instances" of the skeleton device.  Each actual
-   PCMCIA card corresponds to one device instance, and is described
-   by one struct pcmcia_device structure (defined in ds.h).
-
-   You may not want to use a linked list for this -- for example, the
-   memory card driver uses an array of struct pcmcia_device pointers, where minor
-   device numbers are used to derive the corresponding array index.
-*/
-
-/*
-   A driver needs to provide a dev_node_t structure for each device
-   on a card.  In some cases, there is only one device per card (for
-   example, ethernet cards, modems).  In other cases, there may be
-   many actual or logical devices (SCSI adapters, memory cards with
-   multiple partitions).  The dev_node_t structures need to be kept
-   in a linked list starting at the 'dev' field of a struct pcmcia_device
-   structure.  We allocate them in the card's private data structure,
-   because they generally can't be allocated dynamically.
-*/
-   
-typedef struct local_info_t {
-    dev_node_t	node;
-} local_info_t;
-
 /*======================================================================
 
     avmcs_attach() creates an "instance" of the driver, allocating
@@ -100,7 +75,6 @@ typedef struct local_info_t {
 
 static int avmcs_probe(struct pcmcia_device *p_dev)
 {
-    local_info_t *local;
 
     /* The io structure describes IO port mapping */
     p_dev->io.NumPorts1 = 16;
@@ -113,16 +87,7 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
     p_dev->conf.ConfigIndex = 1;
     p_dev->conf.Present = PRESENT_OPTION;
 
-    /* Allocate space for private device-specific data */
-    local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
-    if (!local)
-        goto err;
-    p_dev->priv = local;
-
     return avmcs_config(p_dev);
-
- err:
-    return -ENOMEM;
 } /* avmcs_attach */
 
 /*======================================================================
@@ -137,7 +102,6 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
 static void avmcs_detach(struct pcmcia_device *link)
 {
 	avmcs_release(link);
-	kfree(link->priv);
 } /* avmcs_detach */
 
 /*======================================================================
@@ -168,14 +132,11 @@ static int avmcs_configcheck(struct pcmcia_device *p_dev,
 
 static int avmcs_config(struct pcmcia_device *link)
 {
-    local_info_t *dev;
     int i = -1;
     char devname[128];
     int cardtype;
     int (*addcard)(unsigned int port, unsigned irq);
 
-    dev = link->priv;
-
     devname[0] = 0;
     if (link->prod_id[1])
 	    strlcpy(devname, link->prod_id[1], sizeof(devname));
@@ -204,15 +165,11 @@ static int avmcs_config(struct pcmcia_device *link)
 
     } while (0);
 
-    /* At this point, the dev_node_t structure(s) should be
-       initialized and arranged in a linked list at link->dev. */
-
     if (devname[0]) {
 	char *s = strrchr(devname, ' ');
 	if (!s)
 	   s = devname;
 	else s++;
-	strcpy(dev->node.dev_name, s);
         if (strcmp("M1", s) == 0) {
            cardtype = AVM_CARDTYPE_M1;
         } else if (strcmp("M2", s) == 0) {
@@ -220,14 +177,8 @@ static int avmcs_config(struct pcmcia_device *link)
 	} else {
            cardtype = AVM_CARDTYPE_B1;
 	}
-    } else {
-        strcpy(dev->node.dev_name, "b1");
+    } else
         cardtype = AVM_CARDTYPE_B1;
-    }
-
-    dev->node.major = 64;
-    dev->node.minor = 0;
-    link->dev_node = &dev->node;
 
     /* If any step failed, release any partially configured state */
     if (i != 0) {
@@ -243,12 +194,11 @@ static int avmcs_config(struct pcmcia_device *link)
         case AVM_CARDTYPE_B1: addcard = b1pcmcia_addcard_b1; break;
     }
     if ((i = (*addcard)(link->io.BasePort1, link->irq)) < 0) {
-        printk(KERN_ERR "avm_cs: failed to add AVM-%s-Controller at i/o %#x, irq %d\n",
-		dev->node.dev_name, link->io.BasePort1, link->irq);
-	avmcs_release(link);
-	return -ENODEV;
+	    dev_err(&link->dev, "avm_cs: failed to add AVM-Controller at i/o %#x, irq %d\n",
+		    link->io.BasePort1, link->irq);
+	    avmcs_release(link);
+	    return -ENODEV;
     }
-    dev->node.minor = i;
     return 0;
 
 } /* avmcs_config */
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 8e170e4..218927e 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -87,24 +87,8 @@ static void elsa_cs_release(struct pcmcia_device *link);
 
 static void elsa_cs_detach(struct pcmcia_device *p_dev) __devexit;
 
-/*
-   A driver needs to provide a dev_node_t structure for each device
-   on a card.  In some cases, there is only one device per card (for
-   example, ethernet cards, modems).  In other cases, there may be
-   many actual or logical devices (SCSI adapters, memory cards with
-   multiple partitions).  The dev_node_t structures need to be kept
-   in a linked list starting at the 'dev' field of a struct pcmcia_device
-   structure.  We allocate them in the card's private data structure,
-   because they generally shouldn't be allocated dynamically.
-   In this case, we also provide a flag to indicate if a device is
-   "stopped" due to a power management event, or card ejection.  The
-   device IO routines can use a flag like this to throttle IO to a
-   card that is not ready to accept it.
-*/
-
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t          node;
     int                 busy;
     int			cardnr;
 } local_info_t;
@@ -226,16 +210,9 @@ static int __devinit elsa_cs_config(struct pcmcia_device *link)
     if (i != 0)
 	goto failed;
 
-    /* At this point, the dev_node_t structure(s) should be
-       initialized and arranged in a linked list at link->dev. *//*  */
-    sprintf(dev->node.dev_name, "elsa");
-    dev->node.major = dev->node.minor = 0x0;
-
-    link->dev_node = &dev->node;
-
     /* Finally, report what we've done */
-    printk(KERN_INFO "%s: index 0x%02x: ",
-           dev->node.dev_name, link->conf.ConfigIndex);
+    dev_info(&link->dev, "index 0x%02x: ",
+	    link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 7778385..1f4feaa 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -87,32 +87,8 @@ static void sedlbauer_release(struct pcmcia_device *link);
 
 static void sedlbauer_detach(struct pcmcia_device *p_dev) __devexit;
 
-/*
-   You'll also need to prototype all the functions that will actually
-   be used to talk to your device.  See 'memory_cs' for a good example
-   of a fully self-sufficient driver; the other drivers rely more or
-   less on other parts of the kernel.
-*/
-
-/*
-   A driver needs to provide a dev_node_t structure for each device
-   on a card.  In some cases, there is only one device per card (for
-   example, ethernet cards, modems).  In other cases, there may be
-   many actual or logical devices (SCSI adapters, memory cards with
-   multiple partitions).  The dev_node_t structures need to be kept
-   in a linked list starting at the 'dev' field of a struct pcmcia_device
-   structure.  We allocate them in the card's private data structure,
-   because they generally shouldn't be allocated dynamically.
-
-   In this case, we also provide a flag to indicate if a device is
-   "stopped" due to a power management event, or card ejection.  The
-   device IO routines can use a flag like this to throttle IO to a
-   card that is not ready to accept it.
-*/
-   
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t		node;
     int			stop;
     int			cardnr;
 } local_info_t;
@@ -279,7 +255,6 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 
 static int __devinit sedlbauer_config(struct pcmcia_device *link)
 {
-    local_info_t *dev = link->priv;
     win_req_t *req;
     int ret;
     IsdnCard_t  icard;
@@ -315,17 +290,9 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
     if (ret)
 	    goto failed;
 
-    /*
-      At this point, the dev_node_t structure(s) need to be
-      initialized and arranged in a linked list at link->dev.
-    */
-    sprintf(dev->node.dev_name, "sedlbauer");
-    dev->node.major = dev->node.minor = 0;
-    link->dev_node = &dev->node;
-
     /* Finally, report what we've done */
-    printk(KERN_INFO "%s: index 0x%02x:",
-	   dev->node.dev_name, link->conf.ConfigIndex);
+    dev_info(&link->dev, "index 0x%02x:",
+	   link->conf.ConfigIndex);
     if (link->conf.Vpp)
 	printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 02dec13..5771955 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -68,34 +68,8 @@ static void teles_cs_release(struct pcmcia_device *link);
 
 static void teles_detach(struct pcmcia_device *p_dev) __devexit ;
 
-/*
-   A linked list of "instances" of the teles_cs device.  Each actual
-   PCMCIA card corresponds to one device instance, and is described
-   by one struct pcmcia_device structure (defined in ds.h).
-
-   You may not want to use a linked list for this -- for example, the
-   memory card driver uses an array of struct pcmcia_device pointers, where minor
-   device numbers are used to derive the corresponding array index.
-*/
-
-/*
-   A driver needs to provide a dev_node_t structure for each device
-   on a card.  In some cases, there is only one device per card (for
-   example, ethernet cards, modems).  In other cases, there may be
-   many actual or logical devices (SCSI adapters, memory cards with
-   multiple partitions).  The dev_node_t structures need to be kept
-   in a linked list starting at the 'dev' field of a struct pcmcia_device
-   structure.  We allocate them in the card's private data structure,
-   because they generally shouldn't be allocated dynamically.
-   In this case, we also provide a flag to indicate if a device is
-   "stopped" due to a power management event, or card ejection.  The
-   device IO routines can use a flag like this to throttle IO to a
-   card that is not ready to accept it.
-*/
-
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
-    dev_node_t          node;
     int                 busy;
     int			cardnr;
 } local_info_t;
@@ -216,16 +190,9 @@ static int __devinit teles_cs_config(struct pcmcia_device *link)
     if (i != 0)
       goto cs_failed;
 
-    /* At this point, the dev_node_t structure(s) should be
-       initialized and arranged in a linked list at link->dev. *//*  */
-    sprintf(dev->node.dev_name, "teles");
-    dev->node.major = dev->node.minor = 0x0;
-
-    link->dev_node = &dev->node;
-
     /* Finally, report what we've done */
-    printk(KERN_INFO "%s: index 0x%02x:",
-           dev->node.dev_name, link->conf.ConfigIndex);
+    dev_info(&link->dev, "index 0x%02x:",
+	    link->conf.ConfigIndex);
     if (link->conf.Attributes & CONF_ENABLE_IRQ)
 	    printk(", irq %d", link->irq);
     if (link->io.NumPorts1)
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 7867c51..33bdc6a 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -75,42 +75,7 @@ static void airo_release(struct pcmcia_device *link);
 
 static void airo_detach(struct pcmcia_device *p_dev);
 
-/*
-   You'll also need to prototype all the functions that will actually
-   be used to talk to your device.  See 'pcmem_cs' for a good example
-   of a fully self-sufficient driver; the other drivers rely more or
-   less on other parts of the kernel.
-*/
-
-/*
-   A linked list of "instances" of the  aironet device.  Each actual
-   PCMCIA card corresponds to one device instance, and is described
-   by one struct pcmcia_device structure (defined in ds.h).
-
-   You may not want to use a linked list for this -- for example, the
-   memory card driver uses an array of struct pcmcia_device pointers,
-   where minor device numbers are used to derive the corresponding
-   array index.
-*/
-
-/*
-   A driver needs to provide a dev_node_t structure for each device
-   on a card.  In some cases, there is only one device per card (for
-   example, ethernet cards, modems).  In other cases, there may be
-   many actual or logical devices (SCSI adapters, memory cards with
-   multiple partitions).  The dev_node_t structures need to be kept
-   in a linked list starting at the 'dev' field of a struct pcmcia_device
-   structure.  We allocate them in the card's private data structure,
-   because they generally shouldn't be allocated dynamically.
-
-   In this case, we also provide a flag to indicate if a device is
-   "stopped" due to a power management event, or card ejection.  The
-   device IO routines can use a flag like this to throttle IO to a
-   card that is not ready to accept it.
-*/
-
 typedef struct local_info_t {
-	dev_node_t	node;
 	struct net_device *eth_dev;
 } local_info_t;
 
@@ -311,17 +276,9 @@ static int airo_config(struct pcmcia_device *link)
 	if (!((local_info_t *)link->priv)->eth_dev)
 		goto failed;
 
-	/*
-	  At this point, the dev_node_t structure(s) need to be
-	  initialized and arranged in a linked list at link->dev_node.
-	*/
-	strcpy(dev->node.dev_name, ((local_info_t *)link->priv)->eth_dev->name);
-	dev->node.major = dev->node.minor = 0;
-	link->dev_node = &dev->node;
-
 	/* Finally, report what we've done */
-	printk(KERN_INFO "%s: index 0x%02x: ",
-	       dev->node.dev_name, link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x: ",
+	       link->conf.ConfigIndex);
 	if (link->conf.Vpp)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
 	printk(", irq %d", link->irq);
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index a712788..58cb73c 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -47,7 +47,6 @@ static const char driver_name[DEV_NAME_LEN]  = "sl811_cs";
 
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
-	dev_node_t		node;
 } local_info_t;
 
 static void sl811_cs_release(struct pcmcia_device * link);
@@ -185,7 +184,6 @@ static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 static int sl811_cs_config(struct pcmcia_device *link)
 {
 	struct device		*parent = &link->dev;
-	local_info_t		*dev = link->priv;
 	int			ret;
 
 	dev_dbg(&link->dev, "sl811_cs_config\n");
@@ -204,12 +202,8 @@ static int sl811_cs_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	sprintf(dev->node.dev_name, driver_name);
-	dev->node.major = dev->node.minor = 0;
-	link->dev_node = &dev->node;
-
-	printk(KERN_INFO "%s: index 0x%02x: ",
-	       dev->node.dev_name, link->conf.ConfigIndex);
+	dev_info(&link->dev, "index 0x%02x: ",
+		link->conf.ConfigIndex);
 	if (link->conf.Vpp)
 		printk(", Vpp %d.%d", link->conf.Vpp/10, link->conf.Vpp%10);
 	printk(", irq %d", link->irq);
-- 
1.6.3.3
