From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/6] net: dsa: allow enabling and disable switch ports
Date: Wed, 24 Sep 2014 17:05:18 -0700
Message-ID: <1411603522-8384-3-git-send-email-f.fainelli@gmail.com>
References: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:48203 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbaIYAGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:06:01 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so1257711pad.28
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:06:01 -0700 (PDT)
In-Reply-To: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever a per-port network device is used/unused, invoke the switch
driver port_enable/port_disable callbacks to allow saving as much power
as possible by disabling unused parts of the switch (RX/TX logic, memory
arrays, PHYs...). We supply a PHY device argument to make sure the
switch driver can act on the PHY device if needed (like putting/taking
the PHY out of deep low power mode).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  8 ++++++++
 net/dsa/slave.c   | 14 ++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index d8054fb4a4df..4f664fe0e42c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -224,6 +224,14 @@ struct dsa_switch_driver {
 	 */
 	int	(*suspend)(struct dsa_switch *ds);
 	int	(*resume)(struct dsa_switch *ds);
+
+	/*
+	 * Port enable/disable
+	 */
+	int	(*port_enable)(struct dsa_switch *ds, int port,
+			       struct phy_device *phy);
+	void	(*port_disable)(struct dsa_switch *ds, int port,
+				struct phy_device *phy);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 4392e983abda..182d30ae6818 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -62,6 +62,7 @@ static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = p->parent->dst->master_netdev;
+	struct dsa_switch *ds = p->parent;
 	int err;
 
 	if (!(master->flags & IFF_UP))
@@ -84,11 +85,20 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_allmulti;
 	}
 
+	if (ds->drv->port_enable) {
+		err = ds->drv->port_enable(ds, p->port, p->phy);
+		if (err)
+			goto clear_promisc;
+	}
+
 	if (p->phy)
 		phy_start(p->phy);
 
 	return 0;
 
+clear_promisc:
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(master, 0);
 clear_allmulti:
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(master, -1);
@@ -103,6 +113,7 @@ static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = p->parent->dst->master_netdev;
+	struct dsa_switch *ds = p->parent;
 
 	if (p->phy)
 		phy_stop(p->phy);
@@ -117,6 +128,9 @@ static int dsa_slave_close(struct net_device *dev)
 	if (!ether_addr_equal(dev->dev_addr, master->dev_addr))
 		dev_uc_del(master, dev->dev_addr);
 
+	if (ds->drv->port_disable)
+		ds->drv->port_disable(ds, p->port, p->phy);
+
 	return 0;
 }
 
-- 
1.9.1
