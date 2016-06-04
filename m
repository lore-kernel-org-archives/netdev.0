From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 05/17] net: dsa: Add a ports structure and use it in the switch structure
Date: Sat,  4 Jun 2016 21:16:57 +0200
Message-ID: <1465067829-1875-8-git-send-email-andrew@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59562 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbcFDTYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:24:11 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are going to be more per-port members added to the switch
structure. So add a port structure and move the netdev into it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c   |  4 ++--
 drivers/net/dsa/mv88e6xxx.c | 27 ++++++++++++++++-----------
 include/net/dsa.h           |  8 ++++++--
 net/dsa/dsa.c               |  8 ++++----
 net/dsa/slave.c             |  4 ++--
 net/dsa/tag_brcm.c          |  4 ++--
 net/dsa/tag_dsa.c           |  4 ++--
 net/dsa/tag_edsa.c          |  4 ++--
 net/dsa/tag_trailer.c       |  4 ++--
 9 files changed, 38 insertions(+), 29 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 10ddd5a5dfb6..73df91bb0466 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -804,7 +804,7 @@ static int bcm_sf2_sw_fdb_dump(struct dsa_switch *ds, int port,
 			       int (*cb)(struct switchdev_obj *obj))
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	struct net_device *dev = ds->ports[port];
+	struct net_device *dev = ds->ports[port].netdev;
 	struct bcm_sf2_arl_entry results[2];
 	unsigned int count = 0;
 	int ret;
@@ -1248,7 +1248,7 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		 * state machine and make it go in PHY_FORCING state instead.
 		 */
 		if (!status->link)
-			netif_carrier_off(ds->ports[port]);
+			netif_carrier_off(ds->ports[port].netdev);
 		status->duplex = 1;
 	} else {
 		status->link = 1;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c361036e7f9c..85332d9a245a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1327,7 +1327,7 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
 		if (ret)
 			return ret;
 
-		netdev_dbg(ds->ports[port], "PortState %s (was %s)\n",
+		netdev_dbg(ds->ports[port].netdev, "PortState %s (was %s)\n",
 			   mv88e6xxx_port_state_names[state],
 			   mv88e6xxx_port_state_names[oldstate]);
 	}
@@ -1405,7 +1405,8 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 	mutex_unlock(&ps->smi_mutex);
 
 	if (err)
-		netdev_err(ds->ports[port], "failed to update state to %s\n",
+		netdev_err(ds->ports[port].netdev,
+			   "failed to update state to %s\n",
 			   mv88e6xxx_port_state_names[stp_state]);
 }
 
@@ -1431,8 +1432,8 @@ static int _mv88e6xxx_port_pvid(struct mv88e6xxx_priv_state *ps, int port,
 		if (ret < 0)
 			return ret;
 
-		netdev_dbg(ds->ports[port], "DefaultVID %d (was %d)\n", *new,
-			   pvid);
+		netdev_dbg(ds->ports[port].netdev,
+			   "DefaultVID %d (was %d)\n", *new, pvid);
 	}
 
 	if (old)
@@ -1847,7 +1848,8 @@ static int _mv88e6xxx_port_fid(struct mv88e6xxx_priv_state *ps, int port,
 		if (ret < 0)
 			return ret;
 
-		netdev_dbg(ds->ports[port], "FID %d (was %d)\n", *new, fid);
+		netdev_dbg(ds->ports[port].netdev,
+			   "FID %d (was %d)\n", *new, fid);
 	}
 
 	if (old)
@@ -2028,7 +2030,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			    ps->ports[port].bridge_dev)
 				break; /* same bridge, check next VLAN */
 
