From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/5] ti: wl1251: Convert wl1251_error to wiphy_err/pr_err
Date: Mon,  7 Mar 2016 16:19:34 -0800
Message-ID: <ab729067d0f9ecff6995dd2cd50e96f5176b2c39.1457395071.git.joe@perches.com>
References: <cover.1457395071.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1457395071.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common logging mechanisms.

Miscellanea:

o Coalesce formats
o Realign arguments
o Reflow to fit 80 columns
o Add #define pr_fmt when pr_<level> is used

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ti/wl1251/acx.c    |  6 ++---
 drivers/net/wireless/ti/wl1251/boot.c   | 18 +++++++-------
 drivers/net/wireless/ti/wl1251/cmd.c    | 42 +++++++++++++++++----------------
 drivers/net/wireless/ti/wl1251/event.c  |  2 +-
 drivers/net/wireless/ti/wl1251/init.c   | 13 +++++-----
 drivers/net/wireless/ti/wl1251/io.c     |  3 ++-
 drivers/net/wireless/ti/wl1251/main.c   | 41 ++++++++++++++++++--------------
 drivers/net/wireless/ti/wl1251/ps.c     |  2 +-
 drivers/net/wireless/ti/wl1251/rx.c     |  2 +-
 drivers/net/wireless/ti/wl1251/sdio.c   | 19 +++++++++------
 drivers/net/wireless/ti/wl1251/spi.c    | 19 ++++++++-------
 drivers/net/wireless/ti/wl1251/tx.c     |  5 ++--
 drivers/net/wireless/ti/wl1251/wl1251.h |  3 ---
 13 files changed, 93 insertions(+), 82 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index d6fbdda..23b4882 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -28,7 +28,7 @@ int wl1251_acx_frame_rates(struct wl1251 *wl, u8 ctrl_rate, u8 ctrl_mod,
 	ret = wl1251_cmd_configure(wl, ACX_FW_GEN_FRAME_RATES,
 				   rates, sizeof(*rates));
 	if (ret < 0) {
-		wl1251_error("Failed to set FW rates and modulation");
+		wiphy_err(wl->hw->wiphy, "Failed to set FW rates and modulation\n");
 		goto out;
 	}
 
@@ -74,7 +74,7 @@ int wl1251_acx_default_key(struct wl1251 *wl, u8 key_id)
 	ret = wl1251_cmd_configure(wl, DOT11_DEFAULT_KEY,
 				   default_key, sizeof(*default_key));
 	if (ret < 0) {
-		wl1251_error("Couldn't set default key");
+		wiphy_err(wl->hw->wiphy, "Couldn't set default key\n");
 		goto out;
 	}
 
@@ -208,7 +208,7 @@ int wl1251_acx_feature_cfg(struct wl1251 *wl, u32 data_flow_options)
 	ret = wl1251_cmd_configure(wl, ACX_FEATURE_CFG,
 				   feature, sizeof(*feature));
 	if (ret < 0) {
-		wl1251_error("Couldn't set HW encryption");
+		wiphy_err(wl->hw->wiphy, "Couldn't set HW encryption\n");
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/boot.c b/drivers/net/wireless/ti/wl1251/boot.c
index 2000cd5..456629a 100644
--- a/drivers/net/wireless/ti/wl1251/boot.c
+++ b/drivers/net/wireless/ti/wl1251/boot.c
@@ -53,7 +53,7 @@ int wl1251_boot_soft_reset(struct wl1251 *wl)
 		if (time_after(jiffies, timeout)) {
 			/* 1.2 check pWhalBus->uSelfClearTime if the
 			 * timeout was reached */
-			wl1251_error("soft reset timeout");
+			wiphy_err(wl->hw->wiphy, "soft reset timeout\n");
 			return -1;
 		}
 
@@ -231,7 +231,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 	wl1251_debug(DEBUG_BOOT, "chip id after firmware boot: 0x%x", chip_id);
 
 	if (chip_id != wl->chip_id) {
-		wl1251_error("chip id doesn't match after firmware boot");
+		wiphy_err(wl->hw->wiphy, "chip id doesn't match after firmware boot\n");
 		return -EIO;
 	}
 
@@ -242,8 +242,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 		acx_intr = wl1251_reg_read32(wl, ACX_REG_INTERRUPT_NO_CLEAR);
 
 		if (acx_intr == 0xffffffff) {
-			wl1251_error("error reading hardware complete "
-				     "init indication");
+			wiphy_err(wl->hw->wiphy, "error reading hardware complete init indication\n");
 			return -EIO;
 		}
 		/* check that ACX_INTR_INIT_COMPLETE is enabled */
@@ -255,8 +254,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 	}
 
 	if (loop > INIT_LOOP) {
-		wl1251_error("timeout waiting for the hardware to "
-			     "complete initialization");
+		wiphy_err(wl->hw->wiphy, "timeout waiting for the hardware to complete initialization\n");
 		return -EIO;
 	}
 
@@ -304,7 +302,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 
 	ret = wl1251_event_unmask(wl);
 	if (ret < 0) {
-		wl1251_error("EVENT mask setting failed");
+		wiphy_err(wl->hw->wiphy, "EVENT mask setting failed\n");
 		return ret;
 	}
 
@@ -333,13 +331,13 @@ static int wl1251_boot_upload_firmware(struct wl1251 *wl)
 		CHUNK_SIZE);
 
 	if ((fw_data_len % 4) != 0) {
-		wl1251_error("firmware length not multiple of four");
+		wiphy_err(wl->hw->wiphy, "firmware length not multiple of four\n");
 		return -EIO;
 	}
 
 	buf = kmalloc(CHUNK_SIZE, GFP_KERNEL);
 	if (!buf) {
-		wl1251_error("allocation for firmware upload chunk failed");
+		wiphy_err(wl->hw->wiphy, "allocation for firmware upload chunk failed\n");
 		return -ENOMEM;
 	}
 
