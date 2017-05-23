From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/8] mlxsw: spectrum: Validate firmware revision on init
Date: Tue, 23 May 2017 21:56:29 +0200
Message-ID: <20170523195630.6460-8-jiri@resnulli.us>
References: <20170523195630.6460-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34564 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967265AbdEWT4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:56:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id d127so41922439wmf.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:56:42 -0700 (PDT)
In-Reply-To: <20170523195630.6460-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Make the spectrum module check the current device firmware version, and if
it is below the supported version, use the libfirmware API to request a
firmware file with the supported firmware version and flash it to the
device using the mlxfw module.

The firmware file names are expected to be of Mellanox Firmware Archive
version 2 (MFA2) format and their name are expected to be in the following
pattern: "mlxsw_spectrum-<major>.<minor>.<sub-minor>.mfa2".

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig    |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 67 ++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index ef23eae..b9f80c2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -75,6 +75,7 @@ config MLXSW_SPECTRUM
 	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
 	depends on PSAMPLE || PSAMPLE=n
 	select PARMAN
+	select MLXFW
 	default m
 	---help---
 	  This driver supports Mellanox Technologies Spectrum Ethernet
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b533a53..9594e9d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -70,6 +70,21 @@
 #include "spectrum_dpipe.h"
 #include "../mlxfw/mlxfw.h"
 
+#define MLXSW_FWREV_MAJOR 13
+#define MLXSW_FWREV_MINOR 1420
+#define MLXSW_FWREV_SUBMINOR 122
+
+static const struct mlxsw_fw_rev mlxsw_sp_supported_fw_rev = {
+	.major = MLXSW_FWREV_MAJOR,
+	.minor = MLXSW_FWREV_MINOR,
+	.subminor = MLXSW_FWREV_SUBMINOR
+};
+
+#define MLXSW_SP_FW_FILENAME \
+	"mlxsw_spectrum-" __stringify(MLXSW_FWREV_MAJOR) \
+	"." __stringify(MLXSW_FWREV_MINOR) \
+	"." __stringify(MLXSW_FWREV_SUBMINOR) ".mfa2"
+
 static const char mlxsw_sp_driver_name[] = "mlxsw_spectrum";
 static const char mlxsw_sp_driver_version[] = "1.0";
 
@@ -306,6 +321,51 @@ static const struct mlxfw_dev_ops mlxsw_sp_mlxfw_dev_ops = {
 	.fsm_release		= mlxsw_sp_fsm_release
 };
 
+static bool mlxsw_sp_fw_rev_ge(const struct mlxsw_fw_rev *a,
+			       const struct mlxsw_fw_rev *b)
+{
+	if (a->major != b->major)
+		return a->major > b->major;
+	if (a->minor != b->minor)
+		return a->minor > b->minor;
+	return a->subminor >= b->subminor;
+}
+
+static int mlxsw_sp_fw_rev_validate(struct mlxsw_sp *mlxsw_sp)
+{
+	const struct mlxsw_fw_rev *rev = &mlxsw_sp->bus_info->fw_rev;
+	struct mlxsw_sp_mlxfw_dev mlxsw_sp_mlxfw_dev = {
+		.mlxfw_dev = {
+			.ops = &mlxsw_sp_mlxfw_dev_ops,
+			.psid = mlxsw_sp->bus_info->psid,
+			.psid_size = strlen(mlxsw_sp->bus_info->psid),
+		},
+		.mlxsw_sp = mlxsw_sp
+	};
+	const struct firmware *firmware;
+	int err;
+
+	if (mlxsw_sp_fw_rev_ge(rev, &mlxsw_sp_supported_fw_rev))
+		return 0;
+
+	dev_info(mlxsw_sp->bus_info->dev, "The firmware version %d.%d.%d out of data\n",
+		 rev->major, rev->minor, rev->subminor);
+	dev_info(mlxsw_sp->bus_info->dev, "Upgrading firmware using file %s\n",
+		 MLXSW_SP_FW_FILENAME);
+
+	err = request_firmware_direct(&firmware, MLXSW_SP_FW_FILENAME,
+				      mlxsw_sp->bus_info->dev);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Could not request firmware file %s\n",
+			MLXSW_SP_FW_FILENAME);
+		return err;
+	}
+
+	err = mlxfw_firmware_flash(&mlxsw_sp_mlxfw_dev.mlxfw_dev, firmware);
+	release_firmware(firmware);
+	return err;
+}
+
 int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
 			      unsigned int counter_index, u64 *packets,
 			      u64 *bytes)
@@ -3559,6 +3619,12 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	INIT_LIST_HEAD(&mlxsw_sp->fids);
 	INIT_LIST_HEAD(&mlxsw_sp->vfids.list);
 
+	err = mlxsw_sp_fw_rev_validate(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Could not upgrade firmware\n");
+		return err;
+	}
+
 	err = mlxsw_sp_base_mac_get(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to get base mac\n");
@@ -4930,3 +4996,4 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
 MODULE_DESCRIPTION("Mellanox Spectrum driver");
 MODULE_DEVICE_TABLE(pci, mlxsw_sp_pci_id_table);
+MODULE_FIRMWARE(MLXSW_SP_FW_FILENAME);
-- 
2.9.3
