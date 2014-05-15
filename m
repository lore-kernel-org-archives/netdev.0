From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-05-15
Date: Thu, 15 May 2014 11:45:46 -0400
Message-ID: <20140515154545.GB3431@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Nq2Wo0NMKNjxTN9z"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes for the 3.15 stream...

For the mac80211 bits, Johannes says:

"One fix is to get better VHT performance and the other fixes tracing
garbage or other potential issues with the interface name tracing."

And...

"This has a fix from Emmanuel for a problem I failed to fix - when
association is in progress then it needs to be cancelled while
suspending (I had fixed the same for authentication). Also included a
fix from myself for a userspace API problem that hit the iw tool and a
fix to the remain-on-channel framework."

For the iwlwifi bits, Emmanuel says:

"Alex fixes the scan by disabling the fragmented scan. David prevents
scan offload while associated, the firmware seems not to like it. I
fix a stupid bug I made in BT Coex, and fix a bad #ifdef clause in rate
scaling.  Along with that there is a fix for a NULL pointer exception
that can happen if we load the driver and our ISR gets called because
the interrupt line is shared. The fix has been tested by the reporter."

And...

"We have here a fix from David Spinadel that makes a previous fix more
complete, and an off-by-one issue fixed by Eliad in the same area.
I fix the monitor that broke on the way."

Beyond that...

Daniel Kim's one-liner fixes a brcmfmac regression caused by a typo
in an earlier commit..

Rajkumar Manoharan fixes an ath9k oops reported by David Herrmann.

---

The following changes since commit e84d2f8d2ae33c8215429824e1ecf24cbca9645e:

  net: filter: s390: fix JIT address randomization (2014-05-14 16:10:16 -04=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 025a58fd9d5785d63c398e96ac543db2639c7ddc:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-05-15 10:24:28 -0400)

----------------------------------------------------------------

Alexander Bondar (1):
      iwlwifi: mvm: several fixes in scan

Daniel Kim (1):
      brcmfmac: Fix iovar 'bw_cap' set command failure

David Spinadel (2):
      iwlwifi: mvm: do no sched scan while associated
      iwlwifi: mvm: prevent sched scan while not idle

Eliad Peller (2):
      mac80211: fix vif name tracing
      iwlwifi: mvm: fix off-by-one in scan channels configuration

Emmanuel Grumbach (5):
      iwlwifi: mvm: BT Coex - fix validity flags during init
      iwlwifi: mvm: rs - s/CPTCFG/CONFIG
      iwlwifi: pcie: disable interrupts upon PCIe alloc
      iwlwifi: mvm: fix setting channel in monitor mode
      mac80211: fix suspend vs. association race

Johannes Berg (3):
      mac80211: allow VHT with peers not capable of 40MHz
      nl80211: fix NL80211_FEATURE_P2P_DEVICE_NEEDS_CHANNEL API
      mac80211: fix on-channel remain-on-channel

John W. Linville (5):
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fix=
es
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Rajkumar Manoharan (1):
      ath9k_htc: Stop ANI before doing hw_reset

 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  5 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  2 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  6 +--
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  8 ++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  9 +++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  3 ++
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            | 55 +++++-------------=
----
 drivers/net/wireless/iwlwifi/mvm/utils.c           | 19 ++++++++
 drivers/net/wireless/iwlwifi/pcie/trans.c          | 10 ++--
 include/uapi/linux/nl80211.h                       |  4 +-
 net/mac80211/ieee80211_i.h                         |  1 +
 net/mac80211/mlme.c                                | 20 +++++---
 net/mac80211/offchannel.c                          | 27 ++++++++---
 net/mac80211/trace.h                               |  4 +-
 net/mac80211/vht.c                                 |  9 ++--
 16 files changed, 106 insertions(+), 78 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_main.c
