From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 10/14] net: dsa: mv88e6xxx: add SMI init helper
Date: Mon, 20 Jun 2016 13:14:07 -0400
Message-ID: <20160620171411.13746-11-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an helper function to isolate SMI specific assignments and checks.

This function will later help choosing the different SMI accesses based
of the compatible info.

Since the chip structure is already allocated in the legacy probe, use
the mv88e6xxx_reg_read access routine instead of __mv88e6xxx_reg_read.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 113092a..4e24ac5 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3616,6 +3616,19 @@ static struct mv88e6xxx_priv_state *mv88e6xxx_alloc_chip(struct device *dev)
 	return ps;
 }
 
+static int mv88e6xxx_smi_init(struct mv88e6xxx_priv_state *ps,
+			      struct mii_bus *bus, int sw_addr)
+{
+	/* ADDR[0] pin is unavailable externally and considered zero */
+	if (sw_addr & 0x1)
+		return -EINVAL;
+
+	ps->bus = bus;
+	ps->sw_addr = sw_addr;
+
+	return 0;
+}
+
 static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **priv)
@@ -3635,7 +3648,11 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (!ps)
 		return NULL;
 
-	id = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
+	err = mv88e6xxx_smi_init(ps, bus, sw_addr);
+	if (err)
+		goto free;
+
+	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
 		goto free;
 
@@ -3648,8 +3665,6 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 
 	name = info->name;
 
-	ps->bus = bus;
-	ps->sw_addr = sw_addr;
 	ps->info = info;
 
 	err = mv88e6xxx_mdio_register(ps, NULL);
@@ -3741,8 +3756,9 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (!ps)
 		return -ENOMEM;
 
-	ps->bus = mdiodev->bus;
-	ps->sw_addr = mdiodev->addr;
+	err = mv88e6xxx_smi_init(ps, mdiodev->bus, mdiodev->addr);
+	if (err)
+		return err;
 
 	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
 	if (id < 0)
-- 
2.9.0
