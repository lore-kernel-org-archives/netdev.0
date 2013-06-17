From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-06-17
Date: Mon, 17 Jun 2013 14:27:20 -0400
Message-ID: <20130617182719.GC2104@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tThc/1wpZn/ma/RB"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This will probably be the last batch of wireless fixes intended
for 3.10.  Many of these are one- or two-liners, and a couple of
others are mostly relocating existing code to avoid races or to
limit the code to effecting specific hardware, etc.

The mac80211 fixes have a couple of exceptions to the above.
Regarding those, Johannes says:

"Following davem's complaint about my patch, here's a new pull request
w/o the patch he was complaining about, but instead with the const
fix rolled into the fix.

I have a fix for radar detection, one for rate control and a workaround
for broken HT APs which is a regression fix because we didn't rely
on them to be correct before."

Johannes also sends some iwlwifi fixes:

"I picked up Nikolay's patch for the chain noise calibration bug
that seems to have been there forever, a fix from Emmanuel for
setting TX flags on BAR frames and a fix of my own to avoid printing
request_module() errors if the kernel isn't even modular. We also
have our own version of Stanislaw's fix for rate control."

Along with those...

Anderson Lizardo fixes a Bluetooth memory corruption bug when an MTU
value is set to too small of a value.

Arend van Spriel sends a revised brcmsmac bug that fixes a regression
caused by a bad return value in an earlier patch.  He also sends a
brcmfmac fix to avoid an oops when loading the driver at boot.

Daniel Drake fixes a race condition in btmrvl that causes hangs on
suspend for OLPC hardware.

Johan Hedberg adds a check to avoid sending a
HCI_Delete_Stored_Link_Key command to devices that don't support them,
avoiding some scary looking log spam.

Stanislaw Gruszka gives us a fix for iwlegacy to be able to use rates
higher than 1Mb/s on older wireless networks.  He also sends an rt2x00
fix to reinstate older tx power handling behavior for some devices
that didn't work well with the current code.

Please let me know if there are problems!  If you don't want to
pull this batch for 3.10, then I will go ahead and pull them into
wireless-next...

John

---

The following changes since commit 8177a9d79c0e942dcac3312f15585d0344d505a5:

  lseek(fd, n, SEEK_END) does *not* go to eof - n (2013-06-16 08:10:53 -100=
0)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 722a300bf84ebebe21da164e75024c0ce7ca1868:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-06-17 13:44:01 -0400)

----------------------------------------------------------------

Anderson Lizardo (1):
      Bluetooth: Fix crash in l2cap_build_cmd() with small MTU

Arend van Spriel (2):
      brcmsmac: disable power-save related functions
      brcmfmac: free primary net_device when brcmf_bus_start() fails

Daniel Drake (1):
      Bluetooth: btmrvl: fix thread stopping race

Emmanuel Grumbach (1):
      iwlwifi: mvm: correctly set the flags for BAR

Johan Hedberg (1):
      Bluetooth: Fix conditions for HCI_Delete_Stored_Link_Key

Johannes Berg (2):
      iwlwifi: don't print module loading error if not modular
      mac80211: work around broken APs not including HT info

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Moshe Benji (1):
      iwlwifi: fix rate control regression

Nikolay Martynov (1):
      iwlwifi: dvm: fix chain noise calibration

Simon Wunderlich (2):
      mac80211: abort CAC in stop_ap()
      mac80211: Fix rate control mask matching call

Stanislaw Gruszka (2):
      iwlegacy: fix rate control regression
      rt2800: fix RT5390 & RT3290 TX power settings regression

 drivers/bluetooth/btmrvl_main.c                    |  9 +--
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  4 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     | 17 +----
 drivers/net/wireless/iwlegacy/3945-rs.c            |  1 +
 drivers/net/wireless/iwlegacy/4965-rs.c            |  2 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |  2 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |  2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  2 +
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  1 +
 drivers/net/wireless/iwlwifi/mvm/tx.c              |  3 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            | 29 +++++---
 net/bluetooth/hci_core.c                           | 15 ++--
 net/bluetooth/l2cap_core.c                         |  3 +
 net/mac80211/cfg.c                                 |  6 ++
 net/mac80211/ieee80211_i.h                         |  5 +-
 net/mac80211/mlme.c                                | 87 ++++++++++++++++++=
++--
 net/mac80211/rate.c                                |  2 +-
 net/mac80211/util.c                                |  4 +-
 18 files changed, 142 insertions(+), 52 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_mai=
