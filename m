From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC] net: dsa: export mv88e6xxx functions
Date: Sat,  2 May 2015 14:51:07 -0400
Message-ID: <1430592668-26018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"Florian Fainelli" <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit moves the registration of the mv88e6123_61_65, mv88e6131,
mv88e6171, mv88e6352 drivers from the generic mv88e6xxx driver to their
own modules.

It also removes the NET_DSA_MV88E6XXX Kconfig entry and the mv88e6xxx
module, and exports its symbols, since it is just meant to share common
code, and does not have to be a module.

This allows the switch drivers to be complete modules, remove the need
to expose the dsa_switch_driver structures, and reduce code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/Kconfig           |  8 -----
 drivers/net/dsa/Makefile          | 18 +++-------
 drivers/net/dsa/mv88e6123_61_65.c |  6 +++-
 drivers/net/dsa/mv88e6131.c       |  6 +++-
 drivers/net/dsa/mv88e6171.c       |  6 +++-
 drivers/net/dsa/mv88e6352.c       |  7 +++-
 drivers/net/dsa/mv88e6xxx.c       | 70 +++++++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx.h       |  4 ---
 8 files changed, 56 insertions(+), 69 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 18550c7..72b1835 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -1,10 +1,6 @@
 menu "Distributed Switch Architecture drivers"
 	depends on HAVE_NET_DSA
 
-config NET_DSA_MV88E6XXX
-	tristate
-	default n
-
 config NET_DSA_MV88E6060
 	tristate "Marvell 88E6060 ethernet switch chip support"
 	depends on NET_DSA
@@ -20,7 +16,6 @@ config NET_DSA_MV88E6XXX_NEED_PPU
 config NET_DSA_MV88E6131
 	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
 	depends on NET_DSA
-	select NET_DSA_MV88E6XXX
 	select NET_DSA_MV88E6XXX_NEED_PPU
 	select NET_DSA_TAG_DSA
 	---help---
@@ -30,7 +25,6 @@ config NET_DSA_MV88E6131
 config NET_DSA_MV88E6123_61_65
 	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
 	depends on NET_DSA
-	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
 	  This enables support for the Marvell 88E6123/6161/6165
@@ -39,7 +33,6 @@ config NET_DSA_MV88E6123_61_65
 config NET_DSA_MV88E6171
 	tristate "Marvell 88E6171/6172 ethernet switch chip support"
 	depends on NET_DSA
-	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
 	  This enables support for the Marvell 88E6171/6172 ethernet switch
@@ -48,7 +41,6 @@ config NET_DSA_MV88E6171
 config NET_DSA_MV88E6352
 	tristate "Marvell 88E6176/88E6352 ethernet switch chip support"
 	depends on NET_DSA
-	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
 	  This enables support for the Marvell 88E6176 and 88E6352 ethernet
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index e2d51c4..6253f1a 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,16 +1,6 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
-mv88e6xxx_drv-y += mv88e6xxx.o
-ifdef CONFIG_NET_DSA_MV88E6123_61_65
-mv88e6xxx_drv-y += mv88e6123_61_65.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6131
-mv88e6xxx_drv-y += mv88e6131.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6352
-mv88e6xxx_drv-y += mv88e6352.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6171
-mv88e6xxx_drv-y += mv88e6171.o
-endif
+obj-$(CONFIG_NET_DSA_MV88E6123_61_65)	+= mv88e6xxx.o mv88e6123_61_65.o
+obj-$(CONFIG_NET_DSA_MV88E6131)		+= mv88e6xxx.o mv88e6131.o
+obj-$(CONFIG_NET_DSA_MV88E6171)		+= mv88e6xxx.o mv88e6171.o
+obj-$(CONFIG_NET_DSA_MV88E6352)		+= mv88e6xxx.o mv88e6352.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index b4af6d5..744271c 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -277,7 +277,7 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
+static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6123_61_65_probe,
@@ -296,6 +296,10 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_regs		= mv88e6xxx_get_regs,
 };
 
