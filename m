From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 5/6] net: dsa: Initialize CPU port ethtool ops per tree
Date: Tue,  7 Jun 2016 14:06:55 -0700
Message-ID: <1465333616-6351-6-git-send-email-f.fainelli@gmail.com>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33491 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493AbcFGVJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 17:09:36 -0400
Received: by mail-pa0-f67.google.com with SMTP id di3so14928334pab.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 14:09:36 -0700 (PDT)
In-Reply-To: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can properly support multiple distinct trees in the system,
using a global variable: dsa_cpu_port_ethtool_ops is getting clobbered
as soon as the second switch tree gets probed, and we don't want that.

We need to move this to be dynamically allocated, and since we can't
really be comparing addresses anymore to determine first time
initialization versus any other times, just move this to dsa.c and
dsa2.c where the remainder of the dst/ds initialization happens.

The operations teardown restores the master netdev's ethtool_ops to its
original ethtool_ops pointer (typically within the Ethernet driver)

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  |  1 +
 net/dsa/dsa.c      | 43 +++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa2.c     |  6 ++++++
 net/dsa/dsa_priv.h |  4 ++++
 net/dsa/slave.c    | 10 ----------
 5 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index cca7ef230742..20b3087ad193 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -116,6 +116,7 @@ struct dsa_switch_tree {
 	 * Original copy of the master netdev ethtool_ops
 	 */
 	struct ethtool_ops	master_ethtool_ops;
+	const struct ethtool_ops *master_orig_ethtool_ops;
 
 	/*
 	 * The switch and port to which the CPU is attached.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index ce3b942dce76..80f930d38df1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -266,6 +266,43 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
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
+	dst->master_orig_ethtool_ops = master->ethtool_ops;
+	memcpy(cpu_ops, &dst->master_ethtool_ops,
+	       sizeof(struct ethtool_ops));
+	dsa_cpu_port_ethtool_init(cpu_ops);
+	master->ethtool_ops = cpu_ops;
+
+	return 0;
+}
+
+void dsa_cpu_port_ethtool_restore(struct dsa_switch_tree *dst,
+				  struct dsa_switch *ds)
+{
+	struct net_device *master;
+
+	master = ds->dst->master_netdev;
+	if (ds->master_netdev)
+		master = ds->master_netdev;
+
+	master->ethtool_ops = dst->master_orig_ethtool_ops;
+}
+
 static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
 	struct dsa_switch_driver *drv = ds->drv;
@@ -379,6 +416,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		ret = 0;
 	}
 
+	ret = dsa_cpu_port_ethtool_setup(dst, ds);
+	if (ret)
+		return ret;
+
 #ifdef CONFIG_NET_DSA_HWMON
 	/* If the switch provides a temperature sensor,
 	 * register with hardware monitoring subsystem.
@@ -963,6 +1004,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
+	dsa_cpu_port_ethtool_restore(dst, dst->ds[0]);
+
 	dev_put(dst->master_netdev);
 }
 
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4e0f3c268103..7ffee268a526 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -394,6 +394,10 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
+	err = dsa_cpu_port_ethtool_setup(dst, dst->ds[0]);
+	if (err)
+		return err;
+
 	/* If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
 	 * sent to the tag format's receive function.
@@ -429,6 +433,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
+	dsa_cpu_port_ethtool_restore(dst, dst->ds[0]);
+
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 106a9f067f94..9c920c27f22c 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -54,6 +54,10 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct device_node *port_dn, int port);
 void dsa_cpu_dsa_destroy(struct device_node *port_dn);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
+int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
+			       struct dsa_switch *ds);
+void dsa_cpu_port_ethtool_restore(struct dsa_switch_tree *dst,
+				  struct dsa_switch *ds);
 
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
