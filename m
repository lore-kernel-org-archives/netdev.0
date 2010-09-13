From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 6/9] net: davinci_mdio: use calculated bus access times
Date: Mon, 13 Sep 2010 14:07:28 -0400
Message-ID: <1284401251-8846-7-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the hardcoded scan delay with a calculated delay that
adjusts to clock rates.  This delay is calculated on the basis of a worst case
bus transaction time, with generous built-in margins of error.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_mdio.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/davinci_mdio.c b/drivers/net/davinci_mdio.c
index a9fbc26..f2d7639 100644
--- a/drivers/net/davinci_mdio.c
+++ b/drivers/net/davinci_mdio.c
@@ -83,11 +83,12 @@ struct davinci_mdio_data {
 	struct device	*dev;
 	struct mii_bus	*bus;
 	bool		suspended;
+	unsigned long	access_time; /* jiffies */
 };
 
 static void __davinci_mdio_reset(struct davinci_mdio_data *data)
 {
-	u32 mdio_in, div;
+	u32 mdio_in, div, mdio_out_khz, access_time;
 
 	mdio_in = clk_get_rate(data->clk);
 	div = (mdio_in / data->pdata.bus_freq) - 1;
@@ -96,6 +97,25 @@ static void __davinci_mdio_reset(struct davinci_mdio_data *data)
 
 	/* set enable and clock divider */
 	__raw_writel(div | CONTROL_ENABLE, &data->regs->control);
+
+	/*
+	 * One mdio transaction consists of:
+	 *	32 bits of preamble
+	 *	32 bits of transferred data
+	 *	24 bits of bus yield (not needed unless shared?)
+	 */
+	mdio_out_khz = mdio_in / (1000 * (div + 1));
+	access_time  = (88 * 1000) / mdio_out_khz;
+
+	/*
+	 * In the worst case, we could be kicking off a user-access immediately
+	 * after the mdio bus scan state-machine triggered its own read.  If
+	 * so, our request could get deferred by one access cycle.  We
+	 * defensively allow for 4 access cycles.
+	 */
+	data->access_time = usecs_to_jiffies(access_time * 4);
+	if (!data->access_time)
+		data->access_time = 1;
 }
 
 static int davinci_mdio_reset(struct mii_bus *bus)
@@ -105,15 +125,8 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 
 	__davinci_mdio_reset(data);
 
-	/*
-	 * wait for scan logic to settle:
-	 * the scan time consists of (a) a large fixed component, and (b) a
-	 * small component that varies with the mii bus frequency.  These
-	 * were estimated using measurements at 1.1 and 2.2 MHz on tnetv107x
-	 * silicon.  Since the effect of (b) was found to be largely
-	 * negligible, we keep things simple here.
-	 */
-	mdelay(1);
+	/* wait for scan logic to settle */
+	msleep(PHY_MAX_ADDR * data->access_time);
 
 	/* dump hardware version info */
 	ver = __raw_readl(&data->regs->version);
-- 
1.7.0.4

