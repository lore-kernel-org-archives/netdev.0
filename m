From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 26/30] netdev: convert ni65 to net_device_ops
Date: Thu, 26 Mar 2009 18:11:40 -0700
Message-ID: <20090327011256.830948135@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46964 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763182AbZC0BfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:35:12 -0400
Content-Disposition: inline; filename=ni65.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, use internal net_device_stats.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ni65.c	2009-03-26 17:03:44.248604988 -0700
+++ b/drivers/net/ni65.c	2009-03-26 17:16:16.734599577 -0700
@@ -237,7 +237,7 @@ struct priv
 	void *tmdbounce[TMDNUM];
 	int tmdbouncenum;
 	int lock,xmit_queued;
-	struct net_device_stats stats;
+
 	void *self;
 	int cmdr_addr;
 	int cardno;
@@ -257,7 +257,6 @@ static void  ni65_timeout(struct net_dev
 static int  ni65_close(struct net_device *dev);
 static int  ni65_alloc_buffer(struct net_device *dev);
 static void ni65_free_buffer(struct priv *p);
-static struct net_device_stats *ni65_get_stats(struct net_device *);
 static void set_multicast_list(struct net_device *dev);
 
 static int irqtab[] __initdata = { 9,12,15,5 }; /* irq config-translate */
@@ -401,6 +400,17 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops ni65_netdev_ops = {
+	.ndo_open		= ni65_open,
+	.ndo_stop		= ni65_close,
+	.ndo_start_xmit		= ni65_send_packet,
+	.ndo_tx_timeout		= ni65_timeout,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*
  * this is the real card probe ..
  */
@@ -549,13 +559,9 @@ static int __init ni65_probe1(struct net
 	}
 
 	dev->base_addr = ioaddr;
-	dev->open		= ni65_open;
-	dev->stop		= ni65_close;
-	dev->hard_start_xmit	= ni65_send_packet;
-	dev->tx_timeout		= ni65_timeout;
+	dev->netdev_ops = &ni65_netdev_ops;
 	dev->watchdog_timeo	= HZ/2;
-	dev->get_stats		= ni65_get_stats;
-	dev->set_multicast_list = set_multicast_list;
+
 	return 0; /* everything is OK */
 }
 
@@ -901,13 +907,13 @@ static irqreturn_t ni65_interrupt(int ir
 			if(debuglevel > 1)
 				printk(KERN_ERR "%s: general error: %04x.\n",dev->name,csr0);
 			if(csr0 & CSR0_BABL)
-				p->stats.tx_errors++;
+				dev->stats.tx_errors++;
 			if(csr0 & CSR0_MISS) {
 				int i;
 				for(i=0;i<RMDNUM;i++)
 					printk("%02x ",p->rmdhead[i].u.s.status);
 				printk("\n");
-				p->stats.rx_errors++;
+				dev->stats.rx_errors++;
 			}
 			if(csr0 & CSR0_MERR) {
 				if(debuglevel > 1)
@@ -997,12 +1003,12 @@ static void ni65_xmit_intr(struct net_de
 #endif
 		 /* checking some errors */
 			if(tmdp->status2 & XMIT_RTRY)
-				p->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if(tmdp->status2 & XMIT_LCAR)
-				p->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if(tmdp->status2 & (XMIT_BUFF | XMIT_UFLO )) {
 		/* this stops the xmitter */
-				p->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 				if(debuglevel > 0)
 					printk(KERN_ERR "%s: Xmit FIFO/BUFF error\n",dev->name);
 				if(p->features & INIT_RING_BEFORE_START) {
@@ -1016,12 +1022,12 @@ static void ni65_xmit_intr(struct net_de
 			if(debuglevel > 2)
 				printk(KERN_ERR "%s: xmit-error: %04x %02x-%04x\n",dev->name,csr0,(int) tmdstat,(int) tmdp->status2);
 			if(!(csr0 & CSR0_BABL)) /* don't count errors twice */
-				p->stats.tx_errors++;
+				dev->stats.tx_errors++;
 			tmdp->status2 = 0;
 		}
 		else {
-			p->stats.tx_bytes -= (short)(tmdp->blen);
-			p->stats.tx_packets++;
+			dev->stats.tx_bytes -= (short)(tmdp->blen);
+			dev->stats.tx_packets++;
 		}
 
 #ifdef XMT_VIA_SKB
@@ -1057,7 +1063,7 @@ static void ni65_recv_intr(struct net_de
 			if(!(rmdstat & RCV_ERR)) {
 				if(rmdstat & RCV_START)
 				{
-					p->stats.rx_length_errors++;
+					dev->stats.rx_length_errors++;
 					printk(KERN_ERR "%s: recv, packet too long: %d\n",dev->name,rmdp->mlen & 0x0fff);
 				}
 			}
@@ -1066,16 +1072,16 @@ static void ni65_recv_intr(struct net_de
 					printk(KERN_ERR "%s: receive-error: %04x, lance-status: %04x/%04x\n",
 									dev->name,(int) rmdstat,csr0,(int) inw(PORT+L_DATAREG) );
 				if(rmdstat & RCV_FRAM)
-					p->stats.rx_frame_errors++;
+					dev->stats.rx_frame_errors++;
 				if(rmdstat & RCV_OFLO)
-					p->stats.rx_over_errors++;
+					dev->stats.rx_over_errors++;
 				if(rmdstat & RCV_CRC)
-					p->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 				if(rmdstat & RCV_BUF_ERR)
-					p->stats.rx_fifo_errors++;
+					dev->stats.rx_fifo_errors++;
 			}
 			if(!(csr0 & CSR0_MISS)) /* don't count errors twice */
-				p->stats.rx_errors++;
+				dev->stats.rx_errors++;
 		}
 		else if( (len = (rmdp->mlen & 0x0fff) - 4) >= 60)
 		{
@@ -1106,20 +1112,20 @@ static void ni65_recv_intr(struct net_de
 				skb_put(skb,len);
 				skb_copy_to_linear_data(skb, (unsigned char *) p->recvbounce[p->rmdnum],len);
 #endif
-				p->stats.rx_packets++;
-				p->stats.rx_bytes += len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += len;
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
 			}
 			else
 			{
 				printk(KERN_ERR "%s: can't alloc new sk_buff\n",dev->name);
-				p->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		}
 		else {
 			printk(KERN_INFO "%s: received runt packet\n",dev->name);
-			p->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 		rmdp->blen = -(R_BUF_SIZE-8);
 		rmdp->mlen = 0;
@@ -1213,23 +1219,6 @@ static int ni65_send_packet(struct sk_bu
 	return 0;
 }
 
-static struct net_device_stats *ni65_get_stats(struct net_device *dev)
-{
-
-#if 0
-	int i;
-	struct priv *p = dev->ml_priv;
-	for(i=0;i<RMDNUM;i++)
-	{
-		struct rmd *rmdp = p->rmdhead + ((p->rmdnum + i) & (RMDNUM-1));
-		printk("%02x ",rmdp->u.s.status);
-	}
-	printk("\n");
-#endif
-
-	return &((struct priv *)dev->ml_priv)->stats;
-}
-
 static void set_multicast_list(struct net_device *dev)
 {
 	if(!ni65_lance_reinit(dev))


