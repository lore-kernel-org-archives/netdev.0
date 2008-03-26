From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 2/2] pasemi_mac: Netpoll support
Date: Tue, 25 Mar 2008 20:58:01 -0500
Message-ID: <20080326015801.GC23103@lixom.net>
References: <20080326015625.GA23103@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, pasemi-linux@ozlabs.org,
	netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:42096 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012AbYCZBtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 21:49:36 -0400
Content-Disposition: inline
In-Reply-To: <20080326015625.GA23103@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netpoll support to allow use of netconsole.

Signed-off-by: Nate Case <ncase@xes-inc.com>
Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index abb1dc4..6030ffe 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1648,6 +1648,26 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 	return pkts;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void pasemi_mac_netpoll(struct net_device *dev)
+{
+	const struct pasemi_mac *mac = netdev_priv(dev);
+
+	disable_irq(mac->tx->chan.irq);
+	pasemi_mac_tx_intr(mac->tx->chan.irq, mac->tx);
+	enable_irq(mac->tx->chan.irq);
+
+	disable_irq(mac->rx->chan.irq);
+	pasemi_mac_rx_intr(mac->rx->chan.irq, dev);
+	enable_irq(mac->rx->chan.irq);
+}
+#endif
+
 static int pasemi_mac_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -1807,6 +1827,9 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->mtu = PE_DEF_MTU;
 	/* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = pasemi_mac_netpoll;
+#endif
 
 	dev->change_mtu = pasemi_mac_change_mtu;
 	dev->ethtool_ops = &pasemi_mac_ethtool_ops;
