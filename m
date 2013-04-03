From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v3] netdev/phy: Implement ieee802.3 clause 45 in mdio-octeon.c
Date: Wed,  3 Apr 2013 12:25:32 -0700
Message-ID: <1365017132-6035-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

The Octeon SMI/MDIO interfaces can do clause 45 communications, so
implement this in the driver.

Also fix some comment formatting to make it consistent and to comply
with the netdev style.

Signed-off-by: David Daney <david.daney@cavium.com>
---

v3: Remove now bogus comment noted by Ben Huchings

v2: No code changes from v1, just fixed comment formatting snafu.

Sorry for the spam.


 drivers/net/phy/mdio-octeon.c | 94 +++++++++++++++++++++++++++++++++++++++----
 1 file changed, 87 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index c2c878d..b51fa1f 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2009,2011 Cavium, Inc.
+ * Copyright (C) 2009-2012 Cavium, Inc.
  */
 
 #include <linux/platform_device.h>
@@ -27,30 +27,98 @@
 #define SMI_CLK		0x18
 #define SMI_EN		0x20
 
+enum octeon_mdiobus_mode {
+	UNINIT = 0,
+	C22,
+	C45
+};
+
 struct octeon_mdiobus {
 	struct mii_bus *mii_bus;
 	u64 register_base;
 	resource_size_t mdio_phys;
 	resource_size_t regsize;
+	enum octeon_mdiobus_mode mode;
 	int phy_irq[PHY_MAX_ADDR];
 };
 
+static void octeon_mdiobus_set_mode(struct octeon_mdiobus *p,
+				    enum octeon_mdiobus_mode m)
+{
+	union cvmx_smix_clk smi_clk;
+
+	if (m == p->mode)
+		return;
+
+	smi_clk.u64 = cvmx_read_csr(p->register_base + SMI_CLK);
+	smi_clk.s.mode = (m == C45) ? 1 : 0;
+	smi_clk.s.preamble = 1;
+	cvmx_write_csr(p->register_base + SMI_CLK, smi_clk.u64);
+	p->mode = m;
+}
+
+static int octeon_mdiobus_c45_addr(struct octeon_mdiobus *p,
+				   int phy_id, int regnum)
+{
+	union cvmx_smix_cmd smi_cmd;
+	union cvmx_smix_wr_dat smi_wr;
+	int timeout = 1000;
+
+	octeon_mdiobus_set_mode(p, C45);
+
+	smi_wr.u64 = 0;
+	smi_wr.s.dat = regnum & 0xffff;
+	cvmx_write_csr(p->register_base + SMI_WR_DAT, smi_wr.u64);
+
+	regnum = (regnum >> 16) & 0x1f;
+
+	smi_cmd.u64 = 0;
+	smi_cmd.s.phy_op = 0; /* MDIO_CLAUSE_45_ADDRESS */
+	smi_cmd.s.phy_adr = phy_id;
+	smi_cmd.s.reg_adr = regnum;
+	cvmx_write_csr(p->register_base + SMI_CMD, smi_cmd.u64);
+
+	do {
+		/* Wait 1000 clocks so we don't saturate the RSL bus
+		 * doing reads.
+		 */
+		__delay(1000);
+		smi_wr.u64 = cvmx_read_csr(p->register_base + SMI_WR_DAT);
+	} while (smi_wr.s.pending && --timeout);
+
+	if (timeout <= 0)
+		return -EIO;
+	return 0;
+}
+
 static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int regnum)
 {
 	struct octeon_mdiobus *p = bus->priv;
 	union cvmx_smix_cmd smi_cmd;
 	union cvmx_smix_rd_dat smi_rd;
+	unsigned int op = 1; /* MDIO_CLAUSE_22_READ */
 	int timeout = 1000;
 
+	if (regnum & MII_ADDR_C45) {
+		int r = octeon_mdiobus_c45_addr(p, phy_id, regnum);
+		if (r < 0)
+			return r;
+
+		regnum = (regnum >> 16) & 0x1f;
+		op = 3; /* MDIO_CLAUSE_45_READ */
+	} else {
+		octeon_mdiobus_set_mode(p, C22);
+	}
+
+
 	smi_cmd.u64 = 0;
-	smi_cmd.s.phy_op = 1; /* MDIO_CLAUSE_22_READ */
+	smi_cmd.s.phy_op = op;
 	smi_cmd.s.phy_adr = phy_id;
 	smi_cmd.s.reg_adr = regnum;
 	cvmx_write_csr(p->register_base + SMI_CMD, smi_cmd.u64);
 
 	do {
-		/*
-		 * Wait 1000 clocks so we don't saturate the RSL bus
+		/* Wait 1000 clocks so we don't saturate the RSL bus
 		 * doing reads.
 		 */
 		__delay(1000);
@@ -69,21 +137,33 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 	struct octeon_mdiobus *p = bus->priv;
 	union cvmx_smix_cmd smi_cmd;
 	union cvmx_smix_wr_dat smi_wr;
+	unsigned int op = 0; /* MDIO_CLAUSE_22_WRITE */
 	int timeout = 1000;
 
+
+	if (regnum & MII_ADDR_C45) {
+		int r = octeon_mdiobus_c45_addr(p, phy_id, regnum);
+		if (r < 0)
+			return r;
+
+		regnum = (regnum >> 16) & 0x1f;
+		op = 1; /* MDIO_CLAUSE_45_WRITE */
+	} else {
+		octeon_mdiobus_set_mode(p, C22);
+	}
+
 	smi_wr.u64 = 0;
 	smi_wr.s.dat = val;
 	cvmx_write_csr(p->register_base + SMI_WR_DAT, smi_wr.u64);
 
 	smi_cmd.u64 = 0;
-	smi_cmd.s.phy_op = 0; /* MDIO_CLAUSE_22_WRITE */
+	smi_cmd.s.phy_op = op;
 	smi_cmd.s.phy_adr = phy_id;
 	smi_cmd.s.reg_adr = regnum;
 	cvmx_write_csr(p->register_base + SMI_CMD, smi_cmd.u64);
 
 	do {
-		/*
-		 * Wait 1000 clocks so we don't saturate the RSL bus
+		/* Wait 1000 clocks so we don't saturate the RSL bus
 		 * doing reads.
 		 */
 		__delay(1000);
-- 
1.7.11.7