index f46cd0250e48..5627917c5ff7 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -95,8 +95,10 @@ static void ath9k_htc_vif_iter(void *data, u8 *mac, stru=
ct ieee80211_vif *vif)
=20
 	if ((vif->type =3D=3D NL80211_IFTYPE_AP ||
 	     vif->type =3D=3D NL80211_IFTYPE_MESH_POINT) &&
-	    bss_conf->enable_beacon)
+	    bss_conf->enable_beacon) {
 		priv->reconfig_beacon =3D true;
+		priv->rearm_ani =3D true;
+	}
=20
 	if (bss_conf->assoc) {
 		priv->rearm_ani =3D true;
@@ -257,6 +259,7 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv =
*priv,
=20
 	ath9k_htc_ps_wakeup(priv);
=20
+	ath9k_htc_stop_ani(priv);
 	del_timer_sync(&priv->tx.cleanup_timer);
 	ath9k_htc_tx_drain(priv);
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index afb3d15e38ff..be1985296bdc 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -4948,7 +4948,7 @@ static int brcmf_enable_bw40_2g(struct brcmf_if *ifp)
 	if (!err) {
 		/* only set 2G bandwidth using bw_cap command */
 		band_bwcap.band =3D cpu_to_le32(WLC_BAND_2G);
-		band_bwcap.bw_cap =3D cpu_to_le32(WLC_BW_40MHZ_BIT);
+		band_bwcap.bw_cap =3D cpu_to_le32(WLC_BW_CAP_40MHZ);
 		err =3D brcmf_fil_iovar_data_set(ifp, "bw_cap", &band_bwcap,
 					       sizeof(band_bwcap));
 	} else {
diff --git a/drivers/net/wireless/iwlwifi/mvm/coex.c b/drivers/net/wireless=
/iwlwifi/mvm/coex.c
index fa858d548d13..0489314425cb 100644
--- a/drivers/net/wireless/iwlwifi/mvm/coex.c
+++ b/drivers/net/wireless/iwlwifi/mvm/coex.c
@@ -611,14 +611,14 @@ int iwl_send_bt_init_conf(struct iwl_mvm *mvm)
 		bt_cmd->flags |=3D cpu_to_le32(BT_COEX_SYNC2SCO);
=20
 	if (IWL_MVM_BT_COEX_CORUNNING) {
-		bt_cmd->valid_bit_msk =3D cpu_to_le32(BT_VALID_CORUN_LUT_20 |
-						    BT_VALID_CORUN_LUT_40);
+		bt_cmd->valid_bit_msk |=3D cpu_to_le32(BT_VALID_CORUN_LUT_20 |
+						     BT_VALID_CORUN_LUT_40);
 		bt_cmd->flags |=3D cpu_to_le32(BT_COEX_CORUNNING);
 	}
=20
 	if (IWL_MVM_BT_COEX_MPLUT) {
 		bt_cmd->flags |=3D cpu_to_le32(BT_COEX_MPLUT);
-		bt_cmd->valid_bit_msk =3D cpu_to_le32(BT_VALID_MULTI_PRIO_LUT);
+		bt_cmd->valid_bit_msk |=3D cpu_to_le32(BT_VALID_MULTI_PRIO_LUT);
 	}
=20
 	if (mvm->cfg->bt_shared_single_ant)
diff --git a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h b/drivers/net/w=
ireless/iwlwifi/mvm/fw-api-scan.h
index 9426905de6b2..d73a89ecd78a 100644
--- a/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
+++ b/drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h
@@ -183,9 +183,9 @@ enum iwl_scan_type {
  *	this number of packets were received (typically 1)
  * @passive2active: is auto switching from passive to active during scan a=
llowed
  * @rxchain_sel_flags: RXON_RX_CHAIN_*
- * @max_out_time: in usecs, max out of serving channel time
+ * @max_out_time: in TUs, max out of serving channel time
  * @suspend_time: how long to pause scan when returning to service channel:
- *	bits 0-19: beacon interal in usecs (suspend before executing)
+ *	bits 0-19: beacon interal in TUs (suspend before executing)
  *	bits 20-23: reserved
  *	bits 24-31: number of beacons (suspend between channels)
  * @rxon_flags: RXON_FLG_*
@@ -383,8 +383,8 @@ enum scan_framework_client {
  * @quiet_plcp_th:	quiet channel num of packets threshold
  * @good_CRC_th:	passive to active promotion threshold
  * @rx_chain:		RXON rx chain.
- * @max_out_time:	max uSec to be out of assoceated channel
- * @suspend_time:	pause scan this long when returning to service channel
+ * @max_out_time:	max TUs to be out of assoceated channel
+ * @suspend_time:	pause scan this TUs when returning to service channel
  * @flags:		RXON flags
  * @filter_flags:	RXONfilter
  * @tx_cmd:		tx command for active scan; for 2GHz and for 5GHz.
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index f0cebf12c7b8..b41dc84e9431 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -1007,7 +1007,7 @@ static void iwl_mvm_mc_iface_iterator(void *_data, u8=
 *mac,
 	memcpy(cmd->bssid, vif->bss_conf.bssid, ETH_ALEN);
 	len =3D roundup(sizeof(*cmd) + cmd->count * ETH_ALEN, 4);
=20
-	ret =3D iwl_mvm_send_cmd_pdu(mvm, MCAST_FILTER_CMD, CMD_SYNC, len, cmd);
+	ret =3D iwl_mvm_send_cmd_pdu(mvm, MCAST_FILTER_CMD, CMD_ASYNC, len, cmd);
 	if (ret)
 		IWL_ERR(mvm, "mcast filter cmd error. ret=3D%d\n", ret);
 }
@@ -1023,7 +1023,7 @@ static void iwl_mvm_recalc_multicast(struct iwl_mvm *=
mvm)
 	if (WARN_ON_ONCE(!mvm->mcast_filter_cmd))
 		return;
=20
-	ieee80211_iterate_active_interfaces(
+	ieee80211_iterate_active_interfaces_atomic(
 		mvm->hw, IEEE80211_IFACE_ITER_NORMAL,
 		iwl_mvm_mc_iface_iterator, &iter_data);
 }
@@ -1807,6 +1807,11 @@ static int iwl_mvm_mac_sched_scan_start(struct ieee8=
0211_hw *hw,
=20
 	mutex_lock(&mvm->mutex);
=20
+	if (!iwl_mvm_is_idle(mvm)) {
+		ret =3D -EBUSY;
+		goto out;
+	}
+
 	switch (mvm->scan_status) {
 	case IWL_MVM_SCAN_OS:
 		IWL_DEBUG_SCAN(mvm, "Stopping previous scan for sched_scan\n");
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/=
iwlwifi/mvm/mvm.h
index d564233a65da..f1ec0986c3c9 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -1003,6 +1003,9 @@ static inline bool iwl_mvm_vif_low_latency(struct iwl=
_mvm_vif *mvmvif)
 	return mvmvif->low_latency;
 }
=20
+/* Assoc status */
+bool iwl_mvm_is_idle(struct iwl_mvm *mvm);
+
 /* Thermal management and CT-kill */
 void iwl_mvm_tt_tx_backoff(struct iwl_mvm *mvm, u32 backoff);
 void iwl_mvm_tt_handler(struct iwl_mvm *mvm);
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.c b/drivers/net/wireless/i=
wlwifi/mvm/rs.c
index 9f52c5b3f0ec..e1c838899363 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rs.c
@@ -1010,7 +1010,7 @@ static void rs_tx_status(void *mvm_r, struct ieee8021=
1_supported_band *sband,
 		return;
 	}
=20
-#ifdef CPTCFG_MAC80211_DEBUGFS
+#ifdef CONFIG_MAC80211_DEBUGFS
 	/* Disable last tx check if we are debugging with fixed rate */
 	if (lq_sta->dbg_fixed_rate) {
 		IWL_DEBUG_RATE(mvm, "Fixed rate. avoid rate scaling\n");
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index c91dc8498852..c28de54c75d4 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -277,51 +277,22 @@ static void iwl_mvm_scan_calc_params(struct iwl_mvm *=
mvm,
 					    IEEE80211_IFACE_ITER_NORMAL,
 					    iwl_mvm_scan_condition_iterator,
 					    &global_bound);
-	/*
-	 * Under low latency traffic passive scan is fragmented meaning
-	 * that dwell on a particular channel will be fragmented. Each fragment
-	 * dwell time is 20ms and fragments period is 105ms. Skipping to next
-	 * channel will be delayed by the same period - 105ms. So suspend_time
-	 * parameter describing both fragments and channels skipping periods is
-	 * set to 105ms. This value is chosen so that overall passive scan
-	 * duration will not be too long. Max_out_time in this case is set to
-	 * 70ms, so for active scanning operating channel will be left for 70ms
-	 * while for passive still for 20ms (fragment dwell).
-	 */
-	if (global_bound) {
-		if (!iwl_mvm_low_latency(mvm)) {
-			params->suspend_time =3D ieee80211_tu_to_usec(100);
-			params->max_out_time =3D ieee80211_tu_to_usec(600);
-		} else {
-			params->suspend_time =3D ieee80211_tu_to_usec(105);
-			/* P2P doesn't support fragmented passive scan, so
-			 * configure max_out_time to be at least longest dwell
-			 * time for passive scan.
-			 */
-			if (vif->type =3D=3D NL80211_IFTYPE_STATION && !vif->p2p) {
-				params->max_out_time =3D ieee80211_tu_to_usec(70);
-				params->passive_fragmented =3D true;
-			} else {
-				u32 passive_dwell;
=20
-				/*
-				 * Use band G so that passive channel dwell time
-				 * will be assigned with maximum value.
-				 */
-				band =3D IEEE80211_BAND_2GHZ;
-				passive_dwell =3D iwl_mvm_get_passive_dwell(band);
-				params->max_out_time =3D
-					ieee80211_tu_to_usec(passive_dwell);
-			}
-		}
+	if (!global_bound)
+		goto not_bound;
+
+	params->suspend_time =3D 100;
+	params->max_out_time =3D 600;
+
+	if (iwl_mvm_low_latency(mvm)) {
+		params->suspend_time =3D 250;
+		params->max_out_time =3D 250;
 	}
=20
+not_bound:
+
 	for (band =3D IEEE80211_BAND_2GHZ; band < IEEE80211_NUM_BANDS; band++) {
-		if (params->passive_fragmented)
-			params->dwell[band].passive =3D 20;
-		else
-			params->dwell[band].passive =3D
-				iwl_mvm_get_passive_dwell(band);
+		params->dwell[band].passive =3D iwl_mvm_get_passive_dwell(band);
 		params->dwell[band].active =3D iwl_mvm_get_active_dwell(band,
 								      n_ssids);
 	}
@@ -761,7 +732,7 @@ int iwl_mvm_config_sched_scan(struct iwl_mvm *mvm,
 	int band_2ghz =3D mvm->nvm_data->bands[IEEE80211_BAND_2GHZ].n_channels;
 	int band_5ghz =3D mvm->nvm_data->bands[IEEE80211_BAND_5GHZ].n_channels;
 	int head =3D 0;
-	int tail =3D band_2ghz + band_5ghz;
+	int tail =3D band_2ghz + band_5ghz - 1;
 	u32 ssid_bitmap;
 	int cmd_len;
 	int ret;
diff --git a/drivers/net/wireless/iwlwifi/mvm/utils.c b/drivers/net/wireles=
s/iwlwifi/mvm/utils.c
index d619851745a1..2180902266ae 100644
--- a/drivers/net/wireless/iwlwifi/mvm/utils.c
+++ b/drivers/net/wireless/iwlwifi/mvm/utils.c
@@ -644,3 +644,22 @@ bool iwl_mvm_low_latency(struct iwl_mvm *mvm)
=20
 	return result;
 }
+
+static void iwl_mvm_idle_iter(void *_data, u8 *mac, struct ieee80211_vif *=
vif)
+{
+	bool *idle =3D _data;
+
+	if (!vif->bss_conf.idle)
+		*idle =3D false;
+}
+
+bool iwl_mvm_is_idle(struct iwl_mvm *mvm)
+{
+	bool idle =3D true;
+
+	ieee80211_iterate_active_interfaces_atomic(
+			mvm->hw, IEEE80211_IFACE_ITER_NORMAL,
+			iwl_mvm_idle_iter, &idle);
+
+	return idle;
+}
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index dcfd6d866d09..2365553f1ef7 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1749,6 +1749,10 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_de=
v *pdev,
 	 * PCI Tx retries from interfering with C3 CPU state */
 	pci_write_config_byte(pdev, PCI_CFG_RETRY_TIMEOUT, 0x00);
=20
+	trans->dev =3D &pdev->dev;
+	trans_pcie->pci_dev =3D pdev;
+	iwl_disable_interrupts(trans);
+
 	err =3D pci_enable_msi(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "pci_enable_msi failed(0X%x)\n", err);
@@ -1760,8 +1764,6 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev=
 *pdev,
 		}
 	}
=20
-	trans->dev =3D &pdev->dev;
-	trans_pcie->pci_dev =3D pdev;
 	trans->hw_rev =3D iwl_read32(trans, CSR_HW_REV);
 	trans->hw_id =3D (pdev->device << 16) + pdev->subsystem_device;
 	snprintf(trans->hw_id_str, sizeof(trans->hw_id_str),
@@ -1787,8 +1789,6 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev=
 *pdev,
 		goto out_pci_disable_msi;
 	}
=20
-	trans_pcie->inta_mask =3D CSR_INI_SET_MASK;
-
 	if (iwl_pcie_alloc_ict(trans))
 		goto out_free_cmd_pool;
=20
@@ -1800,6 +1800,8 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev=
 *pdev,
 		goto out_free_ict;
 	}
=20
+	trans_pcie->inta_mask =3D CSR_INI_SET_MASK;
+
 	return trans;
=20
 out_free_ict:
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 1ba9d626aa83..194c1eab04d8 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -3856,6 +3856,8 @@ enum nl80211_ap_sme_features {
  * @NL80211_FEATURE_CELL_BASE_REG_HINTS: This driver has been tested
  *	to work properly to suppport receiving regulatory hints from
  *	cellular base stations.
+ * @NL80211_FEATURE_P2P_DEVICE_NEEDS_CHANNEL: (no longer available, only
+ *	here to reserve the value for API/ABI compatibility)
  * @NL80211_FEATURE_SAE: This driver supports simultaneous authentication =
of
  *	equals (SAE) with user space SME (NL80211_CMD_AUTHENTICATE) in station
  *	mode
@@ -3897,7 +3899,7 @@ enum nl80211_feature_flags {
 	NL80211_FEATURE_HT_IBSS				=3D 1 << 1,
 	NL80211_FEATURE_INACTIVITY_TIMER		=3D 1 << 2,
 	NL80211_FEATURE_CELL_BASE_REG_HINTS		=3D 1 << 3,
-	/* bit 4 is reserved - don't use */
+	NL80211_FEATURE_P2P_DEVICE_NEEDS_CHANNEL	=3D 1 << 4,
 	NL80211_FEATURE_SAE				=3D 1 << 5,
 	NL80211_FEATURE_LOW_PRIORITY_SCAN		=3D 1 << 6,
 	NL80211_FEATURE_SCAN_FLUSH			=3D 1 << 7,
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 222c28b75315..f169b6ee94ee 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -317,6 +317,7 @@ struct ieee80211_roc_work {
=20
 	bool started, abort, hw_begun, notified;
 	bool to_be_freed;
+	bool on_channel;
=20
 	unsigned long hw_start_time;
=20
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index dee50aefd6e8..27600a9808ba 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3598,18 +3598,24 @@ void ieee80211_mgd_quiesce(struct ieee80211_sub_if_=
data *sdata)
=20
 	sdata_lock(sdata);
=20
-	if (ifmgd->auth_data) {
+	if (ifmgd->auth_data || ifmgd->assoc_data) {
+		const u8 *bssid =3D ifmgd->auth_data ?
+				ifmgd->auth_data->bss->bssid :
+				ifmgd->assoc_data->bss->bssid;
+
 		/*
-		 * If we are trying to authenticate while suspending, cfg80211
-		 * won't know and won't actually abort those attempts, thus we
-		 * need to do that ourselves.
+		 * If we are trying to authenticate / associate while suspending,
+		 * cfg80211 won't know and won't actually abort those attempts,
+		 * thus we need to do that ourselves.
 		 */
-		ieee80211_send_deauth_disassoc(sdata,
-					       ifmgd->auth_data->bss->bssid,
+		ieee80211_send_deauth_disassoc(sdata, bssid,
 					       IEEE80211_STYPE_DEAUTH,
 					       WLAN_REASON_DEAUTH_LEAVING,
 					       false, frame_buf);
-		ieee80211_destroy_auth_data(sdata, false);
+		if (ifmgd->assoc_data)
+			ieee80211_destroy_assoc_data(sdata, false);
+		if (ifmgd->auth_data)
+			ieee80211_destroy_auth_data(sdata, false);
 		cfg80211_tx_mlme_mgmt(sdata->dev, frame_buf,
 				      IEEE80211_DEAUTH_FRAME_LEN);
 	}
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index 6fb38558a5e6..7a17decd27f9 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -333,7 +333,7 @@ void ieee80211_sw_roc_work(struct work_struct *work)
 		container_of(work, struct ieee80211_roc_work, work.work);
 	struct ieee80211_sub_if_data *sdata =3D roc->sdata;
 	struct ieee80211_local *local =3D sdata->local;
-	bool started;
+	bool started, on_channel;
=20
 	mutex_lock(&local->mtx);
=20
@@ -354,14 +354,26 @@ void ieee80211_sw_roc_work(struct work_struct *work)
 	if (!roc->started) {
 		struct ieee80211_roc_work *dep;
=20
-		/* start this ROC */
-		ieee80211_offchannel_stop_vifs(local);
+		WARN_ON(local->use_chanctx);
+
+		/* If actually operating on the desired channel (with at least
+		 * 20 MHz channel width) don't stop all the operations but still
+		 * treat it as though the ROC operation started properly, so
+		 * other ROC operations won't interfere with this one.
+		 */
+		roc->on_channel =3D roc->chan =3D=3D local->_oper_chandef.chan &&
+				  local->_oper_chandef.width !=3D NL80211_CHAN_WIDTH_5 &&
+				  local->_oper_chandef.width !=3D NL80211_CHAN_WIDTH_10;
=20
-		/* switch channel etc */
+		/* start this ROC */
 		ieee80211_recalc_idle(local);
=20
-		local->tmp_channel =3D roc->chan;
-		ieee80211_hw_config(local, 0);
+		if (!roc->on_channel) {
+			ieee80211_offchannel_stop_vifs(local);
+
+			local->tmp_channel =3D roc->chan;
+			ieee80211_hw_config(local, 0);
+		}
=20
 		/* tell userspace or send frame */
 		ieee80211_handle_roc_started(roc);
@@ -380,9 +392,10 @@ void ieee80211_sw_roc_work(struct work_struct *work)
  finish:
 		list_del(&roc->list);
 		started =3D roc->started;
+		on_channel =3D roc->on_channel;
 		ieee80211_roc_notify_destroy(roc, !roc->abort);
=20
-		if (started) {
+		if (started && !on_channel) {
 			ieee80211_flush_queues(local, NULL);
=20
 			local->tmp_channel =3D NULL;
diff --git a/net/mac80211/trace.h b/net/mac80211/trace.h
index a0b0aea76525..cec5b60487a4 100644
--- a/net/mac80211/trace.h
+++ b/net/mac80211/trace.h
@@ -21,10 +21,10 @@
=20
 #define VIF_ENTRY	__field(enum nl80211_iftype, vif_type) __field(void *, s=
data)	\
 			__field(bool, p2p)						\
-			__string(vif_name, sdata->dev ? sdata->dev->name : "<nodev>")
+			__string(vif_name, sdata->name)
 #define VIF_ASSIGN	__entry->vif_type =3D sdata->vif.type; __entry->sdata =
=3D sdata;	\
 			__entry->p2p =3D sdata->vif.p2p;					\
-			__assign_str(vif_name, sdata->dev ? sdata->dev->name : sdata->name)
+			__assign_str(vif_name, sdata->name)
 #define VIF_PR_FMT	" vif:%s(%d%s)"
 #define VIF_PR_ARG	__get_str(vif_name), __entry->vif_type, __entry->p2p ? =
"/p2p" : ""
=20
diff --git a/net/mac80211/vht.c b/net/mac80211/vht.c
index e9e36a256165..9265adfdabfc 100644
--- a/net/mac80211/vht.c
+++ b/net/mac80211/vht.c
@@ -129,9 +129,12 @@ ieee80211_vht_cap_ie_to_sta_vht_cap(struct ieee80211_s=
ub_if_data *sdata,
 	if (!vht_cap_ie || !sband->vht_cap.vht_supported)
 		return;
=20
-	/* A VHT STA must support 40 MHz */
-	if (!(sta->sta.ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40))
-		return;
+	/*
+	 * A VHT STA must support 40 MHz, but if we verify that here
+	 * then we break a few things - some APs (e.g. Netgear R6300v2
+	 * and others based on the BCM4360 chipset) will unset this
+	 * capability bit when operating in 20 MHz.
+	 */
=20
 	vht_cap->vht_supported =3D true;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Nq2Wo0NMKNjxTN9z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTdOEpAAoJEJctW/TcYTgGMcoP/jDSRzW8MszsoiR12xFvxt3i
XOtNHN0GMatK6ZDCSsdQcJhaSFw/xTFZdeQ6HvgARk9QaSNAI9AYIp6ESLxGs1pN
eiZjoFGSErMscSPwVoeQVJ8kcZx3BU7sDRMVcRRGs0z6wWM711QfEPPiPo8WuVN9
bMJboQGjlWu8FqKWWyP3xF56XFRbwUL9lnrclu89fo0inX9WNRKyPGxjKN+ufrLF
MiIw0a9ljFVr3qh9bVvB3jjtuLAKEtA5CgfwAXnrSvxX+Efr26BiPzH7XW6mxK5p
GeaeoJxmJ4y4UQVQHL/QKiGGMWNLuaMeORAnCzEkyuUzZkjR+bg0QIaijBGw5/PZ
39gnRsVOn8XCBoSU0sCm3l/Lzovo6VIkSEns38rAjNZ81A9xoJM4muqYZPyocWfJ
2qe5elYNeWTh9f5kRbErOyXMxaZ4ibayRuimIQGAtMiW9EO8qT+hQ5Y90WNRTw7r
AbXyhYpHj+nY5+8UPZTj5aNFUHlE1L/SSI+fYjE17buEjUsonZFvNRcINbeFhd/t
bKkp91NuUWHQcD0Ze+3Kv4GD7vGGVgCh8yfPSa8fVwQeI0QlSEvSVHPMHaKXiLSX
8GDZIDV5BRuglBEqTcCIw+VPLtyeikfzv1lxiCyyNV4tTYAfJV+grmjld/hkAr8V
pLhM3ritakHpwospHgjD
=UdMT
-----END PGP SIGNATURE-----

--Nq2Wo0NMKNjxTN9z--
