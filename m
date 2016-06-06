From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH v2 3/3] mwifiex: add get_antenna support for cfg80211
Date: Mon,  6 Jun 2016 13:02:38 -0400
Message-ID: <1465232558-31678-4-git-send-email-javier@osg.samsung.com>
References: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Shengzhen Li <szli@marvell.com>,
	Enric Balletbo i Serra <enric.balletbo@collabora.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shengzhen Li <szli@marvell.com>

Since commit de3bb771f471 ("cfg80211: add more warnings for inconsistent
ops") the wireless core warns if a driver implements a cfg80211 callback
but doesn't implements the inverse operation.

The mwifiex driver defines a .set_antenna handler but not a .get_antenna
so this not only makes the core to print a warning when creating a new
wiphy but also the antenna isn't reported to user-space apps such as iw.

This patch queries the antenna to the firmware so is properly reported to
user-space. With this patch, the wireless core does not warn anymore and:

$ iw phy phy0 info | grep Antennas
        Available Antennas: TX 0x3 RX 0x3
        Configured Antennas: TX 0x3 RX 0x3

Signed-off-by: Shengzhen Li <szli@marvell.com>
Signed-off-by: Amitkumar Karwar <akarwar@marvell.com>
[javier: expand the commit message]
Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---

 drivers/net/wireless/marvell/mwifiex/cfg80211.c    | 16 +++++++
 drivers/net/wireless/marvell/mwifiex/fw.h          |  3 ++
 drivers/net/wireless/marvell/mwifiex/init.c        |  2 +
 drivers/net/wireless/marvell/mwifiex/main.h        |  2 +
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     | 50 +++++++++++++++-------
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c | 10 +++--
 6 files changed, 64 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index ff3f63ed95e1..ff1eefe5087b 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -1819,6 +1819,21 @@ mwifiex_cfg80211_set_antenna(struct wiphy *wiphy, u32 tx_ant, u32 rx_ant)
 				HostCmd_ACT_GEN_SET, 0, &ant_cfg, true);
 }
 
+static int
+mwifiex_cfg80211_get_antenna(struct wiphy *wiphy, u32 *tx_ant, u32 *rx_ant)
+{
+	struct mwifiex_adapter *adapter = mwifiex_cfg80211_get_adapter(wiphy);
+	struct mwifiex_private *priv = mwifiex_get_priv(adapter,
+							MWIFIEX_BSS_ROLE_ANY);
+	mwifiex_send_cmd(priv, HostCmd_CMD_RF_ANTENNA,
+			 HostCmd_ACT_GEN_GET, 0, NULL, true);
+
+	*tx_ant = priv->tx_ant;
+	*rx_ant = priv->rx_ant;
+
+	return 0;
+}
+
 /* cfg80211 operation handler for stop ap.
  * Function stops BSS running at uAP interface.
  */
