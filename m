From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: dsa: Remove master_netdev and use dst->cpu_dp->netdev
Date: Tue,  6 Jun 2017 10:01:58 -0700
Message-ID: <20170606170202.21491-2-f.fainelli@gmail.com>
References: <20170606170202.21491-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35770 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbdFFRCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:02:08 -0400
Received: by mail-qt0-f194.google.com with SMTP id x58so17313954qtc.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 10:02:07 -0700 (PDT)
In-Reply-To: <20170606170202.21491-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting multiple CPU ports, remove
dst->master_netdev and ds->master_netdev and replace them with only one
instance of the common object we have for a port: struct
dsa_port::netdev. ds->master_netdev is currently write only and would be
helpful in the case where we have two switches, both with CPU ports, and
also connected within each other, which the multi-CPU port patch series
would address.

While at it, introduce a helper function used in net/dsa/slave.c to
immediately get a reference on the master network device called
dsa_master_netdev().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c |  4 ++--
 drivers/net/dsa/mt7530.c  |  4 ++--
 include/net/dsa.h         |  5 -----
 net/dsa/dsa.c             |  9 ++-------
 net/dsa/dsa2.c            | 18 +++++++-----------
 net/dsa/dsa_priv.h        |  5 +++++
 net/dsa/legacy.c          | 22 +++++++++++++---------
 net/dsa/slave.c           | 20 +++++++++-----------
 8 files changed, 40 insertions(+), 47 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 687a8bae5d73..76e98e8ed315 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -806,7 +806,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 			       struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst[ds->index].master_netdev;
+	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	struct ethtool_wolinfo pwol;
 
@@ -829,7 +829,7 @@ static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
 static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 			      struct ethtool_wolinfo *wol)
 {
-	struct net_device *p = ds->dst[ds->index].master_netdev;
+	struct net_device *p = ds->dst[ds->index].cpu_dp->netdev;
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	s8 cpu_port = ds->dst->cpu_dp->index;
 	struct ethtool_wolinfo pwol;
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 25e00d5e0eec..1e46418a3b74 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -912,11 +912,11 @@ mt7530_setup(struct dsa_switch *ds)
 	struct device_node *dn;
 	struct mt7530_dummy_poll p;
 
-	/* The parent node of master_netdev which holds the common system
+	/* The parent node of cpu_dp->netdev which holds the common system
 	 * controller also is the container for two GMACs nodes representing
 	 * as two netdev instances.
 	 */
-	dn = ds->master_netdev->dev.of_node->parent;
+	dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
 	priv->ethernet = syscon_node_to_regmap(dn);
 	if (IS_ERR(priv->ethernet))
 		return PTR_ERR(priv->ethernet);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2effb0af9d7c..b2fb53f5e28e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -227,11 +227,6 @@ struct dsa_switch {
 	s8		rtable[DSA_MAX_SWITCHES];
 
 	/*
-	 * The lower device this switch uses to talk to the host
-	 */
-	struct net_device *master_netdev;
-
-	/*
 	 * Slave mii_bus and devices for the individual ports.
 	 */
 	u32			dsa_port_mask;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fdc448b30e56..eaab1affeeeb 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -118,10 +118,7 @@ int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
 	struct net_device *master;
 	struct ethtool_ops *cpu_ops;
 
-	master = ds->dst->master_netdev;
-	if (ds->master_netdev)
-		master = ds->master_netdev;
-
+	master = ds->dst->cpu_dp->netdev;
 	cpu_ops = devm_kzalloc(ds->dev, sizeof(*cpu_ops), GFP_KERNEL);
 	if (!cpu_ops)
 		return -ENOMEM;
@@ -142,9 +139,7 @@ void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp)
 	struct dsa_switch *ds = cpu_dp->ds;
 	struct net_device *master;
 
-	master = ds->dst->master_netdev;
-	if (ds->master_netdev)
-		master = ds->master_netdev;
+	master = ds->dst->cpu_dp->netdev;
 
 	master->ethtool_ops = ds->dst->master_orig_ethtool_ops;
 }
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index cd13bb54a30c..2674bdf03fef 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -337,7 +337,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		return err;
 
 	if (ds->ops->set_addr) {
-		err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
+		err = ds->ops->set_addr(ds, dst->cpu_dp->netdev->dev_addr);
 		if (err < 0)
 			return err;
 	}
@@ -444,7 +444,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dst->master_netdev->dsa_ptr = dst;
+	dst->cpu_dp->netdev->dsa_ptr = dst;
 	dst->applied = true;
 
 	return 0;
@@ -458,7 +458,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	if (!dst->applied)
 		return;
 
-	dst->master_netdev->dsa_ptr = NULL;
+	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point get sent
@@ -502,14 +502,10 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
-	if (!ds->master_netdev)
-		ds->master_netdev = ethernet_dev;
-
-	if (!dst->master_netdev)
-		dst->master_netdev = ethernet_dev;
-
-	if (!dst->cpu_dp)
+	if (!dst->cpu_dp) {
 		dst->cpu_dp = port;
+		dst->cpu_dp->netdev = ethernet_dev;
+	}
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
 	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
