From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-03-06
Date: Wed, 6 Mar 2013 14:29:14 -0500
Message-ID: <20130306192912.GA17452@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/dobhs11T7y2rNN"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This time just passing along a big batch of fixes from Johannes...

For the mac80211 bits:

"Here I have fixes from Ben Greear for stray work items when deleting
interfaces, another idle handling fix from Felix, a fix from Marco ro a
mesh PS buffering crash and I have a fix for the VHT MCS calculation in
association request frames and more nl80211 feature advertising removal
as well as a workaround to increase the dump size if the SKB overhead is
too large. For 3.10 I already have a complete fix queued, but that also
requires (simple) userspace changes."

And for the iwlwifi bits:

"The patches from Dor fix a bunch of calibration issues in the new MVM
driver, and Emmanuel has a number of fixes there as well. Also, we
decided to disable 8k A-MSDU by default, so that's in there. My own
patches are addressing an issue we found with the new devices but that
seems to also exist on older ones, the DMA writeback the devices do can
be delayed and cause issues. The fix is unfortunately relatively large
and depends on two other changes (to not be hugely conflicting), but I
think it's still worth it at this point."

As Johannes says, it is a bit large.  But I hope it is still early
enough in the cycle to make that worthwhile.

Please let me know if there are problems!

John

---

The following changes since commit 66d29cbc59433ba538922a9e958495156b31b83b:

  benet: Wait f/w POST until timeout (2013-03-06 02:47:06 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 32cdd592b723fc88ecca699e550197cd48bb4ad6:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-03-06 10:21:17 -0500)

----------------------------------------------------------------

Ben Greear (2):
      mac80211: stop timers before canceling work items
      mac80211: Fix crash due to un-canceled work-items

Dor Shaish (3):
      iwlwifi: mvm: Set valid TX antennas value before calib request
      iwlwifi: mvm: Take the phy_cfg from the TLV value
      iwlwifi: mvm: Remove overriding calibrations for the 7000 family

Emmanuel Grumbach (5):
      iwlwifi: disable 8K A-MSDU by default
      iwlwifi: mvm: restart the NIC of the cmd queue gets full
      iwlwifi: mvm: ignore STOP_AGG when restarting
      iwlwifi: mvm: update the rssi calculation
      iwlwifi: mvm: don't warn on normal BAR sending

Felix Fietkau (1):
      mac80211: another fix for idle handling in monitor mode

Johannes Berg (7):
      nl80211: remove channel width and extended capa advertising
      mac80211: really fix monitor mode channel reporting
      iwlwifi: don't map complete commands bidirectionally
      iwlwifi: rename IWL_MAX_CMD_TFDS to IWL_MAX_CMD_TBS_PER_TFD
      iwlwifi: use coherent DMA memory for command header
      nl80211: increase wiphy dump size dynamically
      mac80211: fix VHT MCS calculation

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Marco Porsch (1):
      mac80211: fix oops on mesh PS broadcast forwarding

 drivers/net/wireless/iwlwifi/dvm/sta.c       |   2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |   2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c       |   3 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h |   2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h     |  20 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h    |  18 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c        | 133 +-------------
 drivers/net/wireless/iwlwifi/mvm/mvm.h       |   3 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c       |  18 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c        |  37 ++--
 drivers/net/wireless/iwlwifi/mvm/sta.c       |  10 +
 drivers/net/wireless/iwlwifi/mvm/tx.c        |   6 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h |  34 +++-
 drivers/net/wireless/iwlwifi/pcie/rx.c       |  14 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c       | 266 +++++++++++++----------=
----
 net/mac80211/cfg.c                           |  21 ++-
 net/mac80211/iface.c                         |   6 +
 net/mac80211/mlme.c                          |  28 ++-
 net/mac80211/tx.c                            |   3 +-
 net/wireless/core.c                          |   3 +-
 net/wireless/nl80211.c                       |  51 +++--
 21 files changed, 299 insertions(+), 381 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/sta.c b/drivers/net/wireless/=
iwlwifi/dvm/sta.c
index 94ef338..b775769 100644
--- a/drivers/net/wireless/iwlwifi/dvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/dvm/sta.c
@@ -151,7 +151,7 @@ int iwl_send_add_sta(struct iwl_priv *priv,
 		       sta_id, sta->sta.addr, flags & CMD_ASYNC ?  "a" : "");
