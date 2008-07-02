From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Remove dead code from PC300 driver, part #1
Date: Wed, 02 Jul 2008 21:15:27 +0200
Message-ID: <m3od5g3xo0.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58651 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbYGBTX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

WAN: Remove dead code from PC300 driver, part #1

diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 63e9fcf..cd24ea5 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -100,7 +100,6 @@
 #define	_PC300_H
 
 #include <linux/hdlc.h>
-#include <net/syncppp.h>
 #include "hd64572.h"
 #include "pc300-falc-lh.h"
 
@@ -112,19 +111,11 @@ typedef	__u16	ucshort;	/* 16 bits, unsigned */
 typedef	__u8	ucchar;		/* 8 bits, unsigned */
 #endif /* CY_TYPES */
 
-#define PC300_PROTO_MLPPP 1		
+#define PC300_PROTO_MLPPP 1
 
-#define PC300_KERNEL	"2.4.x"	/* Kernel supported by this driver */
-
-#define	PC300_DEVNAME	"hdlc"	/* Dev. name base (for hdlc0, hdlc1, etc.) */
-#define PC300_MAXINDEX	100	/* Max dev. name index (the '0' in hdlc0) */
-
-#define	PC300_MAXCARDS	4	/* Max number of cards per system */
 #define	PC300_MAXCHAN	2	/* Number of channels per card */
 
-#define	PC300_PLX_WIN	0x80    /* PLX control window size (128b) */
 #define	PC300_RAMSIZE	0x40000 /* RAM window size (256Kb) */
-#define	PC300_SCASIZE	0x400   /* SCA window size (1Kb) */
 #define	PC300_FALCSIZE	0x400	/* FALC window size (1Kb) */
 
 #define PC300_OSC_CLOCK	24576000
@@ -160,7 +151,6 @@ typedef	__u8	ucchar;		/* 8 bits, unsigned */
  * Memory access functions/macros      *
  * (required to support Alpha systems) *
  ***************************************/
-#ifdef __KERNEL__
 #define cpc_writeb(port,val)	{writeb((ucchar)(val),(port)); mb();}
 #define cpc_writew(port,val)	{writew((ushort)(val),(port)); mb();}
 #define cpc_writel(port,val)	{writel((uclong)(val),(port)); mb();}
@@ -169,17 +159,6 @@ typedef	__u8	ucchar;		/* 8 bits, unsigned */
 #define cpc_readw(port)		readw(port)
 #define cpc_readl(port)		readl(port)
 
-#else /* __KERNEL__ */
-#define cpc_writeb(port,val)	(*(volatile ucchar *)(port) = (ucchar)(val))
-#define cpc_writew(port,val)	(*(volatile ucshort *)(port) = (ucshort)(val))
-#define cpc_writel(port,val)	(*(volatile uclong *)(port) = (uclong)(val))
-
-#define cpc_readb(port)		(*(volatile ucchar *)(port))
-#define cpc_readw(port)		(*(volatile ucshort *)(port))
-#define cpc_readl(port)		(*(volatile uclong *)(port))
-
-#endif /* __KERNEL__ */
-
 /****** Data Structures *****************************************************/
 
 /*
@@ -321,24 +300,15 @@ typedef struct pc300patterntst {
 } pc300patterntst_t;
 
 typedef struct pc300dev {
-	void *if_ptr;		/* General purpose pointer */
 	struct pc300ch *chan;
 	ucchar trace_on;
 	uclong line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
 	uclong line_off;
-#ifdef __KERNEL__
 	char name[16];
 	struct net_device *dev;
-
-	void *private;
-	struct sk_buff *tx_skb;
-	union {	/* This union has all the protocol-specific structures */
-		struct ppp_device pppdev;
-	}ifu;
 #ifdef CONFIG_PC300_MLPPP
 	void *cpc_tty;	/* information to PC300 TTY driver */
 #endif
-#endif /* __KERNEL__ */
 }pc300dev_t;
 
 typedef struct pc300hw {
@@ -401,9 +371,7 @@ typedef struct pc300ch {
 typedef struct pc300 {
 	pc300hw_t hw;			/* hardware config. */
 	pc300ch_t chan[PC300_MAXCHAN];
-#ifdef __KERNEL__
 	spinlock_t card_lock;
-#endif /* __KERNEL__ */
 } pc300_t;
 
 typedef struct pc300conf {
@@ -471,12 +439,10 @@ enum pc300_loopback_cmds {
 #define PC300_TX_QUEUE_LEN	100
 #define	PC300_DEF_MTU		1600
 
-#ifdef __KERNEL__
 /* Function Prototypes */
 void tx_dma_start(pc300_t *, int);
 int cpc_open(struct net_device *dev);
 int cpc_set_media(hdlc_device *, int);
-#endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
 
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 694df44..3226a74 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -3150,19 +3150,10 @@ int cpc_open(struct net_device *dev)
 	printk("pc300: cpc_open");
 #endif
 
-#ifdef FIXME
-	if (hdlc->proto.id == IF_PROTO_PPP) {
-		d->if_ptr = &hdlc->state.ppp.pppdev;
-	}
-#endif
-
 	result = hdlc_open(dev);
-	if (/* FIXME hdlc->proto.id == IF_PROTO_PPP*/ 0) {
-		dev->priv = d;
-	}
-	if (result) {
+
+	if (result)
 		return result;
-	}
 
 	sprintf(ifr.ifr_name, "%s", dev->name);
 	result = cpc_opench(d);
@@ -3195,9 +3186,7 @@ static int cpc_close(struct net_device *dev)
 	CPC_UNLOCK(card, flags);
 
 	hdlc_close(dev);
-	if (/* FIXME hdlc->proto.id == IF_PROTO_PPP*/ 0) {
-		d->if_ptr = NULL;
-	}
+
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
 		cpc_tty_unregister_service(d);
@@ -3358,7 +3347,6 @@ static void cpc_init_card(pc300_t * card)
 		chan->nfree_tx_bd = N_DMA_TX_BUF;
 
 		d->chan = chan;
-		d->tx_skb = NULL;
 		d->trace_on = 0;
 		d->line_on = 0;
 		d->line_off = 0;

-- 
Krzysztof Halasa
