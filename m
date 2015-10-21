From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH] net: dsa: mv88e6060: Fix false positive lockdep splat
Date: Wed, 21 Oct 2015 17:37:45 +0200
Message-ID: <5627B149.6030109@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Like the change made for mv88e6xxx, use mutex_lock_nested() to avoid
lockdep to give false positives because of nested MDIO busses.

The false positive was observed using a mv88e6060 from a TI816X SoC.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index c29aebe..b1db460 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -19,14 +19,24 @@
 #define REG_PORT(p)		(8 + (p))
 #define REG_GLOBAL		0x0f

+/* MDIO bus access can be nested in the case of PHYs connected to the
+ * internal MDIO bus of the switch, which is accessed via MDIO bus of
+ * the Ethernet interface. Avoid lockdep false positives by using
+ * mutex_lock_nested().
+ */
 static int reg_read(struct dsa_switch *ds, int addr, int reg)
 {
+	int ret;
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);

 	if (bus == NULL)
 		return -EINVAL;

-	return mdiobus_read(bus, ds->pd->sw_addr + addr, reg);
+	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	ret = bus->read(bus, ds->pd->sw_addr, reg);
+	mutex_unlock(&bus->mdio_lock);
+
+	return ret;
 }

 #define REG_READ(addr, reg)					\
@@ -42,12 +52,17 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)

 static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
+	int ret;
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);

 	if (bus == NULL)
 		return -EINVAL;

-	return mdiobus_write(bus, ds->pd->sw_addr + addr, reg, val);
+	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	ret = bus->write(bus, ds->pd->sw_addr, reg, val);
+	mutex_unlock(&bus->mdio_lock);
+
+	return ret;
 }

 #define REG_WRITE(addr, reg, val)				\
-- 
1.9.1
