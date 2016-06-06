From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/5] net: dsa: Initialize CPU port ethtool ops per tree
Date: Mon,  6 Jun 2016 16:14:54 -0700
Message-ID: <1465254895-11152-5-git-send-email-f.fainelli@gmail.com>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35195 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbcFFXPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:15:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id z187so4570716pfz.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:15:06 -0700 (PDT)
In-Reply-To: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
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
 net/dsa/dsa2.c     |  4 ++++
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/slave.c    | 10 ----------
 4 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index ce3b942dce76..37026f04ee4d 100644
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
index 5ae45210a936..6e912745e43d 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -391,6 +391,10 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
+	err = dsa_cpu_port_ethtool_setup(dst, dst->ds[0]);
+	if (err)
+		return err;
+
 	/* If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
 	 * sent to the tag format's receive function.
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