@@ -3962,6 +3977,7 @@ static struct cfg80211_ops mwifiex_cfg80211_ops = {
 	.change_beacon = mwifiex_cfg80211_change_beacon,
 	.set_cqm_rssi_config = mwifiex_cfg80211_set_cqm_rssi_config,
 	.set_antenna = mwifiex_cfg80211_set_antenna,
+	.get_antenna = mwifiex_cfg80211_get_antenna,
 	.del_station = mwifiex_cfg80211_del_station,
 	.sched_scan_start = mwifiex_cfg80211_sched_scan_start,
 	.sched_scan_stop = mwifiex_cfg80211_sched_scan_stop,
diff --git a/drivers/net/wireless/marvell/mwifiex/fw.h b/drivers/net/wireless/marvell/mwifiex/fw.h
index 8e4145abdbfa..cef72343f5b6 100644
--- a/drivers/net/wireless/marvell/mwifiex/fw.h
+++ b/drivers/net/wireless/marvell/mwifiex/fw.h
@@ -462,6 +462,9 @@ enum P2P_MODES {
 #define HostCmd_ACT_SET_RX              0x0001
 #define HostCmd_ACT_SET_TX              0x0002
 #define HostCmd_ACT_SET_BOTH            0x0003
+#define HostCmd_ACT_GET_RX              0x0004
+#define HostCmd_ACT_GET_TX              0x0008
+#define HostCmd_ACT_GET_BOTH            0x000c
 
 #define RF_ANTENNA_AUTO                 0xFFFF
 
diff --git a/drivers/net/wireless/marvell/mwifiex/init.c b/drivers/net/wireless/marvell/mwifiex/init.c
index 78c532f0d286..fbaf49056746 100644
--- a/drivers/net/wireless/marvell/mwifiex/init.c
+++ b/drivers/net/wireless/marvell/mwifiex/init.c
@@ -110,6 +110,8 @@ int mwifiex_init_priv(struct mwifiex_private *priv)
 	priv->tx_power_level = 0;
 	priv->max_tx_power_level = 0;
 	priv->min_tx_power_level = 0;
+	priv->tx_ant = 0;
+	priv->rx_ant = 0;
 	priv->tx_rate = 0;
 	priv->rxpd_htinfo = 0;
 	priv->rxpd_rate = 0;
diff --git a/drivers/net/wireless/marvell/mwifiex/main.h b/drivers/net/wireless/marvell/mwifiex/main.h
index 79c28cfb7780..2ae7ff74e1c6 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.h
+++ b/drivers/net/wireless/marvell/mwifiex/main.h
@@ -533,6 +533,8 @@ struct mwifiex_private {
 	u16 tx_power_level;
 	u8 max_tx_power_level;
 	u8 min_tx_power_level;
+	u32 tx_ant;
+	u32 rx_ant;
 	u8 tx_rate;
 	u8 tx_htinfo;
 	u8 rxpd_htinfo;
diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
index e436574b1698..8c658495bf66 100644
--- a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
@@ -313,23 +313,41 @@ static int mwifiex_cmd_rf_antenna(struct mwifiex_private *priv,
 
 	cmd->command = cpu_to_le16(HostCmd_CMD_RF_ANTENNA);
 
-	if (cmd_action != HostCmd_ACT_GEN_SET)
-		return 0;
-
-	if (priv->adapter->hw_dev_mcs_support == HT_STREAM_2X2) {
-		cmd->size = cpu_to_le16(sizeof(struct host_cmd_ds_rf_ant_mimo) +
-					S_DS_GEN);
-		ant_mimo->action_tx = cpu_to_le16(HostCmd_ACT_SET_TX);
-		ant_mimo->tx_ant_mode = cpu_to_le16((u16)ant_cfg->tx_ant);
-		ant_mimo->action_rx = cpu_to_le16(HostCmd_ACT_SET_RX);
-		ant_mimo->rx_ant_mode = cpu_to_le16((u16)ant_cfg->rx_ant);
-	} else {
-		cmd->size = cpu_to_le16(sizeof(struct host_cmd_ds_rf_ant_siso) +
-					S_DS_GEN);
-		ant_siso->action = cpu_to_le16(HostCmd_ACT_SET_BOTH);
-		ant_siso->ant_mode = cpu_to_le16((u16)ant_cfg->tx_ant);
+	switch (cmd_action) {
+	case HostCmd_ACT_GEN_SET:
+		if (priv->adapter->hw_dev_mcs_support == HT_STREAM_2X2) {
+			cmd->size = cpu_to_le16(sizeof(struct
+						host_cmd_ds_rf_ant_mimo)
+						+ S_DS_GEN);
+			ant_mimo->action_tx = cpu_to_le16(HostCmd_ACT_SET_TX);
+			ant_mimo->tx_ant_mode = cpu_to_le16((u16)ant_cfg->
+							    tx_ant);
+			ant_mimo->action_rx = cpu_to_le16(HostCmd_ACT_SET_RX);
+			ant_mimo->rx_ant_mode = cpu_to_le16((u16)ant_cfg->
+							    rx_ant);
+		} else {
+			cmd->size = cpu_to_le16(sizeof(struct
+						host_cmd_ds_rf_ant_siso) +
+						S_DS_GEN);
+			ant_siso->action = cpu_to_le16(HostCmd_ACT_SET_BOTH);
+			ant_siso->ant_mode = cpu_to_le16((u16)ant_cfg->tx_ant);
+		}
+		break;
+	case HostCmd_ACT_GEN_GET:
+		if (priv->adapter->hw_dev_mcs_support == HT_STREAM_2X2) {
+			cmd->size = cpu_to_le16(sizeof(struct
+						host_cmd_ds_rf_ant_mimo) +
+						S_DS_GEN);
+			ant_mimo->action_tx = cpu_to_le16(HostCmd_ACT_GET_TX);
+			ant_mimo->action_rx = cpu_to_le16(HostCmd_ACT_GET_RX);
+		} else {
+			cmd->size = cpu_to_le16(sizeof(struct
+						host_cmd_ds_rf_ant_siso) +
+						S_DS_GEN);
+			ant_siso->action = cpu_to_le16(HostCmd_ACT_GET_BOTH);
+		}
+		break;
 	}
-
 	return 0;
 }
 
diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
index d18c7979d723..11f19b668e13 100644
--- a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
@@ -469,7 +469,9 @@ static int mwifiex_ret_rf_antenna(struct mwifiex_private *priv,
 	struct host_cmd_ds_rf_ant_siso *ant_siso = &resp->params.ant_siso;
 	struct mwifiex_adapter *adapter = priv->adapter;
 
-	if (adapter->hw_dev_mcs_support == HT_STREAM_2X2)
+	if (adapter->hw_dev_mcs_support == HT_STREAM_2X2) {
+		priv->tx_ant = le16_to_cpu(ant_mimo->tx_ant_mode);
+		priv->rx_ant = le16_to_cpu(ant_mimo->rx_ant_mode);
 		mwifiex_dbg(adapter, INFO,
 			    "RF_ANT_RESP: Tx action = 0x%x, Tx Mode = 0x%04x\t"
 			    "Rx action = 0x%x, Rx Mode = 0x%04x\n",
@@ -477,12 +479,14 @@ static int mwifiex_ret_rf_antenna(struct mwifiex_private *priv,
 			    le16_to_cpu(ant_mimo->tx_ant_mode),
 			    le16_to_cpu(ant_mimo->action_rx),
 			    le16_to_cpu(ant_mimo->rx_ant_mode));
-	else
+	} else {
+		priv->tx_ant = le16_to_cpu(ant_siso->ant_mode);
+		priv->rx_ant = le16_to_cpu(ant_siso->ant_mode);
 		mwifiex_dbg(adapter, INFO,
 			    "RF_ANT_RESP: action = 0x%x, Mode = 0x%04x\n",
 			    le16_to_cpu(ant_siso->action),
 			    le16_to_cpu(ant_siso->ant_mode));
-
+	}
 	return 0;
 }
 
-- 
2.5.5
