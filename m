From: Russell King <rmk+pcmcia@arm.linux.org.uk>
Subject: [PATCH] 2.6 PCMCIA netdevice ordering issues
Date: Mon, 8 Mar 2004 00:47:05 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308004705.D7065@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-pcmcia@lists.infradead.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an *untested* patch (PCMCIA people, please test) to fix
initialisation ordering issues in these network device drivers.
I don't have the hardware to be able to test these changes, although
it passes a modular build without warnings.

Andrew - it may be worth sticking these in -mm so they get some
visibility via your tree as well.

Many of these drivers were calling register_netdev() before they had
completed their initialisation.

In addition, they were calling register_netdev with the
"DEV_CONFIG_PENDING" flag still set, which prevents hotplug scripts
from bringing up the interface.

Also, we take care to ensure that link->dev is correctly set - this
is used to tell the PCMCIA release code if the netdev is currently
registered (yes, that's probably racy at present, but lets sort one
problem at a time.)

I've arranged that all drivers register the netdevice as close as
possible to the end of their initialisation, copy the net device's
name for cardmgr to pass to it's network scripts, and then print out
whatever information the driver wants to.

Finally, a note about ibmtr - it seemed to assume that cardmgr wanted
"tr0" or "tr1" depending on the base address, and completely ignoring
the real device which the netdev layer allocated it.  I've assumed
that this is wrong (since the netdev name is used in printk messages),
and changed it to behave the same as the other drivers.

