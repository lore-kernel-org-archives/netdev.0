From: Luciano Coelho <coelho@ti.com>
Subject: [PATCH] wlcore: remove newly introduced alloc/OOM messages
Date: Mon, 11 Feb 2013 10:02:29 +0200
Message-ID: <1360569749-28372-1-git-send-email-coelho@ti.com>
References: <1360569218.12803.50.camel@cumari.coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <joe@perches.com>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1360569218.12803.50.camel@cumari.coelho.fi>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit 0d2e7a5c (wireless: Remove unnecessary alloc/OOM messages,
alloc cleanups) OOM messages after alloc were removed from the wlcore
modules.

Commit afb43e6d (wlcore: remove if_ops from platform_data)
reintroduced a couple of those.  This patch removes them.

Signed-off-by: Luciano Coelho <coelho@ti.com>
---

John,

Can you apply this directly on wireless-next after you process my latest pull-request?

Thanks!

 drivers/net/wireless/ti/Kconfig                    |    9 ----
 drivers/net/wireless/ti/Makefile                   |    4 +-
 drivers/net/wireless/ti/wl1251/ps.c                |    3 +-
 drivers/net/wireless/ti/wl12xx/main.c              |    3 +-
 drivers/net/wireless/ti/wl18xx/conf.h              |    7 ++-
 drivers/net/wireless/ti/wl18xx/main.c              |    5 --
 drivers/net/wireless/ti/wlcore/Kconfig             |    5 ++
 drivers/net/wireless/ti/wlcore/Makefile            |    3 ++
 drivers/net/wireless/ti/wlcore/boot.c              |    4 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |    8 ++--
 drivers/net/wireless/ti/wlcore/main.c              |   17 ++++---
 drivers/net/wireless/ti/wlcore/sdio.c              |    4 +-
 drivers/net/wireless/ti/wlcore/spi.c               |    4 +-
 .../net/wireless/ti/wlcore/wl12xx_platform_data.c  |   49 ++++++++++++++++++++
 drivers/net/wireless/ti/wlcore/wlcore.h            |    1 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    9 +---
 16 files changed, 83 insertions(+), 52 deletions(-)
 create mode 100644 drivers/net/wireless/ti/wlcore/wl12xx_platform_data.c

diff --git a/drivers/net/wireless/ti/Kconfig b/drivers/net/wireless/ti/Kconfig
index cbe1e7f..be80011 100644
--- a/drivers/net/wireless/ti/Kconfig
+++ b/drivers/net/wireless/ti/Kconfig
@@ -12,13 +12,4 @@ source "drivers/net/wireless/ti/wl18xx/Kconfig"
 
 # keep last for automatic dependencies
 source "drivers/net/wireless/ti/wlcore/Kconfig"
-
-config WILINK_PLATFORM_DATA
-	bool "TI WiLink platform data"
-	depends on WLCORE_SDIO || WL1251_SDIO
-	default y
-	---help---
-	Small platform data bit needed to pass data to the sdio modules.
-
-
 endif # WL_TI
diff --git a/drivers/net/wireless/ti/Makefile b/drivers/net/wireless/ti/Makefile
index af14231..4d68239 100644
--- a/drivers/net/wireless/ti/Makefile
+++ b/drivers/net/wireless/ti/Makefile
@@ -1,7 +1,5 @@
 obj-$(CONFIG_WLCORE)			+= wlcore/
 obj-$(CONFIG_WL12XX)			+= wl12xx/
+obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+= wlcore/
 obj-$(CONFIG_WL1251)			+= wl1251/
 obj-$(CONFIG_WL18XX)			+= wl18xx/
-
-# small builtin driver bit
-obj-$(CONFIG_WILINK_PLATFORM_DATA)	+= wilink_platform_data.o
diff --git a/drivers/net/wireless/ti/wl1251/ps.c b/drivers/net/wireless/ti/wl1251/ps.c
index db719f7..b9e27b9 100644
--- a/drivers/net/wireless/ti/wl1251/ps.c
+++ b/drivers/net/wireless/ti/wl1251/ps.c
@@ -68,8 +68,7 @@ int wl1251_ps_elp_wakeup(struct wl1251 *wl)
 	unsigned long timeout, start;
 	u32 elp_reg;
 
