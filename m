From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/4] net: dsa: mv88e6xxx: bridges do not need an FID
Date: Sun, 11 Oct 2015 18:08:35 -0400
Message-ID: <1444601318-20561-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 88E6352 and similar switch chips, each port has a map to restrict
which output port this input port can egress frames to.

The current driver code implements hardware bridging using this feature,
and assigns to a bridge group the FID of its first member.

Now that 802.1Q is fully implemented in this driver, a Linux bridge
which is a simple untagged VLAN, already gets its own FID.

This patch gets rid of the per-bridge FID and explicits the usage of the
port based VLAN map feature.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 157 +++++++++++---------------------------------
 drivers/net/dsa/mv88e6xxx.h |   1 -
 2 files changed, 40 insertions(+), 118 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e381bfc..254f9bb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1046,11 +1046,6 @@ static int _mv88e6xxx_atu_flush(struct dsa_switch *ds, u16 fid, bool static_too)
 	return _mv88e6xxx_atu_flush_move(ds, &entry, static_too);
 }
 
-static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
-{
-	return _mv88e6xxx_atu_flush(ds, fid, false);
-}
-
 static int _mv88e6xxx_atu_move(struct dsa_switch *ds, u16 fid, int from_port,
 			       int to_port, bool static_too)
 {
@@ -1112,130 +1107,56 @@ abort:
 	return ret;
 }
 
-/* Must be called with smi lock held */
-static int _mv88e6xxx_update_port_config(struct dsa_switch *ds, int port)
+static int _mv88e6xxx_port_vlan_map_set(struct dsa_switch *ds, int port,
+					u16 output_ports)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u8 fid = ps->fid[port];
-	u16 reg = fid << 12;
+	const u16 mask = (1 << ps->num_ports) - 1;
+	int reg;
 
-	if (dsa_is_cpu_port(ds, port))
-		reg |= ds->phys_port_mask;
-	else
-		reg |= (ps->bridge_mask[fid] |
-		       (1 << dsa_upstream_port(ds))) & ~(1 << port);
+	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_BASE_VLAN);
+	if (reg < 0)
+		return reg;
+
+	reg &= ~mask;
+	reg |= output_ports & mask;
 
 	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
 
-/* Must be called with smi lock held */
-static int _mv88e6xxx_update_bridge_config(struct dsa_switch *ds, int fid)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int port;
-	u32 mask;
-	int ret;
-
-	mask = ds->phys_port_mask;
-	while (mask) {
-		port = __ffs(mask);
-		mask &= ~(1 << port);
-		if (ps->fid[port] != fid)
-			continue;
-
-		ret = _mv88e6xxx_update_port_config(ds, port);
-		if (ret)
-			return ret;
-	}
-
-	return _mv88e6xxx_flush_fid(ds, fid);
-}
-
 /* Bridge handling functions */
 
+static int mv88e6xxx_map_bridge(struct dsa_switch *ds, u16 members)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	const unsigned long output = members | BIT(dsa_upstream_port(ds));
+	int port, err = 0;
+
+	mutex_lock(&ps->smi_mutex);
+
+	for_each_set_bit(port, &output, ps->num_ports) {
+		if (dsa_is_cpu_port(ds, port))
+			continue;
+
+		err = _mv88e6xxx_port_vlan_map_set(ds, port, output & ~port);
+		if (err)
+			break;
+	}
+
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
+}
+
+
 int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret = 0;
-	u32 nmask;
-	int fid;
-
-	/* If the bridge group is not empty, join that group.
-	 * Otherwise create a new group.
-	 */
-	fid = ps->fid[port];
-	nmask = br_port_mask & ~(1 << port);
-	if (nmask)
-		fid = ps->fid[__ffs(nmask)];
-
-	nmask = ps->bridge_mask[fid] | (1 << port);
-	if (nmask != br_port_mask) {
-		netdev_err(ds->ports[port],
-			   "join: Bridge port mask mismatch fid=%d mask=0x%x expected 0x%x\n",
-			   fid, br_port_mask, nmask);
-		return -EINVAL;
-	}
-
-	mutex_lock(&ps->smi_mutex);
-
-	ps->bridge_mask[fid] = br_port_mask;
-
-	if (fid != ps->fid[port]) {
-		clear_bit(ps->fid[port], ps->fid_bitmap);
-		ps->fid[port] = fid;
-		ret = _mv88e6xxx_update_bridge_config(ds, fid);
-	}
-
-	mutex_unlock(&ps->smi_mutex);
-
-	return ret;
+	return mv88e6xxx_map_bridge(ds, br_port_mask);
 }
 
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u8 fid, newfid;
-	int ret;
-
-	fid = ps->fid[port];
-
-	if (ps->bridge_mask[fid] != br_port_mask) {
-		netdev_err(ds->ports[port],
-			   "leave: Bridge port mask mismatch fid=%d mask=0x%x expected 0x%x\n",
-			   fid, br_port_mask, ps->bridge_mask[fid]);
-		return -EINVAL;
-	}
-
-	/* If the port was the last port of a bridge, we are done.
-	 * Otherwise assign a new fid to the port, and fix up
-	 * the bridge configuration.
-	 */
-	if (br_port_mask == (1 << port))
-		return 0;
-
-	mutex_lock(&ps->smi_mutex);
-
-	newfid = find_next_zero_bit(ps->fid_bitmap, VLAN_N_VID, 1);
-	if (unlikely(newfid > ps->num_ports)) {
-		netdev_err(ds->ports[port], "all first %d FIDs are used\n",
-			   ps->num_ports);
-		ret = -ENOSPC;
-		goto unlock;
-	}
-
-	ps->fid[port] = newfid;
-	set_bit(newfid, ps->fid_bitmap);
-	ps->bridge_mask[fid] &= ~(1 << port);
-	ps->bridge_mask[newfid] = 1 << port;
-
-	ret = _mv88e6xxx_update_bridge_config(ds, fid);
-	if (!ret)
-		ret = _mv88e6xxx_update_bridge_config(ds, newfid);
-
-unlock:
-	mutex_unlock(&ps->smi_mutex);
-
-	return ret;
+	return mv88e6xxx_map_bridge(ds, br_port_mask & ~port);
 }
 
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
@@ -2233,10 +2154,12 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	ps->fid[port] = fid;
 	set_bit(fid, ps->fid_bitmap);
 
-	if (!dsa_is_cpu_port(ds, port))
-		ps->bridge_mask[fid] = 1 << port;
+	if (dsa_is_cpu_port(ds, port))
+		reg = BIT(ps->num_ports) - 1;
+	else
+		reg = BIT(dsa_upstream_port(ds));
 
-	ret = _mv88e6xxx_update_port_config(ds, port);
+	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~port);
 	if (ret)
 		goto abort;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 1347a73..716f692 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -411,7 +411,6 @@ struct mv88e6xxx_priv_state {
 
 	DECLARE_BITMAP(fid_bitmap, VLAN_N_VID);	/* FIDs 1 to 4095 available */
 	u16 fid[DSA_MAX_PORTS];			/* per (non-bridged) port FID */
-	u16 bridge_mask[DSA_MAX_PORTS];		/* br groups (indexed by FID) */
 
 	unsigned long port_state_update_mask;
 	u8 port_state[DSA_MAX_PORTS];
-- 
2.6.0