+module_switch_driver(mv88e6123_61_65_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 88E6123/6161/6165 ethernet switch chip");
+MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:mv88e6123");
 MODULE_ALIAS("platform:mv88e6161");
 MODULE_ALIAS("platform:mv88e6165");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e54824f..bcdb81c 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -299,7 +299,7 @@ mv88e6131_phy_write(struct dsa_switch *ds,
 	return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
 }
 
-struct dsa_switch_driver mv88e6131_switch_driver = {
+static struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
@@ -313,6 +313,10 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_sset_count		= mv88e6xxx_get_sset_count,
 };
 
+module_switch_driver(mv88e6131_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 88E6095/6095f/6131 ethernet switch chip");
+MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:mv88e6085");
 MODULE_ALIAS("platform:mv88e6095");
 MODULE_ALIAS("platform:mv88e6095f");
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 9104efe..b67f030 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -280,7 +280,7 @@ static int mv88e6171_set_eee(struct dsa_switch *ds, int port,
 	return -EOPNOTSUPP;
 }
 
-struct dsa_switch_driver mv88e6171_switch_driver = {
+static struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6171_probe,
@@ -307,5 +307,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
+module_switch_driver(mv88e6171_switch_driver);
+
+MODULE_DESCRIPTION("Driver for Marvell 88E6171/88E6172 ethernet switch chip");
+MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:mv88e6171");
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 126c11b..d5577b8 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -519,7 +519,7 @@ static int mv88e6352_set_eeprom(struct dsa_switch *ds,
 	return 0;
 }
 
-struct dsa_switch_driver mv88e6352_switch_driver = {
+static struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6352_probe,
@@ -551,4 +551,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
+module_switch_driver(mv88e6352_switch_driver);
+
+MODULE_AUTHOR("Guenter Roeck <linux@roeck-us.net>");
+MODULE_DESCRIPTION("Driver for Marvell 88E6176/88E6352 ethernet switch chip");
+MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:mv88e6352");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cf309aa9..1deaec0 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -74,6 +74,7 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 
 	return ret & 0xffff;
 }
+EXPORT_SYMBOL_GPL(__mv88e6xxx_reg_read);
 
 /* Must be called with SMI mutex held */
 static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
@@ -105,6 +106,7 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_reg_read);
 
 int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 			  int reg, u16 val)
@@ -164,6 +166,7 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_reg_write);
 
 int mv88e6xxx_config_prio(struct dsa_switch *ds)
 {
@@ -182,6 +185,7 @@ int mv88e6xxx_config_prio(struct dsa_switch *ds)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_config_prio);
 
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
@@ -191,6 +195,7 @@ int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_direct);
 
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 {
@@ -216,6 +221,7 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_indirect);
 
 /* Must be called with phy mutex held */
 static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
@@ -343,6 +349,7 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
 	ps->ppu_timer.data = (unsigned long)ps;
 	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_ppu_state_init);
 
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 {
@@ -356,6 +363,7 @@ int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_ppu);
 
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val)
@@ -370,6 +378,7 @@ int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_ppu);
 #endif
 
 void mv88e6xxx_poll_link(struct dsa_switch *ds)
@@ -433,6 +442,7 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 		}
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_poll_link);
 
 static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 {
@@ -638,6 +648,7 @@ mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 		_mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6xxx_hw_stats) - 3,
 				       mv88e6xxx_hw_stats, port, data);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_strings);
 
 int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
@@ -645,6 +656,7 @@ int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 		return ARRAY_SIZE(mv88e6xxx_hw_stats);
 	return ARRAY_SIZE(mv88e6xxx_hw_stats) - 3;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_sset_count);
 
 void
 mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
@@ -659,11 +671,13 @@ mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 			ds, ARRAY_SIZE(mv88e6xxx_hw_stats) - 3,
 			mv88e6xxx_hw_stats, port, data);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_ethtool_stats);
 
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 {
 	return 32 * sizeof(u16);
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs_len);
 
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p)
@@ -683,6 +697,7 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			p[i] = ret;
 	}
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs);
 
 #ifdef CONFIG_NET_DSA_HWMON
 
@@ -730,6 +745,7 @@ error:
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
@@ -844,6 +860,7 @@ out:
 	mutex_unlock(&ps->phy_mutex);
 	return reg;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_get_eee);
 
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e)
@@ -870,6 +887,7 @@ out:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_set_eee);
 
 static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
 {
@@ -1011,6 +1029,7 @@ int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_join_bridge);
 
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 {
@@ -1050,6 +1069,7 @@ int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_leave_bridge);
 
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 {
@@ -1084,6 +1104,7 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_stp_update);
 
 static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
 				  const unsigned char *addr)
@@ -1157,6 +1178,7 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_add);
 
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid)
@@ -1171,6 +1193,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_del);
 
 static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 				    unsigned char *addr, bool *is_static)
@@ -1224,6 +1247,7 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_getnext);
 
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
@@ -1280,6 +1304,7 @@ abort:
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_port_common);
 
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
@@ -1297,6 +1322,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_setup_common);
 
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
@@ -1337,6 +1363,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_switch_reset);
 
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 {
@@ -1396,6 +1423,7 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read);
 
 int
 mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
@@ -1412,6 +1440,7 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write);
 
 int
 mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
@@ -1428,6 +1457,7 @@ mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_indirect);
 
 int
 mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
@@ -1445,42 +1475,4 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
-
-static int __init mv88e6xxx_init(void)
-{
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	register_switch_driver(&mv88e6131_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
-	register_switch_driver(&mv88e6123_61_65_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	register_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	register_switch_driver(&mv88e6171_switch_driver);
-#endif
-	return 0;
-}
-module_init(mv88e6xxx_init);
-
-static void __exit mv88e6xxx_cleanup(void)
-{
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
-	unregister_switch_driver(&mv88e6171_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
-	unregister_switch_driver(&mv88e6352_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
-	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
-#endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
-	unregister_switch_driver(&mv88e6131_switch_driver);
-#endif
-}
-module_exit(mv88e6xxx_cleanup);
-
-MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
-MODULE_DESCRIPTION("Driver for Marvell 88E6XXX ethernet switch chips");
-MODULE_LICENSE("GPL");
+EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_indirect);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index e045154..54511a2 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -310,10 +310,6 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
-extern struct dsa_switch_driver mv88e6131_switch_driver;
-extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-extern struct dsa_switch_driver mv88e6352_switch_driver;
-extern struct dsa_switch_driver mv88e6171_switch_driver;
 
 #define REG_READ(addr, reg)						\
 	({								\
-- 
2.3.7
