From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 5/8] net: dsa: add new API to register switch devices
Date: Wed, 29 Apr 2015 18:57:41 -0700
Message-ID: <1430359064-23454-6-git-send-email-f.fainelli@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35091 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbD3B6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:08 -0400
Received: by pdbqd1 with SMTP id qd1so45248119pdb.2
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:58:07 -0700 (PDT)
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new API to register DSA switch devices:

- dsa_switch_register
- dsa_switch_unregister

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  15 +++++
 net/dsa/dsa.c     | 182 +++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 168 insertions(+), 29 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63ba8f73..b057536f6a77 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -139,6 +139,12 @@ struct dsa_switch {
 	struct dsa_chip_data	*pd;
 
 	/*
+	 * Configuration came from "classic" platform_data
+	 * registration
+	 */
+	bool			from_pd;
+
+	/*
 	 * The used switch driver.
 	 */
 	struct dsa_switch_driver	*drv;
@@ -317,4 +323,13 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
 	return dst->rcv != NULL;
 }
+
+static inline struct dsa_switch *dsa_alloc_switch(size_t priv_size)
+{
+	return kzalloc(sizeof(struct dsa_switch) + priv_size, GFP_KERNEL);
+}
+
+int dsa_switch_register(struct dsa_switch *ds);
+int dsa_switch_register_phydev(struct dsa_switch *ds, struct phy_device *phy);
+void dsa_switch_unregister(struct dsa_switch *ds);
 #endif
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 58b99ff4591b..2d9762974880 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -364,6 +364,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->dst = dst;
 	ds->index = index;
 	ds->pd = pd;
+	ds->from_pd = true;
 	ds->drv = drv;
 	ds->tag_protocol = drv->tag_protocol;
 	ds->master_dev = host_dev;
@@ -570,12 +571,12 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	kfree(pd->chip);
 }
 
-static int dsa_of_probe(struct device *dev)
+static int dsa_of_probe(struct device *dev, struct phy_device *phydev)
 {
 	struct device_node *np = dev->of_node;
 	struct device_node *child, *mdio, *ethernet, *port, *link;
-	struct mii_bus *mdio_bus;
-	struct net_device *ethernet_dev;
+	struct mii_bus *mdio_bus = NULL;
+	struct net_device *ethernet_dev = NULL;
 	struct dsa_platform_data *pd;
 	struct dsa_chip_data *cd;
 	const char *port_name;
@@ -584,28 +585,38 @@ static int dsa_of_probe(struct device *dev)
 	u32 eeprom_len;
 	int ret;
 
-	mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
-	if (!mdio)
-		return -EINVAL;
-
-	mdio_bus = of_mdio_find_bus(mdio);
-	if (!mdio_bus)
-		return -EPROBE_DEFER;
-
-	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
-	if (!ethernet)
-		return -EINVAL;
-
-	ethernet_dev = of_find_net_device_by_node(ethernet);
-	if (!ethernet_dev)
-		return -EPROBE_DEFER;
+	/* Parsing of these properties only makes sense in the context of
+	 * non-MDIO probed devices (phydev == NULL) since all of these are
+	 * already implied by the PHY device:
+	 *
+	 * phydev->attached_dev is our netdev
+	 * phydev->bus is our MDIO bus
+	 */
+	if (!phydev) {
+		mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
+		if (!mdio)
+			return -EINVAL;
+
+		mdio_bus = of_mdio_find_bus(mdio);
+		if (!mdio_bus)
+			return -EPROBE_DEFER;
+
+		ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
+		if (!ethernet)
+			return -EINVAL;
+
+		ethernet_dev = of_find_net_device_by_node(ethernet);
+		if (!ethernet_dev)
+			return -EPROBE_DEFER;
+	}
 
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
 	if (!pd)
 		return -ENOMEM;
 
 	dev->platform_data = pd;
-	pd->of_netdev = ethernet_dev;
+	if (!phydev)
+		pd->of_netdev = ethernet_dev;
 	pd->nr_chips = of_get_available_child_count(np);
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
 		pd->nr_chips = DSA_MAX_SWITCHES;
@@ -623,15 +634,21 @@ static int dsa_of_probe(struct device *dev)
 		cd = &pd->chip[chip_index];
 
 		cd->of_node = child;
-		cd->host_dev = &mdio_bus->dev;
-
-		sw_addr = of_get_property(child, "reg", NULL);
-		if (!sw_addr)
-			continue;
+		if (!phydev)
+			cd->host_dev = &mdio_bus->dev;
+		else
+			cd->host_dev = &phydev->bus->dev;
+
+		if (!phydev) {
+			sw_addr = of_get_property(child, "reg", NULL);
+			if (!sw_addr)
+				continue;
 
-		cd->sw_addr = be32_to_cpup(sw_addr);
-		if (cd->sw_addr > PHY_MAX_ADDR)
-			continue;
+			cd->sw_addr = be32_to_cpup(sw_addr);
+			if (cd->sw_addr > PHY_MAX_ADDR)
+				continue;
+		} else
+			cd->sw_addr = phydev->addr;
 
 		if (!of_property_read_u32(np, "eeprom-length", &eeprom_len))
 			cd->eeprom_len = eeprom_len;
@@ -761,7 +778,7 @@ static int dsa_probe(struct platform_device *pdev)
 		       dsa_driver_version);
 
 	if (pdev->dev.of_node) {
-		ret = dsa_of_probe(&pdev->dev);
+		ret = dsa_of_probe(&pdev->dev, NULL);
 		if (ret)
 			return ret;
 
@@ -807,6 +824,107 @@ out:
 	return ret;
 }
 
