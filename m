From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/4] net: dsa: mv88e6xxx: do not support per-port FID
Date: Sun, 11 Oct 2015 18:08:36 -0400
Message-ID: <1444601318-20561-3-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Since we configure a switch chip through a Linux bridge, and a bridge is
implemented as a VLAN, there is no need for per-port FID anymore.

This patch gets rid of this and simplifies the driver code since we can
now directly map all 4095 FIDs available to all VLANs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 69 ++++++++-------------------------------------
 drivers/net/dsa/mv88e6xxx.h |  5 ----
 2 files changed, 11 insertions(+), 63 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 254f9bb..787352df 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1468,6 +1468,7 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
 	struct mv88e6xxx_vtu_stu_entry vlan = {
 		.valid = true,
 		.vid = vid,
+		.fid = vid, /* We use one FID per VLAN */
 	};
 	int i;
 
@@ -1501,22 +1502,10 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
 				return err;
 		}
 
-		/* Non-bridged ports and bridge groups use FIDs from 1 to
-		 * num_ports; VLANs use FIDs from num_ports+1 to 4095.
-		 */
-		vlan.fid = find_next_zero_bit(ps->fid_bitmap, VLAN_N_VID,
-					      ps->num_ports + 1);
-		if (unlikely(vlan.fid == VLAN_N_VID)) {
-			pr_err("no more FID available for VLAN %d\n", vid);
-			return -ENOSPC;
-		}
-
 		/* Clear all MAC addresses from the new database */
 		err = _mv88e6xxx_atu_flush(ds, vlan.fid, true);
 		if (err)
 			return err;
-
-		set_bit(vlan.fid, ps->fid_bitmap);
 	}
 
 	*entry = vlan;
@@ -1556,7 +1545,6 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan;
-	bool keep = false;
 	int i, err;
 
 	mutex_lock(&ps->smi_mutex);
@@ -1574,28 +1562,22 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 	vlan.data[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
 	/* keep the VLAN unless all ports are excluded */
+	vlan.valid = false;
 	for (i = 0; i < ps->num_ports; ++i) {
 		if (dsa_is_cpu_port(ds, i))
 			continue;
 
 		if (vlan.data[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
-			keep = true;
+			vlan.valid = true;
 			break;
 		}
 	}
 
-	vlan.valid = keep;
 	err = _mv88e6xxx_vtu_loadpurge(ds, &vlan);
 	if (err)
 		goto unlock;
 
 	err = _mv88e6xxx_atu_remove(ds, vlan.fid, port, false);
-	if (err)
-		goto unlock;
-
-	if (!keep)
-		clear_bit(vlan.fid, ps->fid_bitmap);
-
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
@@ -1722,37 +1704,13 @@ static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
 	return _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_LOAD_DB);
 }
 
-static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct mv88e6xxx_vtu_stu_entry vlan;
-	int err;
-
-	if (vid == 0)
-		return ps->fid[port];
-
-	err = _mv88e6xxx_port_vtu_getnext(ds, port, vid - 1, &vlan);
-	if (err)
-		return err;
-
-	if (vlan.vid == vid)
-		return vlan.fid;
-
-	return -ENOENT;
-}
-
 static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
 				    const unsigned char *addr, u16 vid,
 				    u8 state)
 {
 	struct mv88e6xxx_atu_entry entry = { 0 };
-	int ret;
 
-	ret = _mv88e6xxx_port_vid_to_fid(ds, port, vid);
-	if (ret < 0)
-		return ret;
-
-	entry.fid = ret;
+	entry.fid = vid; /* We use one FID per VLAN */
 	entry.state = state;
 	ether_addr_copy(entry.mac, addr);
 	if (state != GLOBAL_ATU_DATA_STATE_UNUSED) {
@@ -1767,6 +1725,10 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
+	/* We don't use per-port FDB */
+	if (fdb->vid == 0)
+		return -EOPNOTSUPP;
+
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
 	 */
@@ -1864,16 +1826,11 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_atu_entry next;
-	u16 fid;
+	u16 fid = *vid; /* We use one FID per VLAN */
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_port_vid_to_fid(ds, port, *vid);
-	if (ret < 0)
-		goto unlock;
-	fid = ret;
-
 	do {
 		if (is_broadcast_ether_addr(addr)) {
 			struct mv88e6xxx_vtu_stu_entry vtu;
@@ -1924,7 +1881,7 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret, fid;
+	int ret;
 	u16 reg;
 
 	mutex_lock(&ps->smi_mutex);
@@ -2145,15 +2102,11 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	if (ret)
 		goto abort;
 
-	/* Port based VLAN map: give each port its own address
+	/* Port based VLAN map: do not give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the upstream port.
 	 */
-	fid = port + 1;
-	ps->fid[port] = fid;
-	set_bit(fid, ps->fid_bitmap);
-
 	if (dsa_is_cpu_port(ds, port))
 		reg = BIT(ps->num_ports) - 1;
 	else
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 716f692..d5ee01a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -407,11 +407,6 @@ struct mv88e6xxx_priv_state {
 	int		id; /* switch product id */
 	int		num_ports;	/* number of switch ports */
 
-	/* hw bridging */
-
-	DECLARE_BITMAP(fid_bitmap, VLAN_N_VID);	/* FIDs 1 to 4095 available */
-	u16 fid[DSA_MAX_PORTS];			/* per (non-bridged) port FID */
-
 	unsigned long port_state_update_mask;
 	u8 port_state[DSA_MAX_PORTS];
 
-- 
2.6.0