@@ -576,7 +572,7 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (!dst->master_netdev) {
+	if (!dst->cpu_dp->netdev) {
 		pr_warn("Tree has no master device\n");
 		return -EINVAL;
 	}
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 66ee248796c8..5c510f4ba0ce 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -183,4 +183,9 @@ extern const struct dsa_device_ops qca_netdev_ops;
 /* tag_trailer.c */
 extern const struct dsa_device_ops trailer_netdev_ops;
 
+static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
+{
+	return p->dp->ds->dst->cpu_dp->netdev;
+}
+
 #endif
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index d534d8f4b9cf..443ebf3b5e5b 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -101,9 +101,12 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	struct dsa_switch_tree *dst = ds->dst;
 	struct dsa_chip_data *cd = ds->cd;
 	bool valid_name_found = false;
+	struct net_device *master;
 	int index = ds->index;
 	int i, ret;
 
+	master = dst->cpu_dp->netdev;
+
 	/*
 	 * Validate supplied switch configuration.
 	 */
@@ -116,7 +119,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 
 		if (!strcmp(name, "cpu")) {
 			if (dst->cpu_dp) {
-				netdev_err(dst->master_netdev,
+				netdev_err(master,
 					   "multiple cpu ports?!\n");
 				return -EINVAL;
 			}
@@ -168,7 +171,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		return ret;
 
 	if (ops->set_addr) {
-		ret = ops->set_addr(ds, dst->master_netdev->dev_addr);
+		ret = ops->set_addr(ds, master->dev_addr);
 		if (ret < 0)
 			return ret;
 	}
@@ -195,14 +198,14 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 
 		ret = dsa_slave_create(ds, parent, i, cd->port_names[i]);
 		if (ret < 0)
-			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
+			netdev_err(master, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
 				   index, i, cd->port_names[i], ret);
 	}
 
 	/* Perform configuration of the CPU and DSA ports */
 	ret = dsa_cpu_dsa_setups(ds, parent);
 	if (ret < 0)
-		netdev_err(dst->master_netdev, "[%d] : can't configure CPU and DSA ports\n",
+		netdev_err(master, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
 
 	ret = dsa_cpu_port_ethtool_setup(ds->dst->cpu_dp);
@@ -217,6 +220,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		 struct device *parent, struct device *host_dev)
 {
 	struct dsa_chip_data *cd = dst->pd->chip + index;
+	struct net_device *master = dst->cpu_dp->netdev;
 	const struct dsa_switch_ops *ops;
 	struct dsa_switch *ds;
 	int ret;
@@ -228,11 +232,11 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	 */
 	ops = dsa_switch_probe(parent, host_dev, cd->sw_addr, &name, &priv);
 	if (!ops) {
-		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
+		netdev_err(master, "[%d]: could not detect attached switch\n",
 			   index);
 		return ERR_PTR(-EINVAL);
 	}
-	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
+	netdev_info(master, "[%d]: detected a %s switch\n",
 		    index, name);
 
 
@@ -622,7 +626,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	unsigned configured = 0;
 
 	dst->pd = pd;
-	dst->master_netdev = dev;
+	dst->cpu_dp->netdev = dev;
 
 	for (i = 0; i < pd->nr_chips; i++) {
 		struct dsa_switch *ds;
@@ -718,7 +722,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
-	dst->master_netdev->dsa_ptr = NULL;
+	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point get sent
@@ -735,7 +739,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 
 	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
 
-	dev_put(dst->master_netdev);
+	dev_put(dst->cpu_dp->netdev);
 }
 
 static int dsa_remove(struct platform_device *pdev)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1cfdb31a2f44..d52c9ceb0566 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -66,7 +66,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	return p->dp->ds->dst->master_netdev->ifindex;
+	return dsa_master_netdev(p)->ifindex;
 }
 
 static int dsa_slave_open(struct net_device *dev)
@@ -74,7 +74,7 @@ static int dsa_slave_open(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_port *dp = p->dp;
 	struct dsa_switch *ds = dp->ds;
-	struct net_device *master = ds->dst->master_netdev;
+	struct net_device *master = dsa_master_netdev(p);
 	u8 stp_state = dp->bridge_dev ? BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
@@ -127,7 +127,7 @@ static int dsa_slave_open(struct net_device *dev)
 static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->dp->ds->dst->master_netdev;
+	struct net_device *master = dsa_master_netdev(p);
 	struct dsa_switch *ds = p->dp->ds;
 
 	if (p->phy)
@@ -154,7 +154,7 @@ static int dsa_slave_close(struct net_device *dev)
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->dp->ds->dst->master_netdev;
+	struct net_device *master = dsa_master_netdev(p);
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -165,7 +165,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->dp->ds->dst->master_netdev;
+	struct net_device *master = dsa_master_netdev(p);
 
 	dev_mc_sync(master, dev);
 	dev_uc_sync(master, dev);
@@ -174,7 +174,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->dp->ds->dst->master_netdev;
+	struct net_device *master = dsa_master_netdev(p);
 	struct sockaddr *addr = a;
 	int err;
 
@@ -375,7 +375,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	nskb->dev = p->dp->ds->dst->master_netdev;
+	nskb->dev = dsa_master_netdev(p);
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -684,7 +684,7 @@ static int dsa_slave_netpoll_setup(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
-	struct net_device *master = ds->dst->master_netdev;
+	struct net_device *master = dsa_master_netdev(p);
 	struct netpoll *netpoll;
 	int err = 0;
 
@@ -1141,9 +1141,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	struct dsa_slave_priv *p;
 	int ret;
 
-	master = ds->dst->master_netdev;
-	if (ds->master_netdev)
-		master = ds->master_netdev;
+	master = ds->dst->cpu_dp->netdev;
 
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
-- 
2.9.3
