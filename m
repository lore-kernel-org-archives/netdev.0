From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 8/9] net: dsa: add cross-chip bridging operations
Date: Wed, 29 Mar 2017 16:30:19 -0400
Message-ID: <20170329203020.27042-9-vivien.didelot@savoirfairelinux.com>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce crosschip_bridge_{join,leave} operations in the dsa_switch_ops
structure, which can be used by switches supporting interconnection.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  8 ++++++++
 net/dsa/switch.c  | 12 ++++++------
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 951b5e49e899..ffe56cc338fe 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -456,6 +456,14 @@ struct dsa_switch_ops {
 				   bool ingress);
 	void	(*port_mirror_del)(struct dsa_switch *ds, int port,
 				   struct dsa_mall_mirror_tc_entry *mirror);
+
+	/*
+	 * Cross-chip operations
+	 */
+	int	(*crosschip_bridge_join)(struct dsa_switch *ds, int sw_index,
+					 int port, struct net_device *br);
+	void	(*crosschip_bridge_leave)(struct dsa_switch *ds, int sw_index,
+					  int port, struct net_device *br);
 };
 
 struct dsa_switch_driver {
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index 7b6f38e5fef6..ca6e26e514f0 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -20,9 +20,9 @@ static int dsa_switch_bridge_join(struct dsa_switch *ds,
 	if (ds->index == info->sw_index && ds->ops->port_bridge_join)
 		return ds->ops->port_bridge_join(ds, info->port, info->br);
 
-	if (ds->index != info->sw_index)
-		dev_dbg(ds->dev, "crosschip DSA port %d.%d bridged to %s\n",
-			info->sw_index, info->port, netdev_name(info->br));
+	if (ds->index != info->sw_index && ds->ops->crosschip_bridge_join)
+		return ds->ops->crosschip_bridge_join(ds, info->sw_index,
+						      info->port, info->br);
 
 	return 0;
 }
@@ -33,9 +33,9 @@ static int dsa_switch_bridge_leave(struct dsa_switch *ds,
 	if (ds->index == info->sw_index && ds->ops->port_bridge_leave)
 		ds->ops->port_bridge_leave(ds, info->port, info->br);
 
-	if (ds->index != info->sw_index)
-		dev_dbg(ds->dev, "crosschip DSA port %d.%d unbridged from %s\n",
-			info->sw_index, info->port, netdev_name(info->br));
+	if (ds->index != info->sw_index && ds->ops->crosschip_bridge_leave)
+		ds->ops->crosschip_bridge_leave(ds, info->sw_index, info->port,
+						info->br);
 
 	return 0;
 }
-- 
2.12.1
