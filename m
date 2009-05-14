From: David Dillow <dave@thedillows.org>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Wed, 13 May 2009 22:38:29 -0400
Message-ID: <1242268709.4979.7.camel@obelisk.thedillows.org>
References: <200903041828.49972.m.bueker@berlin.de>
	 <1242001754.4093.12.camel@obelisk.thedillows.org>
	 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
	 <1242077392.3716.15.camel@lap75545.ornl.gov>
	 <4A09DC3E.2080807@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:56583 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbZENCij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 22:38:39 -0400
In-Reply-To: <4A09DC3E.2080807@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-05-12 at 22:29 +0200, Michael Riepe wrote:
> Hi!
> 
> David Dillow wrote:
> 
> > I was saying that I don't think the timeouts are necessarily the NIC
> > chipset -- or the bridge chip for that matter --  having issues with
> > MSI. There were some substantial IRQ handling changes in 2.6.28 and my
> > bisection of the problem seem to lead into that code. I'll try this
> > later tonight hopefully, but can you try to run 2.6.27 with the current
> > r8169 driver and see if it is solid for you? That way it is using the
> > same driver code, but avoids the IRQ changes.
> 
> Unfortunately, 2.6.27 won't build with r8169.c copied from 2.6.29.

You are correct, and I should have thought about that. The following
patch reverts the following commits:

288379 net: Remove redundant NAPI functions
908a7a net: Remove unused netdev arg from some NAPI interfaces.
008298 netdev: add more functions to netdevice ops
8b4ab2 r8169: convert to net_device_ops
babcda drivers/net: Kill now superfluous ->last_rx stores.

The patched driver runs on 2.6.27 and survives my 5 minutes 'dd
if=/dev/zero bs=1024k | nc target 9000' test which usually dies in less
than 90 seconds on 2.6.28+.

To use the patch, just copy r8169.c from HEAD and use patch -p1.


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0b6e8c8..2d751bf 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -490,7 +490,6 @@ struct rtl8169_private {
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
-	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
 	int pcie_cap;
 	struct delayed_work task;
 	unsigned features;
@@ -1850,11 +1849,9 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 
-	return netif_running(dev) ? tp->do_ioctl(tp, data, cmd) : -ENODEV;
-}
+	if (!netif_running(dev))
+		return -ENODEV;
 
-static int rtl_xmii_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd)
-{
 	switch (cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id = 32; /* Internal PHY */
@@ -1873,11 +1870,6 @@ static int rtl_xmii_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *dat
 	return -EOPNOTSUPP;
 }
 
-static int rtl_tbi_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd)
-{
-	return -EOPNOTSUPP;
-}
-
 static const struct rtl_cfg_info {
 	void (*hw_start)(struct net_device *);
 	unsigned int region;
@@ -1943,26 +1935,6 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 	}
 }
 
-static const struct net_device_ops rtl8169_netdev_ops = {
-	.ndo_open		= rtl8169_open,
-	.ndo_stop		= rtl8169_close,
-	.ndo_get_stats		= rtl8169_get_stats,
-	.ndo_start_xmit		= rtl8169_start_xmit,
-	.ndo_tx_timeout		= rtl8169_tx_timeout,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= rtl8169_change_mtu,
-	.ndo_set_mac_address	= rtl_set_mac_address,
-	.ndo_do_ioctl		= rtl8169_ioctl,
-	.ndo_set_multicast_list	= rtl_set_rx_mode,
-#ifdef CONFIG_R8169_VLAN
-	.ndo_vlan_rx_register	= rtl8169_vlan_rx_register,
-#endif
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= rtl8169_netpoll,
-#endif
-
-};
-
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1989,7 +1961,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->netdev_ops = &rtl8169_netdev_ops;
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 	tp->pci_dev = pdev;
@@ -2126,7 +2097,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
 		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
 		tp->link_ok = rtl8169_tbi_link_ok;
-		tp->do_ioctl = rtl_tbi_ioctl;
 
 		tp->phy_1000_ctrl_reg = ADVERTISE_1000FULL; /* Implied by TBI */
 	} else {
@@ -2135,7 +2105,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->phy_reset_enable = rtl8169_xmii_reset_enable;
 		tp->phy_reset_pending = rtl8169_xmii_reset_pending;
 		tp->link_ok = rtl8169_xmii_link_ok;
-		tp->do_ioctl = rtl_xmii_ioctl;
+
+		dev->do_ioctl = rtl8169_ioctl;
 	}
 
 	spin_lock_init(&tp->lock);
@@ -2147,15 +2118,28 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
+	dev->open = rtl8169_open;
+	dev->hard_start_xmit = rtl8169_start_xmit;
+	dev->get_stats = rtl8169_get_stats;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
+	dev->stop = rtl8169_close;
+	dev->tx_timeout = rtl8169_tx_timeout;
+	dev->set_multicast_list = rtl_set_rx_mode;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
+	dev->change_mtu = rtl8169_change_mtu;
+	dev->set_mac_address = rtl_set_mac_address;
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->vlan_rx_register = rtl8169_vlan_rx_register;
+#endif
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = rtl8169_netpoll;
 #endif
 
 	tp->intr_mask = 0xffff;
@@ -3513,6 +3497,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
 				netif_receive_skb(skb);
 
+			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
 		}
@@ -3594,8 +3579,8 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
 		tp->intr_mask = ~tp->napi_event;
 
-		if (likely(napi_schedule_prep(&tp->napi)))
-			__napi_schedule(&tp->napi);
+		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
+			__netif_rx_schedule(dev, &tp->napi);
 		else if (netif_msg_intr(tp)) {
 			printk(KERN_INFO "%s: interrupt %04x in poll\n",
 			       dev->name, status);
@@ -3616,7 +3601,7 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		netif_rx_complete(dev, napi);
 		tp->intr_mask = 0xffff;
 		/*
 		 * 20040426: the barrier is not strictly required but the


