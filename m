From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v3 5/5] net: dsa: add mv88e6xxx ppu remove function for
 mv88e6131
Date: Thu, 29 Oct 2015 15:45:48 +0100
Message-ID: <5632311C.3020708@baylibre.com>
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

The mv88e6131 also need to call remove for the ppu part of mv88e6xxx.
Add the ppu remove function and add a mv88e6131 specific remove
callback calling the ppu remove function.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6131.c |  9 ++++++++-
 drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
 drivers/net/dsa/mv88e6xxx.h |  1 +
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 677a6cb..0f559b4 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -137,6 +137,13 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	return mv88e6xxx_setup_ports(ds);
 }

+static void mv88e6131_remove(struct dsa_switch *ds)
+{
+	mv88e6xxx_ppu_state_remove(ds);
+
+	mv88e6xxx_remove_common(ds);
+}
+
 static int mv88e6131_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -175,7 +182,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
 	.setup			= mv88e6131_setup,
-	.remove			= mv88e6xxx_remove_common,
+	.remove			= mv88e6131_remove,
 	.set_addr		= mv88e6xxx_set_addr_direct,
 	.phy_read		= mv88e6131_phy_read,
 	.phy_write		= mv88e6131_phy_write,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3bd63f1..820b651 100644
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
+	cancel_work_sync(&ps->ppu_work);
+	flush_work(&ps->ppu_work);
+}
+
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 {
 	int ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 60acaaf..64d37a0 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -432,6 +432,7 @@ int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum);
 int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 				 u16 val);
 void mv88e6xxx_ppu_state_init(struct dsa_switch *ds);
+void mv88e6xxx_ppu_state_remove(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val);
-- 
1.9.1
