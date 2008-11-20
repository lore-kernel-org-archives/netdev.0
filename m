From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/33] r8169: convert to net_device_ops
Date: Wed, 19 Nov 2008 22:07:18 -0800 (PST)
Message-ID: <20081119.220718.147600739.davem@davemloft.net>
References: <20081117234356.157757873@vyatta.com>
	<20081117173847.38409d56@extreme>
	<20081118211858.GA19059@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751043AbYKTGHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 01:07:18 -0500
In-Reply-To: <20081118211858.GA19059@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 18 Nov 2008 22:18:58 +0100

> Stephen Hemminger <shemminger@vyatta.com> :
> > Convert to new network device ops interface. In this case needed
> > to match behaviour of old code which only allowed ioctl on some
> > device types.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > ---
> > Handle no vlan case as well.
> > 
> > --- a/drivers/net/r8169.c	2008-11-17 17:21:59.000000000 -0800
> > +++ b/drivers/net/r8169.c	2008-11-17 17:24:25.000000000 -0800
> > @@ -1832,6 +1832,9 @@ static int rtl8169_ioctl(struct net_devi
> >  	if (!netif_running(dev))
> >  		return -ENODEV;
> >  
> > +	if (tp->get_settings != rtl8169_gset_xmii)
> > +		return -EOPNOTSUPP;
> > +
> 
> It's a bit hackish. Would you raise an objection against the code
> below ?

I applied this (actually build tested, sigh) version of your patch.

Please, if you are going to propose a real patch, at least do a
minimal build test on it.

If you cannot be bothered to do that, either be happy with the
original submission or make your suggestion using pseudo-code or plain
english.

Otherwise what you post looks like something I can expect to apply
and use.

r8169: convert to net_device_ops

From: Francois Romieu <romieu@fr.zoreil.com>

Based upon a patch by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/r8169.c |   48 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index cb5042e..bac58ca 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -474,6 +474,7 @@ struct rtl8169_private {
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
+	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
 	int pcie_cap;
 	struct delayed_work task;
 	unsigned features;
@@ -1829,9 +1830,11 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 
-	if (!netif_running(dev))
-		return -ENODEV;
+	return netif_running(dev) ? tp->do_ioctl(tp, data, cmd) : -ENODEV;
+}
 
+static int rtl_xmii_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd)
+{
 	switch (cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id = 32; /* Internal PHY */
@@ -1850,6 +1853,11 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static int rtl_tbi_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd)
+{
+	return -EOPNOTSUPP;
+}
+
 static const struct rtl_cfg_info {
 	void (*hw_start)(struct net_device *);
 	unsigned int region;
@@ -1915,6 +1923,25 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 	}
 }
 
+static const struct net_device_ops rtl8169_netdev_ops = {
+	.ndo_open		= rtl8169_open,
+	.ndo_stop		= rtl8169_close,
+	.ndo_get_stats		= rtl8169_get_stats,
+	.ndo_tx_timeout		= rtl8169_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= rtl8169_change_mtu,
+	.ndo_set_mac_address	= rtl_set_mac_address,
+	.ndo_do_ioctl		= rtl8169_ioctl,
+	.ndo_set_multicast_list	= rtl_set_rx_mode,
+#ifdef CONFIG_R8169_VLAN
+	.ndo_vlan_rx_register	= rtl8169_vlan_rx_register,
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= rtl8169_netpoll,
+#endif
+
+};
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1941,6 +1968,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev->netdev_ops = &rtl8169_netdev_ops;
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 	tp->pci_dev = pdev;
@@ -2076,6 +2104,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
 		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
 		tp->link_ok = rtl8169_tbi_link_ok;
+		tp->do_ioctl = rtl_tbi_ioctl;
 
 		tp->phy_1000_ctrl_reg = ADVERTISE_1000FULL; /* Implied by TBI */
 	} else {
@@ -2084,8 +2113,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->phy_reset_enable = rtl8169_xmii_reset_enable;
 		tp->phy_reset_pending = rtl8169_xmii_reset_pending;
 		tp->link_ok = rtl8169_xmii_link_ok;
-
-		dev->do_ioctl = rtl8169_ioctl;
+		tp->do_ioctl = rtl_xmii_ioctl;
 	}
 
 	spin_lock_init(&tp->lock);
@@ -2097,28 +2125,16 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	dev->open = rtl8169_open;
 	dev->hard_start_xmit = rtl8169_start_xmit;
-	dev->get_stats = rtl8169_get_stats;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
-	dev->stop = rtl8169_close;
-	dev->tx_timeout = rtl8169_tx_timeout;
-	dev->set_multicast_list = rtl_set_rx_mode;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
-	dev->change_mtu = rtl8169_change_mtu;
-	dev->set_mac_address = rtl_set_mac_address;
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = rtl8169_vlan_rx_register;
-#endif
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = rtl8169_netpoll;
 #endif
 
 	tp->intr_mask = 0xffff;
-- 
1.5.6.5

