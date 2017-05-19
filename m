From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 12/20] net: dsa: move ageing time setter
Date: Fri, 19 May 2017 17:00:47 -0400
Message-ID: <20170519210055.9366-13-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48422 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932543AbdESVDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 17:03:18 -0400
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the DSA port code which sets a port ageing time in port.c, where it
belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/port.c     | 40 ++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 40 ----------------------------------------
 3 files changed, 42 insertions(+), 40 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index c145223247c5..b0f9837bf5ed 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -68,6 +68,8 @@ int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br);
 void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br);
 int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
 			    struct switchdev_trans *trans);
+int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
+			 struct switchdev_trans *trans);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index c9f95aaf25f1..3382fdc07a11 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -127,3 +127,43 @@ int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
 
 	return 0;
 }
+
+static unsigned int dsa_fastest_ageing_time(struct dsa_switch *ds,
+					    unsigned int ageing_time)
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
+int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
+			 struct switchdev_trans *trans)
+{
+	unsigned long ageing_jiffies = clock_t_to_jiffies(ageing_clock);
+	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
+	struct dsa_switch *ds = dp->ds;
+
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
+			return -ERANGE;
+		if (ds->ageing_time_max && ageing_time > ds->ageing_time_max)
+			return -ERANGE;
+		return 0;
+	}
+
+	/* Keep the fastest ageing time in case of multiple bridges */
+	dp->ageing_time = ageing_time;
+	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
+
+	if (ds->ops->set_ageing_time)
+		return ds->ops->set_ageing_time(ds, ageing_time);
+
+	return 0;
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 32e7e78313ba..1b0f396c4314 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -338,46 +338,6 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
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
-static int dsa_port_ageing_time(struct dsa_port *dp, clock_t ageing_clock,
-				struct switchdev_trans *trans)
-{
-	unsigned long ageing_jiffies = clock_t_to_jiffies(ageing_clock);
-	unsigned int ageing_time = jiffies_to_msecs(ageing_jiffies);
-	struct dsa_switch *ds = dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans)) {
-		if (ds->ageing_time_min && ageing_time < ds->ageing_time_min)
-			return -ERANGE;
-		if (ds->ageing_time_max && ageing_time > ds->ageing_time_max)
-			return -ERANGE;
-		return 0;
-	}
-
-	/* Keep the fastest ageing time in case of multiple bridges */
-	dp->ageing_time = ageing_time;
-	ageing_time = dsa_fastest_ageing_time(ds, ageing_time);
-
-	if (ds->ops->set_ageing_time)
-		return ds->ops->set_ageing_time(ds, ageing_time);
-
-	return 0;
-}
-
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
-- 
2.13.0
