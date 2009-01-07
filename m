From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 41/42] atp: convert to net_device_ops
Date: Tue, 06 Jan 2009 16:33:57 -0800
Message-ID: <20090107003349.884794895@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60728 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756869AbZAGAyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:17 -0500
Content-Disposition: inline; filename=atp.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/atp.c	2009-01-05 14:54:20.114569210 -0800
+++ b/drivers/net/atp.c	2009-01-05 14:58:55.166569651 -0800
@@ -204,8 +204,7 @@ static irqreturn_t atp_interrupt(int irq
 static void net_rx(struct net_device *dev);
 static void read_block(long ioaddr, int length, unsigned char *buffer, int data_mode);
 static int net_close(struct net_device *dev);
-static void set_rx_mode_8002(struct net_device *dev);
-static void set_rx_mode_8012(struct net_device *dev);
+static void set_rx_mode(struct net_device *dev);
 static void tx_timeout(struct net_device *dev);
 
 
@@ -242,6 +241,17 @@ static int __init atp_init(void)
 	return -ENODEV;
 }
 
+static const struct net_device_ops atp_netdev_ops = {
+	.ndo_open		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_start_xmit		= atp_send_packet,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_tx_timeout		= tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init atp_probe1(long ioaddr)
 {
 	struct net_device *dev = NULL;
@@ -342,12 +352,7 @@ static int __init atp_probe1(long ioaddr
 	if (dev->mem_end & 0xf)
 		net_debug = dev->mem_end & 7;
 
-	dev->open		= net_open;
-	dev->stop		= net_close;
-	dev->hard_start_xmit	= atp_send_packet;
-	dev->set_multicast_list =
-	  lp->chip_type == RTL8002 ? &set_rx_mode_8002 : &set_rx_mode_8012;
-	dev->tx_timeout		= tx_timeout;
+	dev->netdev_ops 	= &atp_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 
 	res = register_netdev(dev);
@@ -903,6 +908,17 @@ static void set_rx_mode_8012(struct net_
     write_reg(ioaddr, CMR2, CMR2_IRQOUT); /* Switch back to page 0 */
 }
 
+static void set_rx_mode(struct net_device *dev)
+{
+	struct net_local *lp = netdev_priv(dev);
+
+	if (lp->chip_type == RTL8002)
+		return set_rx_mode_8002(dev);
+	else
+		return set_rx_mode_8012(dev);
+}
+
+
 static int __init atp_init_module(void) {
 	if (debug)					/* Emit version even if no cards detected. */
 		printk(KERN_INFO "%s", version);

-- 

