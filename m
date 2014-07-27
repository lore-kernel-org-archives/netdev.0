From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 2/2] net: mvpp2: implement ioctl() operation for PHY ioctls
Date: Sun, 27 Jul 2014 23:21:36 +0200
Message-ID: <1406496096-11039-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1406496096-11039-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:35497 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752589AbaG0VVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 17:21:39 -0400
In-Reply-To: <1406496096-11039-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit implements the ->ndo_do_ioctl() operation so that the
PHY-related ioctl() calls can work from userspace, which allows
applications like mii-tool or mii-diag to do their job.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
This commit applies on top of net-next, since the mvpp2 driver was
merged there.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3cae3d2..ece83f1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5714,6 +5714,21 @@ mvpp2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	return stats;
 }
 
+static int mvpp2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct mvpp2_port *port = netdev_priv(dev);
+	int ret;
+
+	if (!port->phy_dev)
+		return -ENOTSUPP;
+
+	ret = phy_mii_ioctl(port->phy_dev, ifr, cmd);
+	if (!ret)
+		mvpp2_link_event(dev);
+
+	return ret;
+}
+
 /* Ethtool methods */
 
 /* Get settings (phy address, speed) for ethtools */
@@ -5868,6 +5883,7 @@ static const struct net_device_ops mvpp2_netdev_ops = {
 	.ndo_set_mac_address	= mvpp2_set_mac_address,
 	.ndo_change_mtu		= mvpp2_change_mtu,
 	.ndo_get_stats64	= mvpp2_get_stats64,
+	.ndo_do_ioctl		= mvpp2_ioctl,
 };
 
 static const struct ethtool_ops mvpp2_eth_tool_ops = {
-- 
2.0.0