+static int __dsa_switch_register(struct dsa_switch *ds,
+				 struct phy_device *phydev)
+{
+	struct dsa_switch_tree *dst;
+	struct dsa_platform_data *pd = NULL;
+	struct net_device *dev;
+	int ret;
+
+	/* If using Device Tree, just try to parse standard properties */
+	if (ds->master_dev->of_node) {
+		ret = dsa_of_probe(ds->master_dev, phydev);
+		if (ret)
+			return ret;
+
+		pd = ds->master_dev->platform_data;
+	}
+
+	if (pd == NULL)
+		return -ENODEV;
+
+	/* Cannot find the network device */
+	if (!phydev && (pd->netdev == NULL || pd->of_netdev == NULL))
+		return -ENODEV;
+
+	if (pd->of_netdev) {
+		dev = pd->of_netdev;
+		dev_hold(dev);
+	} else if (phydev == NULL) {
+		dev = dev_to_net_device(pd->netdev);
+	} else {
+		dev = phydev->attached_dev;
+		dev_hold(dev);
+	}
+
+	/* Regardless of our position within a switch tree, we should be
+	 * attached to a network device
+	 */
+	if (dev == NULL) {
+		dev_err(ds->master_dev, "invalid network device\n");
+		if (pd->of_netdev)
+			dev_put(pd->of_netdev);
+		if (phydev)
+			dev_put(phydev->attached_dev);
+		ret = -EPROBE_DEFER;
+		goto out;
+	}
+
+	/* For now we just bail out, but we would want to deal with stacked
+	 * setups with different tagging protocols sitting on top of each other
+	 * in the future
+	 */
+	if (dev->dsa_ptr != NULL) {
+		dev_put(dev);
+		ret = -EEXIST;
+		goto out;
+	}
+
+	dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+	if (!dst) {
+		dev_put(dev);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	dst->pd = pd;
+	ds->dst = dst;
+	ds->index = 0;
+	dst->master_netdev = dev;
+	dst->cpu_switch = -1;
+	dst->cpu_port = -1;
+	ds->pd = (struct dsa_chip_data *)dst->pd->chip + ds->index;
+
+	ret = dsa_switch_setup_one(ds, ds->master_dev);
+	if (ret)
+		return ret;
+
+	dst->ds[ds->index] = ds;
+
+	dsa_setup_dst_end(dev, dst);
+
+	netdev_info(dev, "Attached switch@%d\n", ds->index);
+
+	return 0;
+
+out:
+	dsa_of_remove(ds->master_dev);
+	return ret;
+}
+
+int dsa_switch_register(struct dsa_switch *ds)
+{
+	return __dsa_switch_register(ds, NULL);
+}
+EXPORT_SYMBOL_GPL(dsa_switch_register);
+
+int dsa_switch_register_phydev(struct dsa_switch *ds, struct phy_device *phydev)
+{
+	return __dsa_switch_register(ds, phydev);
+}
+EXPORT_SYMBOL_GPL(dsa_switch_register_phydev);
+
 static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
@@ -824,6 +942,13 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 	}
 }
 
+void dsa_switch_unregister(struct dsa_switch *ds)
+{
+	dsa_remove_dst(ds->dst);
+	dsa_of_remove(ds->master_dev);
+}
+EXPORT_SYMBOL_GPL(dsa_switch_unregister);
+
 static int dsa_remove(struct platform_device *pdev)
 {
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
@@ -897,7 +1022,6 @@ static int dsa_resume(struct device *d)
 static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
 
 static const struct of_device_id dsa_of_match_table[] = {
-	{ .compatible = "brcm,bcm7445-switch-v4.0" },
 	{ .compatible = "marvell,dsa", },
 	{}
 };
-- 
2.1.0
