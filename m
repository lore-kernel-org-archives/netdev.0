From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 2/3] gianfar: Use mpc85xx support for errata detection
Date: Wed, 9 Oct 2013 20:20:41 +0300
Message-ID: <1381339242-32030-2-git-send-email-claudiu.manoil@freescale.com>
References: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:14607
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756373Ab3JIRZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:25:41 -0400
In-Reply-To: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the macros and defines from mpc85xx.h to simplify
and prevent errors in identifying a mpc85xx based SoC
for errata detection.
This should help enabling (and identifying) workarounds
for various mpc85xx based chips and revisions.
For instance, express MPC8548 Rev.2 as:
(SVR_SOC_VER(svr) == SVR_8548) && (SVR_REV(svr) == 0x20)
instead of:
(pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020)

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 33 ++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index db5fc7b..329a206 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -88,6 +88,7 @@
 
 #include <asm/io.h>
 #include <asm/reg.h>
+#include <asm/mpc85xx.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 #include <linux/module.h>
@@ -939,17 +940,13 @@ static void gfar_init_filer_table(struct gfar_private *priv)
 	}
 }
 
-static void gfar_detect_errata(struct gfar_private *priv)
+static void __gfar_detect_errata_83xx(struct gfar_private *priv)
 {
-	struct device *dev = &priv->ofdev->dev;
 	unsigned int pvr = mfspr(SPRN_PVR);
 	unsigned int svr = mfspr(SPRN_SVR);
 	unsigned int mod = (svr >> 16) & 0xfff6; /* w/o E suffix */
 	unsigned int rev = svr & 0xffff;
 
-	/* no plans to fix */
-	priv->errata |= GFAR_ERRATA_A002;
-
 	/* MPC8313 Rev 2.0 and higher; All MPC837x */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev >= 0x0020) ||
 	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
@@ -960,10 +957,30 @@ static void gfar_detect_errata(struct gfar_private *priv)
 	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_76;
 
-	/* MPC8313 Rev < 2.0, MPC8548 rev 2.0 */
-	if ((pvr == 0x80850010 && mod == 0x80b0 && rev < 0x0020) ||
-	    (pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
+	/* MPC8313 Rev < 2.0 */
+	if (pvr == 0x80850010 && mod == 0x80b0 && rev < 0x0020)
+		priv->errata |= GFAR_ERRATA_12;
+}
+
+static void __gfar_detect_errata_85xx(struct gfar_private *priv)
+{
+	unsigned int svr = mfspr(SPRN_SVR);
+
+	if ((SVR_SOC_VER(svr) == SVR_8548) && (SVR_REV(svr) == 0x20))
 		priv->errata |= GFAR_ERRATA_12;
+}
+
+static void gfar_detect_errata(struct gfar_private *priv)
+{
+	struct device *dev = &priv->ofdev->dev;
+
+	/* no plans to fix */
+	priv->errata |= GFAR_ERRATA_A002;
+
+	if (pvr_version_is(PVR_VER_E500V1) || pvr_version_is(PVR_VER_E500V2))
+		__gfar_detect_errata_85xx(priv);
+	else /* non-mpc85xx parts, i.e. e300 core based */
+		__gfar_detect_errata_83xx(priv);
 
 	if (priv->errata)
 		dev_info(dev, "enabled errata workarounds, flags: 0x%x\n",
-- 
1.7.11.7
