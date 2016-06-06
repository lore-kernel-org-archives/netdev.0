From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/5] net: dsa: Add initialization helper for CPU port ethtool_ops
Date: Mon,  6 Jun 2016 16:14:53 -0700
Message-ID: <1465254895-11152-4-git-send-email-f.fainelli@gmail.com>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36314 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbcFFXPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:15:05 -0400
Received: by mail-pa0-f65.google.com with SMTP id fg1so12673305pad.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:15:05 -0700 (PDT)
In-Reply-To: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper function: dsa_cpu_port_ethtool_init() which initializes a
custom ethtool_ops structure with custom DSA ethtool operations for CPU
ports. This is a preliminary change to move the initialization outside
of net/dsa/slave.c.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 14 ++++++++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index b42f1a5f95f3..106a9f067f94 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -58,6 +58,7 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
+void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops);
 int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, const char *name);
 void dsa_slave_destroy(struct net_device *slave_dev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a51dfedf0014..8d159932e082 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -865,6 +865,13 @@ static void dsa_slave_poll_controller(struct net_device *dev)
 }
 #endif
 
+void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
+{
+	ops->get_sset_count = dsa_cpu_port_get_sset_count;
+	ops->get_ethtool_stats = dsa_cpu_port_get_ethtool_stats;
+	ops->get_strings = dsa_cpu_port_get_strings;
+}
+
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_settings		= dsa_slave_get_settings,
 	.set_settings		= dsa_slave_set_settings,
@@ -1124,12 +1131,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		       sizeof(struct ethtool_ops));
 		memcpy(&dsa_cpu_port_ethtool_ops, &dst->master_ethtool_ops,
 		       sizeof(struct ethtool_ops));
-		dsa_cpu_port_ethtool_ops.get_sset_count =
-					dsa_cpu_port_get_sset_count;
-		dsa_cpu_port_ethtool_ops.get_ethtool_stats =
-					dsa_cpu_port_get_ethtool_stats;
-		dsa_cpu_port_ethtool_ops.get_strings =
-					dsa_cpu_port_get_strings;
+		dsa_cpu_port_ethtool_init(&dsa_cpu_port_ethtool_ops);
 		master->ethtool_ops = &dsa_cpu_port_ethtool_ops;
 	}
 	eth_hw_addr_inherit(slave_dev, master);
-- 
2.7.4