-	if (delayed_work_pending(&wl->elp_work))
-		cancel_delayed_work(&wl->elp_work);
+	cancel_delayed_work(&wl->elp_work);
 
 	if (!wl->elp)
 		return 0;
diff --git a/drivers/net/wireless/ti/wl12xx/main.c b/drivers/net/wireless/ti/wl12xx/main.c
index 09694e3..3254bfc 100644
--- a/drivers/net/wireless/ti/wl12xx/main.c
+++ b/drivers/net/wireless/ti/wl12xx/main.c
@@ -1703,8 +1703,7 @@ static struct ieee80211_sta_ht_cap wl12xx_ht_cap = {
 static int wl12xx_setup(struct wl1271 *wl)
 {
 	struct wl12xx_priv *priv = wl->priv;
-	struct wlcore_platdev_data *pdev_data = wl->pdev->dev.platform_data;
-	struct wl12xx_platform_data *pdata = pdev_data->pdata;
+	struct wl12xx_platform_data *pdata = wl->pdev->dev.platform_data;
 
 	wl->rtable = wl12xx_rtable;
 	wl->num_tx_desc = WL12XX_NUM_TX_DESCRIPTORS;
diff --git a/drivers/net/wireless/ti/wl18xx/conf.h b/drivers/net/wireless/ti/wl18xx/conf.h
index e34302e..b5f1148 100644
--- a/drivers/net/wireless/ti/wl18xx/conf.h
+++ b/drivers/net/wireless/ti/wl18xx/conf.h
@@ -23,7 +23,7 @@
 #define __WL18XX_CONF_H__
 
 #define WL18XX_CONF_MAGIC	0x10e100ca
-#define WL18XX_CONF_VERSION	(WLCORE_CONF_VERSION | 0x0006)
+#define WL18XX_CONF_VERSION	(WLCORE_CONF_VERSION | 0x0005)
 #define WL18XX_CONF_MASK	0x0000ffff
 #define WL18XX_CONF_SIZE	(WLCORE_CONF_SIZE + \
 				 sizeof(struct wl18xx_priv_conf))
@@ -70,9 +70,8 @@ struct wl18xx_mac_and_phy_params {
 	u8 pwr_limit_reference_11_abg;
 	u8 per_chan_pwr_limit_arr_11p[NUM_OF_CHANNELS_11_P];
 	u8 pwr_limit_reference_11p;
-	u8 spare1;
-	u8 per_chan_bo_mode_11_abg[13];
-	u8 per_chan_bo_mode_11_p[4];
+	u8 spare1[9];
+	u8 spare2[9];
 	u8 primary_clock_setting_time;
 	u8 clock_valid_on_wake_up;
 	u8 secondary_clock_setting_time;
diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index a10b7a7..0be1cfc 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -547,11 +547,6 @@ static struct wl18xx_priv_conf wl18xx_default_priv_conf = {
 			0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 			0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
 		.pwr_limit_reference_11p	= 0x64,
-		.per_chan_bo_mode_11_abg	= { 0x00, 0x00, 0x00, 0x00,
-						    0x00, 0x00, 0x00, 0x00,
-						    0x00, 0x00, 0x00, 0x00,
-						    0x00 },
-		.per_chan_bo_mode_11_p		= { 0x00, 0x00, 0x00, 0x00 },
 		.per_chan_pwr_limit_arr_11p	= { 0xff, 0xff, 0xff, 0xff,
 						    0xff, 0xff, 0xff },
 		.psat				= 0,
diff --git a/drivers/net/wireless/ti/wlcore/Kconfig b/drivers/net/wireless/ti/wlcore/Kconfig
index 2b83282..d7b907e 100644
--- a/drivers/net/wireless/ti/wlcore/Kconfig
+++ b/drivers/net/wireless/ti/wlcore/Kconfig
@@ -33,3 +33,8 @@ config WLCORE_SDIO
 
 	  If you choose to build a module, it'll be called wlcore_sdio.
 	  Say N if unsure.
+
+config WL12XX_PLATFORM_DATA
+	bool
+	depends on WLCORE_SDIO != n || WL1251_SDIO != n
+	default y
diff --git a/drivers/net/wireless/ti/wlcore/Makefile b/drivers/net/wireless/ti/wlcore/Makefile
index b21398f..d9fba9e 100644
--- a/drivers/net/wireless/ti/wlcore/Makefile
+++ b/drivers/net/wireless/ti/wlcore/Makefile
@@ -9,4 +9,7 @@ obj-$(CONFIG_WLCORE)			+= wlcore.o
 obj-$(CONFIG_WLCORE_SPI)		+= wlcore_spi.o
 obj-$(CONFIG_WLCORE_SDIO)		+= wlcore_sdio.o
 
+# small builtin driver bit
+obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+= wl12xx_platform_data.o
+
 ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/ti/wlcore/boot.c b/drivers/net/wireless/ti/wlcore/boot.c
index 77752b0..b58ae5f 100644
--- a/drivers/net/wireless/ti/wlcore/boot.c
+++ b/drivers/net/wireless/ti/wlcore/boot.c
@@ -84,8 +84,8 @@ out:
 static int wlcore_validate_fw_ver(struct wl1271 *wl)
 {
 	unsigned int *fw_ver = wl->chip.fw_ver;
-	unsigned int *min_ver = (wl->fw_type == WL12XX_FW_TYPE_MULTI) ?
-		wl->min_mr_fw_ver : wl->min_sr_fw_ver;
+	unsigned int *min_ver = (wl->fw_type == WL12XX_FW_TYPE_NORMAL) ?
+		wl->min_sr_fw_ver : wl->min_mr_fw_ver;
 	char min_fw_str[32] = "";
 	int i;
 
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index 6331f9e..1201aca 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -510,12 +510,10 @@ int wl12xx_cmd_role_start_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	cmd->sta.hlid = wlvif->sta.hlid;
 	cmd->sta.session = wl->session_ids[wlvif->sta.hlid];
 	/*
-	 * We don't have the correct remote rates in this stage.  The
-	 * rates will be reconfigured later, after association, if the
-	 * firmware supports ACX_PEER_CAP.  Otherwise, there's nothing
-	 * we can do, so use all supported_rates here.
+	 * We don't have the correct remote rates in this stage. the rates
+	 * will be reconfigured later, after authorization.
 	 */
-	cmd->sta.remote_rates = cpu_to_le32(supported_rates);
+	cmd->sta.remote_rates = cpu_to_le32(wlvif->rate_set);
 
 	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d "
 		     "basic_rate_set: 0x%x, remote_rates: 0x%x",
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 28a3757..e1dfdf9 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -2162,7 +2162,7 @@ static int wl12xx_init_vif_data(struct wl1271 *wl, struct ieee80211_vif *vif)
 	return 0;
 }
 
-static int wl12xx_init_fw(struct wl1271 *wl)
+static bool wl12xx_init_fw(struct wl1271 *wl)
 {
 	int retries = WL1271_BOOT_RETRIES;
 	bool booted = false;
@@ -2228,7 +2228,7 @@ power_off:
 
 	wl->state = WLCORE_STATE_ON;
 out:
-	return ret;
+	return booted;
 }
 
 static bool wl12xx_dev_role_started(struct wl12xx_vif *wlvif)
@@ -2371,6 +2371,7 @@ static int wl1271_op_add_interface(struct ieee80211_hw *hw,
 	struct vif_counter_data vif_count;
 	int ret = 0;
 	u8 role_type;
+	bool booted = false;
 
 	vif->driver_flags |= IEEE80211_VIF_BEACON_FILTER |
 			     IEEE80211_VIF_SUPPORTS_CQM_RSSI;
@@ -2431,9 +2432,11 @@ static int wl1271_op_add_interface(struct ieee80211_hw *hw,
 		 */
 		memcpy(wl->addresses[0].addr, vif->addr, ETH_ALEN);
 
-		ret = wl12xx_init_fw(wl);
-		if (ret < 0)
+		booted = wl12xx_init_fw(wl);
+		if (!booted) {
+			ret = -EINVAL;
 			goto out;
+		}
 	}
 
 	ret = wl12xx_cmd_role_enable(wl, vif->addr,
@@ -5963,8 +5966,7 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 {
 	struct wl1271 *wl = context;
 	struct platform_device *pdev = wl->pdev;
-	struct wlcore_platdev_data *pdev_data = pdev->dev.platform_data;
-	struct wl12xx_platform_data *pdata = pdev_data->pdata;
+	struct wl12xx_platform_data *pdata = pdev->dev.platform_data;
 	unsigned long irqflags;
 	int ret;
 
@@ -5993,7 +5995,8 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 
 	wl->irq = platform_get_irq(pdev, 0);
 	wl->platform_quirks = pdata->platform_quirks;
-	wl->if_ops = pdev_data->if_ops;
+	wl->set_power = pdata->set_power;
+	wl->if_ops = pdata->ops;
 
 	if (wl->platform_quirks & WL12XX_PLATFORM_QUIRK_EDGE_IRQ)
 		irqflags = IRQF_TRIGGER_RISING;
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index 198028d..29ef249 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -229,10 +229,8 @@ static int wl1271_probe(struct sdio_func *func,
 		return -ENODEV;
 
 	pdev_data = kzalloc(sizeof(*pdev_data), GFP_KERNEL);
-	if (!pdev_data) {
-		dev_err(&func->dev, "can't allocate platdev_data\n");
+	if (!pdev_data)
 		goto out;
-	}
 
 	pdev_data->if_ops = &sdio_ops;
 
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index 5ad2e10..e264478 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -332,10 +332,8 @@ static int wl1271_probe(struct spi_device *spi)
 	int ret = -ENOMEM;
 
 	pdev_data = kzalloc(sizeof(*pdev_data), GFP_KERNEL);
-	if (!pdev_data) {
-		dev_err(&spi->dev, "can't allocate platdev_data\n");
+	if (!pdev_data)
 		goto out;
-	}
 
 	pdev_data->pdata = spi->dev.platform_data;
 	if (!pdev_data->pdata) {
diff --git a/drivers/net/wireless/ti/wlcore/wl12xx_platform_data.c b/drivers/net/wireless/ti/wlcore/wl12xx_platform_data.c
new file mode 100644
index 0000000..998e958
--- /dev/null
+++ b/drivers/net/wireless/ti/wlcore/wl12xx_platform_data.c
@@ -0,0 +1,49 @@
+/*
+ * This file is part of wl12xx
+ *
+ * Copyright (C) 2010-2011 Texas Instruments, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/wl12xx.h>
+
+static struct wl12xx_platform_data *platform_data;
+
+int __init wl12xx_set_platform_data(const struct wl12xx_platform_data *data)
+{
+	if (platform_data)
+		return -EBUSY;
+	if (!data)
+		return -EINVAL;
+
+	platform_data = kmemdup(data, sizeof(*data), GFP_KERNEL);
+	if (!platform_data)
+		return -ENOMEM;
+
+	return 0;
+}
+
+struct wl12xx_platform_data *wl12xx_get_platform_data(void)
+{
+	if (!platform_data)
+		return ERR_PTR(-ENODEV);
+
+	return platform_data;
+}
+EXPORT_SYMBOL(wl12xx_get_platform_data);
diff --git a/drivers/net/wireless/ti/wlcore/wlcore.h b/drivers/net/wireless/ti/wlcore/wlcore.h
index af9feca..ebd8c6f 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore.h
@@ -183,6 +183,7 @@ struct wl1271 {
 
 	struct wl1271_if_operations *if_ops;
 
+	void (*set_power)(bool enable);
 	int irq;
 
 	spinlock_t wl_lock;
diff --git a/drivers/net/wireless/ti/wlcore/wlcore_i.h b/drivers/net/wireless/ti/wlcore/wlcore_i.h
index c845b0e..910f8e2 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore_i.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore_i.h
@@ -111,9 +111,9 @@ enum {
 
 struct wl1271_chip {
 	u32 id;
-	char fw_ver_str[ETHTOOL_BUSINFO_LEN];
+	char fw_ver_str[ETHTOOL_FWVERS_LEN];
 	unsigned int fw_ver[NUM_FW_VER];
-	char phy_fw_ver_str[ETHTOOL_BUSINFO_LEN];
+	char phy_fw_ver_str[ETHTOOL_FWVERS_LEN];
 };
 
 #define NUM_TX_QUEUES              4
@@ -206,11 +206,6 @@ struct wl1271_if_operations {
 	void (*set_block_size) (struct device *child, unsigned int blksz);
 };
 
-struct wlcore_platdev_data {
-	struct wl12xx_platform_data *pdata;
-	struct wl1271_if_operations *if_ops;
-};
-
 #define MAX_NUM_KEYS 14
 #define MAX_KEY_SIZE 32
 
-- 
1.7.10.4
