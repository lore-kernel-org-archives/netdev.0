From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 08/14] net: dsa: mv88e6xxx: rename smi_mutex to reg_lock
Date: Fri, 17 Jun 2016 20:07:30 -0400
Message-ID: <20160618000736.5598-9-vivien.didelot@savoirfairelinux.com>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The chip smi_mutex mutex is used to protect the access to the internal
switch registers, not only the Multi-chip Addressing Mode, as commented.

Other registers access (like management frames) may use this mutex.

Since we will isolate SMI-specific pieces of code, avoid the confusion
now by renaming smi_mutex to reg_lock. No functional changes here.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 120 ++++++++++++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx.h |   7 +--
 2 files changed, 62 insertions(+), 65 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 75e5408..2c86172 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -29,10 +29,10 @@
 #include <net/switchdev.h>
 #include "mv88e6xxx.h"
 
-static void assert_smi_lock(struct mv88e6xxx_priv_state *ps)
+static void assert_reg_lock(struct mv88e6xxx_priv_state *ps)
 {
-	if (unlikely(!mutex_is_locked(&ps->smi_mutex))) {
-		dev_err(ps->dev, "SMI lock not held!\n");
+	if (unlikely(!mutex_is_locked(&ps->reg_lock))) {
+		dev_err(ps->dev, "Switch registers lock not held!\n");
 		dump_stack();
 	}
 }
@@ -99,7 +99,7 @@ static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
 {
 	int ret;
 
-	assert_smi_lock(ps);
+	assert_reg_lock(ps);
 
 	ret = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, addr, reg);
 	if (ret < 0)
@@ -116,9 +116,9 @@ static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr,
 {
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	ret = _mv88e6xxx_reg_read(ps, addr, reg);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -158,7 +158,7 @@ static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 				int reg, u16 val)
 {
-	assert_smi_lock(ps);
+	assert_reg_lock(ps);
 
 	dev_dbg(ps->dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
@@ -171,9 +171,9 @@ static int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 {
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	ret = _mv88e6xxx_reg_write(ps, addr, reg, val);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -320,7 +320,7 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 
 	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	if (mutex_trylock(&ps->ppu_mutex)) {
 		if (mv88e6xxx_ppu_enable(ps) == 0)
@@ -328,7 +328,7 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 		mutex_unlock(&ps->ppu_mutex);
 	}
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
@@ -477,7 +477,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	if (!phy_is_pseudo_fixed_link(phydev))
 		return;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_PCS_CTRL);
 	if (ret < 0)
@@ -528,7 +528,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	_mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_PCS_CTRL, reg);
 
 out:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static int _mv88e6xxx_stats_wait(struct mv88e6xxx_priv_state *ps)
@@ -753,11 +753,11 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 	int ret;
 	int i, j;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	ret = _mv88e6xxx_stats_snapshot(ps, port);
 	if (ret < 0) {
-		mutex_unlock(&ps->smi_mutex);
+		mutex_unlock(&ps->reg_lock);
 		return;
 	}
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
@@ -768,7 +768,7 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 		}
 	}
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
@@ -787,7 +787,7 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 
 	memset(p, 0xff, 32 * sizeof(u16));
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	for (i = 0; i < 32; i++) {
 		int ret;
@@ -797,7 +797,7 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			p[i] = ret;
 	}
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
@@ -824,9 +824,9 @@ static int mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg,
 {
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	ret = _mv88e6xxx_wait(ps, reg, offset, mask);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -1123,7 +1123,7 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	reg = mv88e6xxx_mdio_read_indirect(ps, port, 16);
 	if (reg < 0)
@@ -1140,7 +1140,7 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 	reg = 0;
 
 out:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 	return reg;
 }
 
@@ -1154,7 +1154,7 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEE))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	ret = mv88e6xxx_mdio_read_indirect(ps, port, 16);
 	if (ret < 0)
@@ -1168,7 +1168,7 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 
 	ret = mv88e6xxx_mdio_write_indirect(ps, port, 16, reg);
 out:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -1402,9 +1402,9 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 		break;
 	}
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	err = _mv88e6xxx_port_state(ps, port, stp_state);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	if (err)
 		netdev_err(ds->ports[port].netdev,
@@ -1638,7 +1638,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
 	if (err)
@@ -1676,7 +1676,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 	} while (next.vid < GLOBAL_VTU_VID_MASK);
 
 unlock:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return err;
 }
@@ -2004,7 +2004,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 	if (!vid_begin)
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	err = _mv88e6xxx_vtu_vid_write(ps, vid_begin - 1);
 	if (err)
@@ -2043,7 +2043,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 	} while (vlan.vid < vid_end);
 
 unlock:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return err;
 }
@@ -2066,7 +2066,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL_2);
 	if (ret < 0)
