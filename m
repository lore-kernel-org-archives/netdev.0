From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Port LMC driver to generic HDLC
Date: Wed, 02 Jul 2008 21:21:55 +0200
Message-ID: <m3iqvo3xd8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46678 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbYGBTXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

WAN: Port LMC driver to generic HDLC
    
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 9624d0f..34a9782 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -61,7 +61,7 @@ config COSA
 #
 config LANMEDIA
 	tristate "LanMedia Corp. SSI/V.35, T1/E1, HSSI, T3 boards"
-	depends on PCI && VIRT_TO_BUS
+	depends on PCI && VIRT_TO_BUS && HDLC
 	---help---
 	  Driver for the following Lan Media family of serial boards:
 
@@ -78,9 +78,8 @@ config LANMEDIA
 	  - LMC 5245 board connects directly to a T3 circuit saving the
 	  additional external hardware.
 
-	  To change setting such as syncPPP vs Cisco HDLC or clock source you
-	  will need lmcctl.  It is available at <ftp://ftp.lanmedia.com/>
-	  (broken link).
+	  To change setting such as clock source you will need lmcctl.
+	  It is available at <ftp://ftp.lanmedia.com/> (broken link).
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called lmc.
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index 5d27a17..1025496 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -26,7 +26,6 @@ obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	sealevel.o
 obj-$(CONFIG_COSA)		+= cosa.o
 obj-$(CONFIG_FARSYNC)		+= farsync.o
 obj-$(CONFIG_DSCC4)             += dscc4.o
-obj-$(CONFIG_LANMEDIA)		+=		syncppp.o
 obj-$(CONFIG_X25_ASY)		+= x25_asy.o
 
 obj-$(CONFIG_LANMEDIA)		+= lmc/
diff --git a/drivers/net/wan/lmc/lmc_ioctl.h b/drivers/net/wan/lmc/lmc_ioctl.h
index 57dd861..72fb113 100644
--- a/drivers/net/wan/lmc/lmc_ioctl.h
+++ b/drivers/net/wan/lmc/lmc_ioctl.h
@@ -61,7 +61,7 @@
 /*
  * IFTYPE defines
  */
-#define LMC_PPP         1               /* use sppp interface */
+#define LMC_PPP         1               /* use generic HDLC interface */
 #define LMC_NET         2               /* use direct net interface */
 #define LMC_RAW         3               /* use direct net interface */
 
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 62133ce..f64f4ca 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1,6 +1,7 @@
  /*
   * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
   * All rights reserved.  www.lanmedia.com
+  * Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
   *
   * This code is written by:
   * Andrew Stanley-Jones (asj@cban.com)
@@ -36,8 +37,6 @@
   *
   */
 
-/* $Id: lmc_main.c,v 1.36 2000/04/11 05:25:25 asj Exp $ */
-
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/string.h>
@@ -49,6 +48,7 @@
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/init.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
@@ -57,9 +57,6 @@
 #include <linux/skbuff.h>
 #include <linux/inet.h>
 #include <linux/bitops.h>
-
-#include <net/syncppp.h>
-
 #include <asm/processor.h>             /* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -78,8 +75,6 @@
 #include "lmc_debug.h"
 #include "lmc_proto.h"
 
-static int lmc_first_load = 0;
-
 static int LMC_PKT_BUF_SZ = 1542;
 
 static struct pci_device_id lmc_pci_tbl[] = {
@@ -91,11 +86,10 @@ static struct pci_device_id lmc_pci_tbl[] = {
 };
 
 MODULE_DEVICE_TABLE(pci, lmc_pci_tbl);
-MODULE_LICENSE("GPL");
+MODULE_LICENSE("GPL v2");
 
 
 static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lmc_rx (struct net_device *dev);
 static int lmc_open(struct net_device *dev);
 static int lmc_close(struct net_device *dev);
@@ -114,20 +108,14 @@ static void lmc_driver_timeout(struct net_device *dev);
  * linux reserves 16 device specific IOCTLs.  We call them
  * LMCIOC* to control various bits of our world.
  */
-int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
+int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     lmc_ctl_t ctl;
-    int ret;
-    u_int16_t regVal;
+    int ret = -EOPNOTSUPP;
+    u16 regVal;
     unsigned long flags;
 
-    struct sppp *sp;
-
-    ret = -EOPNOTSUPP;
-
-    sc = dev->priv;
-
     lmc_trace(dev, "lmc_ioctl in");
 
     /*
@@ -149,7 +137,6 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         break;
 
     case LMCIOCSINFO: /*fold01*/
-        sp = &((struct ppp_device *) dev)->sppp;
         if (!capable(CAP_NET_ADMIN)) {
             ret = -EPERM;
             break;
@@ -175,25 +162,20 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		sc->TxDescriptControlInit &= ~LMC_TDES_ADD_CRC_DISABLE;
         }
 
-        if (ctl.keepalive_onoff == LMC_CTL_OFF)
-            sp->pp_flags &= ~PP_KEEPALIVE;	/* Turn off */
-        else
-            sp->pp_flags |= PP_KEEPALIVE;	/* Turn on */
-
         ret = 0;
         break;
 
     case LMCIOCIFTYPE: /*fold01*/
         {
-            u_int16_t	old_type = sc->if_type;
-            u_int16_t	new_type;
+	    u16 old_type = sc->if_type;
+	    u16	new_type;
 
 	    if (!capable(CAP_NET_ADMIN)) {
 		ret = -EPERM;
 		break;
 	    }
 
-	    if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u_int16_t))) {
+	    if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u16))) {
 		ret = -EFAULT;
 		break;
 	    }
@@ -206,15 +188,11 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
             }
             
             lmc_proto_close(sc);
-            lmc_proto_detach(sc);
 
             sc->if_type = new_type;
-//            lmc_proto_init(sc);
             lmc_proto_attach(sc);
-            lmc_proto_open(sc);
-
-	    ret = 0 ;
-	    break ;
+	    ret = lmc_proto_open(sc);
+	    break;
 	}
 
     case LMCIOCGETXINFO: /*fold01*/
@@ -241,51 +219,53 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
         break;
 
-    case LMCIOCGETLMCSTATS: /*fold01*/
-        if (sc->lmc_cardtype == LMC_CARDTYPE_T1){
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_FERR_LSB);
-            sc->stats.framingBitErrorCount +=
-                lmc_mii_readreg (sc, 0, 18) & 0xff;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_FERR_MSB);
-            sc->stats.framingBitErrorCount +=
-                (lmc_mii_readreg (sc, 0, 18) & 0xff) << 8;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_LCV_LSB);
-            sc->stats.lineCodeViolationCount +=
-                lmc_mii_readreg (sc, 0, 18) & 0xff;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_LCV_MSB);
-            sc->stats.lineCodeViolationCount +=
-                (lmc_mii_readreg (sc, 0, 18) & 0xff) << 8;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_AERR);
-            regVal = lmc_mii_readreg (sc, 0, 18) & 0xff;
-
-            sc->stats.lossOfFrameCount +=
-                (regVal & T1FRAMER_LOF_MASK) >> 4;
-            sc->stats.changeOfFrameAlignmentCount +=
-                (regVal & T1FRAMER_COFA_MASK) >> 2;
-            sc->stats.severelyErroredFrameCount +=
-                regVal & T1FRAMER_SEF_MASK;
-        }
-
-        if (copy_to_user(ifr->ifr_data, &sc->stats,
-                         sizeof (struct lmc_statistics)))
-		ret = -EFAULT;
-	else
-		ret = 0;
-        break;
+    case LMCIOCGETLMCSTATS:
+	    if (sc->lmc_cardtype == LMC_CARDTYPE_T1) {
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
+		    sc->extra_stats.framingBitErrorCount +=
+			    lmc_mii_readreg(sc, 0, 18) & 0xff;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_MSB);
+		    sc->extra_stats.framingBitErrorCount +=
+			    (lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_LSB);
+		    sc->extra_stats.lineCodeViolationCount +=
+			    lmc_mii_readreg(sc, 0, 18) & 0xff;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_MSB);
+		    sc->extra_stats.lineCodeViolationCount +=
+			    (lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_AERR);
+		    regVal = lmc_mii_readreg(sc, 0, 18) & 0xff;
+
+		    sc->extra_stats.lossOfFrameCount +=
+			    (regVal & T1FRAMER_LOF_MASK) >> 4;
+		    sc->extra_stats.changeOfFrameAlignmentCount +=
+			    (regVal & T1FRAMER_COFA_MASK) >> 2;
+		    sc->extra_stats.severelyErroredFrameCount +=
+			    regVal & T1FRAMER_SEF_MASK;
+	    }
+	    if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
+			     sizeof(sc->lmc_device->stats)) ||
+		copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
+			     &sc->extra_stats, sizeof(sc->extra_stats)))
+		    ret = -EFAULT;
+	    else
+		    ret = 0;
+	    break;
 
