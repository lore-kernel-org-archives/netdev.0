From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: dsa: allow switch drivers to implement suspend/resume hooks
Date: Thu, 18 Sep 2014 17:31:22 -0700
Message-ID: <1411086685-18684-2-git-send-email-f.fainelli@gmail.com>
References: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36482 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653AbaISAbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:31:47 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so2471144pde.40
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:31:47 -0700 (PDT)
In-Reply-To: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an abstraction layer to suspend/resume switch devices, doing the
following split:

- suspend/resume the slave network devices and their corresponding PHY
  devices
- suspend/resume the switch hardware using switch driver callbacks

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  |  6 ++++
 net/dsa/dsa.c      | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/slave.c    | 31 +++++++++++++++++++++
 4 files changed, 119 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c779e9bba1b3..0a34bf3d1ddd 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -209,6 +209,12 @@ struct dsa_switch_driver {
 	void	(*get_ethtool_stats)(struct dsa_switch *ds,
 				     int port, uint64_t *data);
 	int	(*get_sset_count)(struct dsa_switch *ds);
+
+	/*
+	 * Suspend and resume
+	 */
+	int	(*suspend)(struct dsa_switch *ds);
+	int	(*resume)(struct dsa_switch *ds);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6e40928ec0e7..6905f2d84c44 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -238,6 +238,49 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 {
 }
 
+static int dsa_switch_suspend(struct dsa_switch *ds)
+{
+	int i, ret = 0;
+
+	/* Suspend slave network devices */
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		if (!(ds->phys_port_mask & (1 << i)))
+			continue;
+
+		ret = dsa_slave_suspend(ds->ports[i]);
+		if (ret)
+			return ret;
+	}
+
+	if (ds->drv->suspend)
+		ret = ds->drv->suspend(ds);
+
+	return ret;
+}
+
+static int dsa_switch_resume(struct dsa_switch *ds)
+{
+	int i, ret = 0;
+
+	if (ds->drv->resume)
+		ret = ds->drv->resume(ds);
+
+	if (ret)
+		return ret;
+
+	/* Resume slave network devices */
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		if (!(ds->phys_port_mask & (1 << i)))
+			continue;
+
+		ret = dsa_slave_resume(ds->ports[i]);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
 
 /* link polling *************************************************************/
 static void dsa_link_poll_work(struct work_struct *ugly)
@@ -650,6 +693,42 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
+#ifdef CONFIG_PM_SLEEP
+static int dsa_suspend(struct device *d)
+{
+	struct platform_device *pdev = to_platform_device(d);
+	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
+	int i, ret = 0;
+
+	for (i = 0; i < dst->pd->nr_chips; i++) {
+		struct dsa_switch *ds = dst->ds[i];
+
+		if (ds != NULL)
+			ret = dsa_switch_suspend(ds);
+	}
+
+	return ret;
+}
+
+static int dsa_resume(struct device *d)
+{
+	struct platform_device *pdev = to_platform_device(d);
+	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
+	int i, ret = 0;
+
+	for (i = 0; i < dst->pd->nr_chips; i++) {
+		struct dsa_switch *ds = dst->ds[i];
+
+		if (ds != NULL)
+			ret = dsa_switch_resume(ds);
+	}
+
+	return ret;
+}
+#endif
+
+static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
+
 static const struct of_device_id dsa_of_match_table[] = {
 	{ .compatible = "brcm,bcm7445-switch-v4.0" },
 	{ .compatible = "marvell,dsa", },
@@ -665,6 +744,7 @@ static struct platform_driver dsa_driver = {
 		.name	= "dsa",
 		.owner	= THIS_MODULE,
 		.of_match_table = dsa_of_match_table,
+		.pm	= &dsa_pm_ops,
 	},
 };
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index f90899e8ab5a..dc9756d3154c 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -56,6 +56,8 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds);
 struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    struct device *parent,
 				    int port, char *name);
+int dsa_slave_suspend(struct net_device *slave_dev);
+int dsa_slave_resume(struct net_device *slave_dev);
 
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 90c9689ed362..e11c9bdca6e6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -408,6 +408,37 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			p->phy->addr, p->phy->drv->name);
 }
 
+int dsa_slave_suspend(struct net_device *slave_dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+
+	netif_device_detach(slave_dev);
+
+	if (p->phy) {
+		phy_stop(p->phy);
+		p->old_pause = -1;
+		p->old_link = -1;
+		p->old_duplex = -1;
+		phy_suspend(p->phy);
+	}
+
+	return 0;
+}
+
+int dsa_slave_resume(struct net_device *slave_dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+
+	netif_device_attach(slave_dev);
+
+	if (p->phy) {
+		phy_resume(p->phy);
+		phy_start(p->phy);
+	}
+
+	return 0;
+}
+
 struct net_device *
 dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		 int port, char *name)
-- 
1.9.1
