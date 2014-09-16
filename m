From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/8] net: dsa: allow switch drivers to specify phy_device::dev_flags
Date: Tue, 16 Sep 2014 16:53:02 -0700
Message-ID: <1410911584-1559-7-git-send-email-f.fainelli@gmail.com>
References: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:46989 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887AbaIPXx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 19:53:59 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so813905pde.33
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 16:53:58 -0700 (PDT)
In-Reply-To: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switch drivers (e.g: bcm_sf2) may have to communicate specific
workarounds or flags towards the PHY device driver. Allow switches
driver to be delegated that task by introducing a get_phy_flags()
callback which will do just that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 +
 net/dsa/slave.c   | 9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c779e9bba1b3..e020b8a12b7d 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -181,6 +181,7 @@ struct dsa_switch_driver {
 	char	*(*probe)(struct device *host_dev, int sw_addr);
 	int	(*setup)(struct dsa_switch *ds);
 	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
+	u32	(*get_phy_flags)(struct dsa_switch *ds, int port);
 
 	/*
 	 * Access to the switch's PHY registers.
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 90c9689ed362..ea2c52b11739 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -371,6 +371,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	struct dsa_chip_data *cd = ds->pd;
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
+	u32 phy_flags = 0;
 	int ret;
 
 	port_dn = cd->port_dn[p->port];
@@ -390,9 +391,12 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		phy_dn = port_dn;
 	}
 
+	if (ds->drv->get_phy_flags)
+		phy_flags = ds->drv->get_phy_flags(ds, port);
+
 	if (phy_dn)
 		p->phy = of_phy_connect(slave_dev, phy_dn,
-					dsa_slave_adjust_link, 0,
+					dsa_slave_adjust_link, phy_flags,
 					p->phy_interface);
 
 	if (p->phy && phy_is_fixed)
@@ -480,6 +484,9 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	netif_carrier_off(slave_dev);
 
 	if (p->phy != NULL) {
+		if (ds->drv->get_phy_flags(ds, port))
+			p->phy->dev_flags |= ds->drv->get_phy_flags(ds, port);
+
 		phy_attach(slave_dev, dev_name(&p->phy->dev),
 			   PHY_INTERFACE_MODE_GMII);
 
-- 
1.9.1