-    case LMCIOCCLEARLMCSTATS: /*fold01*/
-        if (!capable(CAP_NET_ADMIN)){
-            ret = -EPERM;
-            break;
-        }
+    case LMCIOCCLEARLMCSTATS:
+	    if (!capable(CAP_NET_ADMIN)) {
+		    ret = -EPERM;
+		    break;
+	    }
 
-        memset (&sc->stats, 0, sizeof (struct lmc_statistics));
-        sc->stats.check = STATCHECK;
-        sc->stats.version_size = (DRIVER_VERSION << 16) +
-            sizeof (struct lmc_statistics);
-        sc->stats.lmc_cardtype = sc->lmc_cardtype;
-        ret = 0;
-        break;
+	    memset(&sc->lmc_device->stats, 0, sizeof(sc->lmc_device->stats));
+	    memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
+	    sc->extra_stats.check = STATCHECK;
+	    sc->extra_stats.version_size = (DRIVER_VERSION << 16) +
+		    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
+	    sc->extra_stats.lmc_cardtype = sc->lmc_cardtype;
+	    ret = 0;
+	    break;
 
     case LMCIOCSETCIRCUIT: /*fold01*/
         if (!capable(CAP_NET_ADMIN)){
@@ -641,14 +621,12 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 /* the watchdog process that cruises around */
 static void lmc_watchdog (unsigned long data) /*fold00*/
 {
-    struct net_device *dev = (struct net_device *) data;
-    lmc_softc_t *sc;
+    struct net_device *dev = (struct net_device *)data;
+    lmc_softc_t *sc = dev_to_sc(dev);
     int link_status;
     u_int32_t ticks;
     unsigned long flags;
 
-    sc = dev->priv;
-
     lmc_trace(dev, "lmc_watchdog in");
 
     spin_lock_irqsave(&sc->lmc_lock, flags);
@@ -677,22 +655,22 @@ static void lmc_watchdog (unsigned long data) /*fold00*/
      * check for a transmit interrupt timeout
      * Has the packet xmt vs xmt serviced threshold been exceeded */
     if (sc->lmc_taint_tx == sc->lastlmc_taint_tx &&
-        sc->stats.tx_packets > sc->lasttx_packets &&
-        sc->tx_TimeoutInd == 0)
+	sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	sc->tx_TimeoutInd == 0)
     {
 
         /* wait for the watchdog to come around again */
         sc->tx_TimeoutInd = 1;
     }
     else if (sc->lmc_taint_tx == sc->lastlmc_taint_tx &&
-             sc->stats.tx_packets > sc->lasttx_packets &&
-             sc->tx_TimeoutInd)
+	     sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	     sc->tx_TimeoutInd)
     {
 
         LMC_EVENT_LOG(LMC_EVENT_XMTINTTMO, LMC_CSR_READ (sc, csr_status), 0);
 
         sc->tx_TimeoutDisplay = 1;
-        sc->stats.tx_TimeoutCnt++;
+	sc->extra_stats.tx_TimeoutCnt++;
 
         /* DEC chip is stuck, hit it with a RESET!!!! */
         lmc_running_reset (dev);
@@ -712,13 +690,11 @@ static void lmc_watchdog (unsigned long data) /*fold00*/
         /* reset the transmit timeout detection flag */
         sc->tx_TimeoutInd = 0;
         sc->lastlmc_taint_tx = sc->lmc_taint_tx;
-        sc->lasttx_packets = sc->stats.tx_packets;
-    }
-    else
-    {
+	sc->lasttx_packets = sc->lmc_device->stats.tx_packets;
+    } else {
         sc->tx_TimeoutInd = 0;
         sc->lastlmc_taint_tx = sc->lmc_taint_tx;
-        sc->lasttx_packets = sc->stats.tx_packets;
+	sc->lasttx_packets = sc->lmc_device->stats.tx_packets;
     }
 
     /* --- end time out check ----------------------------------- */
@@ -748,19 +724,7 @@ static void lmc_watchdog (unsigned long data) /*fold00*/
          sc->last_link_status = 1;
          /* lmc_reset (sc); Again why reset??? */
 
-         /* Inform the world that link protocol is back up. */
 	 netif_carrier_on(dev);
-
-         /* Now we have to tell the syncppp that we had an outage
-          * and that it should deal.  Calling sppp_reopen here
-          * should do the trick, but we may have to call sppp_close
-          * when the link goes down, and call sppp_open here.
-          * Subject to more testing.
-          * --bbraun
-          */
-
-         lmc_proto_reopen(sc);
-
      }
 
     /* Call media specific watchdog functions */
@@ -816,114 +780,93 @@ kick_timer:
 
 }
 
-static void lmc_setup(struct net_device * const dev) /*fold00*/
+static int lmc_attach(struct net_device *dev, unsigned short encoding,
+		      unsigned short parity)
 {
-    lmc_trace(dev, "lmc_setup in");
-
-    dev->type = ARPHRD_HDLC;
-    dev->hard_start_xmit = lmc_start_xmit;
-    dev->open = lmc_open;
-    dev->stop = lmc_close;
-    dev->get_stats = lmc_get_stats;
-    dev->do_ioctl = lmc_ioctl;
-    dev->tx_timeout = lmc_driver_timeout;
-    dev->watchdog_timeo = (HZ); /* 1 second */
-    
-    lmc_trace(dev, "lmc_setup out");
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
-
 static int __devinit lmc_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
-    struct net_device *dev;
-    lmc_softc_t *sc;
-    u16 subdevice;
-    u_int16_t AdapModelNum;
-    int err = -ENOMEM;
-    static int cards_found;
-#ifndef GCOM
-    /* We name by type not by vendor */
-    static const char lmcname[] = "hdlc%d";
-#else
-    /* 
-     * GCOM uses LMC vendor name so that clients can know which card
-     * to attach to.
-     */
-    static const char lmcname[] = "lmc%d";
-#endif
-
-
-    /*
-     * Allocate our own device structure
-     */
-    dev = alloc_netdev(sizeof(lmc_softc_t), lmcname, lmc_setup);
-    if (!dev) {
-        printk (KERN_ERR "lmc:alloc_netdev for device failed\n");
-	goto out1;
-    }
- 
-    lmc_trace(dev, "lmc_init_one in");
-
-    err = pci_enable_device(pdev);
-    if (err) {
-	    printk(KERN_ERR "lmc: pci enable failed:%d\n", err);
-	    goto out2;
-    }
-    
-    if (pci_request_regions(pdev, "lmc")) {
-	    printk(KERN_ERR "lmc: pci_request_region failed\n");
-	    err = -EIO;
-	    goto out3;
-    }
-
-    pci_set_drvdata(pdev, dev);
-
-    if(lmc_first_load == 0){
-        printk(KERN_INFO "Lan Media Corporation WAN Driver Version %d.%d.%d\n",
-	       DRIVER_MAJOR_VERSION, DRIVER_MINOR_VERSION,DRIVER_SUB_VERSION);
-        lmc_first_load = 1;
-    }
-    
-    sc = dev->priv;
-    sc->lmc_device = dev;
-    sc->name = dev->name;
-
-    /* Initialize the sppp layer */
-    /* An ioctl can cause a subsequent detach for raw frame interface */
-    dev->ml_priv = sc;
-    sc->if_type = LMC_PPP;
-    sc->check = 0xBEAFCAFE;
-    dev->base_addr = pci_resource_start(pdev, 0);
-    dev->irq = pdev->irq;
-
-    SET_NETDEV_DEV(dev, &pdev->dev);
-
-    /*
-     * This will get the protocol layer ready and do any 1 time init's
-     * Must have a valid sc and dev structure
-     */
-    lmc_proto_init(sc);
-
-    lmc_proto_attach(sc);
+	lmc_softc_t *sc;
+	struct net_device *dev;
+	u16 subdevice;
+	u16 AdapModelNum;
+	int err;
+	static int cards_found;
+
+	/* lmc_trace(dev, "lmc_init_one in"); */
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "lmc: pci enable failed: %d\n", err);
+		return err;
+	}
 
