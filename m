From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3] net: fec: Fix build for MCF5272
Date: Fri, 28 Jun 2013 20:12:47 -0700
Message-ID: <20130629031247.GA21068@roeck-us.net>
References: <1371575099-2962-1-git-send-email-linux@roeck-us.net>
 <20130619.170018.1690166635385887009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, festevam@gmail.com,
	linux-kernel@vger.kernel.org, Frank.Li@freescale.com,
	jim_baxter@mentor.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130619.170018.1690166635385887009.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 05:00:18PM -0700, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Tue, 18 Jun 2013 10:04:59 -0700
> 
> > Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration) and
> > baa70a5c (net: fec: enable pause frame to improve rx prefomance for 1G
> > network) introduced functionality into the FEC driver which is not
> > supported on MCF5272. The registers used to implement this functionality
> > do not exist on MCF5272. Since register defines for MCF5272 are separate
> > from register defines for other chips, building images for MCF5272 fails
> > as follows.
> > 
> > fec_main.c: In function 'fec_restart':
> > fec_main.c:520:8: error: 'FEC_RACC' undeclared (first use in this function)
> > fec_main.c:585:3: error: 'FEC_R_FIFO_RSEM' undeclared (first use in this function)
> > fec_main.c:586:3: error: 'FEC_R_FIFO_RSFL' undeclared (first use in this function)
> > fec_main.c:587:3: error: 'FEC_R_FIFO_RAEM' undeclared (first use in this function)
> > fec_main.c:588:3: error: 'FEC_R_FIFO_RAFL' undeclared (first use in this function)
> > fec_main.c:591:3: error: 'FEC_OPD' undeclared (first use in this function)
> > 
> > Adding the missing register defines is not an option, since the registers
> > do not exist on MCF5272. Disable the added functionality for MCF5272 builds.
> > 
> > Cc: Frank Li <Frank.Li@freescale.com>
> > Cc: Jim Baxter <jim_baxter@mentor.com>
> > Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> 
> Applied, thanks.
> 
> > This problem exists in 3.9 as well, though only due to commit baa70a5c. The
> > patch does therefore not cleanly apply to 3.9. Options I can see are to ignore
> > the build error in 3.9, to back-port the patch manually, or to split it into
> > two separate patches. David, let me know which approach you prefer. 
> 
> You can feel free to send me a backport for v3.9-stable, thanks.
> 

Here it is.

Guenter

---
From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 18 Jun 2013 10:04:59 -0700
Subject: [PATCH] net: fec: Fix build for MCF5272

Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration) and
baa70a5c (net: fec: enable pause frame to improve rx prefomance for 1G
network) introduced functionality into the FEC driver which is not
supported on MCF5272. The registers used to implement this functionality
do not exist on MCF5272. Since register defines for MCF5272 are separate
from register defines for other chips, building images for MCF5272 fails
as follows.

fec_main.c: In function 'fec_restart':
fec_main.c:520:8: error: 'FEC_RACC' undeclared (first use in this function)
fec_main.c:585:3: error: 'FEC_R_FIFO_RSEM' undeclared (first use in this function)
fec_main.c:586:3: error: 'FEC_R_FIFO_RSFL' undeclared (first use in this function)
fec_main.c:587:3: error: 'FEC_R_FIFO_RAEM' undeclared (first use in this function)
fec_main.c:588:3: error: 'FEC_R_FIFO_RAFL' undeclared (first use in this function)
fec_main.c:591:3: error: 'FEC_OPD' undeclared (first use in this function)

Adding the missing register defines is not an option, since the registers
do not exist on MCF5272. Disable the added functionality for MCF5272 builds.

Backport to v3.9. Upstream commit d13919301d9a34cd4d3cc5ac73b89012c48cad71.

Cc: Frank Li <Frank.Li@freescale.com>
Cc: Jim Baxter <jim_baxter@mentor.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/freescale/fec.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ef5b595..49af0174 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -527,6 +527,7 @@ fec_restart(struct net_device *ndev, int duplex)
 #endif
 	}
 
+#if !defined(CONFIG_M5272)
 	/* enable pause frame*/
 	if ((fep->pause_flag & FEC_PAUSE_FLAG_ENABLE) ||
 	    ((fep->pause_flag & FEC_PAUSE_FLAG_AUTONEG) &&
@@ -544,6 +545,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	} else {
 		rcntl &= ~FEC_ENET_FCE;
 	}
+#endif /* !defined(CONFIG_M5272) */
 
 	writel(rcntl, fep->hwp + FEC_R_CNTRL);
 
@@ -1139,7 +1141,9 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	/* mask with MAC supported features */
 	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
 		phy_dev->supported &= PHY_GBIT_FEATURES;
+#if !defined(CONFIG_M5272)
 		phy_dev->supported |= SUPPORTED_Pause;
+#endif
 	}
 	else
 		phy_dev->supported &= PHY_BASIC_FEATURES;
@@ -1326,6 +1330,8 @@ static int fec_enet_get_ts_info(struct net_device *ndev,
 	}
 }
 
+#if !defined(CONFIG_M5272)
+
 static void fec_enet_get_pauseparam(struct net_device *ndev,
 				    struct ethtool_pauseparam *pause)
 {
@@ -1372,9 +1378,13 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 	return 0;
 }
 
+#endif /* !defined(CONFIG_M5272) */
+
 static const struct ethtool_ops fec_enet_ethtool_ops = {
+#if !defined(CONFIG_M5272)
 	.get_pauseparam		= fec_enet_get_pauseparam,
 	.set_pauseparam		= fec_enet_set_pauseparam,
+#endif
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
@@ -1794,10 +1804,12 @@ fec_probe(struct platform_device *pdev)
 	/* setup board info structure */
 	fep = netdev_priv(ndev);
 
+#if !defined(CONFIG_M5272)
 	/* default enable pause frame auto negotiation */
 	if (pdev->id_entry &&
 	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
 		fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
+#endif
 
 	fep->hwp = ioremap(r->start, resource_size(r));
 	fep->pdev = pdev;
-- 
1.7.9.7
