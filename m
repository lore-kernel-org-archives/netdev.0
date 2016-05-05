From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 01/20] net: dsa: mv88e6xxx: factorize PHY access with PPU
Date: Thu,  5 May 2016 18:40:45 -0400
Message-ID: <1462488064-1841-2-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Add a flags bitmap to the mv88e6xxx_info structure to help describing
features supported or not by a switch model.

Add a MV88E6XXX_FLAG_PPU flag to describe switch models with a PHY
Polling Unit. This allows to merge PPU specific PHY access code in the
share code. In the meantime, use unlocked register accesses.

Since the PPU code is shared, also remove NET_DSA_MV88E6XXX_NEED_PPU.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/Kconfig     |   5 --
 drivers/net/dsa/mv88e6131.c |  43 ++-------------
 drivers/net/dsa/mv88e6xxx.c | 130 +++++++++++++++++++++-----------------------
 drivers/net/dsa/mv88e6xxx.h |  25 ++++++---
 4 files changed, 86 insertions(+), 117 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 90ba003..4aaadce 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -13,15 +13,10 @@ config NET_DSA_MV88E6060
 	  This enables support for the Marvell 88E6060 ethernet switch
 	  chip.
 
-config NET_DSA_MV88E6XXX_NEED_PPU
-	bool
-	default n
-
 config NET_DSA_MV88E6131
 	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
 	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
-	select NET_DSA_MV88E6XXX_NEED_PPU
 	select NET_DSA_TAG_DSA
 	---help---
 	  This enables support for the Marvell 88E6085/6095/6095F/6131
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 357ab79..437faf8 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -24,24 +24,28 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
+		.flags = MV88E6XXX_FLAG_PPU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
 		.family = MV88E6XXX_FAMILY_6097,
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
+		.flags = MV88E6XXX_FLAG_PPU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
+		.flags = MV88E6XXX_FLAG_PPU,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
+		.flags = MV88E6XXX_FLAG_PPU,
 	}
 };
 
@@ -128,8 +132,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	mv88e6xxx_ppu_state_init(ps);
-
 	ret = mv88e6xxx_switch_reset(ps, false);
 	if (ret < 0)
 		return ret;
@@ -141,46 +143,13 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	return mv88e6xxx_setup_ports(ds);
 }
 
-static int mv88e6131_port_to_phy_addr(struct dsa_switch *ds, int port)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	if (port >= 0 && port < ps->info->num_ports)
-		return port;
-
-	return -EINVAL;
-}
-
-static int
-mv88e6131_phy_read(struct dsa_switch *ds, int port, int regnum)
-{
-	int addr = mv88e6131_port_to_phy_addr(ds, port);
-
-	if (addr < 0)
-		return addr;
-
-	return mv88e6xxx_phy_read_ppu(ds, addr, regnum);
-}
-
-static int
-mv88e6131_phy_write(struct dsa_switch *ds,
-			      int port, int regnum, u16 val)
-{
-	int addr = mv88e6131_port_to_phy_addr(ds, port);
-
-	if (addr < 0)
-		return addr;
-
-	return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
-}
-
 struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
 	.probe			= mv88e6131_drv_probe,
 	.setup			= mv88e6131_setup,
 	.set_addr		= mv88e6xxx_set_addr_direct,
-	.phy_read		= mv88e6131_phy_read,
-	.phy_write		= mv88e6131_phy_write,
+	.phy_read		= mv88e6xxx_phy_read,
+	.phy_write		= mv88e6xxx_phy_write,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 470cfc7..4e031aa 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -241,60 +241,39 @@ static int _mv88e6xxx_phy_write(struct mv88e6xxx_priv_state *ps, int addr,
 	return 0;
 }
 
-#ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
-static int mv88e6xxx_ppu_disable(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_ppu_enable(struct mv88e6xxx_priv_state *ps, bool enable)
 {
-	int ret;
 	unsigned long timeout;
+	int ret;
 
-	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
-				  ret & ~GLOBAL_CONTROL_PPU_ENABLE);
-	if (ret)
-		return ret;
-
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
-		if (ret < 0)
-			return ret;
-
-		usleep_range(1000, 2000);
-		if ((ret & GLOBAL_STATUS_PPU_MASK) !=
-		    GLOBAL_STATUS_PPU_POLLING)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
-}
-
-static int mv88e6xxx_ppu_enable(struct mv88e6xxx_priv_state *ps)
-{
-	int ret, err;
-	unsigned long timeout;
+	if (enable)
+		ret |= GLOBAL_CONTROL_PPU_ENABLE;
+	else
+		ret &= ~GLOBAL_CONTROL_PPU_ENABLE;
 
-	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL, ret);
 	if (ret < 0)
 		return ret;
 
-	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
-				  ret | GLOBAL_CONTROL_PPU_ENABLE);
-	if (err)
-		return err;
-
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
+		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
 
 		usleep_range(1000, 2000);
-		if ((ret & GLOBAL_STATUS_PPU_MASK) ==
-		    GLOBAL_STATUS_PPU_POLLING)
+
+		ret &= GLOBAL_STATUS_PPU_MASK;
+
+		if ((enable && ret == GLOBAL_STATUS_PPU_POLLING) ||
+		    (!enable && ret != GLOBAL_STATUS_PPU_POLLING)) {
+			ps->ppu_disabled = !enable;
 			return 0;
+		}
 	}
 
 	return -ETIMEDOUT;
@@ -305,9 +284,12 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 	struct mv88e6xxx_priv_state *ps;
 
 	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
