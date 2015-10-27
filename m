From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 2/3] net: dsa: mv88e6xxx: add common and ppu remove
 function
Date: Tue, 27 Oct 2015 17:35:59 +0100
Message-ID: <562FA7EF.3030505@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the previously introduced remove callback, add a
mv88e6xxx common remove function to cleanup all ressources.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6xxx.c | 18 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 2 files changed, 20 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b1b14f5..6287096 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -331,6 +331,16 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
 	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }

+void mv88e6xxx_ppu_state_remove(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	
+	del_timer_sync(&ps->ppu_timer);
+
+	cancel_work_sync(&ps->bridge_work);
+	flush_work(&ps->bridge_work);
+}
+
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 {
 	int ret;
@@ -2083,6 +2093,14 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	return 0;
 }

+void mv88e6xxx_remove_common(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	cancel_work_sync(&ps->bridge_work);
+	flush_work(&ps->bridge_work);
+}
+
 int mv88e6xxx_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6f9ed5d..64d37a0 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -417,6 +417,7 @@ struct mv88e6xxx_hw_stat {
 int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
+void mv88e6xxx_remove_common(struct dsa_switch *ds);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
@@ -431,6 +432,7 @@ int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum);
 int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 				 u16 val);
 void mv88e6xxx_ppu_state_init(struct dsa_switch *ds);
+void mv88e6xxx_ppu_state_remove(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val);
-- 
1.9.1
