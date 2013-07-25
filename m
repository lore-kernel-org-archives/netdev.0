From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: Add support for set MAC address
Date: Thu, 25 Jul 2013 23:44:01 +0530
Message-ID: <1374776041-11746-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36544 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756919Ab3GYSQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 14:16:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding support for setting MAC address to cpsw device via ndo_set_mac_address

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1cd1c00..f51fcd4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1424,6 +1424,33 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 
 }
 
+static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct sockaddr *addr = (struct sockaddr *)p;
+	int flags = 0;
+	u16 vid = 0;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (priv->data.dual_emac) {
+		vid = priv->slaves[priv->emac_port].port_vlan;
+		flags = ALE_VLAN;
+	}
+
+	cpsw_ale_del_ucast(priv->ale, priv->mac_addr, priv->host_port,
+			   flags, vid);
+	cpsw_ale_add_ucast(priv->ale, addr->sa_data, priv->host_port,
+			   flags, vid);
+
+	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
+	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
+	for_each_slave(priv, cpsw_set_slave_mac, priv);
+
+	return 0;
+}
+
 static struct net_device_stats *cpsw_ndo_get_stats(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
@@ -1518,6 +1545,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_stop		= cpsw_ndo_stop,
 	.ndo_start_xmit		= cpsw_ndo_start_xmit,
 	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
+	.ndo_set_mac_address	= cpsw_ndo_set_mac_address,
 	.ndo_do_ioctl		= cpsw_ndo_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
-- 
1.8.1.2