-    /*
-     * Why were we changing this???
-     dev->tx_queue_len = 100;
-     */
+	err = pci_request_regions(pdev, "lmc");
+	if (err) {
+		printk(KERN_ERR "lmc: pci_request_region failed\n");
+		goto err_req_io;
+	}
 
-    /* Init the spin lock so can call it latter */
+	/*
+	 * Allocate our own device structure
+	 */
+	sc = kzalloc(sizeof(lmc_softc_t), GFP_KERNEL);
+	if (!sc) {
+		err = -ENOMEM;
+		goto err_kzalloc;
+	}
 
-    spin_lock_init(&sc->lmc_lock);
-    pci_set_master(pdev);
+	dev = alloc_hdlcdev(sc);
+	if (!dev) {
+		printk(KERN_ERR "lmc:alloc_netdev for device failed\n");
+		goto err_hdlcdev;
+	}
 
-    printk ("%s: detected at %lx, irq %d\n", dev->name,
-	    dev->base_addr, dev->irq);
 
-    if (register_netdev (dev) != 0) {
-        printk (KERN_ERR "%s: register_netdev failed.\n", dev->name);
-	goto out4;
-    }
+	dev->type = ARPHRD_HDLC;
+	dev_to_hdlc(dev)->xmit = lmc_start_xmit;
+	dev_to_hdlc(dev)->attach = lmc_attach;
+	dev->open = lmc_open;
+	dev->stop = lmc_close;
+	dev->get_stats = lmc_get_stats;
+	dev->do_ioctl = lmc_ioctl;
+	dev->tx_timeout = lmc_driver_timeout;
+	dev->watchdog_timeo = HZ; /* 1 second */
+	dev->tx_queue_len = 100;
+	sc->lmc_device = dev;
+	sc->name = dev->name;
+	sc->if_type = LMC_PPP;
+	sc->check = 0xBEAFCAFE;
+	dev->base_addr = pci_resource_start(pdev, 0);
+	dev->irq = pdev->irq;
+	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	/*
+	 * This will get the protocol layer ready and do any 1 time init's
+	 * Must have a valid sc and dev structure
+	 */
+	lmc_proto_attach(sc);
+
+	/* Init the spin lock so can call it latter */
+
+	spin_lock_init(&sc->lmc_lock);
+	pci_set_master(pdev);
+
+	printk(KERN_INFO "%s: detected at %lx, irq %d\n", dev->name,
+	       dev->base_addr, dev->irq);
+
+	err = register_hdlc_device(dev);
+	if (err) {
+		printk(KERN_ERR "%s: register_netdev failed.\n", dev->name);
+		free_netdev(dev);
+		goto err_hdlcdev;
+	}
 
     sc->lmc_cardtype = LMC_CARDTYPE_UNKNOWN;
     sc->lmc_timing = LMC_CTL_CLOCK_SOURCE_EXT;
