From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 06/16] wl1251: split RX and TX data path initialisation
Date: Sat, 26 Oct 2013 22:34:05 +0200
Message-ID: <1382819655-30430-7-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt@davizone.at>

Split up data path initialisation into RX and TX data path initialisation
functions. This change is required for channel switching in monitor mode.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
---
 drivers/net/wireless/ti/wl1251/cmd.c  |   37 ++++++++++++++++++++++++++-------
 drivers/net/wireless/ti/wl1251/cmd.h  |    3 ++-
 drivers/net/wireless/ti/wl1251/init.c |    9 ++++++--
 3 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
index 16b6479..055924c 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -204,11 +204,11 @@ out:
 	return ret;
 }
 
-int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
+int wl1251_cmd_data_path_rx(struct wl1251 *wl, u8 channel, bool enable)
 {
 	struct cmd_enabledisable_path *cmd;
 	int ret;
-	u16 cmd_rx, cmd_tx;
+	u16 cmd_rx;
 
 	wl1251_debug(DEBUG_CMD, "cmd data path");
 
@@ -220,13 +220,10 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
 
 	cmd->channel = channel;
 
-	if (enable) {
+	if (enable)
 		cmd_rx = CMD_ENABLE_RX;
-		cmd_tx = CMD_ENABLE_TX;
-	} else {
+	else
 		cmd_rx = CMD_DISABLE_RX;
-		cmd_tx = CMD_DISABLE_TX;
-	}
 
 	ret = wl1251_cmd_send(wl, cmd_rx, cmd, sizeof(*cmd));
 	if (ret < 0) {
@@ -238,6 +235,32 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
 	wl1251_debug(DEBUG_BOOT, "rx %s cmd channel %d",
 		     enable ? "start" : "stop", channel);
 
+out:
+	kfree(cmd);
+	return ret;
+}
+
+int wl1251_cmd_data_path_tx(struct wl1251 *wl, u8 channel, bool enable)
+{
+	struct cmd_enabledisable_path *cmd;
+	int ret;
+	u16 cmd_tx;
+
+	wl1251_debug(DEBUG_CMD, "cmd data path");
+
+	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
+	if (!cmd) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	cmd->channel = channel;
+
+	if (enable)
+		cmd_tx = CMD_ENABLE_TX;
+	else
+		cmd_tx = CMD_DISABLE_TX;
+
 	ret = wl1251_cmd_send(wl, cmd_tx, cmd, sizeof(*cmd));
 	if (ret < 0) {
 		wl1251_error("tx %s cmd for channel %d failed",
diff --git a/drivers/net/wireless/ti/wl1251/cmd.h b/drivers/net/wireless/ti/wl1251/cmd.h
index 126f273..d824ff9 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.h
+++ b/drivers/net/wireless/ti/wl1251/cmd.h
@@ -35,7 +35,8 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len);
 int wl1251_cmd_configure(struct wl1251 *wl, u16 id, void *buf, size_t len);
 int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 		   void *bitmap, u16 bitmap_len, u8 bitmap_control);
-int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable);
+int wl1251_cmd_data_path_rx(struct wl1251 *wl, u8 channel, bool enable);
+int wl1251_cmd_data_path_tx(struct wl1251 *wl, u8 channel, bool enable);
 int wl1251_cmd_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 		    u16 beacon_interval, u8 dtim_interval);
 int wl1251_cmd_ps_mode(struct wl1251 *wl, u8 ps_mode);
diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wireless/ti/wl1251/init.c
index a6ad223..424ce01 100644
--- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -390,8 +390,13 @@ int wl1251_hw_init(struct wl1251 *wl)
 	if (ret < 0)
 		goto out_free_data_path;
 
-	/* Enable data path */
-	ret = wl1251_cmd_data_path(wl, wl->channel, 1);
+	/* Enable rx data path */
+	ret = wl1251_cmd_data_path_rx(wl, wl->channel, 1);
+	if (ret < 0)
+		goto out_free_data_path;
+
+	/* Enable tx data path */
+	ret = wl1251_cmd_data_path_tx(wl, wl->channel, 1);
 	if (ret < 0)
 		goto out_free_data_path;
 
-- 
1.7.10.4
