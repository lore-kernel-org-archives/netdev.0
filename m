From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 12/20] net: dsa: mv88e6xxx: factorize global setup
Date: Thu,  5 May 2016 18:40:56 -0400
Message-ID: <1462488064-1841-13-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every driver is calling mv88e6xxx_setup_global after
mv88e6xxx_setup_common. Call the former in the latter.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |   4 --
 drivers/net/dsa/mv88e6131.c |   4 --
 drivers/net/dsa/mv88e6171.c |   4 --
 drivers/net/dsa/mv88e6352.c |   4 --
 drivers/net/dsa/mv88e6xxx.c | 109 +++++++++++++++++++++++---------------------
 drivers/net/dsa/mv88e6xxx.h |   1 -
 6 files changed, 56 insertions(+), 70 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index f542fbf..938d5ca 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -61,10 +61,6 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	ret = mv88e6xxx_setup_global(ds);
-	if (ret)
-		return ret;
-
 	/* Disable the PHY polling unit (since there won't be any
 	 * external PHYs to poll), don't discard packets with
 	 * excessive collisions, and mask all interrupt sources.
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 5b33d39..2c43348 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -77,10 +77,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	ret = mv88e6xxx_setup_global(ds);
-	if (ret)
-		return ret;
-
 	/* Enable the PHY polling unit, don't discard packets with
 	 * excessive collisions, use a weighted fair queueing scheme
 	 * to arbitrate between packet queues, set the maximum frame
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 9724a25..fcdb5a7 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -93,10 +93,6 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	ret = mv88e6xxx_setup_global(ds);
-	if (ret)
-		return ret;
-
 	/* Discard packets with excessive collisions, mask all
 	 * interrupt sources, enable PPU.
 	 */
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index a9d4d47a..94a2698 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -144,10 +144,6 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	ret = mv88e6xxx_setup_global(ds);
-	if (ret)
-		return ret;
-
 	/* Discard packets with excessive collisions,
 	 * mask all interrupt sources, enable PPU (bit 14, undocumented).
 	 */
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b52e3d0..7ec532d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2910,36 +2910,11 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	return 0;
 }
 
-int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 {
 	int err;
-
-	mutex_init(&ps->smi_mutex);
-
-	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
-
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
-		mutex_init(&ps->eeprom_mutex);
-
-	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
-		mv88e6xxx_ppu_state_init(ps);
-
-	mutex_lock(&ps->smi_mutex);
-
-	err = _mv88e6xxx_switch_reset(ps);
-
-	mutex_unlock(&ps->smi_mutex);
-
-	return err;
-}
-
-int mv88e6xxx_setup_global(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int err;
 	int i;
 
-	mutex_lock(&ps->smi_mutex);
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
@@ -2947,45 +2922,45 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL,
 				   0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Configure the IP ToS mapping registers. */
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
 	if (err)
-		goto unlock;
+		return err;
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Configure the IEEE 802.1p priority mapping register. */
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:0x to the CPU port.
 	 */
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Ignore removed tag data on doubly tagged packets, disable
 	 * flow control messages, force flow control priority to the
@@ -2996,15 +2971,15 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 				   0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
 				   GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Program the DSA routing table. */
 	for (i = 0; i < 32; i++) {
 		int nexthop = 0x1f;
 
-		if (ds->pd->rtable &&
-		    i != ds->index && i < ds->dst->pd->nr_chips)
-			nexthop = ds->pd->rtable[i] & 0x1f;
+		if (ps->ds->pd->rtable &&
+		    i != ps->ds->index && i < ps->ds->dst->pd->nr_chips)
+			nexthop = ps->ds->pd->rtable[i] & 0x1f;
 
 		err = _mv88e6xxx_reg_write(
 			ps, REG_GLOBAL2,
@@ -3012,7 +2987,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 			GLOBAL2_DEVICE_MAPPING_UPDATE |
 			(i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) | nexthop);
 		if (err)
-			goto unlock;
+			return err;
 	}
 
 	/* Clear all trunk masks. */
@@ -3022,7 +2997,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 					   (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
 					   ((1 << ps->info->num_ports) - 1));
 		if (err)
-			goto unlock;
+			return err;
 	}
 
 	/* Clear all trunk mappings. */
@@ -3033,7 +3008,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 			GLOBAL2_TRUNK_MAPPING_UPDATE |
 			(i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
 		if (err)
-			goto unlock;
+			return err;
 	}
 
 	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
@@ -3045,7 +3020,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2,
 					   GLOBAL2_MGMT_EN_2X, 0xffff);
 		if (err)
-			goto unlock;
+			return err;
 
 		/* Initialise cross-chip port VLAN table to reset
 		 * defaults.
@@ -3053,7 +3028,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2,
 					   GLOBAL2_PVT_ADDR, 0x9000);
 		if (err)
-			goto unlock;
+			return err;
 
 		/* Clear the priority override table. */
 		for (i = 0; i < 16; i++) {
@@ -3061,7 +3036,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 						   GLOBAL2_PRIO_OVERRIDE,
 						   0x8000 | (i << 8));
 			if (err)
-				goto unlock;
+				return err;
 		}
 	}
 
@@ -3078,7 +3053,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 						   GLOBAL2_INGRESS_OP,
 						   0x9000 | (i << 8));
 			if (err)
-				goto unlock;
+				return err;
 		}
 	}
 
@@ -3086,20 +3061,48 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
 				   GLOBAL_STATS_OP_FLUSH_ALL);
 	if (err)
-		goto unlock;
+		return err;
 
 	/* Wait for the flush to complete. */
 	err = _mv88e6xxx_stats_wait(ps);
-	if (err < 0)
-		goto unlock;
+	if (err)
+		return err;
 
 	/* Clear all ATU entries */
 	err = _mv88e6xxx_atu_flush(ps, 0, true);
-	if (err < 0)
-		goto unlock;
+	if (err)
+		return err;
 
 	/* Clear all the VTU and STU entries */
 	err = _mv88e6xxx_vtu_stu_flush(ps);
+	if (err < 0)
+		return err;
+
+	return err;
+}
+
+int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
+{
+	int err;
+
+	mutex_init(&ps->smi_mutex);
+
+	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+		mutex_init(&ps->eeprom_mutex);
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
+		mv88e6xxx_ppu_state_init(ps);
+
+	mutex_lock(&ps->smi_mutex);
+
+	err = _mv88e6xxx_switch_reset(ps);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_setup_global(ps);
+
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 7ca7230..119271e 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -532,7 +532,6 @@ const char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps);
-int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg);
 int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 			int reg, u16 val);
-- 
2.8.2
