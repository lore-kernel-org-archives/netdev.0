From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: mv643xx(16/20): Limit MTU to 1500 bytes unless connected at GigE speed
Date: Wed, 30 Mar 2005 14:46:45 -0700
Message-ID: <20050330214645.GA12409@xyzzy>
References: <20050328233807.GA28423@xyzzy> <20050328235758.GP29098@xyzzy> <424B076E.4080508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <424B076E.4080508@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 08:09:18PM +0000, Jeff Garzik wrote:
> Explanation?
> 
> I see no inherent reason to disallow jumbo frames at slower speeds.

Neither do I, but Marvell chips aren't always reasonable.

I guess my comments in the code:
	/* Chip only supports jumbo frames at 1Gb/S */
and
	/* Jumbo frames are not supported when connected at less than 1Gb/S */
may have been a bit too terse. :)

I expanded on the comments and rebuilt the repository.  The new version
of this patch is included below.  (No code has changed, only comments.)
I have found no other mention of this limitation in the Marvell
documentation other than what is found below.

Thanks,
-Dale


mv643xx: Limit MTU to 1500 bytes unless connected at GigE speed

It's weird, but the user manual says that jumbo frames are not
supported at less than 1Gb/S.  From the description of the MRU
field of the PSCR:

        The Maximal Receive Packet Size:
        0 = Accept packets up to 1518 bytes in length
        1 = Accept packets up to 1522 bytes in length
        2 = Accept packets up to 1558 bytes in length
        3 = Accept packets up to 9022 bytes in length
        4 = Accept packets up to 9192 bytes in length
        5 = Accept packets up to 9700 bytes in length
        6-7 = Reserved

        Note:   Modes 3-5 are supported only when operating in 1000 Mbps.
                Receiving 9700 byte frames is supported only during 1000 
                Mbps operation.  Receiving frames over 2KB during 100 Mbps
                operation may result in overrun/underrun in some cases.

In this patch, we only permit jumbo frames when connecting/connected
at 1Gb/S.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -371,6 +371,7 @@
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 	int tx_curr_desc, rx_curr_desc;
+	int rx_buffer_size_index;
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
@@ -398,14 +399,16 @@
 	mv643xx_eth_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
 	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), 0);
 
-	/* Increase the Rx side buffer size if supporting GigE */
-	if (mp->port_serial_control & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
-		mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-				  (mp->port_serial_control & 0xfff1ffff) |
-				  (0x5 << 17));
+	/* Adjust Rx side buffer size based on mtu */
+	if (dev->mtu <= 1500)
+		rx_buffer_size_index = 1;
 	else
-		mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-				  mp->port_serial_control);
+		rx_buffer_size_index = 5;
+	mp->port_serial_control &= 0xfff1ffff;
+	mp->port_serial_control |= rx_buffer_size_index << 17;
+
+	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+			  mp->port_serial_control);
 
 	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
 			  mp->port_serial_control |
@@ -1289,13 +1292,13 @@
 		printk(KERN_INFO "%s: TX timeout  ", dev->name);
 
 	/* Do the reset outside of interrupt context */
-	schedule_work(&mp->tx_timeout_task);
+	schedule_work(&mp->reset_task);
 }
 
 /*
  * Actual routine to reset the adapter when a timeout on Tx has occurred
  */
-static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
+static void mv643xx_eth_reset_task(struct net_device *dev)
 {
 	netif_device_detach(dev);
 	mv643xx_eth_port_reset(dev);
@@ -1536,6 +1539,19 @@
 			netif_wake_queue(dev);
 			/* Start TX queue */
 			mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
+			/*
+			 * The mv643xx user manuals (in the PSCR MRU field
+			 * description) say that jumbo frames are not reliable
+			 * at 10Mb/S or 100Mb/S, so we disallow them.
+			 */
+			if (cmd.speed != SPEED_1000 && dev->mtu > 1500) {
+				dev->mtu = 1500;
+				mp->port_serial_control &= 0xfff1ffff;
+				mp->port_serial_control |= 1 << 17;
+
+				/* Do the reset outside of interrupt context */
+				schedule_work(&mp->reset_task);
+			}
 
 		} else if (!mii_link_ok(&mp->mii) && netif_carrier_ok(dev)) {
 			netif_stop_queue(dev);
@@ -2220,10 +2236,26 @@
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned long flags;
+	int max_mtu;
+	u32 port_status;
 
 	spin_lock_irqsave(&mp->lock, flags);
 
-	if ((new_mtu > 9500) || (new_mtu < 64)) {
+	/*
+	 * The mv643xx user manuals (in the PSCR MRU field
+	 * description) say that jumbo frames are not reliable
+	 * at 10Mb/S or 100Mb/S, so we disallow them.
+	 */
+	port_status =
+		mv643xx_eth_read(MV643XX_ETH_PORT_STATUS_REG(mp->port_num));
+	if ((port_status & (MV643XX_ETH_PORT_STATUS_LINK_UP |
+			    MV643XX_ETH_PORT_STATUS_GMII_1000)) ==
+			   (MV643XX_ETH_PORT_STATUS_LINK_UP))
+		max_mtu = 1500;
+	else
+		max_mtu = 9500;
+
+	if ((new_mtu > max_mtu) || (new_mtu < 64)) {
 		spin_unlock_irqrestore(&mp->lock, flags);
 		return -EINVAL;
 	}
@@ -2517,9 +2549,9 @@
 #endif
 #endif
 
-	/* Configure the timeout task */
-	INIT_WORK(&mp->tx_timeout_task,
-		  (void (*)(void *))mv643xx_eth_tx_timeout_task, dev);
+	/* Configure the reset task */
+	INIT_WORK(&mp->reset_task,
+		  (void (*)(void *))mv643xx_eth_reset_task, dev);
 
 	spin_lock_init(&mp->lock);
 
Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -512,7 +512,7 @@
 	unsigned int tx_desc_area_size;
 	struct sk_buff **tx_skb;
 
-	struct work_struct tx_timeout_task;
+	struct work_struct reset_task;
 
 	/*
 	 * Former struct mv643xx_eth_priv members start here
