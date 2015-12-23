From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 13/28] net: dsa: Add register/unregister functions for switch drivers
Date: Wed, 23 Dec 2015 13:56:27 +0100
Message-ID: <1450875402-20740-14-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48779 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202AbbLWM6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:36 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A switch device driver registers with DSA as part of the component
slave bind and unregisters on component slave unbind.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/dsa.h |  3 +++
 net/dsa/dsa.c     | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index ea4cfdf1b549..dbb90f2c475b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -345,6 +345,9 @@ struct dsa_switch_driver {
 void register_switch_driver(struct dsa_switch_driver *type);
 void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
+int dsa_switch_register(struct dsa_switch_tree *dst, struct dsa_switch *ds,
+			struct device_node *np, const char *name);
+void dsa_switch_unregister(struct dsa_switch *ds);
 
 static inline void *ds_to_priv(struct dsa_switch *ds)
 {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index eca487dcc9fe..0658077f4e63 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -981,6 +981,55 @@ static const struct component_master_ops dsa_ops = {
 	.unbind = dsa_unbind,
 };
 
+static int dsa_find_chip_index(struct dsa_switch_tree *dst,
+			       struct device_node *np)
+{
+	struct dsa_platform_data *pd = dst->pd;
+	struct dsa_chip_data *cd;
+	int i;
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		cd = &pd->chip[i];
+		if (cd->of_chip == np)
+			return i;
+	}
+	return -ENODEV;
+}
+
+int dsa_switch_register(struct dsa_switch_tree *dst, struct dsa_switch *ds,
+			struct device_node *np, const char *name)
+{
+	struct dsa_platform_data *pd = dst->pd;
+	int index = dsa_find_chip_index(dst, np);
+
+	if (index < 0)
+		return index;
+
+	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n", index, name);
+
+	if (dst->ds[index])
+		return -EINVAL;
+
+	ds->index = index;
+	ds->pd = &pd->chip[index];
+	ds->dst = dst;
+	dst->ds[index] = ds;
+	ds->tag_protocol = ds->drv->tag_protocol;
+	ds->master_dev = &dst->master_netdev->dev;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dsa_switch_register);
+
+void dsa_switch_unregister(struct dsa_switch *ds)
+{
+#ifdef CONFIG_PM_SLEEP
+	dsa_switch_suspend(ds);
+#endif
+	dsa_switch_destroy(ds);
+}
+EXPORT_SYMBOL_GPL(dsa_switch_unregister);
+
 static void dsa_shutdown(struct platform_device *pdev)
 {
 }
-- 
2.6.3
