From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: allow changing MAC address
Date: Mon,  8 Dec 2014 15:59:18 -0800
Message-ID: <1418083158-4027-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49912 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066AbaLHX7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 18:59:32 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so6222757pad.38
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 15:59:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hook a ndo_set_mac_address callback, update the internal Ethernet MAC in
the netdevice structure, and finally write that address down to the
UniMAC registers. If the interface is down, and most likely clock gated,
we do not update the registers but just the local copy, such that next
ndo_open() call will effectively write down the address.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index c1d255972dae..a91a8c263391 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1409,6 +1409,27 @@ static void topctrl_flush(struct bcm_sysport_priv *priv)
 	topctrl_writel(priv, 0, TX_FLUSH_CNTL);
 }
 
+static int bcm_sysport_change_mac(struct net_device *dev, void *p)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	/* interface is disabled, changes to MAC will be reflected on next
+	 * open call
+	 */
+	if (!netif_running(dev))
+		return 0;
+
+	umac_set_hw_addr(priv, dev->dev_addr);
+
+	return 0;
+}
+
 static void bcm_sysport_netif_start(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
@@ -1628,6 +1649,7 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
 	.ndo_stop		= bcm_sysport_stop,
 	.ndo_set_features	= bcm_sysport_set_features,
 	.ndo_set_rx_mode	= bcm_sysport_set_rx_mode,
+	.ndo_set_mac_address	= bcm_sysport_change_mac,
 };
 
 #define REV_FMT	"v%2x.%02x"
-- 
2.1.0
