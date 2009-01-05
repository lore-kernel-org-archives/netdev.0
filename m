From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ofa-general] [PATCH 1/3] infiniband: amso100 convert to
	net_device_ops
Date: Mon, 5 Jan 2009 13:22:11 -0800
Message-ID: <20090105132211.70baefb9@extreme>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.828840735@vyatta.com> <adawsd9mppk.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adawsd9mppk.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Convert to net_device_ops and remove leftover last_rx.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/infiniband/hw/amso1100/c2.c	2009-01-05 13:14:20.990323888 -0800
+++ b/drivers/infiniband/hw/amso1100/c2.c	2009-01-05 13:16:48.581570680 -0800
@@ -76,7 +76,6 @@ static irqreturn_t c2_interrupt(int irq,
 static void c2_tx_timeout(struct net_device *netdev);
 static int c2_change_mtu(struct net_device *netdev, int new_mtu);
 static void c2_reset(struct c2_port *c2_port);
-static struct net_device_stats *c2_get_stats(struct net_device *netdev);
 
 static struct pci_device_id c2_pci_table[] = {
 	{ PCI_DEVICE(0x18b8, 0xb001) },
@@ -531,7 +530,6 @@ static void c2_rx_interrupt(struct net_d
 
 		netif_rx(skb);
 
-		netdev->last_rx = jiffies;
 		c2_port->netstats.rx_packets++;
 		c2_port->netstats.rx_bytes += buflen;
 	}
@@ -880,6 +878,17 @@ static int c2_change_mtu(struct net_devi
 	return ret;
 }
 
+static const struct net_device_ops c2_netdev_ops = {
+	.ndo_open 	     = c2_up,
+	.ndo_stop	     = c2_down,
+	.ndo_start_xmit      = c2_xmit_frame,
+	.ndo_get_stats	     = c2_get_stats,
+	.ndo_tx_timeout	     = c2_tx_timeout,
+	.ndo_change_mtu	     = c2_change_mtu,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_validate_addr   = eth_validate_addr,
+};
+
 /* Initialize network device */
 static struct net_device *c2_devinit(struct c2_dev *c2dev,
 				     void __iomem * mmio_addr)
@@ -894,12 +903,7 @@ static struct net_device *c2_devinit(str
 
 	SET_NETDEV_DEV(netdev, &c2dev->pcidev->dev);
 
-	netdev->open = c2_up;
-	netdev->stop = c2_down;
-	netdev->hard_start_xmit = c2_xmit_frame;
-	netdev->get_stats = c2_get_stats;
-	netdev->tx_timeout = c2_tx_timeout;
-	netdev->change_mtu = c2_change_mtu;
+	netdev->netdev_ops = &c2_netdev_ops;
 	netdev->watchdog_timeo = C2_TX_TIMEOUT;
 	netdev->irq = c2dev->pcidev->irq;
 
--- a/drivers/infiniband/hw/amso1100/c2_provider.c	2009-01-05 13:14:20.978323767 -0800
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c	2009-01-05 13:17:09.911803913 -0800
@@ -719,15 +719,16 @@ static int c2_pseudo_change_mtu(struct n
 	return ret;
 }
 
+static const struct net_device_ops c2_netdev_ops = {
+	.ndo_open       = c2_pseudo_up,
+	.ndo_stop       = c2_pseudo_down,
+	.ndo_start_xmit = c2_pseudo_xmit_frame,
+	.ndo_change_mtu = c2_pseudo_change_mtu,
+};
+
 static void setup(struct net_device *netdev)
 {
-	netdev->open = c2_pseudo_up;
-	netdev->stop = c2_pseudo_down;
-	netdev->hard_start_xmit = c2_pseudo_xmit_frame;
-	netdev->get_stats = NULL;
-	netdev->tx_timeout = NULL;
-	netdev->set_mac_address = NULL;
-	netdev->change_mtu = c2_pseudo_change_mtu;
+	netdev->netdev_ops = &c2_netdev_ops;
 	netdev->watchdog_timeo = 0;
 	netdev->type = ARPHRD_ETHER;
 	netdev->mtu = 1500;
