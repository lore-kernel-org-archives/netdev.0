From: Vadim Pasternak <vadimp@mellanox.com>
Subject: [patch v1 2/2] mlxsw: core: add support for the external thermal zone setting (by DTS)
Date: Tue, 29 Aug 2017 18:45:11 +0000
Message-ID: <1504032311-195988-3-git-send-email-vadimp@mellanox.com>
References: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
Cc: jiri@resnulli.us, ivecera@redhat.com, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, Vadim Pasternak <vadimp@mellanox.com>
To: robh+dt@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34182 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751717AbdH2QsJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:48:09 -0400
In-Reply-To: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It allows:
- thermal zone setting for mlxsw based HW and from DTS file;
- binding ASIC temperature sensor to  cooling devices.
It requires setting of CONFIG_OF.

Signed-off-by: Vadim Pasternak <vadimp@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_thermal.c | 107 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/minimal.c      |   6 ++
 2 files changed, 109 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_thermal.c b/drivers/net/ethernet/mellanox/mlxsw/core_thermal.c
index d866c98..c30783e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_thermal.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_thermal.c
@@ -34,6 +34,7 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/device.h>
+#include <linux/of_platform.h>
 #include <linux/sysfs.h>
 #include <linux/thermal.h>
 #include <linux/err.h>
@@ -44,6 +45,7 @@
 #define MLXSW_THERMAL_MAX_TEMP	110000	/* 110C */
 #define MLXSW_THERMAL_MAX_STATE	10
 #define MLXSW_THERMAL_MAX_DUTY	255
+#define MLXSW_THERMAL_TRIP_ELEM	4
 
 struct mlxsw_thermal_trip {
 	int	type;
@@ -98,6 +100,8 @@ struct mlxsw_thermal {
 	struct thermal_cooling_device *cdevs[MLXSW_MFCR_PWMS_MAX];
 	struct mlxsw_thermal_trip trips[MLXSW_THERMAL_NUM_TRIPS];
 	enum thermal_device_mode mode;
+	int ntrips;
+	bool cooling_external;
 };
 
 static inline u8 mlxsw_state_to_duty(int state)
@@ -121,6 +125,10 @@ static int mlxsw_get_cooling_device_idx(struct mlxsw_thermal *thermal,
 		if (thermal->cdevs[i] == cdev)
 			return i;
 
+	/* Allow external cooling binding if theres is no local. */
+	if (thermal->cooling_external)
+		return 0;
+
 	return -ENODEV;
 }
 
@@ -334,6 +342,83 @@ static const struct thermal_cooling_device_ops mlxsw_cooling_ops = {
 	.set_cur_state	= mlxsw_thermal_set_cur_state,
 };
 
+#ifdef CONFIG_OF
+static int
+mlxsw_thermal_of_init(struct device *dev, struct mlxsw_thermal *thermal)
+{
+	struct device_node *np = dev->of_node;
+	u32 trip[MLXSW_THERMAL_TRIP_ELEM];
+	struct platform_device *pdev;
+	struct device_node *phandle;
+	struct device_node *gchild;
+	struct device_node *child;
+	int ntrips;
+	int i;
+	int ret;
+
+	/* trips */
+	child = of_get_child_by_name(np, "trips");
+
+	/* No trips provided */
+	if (!child) {
+		of_node_put(child);
+		return -EINVAL;
+	}
+
+	/* Cooling device is optional parameter. If it is not defined, driver
+	 * will try to connect PWM which is owned, if any.
+	 */
+	phandle = of_parse_phandle(child, "cooling-phandle", 0);
+	if (phandle) {
+		pdev = of_find_device_by_node(phandle);
+		of_node_put(phandle);
+		if (!pdev) {
+			ret = -ENODEV;
+			goto put_child;
+		}
+
+		thermal->cooling_external = true;
+	}
+
+	ntrips = of_get_child_count(child);
+	if (ntrips == 0) {
+		/* should have at least one child */
+		ret = 0;
+		goto put_child;
+	}
+
+	i = 0;
+	for_each_child_of_node(child, gchild) {
+		ret = of_property_count_u32_elems(gchild, "trip");
+		if (ret != MLXSW_THERMAL_TRIP_ELEM) {
+			ret = -EINVAL;
+			goto put_child;
+		}
+
+		ret = of_property_read_u32_array(gchild, "trip",
+						 trip, ret);
+		if (ret)
+			goto put_gchild;
+
+		memcpy(&thermal->trips[i++], trip, sizeof(trip));
+	}
+	ret = ntrips;
+
+put_gchild:
+	of_node_put(gchild);
+put_child:
+	of_node_put(child);
+
+	return ret;
+}
+#else
+static int
+mlxsw_thermal_of_init(struct device *dev, struct mlxsw_thermal *thermal)
+{
+	return 0;
+}
+#endif
+
 int mlxsw_thermal_init(struct mlxsw_core *core,
 		       const struct mlxsw_bus_info *bus_info,
 		       struct mlxsw_thermal **p_thermal)
@@ -344,7 +429,9 @@ int mlxsw_thermal_init(struct mlxsw_core *core,
 	struct mlxsw_thermal *thermal;
 	u16 tacho_active;
 	u8 pwm_active;
-	int err, i;
+	int ntrips;
+	int i;
+	int err;
 
 	thermal = devm_kzalloc(dev, sizeof(*thermal),
 			       GFP_KERNEL);
@@ -353,7 +440,19 @@ int mlxsw_thermal_init(struct mlxsw_core *core,
 
 	thermal->core = core;
 	thermal->bus_info = bus_info;
-	memcpy(thermal->trips, default_thermal_trips, sizeof(thermal->trips));
+
+	if (dev->of_node) {
+		ntrips = mlxsw_thermal_of_init(dev, thermal);
+		if (ntrips > 0)
+			thermal->ntrips = ntrips;
+	}
+
+	if (!dev->of_node || ntrips <= 0) {
+		/* Use default if the external setting is not available */
+		memcpy(thermal->trips, default_thermal_trips,
+		       sizeof(thermal->trips));
+		thermal->ntrips = MLXSW_THERMAL_NUM_TRIPS;
+	}
 
 	err = mlxsw_reg_query(thermal->core, MLXSW_REG(mfcr), mfcr_pl);
 	if (err) {
@@ -398,8 +497,8 @@ int mlxsw_thermal_init(struct mlxsw_core *core,
 	}
 
 	thermal->tzdev = thermal_zone_device_register("mlxsw",
-						      MLXSW_THERMAL_NUM_TRIPS,
-						      MLXSW_THERMAL_TRIP_MASK,
+						      thermal->ntrips,
+						      BIT(thermal->ntrips) - 1,
 						      thermal,
 						      &mlxsw_thermal_ops,
 						      NULL, 0,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/minimal.c b/drivers/net/ethernet/mellanox/mlxsw/minimal.c
index 3dd1626..8e3cc13 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/minimal.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/minimal.c
@@ -56,8 +56,14 @@ static const struct i2c_device_id mlxsw_minimal_i2c_id[] = {
 	{ },
 };
 
+static const struct of_device_id mlxsw_minimal_dt_match[] = {
+	{ .compatible = "mellanox,mlxsw_minimal" },
+	{ },
+};
+
 static struct i2c_driver mlxsw_minimal_i2c_driver = {
 	.driver.name = "mlxsw_minimal",
+	.driver.of_match_table = of_match_ptr(mlxsw_minimal_dt_match),
 	.class = I2C_CLASS_HWMON,
 	.id_table = mlxsw_minimal_i2c_id,
 };
-- 
2.1.4
