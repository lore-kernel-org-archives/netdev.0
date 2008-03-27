From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 2/2 v2] pasemi_mac: Netpoll support
Date: Thu, 27 Mar 2008 17:40:07 -0500
Message-ID: <20080327224007.GB17980@lixom.net>
References: <20080326015625.GA23103@lixom.net> <20080326015801.GC23103@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, pasemi-linux@ozlabs.org,
	netdev@vger.kernel.org, ncase@xes-inc.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:51509 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873AbYC0WbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 18:31:25 -0400
Content-Disposition: inline
In-Reply-To: <20080326015801.GC23103@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netpoll support to allow use of netconsole.
    
Signed-off-by: Nate Case <ncase@xes-inc.com>
Signed-off-by: Olof Johansson <olof@lixom.net>

---
Changed the interrupt handler arguments as found by Valentine. Will push
through powerpc.git with Jeff's ACKs (that were already given).


-Olof

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index abb1dc4..965f2e4 100644
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
+	pasemi_mac_rx_intr(mac->rx->chan.irq, mac->rx);
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
