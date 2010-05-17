From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] phy/marvell: Add special settings for D-Link DNS-323
	rev C1
Date: Mon, 17 May 2010 21:36:54 +1000
Message-ID: <1274096214.21352.735.camel@pasglop>
References: <1274056058.21352.697.camel@pasglop>
	<20100517005942.GB27301@pengutronix.de>
	<1274058457.21352.711.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@fluxnic.net>,
	linux-arm-kernel@lists.infradead.org, Herbert Valerio Riedel <hvr@gnu.org>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1274058457.21352.711.camel@pasglop>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-05-17 at 11:07 +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2010-05-17 at 02:59 +0200, Wolfram Sang wrote:
> > There is a fixup()-callback to prevent boardcode in the drivers. See
> > Documentation/networking/phy.txt, last chapter.
> 
> Ah nice ! I missed that bit. I'll add a fixup and see if it works.
> 
> The problem is that writing to this register seems to be part of a
> specific initialization sequence, which is done one way in the linux
> driver and differently in the vendor kernel. I don't know whether
> I can just 'override' the value and I have no docs for that part.
> 
> But I'll definitely give it a go tonight.

Ok, that doesn't work.

The problem is that the fixups are called -after- the config_init()
callback of the PHY driver. However, the marvell m88e1118 PHY driver
will unconditionally reset the LEDs setting.

So either we add a layer of PHY fixups to run after init, or I replace
the init completely in my fixup routine. A way to do that would be to do
a small change to allow the fixup code to request the core to skip
config_init().

Something along those lines:

net/phy: Allow platform fixups to completely override the PHY init routine

The fixups are called before the PHY init routine. In some case, that
means that whatever LEDs setup they attempt to do is undone by the said
initialization code.

This patch allows to work around it by enabling the fixups to return the
positive PHY_FIXUP_SKIP_INIT result code, which will cause the core to
skip the normal init routine.

Using this, a platform fixup can effectively replace the entire init
routine for a given PHY.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--- 

(untested btw)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 64be466..48436e6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -353,10 +353,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		phy_write(phydev, mii_data->reg_num, val);
 		
 		if (mii_data->reg_num == MII_BMCR &&
-		    val & BMCR_RESET &&
-		    phydev->drv->config_init) {
-			phy_scan_fixups(phydev);
-			phydev->drv->config_init(phydev);
+		    val & BMCR_RESET && phydev->drv->config_init) {
+			if (phy_scan_fixups(phydev) != PHY_FIXUP_SKIP_INIT)
+				phydev->drv->config_init(phydev);
 		}
 		break;
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index db17945..44ab890 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -126,6 +126,7 @@ static int phy_needs_fixup(struct phy_device *phydev, struct phy_fixup *fixup)
 int phy_scan_fixups(struct phy_device *phydev)
 {
 	struct phy_fixup *fixup;
+	int rc = 0;
 
 	mutex_lock(&phy_fixup_lock);
 	list_for_each_entry(fixup, &phy_fixup_list, list) {
@@ -138,11 +139,13 @@ int phy_scan_fixups(struct phy_device *phydev)
 				mutex_unlock(&phy_fixup_lock);
 				return err;
 			}
+			if (err == PHY_FIXUP_SKIP_INIT)
+				rc = err;
 		}
 	}
 	mutex_unlock(&phy_fixup_lock);
 
-	return 0;
+	return rc;
 }
 EXPORT_SYMBOL(phy_scan_fixups);
 
@@ -405,6 +408,8 @@ int phy_init_hw(struct phy_device *phydev)
 	ret = phy_scan_fixups(phydev);
 	if (ret < 0)
 		return ret;
+	if (ret == PHY_FIXUP_SKIP_INIT)
+		return 0;
 
 	return phydev->drv->config_init(phydev);
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 14d7fdf..5e2b026 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -413,6 +413,12 @@ struct phy_fixup {
 	int (*run)(struct phy_device *phydev);
 };
 
+/* The fixup can return this to skip the PHY driver init routine
+ * (ie. the fixup effectively replaces the init routine)
+ */
+#define PHY_FIXUP_SKIP_INIT	1
+
+
 /**
  * phy_read - Convenience function for reading a given PHY register
  * @phydev: the phy_device struct
