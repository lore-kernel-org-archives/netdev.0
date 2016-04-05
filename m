From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: make the VLAN add function return void
Date: Tue,  5 Apr 2016 11:24:35 -0400
Message-ID: <1459869875-23815-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The switchdev design implies that a software error should not happen in
the commit phase since it must have been previously reported in the
prepare phase. If an hardware error occurs during the commit phase,
there is nothing switchdev can do about it.

The DSA layer separates port_vlan_prepare and port_vlan_add for
simplicity and convenience. If an hardware error occurs during the
commit phase, there is no need to report it outside the driver itself.

Make the DSA port_vlan_add routine return void for explicitness.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 26 +++++++++++---------------
 drivers/net/dsa/mv88e6xxx.h |  6 +++---
 include/net/dsa.h           |  2 +-
 net/dsa/slave.c             | 11 +++--------
 4 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index bca9a2c..2911f91 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1908,31 +1908,27 @@ static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 	return _mv88e6xxx_vtu_loadpurge(ds, &vlan);
 }
 
-int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
-			    const struct switchdev_obj_port_vlan *vlan,
-			    struct switchdev_trans *trans)
+void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_vlan *vlan,
+			     struct switchdev_trans *trans)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	bool pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 	u16 vid;
-	int err = 0;
 
 	mutex_lock(&ps->smi_mutex);
 
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		err = _mv88e6xxx_port_vlan_add(ds, port, vid, untagged);
-		if (err)
-			goto unlock;
-	}
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
+		if (_mv88e6xxx_port_vlan_add(ds, port, vid, untagged))
+			netdev_warn(ds->ports[port], "cannot add VLAN %d%c\n",
+				    vid, untagged ? 'u' : 't');
 
-	/* no PVID with ranges, otherwise it's a bug */
-	if (pvid)
-		err = _mv88e6xxx_port_pvid_set(ds, port, vlan->vid_end);
-unlock:
-	mutex_unlock(&ps->smi_mutex);
+	if (pvid && _mv88e6xxx_port_pvid_set(ds, port, vlan->vid_end))
+		netdev_warn(ds->ports[port], "cannot set PVID %d\n",
+			    vlan->vid_end);
 
-	return err;
+	mutex_unlock(&ps->smi_mutex);
 }
 
 static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index ece008f..ad59022 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -503,9 +503,9 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_vlan *vlan,
 				struct switchdev_trans *trans);
-int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
-			    const struct switchdev_obj_port_vlan *vlan,
-			    struct switchdev_trans *trans);
+void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_vlan *vlan,
+			     struct switchdev_trans *trans);
 int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_vlan *vlan);
 int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fa42b8c..071b50d 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -309,7 +309,7 @@ struct dsa_switch_driver {
 	int	(*port_vlan_prepare)(struct dsa_switch *ds, int port,
 				     const struct switchdev_obj_port_vlan *vlan,
 				     struct switchdev_trans *trans);
-	int	(*port_vlan_add)(struct dsa_switch *ds, int port,
+	void	(*port_vlan_add)(struct dsa_switch *ds, int port,
 				 const struct switchdev_obj_port_vlan *vlan,
 				 struct switchdev_trans *trans);
 	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5a34bab..134b76e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -207,21 +207,16 @@ static int dsa_slave_port_vlan_add(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int err;
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->drv->port_vlan_prepare || !ds->drv->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		err = ds->drv->port_vlan_prepare(ds, p->port, vlan, trans);
-		if (err)
-			return err;
-	} else {
-		err = ds->drv->port_vlan_add(ds, p->port, vlan, trans);
-		if (err)
-			return err;
+		return ds->drv->port_vlan_prepare(ds, p->port, vlan, trans);
 	}
 
+	ds->drv->port_vlan_add(ds, p->port, vlan, trans);
+
 	return 0;
 }
 
-- 
2.8.0
