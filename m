From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH v4 3/4] net: dsa: Associate slave network device with CPU port
Date: Tue, 13 Jun 2017 13:27:21 -0700
Message-ID: <20170613202722.17598-4-f.fainelli@gmail.com>
References: <20170613202722.17598-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36383 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753742AbdFMU1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:27:38 -0400
Received: by mail-wr0-f193.google.com with SMTP id 77so3194715wrb.3
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 13:27:37 -0700 (PDT)
In-Reply-To: <20170613202722.17598-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting multiple CPU ports with DSA, have the
dsa_port structure know which CPU it is associated with. This will be
important in order to make sure the correct CPU is used for transmission
of the frames. If not for functional reasons, for performance (e.g: load
balancing) and forwarding decisions.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  |  1 +
 net/dsa/dsa2.c     | 11 +++++++++++
 net/dsa/dsa_priv.h |  2 +-
 net/dsa/legacy.c   |  1 +
 net/dsa/slave.c    |  4 +++-
 5 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7e93869819f9..58969b9a090c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -171,6 +171,7 @@ struct dsa_port {
 	struct dsa_switch	*ds;
 	unsigned int		index;
 	const char		*name;
+	struct dsa_port		*cpu_dp;
 	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index ab48c4f989da..52af8401af07 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -490,6 +490,8 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	enum dsa_tag_protocol tag_protocol;
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
+	struct dsa_port *p;
+	unsigned int i;
 
 	if (port->dn) {
 		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
@@ -507,6 +509,15 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	if (!dst->cpu_dp) {
 		dst->cpu_dp = port;
 		dst->cpu_dp->netdev = ethernet_dev;
+
+		for (i = 0; i < ds->num_ports; i++) {
+			p = &ds->ports[i];
+			if (!dsa_port_is_valid(p) ||
+			    i == index)
+				continue;
+
+			p->cpu_dp = port;
+		}
 	}
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 5c510f4ba0ce..7c2326f3b538 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -185,7 +185,7 @@ extern const struct dsa_device_ops trailer_netdev_ops;
 
 static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 {
-	return p->dp->ds->dst->cpu_dp->netdev;
+	return p->dp->cpu_dp->netdev;
 }
 
 #endif
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 5d4f6ffa3424..e60906125375 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -129,6 +129,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			ds->dsa_port_mask |= 1 << i;
 		} else {
 			ds->enabled_port_mask |= 1 << i;
+			ds->ports[i].cpu_dp = dst->cpu_dp;
 		}
 		valid_name_found = true;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9bf4c27f3393..a80b46777a04 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1140,9 +1140,11 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
+	struct dsa_port *cpu_dp;
 	int ret;
 
-	master = ds->dst->cpu_dp->netdev;
+	cpu_dp = ds->dst->cpu_dp;
+	master = cpu_dp->netdev;
 
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
-- 
2.9.3
