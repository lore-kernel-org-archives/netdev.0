From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [RFC] hardware bridging support for DSA switches
Date: Mon, 5 Jan 2009 11:36:01 +0100
Message-ID: <20090105103601.GP22131@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felix Fietkau <nbd@openwrt.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <linux@ddcrew.com>,
	Imre Kaloz <kaloz@openwrt.org>
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:60924 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZAEKgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 05:36:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently, the DSA switch driver (do 'git show 91da11f870' to refresh
your memory) treats every port on the connected hardware switch chip
as a single Linux network interface, and any hardware bridging/routing
capabilities that the switch chip might have are not used.

In the past, there have been various ways of configuring external
hardware that can offload things like bridging, routing, firewalling,
etc.  What most of those methods had in common was that they are not
transparent to the user -- they bypass the Linux networking stack
and present their own configuration API, require the system admin to
use special tools to configure them, etc.


The attached patch enables hardware bridging for the 88e6123/6161/6165
DSA ethernet switch chips by mirroring the configuration of Linux
bridge interfaces into the hardware, requiring no extra tools to
configure the hardware bridging capabilities of the chip.

(While the patch in itself works, the implementation is ugly, and I
don't see it being merged upstream in this form any time soon -- I'm
sending it to encourage discussion about what the right way of doing
this should be.)

Basically, if you do:

	# brctl addbr br0
	# brctl addif br0 lan1
	# brctl addif br0 lan2

And if lan1 and lan2 are interfaces on the same DSA switch chip, this
patch will program the switch to tell it that lan1 and lan2 are now
part of the same port group, are to share MAC address databases, and
are allowed to directly forward packets to each other.  The regular
ethtool stats interfaces can be used to determine the byte/packet
counts of all frames forwarded in hardware.


While conceptually I think this is the way this should work (i.e. no
workflow changes for the system administrator), the code shouldn't be
hooking directly into the bridge code at all.  Ideally, it should
just be using a netlink interface providing this info:
- bridge port group creation/destruction
- adding/removing an interface to/from a bridge port group
- changing the STP state of an interface in a bridge port group

>From a quick look, the current net/bridge/ netlink code allows
configuring the bridge from userland, but doesn't seem to be
providing notification in all cases of interest (e.g. when the kernel
STP code changes the STP state of a port, there doesn't seem to be a
notification) -- but I'll have to look into that a bit further.


In any case, any comments about the above appreciated.


thanks,
Lennert




diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0107ec0..ccc78c7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -717,6 +717,12 @@ struct net_device
 #define HAVE_TX_TIMEOUT
 	void			(*tx_timeout) (struct net_device *dev);
 
+	void			(*bridge_join)(struct net_device *dev,
+					       void *bridge);
+	void			(*bridge_set_stp_state)(struct net_device *dev,
+							int state);
+	void			(*bridge_leave)(struct net_device *dev);
+
 	void			(*vlan_rx_register)(struct net_device *dev,
 						    struct vlan_group *grp);
 	void			(*vlan_rx_add_vid)(struct net_device *dev,
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 0a09ccf..e4eb926 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -139,6 +139,9 @@ static void del_nbp(struct net_bridge_port *p)
 	br_stp_disable_port(p);
 	spin_unlock_bh(&br->lock);
 
+	if (dev->bridge_leave != NULL)
+		dev->bridge_leave(dev);
+
 	br_ifinfo_notify(RTM_DELLINK, p);
 
 	br_fdb_delete_by_port(br, p, 1);
@@ -409,6 +412,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
 
+	if (dev->bridge_join != NULL)
+		dev->bridge_join(dev, (void *)br);
+
 	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
 	    (br->dev->flags & IFF_UP))
 		br_stp_enable_port(p);
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 6e63ec3..09fe4b0 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -35,6 +35,8 @@ void br_log_state(const struct net_bridge_port *p)
 		p->br->dev->name, p->port_no, p->dev->name,
 		br_port_state_names[p->state]);
 
+	if (p->dev->bridge_set_stp_state != NULL)
+		p->dev->bridge_set_stp_state(p->dev, p->state);
 }
 
 /* called under bridge lock */
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 9a52ac5..7d69235 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -94,12 +94,11 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	int wasroot;
 
 	br = p->br;
-	printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-	       br->dev->name, p->port_no, p->dev->name, "disabled");
 
 	wasroot = br_is_root_bridge(br);
 	br_become_designated_port(p);
 	p->state = BR_STATE_DISABLED;
