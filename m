From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 06/29] LMC: Remove stub files proto.[ch].
Date: Sat, 31 Jul 2010 17:05:29 +0200
Message-ID: <1280588752-9340-6-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52516 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756437Ab0GaPGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:12 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/Makefile |    2 +-
 drivers/net/wan/lmc/main.c   |   29 ++++++-------
 drivers/net/wan/lmc/proto.c  |   95 ----------------------------------=
--------
 drivers/net/wan/lmc/proto.h  |   18 --------
 4 files changed, 14 insertions(+), 130 deletions(-)
 delete mode 100644 drivers/net/wan/lmc/proto.c
 delete mode 100644 drivers/net/wan/lmc/proto.h

diff --git a/drivers/net/wan/lmc/Makefile b/drivers/net/wan/lmc/Makefil=
e
index 2c14b98..2f461a7 100644
--- a/drivers/net/wan/lmc/Makefile
+++ b/drivers/net/wan/lmc/Makefile
@@ -5,7 +5,7 @@
=20
 obj-$(CONFIG_LANMEDIA) +=3D lmc.o
=20
-lmc-objs :=3D debug.o media.o main.o proto.o
+lmc-objs :=3D debug.o media.o main.o
=20
 # Like above except every packet gets echoed to KERN_DEBUG
 # in hex
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index a6de32f..13bb6f6 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -72,7 +72,6 @@
 #include "var.h"
 #include "ioctl.h"
 #include "debug.h"
-#include "proto.h"
=20
 static int LMC_PKT_BUF_SZ =3D 1542;
=20
@@ -104,6 +103,12 @@ static void lmc_reset(struct card * const sc);
 static void lmc_dec_reset(struct card * const sc);
 static void lmc_driver_timeout(struct net_device *dev);
=20
+static inline struct card* dev_to_sc(struct net_device *dev)
+{
+	return (struct card *)dev_to_hdlc(dev)->priv;
+}
+
+
 /* linux reserves 16 device specific IOCTLs.  We call them
    LMCIOC* to control various bits of our world. */
 int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -566,7 +571,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 	break;
 	default:
 		/* If we don't know what to do, give the protocol a shot. */
-		ret =3D lmc_proto_ioctl(sc, ifr, cmd);
+		ret =3D hdlc_ioctl(sc->lmc_device, ifr, cmd);
 		break;
 	}
=20
@@ -795,12 +800,6 @@ static int __devinit lmc_init_one(struct pci_dev *=
pdev,
 	pci_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
=20
-	/*
-	 * This will get the protocol layer ready and do any 1 time init's
-	 * Must have a valid sc and dev structure
-	 */
-	lmc_proto_attach(sc);
-
 	/* Init the spin lock so can call it latter */
=20
 	spin_lock_init(&sc->lmc_lock);
@@ -973,9 +972,7 @@ static int lmc_open(struct net_device *dev)
 	sc->lmc_media->set_crc_length(sc, sc->ictl.crc_length);
 	/* Acknowledge the Terminal Active and light LEDs */
=20
-	/* dev->flags |=3D IFF_UP; */
-
-	if ((err =3D lmc_proto_open(sc)) !=3D 0)
+	if ((err =3D hdlc_open(sc->lmc_device)) !=3D 0)
 		return err;
=20
 	netif_start_queue(dev);
@@ -1059,7 +1056,7 @@ static int lmc_close(struct net_device *dev)
 	sc->lmc_ok =3D 0;
 	sc->lmc_media->set_link_status(sc, 0);
 	del_timer(&sc->timer);
-	lmc_proto_close(sc);
+	hdlc_close(sc->lmc_device);
 	lmc_ifdown(dev);
=20
 	lmc_trace(dev, "lmc_close out");
@@ -1489,11 +1486,11 @@ give_it_anyways:
 			sc->lmc_rxring[i].buffer1 =3D 0x0;
=20
 			skb_put(skb, len);
-			skb->protocol =3D lmc_proto_type(sc, skb);
+			skb->protocol =3D hdlc_type_trans(skb, sc->lmc_device);
 			skb_reset_mac_header(skb);
 			/* skb_reset_network_header(skb); */
 			skb->dev =3D dev;
-			lmc_proto_netif(sc, skb);
+			netif_rx(skb);
=20
 			/* This skb will be destroyed by the upper layers,
 			   make a new one */
@@ -1520,11 +1517,11 @@ give_it_anyways:
 			if (!nsb)
 				goto give_it_anyways;
 			skb_copy_from_linear_data(skb, skb_put(nsb, len), len);
-			nsb->protocol =3D lmc_proto_type(sc, nsb);
+			nsb->protocol =3D hdlc_type_trans(nsb, sc->lmc_device);
 			skb_reset_mac_header(nsb);
 			/* skb_reset_network_header(nsb); */
 			nsb->dev =3D dev;
-			lmc_proto_netif(sc, nsb);
+			netif_rx(nsb);
 		}