@@ -536,7 +534,7 @@ int wl1251_boot(struct wl1251 *wl)
 	 * pWhalBus->uBootData and start uploading firmware
 	 */
 	if ((boot_data & ECPU_CONTROL_HALT) == 0) {
-		wl1251_error("boot failed, ECPU_CONTROL_HALT not set");
+		wiphy_err(wl->hw->wiphy, "boot failed, ECPU_CONTROL_HALT not set\n");
 		ret = -EIO;
 		goto out;
 	}
diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
index ede31f0..a2a306e 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -40,7 +40,7 @@ int wl1251_cmd_send(struct wl1251 *wl, u16 id, void *buf, size_t len)
 	intr = wl1251_reg_read32(wl, ACX_REG_INTERRUPT_NO_CLEAR);
 	while (!(intr & WL1251_ACX_INTR_CMD_COMPLETE)) {
 		if (time_after(jiffies, timeout)) {
-			wl1251_error("command complete timeout");
+			wiphy_err(wl->hw->wiphy, "command complete timeout\n");
 			ret = -ETIMEDOUT;
 			goto out;
 		}
@@ -91,8 +91,8 @@ int wl1251_cmd_test(struct wl1251 *wl, void *buf, size_t buf_len, u8 answer)
 		cmd_answer = buf;
 
 		if (cmd_answer->header.status != CMD_STATUS_SUCCESS)
-			wl1251_error("TEST command answer error: %d",
-				     cmd_answer->header.status);
+			wiphy_err(wl->hw->wiphy, "TEST command answer error: %d\n",
+				  cmd_answer->header.status);
 	}
 
 	return 0;
@@ -120,7 +120,7 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len)
 
 	ret = wl1251_cmd_send(wl, CMD_INTERROGATE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_error("INTERROGATE command failed");
+		wiphy_err(wl->hw->wiphy, "INTERROGATE command failed\n");
 		goto out;
 	}
 
@@ -129,8 +129,8 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len)
 
 	acx = buf;
 	if (acx->cmd.status != CMD_STATUS_SUCCESS)
-		wl1251_error("INTERROGATE command error: %d",
-			     acx->cmd.status);
+		wiphy_err(wl->hw->wiphy, "INTERROGATE command error: %d\n",
+			  acx->cmd.status);
 
 out:
 	return ret;
@@ -194,7 +194,7 @@ int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 
 	ret = wl1251_cmd_send(wl, CMD_VBM, vbm, sizeof(*vbm));
 	if (ret < 0) {
-		wl1251_error("VBM command failed");
+		wiphy_err(wl->hw->wiphy, "VBM command failed\n");
 		goto out;
 	}
 
