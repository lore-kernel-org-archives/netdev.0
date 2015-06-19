From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa: mv88e6xxx: split phy page accessors
Date: Fri, 19 Jun 2015 10:32:10 -0400
Message-ID: <1434724330-3442-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split mv88e6xxx_phy_page_read and mv88e6xxx_phy_page_write into two
functions each, one to acquire the smi_mutex and one to call the actual
read/write functions.

This will be useful to access registers such as Fiber/SERDES Control,
from setup code with SMI lock held.

Also rename their "error" labels to "clear", since it is not only an
error path.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 43 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index bfe70ce..9caec51 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2068,37 +2068,58 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 	return 0;
 }
 
-int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page,
+				    int reg)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
-		goto error;
+		goto clear;
 	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
-error:
+clear:
 	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
-	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
-int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
-			     int reg, int val)
+int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_phy_page_read(ds, port, page, reg);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
+				     int reg, int val)
+{
+	int ret;
+
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
-		goto error;
-
+		goto clear;
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
-error:
+clear:
 	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	return ret;
+}
+
+int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
+			     int reg, int val)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_phy_page_write(ds, port, page, reg, val);
 	mutex_unlock(&ps->smi_mutex);
+
 	return ret;
 }
 
-- 
2.4.3
