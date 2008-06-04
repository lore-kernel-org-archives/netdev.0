From: Felix Fietkau <nbd@openwrt.org>
Subject: RFC: Custom PHY device detection functions
Date: Wed, 04 Jun 2008 22:55:23 +0200
Message-ID: <4847013B.4090408@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:57162 "EHLO ds10.mine.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792AbYFDV3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 17:29:32 -0400
Received: from p5b10dff7.dip.t-dialin.net ([91.16.223.247] helo=pi.lan)
	by ds10.mine.nu with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <nbd@openwrt.org>)
	id 1K400y-0004Mv-VW
	for netdev@vger.kernel.org; Wed, 04 Jun 2008 22:55:25 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm working on Linux on small consumer grade wireless routers. Many of 
these have switches that connect directly to the Ethernet controller 
through MII/MDIO. These typically support 6-8 ports, one of which connects 
to the CPU. I am working on supporting some of these with PHY drivers, 
which I will submit for review when they're ready.
Most of these devices can be detected with the regular PHY ID and mask, but 
unfortunately there are some that lay out their registers a bit differently 
and thus need custom detection.
I worked around this with the following patch, that allows drivers to do 
their own detection, but I'm not sure if this is suitable for inclusion in 
the PHY layer or if there is a different way to solve this.
Any ideas?

- Felix

--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -132,6 +132,9 @@
  	struct phy_device *phydev = to_phy_device(dev);
  	struct phy_driver *phydrv = to_phy_driver(drv);

+	if (phydrv->detect)
+		return (phydrv->detect(phydev->bus, phydev->addr));
+
  	return ((phydrv->phy_id & phydrv->phy_id_mask) ==
  		(phydev->phy_id & phydrv->phy_id_mask));
  }
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -325,6 +325,11 @@
  	u32 features;
  	u32 flags;

+	/* Called during discovery to test if the
+	 * device can attach to the bus, even if
+	 * phy id and mask do not match */
+	bool (*detect)(struct mii_bus *bus, int addr);
+
  	/* Called to initialize the PHY,
  	 * including after a reset */
  	int (*config_init)(struct phy_device *phydev);