diff -urpN orig/drivers/net/pcmcia/3c574_cs.c linux/drivers/net/pcmcia/3c574_cs.c
--- orig/drivers/net/pcmcia/3c574_cs.c	Wed Feb 18 22:34:14 2004
+++ linux/drivers/net/pcmcia/3c574_cs.c	Mon Mar  8 00:31:46 2004
@@ -384,6 +384,8 @@ static void tc574_detach(dev_link_t *lin
 #define CS_CHECK(fn, ret) \
   do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
 
+static char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
+
 static void tc574_config(dev_link_t *link)
 {
 	client_handle_t handle = link->handle;
@@ -396,6 +398,7 @@ static void tc574_config(dev_link_t *lin
 	ioaddr_t ioaddr;
 	u16 *phys_addr;
 	char *cardname;
+	union wn3_config config;
 
 	phys_addr = (u16 *)dev->dev_addr;
 
@@ -431,15 +434,7 @@ static void tc574_config(dev_link_t *lin
 	dev->irq = link->irq.AssignedIRQ;
 	dev->base_addr = link->io.BasePort1;
 
-	if (register_netdev(dev) != 0) {
-		printk(KERN_NOTICE "3c574_cs: register_netdev() failed\n");
-		goto failed;
-	}
-
 	ioaddr = dev->base_addr;
-	strcpy(lp->node.dev_name, dev->name);
-	link->dev = &lp->node;
-	link->state &= ~DEV_CONFIG_PENDING;
 
 	/* The 3c574 normally uses an EEPROM for configuration info, including
 	   the hardware address.  The future products may include a modem chip
@@ -467,24 +462,14 @@ static void tc574_config(dev_link_t *lin
 	} else
 		cardname = "3Com 3c574";
 
-	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, hw_addr ",
-		   dev->name, cardname, dev->base_addr, dev->irq);
-
-	for (i = 0; i < 6; i++)
-		printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : ".\n"));
-
 	{
-		u_char mcr, *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
-		union wn3_config config;
+		u_char mcr;
 		outw(2<<11, ioaddr + RunnerRdCtrl);
 		mcr = inb(ioaddr + 2);
 		outw(0<<11, ioaddr + RunnerRdCtrl);
 		printk(KERN_INFO "  ASIC rev %d,", mcr>>3);
 		EL3WINDOW(3);
 		config.i = inl(ioaddr + Wn3_Config);
-		printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
-			   8 << config.u.ram_size, ram_split[config.u.ram_split],
-			   config.u.autoselect ? "autoselect " : "");
 		lp->default_media = config.u.xcvr;
 		lp->autoselect = config.u.autoselect;
 	}
@@ -531,6 +516,25 @@ static void tc574_config(dev_link_t *lin
 		}
 	}
 
+	link->state &= ~DEV_CONFIG_PENDING;
+	link->dev = &lp->node;
+
+	if (register_netdev(dev) != 0) {
+		printk(KERN_NOTICE "3c574_cs: register_netdev() failed\n");
+		link->dev = NULL;
+		goto failed;
+	}
+
+	strcpy(lp->node.dev_name, dev->name);
+
+	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, hw_addr ",
+		   dev->name, cardname, dev->base_addr, dev->irq);
+	for (i = 0; i < 6; i++)
+		printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : ".\n"));
+	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
+		   8 << config.u.ram_size, ram_split[config.u.ram_split],
+		   config.u.autoselect ? "autoselect " : "");
+
 	return;
 
 cs_failed:
diff -urpN orig/drivers/net/pcmcia/3c589_cs.c linux/drivers/net/pcmcia/3c589_cs.c
--- orig/drivers/net/pcmcia/3c589_cs.c	Wed Feb 18 22:34:14 2004
+++ linux/drivers/net/pcmcia/3c589_cs.c	Mon Mar  8 00:09:45 2004
@@ -308,7 +308,7 @@ static void tc589_config(dev_link_t *lin
     tuple_t tuple;
     cisparse_t parse;
     u16 buf[32], *phys_addr;
-    int last_fn, last_ret, i, j, multi = 0;
+    int last_fn, last_ret, i, j, multi = 0, fifo;
     ioaddr_t ioaddr;
     char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
     
@@ -357,11 +357,6 @@ static void tc589_config(dev_link_t *lin
 	
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
-    if (register_netdev(dev) != 0) {
-	printk(KERN_ERR "3c589_cs: register_netdev() failed\n");
-	goto failed;
-    }
-    
     ioaddr = dev->base_addr;
     EL3WINDOW(0);
 
@@ -382,13 +377,10 @@ static void tc589_config(dev_link_t *lin
 	}
     }
 
-    strcpy(lp->node.dev_name, dev->name);
-    link->dev = &lp->node;
-    link->state &= ~DEV_CONFIG_PENDING;
-    
     /* The address and resource configuration register aren't loaded from
        the EEPROM and *must* be set to 0 and IRQ3 for the PCMCIA version. */
     outw(0x3f00, ioaddr + 8);
+    fifo = inl(ioaddr);
 
     /* The if_port symbol can be set when the module is loaded */
     if ((if_port >= 0) && (if_port <= 3))
@@ -396,14 +388,24 @@ static void tc589_config(dev_link_t *lin
     else
 	printk(KERN_ERR "3c589_cs: invalid if_port requested\n");
     
+    link->dev = &lp->node;
+    link->state &= ~DEV_CONFIG_PENDING;
+
+    if (register_netdev(dev) != 0) {
+	printk(KERN_ERR "3c589_cs: register_netdev() failed\n");
+	link->dev = NULL;
+	goto failed;
+    }
+    
+    strcpy(lp->node.dev_name, dev->name);
+    
     printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, hw_addr ",
 	   dev->name, (multi ? "562" : "589"), dev->base_addr,
 	   dev->irq);
     for (i = 0; i < 6; i++)
 	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
-    i = inl(ioaddr);
     printk(KERN_INFO "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
-	   (i & 7) ? 32 : 8, ram_split[(i >> 16) & 3],
+	   (fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
 	   if_names[dev->if_port]);
     return;
 
diff -urpN orig/drivers/net/pcmcia/axnet_cs.c linux/drivers/net/pcmcia/axnet_cs.c
--- orig/drivers/net/pcmcia/axnet_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/axnet_cs.c	Mon Mar  8 00:10:15 2004
@@ -430,19 +430,11 @@ static void axnet_config(dev_link_t *lin
     ei_status.block_input = &block_input;
     ei_status.block_output = &block_output;
 
-    strcpy(info->node.dev_name, dev->name);
-
     if (inb(dev->base_addr + AXNET_TEST) != 0)
 	info->flags |= IS_AX88790;
     else
 	info->flags |= IS_AX88190;
 
-    printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, hw_addr ",
-	   dev->name, ((info->flags & IS_AX88790) ? 7 : 1),
-	   dev->base_addr, dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
-
     if (info->flags & IS_AX88790)
 	outb(0x10, dev->base_addr + AXNET_GPIO);  /* select Internal PHY */
 
@@ -463,19 +455,27 @@ static void axnet_config(dev_link_t *lin
     }
 
     info->phy_id = (i < 32) ? i : -1;
-    if (i < 32) {
-	DEBUG(0, "  MII transceiver at index %d, status %x.\n", i, j);
-    } else {
-	printk(KERN_NOTICE "  No MII transceivers found!\n");
-    }
+    link->dev = &info->node;
+    link->state &= ~DEV_CONFIG_PENDING;
 
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "axnet_cs: register_netdev() failed\n");
+	link->dev = NULL;
 	goto failed;
     }
 
-    link->dev = &info->node;
-    link->state &= ~DEV_CONFIG_PENDING;
+    strcpy(info->node.dev_name, dev->name);
+
+    printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, hw_addr ",
+	   dev->name, ((info->flags & IS_AX88790) ? 7 : 1),
+	   dev->base_addr, dev->irq);
+    for (i = 0; i < 6; i++)
+	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
+    if (info->phy_id != -1) {
+	DEBUG(0, "  MII transceiver at index %d, status %x.\n", info->phy_id, j);
+    } else {
+	printk(KERN_NOTICE "  No MII transceivers found!\n");
+    }
     return;
 
 cs_failed:
diff -urpN orig/drivers/net/pcmcia/com20020_cs.c linux/drivers/net/pcmcia/com20020_cs.c
--- orig/drivers/net/pcmcia/com20020_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/com20020_cs.c	Mon Mar  8 00:19:18 2004
@@ -141,7 +141,6 @@ static dev_link_t *dev_list;
 
 typedef struct com20020_dev_t {
     struct net_device       *dev;
-    int dev_configured;
     dev_node_t          node;
 } com20020_dev_t;
 
@@ -277,13 +276,10 @@ static void com20020_detach(dev_link_t *
 	dev = info->dev;
 	if (dev)
 	{
-	    if (info->dev_configured)
+	    if (link->dev)
 	    {
 		DEBUG(1,"unregister...\n");
 
-		if (netif_running(dev))
-		    dev->stop(dev);
-
 		unregister_netdev(dev);
 	    
 		/*
@@ -398,17 +394,18 @@ static void com20020_config(dev_link_t *
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
+    link->dev = &info->node;
+    link->state &= ~DEV_CONFIG_PENDING;
+
     i = com20020_found(dev, 0);	/* calls register_netdev */
     
     if (i != 0) {
 	DEBUG(1,KERN_NOTICE "com20020_cs: com20020_found() failed\n");
+	link->dev = NULL;
 	goto failed;
     }
 
-    info->dev_configured = 1;
     strcpy(info->node.dev_name, dev->name);
-    link->dev = &info->node;
-    link->state &= ~DEV_CONFIG_PENDING;
 
     DEBUG(1,KERN_INFO "%s: port %#3lx, irq %d\n",
            dev->name, dev->base_addr, dev->irq);
diff -urpN orig/drivers/net/pcmcia/fmvj18x_cs.c linux/drivers/net/pcmcia/fmvj18x_cs.c
--- orig/drivers/net/pcmcia/fmvj18x_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/fmvj18x_cs.c	Mon Mar  8 00:13:01 2004
@@ -510,10 +510,6 @@ static void fmvj18x_config(dev_link_t *l
     CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link->handle, &link->conf));
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
-    if (register_netdev(dev) != 0) {
-	printk(KERN_NOTICE "fmvj18x_cs: register_netdev() failed\n");
-	goto failed;
-    }
 
     if (link->io.BasePort2 != 0)
 	fmvj18x_setup_mfc(link);
@@ -575,7 +571,6 @@ static void fmvj18x_config(dev_link_t *l
 	/* Read MACID from Buggy CIS */
 	if (fmvj18x_get_hwinfo(link, tuple.TupleData) == -1) {
 	    printk(KERN_NOTICE "fmvj18x_cs: unable to read hardware net address.\n");
-	    unregister_netdev(dev);
 	    goto failed;
 	}
 	for (i = 0 ; i < 6; i++) {
@@ -592,10 +587,18 @@ static void fmvj18x_config(dev_link_t *l
 	break;
     }
 
-    strcpy(lp->node.dev_name, dev->name);
+    lp->cardtype = cardtype;
     link->dev = &lp->node;
+    link->state &= ~DEV_CONFIG_PENDING;
+
+    if (register_netdev(dev) != 0) {
+	printk(KERN_NOTICE "fmvj18x_cs: register_netdev() failed\n");
+	link->dev = NULL;
+	goto failed;
+    }
+
+    strcpy(lp->node.dev_name, dev->name);
 
-    lp->cardtype = cardtype;
     /* print current configuration */
     printk(KERN_INFO "%s: %s, sram %s, port %#3lx, irq %d, hw_addr ", 
 	   dev->name, card_name, sram_config == 0 ? "4K TX*2" : "8K TX*2", 
@@ -603,7 +606,6 @@ static void fmvj18x_config(dev_link_t *l
     for (i = 0; i < 6; i++)
 	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
 
-    link->state &= ~DEV_CONFIG_PENDING;
     return;
     
 cs_failed:
diff -urpN orig/drivers/net/pcmcia/ibmtr_cs.c linux/drivers/net/pcmcia/ibmtr_cs.c
--- orig/drivers/net/pcmcia/ibmtr_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/ibmtr_cs.c	Mon Mar  8 00:24:13 2004
@@ -317,13 +317,10 @@ static void ibmtr_config(dev_link_t *lin
     /* Try PRIMARY card at 0xA20-0xA23 */
     link->io.BasePort1 = 0xA20;
     i = pcmcia_request_io(link->handle, &link->io);
-    if (i == CS_SUCCESS) {
-	memcpy(info->node.dev_name, "tr0\0", 4);
-    } else {
+    if (i != CS_SUCCESS) {
 	/* Couldn't get 0xA20-0xA23.  Try ALTERNATE at 0xA24-0xA27. */
 	link->io.BasePort1 = 0xA24;
 	CS_CHECK(RequestIO, pcmcia_request_io(link->handle, &link->io));
-	memcpy(info->node.dev_name, "tr1\0", 4);
     }
     dev->base_addr = link->io.BasePort1;
 
@@ -367,15 +364,17 @@ static void ibmtr_config(dev_link_t *lin
         Adapters Technical Reference"  SC30-3585 for this info.  */
     ibmtr_hw_setup(dev, mmiobase);
 
+    link->dev = &info->node;
+    link->state &= ~DEV_CONFIG_PENDING;
+
     i = ibmtr_probe_card(dev);
-    
     if (i != 0) {
 	printk(KERN_NOTICE "ibmtr_cs: register_netdev() failed\n");
+	link->dev = NULL;
 	goto failed;
     }
 
-    link->dev = &info->node;
-    link->state &= ~DEV_CONFIG_PENDING;
+    strcpy(info->node.dev_name, dev->name);
 
     printk(KERN_INFO "%s: port %#3lx, irq %d,",
            dev->name, dev->base_addr, dev->irq);
diff -urpN orig/drivers/net/pcmcia/nmclan_cs.c linux/drivers/net/pcmcia/nmclan_cs.c
--- orig/drivers/net/pcmcia/nmclan_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/nmclan_cs.c	Mon Mar  8 00:13:42 2004
@@ -734,11 +734,6 @@ static void nmclan_config(dev_link_t *li
   CS_CHECK(RequestConfiguration, pcmcia_request_configuration(handle, &link->conf));
   dev->irq = link->irq.AssignedIRQ;
   dev->base_addr = link->io.BasePort1;
-  i = register_netdev(dev);
-  if (i != 0) {
-    printk(KERN_NOTICE "nmclan_cs: register_netdev() failed\n");
-    goto failed;
-  }
 
   ioaddr = dev->base_addr;
 
@@ -777,10 +772,18 @@ static void nmclan_config(dev_link_t *li
   else
     printk(KERN_NOTICE "nmclan_cs: invalid if_port requested\n");
 
-  strcpy(lp->node.dev_name, dev->name);
   link->dev = &lp->node;
   link->state &= ~DEV_CONFIG_PENDING;
 
+  i = register_netdev(dev);
+  if (i != 0) {
+    printk(KERN_NOTICE "nmclan_cs: register_netdev() failed\n");
+    link->dev = NULL;
+    goto failed;
+  }
+
+  strcpy(lp->node.dev_name, dev->name);
+
   printk(KERN_INFO "%s: nmclan: port %#3lx, irq %d, %s port, hw_addr ",
 	 dev->name, dev->base_addr, dev->irq, if_names[dev->if_port]);
   for (i = 0; i < 6; i++)
diff -urpN orig/drivers/net/pcmcia/smc91c92_cs.c linux/drivers/net/pcmcia/smc91c92_cs.c
--- orig/drivers/net/pcmcia/smc91c92_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/smc91c92_cs.c	Mon Mar  8 00:14:06 2004
@@ -901,6 +901,7 @@ static void smc91c92_config(dev_link_t *
     char *name;
     int i, j, rev;
     ioaddr_t ioaddr;
+    u_long mir;
 
     DEBUG(0, "smc91c92_config(0x%p)\n", link);
 
@@ -952,11 +953,6 @@ static void smc91c92_config(dev_link_t *
     else
 	printk(KERN_NOTICE "smc91c92_cs: invalid if_port requested\n");
 
-    if (register_netdev(dev) != 0) {
-	printk(KERN_ERR "smc91c92_cs: register_netdev() failed\n");
-	goto config_undo;
-    }
-
     switch (smc->manfid) {
     case MANFID_OSITECH:
     case MANFID_PSION:
@@ -977,8 +973,6 @@ static void smc91c92_config(dev_link_t *
 	goto config_undo;
     }
 
-    strcpy(smc->node.dev_name, dev->name);
-    link->dev = &smc->node;
     smc->duplex = 0;
     smc->rx_ovrn = 0;
 
@@ -993,25 +987,16 @@ static void smc91c92_config(dev_link_t *
 	case 8: name = "100-FD"; break;
 	case 9: name = "110"; break;
 	}
-    printk(KERN_INFO "%s: smc91c%s rev %d: io %#3lx, irq %d, "
-	   "hw_addr ", dev->name, name, (rev & 0x0f), dev->base_addr,
-	   dev->irq);
-    for (i = 0; i < 6; i++)
-	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
 
     ioaddr = dev->base_addr;
     if (rev > 0) {
-	u_long mir, mcr;
+	u_long mcr;
 	SMC_SELECT_BANK(0);
 	mir = inw(ioaddr + MEMINFO) & 0xff;
 	if (mir == 0xff) mir++;
 	/* Get scale factor for memory size */
 	mcr = ((rev >> 4) > 3) ? inw(ioaddr + MEMCFG) : 0x0200;
 	mir *= 128 * (1<<((mcr >> 9) & 7));
-	if (mir & 0x3ff)
-	    printk(KERN_INFO "  %lu byte", mir);
-	else
-	    printk(KERN_INFO "  %lu kb", mir>>10);
 	SMC_SELECT_BANK(1);
 	smc->cfg = inw(ioaddr + CONFIG) & ~CFG_AUI_SELECT;
 	smc->cfg |= CFG_NO_WAIT | CFG_16BIT | CFG_STATIC;
@@ -1019,9 +1004,8 @@ static void smc91c92_config(dev_link_t *
 	    smc->cfg |= CFG_IRQ_SEL_1 | CFG_IRQ_SEL_0;
 	if ((rev >> 4) >= 7)
 	    smc->cfg |= CFG_MII_SELECT;
-	printk(" buffer, %s xcvr\n", (smc->cfg & CFG_MII_SELECT) ?
-	       "MII" : if_names[dev->if_port]);
-    }
+    } else
+	mir = 0;
 
     if (smc->cfg & CFG_MII_SELECT) {
 	SMC_SELECT_BANK(3);
@@ -1031,16 +1015,45 @@ static void smc91c92_config(dev_link_t *
 	    if ((j != 0) && (j != 0xffff)) break;
 	}
 	smc->mii_if.phy_id = (i < 32) ? i : -1;
-	if (i < 32) {
-	    DEBUG(0, "  MII transceiver at index %d, status %x.\n", i, j);
-	} else {
-    	    printk(KERN_NOTICE "  No MII transceivers found!\n");
-	}
 
 	SMC_SELECT_BANK(0);
     }
 
+    link->dev = &smc->node;
     link->state &= ~DEV_CONFIG_PENDING;
+
+    if (register_netdev(dev) != 0) {
+	printk(KERN_ERR "smc91c92_cs: register_netdev() failed\n");
+	link->dev = NULL;
+	goto config_undo;
+    }
+
+    strcpy(smc->node.dev_name, dev->name);
+
+    printk(KERN_INFO "%s: smc91c%s rev %d: io %#3lx, irq %d, "
+	   "hw_addr ", dev->name, name, (rev & 0x0f), dev->base_addr,
+	   dev->irq);
+    for (i = 0; i < 6; i++)
+	printk("%02X%s", dev->dev_addr[i], ((i<5) ? ":" : "\n"));
+
+    if (rev > 0) {
+	if (mir & 0x3ff)
+	    printk(KERN_INFO "  %lu byte", mir);
+	else
+	    printk(KERN_INFO "  %lu kb", mir>>10);
+	printk(" buffer, %s xcvr\n", (smc->cfg & CFG_MII_SELECT) ?
+	       "MII" : if_names[dev->if_port]);
+    }
+
+    if (smc->cfg & CFG_MII_SELECT) {
+	if (smc->mii_if.phy_id != -1) {
+	    DEBUG(0, "  MII transceiver at index %d, status %x.\n",
+		  smc->mii_if.phy_id, j);
+	} else {
+    	    printk(KERN_NOTICE "  No MII transceivers found!\n");
+	}
+    }
+
     return;
 
 config_undo:
diff -urpN orig/drivers/net/pcmcia/xirc2ps_cs.c linux/drivers/net/pcmcia/xirc2ps_cs.c
--- orig/drivers/net/pcmcia/xirc2ps_cs.c	Wed Feb 18 22:34:15 2004
+++ linux/drivers/net/pcmcia/xirc2ps_cs.c	Mon Mar  8 00:14:21 2004
@@ -1114,17 +1114,20 @@ xirc2ps_config(dev_link_t * link)
     /* we can now register the device with the net subsystem */
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
+
+    if (local->dingo)
+	do_reset(dev, 1); /* a kludge to make the cem56 work */
+
+    link->dev = &local->node;
+    link->state &= ~DEV_CONFIG_PENDING;
+
     if ((err=register_netdev(dev))) {
 	printk(KNOT_XIRC "register_netdev() failed\n");
+	link->dev = NULL;
 	goto config_error;
     }
 
     strcpy(local->node.dev_name, dev->name);
-    link->dev = &local->node;
-    link->state &= ~DEV_CONFIG_PENDING;
-
-    if (local->dingo)
-	do_reset(dev, 1); /* a kludge to make the cem56 work */
 
     /* give some infos about the hardware */
     printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr",

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
