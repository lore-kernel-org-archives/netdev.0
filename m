From: John Crispin <john@phrozen.org>
Subject: [RFC 3/4] net-next: dsa: Add support for multiple cpu ports.
Date: Wed,  4 Jan 2017 08:38:03 +0100
Message-ID: <1483515484-21793-4-git-send-email-john@phrozen.org>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60158 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934379AbdADHiR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 02:38:17 -0500
In-Reply-To: <1483515484-21793-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

Some boards have two CPU interfaces connected to the switch, e.g. WiFi
access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, and
two port connected to the SoC.

This patch extends DSA to allows both CPU ports to be used. The "cpu"
node in the DSA tree can now have a phandle to the host interface it
connects to. Each user port can have a phandle to a cpu port which
should be used for traffic between the port and the CPU. Thus simple
load sharing over the two CPU ports can be achieved.

Signed-off-by: John Crispin <john@phrozen.org>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/dsa.h  |   21 ++++++++++++++++++++-
 net/dsa/dsa2.c     |   36 ++++++++++++++++++++++++++++++------
 net/dsa/dsa_priv.h |    5 +++++
 net/dsa/slave.c    |   27 ++++++++++++++++-----------
 4 files changed, 71 insertions(+), 18 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b122196..f68180b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -60,6 +60,8 @@ struct dsa_chip_data {
 	 */
 	char		*port_names[DSA_MAX_PORTS];
 	struct device_node *port_dn[DSA_MAX_PORTS];
+	struct net_device *port_ethernet[DSA_MAX_PORTS];
+	int		port_cpu[DSA_MAX_PORTS];
 
 	/*
 	 * An array of which element [a] indicates which port on this
@@ -204,7 +206,7 @@ struct dsa_switch {
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 {
-	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
+	return !!(ds->cpu_port_mask & (1 << p));
 }
 
 static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
@@ -217,6 +219,11 @@ static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
 }
 
+static inline bool dsa_is_upstream_port(struct dsa_switch *ds, int p)
+{
+	return dsa_is_cpu_port(ds, p) || dsa_is_dsa_port(ds, p);
+}
+
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
@@ -233,6 +240,18 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 		return ds->rtable[dst->cpu_switch];
 }
 
+static inline u8 dsa_port_upstream_port(struct dsa_switch *ds, int port)
+{
+	/*
+	 * If this port has a specific upstream cpu port, use it,
+	 * otherwise use the switch default.
+	 */
+	if (ds->cd->port_cpu[port])
+		return ds->cd->port_cpu[port];
+	else
+		return dsa_upstream_port(ds);
+}
+
 struct switchdev_trans;
 struct switchdev_obj;
 struct switchdev_obj_port_fdb;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 5fff951..1763cd4 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -258,7 +258,7 @@ static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
 {
 	dsa_cpu_dsa_destroy(port);
 	ds->cpu_port_mask &= ~BIT(index);
-
+	dev_put(ds->cd->port_ethernet[index]);
 }
 
 static int dsa_user_port_apply(struct device_node *port, u32 index,
@@ -475,6 +475,28 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 
 	dst->rcv = dst->tag_ops->rcv;
 
+	dev_hold(ethernet_dev);
+	ds->cd->port_ethernet[index] = ethernet_dev;
+
+	return 0;
+}
+
+static int dsa_user_parse(struct device_node *port, u32 index,
+			  struct dsa_switch *ds)
+{
+	struct device_node *cpu_port;
+	const unsigned int *cpu_port_reg;
+	int cpu_port_index;
+
+	cpu_port = of_parse_phandle(port, "cpu", 0);
+	if (cpu_port) {
+		cpu_port_reg = of_get_property(cpu_port, "reg", NULL);
+		if (!cpu_port_reg)
+			return -EINVAL;
+		cpu_port_index = be32_to_cpup(cpu_port_reg);
+		ds->cd->port_cpu[index] = cpu_port_index;
+	}
+
 	return 0;
 }
 
@@ -482,18 +504,20 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
 	struct device_node *port;
 	u32 index;
-	int err;
+	int err = 0;
 
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
 		port = ds->ports[index].dn;
 		if (!port)
 			continue;
 
-		if (dsa_port_is_cpu(port)) {
+		if (dsa_port_is_cpu(port))
 			err = dsa_cpu_parse(port, index, dst, ds);
-			if (err)
-				return err;
-		}
+		else if (!dsa_port_is_dsa(port))
+			err = dsa_user_parse(port, index,  ds);
+
+		if (err)
+			return err;
 	}
 
 	pr_info("DSA: switch %d %d parsed\n", dst->tree, ds->index);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 6cfd738..7e1e62c 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -24,6 +24,11 @@ struct dsa_device_ops {
 struct dsa_slave_priv {
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
+	/*
+	 * Which host device do we used to send packets to the switch
+	 * for this port.
+	 */
+	struct net_device	*master;
 
 	/*
 	 * Which switch this port is a part of, and the port index
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ffd91969..260d4a9 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -61,7 +61,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	return p->parent->dst->master_netdev->ifindex;
+	return p->master->ifindex;
 }
 
 static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
@@ -96,7 +96,7 @@ static void dsa_port_set_stp_state(struct dsa_switch *ds, int port, u8 state)
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->master;
 	struct dsa_switch *ds = p->parent;
 	u8 stp_state = dsa_port_is_bridged(p) ?
 			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
@@ -151,7 +151,7 @@ static int dsa_slave_open(struct net_device *dev)
 static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->master;
 	struct dsa_switch *ds = p->parent;
 
 	if (p->phy)
@@ -178,7 +178,7 @@ static int dsa_slave_close(struct net_device *dev)
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->master;
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -189,7 +189,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->master;
 
 	dev_mc_sync(master, dev);
 	dev_uc_sync(master, dev);
@@ -198,7 +198,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->parent->dst->master_netdev;
+	struct net_device *master = p->master;
 	struct sockaddr *addr = a;
 	int err;
 
@@ -633,7 +633,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	nskb->dev = p->parent->dst->master_netdev;
+	nskb->dev = p->master;
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -947,7 +947,7 @@ static int dsa_slave_netpoll_setup(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	struct net_device *master = ds->dst->master_netdev;
+	struct net_device *master = p->master;
 	struct netpoll *netpoll;
 	int err = 0;
 
@@ -1247,12 +1247,16 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
+	int port_cpu = ds->cd->port_cpu[port];
 	int ret;
 
-	master = ds->dst->master_netdev;
-	if (ds->master_netdev)
+	if (port_cpu && ds->cd->port_ethernet[port_cpu])
+		master = ds->cd->port_ethernet[port_cpu];
+	else if (ds->master_netdev)
 		master = ds->master_netdev;
-
+	else
+		master = ds->dst->master_netdev;
+	master->dsa_ptr = (void *)ds->dst;
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
 	if (slave_dev == NULL)
@@ -1279,6 +1283,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->parent = ds;
 	p->port = port;
 	p->xmit = dst->tag_ops->xmit;
+	p->master = master;
 
 	p->old_pause = -1;
 	p->old_link = -1;
-- 
1.7.10.4