@@ -226,8 +226,8 @@ int wl1251_cmd_data_path_rx(struct wl1251 *wl, u8 channel, bool enable)
 
 	ret = wl1251_cmd_send(wl, cmd_rx, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("rx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", channel);
+		wiphy_err(wl->hw->wiphy, "rx %s cmd for channel %d failed\n",
+			  enable ? "start" : "stop", channel);
 		goto out;
 	}
 
@@ -260,8 +260,8 @@ int wl1251_cmd_data_path_tx(struct wl1251 *wl, u8 channel, bool enable)
 
 	ret = wl1251_cmd_send(wl, cmd_tx, cmd, sizeof(*cmd));
 	if (ret < 0)
-		wl1251_error("tx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", channel);
+		wiphy_err(wl->hw->wiphy, "tx %s cmd for channel %d failed\n",
+			  enable ? "start" : "stop", channel);
 	else
 		wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d",
 			     enable ? "start" : "stop", channel);
@@ -306,7 +306,7 @@ int wl1251_cmd_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 
 	ret = wl1251_cmd_send(wl, CMD_START_JOIN, join, sizeof(*join));
 	if (ret < 0) {
-		wl1251_error("failed to initiate cmd join");
+		wiphy_err(wl->hw->wiphy, "failed to initiate cmd join\n");
 		goto out;
 	}
 
@@ -337,7 +337,7 @@ int wl1251_cmd_ps_mode(struct wl1251 *wl, u8 ps_mode)
 	ret = wl1251_cmd_send(wl, CMD_SET_PS_MODE, ps_params,
 			      sizeof(*ps_params));
 	if (ret < 0) {
-		wl1251_error("cmd set_ps_mode failed");
+		wiphy_err(wl->hw->wiphy, "cmd set_ps_mode failed\n");
 		goto out;
 	}
 
@@ -368,7 +368,8 @@ int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
 
 	ret = wl1251_cmd_send(wl, CMD_READ_MEMORY, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("read memory command failed: %d", ret);
+		wiphy_err(wl->hw->wiphy, "read memory command failed: %d\n",
+			  ret);
 		goto out;
 	}
 
@@ -376,8 +377,8 @@ int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
 	wl1251_mem_read(wl, wl->cmd_box_addr, cmd, sizeof(*cmd));
 
 	if (cmd->header.status != CMD_STATUS_SUCCESS)
-		wl1251_error("error in read command result: %d",
-			     cmd->header.status);
+		wiphy_err(wl->hw->wiphy, "error in read command result: %d\n",
+			  cmd->header.status);
 
 	memcpy(answer, cmd->value, len);
 
@@ -471,15 +472,15 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
 
 	ret = wl1251_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("cmd scan failed: %d", ret);
+		wiphy_err(wl->hw->wiphy, "cmd scan failed: %d\n", ret);
 		goto out;
 	}
 
 	wl1251_mem_read(wl, wl->cmd_box_addr, cmd, sizeof(*cmd));
 
 	if (cmd->header.status != CMD_STATUS_SUCCESS) {
-		wl1251_error("cmd scan status wasn't success: %d",
-			     cmd->header.status);
+		wiphy_err(wl->hw->wiphy, "cmd scan status wasn't success: %d\n",
+			  cmd->header.status);
 		ret = -EIO;
 		goto out;
 	}