=20
 skip_packet:
diff --git a/drivers/net/wan/lmc/proto.c b/drivers/net/wan/lmc/proto.c
deleted file mode 100644
index ffd952a..0000000
--- a/drivers/net/wan/lmc/proto.c
+++ /dev/null
@@ -1,95 +0,0 @@
-/*
- * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
- * All rights reserved.  www.lanmedia.com
- *
- * This code is written by:
- * Andrew Stanley-Jones (asj@cban.com)
- * Rob Braun (bbraun@vix.com),
- * Michael Graff (explorer@vix.com) and
- * Matt Thomas (matt@3am-software.com).
- *
- * With Help By:
- * David Boggs
- * Ron Crane
- * Allan Cox
- *
- * This software may be used and distributed according to the terms of
- * the GNU General Public License version 2, incorporated herein by re=
ference.
- *
- * Driver for the LanMedia LMC5200, LMC5245, LMC1000, LMC1200 cards.
- */
-
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ptrace.h>
-#include <linux/errno.h>
-#include <linux/ioport.h>
-#include <linux/interrupt.h>
-#include <linux/in.h>
-#include <linux/if_arp.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/inet.h>
-#include <linux/workqueue.h>
-#include <linux/proc_fs.h>
-#include <linux/bitops.h>
-#include <linux/io.h>
-#include <asm/processor.h>   /* Processor type for cache alignment. */
-#include <asm/dma.h>
-#include <linux/smp.h>
-
-#include "lmc.h"
-#include "var.h"
-#include "debug.h"
-#include "ioctl.h"
-#include "proto.h"
-
-void lmc_proto_attach(struct card *sc)
-{
-	lmc_trace(sc->lmc_device, "lmc_proto_attach in");
-	lmc_trace(sc->lmc_device, "lmc_proto_attach out");
-}
-
-int lmc_proto_ioctl(struct card *sc, struct ifreq *ifr, int cmd)
-{
-	lmc_trace(sc->lmc_device, "lmc_proto_ioctl");
-	return hdlc_ioctl(sc->lmc_device, ifr, cmd);
-}
-
-int lmc_proto_open(struct card *sc)
-{
-	int ret =3D 0;
-
-	lmc_trace(sc->lmc_device, "lmc_proto_open in");
-
-	ret =3D hdlc_open(sc->lmc_device);
-	if (ret < 0)
-		printk(KERN_WARNING "%s: HDLC open failed: %d\n",
-		       sc->name, ret);
-
-	lmc_trace(sc->lmc_device, "lmc_proto_open out");
-	return ret;
-}
-
-void lmc_proto_close(struct card *sc)
-{
-	lmc_trace(sc->lmc_device, "lmc_proto_close in");
-	hdlc_close(sc->lmc_device);
-	lmc_trace(sc->lmc_device, "lmc_proto_close out");
-}
-
-__be16 lmc_proto_type(struct card *sc, struct sk_buff *skb)
-{
-	lmc_trace(sc->lmc_device, "lmc_proto_type in");
-	return hdlc_type_trans(skb, sc->lmc_device);
-	lmc_trace(sc->lmc_device, "lmc_proto_tye out");
-}
-
-void lmc_proto_netif(struct card *sc, struct sk_buff *skb)
-{
-	lmc_trace(sc->lmc_device, "lmc_proto_netif in");
-	netif_rx(skb);
-	lmc_trace(sc->lmc_device, "lmc_proto_netif out");
-}
diff --git a/drivers/net/wan/lmc/proto.h b/drivers/net/wan/lmc/proto.h
deleted file mode 100644
index 23094ed..0000000
--- a/drivers/net/wan/lmc/proto.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#ifndef _LMC_PROTO_H_
-#define _LMC_PROTO_H_
-
-#include <linux/hdlc.h>
-
-void lmc_proto_attach(struct card *sc);
-int lmc_proto_ioctl(struct card *sc, struct ifreq *ifr, int cmd);
-int lmc_proto_open(struct card *sc);
-void lmc_proto_close(struct card *sc);
-__be16 lmc_proto_type(struct card *sc, struct sk_buff *skb);
-void lmc_proto_netif(struct card *sc, struct sk_buff *skb);
-
-static inline struct card* dev_to_sc(struct net_device *dev)
-{
-	return (struct card *)dev_to_hdlc(dev)->priv;
-}
-
-#endif
--=20
1.7.1.1