=20
 	if (!(flags & CMD_ASYNC)) {
-		cmd.flags |=3D CMD_WANT_SKB | CMD_WANT_HCMD;
+		cmd.flags |=3D CMD_WANT_SKB;
 		might_sleep();
 	}
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.h b/drivers/net/wire=
less/iwlwifi/iwl-devtrace.h
index 10f0179..81aa91f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace.h
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
@@ -363,7 +363,7 @@ TRACE_EVENT(iwlwifi_dev_hcmd,
 		__entry->flags =3D cmd->flags;
 		memcpy(__get_dynamic_array(hcmd), hdr, sizeof(*hdr));
=20
-		for (i =3D 0; i < IWL_MAX_CMD_TFDS; i++) {
+		for (i =3D 0; i < IWL_MAX_CMD_TBS_PER_TFD; i++) {
 			if (!cmd->len[i])
 				continue;
 			memcpy((u8 *)__get_dynamic_array(hcmd) + offset,
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/=
iwlwifi/iwl-drv.c
index 6f228bb..fbfd2d1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/iwlwifi/iwl-drv.c
@@ -1102,7 +1102,6 @@ void iwl_drv_stop(struct iwl_drv *drv)
=20
 /* shared module parameters */
 struct iwl_mod_params iwlwifi_mod_params =3D {
-	.amsdu_size_8K =3D 1,
 	.restart_fw =3D 1,
 	.plcp_check =3D true,
 	.bt_coex_active =3D true,
@@ -1207,7 +1206,7 @@ MODULE_PARM_DESC(11n_disable,
 	"disable 11n functionality, bitmap: 1: full, 2: agg TX, 4: agg RX");
 module_param_named(amsdu_size_8K, iwlwifi_mod_params.amsdu_size_8K,
 		   int, S_IRUGO);
-MODULE_PARM_DESC(amsdu_size_8K, "enable 8K amsdu size");
+MODULE_PARM_DESC(amsdu_size_8K, "enable 8K amsdu size (default 0)");
 module_param_named(fw_restart, iwlwifi_mod_params.restart_fw, int, S_IRUGO=
);
 MODULE_PARM_DESC(fw_restart, "restart firmware in case of error");
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-modparams.h b/drivers/net/wir=
eless/iwlwifi/iwl-modparams.h
index e5e3a79..2c2a729 100644
--- a/drivers/net/wireless/iwlwifi/iwl-modparams.h
+++ b/drivers/net/wireless/iwlwifi/iwl-modparams.h
@@ -91,7 +91,7 @@ enum iwl_power_level {
  * @sw_crypto: using hardware encryption, default =3D 0
  * @disable_11n: disable 11n capabilities, default =3D 0,
  *	use IWL_DISABLE_HT_* constants
- * @amsdu_size_8K: enable 8K amsdu size, default =3D 1
+ * @amsdu_size_8K: enable 8K amsdu size, default =3D 0
  * @restart_fw: restart firmware, default =3D 1
  * @plcp_check: enable plcp health check, default =3D true
  * @wd_disable: enable stuck queue check, default =3D 0
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireles=
s/iwlwifi/iwl-trans.h
index 8c7bec6..0cac2b7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@ -186,19 +186,13 @@ struct iwl_rx_packet {
  * @CMD_ASYNC: Return right away and don't want for the response
  * @CMD_WANT_SKB: valid only with CMD_SYNC. The caller needs the buffer of=
 the
  *	response. The caller needs to call iwl_free_resp when done.
- * @CMD_WANT_HCMD: The caller needs to get the HCMD that was sent in the
- *	response handler. Chunks flagged by %IWL_HCMD_DFL_NOCOPY won't be
- *	copied. The pointer passed to the response handler is in the transport
- *	ownership and don't need to be freed by the op_mode. This also means
- *	that the pointer is invalidated after the op_mode's handler returns.
  * @CMD_ON_DEMAND: This command is sent by the test mode pipe.
  */
 enum CMD_MODE {
 	CMD_SYNC		=3D 0,
 	CMD_ASYNC		=3D BIT(0),
 	CMD_WANT_SKB		=3D BIT(1),
-	CMD_WANT_HCMD		=3D BIT(2),
-	CMD_ON_DEMAND		=3D BIT(3),
+	CMD_ON_DEMAND		=3D BIT(2),
 };
=20
 #define DEF_CMD_PAYLOAD_SIZE 320
@@ -217,7 +211,11 @@ struct iwl_device_cmd {
=20
 #define TFD_MAX_PAYLOAD_SIZE (sizeof(struct iwl_device_cmd))
=20
-#define IWL_MAX_CMD_TFDS	2
+/*
+ * number of transfer buffers (fragments) per transmit frame descriptor;
+ * this is just the driver's idea, the hardware supports 20
+ */
+#define IWL_MAX_CMD_TBS_PER_TFD	2
=20
 /**
  * struct iwl_hcmd_dataflag - flag for each one of the chunks of the comma=
nd
@@ -254,15 +252,15 @@ enum iwl_hcmd_dataflag {
  * @id: id of the host command
  */
 struct iwl_host_cmd {
-	const void *data[IWL_MAX_CMD_TFDS];
+	const void *data[IWL_MAX_CMD_TBS_PER_TFD];
 	struct iwl_rx_packet *resp_pkt;
 	unsigned long _rx_page_addr;
 	u32 _rx_page_order;
 	int handler_status;
=20
 	u32 flags;
-	u16 len[IWL_MAX_CMD_TFDS];
-	u8 dataflags[IWL_MAX_CMD_TFDS];
+	u16 len[IWL_MAX_CMD_TBS_PER_TFD];
+	u8 dataflags[IWL_MAX_CMD_TBS_PER_TFD];
 	u8 id;
 };
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api.h b/drivers/net/wirele=
ss/iwlwifi/mvm/fw-api.h
index 23eebda..2adb61f 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api.h
@@ -762,18 +762,20 @@ struct iwl_phy_context_cmd {
 #define IWL_RX_INFO_PHY_CNT 8
 #define IWL_RX_INFO_AGC_IDX 1
 #define IWL_RX_INFO_RSSI_AB_IDX 2
-#define IWL_RX_INFO_RSSI_C_IDX 3
-#define IWL_OFDM_AGC_DB_MSK 0xfe00
-#define IWL_OFDM_AGC_DB_POS 9
+#define IWL_OFDM_AGC_A_MSK 0x0000007f
+#define IWL_OFDM_AGC_A_POS 0
+#define IWL_OFDM_AGC_B_MSK 0x00003f80
+#define IWL_OFDM_AGC_B_POS 7
+#define IWL_OFDM_AGC_CODE_MSK 0x3fe00000
+#define IWL_OFDM_AGC_CODE_POS 20
 #define IWL_OFDM_RSSI_INBAND_A_MSK 0x00ff
-#define IWL_OFDM_RSSI_ALLBAND_A_MSK 0xff00
 #define IWL_OFDM_RSSI_A_POS 0
+#define IWL_OFDM_RSSI_ALLBAND_A_MSK 0xff00
+#define IWL_OFDM_RSSI_ALLBAND_A_POS 8
 #define IWL_OFDM_RSSI_INBAND_B_MSK 0xff0000
-#define IWL_OFDM_RSSI_ALLBAND_B_MSK 0xff000000
 #define IWL_OFDM_RSSI_B_POS 16
-#define IWL_OFDM_RSSI_INBAND_C_MSK 0x00ff
-#define IWL_OFDM_RSSI_ALLBAND_C_MSK 0xff00
-#define IWL_OFDM_RSSI_C_POS 0
+#define IWL_OFDM_RSSI_ALLBAND_B_MSK 0xff000000
+#define IWL_OFDM_RSSI_ALLBAND_B_POS 24
=20
 /**
  * struct iwl_rx_phy_info - phy info
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw.c b/drivers/net/wireless/i=
wlwifi/mvm/fw.c
index d3d959d..500f818 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/iwlwifi/mvm/fw.c
@@ -79,17 +79,8 @@
 #define UCODE_VALID_OK	cpu_to_le32(0x1)
=20
 /* Default calibration values for WkP - set to INIT image w/o running */
-static const u8 wkp_calib_values_bb_filter[] =3D { 0xbf, 0x00, 0x5f, 0x00,=
 0x2f,
-						 0x00, 0x18, 0x00 };
-static const u8 wkp_calib_values_rx_dc[] =3D { 0x7f, 0x7f, 0x7f, 0x7f, 0x7=
f,
-					     0x7f, 0x7f, 0x7f };
-static const u8 wkp_calib_values_tx_lo[] =3D { 0x00, 0x00, 0x00, 0x00 };
-static const u8 wkp_calib_values_tx_iq[] =3D { 0xff, 0x00, 0xff, 0x00, 0x0=
0,
-					     0x00 };
-static const u8 wkp_calib_values_rx_iq[] =3D { 0xff, 0x00, 0x00, 0x00 };
 static const u8 wkp_calib_values_rx_iq_skew[] =3D { 0x00, 0x00, 0x01, 0x00=
 };
 static const u8 wkp_calib_values_tx_iq_skew[] =3D { 0x01, 0x00, 0x00, 0x00=
 };
-static const u8 wkp_calib_values_xtal[] =3D { 0xd2, 0xd2 };
=20
 struct iwl_calib_default_data {
 	u16 size;
@@ -99,12 +90,7 @@ struct iwl_calib_default_data {
 #define CALIB_SIZE_N_DATA(_buf) {.size =3D sizeof(_buf), .data =3D &_buf}
=20
 static const struct iwl_calib_default_data wkp_calib_default_data[12] =3D {
-	[5] =3D CALIB_SIZE_N_DATA(wkp_calib_values_rx_dc),
-	[6] =3D CALIB_SIZE_N_DATA(wkp_calib_values_bb_filter),
-	[7] =3D CALIB_SIZE_N_DATA(wkp_calib_values_tx_lo),
-	[8] =3D CALIB_SIZE_N_DATA(wkp_calib_values_tx_iq),
 	[9] =3D CALIB_SIZE_N_DATA(wkp_calib_values_tx_iq_skew),
-	[10] =3D CALIB_SIZE_N_DATA(wkp_calib_values_rx_iq),
 	[11] =3D CALIB_SIZE_N_DATA(wkp_calib_values_rx_iq_skew),
 };
=20
@@ -241,20 +227,6 @@ static int iwl_mvm_load_ucode_wait_alive(struct iwl_mv=
m *mvm,
=20
 	return 0;
 }
-#define IWL_HW_REV_ID_RAINBOW	0x2
-#define IWL_PROJ_TYPE_LHP	0x5
-
-static u32 iwl_mvm_build_phy_cfg(struct iwl_mvm *mvm)
-{
-	struct iwl_nvm_data *data =3D mvm->nvm_data;
-	/* Temp calls to static definitions, will be changed to CSR calls */
-	u8 hw_rev_id =3D IWL_HW_REV_ID_RAINBOW;
-	u8 project_type =3D IWL_PROJ_TYPE_LHP;
-
-	return data->radio_cfg_dash | (data->radio_cfg_step << 2) |
-		(hw_rev_id << 4) | ((project_type & 0x7f) << 6) |
-		(data->valid_tx_ant << 16) | (data->valid_rx_ant << 20);
-}
=20
 static int iwl_send_phy_cfg_cmd(struct iwl_mvm *mvm)
 {
@@ -262,7 +234,7 @@ static int iwl_send_phy_cfg_cmd(struct iwl_mvm *mvm)
 	enum iwl_ucode_type ucode_type =3D mvm->cur_ucode;
=20
 	/* Set parameters */
-	phy_cfg_cmd.phy_cfg =3D cpu_to_le32(iwl_mvm_build_phy_cfg(mvm));
+	phy_cfg_cmd.phy_cfg =3D cpu_to_le32(mvm->fw->phy_config);
 	phy_cfg_cmd.calib_control.event_trigger =3D
 		mvm->fw->default_calib[ucode_type].event_trigger;
 	phy_cfg_cmd.calib_control.flow_trigger =3D
@@ -275,103 +247,6 @@ static int iwl_send_phy_cfg_cmd(struct iwl_mvm *mvm)
 				    sizeof(phy_cfg_cmd), &phy_cfg_cmd);
 }
=20
-/* Starting with the new PHY DB implementation - New calibs are enabled */
-/* Value - 0x405e7 */
-#define IWL_CALIB_DEFAULT_FLOW_INIT	(IWL_CALIB_CFG_XTAL_IDX		|\
-					 IWL_CALIB_CFG_TEMPERATURE_IDX	|\
-					 IWL_CALIB_CFG_VOLTAGE_READ_IDX	|\
-					 IWL_CALIB_CFG_DC_IDX		|\
-					 IWL_CALIB_CFG_BB_FILTER_IDX	|\
-					 IWL_CALIB_CFG_LO_LEAKAGE_IDX	|\
-					 IWL_CALIB_CFG_TX_IQ_IDX	|\
-					 IWL_CALIB_CFG_RX_IQ_IDX	|\
-					 IWL_CALIB_CFG_AGC_IDX)
-
-#define IWL_CALIB_DEFAULT_EVENT_INIT	0x0
-
-/* Value 0x41567 */
-#define IWL_CALIB_DEFAULT_FLOW_RUN	(IWL_CALIB_CFG_XTAL_IDX		|\
-					 IWL_CALIB_CFG_TEMPERATURE_IDX	|\
-					 IWL_CALIB_CFG_VOLTAGE_READ_IDX	|\
-					 IWL_CALIB_CFG_BB_FILTER_IDX	|\
-					 IWL_CALIB_CFG_DC_IDX		|\
-					 IWL_CALIB_CFG_TX_IQ_IDX	|\
-					 IWL_CALIB_CFG_RX_IQ_IDX	|\
-					 IWL_CALIB_CFG_SENSITIVITY_IDX	|\
-					 IWL_CALIB_CFG_AGC_IDX)
-
-#define IWL_CALIB_DEFAULT_EVENT_RUN	(IWL_CALIB_CFG_XTAL_IDX		|\
-					 IWL_CALIB_CFG_TEMPERATURE_IDX	|\
-					 IWL_CALIB_CFG_VOLTAGE_READ_IDX	|\
-					 IWL_CALIB_CFG_TX_PWR_IDX	|\
-					 IWL_CALIB_CFG_DC_IDX		|\
-					 IWL_CALIB_CFG_TX_IQ_IDX	|\
-					 IWL_CALIB_CFG_SENSITIVITY_IDX)
-
-/*
- * Sets the calibrations trigger values that will be sent to the FW for ru=
ntime
- * and init calibrations.
- * The ones given in the FW TLV are not correct.
- */
-static void iwl_set_default_calib_trigger(struct iwl_mvm *mvm)
-{
-	struct iwl_tlv_calib_ctrl default_calib;
-
-	/*
-	 * WkP FW TLV calib bits are wrong, overwrite them.
-	 * This defines the dynamic calibrations which are implemented in the
-	 * uCode both for init(flow) calculation and event driven calibs.
-	 */
-
-	/* Init Image */
-	default_calib.event_trigger =3D cpu_to_le32(IWL_CALIB_DEFAULT_EVENT_INIT);
-	default_calib.flow_trigger =3D cpu_to_le32(IWL_CALIB_DEFAULT_FLOW_INIT);
-
-	if (default_calib.event_trigger !=3D
-	    mvm->fw->default_calib[IWL_UCODE_INIT].event_trigger)
-		IWL_ERR(mvm,
-			"Updating the event calib for INIT image: 0x%x -> 0x%x\n",
-			mvm->fw->default_calib[IWL_UCODE_INIT].event_trigger,
-			default_calib.event_trigger);
-	if (default_calib.flow_trigger !=3D
-	    mvm->fw->default_calib[IWL_UCODE_INIT].flow_trigger)
-		IWL_ERR(mvm,
-			"Updating the flow calib for INIT image: 0x%x -> 0x%x\n",
-			mvm->fw->default_calib[IWL_UCODE_INIT].flow_trigger,
-			default_calib.flow_trigger);
-
-	memcpy((void *)&mvm->fw->default_calib[IWL_UCODE_INIT],
-	       &default_calib, sizeof(struct iwl_tlv_calib_ctrl));
-	IWL_ERR(mvm,
-		"Setting uCode init calibrations event 0x%x, trigger 0x%x\n",
-		default_calib.event_trigger,
-		default_calib.flow_trigger);
-
-	/* Run time image */
-	default_calib.event_trigger =3D cpu_to_le32(IWL_CALIB_DEFAULT_EVENT_RUN);
-	default_calib.flow_trigger =3D cpu_to_le32(IWL_CALIB_DEFAULT_FLOW_RUN);
-
-	if (default_calib.event_trigger !=3D
-	    mvm->fw->default_calib[IWL_UCODE_REGULAR].event_trigger)
-		IWL_ERR(mvm,
-			"Updating the event calib for RT image: 0x%x -> 0x%x\n",
-			mvm->fw->default_calib[IWL_UCODE_REGULAR].event_trigger,
-			default_calib.event_trigger);
-	if (default_calib.flow_trigger !=3D
-	    mvm->fw->default_calib[IWL_UCODE_REGULAR].flow_trigger)
-		IWL_ERR(mvm,
-			"Updating the flow calib for RT image: 0x%x -> 0x%x\n",
-			mvm->fw->default_calib[IWL_UCODE_REGULAR].flow_trigger,
-			default_calib.flow_trigger);
-
-	memcpy((void *)&mvm->fw->default_calib[IWL_UCODE_REGULAR],
-	       &default_calib, sizeof(struct iwl_tlv_calib_ctrl));
-	IWL_ERR(mvm,
-		"Setting uCode runtime calibs event 0x%x, trigger 0x%x\n",
-		default_calib.event_trigger,
-		default_calib.flow_trigger);
-}
-
 static int iwl_set_default_calibrations(struct iwl_mvm *mvm)
 {
 	u8 cmd_raw[16]; /* holds the variable size commands */
@@ -446,8 +321,10 @@ int iwl_run_init_mvm_ucode(struct iwl_mvm *mvm, bool r=
ead_nvm)
 	ret =3D iwl_nvm_check_version(mvm->nvm_data, mvm->trans);
 	WARN_ON(ret);
=20
-	/* Override the calibrations from TLV and the const of fw */
-	iwl_set_default_calib_trigger(mvm);
+	/* Send TX valid antennas before triggering calibrations */
+	ret =3D iwl_send_tx_ant_cfg(mvm, mvm->nvm_data->valid_tx_ant);
+	if (ret)
+		goto error;
=20
 	/* WkP doesn't have all calibrations, need to set default values */
 	if (mvm->cfg->device_family =3D=3D IWL_DEVICE_FAMILY_7000) {
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/=
iwlwifi/mvm/mvm.h
index 537711b..bdae700 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -80,7 +80,8 @@
=20
 #define IWL_INVALID_MAC80211_QUEUE	0xff
 #define IWL_MVM_MAX_ADDRESSES		2
-#define IWL_RSSI_OFFSET 44
+/* RSSI offset for WkP */
+#define IWL_RSSI_OFFSET 50
=20
 enum iwl_mvm_tx_fifo {
 	IWL_MVM_TX_FIFO_BK =3D 0,
diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c b/drivers/net/wireless/=
iwlwifi/mvm/ops.c
index aa59adf..d0f9c1e 100644
--- a/drivers/net/wireless/iwlwifi/mvm/ops.c
+++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
@@ -624,12 +624,8 @@ static void iwl_mvm_free_skb(struct iwl_op_mode *op_mo=
de, struct sk_buff *skb)
 	ieee80211_free_txskb(mvm->hw, skb);
 }
=20
-static void iwl_mvm_nic_error(struct iwl_op_mode *op_mode)
+static void iwl_mvm_nic_restart(struct iwl_mvm *mvm)
 {
-	struct iwl_mvm *mvm =3D IWL_OP_MODE_GET_MVM(op_mode);
-
-	iwl_mvm_dump_nic_error_log(mvm);
-
 	iwl_abort_notification_waits(&mvm->notif_wait);
=20
 	/*
@@ -663,9 +659,21 @@ static void iwl_mvm_nic_error(struct iwl_op_mode *op_m=
ode)
 	}
 }
=20
+static void iwl_mvm_nic_error(struct iwl_op_mode *op_mode)
+{
+	struct iwl_mvm *mvm =3D IWL_OP_MODE_GET_MVM(op_mode);
+
+	iwl_mvm_dump_nic_error_log(mvm);
+
+	iwl_mvm_nic_restart(mvm);
+}
+
 static void iwl_mvm_cmd_queue_full(struct iwl_op_mode *op_mode)
 {
+	struct iwl_mvm *mvm =3D IWL_OP_MODE_GET_MVM(op_mode);
+
 	WARN_ON(1);
+	iwl_mvm_nic_restart(mvm);
 }
=20
 static const struct iwl_op_mode_ops iwl_mvm_ops =3D {
diff --git a/drivers/net/wireless/iwlwifi/mvm/rx.c b/drivers/net/wireless/i=
wlwifi/mvm/rx.c
index 3f40ab0..b0b190d 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rx.c
@@ -131,33 +131,42 @@ static void iwl_mvm_pass_packet_to_mac80211(struct iw=
l_mvm *mvm,
 static int iwl_mvm_calc_rssi(struct iwl_mvm *mvm,
 			     struct iwl_rx_phy_info *phy_info)
 {
-	u32 rssi_a, rssi_b, rssi_c, max_rssi, agc_db;
+	int rssi_a, rssi_b, rssi_a_dbm, rssi_b_dbm, max_rssi_dbm;
+	int rssi_all_band_a, rssi_all_band_b;
+	u32 agc_a, agc_b, max_agc;
 	u32 val;
=20
-	/* Find max rssi among 3 possible receivers.
+	/* Find max rssi among 2 possible receivers.
 	 * These values are measured by the Digital Signal Processor (DSP).
 	 * They should stay fairly constant even as the signal strength varies,
 	 * if the radio's Automatic Gain Control (AGC) is working right.
 	 * AGC value (see below) will provide the "interesting" info.
 	 */
+	val =3D le32_to_cpu(phy_info->non_cfg_phy[IWL_RX_INFO_AGC_IDX]);
+	agc_a =3D (val & IWL_OFDM_AGC_A_MSK) >> IWL_OFDM_AGC_A_POS;
+	agc_b =3D (val & IWL_OFDM_AGC_B_MSK) >> IWL_OFDM_AGC_B_POS;
+	max_agc =3D max_t(u32, agc_a, agc_b);
+
 	val =3D le32_to_cpu(phy_info->non_cfg_phy[IWL_RX_INFO_RSSI_AB_IDX]);
 	rssi_a =3D (val & IWL_OFDM_RSSI_INBAND_A_MSK) >> IWL_OFDM_RSSI_A_POS;
 	rssi_b =3D (val & IWL_OFDM_RSSI_INBAND_B_MSK) >> IWL_OFDM_RSSI_B_POS;
-	val =3D le32_to_cpu(phy_info->non_cfg_phy[IWL_RX_INFO_RSSI_C_IDX]);
-	rssi_c =3D (val & IWL_OFDM_RSSI_INBAND_C_MSK) >> IWL_OFDM_RSSI_C_POS;
-
-	val =3D le32_to_cpu(phy_info->non_cfg_phy[IWL_RX_INFO_AGC_IDX]);
-	agc_db =3D (val & IWL_OFDM_AGC_DB_MSK) >> IWL_OFDM_AGC_DB_POS;
+	rssi_all_band_a =3D (val & IWL_OFDM_RSSI_ALLBAND_A_MSK) >>
+				IWL_OFDM_RSSI_ALLBAND_A_POS;
+	rssi_all_band_b =3D (val & IWL_OFDM_RSSI_ALLBAND_B_MSK) >>
+				IWL_OFDM_RSSI_ALLBAND_B_POS;
=20
-	max_rssi =3D max_t(u32, rssi_a, rssi_b);
-	max_rssi =3D max_t(u32, max_rssi, rssi_c);
+	/*
+	 * dBm =3D rssi dB - agc dB - constant.
+	 * Higher AGC (higher radio gain) means lower signal.
+	 */
+	rssi_a_dbm =3D rssi_a - IWL_RSSI_OFFSET - agc_a;
+	rssi_b_dbm =3D rssi_b - IWL_RSSI_OFFSET - agc_b;
+	max_rssi_dbm =3D max_t(int, rssi_a_dbm, rssi_b_dbm);
=20
-	IWL_DEBUG_STATS(mvm, "Rssi In A %d B %d C %d Max %d AGC dB %d\n",
-			rssi_a, rssi_b, rssi_c, max_rssi, agc_db);
+	IWL_DEBUG_STATS(mvm, "Rssi In A %d B %d Max %d AGCA %d AGCB %d\n",
+			rssi_a_dbm, rssi_b_dbm, max_rssi_dbm, agc_a, agc_b);
=20
-	/* dBm =3D max_rssi dB - agc dB - constant.
-	 * Higher AGC (higher radio gain) means lower signal. */
-	return max_rssi - agc_db - IWL_RSSI_OFFSET;
+	return max_rssi_dbm;
 }
=20
 /*
diff --git a/drivers/net/wireless/iwlwifi/mvm/sta.c b/drivers/net/wireless/=
iwlwifi/mvm/sta.c
index 861a7f9..274f44e 100644
--- a/drivers/net/wireless/iwlwifi/mvm/sta.c
+++ b/drivers/net/wireless/iwlwifi/mvm/sta.c
@@ -770,6 +770,16 @@ int iwl_mvm_sta_tx_agg_stop(struct iwl_mvm *mvm, struc=
t ieee80211_vif *vif,
 	u16 txq_id;
 	int err;
=20
+
+	/*
+	 * If mac80211 is cleaning its state, then say that we finished since
+	 * our state has been cleared anyway.
+	 */
+	if (test_bit(IWL_MVM_STATUS_IN_HW_RESTART, &mvm->status)) {
+		ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
+		return 0;
+	}
+
 	spin_lock_bh(&mvmsta->lock);
=20
 	txq_id =3D tid_data->txq_id;
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index 6b67ce3..6645efe 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -607,12 +607,8 @@ static void iwl_mvm_rx_tx_cmd_single(struct iwl_mvm *m=
vm,
=20
 		/* Single frame failure in an AMPDU queue =3D> send BAR */
 		if (txq_id >=3D IWL_FIRST_AMPDU_QUEUE &&
-		    !(info->flags & IEEE80211_TX_STAT_ACK)) {
-			/* there must be only one skb in the skb_list */
-			WARN_ON_ONCE(skb_freed > 1 ||
-				     !skb_queue_empty(&skbs));
+		    !(info->flags & IEEE80211_TX_STAT_ACK))
 			info->flags |=3D IEEE80211_TX_STAT_AMPDU_NO_BACK;
-		}
=20
 		/* W/A FW bug: seq_ctl is wrong when the queue is flushed */
 		if (status =3D=3D TX_STATUS_FAIL_FIFO_FLUSHED) {
diff --git a/drivers/net/wireless/iwlwifi/pcie/internal.h b/drivers/net/wir=
eless/iwlwifi/pcie/internal.h
index 3d62e80..148843e 100644
--- a/drivers/net/wireless/iwlwifi/pcie/internal.h
+++ b/drivers/net/wireless/iwlwifi/pcie/internal.h
@@ -137,10 +137,6 @@ static inline int iwl_queue_dec_wrap(int index, int n_=
bd)
 struct iwl_cmd_meta {
 	/* only for SYNC commands, iff the reply skb is wanted */
 	struct iwl_host_cmd *source;
-
-	DEFINE_DMA_UNMAP_ADDR(mapping);
-	DEFINE_DMA_UNMAP_LEN(len);
-
 	u32 flags;
 };
=20
@@ -185,25 +181,36 @@ struct iwl_queue {
 /*
  * The FH will write back to the first TB only, so we need
  * to copy some data into the buffer regardless of whether
- * it should be mapped or not. This indicates how much to
- * copy, even for HCMDs it must be big enough to fit the
- * DRAM scratch from the TX cmd, at least 16 bytes.
+ * it should be mapped or not. This indicates how big the
+ * first TB must be to include the scratch buffer. Since
+ * the scratch is 4 bytes at offset 12, it's 16 now. If we
+ * make it bigger then allocations will be bigger and copy
+ * slower, so that's probably not useful.
  */
-#define IWL_HCMD_MIN_COPY_SIZE	16
+#define IWL_HCMD_SCRATCHBUF_SIZE	16
=20
 struct iwl_pcie_txq_entry {
 	struct iwl_device_cmd *cmd;
-	struct iwl_device_cmd *copy_cmd;
 	struct sk_buff *skb;
 	/* buffer to free after command completes */
 	const void *free_buf;
 	struct iwl_cmd_meta meta;
 };
=20
+struct iwl_pcie_txq_scratch_buf {
+	struct iwl_cmd_header hdr;
+	u8 buf[8];
+	__le32 scratch;
+};
+
 /**
  * struct iwl_txq - Tx Queue for DMA
  * @q: generic Rx/Tx queue descriptor
  * @tfds: transmit frame descriptors (DMA memory)
+ * @scratchbufs: start of command headers, including scratch buffers, for
+ *	the writeback -- this is DMA memory and an array holding one buffer
+ *	for each command on the queue
+ * @scratchbufs_dma: DMA address for the scratchbufs start
  * @entries: transmit entries (driver state)
  * @lock: queue lock
  * @stuck_timer: timer that fires if queue gets stuck
@@ -217,6 +224,8 @@ struct iwl_pcie_txq_entry {
 struct iwl_txq {
 	struct iwl_queue q;
 	struct iwl_tfd *tfds;
+	struct iwl_pcie_txq_scratch_buf *scratchbufs;
+	dma_addr_t scratchbufs_dma;
 	struct iwl_pcie_txq_entry *entries;
 	spinlock_t lock;
 	struct timer_list stuck_timer;
@@ -225,6 +234,13 @@ struct iwl_txq {
 	u8 active;
 };
=20
+static inline dma_addr_t
+iwl_pcie_get_scratchbuf_dma(struct iwl_txq *txq, int idx)
+{
+	return txq->scratchbufs_dma +
+	       sizeof(struct iwl_pcie_txq_scratch_buf) * idx;
+}
+
 /**
  * struct iwl_trans_pcie - PCIe transport specific data
  * @rxq: all the RX queue data
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/=
iwlwifi/pcie/rx.c
index b0ae06d..567e67a 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -637,22 +637,14 @@ static void iwl_pcie_rx_handle_rb(struct iwl_trans *t=
rans,
 		index =3D SEQ_TO_INDEX(sequence);
 		cmd_index =3D get_cmd_index(&txq->q, index);
=20
-		if (reclaim) {
-			struct iwl_pcie_txq_entry *ent;
-			ent =3D &txq->entries[cmd_index];
-			cmd =3D ent->copy_cmd;
-			WARN_ON_ONCE(!cmd && ent->meta.flags & CMD_WANT_HCMD);
-		} else {
+		if (reclaim)
+			cmd =3D txq->entries[cmd_index].cmd;
+		else
 			cmd =3D NULL;
-		}
=20
 		err =3D iwl_op_mode_rx(trans->op_mode, &rxcb, cmd);
=20
 		if (reclaim) {
-			/* The original command isn't needed any more */
-			kfree(txq->entries[cmd_index].copy_cmd);
-			txq->entries[cmd_index].copy_cmd =3D NULL;
-			/* nor is the duplicated part of the command */
 			kfree(txq->entries[cmd_index].free_buf);
 			txq->entries[cmd_index].free_buf =3D NULL;
 		}
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/=
iwlwifi/pcie/tx.c
index 8b625a7..8595c16 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -191,12 +191,9 @@ static void iwl_pcie_txq_stuck_timer(unsigned long dat=
a)
 	}
=20
 	for (i =3D q->read_ptr; i !=3D q->write_ptr;
-	     i =3D iwl_queue_inc_wrap(i, q->n_bd)) {
-		struct iwl_tx_cmd *tx_cmd =3D
-			(struct iwl_tx_cmd *)txq->entries[i].cmd->payload;
+	     i =3D iwl_queue_inc_wrap(i, q->n_bd))
 		IWL_ERR(trans, "scratch %d =3D 0x%08x\n", i,
-			get_unaligned_le32(&tx_cmd->scratch));
-	}
+			le32_to_cpu(txq->scratchbufs[i].scratch));
=20
 	iwl_op_mode_nic_error(trans->op_mode);
 }
@@ -367,8 +364,8 @@ static inline u8 iwl_pcie_tfd_get_num_tbs(struct iwl_tf=
d *tfd)
 }
=20
 static void iwl_pcie_tfd_unmap(struct iwl_trans *trans,
-			       struct iwl_cmd_meta *meta, struct iwl_tfd *tfd,
-			       enum dma_data_direction dma_dir)
+			       struct iwl_cmd_meta *meta,
+			       struct iwl_tfd *tfd)
 {
 	int i;
 	int num_tbs;
@@ -382,17 +379,12 @@ static void iwl_pcie_tfd_unmap(struct iwl_trans *tran=
s,
 		return;
 	}
=20
-	/* Unmap tx_cmd */
-	if (num_tbs)
-		dma_unmap_single(trans->dev,
-				dma_unmap_addr(meta, mapping),
-				dma_unmap_len(meta, len),
-				DMA_BIDIRECTIONAL);
+	/* first TB is never freed - it's the scratchbuf data */
=20
-	/* Unmap chunks, if any. */
 	for (i =3D 1; i < num_tbs; i++)
 		dma_unmap_single(trans->dev, iwl_pcie_tfd_tb_get_addr(tfd, i),
-				 iwl_pcie_tfd_tb_get_len(tfd, i), dma_dir);
+				 iwl_pcie_tfd_tb_get_len(tfd, i),
+				 DMA_TO_DEVICE);
=20
 	tfd->num_tbs =3D 0;
 }
@@ -406,8 +398,7 @@ static void iwl_pcie_tfd_unmap(struct iwl_trans *trans,
  * Does NOT advance any TFD circular buffer read/write indexes
  * Does NOT free the TFD itself (which is within circular buffer)
  */
-static void iwl_pcie_txq_free_tfd(struct iwl_trans *trans, struct iwl_txq =
*txq,
-				  enum dma_data_direction dma_dir)
+static void iwl_pcie_txq_free_tfd(struct iwl_trans *trans, struct iwl_txq =
*txq)
 {
 	struct iwl_tfd *tfd_tmp =3D txq->tfds;
=20
@@ -418,8 +409,7 @@ static void iwl_pcie_txq_free_tfd(struct iwl_trans *tra=
ns, struct iwl_txq *txq,
 	lockdep_assert_held(&txq->lock);
=20
 	/* We have only q->n_window txq->entries, but we use q->n_bd tfds */
-	iwl_pcie_tfd_unmap(trans, &txq->entries[idx].meta, &tfd_tmp[rd_ptr],
-			   dma_dir);
+	iwl_pcie_tfd_unmap(trans, &txq->entries[idx].meta, &tfd_tmp[rd_ptr]);
=20
 	/* free SKB */
 	if (txq->entries) {
@@ -479,6 +469,7 @@ static int iwl_pcie_txq_alloc(struct iwl_trans *trans,
 {
 	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
 	size_t tfd_sz =3D sizeof(struct iwl_tfd) * TFD_QUEUE_SIZE_MAX;
+	size_t scratchbuf_sz;
 	int i;
=20
 	if (WARN_ON(txq->entries || txq->tfds))
@@ -514,9 +505,25 @@ static int iwl_pcie_txq_alloc(struct iwl_trans *trans,
 		IWL_ERR(trans, "dma_alloc_coherent(%zd) failed\n", tfd_sz);
 		goto error;
 	}
+
+	BUILD_BUG_ON(IWL_HCMD_SCRATCHBUF_SIZE !=3D sizeof(*txq->scratchbufs));
+	BUILD_BUG_ON(offsetof(struct iwl_pcie_txq_scratch_buf, scratch) !=3D
+			sizeof(struct iwl_cmd_header) +
+			offsetof(struct iwl_tx_cmd, scratch));
+
+	scratchbuf_sz =3D sizeof(*txq->scratchbufs) * slots_num;
+
+	txq->scratchbufs =3D dma_alloc_coherent(trans->dev, scratchbuf_sz,
+					      &txq->scratchbufs_dma,
+					      GFP_KERNEL);
+	if (!txq->scratchbufs)
+		goto err_free_tfds;
+
 	txq->q.id =3D txq_id;
=20
 	return 0;
+err_free_tfds:
+	dma_free_coherent(trans->dev, tfd_sz, txq->tfds, txq->q.dma_addr);
 error:
 	if (txq->entries && txq_id =3D=3D trans_pcie->cmd_queue)
 		for (i =3D 0; i < slots_num; i++)
@@ -565,22 +572,13 @@ static void iwl_pcie_txq_unmap(struct iwl_trans *tran=
s, int txq_id)
 	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
 	struct iwl_txq *txq =3D &trans_pcie->txq[txq_id];
 	struct iwl_queue *q =3D &txq->q;
-	enum dma_data_direction dma_dir;
=20
 	if (!q->n_bd)
 		return;
=20
-	/* In the command queue, all the TBs are mapped as BIDI
-	 * so unmap them as such.
-	 */
-	if (txq_id =3D=3D trans_pcie->cmd_queue)
-		dma_dir =3D DMA_BIDIRECTIONAL;
-	else
-		dma_dir =3D DMA_TO_DEVICE;
-
 	spin_lock_bh(&txq->lock);
 	while (q->write_ptr !=3D q->read_ptr) {
-		iwl_pcie_txq_free_tfd(trans, txq, dma_dir);
+		iwl_pcie_txq_free_tfd(trans, txq);
 		q->read_ptr =3D iwl_queue_inc_wrap(q->read_ptr, q->n_bd);
 	}
 	spin_unlock_bh(&txq->lock);
@@ -610,7 +608,6 @@ static void iwl_pcie_txq_free(struct iwl_trans *trans, =
int txq_id)
 	if (txq_id =3D=3D trans_pcie->cmd_queue)
 		for (i =3D 0; i < txq->q.n_window; i++) {
 			kfree(txq->entries[i].cmd);
-			kfree(txq->entries[i].copy_cmd);
 			kfree(txq->entries[i].free_buf);
 		}
=20
@@ -619,6 +616,10 @@ static void iwl_pcie_txq_free(struct iwl_trans *trans,=
 int txq_id)
 		dma_free_coherent(dev, sizeof(struct iwl_tfd) *
 				  txq->q.n_bd, txq->tfds, txq->q.dma_addr);
 		txq->q.dma_addr =3D 0;
+
+		dma_free_coherent(dev,
+				  sizeof(*txq->scratchbufs) * txq->q.n_window,
+				  txq->scratchbufs, txq->scratchbufs_dma);
 	}
=20
 	kfree(txq->entries);
@@ -962,7 +963,7 @@ void iwl_trans_pcie_reclaim(struct iwl_trans *trans, in=
t txq_id, int ssn,
=20
 		iwl_pcie_txq_inval_byte_cnt_tbl(trans, txq);
=20
-		iwl_pcie_txq_free_tfd(trans, txq, DMA_TO_DEVICE);
+		iwl_pcie_txq_free_tfd(trans, txq);
 	}
=20
 	iwl_pcie_txq_progress(trans_pcie, txq);
@@ -1152,29 +1153,29 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *=
trans,
 	void *dup_buf =3D NULL;
 	dma_addr_t phys_addr;
 	int idx;
-	u16 copy_size, cmd_size, dma_size;
+	u16 copy_size, cmd_size, scratch_size;
 	bool had_nocopy =3D false;
 	int i;
 	u32 cmd_pos;
-	const u8 *cmddata[IWL_MAX_CMD_TFDS];
-	u16 cmdlen[IWL_MAX_CMD_TFDS];
+	const u8 *cmddata[IWL_MAX_CMD_TBS_PER_TFD];
+	u16 cmdlen[IWL_MAX_CMD_TBS_PER_TFD];
=20
 	copy_size =3D sizeof(out_cmd->hdr);
 	cmd_size =3D sizeof(out_cmd->hdr);
=20
 	/* need one for the header if the first is NOCOPY */
-	BUILD_BUG_ON(IWL_MAX_CMD_TFDS > IWL_NUM_OF_TBS - 1);
+	BUILD_BUG_ON(IWL_MAX_CMD_TBS_PER_TFD > IWL_NUM_OF_TBS - 1);
=20
-	for (i =3D 0; i < IWL_MAX_CMD_TFDS; i++) {
+	for (i =3D 0; i < IWL_MAX_CMD_TBS_PER_TFD; i++) {
 		cmddata[i] =3D cmd->data[i];
 		cmdlen[i] =3D cmd->len[i];
=20
 		if (!cmd->len[i])
 			continue;
=20
-		/* need at least IWL_HCMD_MIN_COPY_SIZE copied */
-		if (copy_size < IWL_HCMD_MIN_COPY_SIZE) {
-			int copy =3D IWL_HCMD_MIN_COPY_SIZE - copy_size;
+		/* need at least IWL_HCMD_SCRATCHBUF_SIZE copied */
+		if (copy_size < IWL_HCMD_SCRATCHBUF_SIZE) {
+			int copy =3D IWL_HCMD_SCRATCHBUF_SIZE - copy_size;
=20
 			if (copy > cmdlen[i])
 				copy =3D cmdlen[i];
@@ -1260,15 +1261,15 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *=
trans,
 	/* and copy the data that needs to be copied */
 	cmd_pos =3D offsetof(struct iwl_device_cmd, payload);
 	copy_size =3D sizeof(out_cmd->hdr);
-	for (i =3D 0; i < IWL_MAX_CMD_TFDS; i++) {
+	for (i =3D 0; i < IWL_MAX_CMD_TBS_PER_TFD; i++) {
 		int copy =3D 0;
=20
 		if (!cmd->len)
 			continue;
=20
-		/* need at least IWL_HCMD_MIN_COPY_SIZE copied */
-		if (copy_size < IWL_HCMD_MIN_COPY_SIZE) {
-			copy =3D IWL_HCMD_MIN_COPY_SIZE - copy_size;
+		/* need at least IWL_HCMD_SCRATCHBUF_SIZE copied */
+		if (copy_size < IWL_HCMD_SCRATCHBUF_SIZE) {
+			copy =3D IWL_HCMD_SCRATCHBUF_SIZE - copy_size;
=20
 			if (copy > cmd->len[i])
 				copy =3D cmd->len[i];
@@ -1286,50 +1287,38 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *=
trans,
 		}
 	}
=20
-	WARN_ON_ONCE(txq->entries[idx].copy_cmd);
-
-	/*
-	 * since out_cmd will be the source address of the FH, it will write
-	 * the retry count there. So when the user needs to receivce the HCMD
-	 * that corresponds to the response in the response handler, it needs
-	 * to set CMD_WANT_HCMD.
-	 */
-	if (cmd->flags & CMD_WANT_HCMD) {
-		txq->entries[idx].copy_cmd =3D
-			kmemdup(out_cmd, cmd_pos, GFP_ATOMIC);
-		if (unlikely(!txq->entries[idx].copy_cmd)) {
-			idx =3D -ENOMEM;
-			goto out;
-		}
-	}
-
 	IWL_DEBUG_HC(trans,
 		     "Sending command %s (#%x), seq: 0x%04X, %d bytes at %d[%d]:%d\n",
 		     get_cmd_string(trans_pcie, out_cmd->hdr.cmd),
 		     out_cmd->hdr.cmd, le16_to_cpu(out_cmd->hdr.sequence),
 		     cmd_size, q->write_ptr, idx, trans_pcie->cmd_queue);
=20
-	/*
-	 * If the entire command is smaller than IWL_HCMD_MIN_COPY_SIZE, we must
-	 * still map at least that many bytes for the hardware to write back to.
-	 * We have enough space, so that's not a problem.
-	 */
-	dma_size =3D max_t(u16, copy_size, IWL_HCMD_MIN_COPY_SIZE);
+	/* start the TFD with the scratchbuf */
+	scratch_size =3D min_t(int, copy_size, IWL_HCMD_SCRATCHBUF_SIZE);
+	memcpy(&txq->scratchbufs[q->write_ptr], &out_cmd->hdr, scratch_size);
+	iwl_pcie_txq_build_tfd(trans, txq,
+			       iwl_pcie_get_scratchbuf_dma(txq, q->write_ptr),
+			       scratch_size, 1);
+
+	/* map first command fragment, if any remains */
+	if (copy_size > scratch_size) {
+		phys_addr =3D dma_map_single(trans->dev,
+					   ((u8 *)&out_cmd->hdr) + scratch_size,
+					   copy_size - scratch_size,
+					   DMA_TO_DEVICE);
+		if (dma_mapping_error(trans->dev, phys_addr)) {
+			iwl_pcie_tfd_unmap(trans, out_meta,
+					   &txq->tfds[q->write_ptr]);
+			idx =3D -ENOMEM;
+			goto out;
+		}
=20
-	phys_addr =3D dma_map_single(trans->dev, &out_cmd->hdr, dma_size,
-				   DMA_BIDIRECTIONAL);
-	if (unlikely(dma_mapping_error(trans->dev, phys_addr))) {
-		idx =3D -ENOMEM;
-		goto out;
+		iwl_pcie_txq_build_tfd(trans, txq, phys_addr,
+				       copy_size - scratch_size, 0);
 	}
=20
-	dma_unmap_addr_set(out_meta, mapping, phys_addr);
-	dma_unmap_len_set(out_meta, len, dma_size);
-
-	iwl_pcie_txq_build_tfd(trans, txq, phys_addr, copy_size, 1);
-
 	/* map the remaining (adjusted) nocopy/dup fragments */
-	for (i =3D 0; i < IWL_MAX_CMD_TFDS; i++) {
+	for (i =3D 0; i < IWL_MAX_CMD_TBS_PER_TFD; i++) {
 		const void *data =3D cmddata[i];
=20
 		if (!cmdlen[i])
@@ -1340,11 +1329,10 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *=
trans,
 		if (cmd->dataflags[i] & IWL_HCMD_DFL_DUP)
 			data =3D dup_buf;
 		phys_addr =3D dma_map_single(trans->dev, (void *)data,
-					   cmdlen[i], DMA_BIDIRECTIONAL);
+					   cmdlen[i], DMA_TO_DEVICE);
 		if (dma_mapping_error(trans->dev, phys_addr)) {
 			iwl_pcie_tfd_unmap(trans, out_meta,
-					   &txq->tfds[q->write_ptr],
-					   DMA_BIDIRECTIONAL);
+					   &txq->tfds[q->write_ptr]);
 			idx =3D -ENOMEM;
 			goto out;
 		}
@@ -1418,7 +1406,7 @@ void iwl_pcie_hcmd_complete(struct iwl_trans *trans,
 	cmd =3D txq->entries[cmd_index].cmd;
 	meta =3D &txq->entries[cmd_index].meta;
=20
-	iwl_pcie_tfd_unmap(trans, meta, &txq->tfds[index], DMA_BIDIRECTIONAL);
+	iwl_pcie_tfd_unmap(trans, meta, &txq->tfds[index]);
=20
 	/* Input error checking is done when commands are added to queue. */
 	if (meta->flags & CMD_WANT_SKB) {
@@ -1597,10 +1585,9 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struc=
t sk_buff *skb,
 	struct iwl_cmd_meta *out_meta;
 	struct iwl_txq *txq;
 	struct iwl_queue *q;
-	dma_addr_t phys_addr =3D 0;
-	dma_addr_t txcmd_phys;
-	dma_addr_t scratch_phys;
-	u16 len, firstlen, secondlen;
+	dma_addr_t tb0_phys, tb1_phys, scratch_phys;
+	void *tb1_addr;
+	u16 len, tb1_len, tb2_len;
 	u8 wait_write_ptr =3D 0;
 	__le16 fc =3D hdr->frame_control;
 	u8 hdr_len =3D ieee80211_hdrlen(fc);
@@ -1638,85 +1625,80 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, stru=
ct sk_buff *skb,
 		cpu_to_le16((u16)(QUEUE_TO_SEQ(txq_id) |
 			    INDEX_TO_SEQ(q->write_ptr)));
=20
+	tb0_phys =3D iwl_pcie_get_scratchbuf_dma(txq, q->write_ptr);
+	scratch_phys =3D tb0_phys + sizeof(struct iwl_cmd_header) +
+		       offsetof(struct iwl_tx_cmd, scratch);
+
+	tx_cmd->dram_lsb_ptr =3D cpu_to_le32(scratch_phys);
+	tx_cmd->dram_msb_ptr =3D iwl_get_dma_hi_addr(scratch_phys);
+
 	/* Set up first empty entry in queue's array of Tx/cmd buffers */
 	out_meta =3D &txq->entries[q->write_ptr].meta;
=20
 	/*
-	 * Use the first empty entry in this queue's command buffer array
-	 * to contain the Tx command and MAC header concatenated together
-	 * (payload data will be in another buffer).
-	 * Size of this varies, due to varying MAC header length.
-	 * If end is not dword aligned, we'll have 2 extra bytes at the end
-	 * of the MAC header (device reads on dword boundaries).
-	 * We'll tell device about this padding later.
+	 * The second TB (tb1) points to the remainder of the TX command
+	 * and the 802.11 header - dword aligned size
+	 * (This calculation modifies the TX command, so do it before the
+	 * setup of the first TB)
 	 */
-	len =3D sizeof(struct iwl_tx_cmd) +
-		sizeof(struct iwl_cmd_header) + hdr_len;
-	firstlen =3D (len + 3) & ~3;
+	len =3D sizeof(struct iwl_tx_cmd) + sizeof(struct iwl_cmd_header) +
+	      hdr_len - IWL_HCMD_SCRATCHBUF_SIZE;
+	tb1_len =3D (len + 3) & ~3;
=20
 	/* Tell NIC about any 2-byte padding after MAC header */
-	if (firstlen !=3D len)
+	if (tb1_len !=3D len)
 		tx_cmd->tx_flags |=3D TX_CMD_FLG_MH_PAD_MSK;
=20
-	/* Physical address of this Tx command's header (not MAC header!),
-	 * within command buffer array. */
-	txcmd_phys =3D dma_map_single(trans->dev,
-				    &dev_cmd->hdr, firstlen,
-				    DMA_BIDIRECTIONAL);
-	if (unlikely(dma_mapping_error(trans->dev, txcmd_phys)))
-		goto out_err;
-	dma_unmap_addr_set(out_meta, mapping, txcmd_phys);
-	dma_unmap_len_set(out_meta, len, firstlen);
+	/* The first TB points to the scratchbuf data - min_copy bytes */
+	memcpy(&txq->scratchbufs[q->write_ptr], &dev_cmd->hdr,
+	       IWL_HCMD_SCRATCHBUF_SIZE);
+	iwl_pcie_txq_build_tfd(trans, txq, tb0_phys,
+			       IWL_HCMD_SCRATCHBUF_SIZE, 1);
=20
-	if (!ieee80211_has_morefrags(fc)) {
-		txq->need_update =3D 1;
-	} else {
-		wait_write_ptr =3D 1;
-		txq->need_update =3D 0;
-	}
+	/* there must be data left over for TB1 or this code must be changed */
+	BUILD_BUG_ON(sizeof(struct iwl_tx_cmd) < IWL_HCMD_SCRATCHBUF_SIZE);
=20
-	/* Set up TFD's 2nd entry to point directly to remainder of skb,
-	 * if any (802.11 null frames have no payload). */
-	secondlen =3D skb->len - hdr_len;
-	if (secondlen > 0) {
-		phys_addr =3D dma_map_single(trans->dev, skb->data + hdr_len,
-					   secondlen, DMA_TO_DEVICE);
-		if (unlikely(dma_mapping_error(trans->dev, phys_addr))) {
-			dma_unmap_single(trans->dev,
-					 dma_unmap_addr(out_meta, mapping),
-					 dma_unmap_len(out_meta, len),
-					 DMA_BIDIRECTIONAL);
+	/* map the data for TB1 */
+	tb1_addr =3D ((u8 *)&dev_cmd->hdr) + IWL_HCMD_SCRATCHBUF_SIZE;
+	tb1_phys =3D dma_map_single(trans->dev, tb1_addr, tb1_len, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(trans->dev, tb1_phys)))
+		goto out_err;
+	iwl_pcie_txq_build_tfd(trans, txq, tb1_phys, tb1_len, 0);
+
+	/*
+	 * Set up TFD's third entry to point directly to remainder
+	 * of skb, if any (802.11 null frames have no payload).
+	 */
+	tb2_len =3D skb->len - hdr_len;
+	if (tb2_len > 0) {
+		dma_addr_t tb2_phys =3D dma_map_single(trans->dev,
+						     skb->data + hdr_len,
+						     tb2_len, DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(trans->dev, tb2_phys))) {
+			iwl_pcie_tfd_unmap(trans, out_meta,
+					   &txq->tfds[q->write_ptr]);
 			goto out_err;
 		}
+		iwl_pcie_txq_build_tfd(trans, txq, tb2_phys, tb2_len, 0);
 	}
=20
-	/* Attach buffers to TFD */
-	iwl_pcie_txq_build_tfd(trans, txq, txcmd_phys, firstlen, 1);
-	if (secondlen > 0)
-		iwl_pcie_txq_build_tfd(trans, txq, phys_addr, secondlen, 0);
-
-	scratch_phys =3D txcmd_phys + sizeof(struct iwl_cmd_header) +
-				offsetof(struct iwl_tx_cmd, scratch);
-
-	/* take back ownership of DMA buffer to enable update */
-	dma_sync_single_for_cpu(trans->dev, txcmd_phys, firstlen,
-				DMA_BIDIRECTIONAL);
-	tx_cmd->dram_lsb_ptr =3D cpu_to_le32(scratch_phys);
-	tx_cmd->dram_msb_ptr =3D iwl_get_dma_hi_addr(scratch_phys);
-
 	/* Set up entry for this TFD in Tx byte-count array */
 	iwl_pcie_txq_update_byte_cnt_tbl(trans, txq, le16_to_cpu(tx_cmd->len));
=20
-	dma_sync_single_for_device(trans->dev, txcmd_phys, firstlen,
-				   DMA_BIDIRECTIONAL);
-
 	trace_iwlwifi_dev_tx(trans->dev, skb,
 			     &txq->tfds[txq->q.write_ptr],
 			     sizeof(struct iwl_tfd),
-			     &dev_cmd->hdr, firstlen,
-			     skb->data + hdr_len, secondlen);
+			     &dev_cmd->hdr, IWL_HCMD_SCRATCHBUF_SIZE + tb1_len,
+			     skb->data + hdr_len, tb2_len);
 	trace_iwlwifi_dev_tx_data(trans->dev, skb,
-				  skb->data + hdr_len, secondlen);
+				  skb->data + hdr_len, tb2_len);
+
+	if (!ieee80211_has_morefrags(fc)) {
+		txq->need_update =3D 1;
+	} else {
+		wait_write_ptr =3D 1;
+		txq->need_update =3D 0;
+	}
=20
 	/* start timer if queue currently empty */
 	if (txq->need_update && q->read_ptr =3D=3D q->write_ptr &&
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 808f5fc..fb30681 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -3290,14 +3290,19 @@ static int ieee80211_cfg_get_channel(struct wiphy *=
wiphy,
 	int ret =3D -ENODATA;
=20
 	rcu_read_lock();
-	if (local->use_chanctx) {
-		chanctx_conf =3D rcu_dereference(sdata->vif.chanctx_conf);
-		if (chanctx_conf) {
-			*chandef =3D chanctx_conf->def;
-			ret =3D 0;
-		}
-	} else if (local->open_count =3D=3D local->monitors) {
-		*chandef =3D local->monitor_chandef;
+	chanctx_conf =3D rcu_dereference(sdata->vif.chanctx_conf);
+	if (chanctx_conf) {
+		*chandef =3D chanctx_conf->def;
+		ret =3D 0;
+	} else if (local->open_count > 0 &&
+		   local->open_count =3D=3D local->monitors &&
+		   sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR) {
+		if (local->use_chanctx)
+			*chandef =3D local->monitor_chandef;
+		else
+			cfg80211_chandef_create(chandef,
+						local->_oper_channel,
+						local->_oper_channel_type);
 		ret =3D 0;
 	}
 	rcu_read_unlock();
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 640afab..baaa860 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -541,6 +541,9 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool c=
oming_up)
=20
 		ieee80211_adjust_monitor_flags(sdata, 1);
 		ieee80211_configure_filter(local);
+		mutex_lock(&local->mtx);
+		ieee80211_recalc_idle(local);
+		mutex_unlock(&local->mtx);
=20
 		netif_carrier_on(dev);
 		break;
@@ -812,6 +815,9 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_d=
ata *sdata,
=20
 		ieee80211_adjust_monitor_flags(sdata, -1);
 		ieee80211_configure_filter(local);
+		mutex_lock(&local->mtx);
+		ieee80211_recalc_idle(local);
+		mutex_unlock(&local->mtx);
 		break;
 	case NL80211_IFTYPE_P2P_DEVICE:
 		/* relies on synchronize_rcu() below */
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 9f6464f..1415774 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -647,6 +647,9 @@ static void ieee80211_add_vht_ie(struct ieee80211_sub_i=
f_data *sdata,
 		our_mcs =3D (le16_to_cpu(vht_cap.vht_mcs.rx_mcs_map) &
 								mask) >> shift;
=20
+		if (our_mcs =3D=3D IEEE80211_VHT_MCS_NOT_SUPPORTED)
+			continue;
+
 		switch (ap_mcs) {
 		default:
 			if (our_mcs <=3D ap_mcs)
@@ -3503,6 +3506,14 @@ void ieee80211_sta_quiesce(struct ieee80211_sub_if_d=
ata *sdata)
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
=20
 	/*
+	 * Stop timers before deleting work items, as timers
+	 * could race and re-add the work-items. They will be
+	 * re-established on connection.
+	 */
+	del_timer_sync(&ifmgd->conn_mon_timer);
+	del_timer_sync(&ifmgd->bcn_mon_timer);
+
+	/*
 	 * we need to use atomic bitops for the running bits
 	 * only because both timers might fire at the same
 	 * time -- the code here is properly synchronised.
@@ -3516,13 +3527,9 @@ void ieee80211_sta_quiesce(struct ieee80211_sub_if_d=
ata *sdata)
 	if (del_timer_sync(&ifmgd->timer))
 		set_bit(TMR_RUNNING_TIMER, &ifmgd->timers_running);
=20
-	cancel_work_sync(&ifmgd->chswitch_work);
 	if (del_timer_sync(&ifmgd->chswitch_timer))
 		set_bit(TMR_RUNNING_CHANSW, &ifmgd->timers_running);
-
-	/* these will just be re-established on connection */
-	del_timer_sync(&ifmgd->conn_mon_timer);
-	del_timer_sync(&ifmgd->bcn_mon_timer);
+	cancel_work_sync(&ifmgd->chswitch_work);
 }
=20
 void ieee80211_sta_restart(struct ieee80211_sub_if_data *sdata)
@@ -4315,6 +4322,17 @@ void ieee80211_mgd_stop(struct ieee80211_sub_if_data=
 *sdata)
 {
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
=20
+	/*
+	 * Make sure some work items will not run after this,
+	 * they will not do anything but might not have been
+	 * cancelled when disconnecting.
+	 */
+	cancel_work_sync(&ifmgd->monitor_work);
+	cancel_work_sync(&ifmgd->beacon_connection_loss_work);
+	cancel_work_sync(&ifmgd->request_smps_work);
+	cancel_work_sync(&ifmgd->csa_connection_drop_work);
+	cancel_work_sync(&ifmgd->chswitch_work);
+
 	mutex_lock(&ifmgd->mtx);
 	if (ifmgd->assoc_data)
 		ieee80211_destroy_assoc_data(sdata, false);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index ce78d11..8914d2d 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2745,7 +2745,8 @@ ieee80211_get_buffered_bc(struct ieee80211_hw *hw,
 				cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 		}
=20
-		sdata =3D IEEE80211_DEV_TO_SUB_IF(skb->dev);
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+			sdata =3D IEEE80211_DEV_TO_SUB_IF(skb->dev);
 		if (!ieee80211_tx_prepare(sdata, &tx, skb))
 			break;
 		dev_kfree_skb_any(skb);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 5ffff03..ea4155f 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -367,8 +367,7 @@ struct wiphy *wiphy_new(const struct cfg80211_ops *ops,=
 int sizeof_priv)
 	rdev->wiphy.rts_threshold =3D (u32) -1;
 	rdev->wiphy.coverage_class =3D 0;
=20
-	rdev->wiphy.features =3D NL80211_FEATURE_SCAN_FLUSH |
-			       NL80211_FEATURE_ADVERTISE_CHAN_LIMITS;
+	rdev->wiphy.features =3D NL80211_FEATURE_SCAN_FLUSH;
=20
 	return &rdev->wiphy;
 }
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e652d05..d44ab21 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -557,18 +557,6 @@ static int nl80211_msg_put_channel(struct sk_buff *msg,
 	if ((chan->flags & IEEE80211_CHAN_RADAR) &&
 	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_RADAR))
 		goto nla_put_failure;
-	if ((chan->flags & IEEE80211_CHAN_NO_HT40MINUS) &&
-	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_NO_HT40_MINUS))
-		goto nla_put_failure;
-	if ((chan->flags & IEEE80211_CHAN_NO_HT40PLUS) &&
-	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_NO_HT40_PLUS))
-		goto nla_put_failure;
-	if ((chan->flags & IEEE80211_CHAN_NO_80MHZ) &&
-	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_NO_80MHZ))
-		goto nla_put_failure;
-	if ((chan->flags & IEEE80211_CHAN_NO_160MHZ) &&
-	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_NO_160MHZ))
-		goto nla_put_failure;
=20
 	if (nla_put_u32(msg, NL80211_FREQUENCY_ATTR_MAX_TX_POWER,
 			DBM_TO_MBM(chan->max_power)))
@@ -1310,15 +1298,6 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u=
32 portid, u32 seq, int flag
 			dev->wiphy.max_acl_mac_addrs))
 		goto nla_put_failure;
=20
-	if (dev->wiphy.extended_capabilities &&
-	    (nla_put(msg, NL80211_ATTR_EXT_CAPA,
-		     dev->wiphy.extended_capabilities_len,
-		     dev->wiphy.extended_capabilities) ||
-	     nla_put(msg, NL80211_ATTR_EXT_CAPA_MASK,
-		     dev->wiphy.extended_capabilities_len,
-		     dev->wiphy.extended_capabilities_mask)))
-		goto nla_put_failure;
-
 	return genlmsg_end(msg, hdr);
=20
  nla_put_failure:
@@ -1328,7 +1307,7 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u3=
2 portid, u32 seq, int flag
=20
 static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback=
 *cb)
 {
-	int idx =3D 0;
+	int idx =3D 0, ret;
 	int start =3D cb->args[0];
 	struct cfg80211_registered_device *dev;
=20
@@ -1338,9 +1317,29 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, s=
truct netlink_callback *cb)
 			continue;
 		if (++idx <=3D start)
 			continue;
-		if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).portid,
-				       cb->nlh->nlmsg_seq, NLM_F_MULTI,
-				       dev) < 0) {
+		ret =3D nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).portid,
+					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					 dev);
+		if (ret < 0) {
+			/*
+			 * If sending the wiphy data didn't fit (ENOBUFS or
+			 * EMSGSIZE returned), this SKB is still empty (so
+			 * it's not too big because another wiphy dataset is
+			 * already in the skb) and we've not tried to adjust
+			 * the dump allocation yet ... then adjust the alloc
+			 * size to be bigger, and return 1 but with the empty
+			 * skb. This results in an empty message being RX'ed
+			 * in userspace, but that is ignored.
+			 *
+			 * We can then retry with the larger buffer.
+			 */
+			if ((ret =3D=3D -ENOBUFS || ret =3D=3D -EMSGSIZE) &&
+			    !skb->len &&
+			    cb->min_dump_alloc < 4096) {
+				cb->min_dump_alloc =3D 4096;
+				mutex_unlock(&cfg80211_mutex);
+				return 1;
+			}
 			idx--;
 			break;
 		}
@@ -1357,7 +1356,7 @@ static int nl80211_get_wiphy(struct sk_buff *skb, str=
uct genl_info *info)
 	struct sk_buff *msg;
 	struct cfg80211_registered_device *dev =3D info->user_ptr[0];
=20
-	msg =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	msg =3D nlmsg_new(4096, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRN5kIAAoJEJctW/TcYTgGP6sP/3x5Z5i7K7YZAoo9iJ1/FIdx
X3b896aKlZ4JSHyD8nyj1M97cyP+AFDW30HfKaBHztNo5Z8eS/di9Dv3Zr6L1+Ss
LbyboIPjTPtFnUPtGuWcubLeXBN8eQpkQY6cCmIgG/wOWKaro/q72e0g7A9G+HH8
bFgKEMQWmrIujk0bk2Yw+tTWqAi1cV5U7IGV22hVf0wWtXB7RLNbgE30n0/77E6K
3RrWfK9/mWViDhZ91C7DpB2/jw5PRsihm5JwUDZ7+VEgX9www8Vm9GaIrIXMVLgL
XOI4WjBcmPHSZvm33Aw8RdF5s37xVB5rP2Beb192tzO84NopNw8GKgxGdj0zeXrA
1OWdimprUWqCnZMTF/92yLIl3EUU9JFo1DDKePBBSmPTm/MvqeFDo3sMTYS+1ZeQ
sLB9e29CaO27Lev0OmLsNAK8rRXwmMXRoIAwFH/Vm8Kr6zVOuSGD5Ha9KOcQJ7Rj
uihFK0SZL+nFJAjnUu39HlhAhLUfCH9Q9LXso1Ih+/Tt8jhcexrJwoDjN1KH12JH
l5LQlcPxS21niFtH1qiFhuGzOqz+0FbKcJ5N4Aqz+Da86P87ruDBb5kljgsx7GPX
/7tSD29lD3WnkUYmi2FsUJTF9bGu+lKMlB43PGdXXZSxf5wKGI1Nzzu2Jof18lj7
v/Tj98NnIn6W7gYVJHsT
=TgQ3
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--
