From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/9] net: dsa: Initialize CPU port ethtool ops per tree
Date: Fri,  3 Jun 2016 17:05:30 -0700
Message-ID: <1464998733-10405-11-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34475 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbcFDAF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:57 -0400
Received: by mail-pf0-f196.google.com with SMTP id c84so12608287pfc.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:57 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can properly support multiple distinct trees in the system,
using a global variable: dsa_cpu_port_ethtool_ops is getting clobbered
as soon as the second switch tree gets probed, and we don't want that.

We need to move this to be dynamically allocated, and since we can't
really be comparing addresses anymore to determine first time
initialization versus any other times, just move this to dsa.c and
dsa2.c where the remainder of the dst/ds initialization happens.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      | 28 ++++++++++++++++++++++++++++
 net/dsa/dsa2.c     |  2 +-
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/slave.c    | 10 ----------
 4 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index ebc29a1bee08..8fb8de6fb82d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -266,6 +266,30 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
 	return ops;
 }
 
+int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
+			       struct dsa_switch *ds)
+{
+	struct net_device *master;
+	struct ethtool_ops *cpu_ops;
+
+	master = ds->dst->master_netdev;
+	if (ds->master_netdev)
+		master = ds->master_netdev;
+
+	cpu_ops = devm_kzalloc(ds->dev, sizeof(*cpu_ops), GFP_KERNEL);
+	if (!cpu_ops)
+		return -ENOMEM;
+
+	memcpy(&dst->master_ethtool_ops, master->ethtool_ops,
+	       sizeof(struct ethtool_ops));
+	memcpy(cpu_ops, &dst->master_ethtool_ops,
+	       sizeof(struct ethtool_ops));
+	dsa_cpu_port_ethtool_init(cpu_ops);
+	master->ethtool_ops = cpu_ops;
+
+	return 0;
+}
+
 static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
 	struct dsa_switch_driver *drv = ds->drv;
@@ -379,6 +403,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		ret = 0;
 	}
 
+	ret = dsa_cpu_port_ethtool_setup(dst, ds);
+	if (ret)
+		return ret;
+
 #ifdef CONFIG_NET_DSA_HWMON
 	/* If the switch provides a temperature sensor,
 	 * register with hardware monitoring subsystem.
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index e8386157de30..938262010524 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -346,7 +346,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			continue;
 	}
 
-	return 0;
+	return dsa_cpu_port_ethtool_setup(dst, ds);
 }
 
 static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 106a9f067f94..3bb88b2fb580 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -54,6 +54,8 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct device_node *port_dn, int port);
 void dsa_cpu_dsa_destroy(struct device_node *port_dn);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
+int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
+			       struct dsa_switch *ds);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8d159932e082..7236eb26dc97 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -892,8 +892,6 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_eee		= dsa_slave_get_eee,
 };
 
-static struct ethtool_ops dsa_cpu_port_ethtool_ops;
-
 static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
@@ -1126,14 +1124,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	slave_dev->features = master->vlan_features;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
-	if (master->ethtool_ops != &dsa_cpu_port_ethtool_ops) {
-		memcpy(&dst->master_ethtool_ops, master->ethtool_ops,
-		       sizeof(struct ethtool_ops));
-		memcpy(&dsa_cpu_port_ethtool_ops, &dst->master_ethtool_ops,
-		       sizeof(struct ethtool_ops));
-		dsa_cpu_port_ethtool_init(&dsa_cpu_port_ethtool_ops);
-		master->ethtool_ops = &dsa_cpu_port_ethtool_ops;
-	}
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->priv_flags |= IFF_NO_QUEUE;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
-- 
2.7.4
