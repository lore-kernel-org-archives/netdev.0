From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC] IXP4xx: Add ethtool support to Ethernet driver.
Date: Sun, 21 Dec 2008 02:16:52 +0100
Message-ID: <m3myeqba4b.fsf@maximus.localdomain>
References: <m3vdtebadt.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:54633 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbYLUBRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 20:17:05 -0500
In-Reply-To: <m3vdtebadt.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Sun\, 21 Dec 2008 02\:11\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few patches I'm posting for review only.

Not for operational use.

IXP4xx: Add ethtool support to Ethernet driver.
    
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -170,6 +170,7 @@ struct port {
 	u32 desc_tab_phys;
 	int id;			/* logical port ID */
 	int speed, duplex;
+	u8 firmware[4];
 };
 
 /* NPE message structure */
@@ -796,6 +797,45 @@ static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	return phy_mii_ioctl(port->phydev, if_mii(req), cmd);
 }
 
+/* ethtool support */
+
+static void ixp4xx_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	struct port *port = netdev_priv(dev);
+	strcpy(info->driver, DRV_NAME);
+	snprintf(info->fw_version, sizeof(info->fw_version), "%u:%u:%u:%u",
+		 port->firmware[0], port->firmware[1],
+		 port->firmware[2], port->firmware[3]);
+	strcpy(info->bus_info, "internal");
+}
+
+static int ixp4xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct port *port = netdev_priv(dev);
+	return phy_ethtool_gset(port->phydev, cmd);
+}
+
+static int ixp4xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct port *port = netdev_priv(dev);
+	return phy_ethtool_sset(port->phydev, cmd);
+}
+
+static int ixp4xx_nway_reset(struct net_device *dev)
+{
+	struct port *port = netdev_priv(dev);
+	return phy_start_aneg(port->phydev);
+}
+
+static struct ethtool_ops ixp4xx_ethtool_ops = {
+	.get_drvinfo = ixp4xx_get_drvinfo,
+	.get_settings = ixp4xx_get_settings,
+	.set_settings = ixp4xx_set_settings,
+	.nway_reset = ixp4xx_nway_reset,
+	.get_link = ethtool_op_get_link,
+};
+
 
 static int request_queues(struct port *port)
 {
@@ -943,6 +983,10 @@ static int eth_open(struct net_device *dev)
 			       npe_name(npe));
 			return -EIO;
 		}
+		port->firmware[0] = msg.byte4;
+		port->firmware[1] = msg.byte5;
+		port->firmware[2] = msg.byte6;
+		port->firmware[3] = msg.byte7;
 	}
 
 	memset(&msg, 0, sizeof(msg));
@@ -1152,6 +1196,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	dev->hard_start_xmit = eth_xmit;
 	dev->stop = eth_close;
 	dev->do_ioctl = eth_ioctl;
+	dev->ethtool_ops = &ixp4xx_ethtool_ops;
 	dev->set_multicast_list = eth_set_mcast_list;
 	dev->tx_queue_len = 100;
 
-- 
Krzysztof Halasa
