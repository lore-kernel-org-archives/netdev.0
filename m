From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/6] net: dsa: mv88e6xxx: implement port_fdb_dump
Date: Tue, 13 Oct 2015 11:43:01 -0400
Message-ID: <1444750983-14726-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the port_fdb_dump DSA operation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  1 +
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 65 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 +++
 4 files changed, 70 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index dfca352..489deb8 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -123,6 +123,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
+	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 796fdcb..6b8fd24 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -350,6 +350,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
+	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b4e97c1..41e630a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1799,6 +1799,71 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 	return 0;
 }
 
+int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
+			    struct switchdev_obj_port_fdb *fdb,
+			    switchdev_obj_dump_cb_t *cb)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_stu_entry vlan = {
+		.vid = GLOBAL_VTU_VID_MASK, /* all ones */
+	};
+	int err;
+
+	mutex_lock(&ps->smi_mutex);
+
+	err = _mv88e6xxx_vtu_vid_write(ds, vlan.vid);
+	if (err)
+		goto unlock;
+
+	do {
+		struct mv88e6xxx_atu_entry addr = {
+			.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
+		};
+
+		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
+		if (err)
+			break;
+
+		if (!vlan.valid)
+			break;
+
+		err = _mv88e6xxx_atu_mac_write(ds, addr.mac);
+		if (err)
+			return err;
+
+		do {
+			err = _mv88e6xxx_atu_getnext(ds, vlan.fid, &addr);
+			if (err)
+				break;
+
+			if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
+				break;
+
+			if (!addr.trunk && addr.portv_trunkid & BIT(port)) {
+				bool is_static = addr.state ==
+					(is_multicast_ether_addr(addr.mac) ?
+					 GLOBAL_ATU_DATA_STATE_MC_STATIC :
+					 GLOBAL_ATU_DATA_STATE_UC_STATIC);
+
+				fdb->vid = vlan.vid;
+				fdb->addr = addr.mac;
+				fdb->ndm_state = is_static ? NUD_NOARP :
+					NUD_REACHABLE;
+
+				err = cb(&fdb->obj);
+				if (err)
+					goto unlock;
+			}
+		} while (!is_broadcast_ether_addr(addr.mac));
+
+	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
+
+unlock:
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
+}
+
 /* get next entry for port */
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 			       unsigned char *addr, u16 *vid, bool *is_static)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index ba94f17..08e0fbb 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -481,6 +481,9 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb);
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 			       unsigned char *addr, u16 *vid, bool *is_static);
+int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
+			    struct switchdev_obj_port_fdb *fdb,
+			    switchdev_obj_dump_cb_t *cb);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
-- 
2.6.1
