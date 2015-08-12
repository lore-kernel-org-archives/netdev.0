From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 12 Aug 2015 17:06:27 -0500
Message-ID: <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	rafael.j.wysocki@intel.com, grant.likely@linaro.org,
	Suravee.Suthikulpanit@amd.com, Catalin.Marinas@arm.com,
	Jeremy Linton <jeremy.linton@arm.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:23302 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751867AbbHLWGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 18:06:52 -0400
In-Reply-To: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ACPI bindings for the smsc911x driver. Convert the DT specific calls
to nonspecific device* calls, This allows the driver to work
with both ACPI and DT configurations. Ethernet should now work when using
ACPI on ARM Juno.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 48 +++++++++++++++++---------------=
----
 1 file changed, 22 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/sm=
sc/smsc911x.c
index 959aeea..0f21aa3 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -59,7 +59,9 @@
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
+#include <linux/acpi.h>
 #include <linux/pm_runtime.h>
+#include <linux/property.h>
=20
 #include "smsc911x.h"
=20
@@ -2362,59 +2364,46 @@ static const struct smsc911x_ops shifted_smsc911x_o=
ps =3D {
 =09.tx_writefifo =3D smsc911x_tx_writefifo_shift,
 };
=20
-#ifdef CONFIG_OF
-static int smsc911x_probe_config_dt(struct smsc911x_platform_config *confi=
g,
-=09=09=09=09    struct device_node *np)
+static int smsc911x_probe_config(struct smsc911x_platform_config *config,
+=09=09=09=09 struct device *dev)
 {
-=09const char *mac;
 =09u32 width =3D 0;
=20
-=09if (!np)
+=09if (!dev)
 =09=09return -ENODEV;
=20
-=09config->phy_interface =3D of_get_phy_mode(np);
+=09config->phy_interface =3D device_get_phy_mode(dev);
=20
-=09mac =3D of_get_mac_address(np);
-=09if (mac)
-=09=09memcpy(config->mac, mac, ETH_ALEN);
+=09device_get_mac_address(dev, config->mac, ETH_ALEN);
=20
-=09of_property_read_u32(np, "reg-shift", &config->shift);
+=09device_property_read_u32(dev, "reg-shift", &config->shift);
=20
-=09of_property_read_u32(np, "reg-io-width", &width);
+=09device_property_read_u32(dev, "reg-io-width", &width);
 =09if (width =3D=3D 4)
 =09=09config->flags |=3D SMSC911X_USE_32BIT;
 =09else
 =09=09config->flags |=3D SMSC911X_USE_16BIT;
=20
-=09if (of_get_property(np, "smsc,irq-active-high", NULL))
+=09if (device_property_present(dev, "smsc,irq-active-high"))
 =09=09config->irq_polarity =3D SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
=20
-=09if (of_get_property(np, "smsc,irq-push-pull", NULL))
+=09if (device_property_present(dev, "smsc,irq-push-pull"))
 =09=09config->irq_type =3D SMSC911X_IRQ_TYPE_PUSH_PULL;
=20
-=09if (of_get_property(np, "smsc,force-internal-phy", NULL))
+=09if (device_property_present(dev, "smsc,force-internal-phy"))
 =09=09config->flags |=3D SMSC911X_FORCE_INTERNAL_PHY;
=20
-=09if (of_get_property(np, "smsc,force-external-phy", NULL))
+=09if (device_property_present(dev, "smsc,force-external-phy"))
 =09=09config->flags |=3D SMSC911X_FORCE_EXTERNAL_PHY;
=20
-=09if (of_get_property(np, "smsc,save-mac-address", NULL))
+=09if (device_property_present(dev, "smsc,save-mac-address"))
 =09=09config->flags |=3D SMSC911X_SAVE_MAC_ADDRESS;
=20
 =09return 0;
 }
-#else
-static inline int smsc911x_probe_config_dt(
-=09=09=09=09struct smsc911x_platform_config *config,
-=09=09=09=09struct device_node *np)
-{
-=09return -ENODEV;
-}
-#endif /* CONFIG_OF */
=20
 static int smsc911x_drv_probe(struct platform_device *pdev)
 {
-=09struct device_node *np =3D pdev->dev.of_node;
 =09struct net_device *dev;
 =09struct smsc911x_data *pdata;
 =09struct smsc911x_platform_config *config =3D dev_get_platdata(&pdev->dev=
);
@@ -2478,7 +2467,7 @@ static int smsc911x_drv_probe(struct platform_device =
*pdev)
 =09=09goto out_disable_resources;
 =09}
=20
-=09retval =3D smsc911x_probe_config_dt(&pdata->config, np);
+=09retval =3D smsc911x_probe_config(&pdata->config, &pdev->dev);
 =09if (retval && config) {
 =09=09/* copy config parameters across to pdata */
 =09=09memcpy(&pdata->config, config, sizeof(pdata->config));
@@ -2654,6 +2643,12 @@ static const struct of_device_id smsc911x_dt_ids[] =
=3D {
 MODULE_DEVICE_TABLE(of, smsc911x_dt_ids);
 #endif
=20
+static const struct acpi_device_id smsc911x_acpi_match[] =3D {
+=09{ "ARMH9118", 0 },
+=09{ }
+};
+MODULE_DEVICE_TABLE(acpi, smsc911x_acpi_match);
+
 static struct platform_driver smsc911x_driver =3D {
 =09.probe =3D smsc911x_drv_probe,
 =09.remove =3D smsc911x_drv_remove,
@@ -2661,6 +2656,7 @@ static struct platform_driver smsc911x_driver =3D {
 =09=09.name=09=3D SMSC_CHIPNAME,
 =09=09.pm=09=3D SMSC911X_PM_OPS,
 =09=09.of_match_table =3D of_match_ptr(smsc911x_dt_ids),
+=09=09.acpi_match_table =3D ACPI_PTR(smsc911x_acpi_match),
 =09},
 };
=20
--=20
2.4.3