@@ -2090,7 +2090,7 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 
 	ret = 0;
 unlock:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -2149,7 +2149,7 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
 		return;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
 		if (_mv88e6xxx_port_vlan_add(ps, port, vid, untagged))
@@ -2161,7 +2161,7 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 		netdev_err(ds->ports[port].netdev, "failed to set PVID %d\n",
 			   vlan->vid_end);
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_priv_state *ps,
@@ -2210,7 +2210,7 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
 	if (err)
@@ -2229,7 +2229,7 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	}
 
 unlock:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return err;
 }
@@ -2341,11 +2341,11 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
 		return;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	if (_mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[port].netdev,
 			   "failed to load MAC address\n");
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
@@ -2357,10 +2357,10 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	ret = _mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -2465,7 +2465,7 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
 	err = _mv88e6xxx_port_fid_get(ps, port, &fid);
@@ -2496,7 +2496,7 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
 
 unlock:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return err;
 }
@@ -2510,7 +2510,7 @@ static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VLANTABLE))
 		return -EOPNOTSUPP;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	/* Assign the bridge and remap each port's VLANTable */
 	ps->ports[port].bridge_dev = bridge;
@@ -2523,7 +2523,7 @@ static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 		}
 	}
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return err;
 }
@@ -2537,7 +2537,7 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VLANTABLE))
 		return;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	/* Unassign the bridge and remap each port's VLANTable */
 	ps->ports[port].bridge_dev = NULL;
@@ -2548,7 +2548,7 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 				netdev_warn(ds->ports[i].netdev,
 					    "failed to remap\n");
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 }
 
 static int _mv88e6xxx_mdio_page_write(struct mv88e6xxx_priv_state *ps,
@@ -3139,7 +3139,7 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
 		mutex_init(&ps->eeprom_mutex);
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	err = mv88e6xxx_switch_reset(ps);
 	if (err)
@@ -3156,7 +3156,7 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	}
 
 unlock:
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return err;
 }
@@ -3167,9 +3167,9 @@ static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	ret = _mv88e6xxx_mdio_page_read(ps, port, page, reg);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -3180,9 +3180,9 @@ static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 	ret = _mv88e6xxx_mdio_page_write(ps, port, page, reg, val);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 
 	return ret;
 }
@@ -3204,7 +3204,7 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
 	if (addr < 0)
 		return 0xffff;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
 		ret = mv88e6xxx_mdio_read_ppu(ps, addr, regnum);
@@ -3213,7 +3213,7 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int port, int regnum)
 	else
 		ret = mv88e6xxx_mdio_read_direct(ps, addr, regnum);
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 	return ret;
 }
 
@@ -3227,7 +3227,7 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
 	if (addr < 0)
 		return 0xffff;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
 		ret = mv88e6xxx_mdio_write_ppu(ps, addr, regnum, val);
@@ -3236,7 +3236,7 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int port, int regnum,
 	else
 		ret = mv88e6xxx_mdio_write_direct(ps, addr, regnum, val);
 
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 	return ret;
 }
 
@@ -3310,7 +3310,7 @@ static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 
 	*temp = 0;
 
-	mutex_lock(&ps->smi_mutex);
+	mutex_lock(&ps->reg_lock);
 
 	ret = mv88e6xxx_mdio_write_direct(ps, 0x0, 0x16, 0x6);
 	if (ret < 0)
@@ -3343,7 +3343,7 @@ static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 
 error:
 	mv88e6xxx_mdio_write_direct(ps, 0x0, 0x16, 0x0);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_unlock(&ps->reg_lock);
 	return ret;
 }
 
@@ -3637,7 +3637,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	ps->sw_addr = sw_addr;
 	ps->info = info;
 	ps->dev = dsa_dev;
-	mutex_init(&ps->smi_mutex);
+	mutex_init(&ps->reg_lock);
 
 	err = mv88e6xxx_mdio_register(ps, NULL);
 	if (err)
@@ -3727,7 +3727,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	ps->dev = dev;
 	ps->bus = mdiodev->bus;
 	ps->sw_addr = mdiodev->addr;
-	mutex_init(&ps->smi_mutex);
+	mutex_init(&ps->reg_lock);
 
 	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8221c3c..b279f8c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -554,11 +554,8 @@ struct mv88e6xxx_priv_state {
 	/* The device this structure is associated to */
 	struct device *dev;
 
-	/* When using multi-chip addressing, this mutex protects
-	 * access to the indirect access registers.  (In single-chip
-	 * mode, this mutex is effectively useless.)
-	 */
-	struct mutex	smi_mutex;
+	/* This mutex protects the access to the switch registers */
+	struct mutex reg_lock;
 
 	/* The MII bus and the address on the bus that is used to
 	 * communication with the switch
-- 
2.8.3