-			netdev_warn(ds->ports[port],
+			netdev_warn(ds->ports[port].netdev,
 				    "hardware VLAN %d already used by %s\n",
 				    vlan.vid,
 				    netdev_name(ps->ports[i].bridge_dev));
@@ -2078,7 +2080,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		if (ret < 0)
 			goto unlock;
 
-		netdev_dbg(ds->ports[port], "802.1Q Mode %s (was %s)\n",
+		netdev_dbg(ds->ports[port].netdev, "802.1Q Mode %s (was %s)\n",
 			   mv88e6xxx_port_8021q_mode_names[new],
 			   mv88e6xxx_port_8021q_mode_names[old]);
 	}
@@ -2147,11 +2149,12 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
 		if (_mv88e6xxx_port_vlan_add(ps, port, vid, untagged))
-			netdev_err(ds->ports[port], "failed to add VLAN %d%c\n",
+			netdev_err(ds->ports[port].netdev,
+				   "failed to add VLAN %d%c\n",
 				   vid, untagged ? 'u' : 't');
 
 	if (pvid && _mv88e6xxx_port_pvid_set(ps, port, vlan->vid_end))
-		netdev_err(ds->ports[port], "failed to set PVID %d\n",
+		netdev_err(ds->ports[port].netdev, "failed to set PVID %d\n",
 			   vlan->vid_end);
 
 	mutex_unlock(&ps->smi_mutex);
@@ -2336,7 +2339,8 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 	if (_mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid, state))
-		netdev_err(ds->ports[port], "failed to load MAC address\n");
+		netdev_err(ds->ports[port].netdev,
+			   "failed to load MAC address\n");
 	mutex_unlock(&ps->smi_mutex);
 }
 
@@ -2537,7 +2541,8 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	for (i = 0; i < ps->info->num_ports; ++i)
 		if (i == port || ps->ports[i].bridge_dev == bridge)
 			if (_mv88e6xxx_port_based_vlan_map(ps, i))
-				netdev_warn(ds->ports[i], "failed to remap\n");
+				netdev_warn(ds->ports[i].netdev,
+					    "failed to remap\n");
 
 	mutex_unlock(&ps->smi_mutex);
 }
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 17c3d37b6779..9aed8572037c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -119,6 +119,10 @@ struct dsa_switch_tree {
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
 };
 
+struct dsa_port {
+	struct net_device	*netdev;
+};
+
 struct dsa_switch {
 	struct device *dev;
 
@@ -158,8 +162,8 @@ struct dsa_switch {
 	u32			dsa_port_mask;
 	u32			enabled_port_mask;
 	u32			phys_mii_mask;
+	struct dsa_port		ports[DSA_MAX_PORTS];
 	struct mii_bus		*slave_mii_bus;
-	struct net_device	*ports[DSA_MAX_PORTS];
 };
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
@@ -174,7 +178,7 @@ static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
 
 static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 {
-	return ds->enabled_port_mask & (1 << p) && ds->ports[p];
+	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
 }
 
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index eff5dfc2e33f..18086e0cc617 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -437,10 +437,10 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		if (!(ds->enabled_port_mask & (1 << port)))
 			continue;
 
-		if (!ds->ports[port])
+		if (!ds->ports[port].netdev)
 			continue;
 
-		dsa_slave_destroy(ds->ports[port]);
+		dsa_slave_destroy(ds->ports[port].netdev);
 	}
 
 	/* Remove any fixed link PHYs */
@@ -469,7 +469,7 @@ static int dsa_switch_suspend(struct dsa_switch *ds)
 		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
-		ret = dsa_slave_suspend(ds->ports[i]);
+		ret = dsa_slave_suspend(ds->ports[i].netdev);
 		if (ret)
 			return ret;
 	}
@@ -495,7 +495,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
 		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
-		ret = dsa_slave_resume(ds->ports[i]);
+		ret = dsa_slave_resume(ds->ports[i].netdev);
 		if (ret)
 			return ret;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f640a48a6ff3..169abacbc6ce 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1183,12 +1183,12 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->old_link = -1;
 	p->old_duplex = -1;
 
-	ds->ports[port] = slave_dev;
+	ds->ports[port].netdev = slave_dev;
 	ret = register_netdev(slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d registering interface %s\n",
 			   ret, slave_dev->name);
-		ds->ports[port] = NULL;
+		ds->ports[port].netdev = NULL;
 		free_netdev(slave_dev);
 		return ret;
 	}
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index e2aadb73111d..21bffde6e4bf 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -127,7 +127,7 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
 
 	/* Validate port against switch setup, either the port is totally */
-	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	/* Remove Broadcom tag and update checksum */
@@ -140,7 +140,7 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
-	skb->dev = ds->ports[source_port];
+	skb->dev = ds->ports[source_port].netdev;
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
 	skb->dev->stats.rx_packets++;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index f9832f097681..bce79ffe342b 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -114,7 +114,7 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!ds)
 		goto out_drop;
 
-	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	/*
@@ -163,7 +163,7 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			2 * ETH_ALEN);
 	}
 
-	skb->dev = ds->ports[source_port];
+	skb->dev = ds->ports[source_port].netdev;
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 3890aac8190f..6c1720e88537 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -127,7 +127,7 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!ds)
 		goto out_drop;
 
-	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	/*
@@ -182,7 +182,7 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			2 * ETH_ALEN);
 	}
 
-	skb->dev = ds->ports[source_port];
+	skb->dev = ds->ports[source_port].netdev;
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b6ca0890d018..5e3903eb1afa 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -82,12 +82,12 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out_drop;
 
 	source_port = trailer[1] & 7;
-	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
+	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	pskb_trim_rcsum(skb, skb->len - 4);
 
-	skb->dev = ds->ports[source_port];
+	skb->dev = ds->ports[source_port].netdev;
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
-- 
2.8.1