@@ -939,27 +882,27 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
 
     switch (subdevice) {
     case PCI_DEVICE_ID_LMC_HSSI:
-        printk ("%s: LMC HSSI\n", dev->name);
+	printk(KERN_INFO "%s: LMC HSSI\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_HSSI;
         sc->lmc_media = &lmc_hssi_media;
         break;
     case PCI_DEVICE_ID_LMC_DS3:
-        printk ("%s: LMC DS3\n", dev->name);
+	printk(KERN_INFO "%s: LMC DS3\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_DS3;
         sc->lmc_media = &lmc_ds3_media;
         break;
     case PCI_DEVICE_ID_LMC_SSI:
-        printk ("%s: LMC SSI\n", dev->name);
+	printk(KERN_INFO "%s: LMC SSI\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_SSI;
         sc->lmc_media = &lmc_ssi_media;
         break;
     case PCI_DEVICE_ID_LMC_T1:
-        printk ("%s: LMC T1\n", dev->name);
+	printk(KERN_INFO "%s: LMC T1\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_T1;
         sc->lmc_media = &lmc_t1_media;
         break;
     default:
-        printk (KERN_WARNING "%s: LMC UNKOWN CARD!\n", dev->name);
+	printk(KERN_WARNING "%s: LMC UNKOWN CARD!\n", dev->name);
         break;
     }
 
@@ -977,32 +920,28 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
      */
     AdapModelNum = (lmc_mii_readreg (sc, 0, 3) & 0x3f0) >> 4;
 
-    if ((AdapModelNum == LMC_ADAP_T1
-         && subdevice == PCI_DEVICE_ID_LMC_T1) ||	/* detect LMC1200 */
-        (AdapModelNum == LMC_ADAP_SSI
-         && subdevice == PCI_DEVICE_ID_LMC_SSI) ||	/* detect LMC1000 */
-        (AdapModelNum == LMC_ADAP_DS3
-         && subdevice == PCI_DEVICE_ID_LMC_DS3) ||	/* detect LMC5245 */
-        (AdapModelNum == LMC_ADAP_HSSI
-         && subdevice == PCI_DEVICE_ID_LMC_HSSI))
-    {				/* detect LMC5200 */
+    if ((AdapModelNum != LMC_ADAP_T1 || /* detect LMC1200 */
+	 subdevice != PCI_DEVICE_ID_LMC_T1) &&
+	(AdapModelNum != LMC_ADAP_SSI || /* detect LMC1000 */
+	 subdevice != PCI_DEVICE_ID_LMC_SSI) &&
+	(AdapModelNum != LMC_ADAP_DS3 || /* detect LMC5245 */
+	 subdevice != PCI_DEVICE_ID_LMC_DS3) &&
+	(AdapModelNum != LMC_ADAP_HSSI || /* detect LMC5200 */
+	 subdevice != PCI_DEVICE_ID_LMC_HSSI))
+	    printk(KERN_WARNING "%s: Model number (%d) miscompare for PCI"
+		   " Subsystem ID = 0x%04x\n",
+		   dev->name, AdapModelNum, subdevice);
 
-    }
-    else {
-        printk ("%s: Model number (%d) miscompare for PCI Subsystem ID = 0x%04x\n",
-                dev->name, AdapModelNum, subdevice);
-//        return (NULL);
-    }
     /*
      * reset clock
      */
     LMC_CSR_WRITE (sc, csr_gp_timer, 0xFFFFFFFFUL);
 
     sc->board_idx = cards_found++;
-    sc->stats.check = STATCHECK;
-    sc->stats.version_size = (DRIVER_VERSION << 16) +
-        sizeof (struct lmc_statistics);
-    sc->stats.lmc_cardtype = sc->lmc_cardtype;
+    sc->extra_stats.check = STATCHECK;
+    sc->extra_stats.version_size = (DRIVER_VERSION << 16) +
+	    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
+    sc->extra_stats.lmc_cardtype = sc->lmc_cardtype;
 
     sc->lmc_ok = 0;
     sc->last_link_status = 0;
@@ -1010,58 +949,51 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
     lmc_trace(dev, "lmc_init_one out");
     return 0;
 
- out4:
-    lmc_proto_detach(sc);
- out3:
-    if (pdev) {
-	    pci_release_regions(pdev);
-	    pci_set_drvdata(pdev, NULL);
-    }
- out2:
-    free_netdev(dev);
- out1:
-    return err;
+err_hdlcdev:
+	pci_set_drvdata(pdev, NULL);
+	kfree(sc);
+err_kzalloc:
+	pci_release_regions(pdev);
+err_req_io:
+	pci_disable_device(pdev);
+	return err;
 }
 
 /*
  * Called from pci when removing module.
  */
-static void __devexit lmc_remove_one (struct pci_dev *pdev)
+static void __devexit lmc_remove_one(struct pci_dev *pdev)
 {
-    struct net_device *dev = pci_get_drvdata(pdev);
-    
-    if (dev) {
-	    lmc_softc_t *sc = dev->priv;
-	    
-	    printk("%s: removing...\n", dev->name);
-	    lmc_proto_detach(sc);
-	    unregister_netdev(dev);
-	    free_netdev(dev);
-	    pci_release_regions(pdev);
-	    pci_disable_device(pdev);
-	    pci_set_drvdata(pdev, NULL);
-    }
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (dev) {
+		printk(KERN_DEBUG "%s: removing...\n", dev->name);
+		unregister_hdlc_device(dev);
+		free_netdev(dev);
+		pci_release_regions(pdev);
+		pci_disable_device(pdev);
+		pci_set_drvdata(pdev, NULL);
+	}
 }
 
 /* After this is called, packets can be sent.
  * Does not initialize the addresses
  */
-static int lmc_open (struct net_device *dev) /*fold00*/
+static int lmc_open(struct net_device *dev)
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
+    int err;
 
     lmc_trace(dev, "lmc_open in");
 
     lmc_led_on(sc, LMC_DS3_LED0);
 
-    lmc_dec_reset (sc);
-    lmc_reset (sc);
-
-    LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ (sc, csr_status), 0);
-    LMC_EVENT_LOG(LMC_EVENT_RESET2,
-                  lmc_mii_readreg (sc, 0, 16),
-                  lmc_mii_readreg (sc, 0, 17));
+    lmc_dec_reset(sc);
+    lmc_reset(sc);
 
+    LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
+    LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
+		  lmc_mii_readreg(sc, 0, 17));
 
     if (sc->lmc_ok){
         lmc_trace(dev, "lmc_open lmc_ok out");
@@ -1106,14 +1038,14 @@ static int lmc_open (struct net_device *dev) /*fold00*/
 
     /* dev->flags |= IFF_UP; */
 
-    lmc_proto_open(sc);
+    if ((err = lmc_proto_open(sc)) != 0)
+	    return err;
 
     dev->do_ioctl = lmc_ioctl;
 
 
     netif_start_queue(dev);
-    
-    sc->stats.tx_tbusy0++ ;
+    sc->extra_stats.tx_tbusy0++;
 
     /*
      * select what interrupts we want to get
@@ -1165,8 +1097,7 @@ static int lmc_open (struct net_device *dev) /*fold00*/
 
 static void lmc_running_reset (struct net_device *dev) /*fold00*/
 {
-
-    lmc_softc_t *sc = (lmc_softc_t *) dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
 
     lmc_trace(dev, "lmc_runnig_reset in");
 
@@ -1184,7 +1115,7 @@ static void lmc_running_reset (struct net_device *dev) /*fold00*/
     netif_wake_queue(dev);
 
     sc->lmc_txfull = 0;
-    sc->stats.tx_tbusy0++ ;
+    sc->extra_stats.tx_tbusy0++;
 
     sc->lmc_intrmask = TULIP_DEFAULT_INTR_MASK;
     LMC_CSR_WRITE (sc, csr_intr, sc->lmc_intrmask);
@@ -1200,14 +1131,13 @@ static void lmc_running_reset (struct net_device *dev) /*fold00*/
  * This disables the timer for the watchdog and keepalives,
  * and disables the irq for dev.
  */
-static int lmc_close (struct net_device *dev) /*fold00*/
+static int lmc_close(struct net_device *dev)
 {
     /* not calling release_region() as we should */
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
 
     lmc_trace(dev, "lmc_close in");
-    
-    sc = dev->priv;
+
     sc->lmc_ok = 0;
     sc->lmc_media->set_link_status (sc, 0);
     del_timer (&sc->timer);
@@ -1215,7 +1145,7 @@ static int lmc_close (struct net_device *dev) /*fold00*/
     lmc_ifdown (dev);
 
     lmc_trace(dev, "lmc_close out");
-    
+
     return 0;
 }
 
@@ -1223,16 +1153,16 @@ static int lmc_close (struct net_device *dev) /*fold00*/
 /* When the interface goes down, this is called */
 static int lmc_ifdown (struct net_device *dev) /*fold00*/
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 csr6;
     int i;
 
     lmc_trace(dev, "lmc_ifdown in");
-    
+
     /* Don't let anything else go on right now */
     //    dev->start = 0;
     netif_stop_queue(dev);
-    sc->stats.tx_tbusy1++ ;
+    sc->extra_stats.tx_tbusy1++;
 
     /* stop interrupts */
     /* Clear the interrupt mask */
@@ -1244,8 +1174,8 @@ static int lmc_ifdown (struct net_device *dev) /*fold00*/
     csr6 &= ~LMC_DEC_SR;		/* Turn off the Receive bit */
     LMC_CSR_WRITE (sc, csr_command, csr6);
 
-    sc->stats.rx_missed_errors +=
-        LMC_CSR_READ (sc, csr_missed_frames) & 0xffff;
+    sc->lmc_device->stats.rx_missed_errors +=
+	    LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
 
     /* release the interrupt */
     if(sc->got_irq == 1){
@@ -1276,7 +1206,7 @@ static int lmc_ifdown (struct net_device *dev) /*fold00*/
     lmc_led_off (sc, LMC_MII16_LED_ALL);
 
     netif_wake_queue(dev);
-    sc->stats.tx_tbusy0++ ;
+    sc->extra_stats.tx_tbusy0++;
 
     lmc_trace(dev, "lmc_ifdown out");
 
@@ -1289,7 +1219,7 @@ static int lmc_ifdown (struct net_device *dev) /*fold00*/
 static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
 {
     struct net_device *dev = (struct net_device *) dev_instance;
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 csr;
     int i;
     s32 stat;
@@ -1300,8 +1230,6 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
 
     lmc_trace(dev, "lmc_interrupt in");
 
-    sc = dev->priv;
-    
     spin_lock(&sc->lmc_lock);
 
     /*
@@ -1354,7 +1282,7 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
 
 	    int		n_compl = 0 ;
             /* reset the transmit timeout detection flag -baz */
-            sc->stats.tx_NoCompleteCnt = 0;
+	    sc->extra_stats.tx_NoCompleteCnt = 0;
 
             badtx = sc->lmc_taint_tx;
             i = badtx % LMC_TXDESCS;
@@ -1378,27 +1306,25 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
                 if (sc->lmc_txq[i] == NULL)
                     continue;
 
-                /*
-                 * Check the total error summary to look for any errors
-                 */
-                if (stat & 0x8000) {
-                    sc->stats.tx_errors++;
-                    if (stat & 0x4104)
-                        sc->stats.tx_aborted_errors++;
-                    if (stat & 0x0C00)
-                        sc->stats.tx_carrier_errors++;
-                    if (stat & 0x0200)
-                        sc->stats.tx_window_errors++;
-                    if (stat & 0x0002)
-                        sc->stats.tx_fifo_errors++;
-                }
-                else {
-                    
-                    sc->stats.tx_bytes += sc->lmc_txring[i].length & 0x7ff;
-                    
-                    sc->stats.tx_packets++;
+		/*
+		 * Check the total error summary to look for any errors
+		 */
+		if (stat & 0x8000) {
+			sc->lmc_device->stats.tx_errors++;
+			if (stat & 0x4104)
+				sc->lmc_device->stats.tx_aborted_errors++;
+			if (stat & 0x0C00)
+				sc->lmc_device->stats.tx_carrier_errors++;
+			if (stat & 0x0200)
+				sc->lmc_device->stats.tx_window_errors++;
+			if (stat & 0x0002)
+				sc->lmc_device->stats.tx_fifo_errors++;
+		} else {
+			sc->lmc_device->stats.tx_bytes += sc->lmc_txring[i].length & 0x7ff;
+
+			sc->lmc_device->stats.tx_packets++;
                 }
-                
+
                 //                dev_kfree_skb(sc->lmc_txq[i]);
                 dev_kfree_skb_irq(sc->lmc_txq[i]);
                 sc->lmc_txq[i] = NULL;
@@ -1415,13 +1341,13 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
             LMC_EVENT_LOG(LMC_EVENT_TBUSY0, n_compl, 0);
             sc->lmc_txfull = 0;
             netif_wake_queue(dev);
-            sc->stats.tx_tbusy0++ ;
+	    sc->extra_stats.tx_tbusy0++;
 
 
 #ifdef DEBUG
-            sc->stats.dirtyTx = badtx;
-            sc->stats.lmc_next_tx = sc->lmc_next_tx;
-            sc->stats.lmc_txfull = sc->lmc_txfull;
+	    sc->extra_stats.dirtyTx = badtx;
+	    sc->extra_stats.lmc_next_tx = sc->lmc_next_tx;
+	    sc->extra_stats.lmc_txfull = sc->lmc_txfull;
 #endif
             sc->lmc_taint_tx = badtx;
 
@@ -1476,9 +1402,9 @@ lmc_int_fail_out:
     return IRQ_RETVAL(handled);
 }
 
-static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00*/
+static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 flag;
     int entry;
     int ret = 0;
@@ -1486,8 +1412,6 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
 
     lmc_trace(dev, "lmc_start_xmit in");
 
-    sc = dev->priv;
-
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
     /* normal path, tbusy known to be zero */
@@ -1532,8 +1456,8 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
     if (sc->lmc_next_tx - sc->lmc_taint_tx >= LMC_TXDESCS - 1)
     {				/* ring full, go busy */
         sc->lmc_txfull = 1;
-        netif_stop_queue(dev);
-        sc->stats.tx_tbusy1++ ;
+	netif_stop_queue(dev);
+	sc->extra_stats.tx_tbusy1++;
         LMC_EVENT_LOG(LMC_EVENT_TBUSY1, entry, 0);
     }
 #endif
@@ -1550,7 +1474,7 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
      * the watchdog timer handler. -baz
      */
 
-    sc->stats.tx_NoCompleteCnt++;
+    sc->extra_stats.tx_NoCompleteCnt++;
     sc->lmc_next_tx++;
 
     /* give ownership to the chip */
@@ -1569,9 +1493,9 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
 }
 
 
-static int lmc_rx (struct net_device *dev) /*fold00*/
+static int lmc_rx(struct net_device *dev)
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     int i;
     int rx_work_limit = LMC_RXDESCS;
     unsigned int next_rx;
@@ -1583,8 +1507,6 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
 
     lmc_trace(dev, "lmc_rx in");
 
-    sc = dev->priv;
-
     lmc_led_on(sc, LMC_DS3_LED3);
 
     rxIntLoopCnt = 0;		/* debug -baz */
@@ -1597,39 +1519,38 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
         rxIntLoopCnt++;		/* debug -baz */
         len = ((stat & LMC_RDES_FRAME_LENGTH) >> RDES_FRAME_LENGTH_BIT_NUMBER);
         if ((stat & 0x0300) != 0x0300) {  /* Check first segment and last segment */
-            if ((stat & 0x0000ffff) != 0x7fff) {
-                /* Oversized frame */
-                sc->stats.rx_length_errors++;
-                goto skip_packet;
-            }
-        }
-
-        if(stat & 0x00000008){ /* Catch a dribbling bit error */
-            sc->stats.rx_errors++;
-            sc->stats.rx_frame_errors++;
-            goto skip_packet;
-        }
+		if ((stat & 0x0000ffff) != 0x7fff) {
+			/* Oversized frame */
+			sc->lmc_device->stats.rx_length_errors++;
+			goto skip_packet;
+		}
+	}
 
+	if (stat & 0x00000008) { /* Catch a dribbling bit error */
+		sc->lmc_device->stats.rx_errors++;
+		sc->lmc_device->stats.rx_frame_errors++;
+		goto skip_packet;
+	}
 
-        if(stat & 0x00000004){ /* Catch a CRC error by the Xilinx */
-            sc->stats.rx_errors++;
-            sc->stats.rx_crc_errors++;
-            goto skip_packet;
-        }
 
+	if (stat & 0x00000004) { /* Catch a CRC error by the Xilinx */
+		sc->lmc_device->stats.rx_errors++;
+		sc->lmc_device->stats.rx_crc_errors++;
+		goto skip_packet;
+	}
 
-        if (len > LMC_PKT_BUF_SZ){
-            sc->stats.rx_length_errors++;
-            localLengthErrCnt++;
-            goto skip_packet;
-        }
+	if (len > LMC_PKT_BUF_SZ) {
+		sc->lmc_device->stats.rx_length_errors++;
+		localLengthErrCnt++;
+		goto skip_packet;
+	}
 
-        if (len < sc->lmc_crcSize + 2) {
-            sc->stats.rx_length_errors++;
-            sc->stats.rx_SmallPktCnt++;
-            localLengthErrCnt++;
-            goto skip_packet;
-        }
+	if (len < sc->lmc_crcSize + 2) {
+		sc->lmc_device->stats.rx_length_errors++;
+		sc->extra_stats.rx_SmallPktCnt++;
+		localLengthErrCnt++;
+		goto skip_packet;
+	}
 
         if(stat & 0x00004000){
             printk(KERN_WARNING "%s: Receiver descriptor error, receiver out of sync?\n", dev->name);
@@ -1656,8 +1577,8 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
         }
         
         dev->last_rx = jiffies;
-        sc->stats.rx_packets++;
-        sc->stats.rx_bytes += len;
+	sc->lmc_device->stats.rx_packets++;
+	sc->lmc_device->stats.rx_bytes += len;
 
         LMC_CONSOLE_LOG("recv", skb->data, len);
 
@@ -1679,7 +1600,6 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
 
             skb_put (skb, len);
             skb->protocol = lmc_proto_type(sc, skb);
-            skb->protocol = htons(ETH_P_WAN_PPP);
             skb_reset_mac_header(skb);
             /* skb_reset_network_header(skb); */
             skb->dev = dev;
@@ -1704,7 +1624,7 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
                  * in which care we'll try to allocate the buffer
                  * again.  (once a second)
                  */
-                sc->stats.rx_BuffAllocErr++;
+		sc->extra_stats.rx_BuffAllocErr++;
                 LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
                 sc->failed_recv_alloc = 1;
                 goto skip_out_of_mem;
@@ -1739,16 +1659,14 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
      * descriptors with bogus packets
      *
     if (localLengthErrCnt > LMC_RXDESCS - 3) {
-        sc->stats.rx_BadPktSurgeCnt++;
-        LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE,
-                      localLengthErrCnt,
-                      sc->stats.rx_BadPktSurgeCnt);
+	sc->extra_stats.rx_BadPktSurgeCnt++;
+	LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE, localLengthErrCnt,
+		      sc->extra_stats.rx_BadPktSurgeCnt);
     } */
 
     /* save max count of receive descriptors serviced */
-    if (rxIntLoopCnt > sc->stats.rxIntLoopCnt) {
-        sc->stats.rxIntLoopCnt = rxIntLoopCnt;	/* debug -baz */
-    }
+    if (rxIntLoopCnt > sc->extra_stats.rxIntLoopCnt)
+	    sc->extra_stats.rxIntLoopCnt = rxIntLoopCnt; /* debug -baz */
 
 #ifdef DEBUG
     if (rxIntLoopCnt == 0)
@@ -1775,23 +1693,22 @@ skip_out_of_mem:
     return 0;
 }
 
