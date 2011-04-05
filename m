From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 12/14] ehea: Add some more ethtool operations and 64bit
 stats
Date: Tue, 5 Apr 2011 21:42:49 +1000
Message-ID: <20110405214249.36d248e7@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53829 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743Ab1DELmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:42:51 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can use the standard ethtool functions for set_tx_csum and set_sg.
Also switch to using ndo_get_stats64 to get 64bit tx/rx stats.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_ethtool.c	2011-03-25 18:34:06.358846652 +1100
+++ linux-2.6/drivers/net/ehea/ehea_ethtool.c	2011-03-25 18:37:37.982330408 +1100
@@ -295,6 +295,8 @@ const struct ethtool_ops ehea_ethtool_op
 	.get_flags = ethtool_op_get_flags,
 	.set_flags = ehea_set_flags,
 	.nway_reset = ehea_nway_reset,		/* Restart autonegotiation */
+	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_sg = ethtool_op_set_sg,
 };
 
 void ehea_set_ethtool_ops(struct net_device *netdev)
Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-03-25 18:34:06.378861533 +1100
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-03-25 18:37:02.810025945 +1100
@@ -321,10 +321,10 @@ out:
 	spin_unlock_irqrestore(&ehea_bcmc_regs.lock, flags);
 }
 
-static struct net_device_stats *ehea_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
+					struct rtnl_link_stats64 *stats)
 {
 	struct ehea_port *port = netdev_priv(dev);
-	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
 	u64 hret, rx_packets, tx_packets, rx_bytes = 0, tx_bytes = 0;
 	int i;
@@ -3038,7 +3038,7 @@ static const struct net_device_ops ehea_
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ehea_netpoll,
 #endif
-	.ndo_get_stats		= ehea_get_stats,
+	.ndo_get_stats64	= ehea_get_stats64,
 	.ndo_set_mac_address	= ehea_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= ehea_set_multicast_list,
