From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(16/20): Limit MTU to 1500 bytes unless connected at GigE speed
Date: Mon, 28 Mar 2005 16:57:58 -0700
Message-ID: <20050328235758.GP29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
@@ -1536,6 +1539,15 @@
 			netif_wake_queue(dev);
 			/* Start TX queue */
 			mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
+			/* Chip only supports jumbo frames at 1Gb/S */
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
@@ -2220,10 +2232,22 @@
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned long flags;
+	int max_mtu;
+	u32 port_status;
 
 	spin_lock_irqsave(&mp->lock, flags);
 
-	if ((new_mtu > 9500) || (new_mtu < 64)) {
+	/* Jumbo frames are not supported when connected at less than 1Gb/S */
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
@@ -2517,9 +2541,9 @@
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
