From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC net 1/3] net: bridge: add helper to offload ageing time
Date: Wed, 19 Oct 2016 17:38:01 -0400
Message-ID: <20161019213803.22837-2-vivien.didelot@savoirfairelinux.com>
References: <20161019213803.22837-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        cphealy@gmail.com, bridge@lists.linux-foundation.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019213803.22837-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME switchdev attr is actually set
when initializing a bridge port, and when configuring the bridge ageing
time from ioctl/netlink/sysfs.

Add a __set_ageing_time helper to offload the ageing time to physical
switches, and add the SWITCHDEV_F_DEFER flag since it can be called
under bridge lock.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_private.h |  1 +
 net/bridge/br_stp.c     | 28 ++++++++++++++++++++--------
 net/bridge/br_stp_if.c  | 12 +++---------
 3 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1b63177..3c294b4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -992,6 +992,7 @@ void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
 int br_set_forward_delay(struct net_bridge *br, unsigned long x);
 int br_set_hello_time(struct net_bridge *br, unsigned long x);
 int br_set_max_age(struct net_bridge *br, unsigned long x);
+int __set_ageing_time(struct net_device *dev, unsigned long t);
 int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time);
 
 
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 9258b8e..6ebe2a0 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -562,6 +562,24 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
 
 }
 
+/* called under bridge lock */
+int __set_ageing_time(struct net_device *dev, unsigned long t)
+{
+	struct switchdev_attr attr = {
+		.orig_dev = dev,
+		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
+		.u.ageing_time = jiffies_to_clock_t(t),
+	};
+	int err;
+
+	err = switchdev_port_attr_set(dev, &attr);
+	if (err && err != -EOPNOTSUPP)
+		return err;
+
+	return 0;
+}
+
 /* Set time interval that dynamic forwarding entries live
  * For pure software bridge, allow values outside the 802.1
  * standard specification for special cases:
@@ -572,17 +590,11 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
  */
 int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time)
 {
-	struct switchdev_attr attr = {
-		.orig_dev = br->dev,
-		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
-		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
-		.u.ageing_time = ageing_time,
-	};
 	unsigned long t = clock_t_to_jiffies(ageing_time);
 	int err;
 
-	err = switchdev_port_attr_set(br->dev, &attr);
-	if (err && err != -EOPNOTSUPP)
+	err = __set_ageing_time(br->dev, t);
+	if (err)
 		return err;
 
 	br->ageing_time = t;
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index d8ad73b..2efbba5 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -36,12 +36,6 @@ static inline port_id br_make_port_id(__u8 priority, __u16 port_no)
 /* called under bridge lock */
 void br_init_port(struct net_bridge_port *p)
 {
-	struct switchdev_attr attr = {
-		.orig_dev = p->dev,
-		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
-		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
-		.u.ageing_time = jiffies_to_clock_t(p->br->ageing_time),
-	};
 	int err;
 
 	p->port_id = br_make_port_id(p->priority, p->port_no);
@@ -50,9 +44,9 @@ void br_init_port(struct net_bridge_port *p)
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
 
-	err = switchdev_port_attr_set(p->dev, &attr);
-	if (err && err != -EOPNOTSUPP)
-		netdev_err(p->dev, "failed to set HW ageing time\n");
+	err = __set_ageing_time(p->dev, p->br->ageing_time);
+	if (err)
+		netdev_err(p->dev, "failed to offload ageing time\n");
 }
 
 /* NO locks held */
-- 
2.10.0
