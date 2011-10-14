From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 12/15] ehea: Add 64bit statistics
Date: Fri, 14 Oct 2011 12:31:09 -0300
Message-ID: <1318606272-27647-13-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:39545 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756938Ab1JNPb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:56 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:31:50 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFULhH3293420
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:21 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVcov008827
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:38 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Switch to using ndo_get_stats64 to get 64bit statistics.

v3:
[cascardo] use rtnl_link_stats64 as port stats

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h      |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index 7aa47d8..c9dbe52 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
@@ -448,7 +448,7 @@ struct ehea_bcmc_reg_array {
 struct ehea_port {
 	struct ehea_adapter *adapter;	 /* adapter that owns this port */
 	struct net_device *netdev;
-	struct net_device_stats stats;
+	struct rtnl_link_stats64 stats;
 	struct ehea_port_res port_res[EHEA_MAX_PORT_RES];
 	struct platform_device  ofdev; /* Open Firmware Device */
 	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 289ad4d..a0a3c5f 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -323,10 +323,10 @@ out:
 	spin_unlock_irqrestore(&ehea_bcmc_regs.lock, flags);
 }
 
-static struct net_device_stats *ehea_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
+					struct rtnl_link_stats64 *stats)
 {
 	struct ehea_port *port = netdev_priv(dev);
-	struct net_device_stats *stats = &port->stats;
 	u64 rx_packets = 0, tx_packets = 0, rx_bytes = 0, tx_bytes = 0;
 	int i;
 
@@ -353,7 +353,7 @@ static void ehea_update_stats(struct work_struct *work)
 	struct ehea_port *port =
 		container_of(work, struct ehea_port, stats_work.work);
 	struct net_device *dev = port->netdev;
-	struct net_device_stats *stats = &port->stats;
+	struct rtnl_link_stats64 *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
 	u64 hret;
 
@@ -3004,7 +3004,7 @@ static const struct net_device_ops ehea_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ehea_netpoll,
 #endif
-	.ndo_get_stats		= ehea_get_stats,
+	.ndo_get_stats64	= ehea_get_stats64,
 	.ndo_set_mac_address	= ehea_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= ehea_set_multicast_list,
-- 
1.7.4.4