@@ -504,7 +505,8 @@ int wl1251_cmd_trigger_scan_to(struct wl1251 *wl, u32 timeout)
 
 	ret = wl1251_cmd_send(wl, CMD_TRIGGER_SCAN_TO, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("cmd trigger scan to failed: %d", ret);
+		wiphy_err(wl->hw->wiphy, "cmd trigger scan to failed: %d\n",
+			  ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/event.c b/drivers/net/wireless/ti/wl1251/event.c
index c986303..3939734 100644
--- a/drivers/net/wireless/ti/wl1251/event.c
+++ b/drivers/net/wireless/ti/wl1251/event.c
@@ -68,7 +68,7 @@ static int wl1251_event_ps_report(struct wl1251 *wl,
 			wl->psm_entry_retry++;
 			ret = wl1251_ps_set_mode(wl, STATION_POWER_SAVE_MODE);
 		} else {
-			wl1251_error("Power save entry failed, giving up");
+			wiphy_err(wl->hw->wiphy, "Power save entry failed, giving up\n");
 			wl->psm_entry_retry = 0;
 		}
 		break;
diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wireless/ti/wl1251/init.c
index 1d799bf..b1fedb9 100644
--- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -211,7 +211,7 @@ int wl1251_hw_init_mem_config(struct wl1251 *wl)
 	wl->target_mem_map = kzalloc(sizeof(struct wl1251_acx_mem_map),
 					  GFP_KERNEL);
 	if (!wl->target_mem_map) {
-		wl1251_error("couldn't allocate target memory map");
+		wiphy_err(wl->hw->wiphy, "couldn't allocate target memory map\n");
 		return -ENOMEM;
 	}
 
@@ -219,7 +219,7 @@ int wl1251_hw_init_mem_config(struct wl1251 *wl)
 	ret = wl1251_acx_mem_map(wl, wl->target_mem_map,
 				 sizeof(struct wl1251_acx_mem_map));
 	if (ret < 0) {
-		wl1251_error("couldn't retrieve firmware memory map");
+		wiphy_err(wl->hw->wiphy, "couldn't retrieve firmware memory map\n");
 		kfree(wl->target_mem_map);
 		wl->target_mem_map = NULL;
 		return ret;
@@ -228,7 +228,8 @@ int wl1251_hw_init_mem_config(struct wl1251 *wl)
 	return 0;
 }
 
-static int wl1251_hw_init_txq_fill(u8 qid,
+static int wl1251_hw_init_txq_fill(struct wl1251 *wl,
+				   u8 qid,
 				   struct acx_tx_queue_qos_config *config,
 				   u32 num_blocks)
 {
@@ -260,7 +261,7 @@ static int wl1251_hw_init_txq_fill(u8 qid,
 			(QOS_TX_LOW_VO_DEF * num_blocks) / 100;
 		break;
 	default:
-		wl1251_error("Invalid TX queue id: %d", qid);
+		wiphy_err(wl->hw->wiphy, "Invalid TX queue id: %d\n", qid);
 		return -EINVAL;
 	}
 
@@ -282,7 +283,7 @@ static int wl1251_hw_init_tx_queue_config(struct wl1251 *wl)
 	}
 
 	for (i = 0; i < MAX_NUM_OF_AC; i++) {
-		ret = wl1251_hw_init_txq_fill(i, config,
+		ret = wl1251_hw_init_txq_fill(wl, i, config,
 					      wl_mem_map->num_tx_mem_blocks);
 		if (ret < 0)
 			goto out;
@@ -311,7 +312,7 @@ static int wl1251_hw_init_data_path_config(struct wl1251 *wl)
 	wl->data_path = kzalloc(sizeof(struct acx_data_path_params_resp),
 				GFP_KERNEL);
 	if (!wl->data_path) {
-		wl1251_error("Couldnt allocate data path parameters");
+		wiphy_err(wl->hw->wiphy, "Couldnt allocate data path parameters\n");
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/io.c b/drivers/net/wireless/ti/wl1251/io.c
index cdcadbf..36ead14 100644
--- a/drivers/net/wireless/ti/wl1251/io.c
+++ b/drivers/net/wireless/ti/wl1251/io.c
@@ -46,7 +46,8 @@ static int wl1251_translate_reg_addr(struct wl1251 *wl, int addr)
 	if (addr < REGISTERS_BASE) {
 		/* Make sure we don't go over the table */
 		if (addr >= ACX_REG_TABLE_LEN) {
-			wl1251_error("address out of range (%d)", addr);
+			wiphy_err(wl->hw->wiphy, "address out of range (%d)\n",
+				  addr);
 			return -EINVAL;
 		}
 		addr = wl1251_io_reg_table[addr];
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index cd47779..7266d66 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -19,6 +19,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/firmware.h>
@@ -72,13 +74,13 @@ static int wl1251_fetch_firmware(struct wl1251 *wl)
 	ret = request_firmware(&fw, WL1251_FW_NAME, dev);
 
 	if (ret < 0) {
-		wl1251_error("could not get firmware: %d", ret);
+		wiphy_err(wl->hw->wiphy, "could not get firmware: %d\n", ret);
 		return ret;
 	}
 
 	if (fw->size % 4) {
-		wl1251_error("firmware size is not multiple of 32 bits: %zu",
-			     fw->size);
+		wiphy_err(wl->hw->wiphy, "firmware size is not multiple of 32 bits: %zu\n",
+			  fw->size);
 		ret = -EILSEQ;
 		goto out;
 	}
@@ -87,7 +89,7 @@ static int wl1251_fetch_firmware(struct wl1251 *wl)
 	wl->fw = vmalloc(wl->fw_len);
 
 	if (!wl->fw) {
-		wl1251_error("could not allocate memory for the firmware");
+		wiphy_err(wl->hw->wiphy, "could not allocate memory for the firmware\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -111,13 +113,13 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
 	ret = request_firmware(&fw, WL1251_NVS_NAME, dev);
 
 	if (ret < 0) {
-		wl1251_error("could not get nvs file: %d", ret);
+		wiphy_err(wl->hw->wiphy, "could not get nvs file: %d\n", ret);
 		return ret;
 	}
 
 	if (fw->size % 4) {
-		wl1251_error("nvs size is not multiple of 32 bits: %zu",
-			     fw->size);
+		wiphy_err(wl->hw->wiphy, "nvs size is not multiple of 32 bits: %zu\n",
+			  fw->size);
 		ret = -EILSEQ;
 		goto out;
 	}
@@ -126,7 +128,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
 	wl->nvs = kmemdup(fw->data, wl->nvs_len, GFP_KERNEL);
 
 	if (!wl->nvs) {
-		wl1251_error("could not allocate memory for the nvs file");
+		wiphy_err(wl->hw->wiphy, "could not allocate memory for the nvs file\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -191,7 +193,8 @@ static int wl1251_chip_wakeup(struct wl1251 *wl)
 		break;
 	case CHIP_ID_1251_PG10:
 	default:
-		wl1251_error("unsupported chip id: 0x%x", wl->chip_id);
+		wiphy_err(wl->hw->wiphy, "unsupported chip id: 0x%x\n",
+			  wl->chip_id);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -396,8 +399,8 @@ static int wl1251_op_start(struct ieee80211_hw *hw)
 	mutex_lock(&wl->mutex);
 
 	if (wl->state != WL1251_STATE_OFF) {
-		wl1251_error("cannot start because not in off state: %d",
-			     wl->state);
+		wiphy_err(wl->hw->wiphy, "cannot start because not in off state: %d\n",
+			  wl->state);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -743,7 +746,7 @@ static u64 wl1251_op_prepare_multicast(struct ieee80211_hw *hw,
 
 	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
 	if (!fp) {
-		wl1251_error("Out of memory setting filters.");
+		wiphy_err(wl->hw->wiphy, "Out of memory setting filters\n");
 		return 0;
 	}
 
@@ -872,7 +875,8 @@ static int wl1251_set_key_type(struct wl1251 *wl,
 		mac80211_key->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
 		break;
 	default:
-		wl1251_error("Unknown key cipher 0x%x", mac80211_key->cipher);
+		wiphy_err(wl->hw->wiphy, "Unknown key cipher 0x%x\n",
+			  mac80211_key->cipher);
 		return -EOPNOTSUPP;
 	}
 
@@ -928,7 +932,7 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		wl_cmd->key_action = KEY_REMOVE;
 		break;
 	default:
-		wl1251_error("Unsupported key cmd 0x%x", cmd);
+		wiphy_err(wl->hw->wiphy, "Unsupported key cmd 0x%x\n", cmd);
 		break;
 	}
 
@@ -938,7 +942,7 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	ret = wl1251_set_key_type(wl, wl_cmd, cmd, key, addr);
 	if (ret < 0) {
-		wl1251_error("Set KEY type failed");
+		wiphy_err(wl->hw->wiphy, "Set KEY type failed\n");
 		goto out_sleep;
 	}
 
@@ -1454,7 +1458,8 @@ static int wl1251_register_hw(struct wl1251 *wl)
 
 	ret = ieee80211_register_hw(wl->hw);
 	if (ret < 0) {
-		wl1251_error("unable to register mac80211 hw: %d", ret);
+		wiphy_err(wl->hw->wiphy, "unable to register mac80211 hw: %d\n",
+			  ret);
 		return ret;
 	}
 
@@ -1512,7 +1517,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 
 	hw = ieee80211_alloc_hw(sizeof(*wl), &wl1251_ops);
 	if (!hw) {
-		wl1251_error("could not alloc ieee80211_hw");
+		pr_err("could not alloc ieee80211_hw\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -1573,7 +1578,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 
 	wl->rx_descriptor = kmalloc(sizeof(*wl->rx_descriptor), GFP_KERNEL);
 	if (!wl->rx_descriptor) {
-		wl1251_error("could not allocate memory for rx descriptor");
+		wiphy_err(wl->hw->wiphy, "could not allocate memory for rx descriptor\n");
 		ieee80211_free_hw(hw);
 		return ERR_PTR(-ENOMEM);
 	}
diff --git a/drivers/net/wireless/ti/wl1251/ps.c b/drivers/net/wireless/ti/wl1251/ps.c
index b9e27b9..d84762d 100644
--- a/drivers/net/wireless/ti/wl1251/ps.c
+++ b/drivers/net/wireless/ti/wl1251/ps.c
@@ -88,7 +88,7 @@ int wl1251_ps_elp_wakeup(struct wl1251 *wl)
 	 */
 	while (!(elp_reg & ELPCTRL_WLAN_READY)) {
 		if (time_after(jiffies, timeout)) {
-			wl1251_error("elp wakeup timeout");
+			wiphy_err(wl->hw->wiphy, "elp wakeup timeout\n");
 			return -ETIMEDOUT;
 		}
 		msleep(1);
diff --git a/drivers/net/wireless/ti/wl1251/rx.c b/drivers/net/wireless/ti/wl1251/rx.c
index cde0eaf..0176656 100644
--- a/drivers/net/wireless/ti/wl1251/rx.c
+++ b/drivers/net/wireless/ti/wl1251/rx.c
@@ -172,7 +172,7 @@ static void wl1251_rx_body(struct wl1251 *wl,
 
 	skb = __dev_alloc_skb(length, GFP_KERNEL);
 	if (!skb) {
-		wl1251_error("Couldn't allocate RX frame");
+		wiphy_err(wl->hw->wiphy, "Couldn't allocate RX frame\n");
 		return;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index b661f89..f48e985 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -19,6 +19,9 @@
  * Copyright (C) 2008 Google Inc
  * Copyright (C) 2009 Bob Copeland (me@bobcopeland.com)
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/mod_devicetable.h>
@@ -77,7 +80,7 @@ static void wl1251_sdio_read(struct wl1251 *wl, int addr,
 	sdio_claim_host(func);
 	ret = sdio_memcpy_fromio(func, buf, addr, len);
 	if (ret)
-		wl1251_error("sdio read failed (%d)", ret);
+		wiphy_err(wl->hw->wiphy, "sdio read failed (%d)\n", ret);
 	sdio_release_host(func);
 }
 
@@ -90,7 +93,7 @@ static void wl1251_sdio_write(struct wl1251 *wl, int addr,
 	sdio_claim_host(func);
 	ret = sdio_memcpy_toio(func, addr, buf, len);
 	if (ret)
-		wl1251_error("sdio write failed (%d)", ret);
+		wiphy_err(wl->hw->wiphy, "sdio write failed (%d)\n", ret);
 	sdio_release_host(func);
 }
 
@@ -111,7 +114,7 @@ static void wl1251_sdio_read_elp(struct wl1251 *wl, int addr, u32 *val)
 	sdio_release_host(func);
 
 	if (ret)
-		wl1251_error("sdio_readb failed (%d)", ret);
+		wiphy_err(wl->hw->wiphy, "sdio_readb failed (%d)\n", ret);
 }
 
 static void wl1251_sdio_write_elp(struct wl1251 *wl, int addr, u32 val)
@@ -125,7 +128,7 @@ static void wl1251_sdio_write_elp(struct wl1251 *wl, int addr, u32 val)
 	sdio_release_host(func);
 
 	if (ret)
-		wl1251_error("sdio_writeb failed (%d)", ret);
+		wiphy_err(wl->hw->wiphy, "sdio_writeb failed (%d)\n", ret);
 	else
 		wl_sdio->elp_val = val;
 }
@@ -267,7 +270,8 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 		ret = devm_gpio_request(&func->dev, wl->power_gpio,
 								"wl1251 power");
 		if (ret) {
-			wl1251_error("Failed to request gpio: %d\n", ret);
+			wiphy_err(wl->hw->wiphy, "Failed to request gpio: %d\n",
+				  ret);
 			goto disable;
 		}
 	}
@@ -276,7 +280,8 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 		irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 		ret = request_irq(wl->irq, wl1251_line_irq, 0, "wl1251", wl);
 		if (ret < 0) {
-			wl1251_error("request_irq() failed: %d", ret);
+			wiphy_err(wl->hw->wiphy, "request_irq() failed: %d\n",
+				  ret);
 			goto disable;
 		}
 
@@ -370,7 +375,7 @@ static int __init wl1251_sdio_init(void)
 
 	err = sdio_register_driver(&wl1251_sdio_driver);
 	if (err)
-		wl1251_error("failed to register sdio driver: %d", err);
+		pr_err("failed to register sdio driver: %d\n", err);
 	return err;
 }
 
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 8de9d44..d8b7dc8 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -62,7 +62,7 @@ static void wl1251_spi_reset(struct wl1251 *wl)
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
 	if (!cmd) {
-		wl1251_error("could not allocate cmd for spi reset");
+		wiphy_err(wl->hw->wiphy, "could not allocate cmd for spi reset\n");
 		return;
 	}
 
@@ -89,7 +89,7 @@ static void wl1251_spi_wake(struct wl1251 *wl)
 	u8 *cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
 
 	if (!cmd) {
-		wl1251_error("could not allocate cmd for spi init");
+		wiphy_err(wl->hw->wiphy, "could not allocate cmd for spi init\n");
 		return;
 	}
 
@@ -247,7 +247,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 	int ret;
 
 	if (!np && !pdata) {
-		wl1251_error("no platform data");
+		wiphy_err(wl->hw->wiphy, "no platform data\n");
 		return -ENODEV;
 	}
 
@@ -269,7 +269,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 
 	ret = spi_setup(spi);
 	if (ret < 0) {
-		wl1251_error("spi_setup failed");
+		wiphy_err(wl->hw->wiphy, "spi_setup failed\n");
 		goto out_free;
 	}
 
@@ -290,18 +290,19 @@ static int wl1251_spi_probe(struct spi_device *spi)
 		ret = devm_gpio_request_one(&spi->dev, wl->power_gpio,
 					GPIOF_OUT_INIT_LOW, "wl1251 power");
 		if (ret) {
-			wl1251_error("Failed to request gpio: %d\n", ret);
+			wiphy_err(wl->hw->wiphy, "Failed to request gpio: %d\n",
+				  ret);
 			goto out_free;
 		}
 	} else {
-		wl1251_error("set power gpio missing in platform data");
+		wiphy_err(wl->hw->wiphy, "set power gpio missing in platform data\n");
 		ret = -ENODEV;
 		goto out_free;
 	}
 
 	wl->irq = spi->irq;
 	if (wl->irq < 0) {
-		wl1251_error("irq missing in platform data");
+		wiphy_err(wl->hw->wiphy, "irq missing in platform data\n");
 		ret = -ENODEV;
 		goto out_free;
 	}
@@ -310,7 +311,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 	ret = devm_request_irq(&spi->dev, wl->irq, wl1251_irq, 0,
 							DRIVER_NAME, wl);
 	if (ret < 0) {
-		wl1251_error("request_irq() failed: %d", ret);
+		wiphy_err(wl->hw->wiphy, "request_irq() failed: %d\n", ret);
 		goto out_free;
 	}
 
@@ -319,7 +320,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 	wl->vio = devm_regulator_get(&spi->dev, "vio");
 	if (IS_ERR(wl->vio)) {
 		ret = PTR_ERR(wl->vio);
-		wl1251_error("vio regulator missing: %d", ret);
+		wiphy_err(wl->hw->wiphy, "vio regulator missing: %d\n", ret);
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 81de83c..0aa2d54 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -223,7 +223,7 @@ static int wl1251_tx_send_packet(struct wl1251 *wl, struct sk_buff *skb,
 								 GFP_KERNEL);
 
 			if (unlikely(newskb == NULL)) {
-				wl1251_error("Can't allocate skb!");
+				wiphy_err(wl->hw->wiphy, "Can't allocate skb!\n");
 				return -EINVAL;
 			}
 
@@ -419,7 +419,8 @@ static void wl1251_tx_packet_cb(struct wl1251 *wl,
 
 	skb = wl->tx_frames[result->id];
 	if (skb == NULL) {
-		wl1251_error("SKB for packet %d is NULL", result->id);
+		wiphy_err(wl->hw->wiphy, "SKB for packet %d is NULL\n",
+			  result->id);
 		return;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index 16dae52..2fdb194 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -54,9 +54,6 @@ enum {
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1251_error(fmt, arg...) \
-	printk(KERN_ERR DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
-
 #define wl1251_warning(fmt, arg...) \
 	printk(KERN_WARNING DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
 
-- 
2.6.3.368.gf34be46
