From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 5/6] net: dsa: mv88e6xxx: remove port_fdb_getnext
Date: Tue, 20 Oct 2015 12:17:25 -0400
Message-ID: <1445357846-25720-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that port_fdb_dump is implemented and even simpler, get rid of
port_fdb_getnext.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  1 -
 drivers/net/dsa/mv88e6352.c |  1 -
 drivers/net/dsa/mv88e6xxx.c | 73 ---------------------------------------------
 drivers/net/dsa/mv88e6xxx.h |  2 --
 4 files changed, 77 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 489deb8..2c8eb6f 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -122,7 +122,6 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_fdb_prepare	= mv88e6xxx_port_fdb_prepare,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
-	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 6b8fd24..cbf4dd8 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -349,7 +349,6 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_fdb_prepare	= mv88e6xxx_port_fdb_prepare,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
-	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 	.port_fdb_dump		= mv88e6xxx_port_fdb_dump,
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6d74d75..dea31b4 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1559,33 +1559,6 @@ unlock:
 	return err;
 }
 
-static int _mv88e6xxx_port_vtu_getnext(struct dsa_switch *ds, int port, u16 vid,
-				       struct mv88e6xxx_vtu_stu_entry *entry)
-{
-	int err;
-
-	do {
-		if (vid == 4095)
-			return -ENOENT;
-
-		err = _mv88e6xxx_vtu_vid_write(ds, vid);
-		if (err)
-			return err;
-
-		err = _mv88e6xxx_vtu_getnext(ds, entry);
-		if (err)
-			return err;
-
-		if (!entry->valid)
-			return -ENOENT;
-
-		vid = entry->vid;
-	} while (entry->data[port] != GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED &&
-		 entry->data[port] != GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED);
-
-	return 0;
-}
-
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged)
 {
@@ -1864,52 +1837,6 @@ unlock:
 	return err;
 }
 
-/* get next entry for port */
-int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, u16 *vid, bool *is_static)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct mv88e6xxx_atu_entry next;
-	u16 fid = *vid; /* We use one FID per VLAN */
-	int ret;
-
-	mutex_lock(&ps->smi_mutex);
-
-	do {
-		if (is_broadcast_ether_addr(addr)) {
-			struct mv88e6xxx_vtu_stu_entry vtu;
-
-			ret = _mv88e6xxx_port_vtu_getnext(ds, port, *vid, &vtu);
-			if (ret < 0)
-				goto unlock;
-
-			*vid = vtu.vid;
-			fid = vtu.fid;
-		}
-
-		ret = _mv88e6xxx_atu_mac_write(ds, addr);
-		if (ret < 0)
-			goto unlock;
-
-		ret = _mv88e6xxx_atu_getnext(ds, fid, &next);
-		if (ret < 0)
-			goto unlock;
-
-		ether_addr_copy(addr, next.mac);
-
-		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
-			continue;
-	} while (next.trunk || (next.portv_trunkid & BIT(port)) == 0);
-
-	*is_static = next.state == (is_multicast_ether_addr(addr) ?
-				    GLOBAL_ATU_DATA_STATE_MC_STATIC :
-				    GLOBAL_ATU_DATA_STATE_UC_STATIC);
-unlock:
-	mutex_unlock(&ps->smi_mutex);
-
-	return ret;
-}
-
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
 	struct mv88e6xxx_priv_state *ps;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index b422a5e..f78d45c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -478,8 +478,6 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   struct switchdev_trans *trans);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const struct switchdev_obj_port_fdb *fdb);
-int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, u16 *vid, bool *is_static);
 int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 			    struct switchdev_obj_port_fdb *fdb,
 			    int (*cb)(struct switchdev_obj *obj));
-- 
2.6.1
