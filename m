From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH RESEND net 4/9] net/mac89x0: Replace custom debug logging with
 netif_* calls
Date: Mon,  2 Oct 2017 21:07:18 -0400 (EDT)
Message-ID: <433dfc32eecb5c24d1cd11894f28da873589d27d.1506992619.git.fthain@telegraphics.com.au>
References: <cover.1506992619.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1506992619.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/cirrus/mac89x0.c | 47 ++++++++++++-----------------------
 1 file changed, 16 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index 4393d9b89f33..278df230c5f6 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -61,18 +61,6 @@
 static const char version[] =
 "cs89x0.c:v1.02 11/26/96 Russell Nelson <nelson@crynwr.com>\n";
 
-/* ======================= configure the driver here ======================= */
-
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifndef NET_DEBUG
-#define NET_DEBUG 0
-#endif
-
-/* ======================= end of configuration ======================= */
-
-
-/* Always include 'config.h' first in case the user wants to turn on
-   or override something. */
 #include <linux/module.h>
 
 /*
@@ -107,10 +95,13 @@ static const char version[] =
 
 #include "cs89x0.h"
 
-static unsigned int net_debug = NET_DEBUG;
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "debug message level");
 
 /* Information that need to be kept for each board. */
 struct net_local {
+	int msg_enable;
 	int chip_type;		/* one of: CS8900, CS8920, CS8920M */
 	char chip_revision;	/* revision letter of the chip ('A'...) */
 	int send_cmd;		/* the propercommand used to send a packet. */
@@ -174,7 +165,6 @@ struct net_device * __init mac89x0_probe(int unit)
 {
 	struct net_device *dev;
 	struct net_local *lp;
-	static unsigned version_printed;
 	int i, slot;
 	unsigned rev_type = 0;
 	unsigned long ioaddr;
@@ -220,6 +210,8 @@ struct net_device * __init mac89x0_probe(int unit)
 	/* Initialize the net_device structure. */
 	lp = netdev_priv(dev);
 
+	lp->msg_enable = netif_msg_init(debug, 0);
+
 	/* Fill in the 'dev' fields. */
 	dev->base_addr = ioaddr;
 	dev->mem_start = (unsigned long)
@@ -242,8 +234,7 @@ struct net_device * __init mac89x0_probe(int unit)
 	if (lp->chip_type != CS8900 && lp->chip_revision >= 'C')
 		lp->send_cmd = TX_NOW;
 
-	if (net_debug && version_printed++ == 0)
-		printk(version);
+	netif_dbg(lp, drv, dev, "%s", version);
 
 	pr_info("CS89%c0%s rev %c found at %#8lx\n",
 	        lp->chip_type == CS8900 ? '0' : '2',
@@ -340,11 +331,9 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
-	if (net_debug > 3)
-		printk("%s: sent %d byte packet of type %x\n",
-		       dev->name, skb->len,
-		       (skb->data[ETH_ALEN+ETH_ALEN] << 8)
-		       | skb->data[ETH_ALEN+ETH_ALEN+1]);
+	netif_dbg(lp, tx_queued, dev, "sent %d byte packet of type %x\n",
+	          skb->len, skb->data[ETH_ALEN + ETH_ALEN] << 8 |
+	                    skb->data[ETH_ALEN + ETH_ALEN + 1]);
 
 	/* keep the upload from being interrupted, since we
 	   ask the chip to start transmitting before the
@@ -393,7 +382,7 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
            faster than you can read them off, you're screwed.  Hasta la
            vista, baby!  */
 	while ((status = swab16(nubus_readw(dev->base_addr + ISQ_PORT)))) {
-		if (net_debug > 4)printk("%s: event=%04x\n", dev->name, status);
+		netif_dbg(lp, intr, dev, "status=%04x\n", status);
 		switch(status & ISQ_EVENT_MASK) {
 		case ISQ_RECEIVER_EVENT:
 			/* Got a packet(s). */
@@ -423,7 +412,7 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 				netif_wake_queue(dev);
 			}
 			if (status & TX_UNDERRUN) {
-				if (net_debug > 0) printk("%s: transmit underrun\n", dev->name);
+				netif_dbg(lp, tx_err, dev, "transmit underrun\n");
                                 lp->send_underrun++;
                                 if (lp->send_underrun == 3) lp->send_cmd = TX_AFTER_381;
                                 else if (lp->send_underrun == 6) lp->send_cmd = TX_AFTER_ALL;
@@ -444,6 +433,7 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 static void
 net_rx(struct net_device *dev)
 {
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 
@@ -475,10 +465,9 @@ net_rx(struct net_device *dev)
 	skb_copy_to_linear_data(skb, (void *)(dev->mem_start + PP_RxFrame),
 				length);
 
-	if (net_debug > 3)printk("%s: received %d byte packet of type %x\n",
-                                 dev->name, length,
-                                 (skb->data[ETH_ALEN+ETH_ALEN] << 8)
-				 | skb->data[ETH_ALEN+ETH_ALEN+1]);
+	netif_dbg(lp, rx_status, dev, "received %d byte packet of type %x\n",
+	          length, skb->data[ETH_ALEN + ETH_ALEN] << 8 |
+	                  skb->data[ETH_ALEN + ETH_ALEN + 1]);
 
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
@@ -566,16 +555,12 @@ static int set_mac_address(struct net_device *dev, void *addr)
 #ifdef MODULE
 
 static struct net_device *dev_cs89x0;
-static int debug;
 
-module_param(debug, int, 0);
-MODULE_PARM_DESC(debug, "CS89[02]0 debug level (0-5)");
 MODULE_LICENSE("GPL");
 
 int __init
 init_module(void)
 {
-	net_debug = debug;
         dev_cs89x0 = mac89x0_probe(-1);
 	if (IS_ERR(dev_cs89x0)) {
 		pr_warn("No card found\n");
-- 
2.13.5