-static struct net_device_stats *lmc_get_stats (struct net_device *dev) /*fold00*/
+static struct net_device_stats *lmc_get_stats(struct net_device *dev)
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
     unsigned long flags;
 
     lmc_trace(dev, "lmc_get_stats in");
 
-
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
-    sc->stats.rx_missed_errors += LMC_CSR_READ (sc, csr_missed_frames) & 0xffff;
+    sc->lmc_device->stats.rx_missed_errors += LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
 
     spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
     lmc_trace(dev, "lmc_get_stats out");
 
-    return (struct net_device_stats *) &sc->stats;
+    return &sc->lmc_device->stats;
 }
 
 static struct pci_driver lmc_driver = {
@@ -1970,7 +1887,7 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
     {
         if (sc->lmc_txq[i] != NULL){		/* have buffer */
             dev_kfree_skb(sc->lmc_txq[i]);	/* free it */
-            sc->stats.tx_dropped++;      /* We just dropped a packet */
+	    sc->lmc_device->stats.tx_dropped++;	/* We just dropped a packet */
         }
         sc->lmc_txq[i] = NULL;
         sc->lmc_txring[i].status = 0x00000000;
@@ -2061,7 +1978,7 @@ static void lmc_reset(lmc_softc_t * const sc) /*fold00*/
      */
     sc->lmc_media->init(sc);
 
-    sc->stats.resetCount++;
+    sc->extra_stats.resetCount++;
     lmc_trace(sc->lmc_device, "lmc_reset out");
 }
 
@@ -2151,23 +2068,21 @@ static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base, /*fold00
     lmc_trace(sc->lmc_device, "lmc_initcsrs out");
 }
 
-static void lmc_driver_timeout(struct net_device *dev) { /*fold00*/
-    lmc_softc_t *sc;
+static void lmc_driver_timeout(struct net_device *dev)
+{
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 csr6;
     unsigned long flags;
 
     lmc_trace(dev, "lmc_driver_timeout in");
 
-    sc = dev->priv;
-
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
     printk("%s: Xmitter busy|\n", dev->name);
 
-    sc->stats.tx_tbusy_calls++ ;
-    if (jiffies - dev->trans_start < TX_TIMEOUT) {
-        goto bug_out;
-    }
+    sc->extra_stats.tx_tbusy_calls++;
+    if (jiffies - dev->trans_start < TX_TIMEOUT)
+	    goto bug_out;
 
     /*
      * Chip seems to have locked up
@@ -2178,7 +2093,7 @@ static void lmc_driver_timeout(struct net_device *dev) { /*fold00*/
 
     LMC_EVENT_LOG(LMC_EVENT_XMTPRCTMO,
                   LMC_CSR_READ (sc, csr_status),
-                  sc->stats.tx_ProcTimeout);
+		  sc->extra_stats.tx_ProcTimeout);
 
     lmc_running_reset (dev);
 
@@ -2195,8 +2110,8 @@ static void lmc_driver_timeout(struct net_device *dev) { /*fold00*/
     /* immediate transmit */
     LMC_CSR_WRITE (sc, csr_txpoll, 0);
 
-    sc->stats.tx_errors++;
-    sc->stats.tx_ProcTimeout++;	/* -baz */
+    sc->lmc_device->stats.tx_errors++;
+    sc->extra_stats.tx_ProcTimeout++; /* -baz */
 
     dev->trans_start = jiffies;
 
diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/lmc_media.c
index 1cc5834..2e0711a 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/lmc_media.c
@@ -425,7 +425,7 @@ lmc_ds3_set_scram (lmc_softc_t * const sc, int ie)
 static int
 lmc_ds3_get_link_status (lmc_softc_t * const sc)
 {
-    u_int16_t link_status, link_status_11;
+    u16 link_status, link_status_11;
     int ret = 1;
 
     lmc_mii_writereg (sc, 0, 17, 7);
@@ -447,7 +447,7 @@ lmc_ds3_get_link_status (lmc_softc_t * const sc)
         (link_status & LMC_FRAMER_REG0_OOFS)){
         ret = 0;
         if(sc->last_led_err[3] != 1){
-            u16 r1;
+	    u16 r1;
             lmc_mii_writereg (sc, 0, 17, 01); /* Turn on Xbit error as our cisco does */
             r1 = lmc_mii_readreg (sc, 0, 18);
             r1 &= 0xfe;
@@ -460,7 +460,7 @@ lmc_ds3_get_link_status (lmc_softc_t * const sc)
     else {
         lmc_led_off(sc, LMC_DS3_LED3);	/* turn on red LED */
         if(sc->last_led_err[3] == 1){
-            u16 r1;
+	    u16 r1;
             lmc_mii_writereg (sc, 0, 17, 01); /* Turn off Xbit error */
             r1 = lmc_mii_readreg (sc, 0, 18);
             r1 |= 0x01;
@@ -538,20 +538,19 @@ lmc_ds3_watchdog (lmc_softc_t * const sc)
  *  SSI methods
  */
 
-static void
-lmc_ssi_init (lmc_softc_t * const sc)
+static void lmc_ssi_init(lmc_softc_t * const sc)
 {
-  u_int16_t mii17;
-  int cable;
+	u16 mii17;
+	int cable;
 
-  sc->ictl.cardtype = LMC_CTL_CARDTYPE_LMC1000;
+	sc->ictl.cardtype = LMC_CTL_CARDTYPE_LMC1000;
 
-  mii17 = lmc_mii_readreg (sc, 0, 17);
+	mii17 = lmc_mii_readreg(sc, 0, 17);
 
-  cable = (mii17 & LMC_MII17_SSI_CABLE_MASK) >> LMC_MII17_SSI_CABLE_SHIFT;
-  sc->ictl.cable_type = cable;
+	cable = (mii17 & LMC_MII17_SSI_CABLE_MASK) >> LMC_MII17_SSI_CABLE_SHIFT;
+	sc->ictl.cable_type = cable;
 
-  lmc_gpio_mkoutput (sc, LMC_GEP_SSI_TXCLOCK);
+	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
 }
 
 static void
@@ -679,11 +678,11 @@ lmc_ssi_set_speed (lmc_softc_t * const sc, lmc_ctl_t * ctl)
 static int
 lmc_ssi_get_link_status (lmc_softc_t * const sc)
 {
-  u_int16_t link_status;
+  u16 link_status;
   u_int32_t ticks;
   int ret = 1;
   int hw_hdsk = 1;
-  
+
   /*
    * missing CTS?  Hmm.  If we require CTS on, we may never get the
    * link to come up, so omit it in this test.
@@ -718,9 +717,9 @@ lmc_ssi_get_link_status (lmc_softc_t * const sc)
   }
   else if (ticks == 0 ) {				/* no clock found ? */
       ret = 0;
-      if(sc->last_led_err[3] != 1){
-          sc->stats.tx_lossOfClockCnt++;
-          printk(KERN_WARNING "%s: Lost Clock, Link Down\n", sc->name);
+      if (sc->last_led_err[3] != 1) {
+	      sc->extra_stats.tx_lossOfClockCnt++;
+	      printk(KERN_WARNING "%s: Lost Clock, Link Down\n", sc->name);
       }
       sc->last_led_err[3] = 1;
       lmc_led_on (sc, LMC_MII16_LED3);	/* turn ON red LED */
@@ -885,19 +884,13 @@ write_av9110 (lmc_softc_t * sc, u_int32_t n, u_int32_t m, u_int32_t v,
 		     | LMC_GEP_SSI_GENERATOR));
 }
 
-static void
-lmc_ssi_watchdog (lmc_softc_t * const sc)
+static void lmc_ssi_watchdog(lmc_softc_t * const sc)
 {
-  u_int16_t mii17 = lmc_mii_readreg (sc, 0, 17);
-  if (((mii17 >> 3) & 7) == 7)
-    {
-      lmc_led_off (sc, LMC_MII16_LED2);
-    }
-  else
-    {
-      lmc_led_on (sc, LMC_MII16_LED2);
-    }
-
+	u16 mii17 = lmc_mii_readreg(sc, 0, 17);
+	if (((mii17 >> 3) & 7) == 7)
+		lmc_led_off(sc, LMC_MII16_LED2);
+	else
+		lmc_led_on(sc, LMC_MII16_LED2);
 }
 
 /*
@@ -927,7 +920,7 @@ lmc_t1_read (lmc_softc_t * const sc, int a)
 static void
 lmc_t1_init (lmc_softc_t * const sc)
 {
-  u_int16_t mii16;
+  u16 mii16;
   int i;
 
   sc->ictl.cardtype = LMC_CTL_CARDTYPE_LMC1200;
@@ -1026,7 +1019,7 @@ lmc_t1_set_status (lmc_softc_t * const sc, lmc_ctl_t * ctl)
  */ static int
 lmc_t1_get_link_status (lmc_softc_t * const sc)
 {
-    u_int16_t link_status;
+    u16 link_status;
     int ret = 1;
 
   /* LMC5245 (DS3) & LMC1200 (DS1) LED definitions
diff --git a/drivers/net/wan/lmc/lmc_proto.c b/drivers/net/wan/lmc/lmc_proto.c
index 8531575..be9877f 100644
--- a/drivers/net/wan/lmc/lmc_proto.c
+++ b/drivers/net/wan/lmc/lmc_proto.c
@@ -36,9 +36,6 @@
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/bitops.h>
-
-#include <net/syncppp.h>
-
 #include <asm/processor.h>             /* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -50,48 +47,6 @@
 #include "lmc_ioctl.h"
 #include "lmc_proto.h"
 
-/*
- * The compile-time variable SPPPSTUP causes the module to be
- * compiled without referencing any of the sync ppp routines.
- */
-#ifdef SPPPSTUB
-#define SPPP_detach(d)	(void)0
-#define SPPP_open(d)	0
-#define SPPP_reopen(d)	(void)0
-#define SPPP_close(d)	(void)0
-#define SPPP_attach(d)	(void)0
-#define SPPP_do_ioctl(d,i,c)	-EOPNOTSUPP
-#else
-#define SPPP_attach(x)	sppp_attach((x)->pd)
-#define SPPP_detach(x)	sppp_detach((x)->pd->dev)
-#define SPPP_open(x)	sppp_open((x)->pd->dev)
-#define SPPP_reopen(x)	sppp_reopen((x)->pd->dev)
-#define SPPP_close(x)	sppp_close((x)->pd->dev)
-#define SPPP_do_ioctl(x, y, z)	sppp_do_ioctl((x)->pd->dev, (y), (z))
-#endif
-
-// init
-void lmc_proto_init(lmc_softc_t *sc) /*FOLD00*/
-{
-    lmc_trace(sc->lmc_device, "lmc_proto_init in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        sc->pd = kmalloc(sizeof(struct ppp_device), GFP_KERNEL);
-	if (!sc->pd) {
-		printk("lmc_proto_init(): kmalloc failure!\n");
-		return;
-	}
-        sc->pd->dev = sc->lmc_device;
-        sc->if_ptr = sc->pd;
-        break;
-    case LMC_RAW:
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_init out");
-}
-
 // attach
 void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
 {
@@ -100,7 +55,6 @@ void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
     case LMC_PPP:
         {
             struct net_device *dev = sc->lmc_device;
-            SPPP_attach(sc);
             dev->do_ioctl = lmc_ioctl;
         }
         break;
@@ -108,7 +62,7 @@ void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
         {
             struct net_device *dev = sc->lmc_device;
             /*
-             * They set a few basics because they don't use sync_ppp
+	     * They set a few basics because they don't use HDLC
              */
             dev->flags |= IFF_POINTOPOINT;
 
@@ -124,88 +78,39 @@ void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
     lmc_trace(sc->lmc_device, "lmc_proto_attach out");
 }
 
-// detach
-void lmc_proto_detach(lmc_softc_t *sc) /*FOLD00*/
+int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd)
 {
-    switch(sc->if_type){
-    case LMC_PPP:
-        SPPP_detach(sc);
-        break;
-    case LMC_RAW: /* Tell someone we're detaching? */
-        break;
-    default:
-        break;
-    }
-
+	lmc_trace(sc->lmc_device, "lmc_proto_ioctl");
+	if (sc->if_type == LMC_PPP)
+		return hdlc_ioctl(sc->lmc_device, ifr, cmd);
+	return -EOPNOTSUPP;
 }
 
-// reopen
-void lmc_proto_reopen(lmc_softc_t *sc) /*FOLD00*/
+int lmc_proto_open(lmc_softc_t *sc)
 {
-    lmc_trace(sc->lmc_device, "lmc_proto_reopen in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        SPPP_reopen(sc);
-        break;
-    case LMC_RAW: /* Reset the interface after being down, prerape to receive packets again */
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_reopen out");
-}
+	int ret = 0;
 
+	lmc_trace(sc->lmc_device, "lmc_proto_open in");
 
-// ioctl
-int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd) /*FOLD00*/
-{
-    lmc_trace(sc->lmc_device, "lmc_proto_ioctl out");
-    switch(sc->if_type){
-    case LMC_PPP:
-        return SPPP_do_ioctl (sc, ifr, cmd);
-        break;
-    default:
-        return -EOPNOTSUPP;
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_ioctl out");
+	if (sc->if_type == LMC_PPP) {
+		ret = hdlc_open(sc->lmc_device);
+		if (ret < 0)
+			printk(KERN_WARNING "%s: HDLC open failed: %d\n",
+			       sc->name, ret);
+	}
+
+	lmc_trace(sc->lmc_device, "lmc_proto_open out");
+	return ret;
 }
 
-// open
-void lmc_proto_open(lmc_softc_t *sc) /*FOLD00*/
+void lmc_proto_close(lmc_softc_t *sc)
 {
-    int ret;
+	lmc_trace(sc->lmc_device, "lmc_proto_close in");
 
-    lmc_trace(sc->lmc_device, "lmc_proto_open in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        ret = SPPP_open(sc);
-        if(ret < 0)
-            printk("%s: syncPPP open failed: %d\n", sc->name, ret);
-        break;
-    case LMC_RAW: /* We're about to start getting packets! */
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_open out");
-}
-
-// close
+	if (sc->if_type == LMC_PPP)
+		hdlc_close(sc->lmc_device);
 
-void lmc_proto_close(lmc_softc_t *sc) /*FOLD00*/
-{
-    lmc_trace(sc->lmc_device, "lmc_proto_close in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        SPPP_close(sc);
-        break;
-    case LMC_RAW: /* Interface going down */
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_close out");
+	lmc_trace(sc->lmc_device, "lmc_proto_close out");
 }
 
 __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
@@ -213,8 +118,8 @@ __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
     lmc_trace(sc->lmc_device, "lmc_proto_type in");
     switch(sc->if_type){
     case LMC_PPP:
-        return htons(ETH_P_WAN_PPP);
-        break;
+	    return hdlc_type_trans(skb, sc->lmc_device);
+	    break;
     case LMC_NET:
         return htons(ETH_P_802_2);
         break;
@@ -245,4 +150,3 @@ void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
     }
     lmc_trace(sc->lmc_device, "lmc_proto_netif out");
 }
-
diff --git a/drivers/net/wan/lmc/lmc_proto.h b/drivers/net/wan/lmc/lmc_proto.h
index ccaa69e..662148c 100644
--- a/drivers/net/wan/lmc/lmc_proto.h
+++ b/drivers/net/wan/lmc/lmc_proto.h
@@ -1,16 +1,18 @@
 #ifndef _LMC_PROTO_H_
 #define _LMC_PROTO_H_
 
-void lmc_proto_init(lmc_softc_t *sc);
+#include <linux/hdlc.h>
+
 void lmc_proto_attach(lmc_softc_t *sc);
-void lmc_proto_detach(lmc_softc_t *sc);
-void lmc_proto_reopen(lmc_softc_t *sc);
 int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd);
-void lmc_proto_open(lmc_softc_t *sc);
+int lmc_proto_open(lmc_softc_t *sc);
 void lmc_proto_close(lmc_softc_t *sc);
 __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb);
 void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb);
-int lmc_skb_rawpackets(char *buf, char **start, off_t offset, int len, int unused);
 
-#endif
+static inline lmc_softc_t* dev_to_sc(struct net_device *dev)
+{
+	return (lmc_softc_t *)dev_to_hdlc(dev)->priv;
+}
 
+#endif
diff --git a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_var.h
index 6d003a3..52e0442 100644
--- a/drivers/net/wan/lmc/lmc_var.h
+++ b/drivers/net/wan/lmc/lmc_var.h
@@ -1,8 +1,6 @@
 #ifndef _LMC_VAR_H_
 #define _LMC_VAR_H_
 
-/* $Id: lmc_var.h,v 1.17 2000/04/06 12:16:47 asj Exp $ */
-
  /*
   * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
   * All rights reserved.  www.lanmedia.com
@@ -19,23 +17,6 @@
 
 #include <linux/timer.h>
 
-#ifndef __KERNEL__
-typedef signed char s8;
-typedef unsigned char u8;
-
-typedef signed short s16;
-typedef unsigned short u16;
-
-typedef signed int s32;
-typedef unsigned int u32;
-
-typedef signed long long s64;
-typedef unsigned long long u64;
-
-#define BITS_PER_LONG 32 
-
-#endif
-
 /*
  * basic definitions used in lmc include files
  */
@@ -45,9 +26,6 @@ typedef struct lmc___media lmc_media_t;
 typedef struct lmc___ctl lmc_ctl_t;
 
 #define lmc_csrptr_t    unsigned long
-#define u_int16_t	u16
-#define u_int8_t	u8
-#define tulip_uint32_t	u32
 
 #define LMC_REG_RANGE 0x80
 
@@ -244,46 +222,8 @@ struct lmc___media {
 
 #define STATCHECK     0xBEEFCAFE
 
-/*  Included in this structure are first
- *   - standard net_device_stats
- *   - some other counters used for debug and driver performance
- *  evaluation -baz
- */
-struct lmc_statistics
+struct lmc_extra_statistics
 {
-        unsigned long     rx_packets;             /* total packets received       */
-        unsigned long     tx_packets;             /* total packets transmitted    */
-	unsigned long     rx_bytes;
-        unsigned long     tx_bytes;
-        
-        unsigned long     rx_errors;              /* bad packets received         */
-        unsigned long     tx_errors;              /* packet transmit problems     */
-        unsigned long     rx_dropped;             /* no space in linux buffers    */
-        unsigned long     tx_dropped;             /* no space available in linux  */
-        unsigned long     multicast;              /* multicast packets received   */
-        unsigned long     collisions;
-
-        /* detailed rx_errors: */
-        unsigned long     rx_length_errors;
-        unsigned long     rx_over_errors;         /* receiver ring buff overflow  */
-        unsigned long     rx_crc_errors;          /* recved pkt with crc error    */
-        unsigned long     rx_frame_errors;        /* recv'd frame alignment error */
-        unsigned long     rx_fifo_errors;         /* recv'r fifo overrun          */
-        unsigned long     rx_missed_errors;       /* receiver missed packet       */
-
-        /* detailed tx_errors */
-        unsigned long     tx_aborted_errors;
-        unsigned long     tx_carrier_errors;
-        unsigned long     tx_fifo_errors;
-        unsigned long     tx_heartbeat_errors;
-        unsigned long     tx_window_errors;
-
-        /* for cslip etc */
-        unsigned long rx_compressed;
-        unsigned long tx_compressed;
-
-        /* -------------------------------------
-         * Custom stats & counters follow -baz */
         u_int32_t       version_size;
         u_int32_t       lmc_cardtype;
 
@@ -325,27 +265,26 @@ struct lmc_statistics
         u_int32_t       check;
 };
 
-
 typedef struct lmc_xinfo {
-        u_int32_t       Magic0;                         /* BEEFCAFE */
+	u_int32_t       Magic0;                         /* BEEFCAFE */
 
-        u_int32_t       PciCardType;
-        u_int32_t       PciSlotNumber;          /* PCI slot number       */
+	u_int32_t       PciCardType;
+	u_int32_t       PciSlotNumber;          /* PCI slot number       */
 
-        u_int16_t       DriverMajorVersion;
-        u_int16_t       DriverMinorVersion;
-        u_int16_t       DriverSubVersion;
+	u16	       DriverMajorVersion;
+	u16	       DriverMinorVersion;
+	u16	       DriverSubVersion;
 
-        u_int16_t       XilinxRevisionNumber;
-        u_int16_t       MaxFrameSize;
+	u16	       XilinxRevisionNumber;
+	u16	       MaxFrameSize;
 
-        u_int16_t       t1_alarm1_status;
-        u_int16_t       t1_alarm2_status;
+	u16     	  t1_alarm1_status;
+	u16       	t1_alarm2_status;
 
-        int                     link_status;
-        u_int32_t       mii_reg16;
+	int             link_status;
+	u_int32_t       mii_reg16;
 
-        u_int32_t       Magic1;                         /* DEADBEEF */
+	u_int32_t       Magic1;                         /* DEADBEEF */
 } LMC_XINFO;
 
 
@@ -353,11 +292,10 @@ typedef struct lmc_xinfo {
  * forward decl
  */
 struct lmc___softc {
-        void *if_ptr;   /* General purpose pointer (used by SPPP) */
 	char                   *name;
 	u8			board_idx;
-	struct lmc_statistics   stats;
-	struct net_device          *lmc_device;
+	struct lmc_extra_statistics extra_stats;
+	struct net_device      *lmc_device;
 
 	int                     hang, rxdesc, bad_packet, some_counter;
 	u_int32_t               txgo;
@@ -381,7 +319,7 @@ struct lmc___softc {
 	unsigned int		lmc_taint_tx, lmc_taint_rx;
 	int			lmc_tx_start, lmc_txfull;
 	int			lmc_txbusy;
-	u_int16_t		lmc_miireg16;
+	u16			lmc_miireg16;
 	int			lmc_ok;
 	int			last_link_status;
 	int			lmc_cardtype;
@@ -408,8 +346,7 @@ struct lmc___softc {
         u32                     num_int;
 
 	spinlock_t              lmc_lock;
-        u_int16_t               if_type;       /* PPP or NET */
-        struct ppp_device       *pd;
+	u16			if_type;       /* HDLC/PPP or NET */
 
         /* Failure cases */
         u8                       failed_ring;
@@ -525,46 +462,9 @@ struct lmc___softc {
 #define LMC_ADAP_SSI            4
 #define LMC_ADAP_T1             5
 
-#define HDLC_HDR_LEN  4
-#define HDLC_ADDR_LEN 1
-#define HDLC_SLARP    0x8035
 #define LMC_MTU 1500
-#define SLARP_LINECHECK 2
 
 #define LMC_CRC_LEN_16 2  /* 16-bit CRC */
 #define LMC_CRC_LEN_32 4
 
-#ifdef LMC_HDLC
-/* definition of an hdlc header. */
-struct hdlc_hdr
-{
-	u8  address;
-	u8  control;
-	u16 type;
-};
-
-/* definition of a slarp header. */
-struct slarp
-{
-	long code;
-	union sl
-	{
-		struct
-		{
-			ulong address;
-			ulong mask;
-			ushort unused;
-		} add;
-		struct
-		{
-			ulong mysequence;
-			ulong yoursequence;
-			ushort reliability;
-			ulong time;
-		} chk;
-	} t;
-};
-#endif /* LMC_HDLC */
-
-
 #endif /* _LMC_VAR_H_ */
-- 
Krzysztof Halasa
