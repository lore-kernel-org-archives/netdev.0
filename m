From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 07/10] net/faraday: Read MAC address from chip
Date: Fri, 15 Jul 2016 20:44:17 +1000
Message-ID: <1468579460-13768-8-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:31249 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932493AbcGOKuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:50:55 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6FAnCF3081442
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:50:54 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 246k21av32-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 06:50:54 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 15 Jul 2016 20:50:52 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 44B912BB0059
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:50:49 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6FAontX22151264
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:50:49 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6FAomjK004336
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 20:50:49 +1000
In-Reply-To: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device is assigned with random MAC address. It isn't reasonable.
An valid MAC address might have been provided by (uboot) firmware by
device-tree or in chip. It's reasonable to use it to maintain consistency.

This uses the MAC address from device-tree or that in the chip if it's
valid. Otherwise, a random MAC address is given as before.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Acked-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 69 ++++++++++++++++++++++++++++----
 1 file changed, 62 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 9b09493..2c3f656 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -141,6 +141,64 @@ static void ftgmac100_set_mac(struct ftgmac100 *priv, const unsigned char *mac)
 	iowrite32(laddr, priv->base + FTGMAC100_OFFSET_MAC_LADR);
 }
 
+static void ftgmac100_setup_mac(struct ftgmac100 *priv)
+{
+	u8 mac[ETH_ALEN];
+	unsigned int m;
+	unsigned int l;
+	void *addr;
+
+	addr = device_get_mac_address(priv->dev, mac, ETH_ALEN);
+	if (addr) {
+		ether_addr_copy(priv->netdev->dev_addr, mac);
+		dev_info(priv->dev, "Read MAC address %pM from device tree\n",
+			 mac);
+		return;
+	}
+
+	m = ioread32(priv->base + FTGMAC100_OFFSET_MAC_MADR);
+	l = ioread32(priv->base + FTGMAC100_OFFSET_MAC_LADR);
+
+	mac[0] = (m >> 8) & 0xff;
+	mac[1] = m & 0xff;
+	mac[2] = (l >> 24) & 0xff;
+	mac[3] = (l >> 16) & 0xff;
+	mac[4] = (l >> 8) & 0xff;
+	mac[5] = l & 0xff;
+
+	if (!is_valid_ether_addr(mac)) {
+		mac[5] = (m >> 8) & 0xff;
+		mac[4] = m & 0xff;
+		mac[3] = (l >> 24) & 0xff;
+		mac[2] = (l >> 16) & 0xff;
+		mac[1] = (l >>  8) & 0xff;
+		mac[0] = l & 0xff;
+	}
+
+	if (is_valid_ether_addr(mac)) {
+		ether_addr_copy(priv->netdev->dev_addr, mac);
+		dev_info(priv->dev, "Read MAC address %pM from chip\n", mac);
+	} else {
+		eth_hw_addr_random(priv->netdev);
+		dev_info(priv->dev, "Generated random MAC address %pM\n",
+			 priv->netdev->dev_addr);
+	}
+}
+
+static int ftgmac100_set_mac_addr(struct net_device *dev, void *p)
+{
+	int ret;
+
+	ret = eth_prepare_mac_addr_change(dev, p);
+	if (ret < 0)
+		return ret;
+
+	eth_commit_mac_addr_change(dev, p);
+	ftgmac100_set_mac(netdev_priv(dev), dev->dev_addr);
+
+	return 0;
+}
+
 static void ftgmac100_init_hw(struct ftgmac100 *priv)
 {
 	/* setup ring buffer base registers */
@@ -1141,7 +1199,7 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_open		= ftgmac100_open,
 	.ndo_stop		= ftgmac100_stop,
 	.ndo_start_xmit		= ftgmac100_hard_start_xmit,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address	= ftgmac100_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= ftgmac100_do_ioctl,
 };
@@ -1265,6 +1323,9 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	priv->irq = irq;
 
+	/* MAC address from chip or random one */
+	ftgmac100_setup_mac(priv);
+
 	err = ftgmac100_setup_mdio(netdev);
 	if (err)
 		goto err_setup_mdio;
@@ -1278,12 +1339,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		eth_hw_addr_random(netdev);
-		netdev_info(netdev, "generated random MAC address %pM\n",
-			    netdev->dev_addr);
-	}
-
 	return 0;
 
 err_register_netdev:
-- 
2.1.0