n.c
index 3a4343b..9a9f518 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -498,6 +498,10 @@ static int btmrvl_service_main_thread(void *data)
 		add_wait_queue(&thread->wait_q, &wait);
=20
 		set_current_state(TASK_INTERRUPTIBLE);
+		if (kthread_should_stop()) {
+			BT_DBG("main_thread: break from main thread");
+			break;
+		}
=20
 		if (adapter->wakeup_tries ||
 				((!adapter->int_count) &&
@@ -513,11 +517,6 @@ static int btmrvl_service_main_thread(void *data)
=20
 		BT_DBG("main_thread woke up");
=20
-		if (kthread_should_stop()) {
-			BT_DBG("main_thread: break from main thread");
-			break;
-		}
-
 		spin_lock_irqsave(&priv->driver_lock, flags);
 		if (adapter->int_count) {
 			adapter->int_count =3D 0;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/=
net/wireless/brcm80211/brcmfmac/dhd_linux.c
index b98f223..2c59357 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -930,6 +930,10 @@ fail:
 			brcmf_fws_del_interface(ifp);
 			brcmf_fws_deinit(drvr);
 		}
+		if (drvr->iflist[0]) {
+			free_netdev(ifp->ndev);
+			drvr->iflist[0] =3D NULL;
+		}
 		if (p2p_ifp) {
 			free_netdev(p2p_ifp->ndev);
 			drvr->iflist[1] =3D NULL;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index 28e7aee..9fd6f2f 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -3074,21 +3074,8 @@ static void brcms_b_antsel_set(struct brcms_hardware=
 *wlc_hw, u32 antsel_avail)
  */
 static bool brcms_c_ps_allowed(struct brcms_c_info *wlc)
 {
-	/* disallow PS when one of the following global conditions meets */
-	if (!wlc->pub->associated)
-		return false;
-
-	/* disallow PS when one of these meets when not scanning */
-	if (wlc->filter_flags & FIF_PROMISC_IN_BSS)
-		return false;
-
-	if (wlc->bsscfg->type =3D=3D BRCMS_TYPE_AP)
-		return false;
-
-	if (wlc->bsscfg->type =3D=3D BRCMS_TYPE_ADHOC)
-		return false;
-
-	return true;
+	/* not supporting PS so always return false for now */
+	return false;
 }
=20
 static void brcms_c_statsupd(struct brcms_c_info *wlc)
diff --git a/drivers/net/wireless/iwlegacy/3945-rs.c b/drivers/net/wireless=
/iwlegacy/3945-rs.c
index c9f197d..fe31590 100644
--- a/drivers/net/wireless/iwlegacy/3945-rs.c
+++ b/drivers/net/wireless/iwlegacy/3945-rs.c
@@ -816,6 +816,7 @@ out:
 		rs_sta->last_txrate_idx =3D idx;
 		info->control.rates[0].idx =3D rs_sta->last_txrate_idx;
 	}
+	info->control.rates[0].count =3D 1;
=20
 	D_RATE("leave: %d\n", idx);
 }
diff --git a/drivers/net/wireless/iwlegacy/4965-rs.c b/drivers/net/wireless=
/iwlegacy/4965-rs.c
index 1fc0b22..ed3c42a 100644
--- a/drivers/net/wireless/iwlegacy/4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/4965-rs.c
@@ -2268,7 +2268,7 @@ il4965_rs_get_rate(void *il_r, struct ieee80211_sta *=
sta, void *il_sta,
 		info->control.rates[0].flags =3D 0;
 	}
 	info->control.rates[0].idx =3D rate_idx;
-
+	info->control.rates[0].count =3D 1;
 }
=20
 static void *
diff --git a/drivers/net/wireless/iwlwifi/dvm/rs.c b/drivers/net/wireless/i=
wlwifi/dvm/rs.c
index 907bd6e..10fbb17 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rs.c
@@ -2799,7 +2799,7 @@ static void rs_get_rate(void *priv_r, struct ieee8021=
1_sta *sta, void *priv_sta,
 		info->control.rates[0].flags =3D 0;
 	}
 	info->control.rates[0].idx =3D rate_idx;
-
+	info->control.rates[0].count =3D 1;
 }
