From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 2/2] net: dsa: mv88e6xxx: add SERDES registers to debugfs
Date: Wed,  8 Jul 2015 16:36:19 -0400
Message-ID: <1436387779-23407-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add read and write access to a SERDES column in the regs debugfs file
for the Fiber/SERDES registers.

For instance, imagining that the Fiber Control register value is 0x1940,
you can clear the POWER_DOWN bit (11) with:

    echo SERDES 0 1140 > /sys/kernel/debug/dsa0/regs

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 11 ++++++++---
 drivers/net/dsa/mv88e6xxx.h |  4 ++++
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 04e6eb6..f1e9ab4 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1628,16 +1628,18 @@ static int mv88e6xxx_regs_show(struct seq_file *s, void *p)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int reg, port;
 
-	seq_puts(s, "    GLOBAL GLOBAL2 ");
+	seq_puts(s, "    GLOBAL GLOBAL2 SERDES ");
 	for (port = 0 ; port < ps->num_ports; port++)
 		seq_printf(s, " %2d  ", port);
 	seq_puts(s, "\n");
 
 	for (reg = 0; reg < 32; reg++) {
 		seq_printf(s, "%2x: ", reg);
-		seq_printf(s, " %4x    %4x  ",
+		seq_printf(s, " %4x    %4x    %4x  ",
 			   mv88e6xxx_reg_read(ds, REG_GLOBAL, reg),
-			   mv88e6xxx_reg_read(ds, REG_GLOBAL2, reg));
+			   mv88e6xxx_reg_read(ds, REG_GLOBAL2, reg),
+			   mv88e6xxx_phy_page_read(ds, REG_FIBER_SERDES,
+						   PAGE_FIBER_SERDES, reg));
 
 		for (port = 0 ; port < ps->num_ports; port++)
 			seq_printf(s, "%4x ",
@@ -1669,6 +1671,9 @@ static ssize_t mv88e6xxx_regs_write(struct file *file, const char __user *buf,
 		ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, reg, val);
 	else if (strcasecmp(name, "GLOBAL2") == 0)
 		ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, reg, val);
+	else if (strcasecmp(name, "SERDES") == 0)
+		ret = mv88e6xxx_phy_page_write(ds, REG_FIBER_SERDES,
+					       PAGE_FIBER_SERDES, reg, val);
 	else if (kstrtouint(name, 10, &port) == 0 && port < ps->num_ports)
 		ret = mv88e6xxx_reg_write(ds, REG_PORT(port), reg, val);
 	else
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 1bc5a3e..87573c3 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -310,6 +310,10 @@
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
+/* Fiber/SERDES Registers are located at SMI address F, page 1 */
+#define REG_FIBER_SERDES	0x0f
+#define PAGE_FIBER_SERDES	0x01
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
-- 
2.4.5
