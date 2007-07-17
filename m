From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 4/4] gianfar: Fix RGMII-ID handling in gianfar
Date: Mon, 16 Jul 2007 20:27:01 -0500
Message-ID: <11846356251126-git-send-email-afleming@freescale.com>
References: <1184635621688-git-send-email-afleming@freescale.com> <1184635622653-git-send-email-afleming@freescale.com> <11846356233423-git-send-email-afleming@freescale.com> <11846356241295-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com, paulus@samba.org, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:35758 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001AbXGQB2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:28:03 -0400
In-Reply-To: <11846356241295-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TSEC/eTSEC can detect the interface to the PHY automatically,
but it isn't able to detect whether the RGMII connection needs internal
delay.  So we need to detect that change in the device tree, propagate
it to the platform data, and then check it if we're in RGMII.  This fixes
a bug on the 8641D HPCN board where the Vitesse PHY doesn't use the delay
for RGMII.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 arch/powerpc/sysdev/fsl_soc.c |    9 +++++++++
 drivers/net/gianfar.c         |   12 +++++++++++-
 include/linux/fsl_devices.h   |    1 +
 3 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index cad1757..64efee6 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -197,6 +197,7 @@ static int __init gfar_of_init(void)
 		struct gianfar_platform_data gfar_data;
 		const unsigned int *id;
 		const char *model;
+		const char *ctype;
 		const void *mac_addr;
 		const phandle *ph;
 		int n_res = 2;
@@ -254,6 +255,14 @@ static int __init gfar_of_init(void)
 			    FSL_GIANFAR_DEV_HAS_VLAN |
 			    FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
 
+		ctype = of_get_property(np, "phy-connection-type", NULL);
+
+		/* We only care about rgmii-id.  The rest are autodetected */
+		if (ctype && !strcmp(ctype, "rgmii-id"))
+			gfar_data.interface = PHY_INTERFACE_MODE_RGMII_ID;
+		else
+			gfar_data.interface = PHY_INTERFACE_MODE_MII;
+
 		ph = of_get_property(np, "phy-handle", NULL);
 		phy = of_find_node_by_phandle(*ph);
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index d7a1a58..f926905 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -420,8 +420,18 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 	if (ecntrl & ECNTRL_REDUCED_MODE) {
 		if (ecntrl & ECNTRL_REDUCED_MII_MODE)
 			return PHY_INTERFACE_MODE_RMII;
-		else
+		else {
+			phy_interface_t interface = priv->einfo->interface;
+
+			/*
+			 * This isn't autodetected right now, so it must
+			 * be set by the device tree or platform code.
+			 */
+			if (interface == PHY_INTERFACE_MODE_RGMII_ID)
+				return PHY_INTERFACE_MODE_RGMII_ID;
+
 			return PHY_INTERFACE_MODE_RGMII;
+		}
 	}
 
 	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT)
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 73710d6..2de358f 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -53,6 +53,7 @@ struct gianfar_platform_data {
 	u32	bus_id;
 	u32	phy_id;
 	u8	mac_addr[6];
+	phy_interface_t interface;
 };
 
 struct gianfar_mdio_data {
-- 
1.5.0.2.230.gfbe3d-dirty