+	br_log_state(p);
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7063378..f67f99b 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -90,6 +90,15 @@ struct dsa_switch_driver {
 	void	(*get_ethtool_stats)(struct dsa_switch *ds,
 				     int port, uint64_t *data);
 	int	(*get_sset_count)(struct dsa_switch *ds);
+
+	/*
+	 * Hardware bridging.
+	 */
+	void	(*bridge_join)(struct dsa_switch *ds, int port,
+			       void *bridge);
+	void	(*bridge_set_stp_state)(struct dsa_switch *ds, int port,
+					int state);
+	void	(*bridge_leave)(struct dsa_switch *ds, int port);
 };
 
 /* dsa.c */
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index 555b164..66cbc14 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -8,6 +8,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/if_bridge.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -207,10 +208,9 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 			 0x0433);
 
 	/*
-	 * Port Control 1: disable trunking.  Also, if this is the
-	 * CPU port, enable learn messages to be sent to this port.
+	 * Port Control 1: disable trunking.
 	 */
-	REG_WRITE(addr, 0x05, (p == ds->cpu_port) ? 0x8000 : 0x0000);
+	REG_WRITE(addr, 0x05, 0x0000);
 
 	/*
 	 * Port based VLAN map: give each port its own address
@@ -290,6 +290,8 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	return 0;
 }
 
+static void mv88e6123_61_65_hw_bridge_sync_work(struct work_struct *ugly);
+
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
@@ -298,6 +300,8 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 
 	mutex_init(&ps->smi_mutex);
 	mutex_init(&ps->stats_mutex);
+	spin_lock_init(&ps->hw_bridge_state);
+	INIT_WORK(&ps->hw_bridge_work, mv88e6123_61_65_hw_bridge_sync_work);
 
 	ret = mv88e6123_61_65_switch_reset(ds);
 	if (ret < 0)
@@ -313,6 +317,10 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 		ret = mv88e6123_61_65_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
+
+		// @@@
+		ps->fid[i] = i;
+		ps->stp_state[i] = 3;
 	}
 
 	return 0;
@@ -393,6 +401,159 @@ static int mv88e6123_61_65_get_sset_count(struct dsa_switch *ds)
 	return ARRAY_SIZE(mv88e6123_61_65_hw_stats);
 }
 
+static void mv88e6123_61_65_hw_bridge_sync_work(struct work_struct *ugly)
+{
+	struct mv88e6xxx_priv_state *ps;
+	struct dsa_switch *ds;
+	int i;
+
+	ps = container_of(ugly, struct mv88e6xxx_priv_state, hw_bridge_work);
+	ds = ((struct dsa_switch *)ps) - 1;
+
+	spin_lock(&ps->hw_bridge_state);
+	for (i = 0; i < MV88E6XXX_MAX_PORTS; i++) {
+		if (ps->fid_dirty[i]) {
+			int reg;
+			int j;
+
+			reg = (ps->fid[i] << 12) | (1 << ds->cpu_port);
+			ps->fid_dirty[i] = 0;
+
+			for (j = 0; j < MV88E6XXX_MAX_PORTS; j++) {
+				if (i != j && ps->bridge[i] != NULL &&
+				    ps->bridge[i] == ps->bridge[j]) {
+					reg |= 1 << j;
+				}
+			}
+
+			spin_unlock(&ps->hw_bridge_state);
+			mv88e6xxx_reg_write(ds, REG_PORT(i), 6, reg);
+			spin_lock(&ps->hw_bridge_state);
+		}
+
+		if (ps->stp_state_dirty[i]) {
+			int new_state;
+			int reg;
+
+			new_state = ps->stp_state[i];
+			ps->stp_state_dirty[i] = 0;
+			spin_unlock(&ps->hw_bridge_state);
+			reg = mv88e6xxx_reg_read(ds, REG_PORT(i), 4);
+			if (reg >= 0) {
+				reg &= ~0x0003;
+				reg |= new_state;
+				mv88e6xxx_reg_write(ds, REG_PORT(i), 4, reg);
+			}
+			spin_lock(&ps->hw_bridge_state);
+		}
+	}
+	spin_unlock(&ps->hw_bridge_state);
+}
+
+static void
+set_stp_state(struct dsa_switch *ds, int port, int state)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	int hw_state = 0;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		hw_state = 0;
+		break;
+	case BR_STATE_BLOCKING:
+	case BR_STATE_LISTENING:
+		hw_state = 1;
+		break;
+	case BR_STATE_LEARNING:
+		hw_state = 2;
+		break;
+	case BR_STATE_FORWARDING:
+		hw_state = 3;
+		break;
+	default:
+		BUG();
+	}
+
+	if (ps->stp_state[port] != hw_state) {
+		ps->stp_state_dirty[port] = 1;
+		ps->stp_state[port] = hw_state;
+	}
+}
+
+static void
+mv88e6123_61_65_bridge_join(struct dsa_switch *ds, int port, void *bridge)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	int fid;
+	int i;
+
+	spin_lock(&ps->hw_bridge_state);
+
+	fid = 65536;
+	for (i = 0; i < MV88E6XXX_MAX_PORTS; i++) {
+		if (ps->bridge[i] == bridge) {
+			if (ps->fid[i] < fid)
+				fid = ps->fid[i];
+			ps->fid_dirty[i] = 1;
+		}
+	}
+
+	ps->bridge[port] = bridge;
+
+	ps->fid_dirty[port] = 1;
+	if (fid != 65536)
+		ps->fid[port] = fid;
+
+	set_stp_state(ds, port, BR_STATE_DISABLED);
+
+	spin_unlock(&ps->hw_bridge_state);
+
+	schedule_work(&ps->hw_bridge_work);
+}
+
+static void
+mv88e6123_61_65_bridge_set_stp_state(struct dsa_switch *ds, int port, int state)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+
+	spin_lock(&ps->hw_bridge_state);
+	set_stp_state(ds, port, state);
+	spin_unlock(&ps->hw_bridge_state);
+
+	schedule_work(&ps->hw_bridge_work);
+}
+
+static void mv88e6123_61_65_bridge_leave(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	u16 free_fids;
+	int i;
+	int fid;
+
+	spin_lock(&ps->hw_bridge_state);
+
+	free_fids = 0xffff;
+	for (i = 0; i < MV88E6XXX_MAX_PORTS; i++) {
+		if (i == ds->cpu_port || ds->valid_port_mask & (1 << i)) {
+			if (ps->bridge[i] == ps->bridge[port])
+				ps->fid_dirty[i] = 1;
+			if (i != port)
+				free_fids &= ~(1 << ps->fid[i]);
+		}
+	}
+
+	fid = ffs(free_fids) - 1;
+
+	ps->fid[port] = fid;
+	ps->bridge[port] = NULL;
+
+	set_stp_state(ds, port, BR_STATE_FORWARDING);
+
+	spin_unlock(&ps->hw_bridge_state);
+
+	schedule_work(&ps->hw_bridge_work);
+}
+
 static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.tag_protocol		= __constant_htons(ETH_P_EDSA),
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
@@ -405,6 +566,9 @@ static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_strings		= mv88e6123_61_65_get_strings,
 	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
 	.get_sset_count		= mv88e6123_61_65_get_sset_count,
+	.bridge_join		= mv88e6123_61_65_bridge_join,
+	.bridge_set_stp_state	= mv88e6123_61_65_bridge_set_stp_state,
+	.bridge_leave		= mv88e6123_61_65_bridge_leave,
 };
 
 int __init mv88e6123_61_65_init(void)
diff --git a/net/dsa/mv88e6xxx.h b/net/dsa/mv88e6xxx.h
index eb0e0aa..8f0fe44 100644
--- a/net/dsa/mv88e6xxx.h
+++ b/net/dsa/mv88e6xxx.h
@@ -15,6 +15,8 @@
 #define REG_GLOBAL		0x1b
 #define REG_GLOBAL2		0x1c
 
+#define MV88E6XXX_MAX_PORTS	11
+
 struct mv88e6xxx_priv_state {
 	/*
 	 * When using multi-chip addressing, this mutex protects
@@ -39,6 +41,17 @@ struct mv88e6xxx_priv_state {
 	 * Hold this mutex over snapshot + dump sequences.
 	 */
 	struct mutex	stats_mutex;
