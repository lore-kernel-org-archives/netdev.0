From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ofa-general] [PATCH 03/77] infiniband: convert c2 to net_device_ops
Date: Fri, 20 Mar 2009 22:35:30 -0700
Message-ID: <20090321053712.797092692@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>, tom@opengridcomputing.com,
	swise@opengridcomputing.com
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline; filename=infiniband-c2.patch
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

Convert this driver to new net_device_ops infrastructure.
Also use default net_device get-stats infrastructure

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/infiniband/hw/amso1100/c2.c          |   41 ++++++++++++---------------
 drivers/infiniband/hw/amso1100/c2.h          |    2 -
 drivers/infiniband/hw/amso1100/c2_provider.c |   22 +++++++-------
 3 files changed, 30 insertions(+), 35 deletions(-)

--- a/drivers/infiniband/hw/amso1100/c2.c	2009-03-19 22:40:30.574963980 -0700
+++ b/drivers/infiniband/hw/amso1100/c2.c	2009-03-19 22:42:42.388718732 -0700
@@ -76,7 +76,6 @@ static irqreturn_t c2_interrupt(int irq,
 static void c2_tx_timeout(struct net_device *netdev);
 static int c2_change_mtu(struct net_device *netdev, int new_mtu);
 static void c2_reset(struct c2_port *c2_port);
-static struct net_device_stats *c2_get_stats(struct net_device *netdev);
 
 static struct pci_device_id c2_pci_table[] = {
 	{ PCI_DEVICE(0x18b8, 0xb001) },
@@ -349,7 +348,7 @@ static void c2_tx_clean(struct c2_port *
 					     elem->hw_desc + C2_TXP_ADDR);
 				__raw_writew((__force u16) cpu_to_be16(TXP_HTXD_DONE),
 					     elem->hw_desc + C2_TXP_FLAGS);
-				c2_port->netstats.tx_dropped++;
+				c2_port->netdev->stats.tx_dropped++;
 				break;
 			} else {
 				__raw_writew(0,
@@ -457,7 +456,7 @@ static void c2_rx_error(struct c2_port *
 		     elem->hw_desc + C2_RXP_FLAGS);
 
 	pr_debug("packet dropped\n");
-	c2_port->netstats.rx_dropped++;
+	c2_port->netdev->stats.rx_dropped++;
 }
 
 static void c2_rx_interrupt(struct net_device *netdev)
@@ -532,8 +531,8 @@ static void c2_rx_interrupt(struct net_d
 		netif_rx(skb);
 
 		netdev->last_rx = jiffies;
-		c2_port->netstats.rx_packets++;
-		c2_port->netstats.rx_bytes += buflen;
+		netdev->stats.rx_packets++;
+		netdev->stats.rx_bytes += buflen;
 	}
 
 	/* Save where we left off */
@@ -797,8 +796,8 @@ static int c2_xmit_frame(struct sk_buff 
 	__raw_writew((__force u16) cpu_to_be16(TXP_HTXD_READY),
 		     elem->hw_desc + C2_TXP_FLAGS);
 
-	c2_port->netstats.tx_packets++;
-	c2_port->netstats.tx_bytes += maplen;
+	netdev->stats.tx_packets++;
+	netdev->stats.tx_bytes += maplen;
 
 	/* Loop thru additional data fragments and queue them */
 	if (skb_shinfo(skb)->nr_frags) {
@@ -823,8 +822,8 @@ static int c2_xmit_frame(struct sk_buff 
 			__raw_writew((__force u16) cpu_to_be16(TXP_HTXD_READY),
 				     elem->hw_desc + C2_TXP_FLAGS);
 
-			c2_port->netstats.tx_packets++;
-			c2_port->netstats.tx_bytes += maplen;
+			netdev->stats.tx_packets++;
+			netdev->stats.tx_bytes += maplen;
 		}
 	}
 
@@ -845,13 +844,6 @@ static int c2_xmit_frame(struct sk_buff 
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *c2_get_stats(struct net_device *netdev)
-{
-	struct c2_port *c2_port = netdev_priv(netdev);
-
-	return &c2_port->netstats;
-}
-
 static void c2_tx_timeout(struct net_device *netdev)
 {
 	struct c2_port *c2_port = netdev_priv(netdev);
@@ -880,6 +872,16 @@ static int c2_change_mtu(struct net_devi
 	return ret;
 }
 
+static const struct net_device_ops c2_netdev = {
+	.ndo_open 		= c2_up,
+	.ndo_stop 		= c2_down,
+	.ndo_start_xmit		= c2_xmit_frame,
+	.ndo_tx_timeout		= c2_tx_timeout,
+	.ndo_change_mtu		= c2_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* Initialize network device */
 static struct net_device *c2_devinit(struct c2_dev *c2dev,
 				     void __iomem * mmio_addr)
@@ -894,12 +896,7 @@ static struct net_device *c2_devinit(str
 
 	SET_NETDEV_DEV(netdev, &c2dev->pcidev->dev);
 
-	netdev->open = c2_up;
-	netdev->stop = c2_down;
-	netdev->hard_start_xmit = c2_xmit_frame;
-	netdev->get_stats = c2_get_stats;
-	netdev->tx_timeout = c2_tx_timeout;
-	netdev->change_mtu = c2_change_mtu;
+	netdev->netdev_ops = &c2_netdev;
 	netdev->watchdog_timeo = C2_TX_TIMEOUT;
 	netdev->irq = c2dev->pcidev->irq;
 
--- a/drivers/infiniband/hw/amso1100/c2.h	2009-03-19 22:40:30.587964264 -0700
+++ b/drivers/infiniband/hw/amso1100/c2.h	2009-03-19 22:42:42.389902290 -0700
@@ -369,8 +369,6 @@ struct c2_port {
 	unsigned long mem_size;
 
 	u32 rx_buf_size;
-
-	struct net_device_stats netstats;
 };
 
 /*
--- a/drivers/infiniband/hw/amso1100/c2_provider.c	2009-03-19 22:40:30.579963953 -0700
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c	2009-03-19 22:42:42.389902290 -0700
@@ -708,26 +708,27 @@ static int c2_pseudo_xmit_frame(struct s
 
 static int c2_pseudo_change_mtu(struct net_device *netdev, int new_mtu)
 {
-	int ret = 0;
-
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
 	netdev->mtu = new_mtu;
 
 	/* TODO: Tell rnic about new rmda interface mtu */
-	return ret;
+	return 0;
 }
 
+static const struct net_device_ops c2_pseudo_netdev_ops = {
+	.ndo_open 		= c2_pseudo_up,
+	.ndo_stop 		= c2_pseudo_down,
+	.ndo_start_xmit 	= c2_pseudo_xmit_frame,
+	.ndo_change_mtu 	= c2_pseudo_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
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
+	netdev->netdev_ops = &c2_pseudo_netdev_ops;
+
 	netdev->watchdog_timeo = 0;
 	netdev->type = ARPHRD_ETHER;
 	netdev->mtu = 1500;
@@ -735,7 +736,6 @@ static void setup(struct net_device *net
 	netdev->addr_len = ETH_ALEN;
 	netdev->tx_queue_len = 0;
 	netdev->flags |= IFF_NOARP;
-	return;
 }
 
 static struct net_device *c2_pseudo_netdev_init(struct c2_dev *c2dev)

-- 
