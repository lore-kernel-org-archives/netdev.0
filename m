From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 17/20] net: dsa: add notifier for ageing time
Date: Fri, 19 May 2017 17:00:52 -0400
Message-ID: <20170519210055.9366-18-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch keeps the port-wide ageing time handling code in
dsa_port_ageing_time, pushes the requested ageing time value in a new
switch fabric notification, and moves the switch-wide ageing time
handling code in dsa_switch_ageing_time.

This has the effect that now not only the switch that the target port
belongs to can be programmed, but all switches composing the switch
fabric. For the moment, keep the current behavior and ignore other
switches.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  8 ++++++++
 net/dsa/port.c     | 37 ++++++++-----------------------------
 net/dsa/switch.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 29 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c19241eb094b..becaf8a61b13 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -17,10 +17,18 @@
 #include <net/dsa.h>
 
 enum {
+	DSA_NOTIFIER_AGEING_TIME,
 	DSA_NOTIFIER_BRIDGE_JOIN,
 	DSA_NOTIFIER_BRIDGE_LEAVE,
 };
 
+/* DSA_NOTIFIER_AGEING_TIME */
+struct dsa_notifier_ageing_time_info {
+	struct switchdev_trans *trans;
+	unsigned int ageing_time;
+	int sw_index;
+};
+
 /* DSA_NOTIFIER_BRIDGE_* */
 struct dsa_notifier_bridge_info {
 	struct net_device *br;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index f211b0dfb12d..59328a35394d 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -128,44 +128,23 @@ int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
 	return 0;
 }
 
-static unsigned int dsa_fastest_ageing_time(struct dsa_switch *ds,
-					    unsigned int ageing_time)
-{
-	int i;
-
-	for (i = 0; i < ds->num_ports; ++i) {
-		struct dsa_port *dp = &ds->ports[i];
-
-		if (dp->ageing_time && dp->ageing_time < ageing_time)
-			ageing_time = dp->ageing_time;
-	}
-
-	return ageing_time;
-}
-
 int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
 			 struct switchdev_trans *trans)
 {
 	unsigned long ageing_jiffies = clock_t_to_jiffies(ageing_clock);
 	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
-	struct dsa_switch *ds = dp->ds;
+	struct dsa_notifier_ageing_time_info info = {
+		.ageing_time = ageing_time,
+		.sw_index = dp->ds->index,
+		.trans = trans,
+	};
 
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
-			return -ERANGE;
-		if (ds->ageing_time_max && ageing_time > ds->ageing_time_max)
-			return -ERANGE;
-		return 0;
-	}
+	if (switchdev_trans_ph_prepare(trans))
+		return dsa_port_notify(dp, DSA_NOTIFIER_AGEING_TIME, &info);
 
-	/* Keep the fastest ageing time in case of multiple bridges */
 	dp->ageing_time = ageing_time;
-	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
 
-	if (ds->ops->set_ageing_time)
-		return ds->ops->set_ageing_time(ds, ageing_time);
-
-	return 0;
+	return dsa_port_notify(dp, DSA_NOTIFIER_AGEING_TIME, &info);
 }
 
 int dsa_port_fdb_add(struct dsa_port *dp,
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index f477053308d2..540770ecc8b0 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -12,9 +12,52 @@
 
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
+#include <net/switchdev.h>
 
 #include "dsa_priv.h"
 
+static unsigned int dsa_switch_fastest_ageing_time(struct dsa_switch *ds,
+						   unsigned int ageing_time)
+{
+	int i;
+
+	for (i = 0; i < ds->num_ports; ++i) {
+		struct dsa_port *dp = &ds->ports[i];
+
+		if (dp->ageing_time && dp->ageing_time < ageing_time)
+			ageing_time = dp->ageing_time;
+	}
+
+	return ageing_time;
+}
+
+static int dsa_switch_ageing_time(struct dsa_switch *ds,
+				  struct dsa_notifier_ageing_time_info *info)
+{
+	unsigned int ageing_time = info->ageing_time;
+	struct switchdev_trans *trans = info->trans;
+
+	/* Do not care yet about other switch chips of the fabric */
+	if (ds->index != info->sw_index)
+		return 0;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
+			return -ERANGE;
+		if (ds->ageing_time_max && ageing_time > ds->ageing_time_max)
+			return -ERANGE;
+		return 0;
+	}
+
+	/* Program the fastest ageing time in case of multiple bridges */
+	ageing_time = dsa_switch_fastest_ageing_time(ds, ageing_time);
+
+	if (ds->ops->set_ageing_time)
+		return ds->ops->set_ageing_time(ds, ageing_time);
+
+	return 0;
+}
+
 static int dsa_switch_bridge_join(struct dsa_switch *ds,
 				  struct dsa_notifier_bridge_info *info)
 {
@@ -48,6 +91,9 @@ static int dsa_switch_event(struct notifier_block *nb,
 	int err;
 
 	switch (event) {
+	case DSA_NOTIFIER_AGEING_TIME:
+		err = dsa_switch_ageing_time(ds, info);
+		break;
 	case DSA_NOTIFIER_BRIDGE_JOIN:
 		err = dsa_switch_bridge_join(ds, info);
 		break;
-- 
2.13.0