+
+	/*
+	 * Hardware bridging state.
+	 */
+	spinlock_t	hw_bridge_state;
+	struct work_struct	hw_bridge_work;
+	void		*bridge[MV88E6XXX_MAX_PORTS];
+	int		fid_dirty[MV88E6XXX_MAX_PORTS];
+	int		fid[MV88E6XXX_MAX_PORTS];
+	int		stp_state_dirty[MV88E6XXX_MAX_PORTS];
+	int		stp_state[MV88E6XXX_MAX_PORTS];
 };
 
 struct mv88e6xxx_hw_stat {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5cb314c..abc6c77 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -163,6 +163,33 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static void dsa_bridge_join(struct net_device *dev, void *bridge)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->bridge_join != NULL)
+		ds->drv->bridge_join(ds, p->port, bridge);
+}
+
+static void dsa_bridge_set_stp_state(struct net_device *dev, int state)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->bridge_set_stp_state != NULL)
+		ds->drv->bridge_set_stp_state(ds, p->port, state);
+}
+
+static void dsa_bridge_leave(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->bridge_leave != NULL)
+		ds->drv->bridge_leave(ds, p->port);
+}
+
 
 /* ethtool operations *******************************************************/
 static int
@@ -335,6 +362,9 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->set_multicast_list = dsa_slave_set_rx_mode;
 	slave_dev->set_mac_address = dsa_slave_set_mac_address;
 	slave_dev->do_ioctl = dsa_slave_ioctl;
+	slave_dev->bridge_join = dsa_bridge_join;
+	slave_dev->bridge_set_stp_state = dsa_bridge_set_stp_state;
+	slave_dev->bridge_leave = dsa_bridge_leave;
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->vlan_features = master->vlan_features;
 
