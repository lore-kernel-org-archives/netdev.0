From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 2/2] mwifiex: add a cfg80211 .get_antenna operation callback
Date: Mon,  6 Jun 2016 10:59:21 -0400
Message-ID: <1465225161-23492-3-git-send-email-javier@osg.samsung.com>
References: <1465225161-23492-1-git-send-email-javier@osg.samsung.com>
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Enric Balletbo i Serra <enric.balletbo@collabora.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465225161-23492-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit de3bb771f471 ("cfg80211: add more warnings for inconsistent
ops") the wireless core warns if a driver implements a cfg80211 callback
but doesn't implements the inverse operation.

The mwifiex driver defines a .set_antenna handler but not a .get_antenna
so this not only makes the core to print a warning when creating a new
wiphy but also the antenna isn't reported to user-space apps such as iw.

Unfortunately the driver doesn't have support to query the antena to the
firmware and there isn't public documentation about the interface so this
patch caches the values set in .set_antenna and reports those back in get.

With this patch, the wireless core does not warn anymore and the antenna
is properly reported once has been set:

$ iw phy phy0 set antenna 0x1

$ iw phy phy0 info | grep Antennas
        Available Antennas: TX 0x3 RX 0x3
        Configured Antennas: TX 0x1 RX 0x1

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---
Hello,

Even though this approach prevents the warning and allows to reports the
antenna values, it would be better if instead of caching the set values,
these are asked to the firmware for each .get_antenna callback.

But the driver currently only implements a set antenna command and the
firmware interface documentation is not public so isn't clear if the
firmware doesn't support or is just that the driver didn't implement it.

Best regards,
Javier

 drivers/net/wireless/marvell/mwifiex/cfg80211.c | 26 +++++++++++++++++++++++--
 drivers/net/wireless/marvell/mwifiex/main.h     |  1 +
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index b17f3d09a2c7..e9efbc852d23 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -1771,6 +1771,7 @@ mwifiex_cfg80211_set_antenna(struct wiphy *wiphy, u32 tx_ant, u32 rx_ant)
 	struct mwifiex_private *priv = mwifiex_get_priv(adapter,
 							MWIFIEX_BSS_ROLE_ANY);
 	struct mwifiex_ds_ant_cfg ant_cfg;
+	int ret;
 
 	if (!tx_ant || !rx_ant)
 		return -EOPNOTSUPP;
@@ -1823,8 +1824,28 @@ mwifiex_cfg80211_set_antenna(struct wiphy *wiphy, u32 tx_ant, u32 rx_ant)
 	ant_cfg.tx_ant = tx_ant;
 	ant_cfg.rx_ant = rx_ant;
 
-	return mwifiex_send_cmd(priv, HostCmd_CMD_RF_ANTENNA,
-				HostCmd_ACT_GEN_SET, 0, &ant_cfg, true);
+	ret = mwifiex_send_cmd(priv, HostCmd_CMD_RF_ANTENNA,
+			       HostCmd_ACT_GEN_SET, 0, &ant_cfg, true);
+
+	if (ret < 0)
+		return ret;
+
+	priv->ant_cfg.tx_ant = tx_ant;
+	priv->ant_cfg.rx_ant = rx_ant;
+
+	return 0;
+}
+
+static int
+mwifiex_cfg80211_get_antenna(struct wiphy *wiphy, u32 *tx_ant, u32 *rx_ant)
+{
+	struct mwifiex_adapter *adapter = mwifiex_cfg80211_get_adapter(wiphy);
+	struct mwifiex_private *priv = mwifiex_get_priv(adapter,
+							MWIFIEX_BSS_ROLE_ANY);
+	*tx_ant = priv->ant_cfg.tx_ant;
+	*rx_ant = priv->ant_cfg.rx_ant;
+
+	return 0;
 }
 
 /* cfg80211 operation handler for stop ap.
@@ -3970,6 +3991,7 @@ static struct cfg80211_ops mwifiex_cfg80211_ops = {
 	.change_beacon = mwifiex_cfg80211_change_beacon,
 	.set_cqm_rssi_config = mwifiex_cfg80211_set_cqm_rssi_config,
 	.set_antenna = mwifiex_cfg80211_set_antenna,
+	.get_antenna = mwifiex_cfg80211_get_antenna,
 	.del_station = mwifiex_cfg80211_del_station,
 	.sched_scan_start = mwifiex_cfg80211_sched_scan_start,
 	.sched_scan_stop = mwifiex_cfg80211_sched_scan_stop,
diff --git a/drivers/net/wireless/marvell/mwifiex/main.h b/drivers/net/wireless/marvell/mwifiex/main.h
index 0207af00be42..b4fe10cbb34d 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.h
+++ b/drivers/net/wireless/marvell/mwifiex/main.h
@@ -668,6 +668,7 @@ struct mwifiex_private {
 	struct delayed_work dfs_chan_sw_work;
 	struct cfg80211_beacon_data beacon_after;
 	struct mwifiex_11h_intf_state state_11h;
+	struct mwifiex_ds_ant_cfg ant_cfg;
 	struct mwifiex_ds_mem_rw mem_rw;
 	struct sk_buff_head bypass_txq;
 	struct mwifiex_user_scan_chan hidden_chan[MWIFIEX_USER_SCAN_CHAN_MAX];
-- 
2.5.5