+
 	if (mutex_trylock(&ps->ppu_mutex)) {
-		if (mv88e6xxx_ppu_enable(ps) == 0)
-			ps->ppu_disabled = 0;
+		mutex_lock(&ps->smi_mutex);
+		_mv88e6xxx_ppu_enable(ps, true);
+		mutex_unlock(&ps->smi_mutex);
+
 		mutex_unlock(&ps->ppu_mutex);
 	}
 }
@@ -319,9 +301,9 @@ static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
 	schedule_work(&ps->ppu_work);
 }
 
-static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)
 {
-	int ret;
+	int err;
 
 	mutex_lock(&ps->ppu_mutex);
 
@@ -330,29 +312,27 @@ static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)
 	 * disabled, cancel the timer that is going to re-enable
 	 * it.
 	 */
-	if (!ps->ppu_disabled) {
-		ret = mv88e6xxx_ppu_disable(ps);
-		if (ret < 0) {
+	if (ps->ppu_disabled) {
+		del_timer(&ps->ppu_timer);
+	} else {
+		err = _mv88e6xxx_ppu_enable(ps, false);
+		if (err) {
 			mutex_unlock(&ps->ppu_mutex);
-			return ret;
+			return err;
 		}
-		ps->ppu_disabled = 1;
-	} else {
-		del_timer(&ps->ppu_timer);
-		ret = 0;
 	}
 
-	return ret;
+	return 0;
 }
 
-static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_priv_state *ps)
+static void _mv88e6xxx_ppu_access_put(struct mv88e6xxx_priv_state *ps)
 {
 	/* Schedule a timer to re-enable the PHY polling unit. */
 	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
 	mutex_unlock(&ps->ppu_mutex);
 }
 
-void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
 {
 	mutex_init(&ps->ppu_mutex);
 	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
@@ -361,35 +341,33 @@ void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
 	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
 
-int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
+static int _mv88e6xxx_phy_read_ppu(struct mv88e6xxx_priv_state *ps, int addr,
+				   int regnum)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ret = mv88e6xxx_ppu_access_get(ps);
+	ret = _mv88e6xxx_ppu_access_get(ps);
 	if (ret >= 0) {
-		ret = mv88e6xxx_reg_read(ps, addr, regnum);
-		mv88e6xxx_ppu_access_put(ps);
+		ret = _mv88e6xxx_reg_read(ps, addr, regnum);
+		_mv88e6xxx_ppu_access_put(ps);
 	}
 
 	return ret;
 }
 
-int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
-			    int regnum, u16 val)
+static int _mv88e6xxx_phy_write_ppu(struct mv88e6xxx_priv_state *ps, int addr,
+				    int regnum, u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ret = mv88e6xxx_ppu_access_get(ps);
+	ret = _mv88e6xxx_ppu_access_get(ps);
 	if (ret >= 0) {
-		ret = mv88e6xxx_reg_write(ps, addr, regnum, val);
-		mv88e6xxx_ppu_access_put(ps);
+		ret = _mv88e6xxx_reg_write(ps, addr, regnum, val);
+		_mv88e6xxx_ppu_access_put(ps);
 	}
 
 	return ret;
 }
-#endif
 
 static bool mv88e6xxx_6065_family(struct mv88e6xxx_priv_state *ps)
 {
@@ -2599,6 +2577,9 @@ int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
+		mv88e6xxx_ppu_state_init(ps);
+
 	return 0;
 }
 
@@ -2884,8 +2865,14 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 		return 0xffff;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_read(ps, addr, regnum);
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
+		ret = _mv88e6xxx_phy_read_ppu(ps, addr, regnum);
+	else
+		ret = _mv88e6xxx_phy_read(ps, addr, regnum);
+
 	mutex_unlock(&ps->smi_mutex);
+
 	return ret;
 }
 
@@ -2894,15 +2881,22 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
-	int ret;
+	int err;
 
 	if (addr < 0)
 		return 0xffff;
 
+
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_write(ps, addr, regnum, val);
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
+		err = _mv88e6xxx_phy_write_ppu(ps, addr, regnum, val);
+	else
+		err = _mv88e6xxx_phy_write(ps, addr, regnum, val);
+
 	mutex_unlock(&ps->smi_mutex);
-	return ret;
+
+	return err;
 }
 
 int
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 4f455d2..3e77985 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -350,12 +350,23 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
 };
 
+enum mv88e6xxx_cap {
+	/* PHY Polling Unit.
+	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
+	 */
+	MV88E6XXX_CAP_PPU,
+};
+
+/* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
+
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned long flags;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -403,15 +414,13 @@ struct mv88e6xxx_priv_state {
 	struct mii_bus *bus;
 	int sw_addr;
 
-#ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
 	/* Handles automatic disabling and re-enabling of the PHY
 	 * polling unit.
 	 */
 	struct mutex		ppu_mutex;
-	int			ppu_disabled;
+	bool			ppu_disabled;
 	struct work_struct	ppu_work;
 	struct timer_list	ppu_timer;
-#endif
 
 	/* This mutex serialises access to the statistics unit.
 	 * Hold this mutex over snapshot + dump sequences.
@@ -449,6 +458,12 @@ struct mv88e6xxx_hw_stat {
 	enum stat_type type;
 };
 
+static inline bool mv88e6xxx_has(struct mv88e6xxx_priv_state *ps,
+				 unsigned long flags)
+{
+	return (ps->info->flags & flags) == flags;
+}
+
 int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps, bool ppu_active);
 const char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 				int sw_addr, void **priv,
@@ -468,10 +483,6 @@ int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val);
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum);
 int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 				 u16 val);
-void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps);
-int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
-int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
-			    int regnum, u16 val);
 void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
 void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 				 uint64_t *data);
-- 
2.8.2