=20
 static void *rs_alloc_sta(void *priv_rate, struct ieee80211_sta *sta,
diff --git a/drivers/net/wireless/iwlwifi/dvm/rxon.c b/drivers/net/wireless=
/iwlwifi/dvm/rxon.c
index 707446f..cd1ad001 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rxon.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rxon.c
@@ -1378,7 +1378,7 @@ static void iwlagn_chain_noise_reset(struct iwl_priv =
*priv)
 	struct iwl_chain_noise_data *data =3D &priv->chain_noise_data;
 	int ret;
=20
-	if (!(priv->calib_disabled & IWL_CHAIN_NOISE_CALIB_DISABLED))
+	if (priv->calib_disabled & IWL_CHAIN_NOISE_CALIB_DISABLED)
 		return;
=20
 	if ((data->state =3D=3D IWL_CHAIN_NOISE_ALIVE) &&
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/=
iwlwifi/iwl-drv.c
index 39aad98..40fed1f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/iwlwifi/iwl-drv.c
@@ -1000,10 +1000,12 @@ static void iwl_req_fw_callback(const struct firmwa=
re *ucode_raw, void *context)
 	 */
 	if (load_module) {
 		err =3D request_module("%s", op->name);
+#ifdef CONFIG_IWLWIFI_OPMODE_MODULAR
 		if (err)
 			IWL_ERR(drv,
 				"failed to load module %s (error %d), is dynamic loading enabled?\n",
 				op->name, err);
+#endif
 	}
 	return;
=20
diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.c b/drivers/net/wireless/i=
wlwifi/mvm/rs.c
index 55334d5..b99fe31 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rs.c
@@ -2546,6 +2546,7 @@ static void rs_get_rate(void *mvm_r, struct ieee80211=
_sta *sta, void *mvm_sta,
 		info->control.rates[0].flags =3D 0;
 	}
 	info->control.rates[0].idx =3D rate_idx;
+	info->control.rates[0].count =3D 1;
 }
=20
 static void *rs_alloc_sta(void *mvm_rate, struct ieee80211_sta *sta,
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index f212f16..48c1891 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -180,7 +180,8 @@ static void iwl_mvm_set_tx_cmd_rate(struct iwl_mvm *mvm,
 		tx_cmd->tx_flags |=3D cpu_to_le32(TX_CMD_FLG_STA_RATE);
 		return;
 	} else if (ieee80211_is_back_req(fc)) {
-		tx_cmd->tx_flags |=3D cpu_to_le32(TX_CMD_FLG_STA_RATE);
+		tx_cmd->tx_flags |=3D
+			cpu_to_le32(TX_CMD_FLG_ACK | TX_CMD_FLG_BAR);
 	}
=20
 	/* HT rate doesn't make sense for a non data frame */
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index b52d70c..72f32e5 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -3027,19 +3027,26 @@ static void rt2800_config_txpower(struct rt2x00_dev=
 *rt2x00dev,
 	 * TODO: we do not use +6 dBm option to do not increase power beyond
 	 * regulatory limit, however this could be utilized for devices with
 	 * CAPABILITY_POWER_LIMIT.
+	 *
+	 * TODO: add different temperature compensation code for RT3290 & RT5390
+	 * to allow to use BBP_R1 for those chips.
 	 */
-	rt2800_bbp_read(rt2x00dev, 1, &r1);
-	if (delta <=3D -12) {
-		power_ctrl =3D 2;
-		delta +=3D 12;
-	} else if (delta <=3D -6) {
-		power_ctrl =3D 1;
-		delta +=3D 6;
-	} else {
-		power_ctrl =3D 0;
+	if (!rt2x00_rt(rt2x00dev, RT3290) &&
+	    !rt2x00_rt(rt2x00dev, RT5390)) {
+		rt2800_bbp_read(rt2x00dev, 1, &r1);
+		if (delta <=3D -12) {
+			power_ctrl =3D 2;
+			delta +=3D 12;
+		} else if (delta <=3D -6) {
+			power_ctrl =3D 1;
+			delta +=3D 6;
+		} else {
+			power_ctrl =3D 0;
+		}
+		rt2x00_set_field8(&r1, BBP1_TX_POWER_CTRL, power_ctrl);
+		rt2800_bbp_write(rt2x00dev, 1, r1);
 	}
-	rt2x00_set_field8(&r1, BBP1_TX_POWER_CTRL, power_ctrl);
-	rt2800_bbp_write(rt2x00dev, 1, r1);
+
 	offset =3D TX_PWR_CFG_0;
=20
 	for (i =3D 0; i < EEPROM_TXPOWER_BYRATE_SIZE; i +=3D 2) {
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index d817c93..ace5e55 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -341,7 +341,6 @@ static void hci_init1_req(struct hci_request *req, unsi=
gned long opt)
=20
 static void bredr_setup(struct hci_request *req)
 {
-	struct hci_cp_delete_stored_link_key cp;
 	__le16 param;
 	__u8 flt_type;
=20
@@ -365,10 +364,6 @@ static void bredr_setup(struct hci_request *req)
 	param =3D __constant_cpu_to_le16(0x7d00);
 	hci_req_add(req, HCI_OP_WRITE_CA_TIMEOUT, 2, &param);
=20
-	bacpy(&cp.bdaddr, BDADDR_ANY);
-	cp.delete_all =3D 0x01;
-	hci_req_add(req, HCI_OP_DELETE_STORED_LINK_KEY, sizeof(cp), &cp);
-
 	/* Read page scan parameters */
 	if (req->hdev->hci_ver > BLUETOOTH_VER_1_1) {
 		hci_req_add(req, HCI_OP_READ_PAGE_SCAN_ACTIVITY, 0, NULL);
@@ -602,6 +597,16 @@ static void hci_init3_req(struct hci_request *req, uns=
igned long opt)
 	struct hci_dev *hdev =3D req->hdev;
 	u8 p;
=20
+	/* Only send HCI_Delete_Stored_Link_Key if it is supported */
+	if (hdev->commands[6] & 0x80) {
+		struct hci_cp_delete_stored_link_key cp;
+
+		bacpy(&cp.bdaddr, BDADDR_ANY);
+		cp.delete_all =3D 0x01;
+		hci_req_add(req, HCI_OP_DELETE_STORED_LINK_KEY,
+			    sizeof(cp), &cp);
+	}
+
 	if (hdev->commands[5] & 0x10)
 		hci_setup_link_policy(req);
=20
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 24bee07..4be6a26 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2852,6 +2852,9 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_c=
onn *conn, u8 code,
 	BT_DBG("conn %p, code 0x%2.2x, ident 0x%2.2x, len %u",
 	       conn, code, ident, dlen);
=20
+	if (conn->mtu < L2CAP_HDR_SIZE + L2CAP_CMD_HDR_SIZE)
+		return NULL;
+
 	len =3D L2CAP_HDR_SIZE + L2CAP_CMD_HDR_SIZE + dlen;
 	count =3D min_t(unsigned int, conn->mtu, len);
=20
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 1a89c80..4fdb306e 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1057,6 +1057,12 @@ static int ieee80211_stop_ap(struct wiphy *wiphy, st=
ruct net_device *dev)
 	clear_bit(SDATA_STATE_OFFCHANNEL_BEACON_STOPPED, &sdata->state);
 	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BEACON_ENABLED);
=20
+	if (sdata->wdev.cac_started) {
+		cancel_delayed_work_sync(&sdata->dfs_cac_timer_work);
+		cfg80211_cac_event(sdata->dev, NL80211_RADAR_CAC_ABORTED,
+				   GFP_KERNEL);
+	}
+
 	drv_stop_ap(sdata->local, sdata);
=20
 	/* free all potentially still buffered bcast frames */
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 44be28c..9ca8e32 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1497,10 +1497,11 @@ static inline void ieee80211_tx_skb(struct ieee8021=
1_sub_if_data *sdata,
 	ieee80211_tx_skb_tid(sdata, skb, 7);
 }
=20
-u32 ieee802_11_parse_elems_crc(u8 *start, size_t len, bool action,
+u32 ieee802_11_parse_elems_crc(const u8 *start, size_t len, bool action,
 			       struct ieee802_11_elems *elems,
 			       u64 filter, u32 crc);
-static inline void ieee802_11_parse_elems(u8 *start, size_t len, bool acti=
on,
+static inline void ieee802_11_parse_elems(const u8 *start, size_t len,
+					  bool action,
 					  struct ieee802_11_elems *elems)
 {
 	ieee802_11_parse_elems_crc(start, len, action, elems, 0, 0);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a8c2130..741448b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2522,8 +2522,11 @@ static bool ieee80211_assoc_success(struct ieee80211=
_sub_if_data *sdata,
 	u16 capab_info, aid;
 	struct ieee802_11_elems elems;
 	struct ieee80211_bss_conf *bss_conf =3D &sdata->vif.bss_conf;
+	const struct cfg80211_bss_ies *bss_ies =3D NULL;
+	struct ieee80211_mgd_assoc_data *assoc_data =3D ifmgd->assoc_data;
 	u32 changed =3D 0;
 	int err;
+	bool ret;
=20
 	/* AssocResp and ReassocResp have identical structure */
=20
@@ -2555,21 +2558,86 @@ static bool ieee80211_assoc_success(struct ieee8021=
1_sub_if_data *sdata,
 	ifmgd->aid =3D aid;
=20
 	/*
+	 * Some APs are erroneously not including some information in their
+	 * (re)association response frames. Try to recover by using the data
+	 * from the beacon or probe response. This seems to afflict mobile
+	 * 2G/3G/4G wifi routers, reported models include the "Onda PN51T",
+	 * "Vodafone PocketWiFi 2", "ZTE MF60" and a similar T-Mobile device.
+	 */
+	if ((assoc_data->wmm && !elems.wmm_param) ||
+	    (!(ifmgd->flags & IEEE80211_STA_DISABLE_HT) &&
+	     (!elems.ht_cap_elem || !elems.ht_operation)) ||
+	    (!(ifmgd->flags & IEEE80211_STA_DISABLE_VHT) &&
+	     (!elems.vht_cap_elem || !elems.vht_operation))) {
+		const struct cfg80211_bss_ies *ies;
+		struct ieee802_11_elems bss_elems;
+
+		rcu_read_lock();
+		ies =3D rcu_dereference(cbss->ies);
+		if (ies)
+			bss_ies =3D kmemdup(ies, sizeof(*ies) + ies->len,
+					  GFP_ATOMIC);
+		rcu_read_unlock();
+		if (!bss_ies)
+			return false;
+
+		ieee802_11_parse_elems(bss_ies->data, bss_ies->len,
+				       false, &bss_elems);
+		if (assoc_data->wmm &&
+		    !elems.wmm_param && bss_elems.wmm_param) {
+			elems.wmm_param =3D bss_elems.wmm_param;
+			sdata_info(sdata,
+				   "AP bug: WMM param missing from AssocResp\n");
+		}
+
+		/*
+		 * Also check if we requested HT/VHT, otherwise the AP doesn't
+		 * have to include the IEs in the (re)association response.
+		 */
+		if (!elems.ht_cap_elem && bss_elems.ht_cap_elem &&
+		    !(ifmgd->flags & IEEE80211_STA_DISABLE_HT)) {
+			elems.ht_cap_elem =3D bss_elems.ht_cap_elem;
+			sdata_info(sdata,
+				   "AP bug: HT capability missing from AssocResp\n");
+		}
+		if (!elems.ht_operation && bss_elems.ht_operation &&
+		    !(ifmgd->flags & IEEE80211_STA_DISABLE_HT)) {
+			elems.ht_operation =3D bss_elems.ht_operation;
+			sdata_info(sdata,
+				   "AP bug: HT operation missing from AssocResp\n");
+		}
+		if (!elems.vht_cap_elem && bss_elems.vht_cap_elem &&
+		    !(ifmgd->flags & IEEE80211_STA_DISABLE_VHT)) {
+			elems.vht_cap_elem =3D bss_elems.vht_cap_elem;
+			sdata_info(sdata,
+				   "AP bug: VHT capa missing from AssocResp\n");
+		}
+		if (!elems.vht_operation && bss_elems.vht_operation &&
+		    !(ifmgd->flags & IEEE80211_STA_DISABLE_VHT)) {
+			elems.vht_operation =3D bss_elems.vht_operation;
+			sdata_info(sdata,
+				   "AP bug: VHT operation missing from AssocResp\n");
+		}
+	}
+
+	/*
 	 * We previously checked these in the beacon/probe response, so
 	 * they should be present here. This is just a safety net.
 	 */
 	if (!(ifmgd->flags & IEEE80211_STA_DISABLE_HT) &&
 	    (!elems.wmm_param || !elems.ht_cap_elem || !elems.ht_operation)) {
 		sdata_info(sdata,
-			   "HT AP is missing WMM params or HT capability/operation in AssocResp=
\n");
-		return false;
+			   "HT AP is missing WMM params or HT capability/operation\n");
+		ret =3D false;
+		goto out;
 	}
=20
 	if (!(ifmgd->flags & IEEE80211_STA_DISABLE_VHT) &&
 	    (!elems.vht_cap_elem || !elems.vht_operation)) {
 		sdata_info(sdata,
-			   "VHT AP is missing VHT capability/operation in AssocResp\n");
-		return false;
+			   "VHT AP is missing VHT capability/operation\n");
+		ret =3D false;
+		goto out;
 	}
=20
 	mutex_lock(&sdata->local->sta_mtx);
@@ -2580,7 +2648,8 @@ static bool ieee80211_assoc_success(struct ieee80211_=
sub_if_data *sdata,
 	sta =3D sta_info_get(sdata, cbss->bssid);
 	if (WARN_ON(!sta)) {
 		mutex_unlock(&sdata->local->sta_mtx);
-		return false;
+		ret =3D false;
+		goto out;
 	}
=20
 	sband =3D local->hw.wiphy->bands[ieee80211_get_sdata_band(sdata)];
@@ -2633,7 +2702,8 @@ static bool ieee80211_assoc_success(struct ieee80211_=
sub_if_data *sdata,
 			   sta->sta.addr);
 		WARN_ON(__sta_info_destroy(sta));
 		mutex_unlock(&sdata->local->sta_mtx);
-		return false;
+		ret =3D false;
+		goto out;
 	}
=20
 	mutex_unlock(&sdata->local->sta_mtx);
@@ -2673,7 +2743,10 @@ static bool ieee80211_assoc_success(struct ieee80211=
_sub_if_data *sdata,
 	ieee80211_sta_rx_notify(sdata, (struct ieee80211_hdr *)mgmt);
 	ieee80211_sta_reset_beacon_monitor(sdata);
=20
-	return true;
+	ret =3D true;
+ out:
+	kfree(bss_ies);
+	return ret;
 }
=20
 static enum rx_mgmt_action __must_check
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index d3f414f..a02bef3 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -615,7 +615,7 @@ static void rate_control_apply_mask(struct ieee80211_su=
b_if_data *sdata,
 		if (rates[i].idx < 0)
 			break;
=20
-		rate_idx_match_mask(&rates[i], sband, mask, chan_width,
+		rate_idx_match_mask(&rates[i], sband, chan_width, mask,
 				    mcs_mask);
 	}
 }
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 27e0715..72e6292 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -661,12 +661,12 @@ void ieee80211_queue_delayed_work(struct ieee80211_hw=
 *hw,
 }
 EXPORT_SYMBOL(ieee80211_queue_delayed_work);
=20
-u32 ieee802_11_parse_elems_crc(u8 *start, size_t len, bool action,
+u32 ieee802_11_parse_elems_crc(const u8 *start, size_t len, bool action,
 			       struct ieee802_11_elems *elems,
 			       u64 filter, u32 crc)
 {
 	size_t left =3D len;
-	u8 *pos =3D start;
+	const u8 *pos =3D start;
 	bool calc_crc =3D filter !=3D 0;
 	DECLARE_BITMAP(seen_elems, 256);
 	const u8 *ie;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--tThc/1wpZn/ma/RB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRv1UHAAoJEJctW/TcYTgGvsIP/iHrOp64FpxxbRqq4AMHy+D3
6xq1hOm11KOfzwTPUhv74mXwRCsNBHSpZxv3Cjx/DbJXQ2O0gR0x1Chphdqmou48
V67OvOwFVR5pVwAOT/tbhRlAmWh5BXwdWQOzVkNFNffO15SouSSteGPk8D//SADG
2wTUi3EttBA4EMO0HXz3ovmikpOpCLAQ0cX27gJy6f/EEsU4H541vHpQ6iZ6VSkN
U0mDd9+s0sTOm4NVTihEtbc1BKcqUQ0KqSffrh4ymChXLPPQQ94JgQJs3MoH8MNX
wpZXFfp6CuSvxdUJUhdy/A9LtCn0RXfIUB879WUDFbDXZHLXQB7ayFF+Oc18fpvZ
/CPzm8kyqwzX6S8a0Kjkbl8AYaKjuPQ83FLgYRx4hvsWB0gmLv57qXYC2lRFoPr0
I8gSzQ3zh91BzNNMatMoXVnCVPEocJwGBrXI5CKyUNrpFg/OQH8mgstyKD6FtNV0
DSOdxfk/NKCSCmt42GLFNB3m/6P/vzyiJcA9gBDfuhWppJwhpodPi/zHta149dL6
PCyk85AFTitu7j/2cac1N1czELL6taZj05g6Y6eBhzyemVZguog8BNfYkMujDb/5
4o+qZrvSOnNCA+u/vdUrlKaqLWpHx4g+SKzmcolNTp5L/HvtXK1ryTRXPvK9AvpH
GWiVK5dNtbQIx0wwTBPl
=OXrs
-----END PGP SIGNATURE-----

--tThc/1wpZn/ma/RB--
