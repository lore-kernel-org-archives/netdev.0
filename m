From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-10-19
Date: Fri, 19 Oct 2012 17:14:10 -0400
Message-ID: <20121019211410.GC2208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="U+BazGySraz5kW0T"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--U+BazGySraz5kW0T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 06f40a41b80e25e88a2b612ea3b2a94f93c94f72

Dave,

This is a batch of fixes intended for the 3.7 stream.

Dan Carpenter brings a fix for a simple signedness bug that could
prevent the proper termination of a loop.

Felix Fietkau found a few more places that need to use
ieee80211_free_txskb for properly releasing SKBs used by mac80211.

Franky Lin offers a pair of brcmfmac fixes, both fixing simple state
reporting errors.

Hante Meuleman corrects an error reporting case that wasn't handling
all types of errors properly.

Johan Hedberg offers a fix for an issue discovered at the Bluetooth
UnPlug Fest.  Gustavo says "the patch fixes a failure to pair with
devices that support the LE Secure Connections feature."

Johannes Berg sends an iwlwifi fix to handle a message type that
is too large for the normal command mechanism.  He also provides a
mac80211 fix to use HT20 channels when HT40 channels are not permitted.

Jouni Malinen offers a mac80211 fix for a masking error that was
incorrectly marking some frames.

Piotr Haber provides a fix to make sure bcma devices are unregistered
properly.

Stanislav Yakovlev gives us a fix for a panic in the ipw2200 driver.

Stanislaw Gruszka sends a pair of fixes: one prevents a mismatch on
connection states between cfg80211 and mac80211; the other prevents
some frame corruption related to handling encryption.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit db0fe0b2f6bba2fda939737d063db2ae14c58d71:

  Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-mer=
ge (2012-10-18 15:36:59 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 06f40a41b80e25e88a2b612ea3b2a94f93c94f72:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-10-19 13:55:42 -0400)

----------------------------------------------------------------

Dan Carpenter (1):
      brcmfmac: fix end of loop check (signedness bug)

Felix Fietkau (1):
      mac80211: use ieee80211_free_txskb in a few more places

Franky Lin (2):
      brcmfmac: use control channel in roamed status reporting
      brcmfmac: set dongle mode accordingly when interface up

Hante Meuleman (1):
      brcmfmac: handle all exceptions as an error.

Johan Hedberg (1):
      Bluetooth: SMP: Fix setting unknown auth_req bits

Johannes Berg (3):
      Merge remote-tracking branch 'wireless/master' into mac80211
      iwlwifi: fix 6000 series channel switch command
      mac80211: connect with HT20 if HT40 is not permitted

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jouni Malinen (1):
      mac80211: Fix FC masking in BIP AAD generation

Piotr Haber (1):
      bcma: fix unregistration of cores

Stanislav Yakovlev (1):
      net/wireless: ipw2200: Fix panic occurring in ipw_handle_promiscuous_=
tx()

Stanislaw Gruszka (2):
      cfg80211/mac80211: avoid state mishmash on deauth
      mac80211: check if key has TKIP type before updating IV

 drivers/bcma/main.c                                |  5 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  2 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 68 ++++++++----------=
----
 drivers/net/wireless/ipw2x00/ipw2200.c             |  2 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         | 39 ++++++++-----
 include/net/cfg80211.h                             |  1 +
 net/bluetooth/smp.c                                |  6 +-
 net/mac80211/iface.c                               |  2 +-
 net/mac80211/mlme.c                                | 35 +++++++----
 net/mac80211/sta_info.c                            |  4 +-
 net/mac80211/util.c                                |  4 +-
 net/mac80211/wpa.c                                 | 14 +++--
 net/wireless/mlme.c                                | 12 +---
 13 files changed, 99 insertions(+), 95 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 432aeee..d865470 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -158,9 +158,10 @@ static int bcma_register_cores(struct bcma_bus *bus)
=20
 static void bcma_unregister_cores(struct bcma_bus *bus)
 {
-	struct bcma_device *core;
+	struct bcma_device *core, *tmp;
=20
-	list_for_each_entry(core, &bus->cores, list) {
+	list_for_each_entry_safe(core, tmp, &bus->cores, list) {
+		list_del(&core->list);
 		if (core->dev_registered)
 			device_unregister(&core->dev);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index a2b4b1e..7a6dfdc 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -1339,7 +1339,7 @@ static int brcmf_usb_probe_cb(struct brcmf_usbdev_inf=
o *devinfo,
 	}
=20
 	ret =3D brcmf_bus_start(dev);
-	if (ret =3D=3D -ENOLINK) {
+	if (ret) {
 		brcmf_dbg(ERROR, "dongle is not responding\n");
 		brcmf_detach(dev);
 		goto fail;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index c1abaa6..411dfe7 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -3972,7 +3972,7 @@ brcmf_set_management_ie(struct brcmf_cfg80211_info *c=
fg,
 	u8  *iovar_ie_buf;
 	u8  *curr_ie_buf;
 	u8  *mgmt_ie_buf =3D NULL;
-	u32 mgmt_ie_buf_len =3D 0;
+	int mgmt_ie_buf_len;
 	u32 *mgmt_ie_len =3D 0;
 	u32 del_add_ie_buf_len =3D 0;
 	u32 total_ie_buf_len =3D 0;
@@ -3982,7 +3982,7 @@ brcmf_set_management_ie(struct brcmf_cfg80211_info *c=
fg,
 	struct parsed_vndr_ie_info *vndrie_info;
 	s32 i;
 	u8 *ptr;
-	u32 remained_buf_len;
+	int remained_buf_len;
=20
 	WL_TRACE("bssidx %d, pktflag : 0x%02X\n", bssidx, pktflag);
 	iovar_ie_buf =3D kzalloc(WL_EXTRA_BUF_MAX, GFP_KERNEL);
@@ -4606,12 +4606,13 @@ brcmf_bss_roaming_done(struct brcmf_cfg80211_info *=
cfg,
 	struct brcmf_cfg80211_profile *profile =3D cfg->profile;
 	struct brcmf_cfg80211_connect_info *conn_info =3D cfg_to_conn(cfg);
 	struct wiphy *wiphy =3D cfg_to_wiphy(cfg);
-	struct brcmf_channel_info_le channel_le;
-	struct ieee80211_channel *notify_channel;
+	struct ieee80211_channel *notify_channel =3D NULL;
 	struct ieee80211_supported_band *band;
+	struct brcmf_bss_info_le *bi;
 	u32 freq;
 	s32 err =3D 0;
 	u32 target_channel;
+	u8 *buf;
=20
 	WL_TRACE("Enter\n");
=20
@@ -4619,11 +4620,22 @@ brcmf_bss_roaming_done(struct brcmf_cfg80211_info *=
cfg,
 	memcpy(profile->bssid, e->addr, ETH_ALEN);
 	brcmf_update_bss_info(cfg);
=20
-	brcmf_exec_dcmd(ndev, BRCMF_C_GET_CHANNEL, &channel_le,
-			sizeof(channel_le));
+	buf =3D kzalloc(WL_BSS_INFO_MAX, GFP_KERNEL);
+	if (buf =3D=3D NULL) {
+		err =3D -ENOMEM;
+		goto done;
+	}
+
+	/* data sent to dongle has to be little endian */
+	*(__le32 *)buf =3D cpu_to_le32(WL_BSS_INFO_MAX);
+	err =3D brcmf_exec_dcmd(ndev, BRCMF_C_GET_BSS_INFO, buf, WL_BSS_INFO_MAX);
+
+	if (err)
+		goto done;
=20
-	target_channel =3D le32_to_cpu(channel_le.target_channel);
-	WL_CONN("Roamed to channel %d\n", target_channel);
+	bi =3D (struct brcmf_bss_info_le *)(buf + 4);
+	target_channel =3D bi->ctl_ch ? bi->ctl_ch :
+				      CHSPEC_CHANNEL(le16_to_cpu(bi->chanspec));
=20
 	if (target_channel <=3D CH_MAX_2G_CHANNEL)
 		band =3D wiphy->bands[IEEE80211_BAND_2GHZ];
@@ -4633,6 +4645,8 @@ brcmf_bss_roaming_done(struct brcmf_cfg80211_info *cf=
g,
 	freq =3D ieee80211_channel_to_frequency(target_channel, band->band);
 	notify_channel =3D ieee80211_get_channel(wiphy, freq);
=20
+done:
+	kfree(buf);
 	cfg80211_roamed(ndev, notify_channel, (u8 *)profile->bssid,
 			conn_info->req_ie, conn_info->req_ie_len,
 			conn_info->resp_ie, conn_info->resp_ie_len, GFP_KERNEL);
@@ -5186,41 +5200,6 @@ brcmf_cfg80211_event(struct net_device *ndev,
 		schedule_work(&cfg->event_work);
 }
=20
-static s32 brcmf_dongle_mode(struct net_device *ndev, s32 iftype)
-{
-	s32 infra =3D 0;
-	s32 err =3D 0;
-
-	switch (iftype) {
-	case NL80211_IFTYPE_MONITOR:
-	case NL80211_IFTYPE_WDS:
-		WL_ERR("type (%d) : currently we do not support this mode\n",
-		       iftype);
-		err =3D -EINVAL;
-		return err;
-	case NL80211_IFTYPE_ADHOC:
-		infra =3D 0;
-		break;
-	case NL80211_IFTYPE_STATION:
-		infra =3D 1;
-		break;
-	case NL80211_IFTYPE_AP:
-		infra =3D 1;
-		break;
-	default:
-		err =3D -EINVAL;
-		WL_ERR("invalid type (%d)\n", iftype);
-		return err;
-	}
-	err =3D brcmf_exec_dcmd_u32(ndev, BRCMF_C_SET_INFRA, &infra);
-	if (err) {
-		WL_ERR("WLC_SET_INFRA error (%d)\n", err);
-		return err;
-	}
-
-	return 0;
-}
-
 static s32 brcmf_dongle_eventmsg(struct net_device *ndev)
 {
 	/* Room for "event_msgs" + '\0' + bitvec */
@@ -5439,7 +5418,8 @@ static s32 brcmf_config_dongle(struct brcmf_cfg80211_=
info *cfg)
 				WL_BEACON_TIMEOUT);
 	if (err)
 		goto default_conf_out;
-	err =3D brcmf_dongle_mode(ndev, wdev->iftype);
+	err =3D brcmf_cfg80211_change_iface(wdev->wiphy, ndev, wdev->iftype,
+					  NULL, NULL);
 	if (err && err !=3D -EINPROGRESS)
 		goto default_conf_out;
 	err =3D brcmf_dongle_probecap(cfg);
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/=
ipw2x00/ipw2200.c
index 935120f..768bf61 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -10472,7 +10472,7 @@ static void ipw_handle_promiscuous_tx(struct ipw_pr=
iv *priv,
 		} else
 			len =3D src->len;
=20
-		dst =3D alloc_skb(len + sizeof(*rt_hdr), GFP_ATOMIC);
+		dst =3D alloc_skb(len + sizeof(*rt_hdr) + sizeof(u16)*2, GFP_ATOMIC);
 		if (!dst)
 			continue;
=20
diff --git a/drivers/net/wireless/iwlwifi/dvm/devices.c b/drivers/net/wirel=
ess/iwlwifi/dvm/devices.c
index 349c205..da58620 100644
--- a/drivers/net/wireless/iwlwifi/dvm/devices.c
+++ b/drivers/net/wireless/iwlwifi/dvm/devices.c
@@ -518,7 +518,7 @@ static int iwl6000_hw_channel_switch(struct iwl_priv *p=
riv,
 	 * See iwlagn_mac_channel_switch.
 	 */
 	struct iwl_rxon_context *ctx =3D &priv->contexts[IWL_RXON_CTX_BSS];
-	struct iwl6000_channel_switch_cmd cmd;
+	struct iwl6000_channel_switch_cmd *cmd;
 	u32 switch_time_in_usec, ucode_switch_time;
 	u16 ch;
 	u32 tsf_low;
@@ -527,18 +527,25 @@ static int iwl6000_hw_channel_switch(struct iwl_priv =
*priv,
 	struct ieee80211_vif *vif =3D ctx->vif;
 	struct iwl_host_cmd hcmd =3D {
 		.id =3D REPLY_CHANNEL_SWITCH,
-		.len =3D { sizeof(cmd), },
+		.len =3D { sizeof(*cmd), },
 		.flags =3D CMD_SYNC,
-		.data =3D { &cmd, },
+		.dataflags[0] =3D IWL_HCMD_DFL_NOCOPY,
 	};
+	int err;
=20
-	cmd.band =3D priv->band =3D=3D IEEE80211_BAND_2GHZ;
+	cmd =3D kzalloc(sizeof(*cmd), GFP_KERNEL);
+	if (!cmd)
+		return -ENOMEM;
+
+	hcmd.data[0] =3D cmd;
+
+	cmd->band =3D priv->band =3D=3D IEEE80211_BAND_2GHZ;
 	ch =3D ch_switch->channel->hw_value;
 	IWL_DEBUG_11H(priv, "channel switch from %u to %u\n",
 		      ctx->active.channel, ch);
-	cmd.channel =3D cpu_to_le16(ch);
-	cmd.rxon_flags =3D ctx->staging.flags;
-	cmd.rxon_filter_flags =3D ctx->staging.filter_flags;
+	cmd->channel =3D cpu_to_le16(ch);
+	cmd->rxon_flags =3D ctx->staging.flags;
+	cmd->rxon_filter_flags =3D ctx->staging.filter_flags;
 	switch_count =3D ch_switch->count;
 	tsf_low =3D ch_switch->timestamp & 0x0ffffffff;
 	/*
@@ -554,23 +561,25 @@ static int iwl6000_hw_channel_switch(struct iwl_priv =
*priv,
 			switch_count =3D 0;
 	}
 	if (switch_count <=3D 1)
-		cmd.switch_time =3D cpu_to_le32(priv->ucode_beacon_time);
+		cmd->switch_time =3D cpu_to_le32(priv->ucode_beacon_time);
 	else {
 		switch_time_in_usec =3D
 			vif->bss_conf.beacon_int * switch_count * TIME_UNIT;
 		ucode_switch_time =3D iwl_usecs_to_beacons(priv,
 							 switch_time_in_usec,
 							 beacon_interval);
-		cmd.switch_time =3D iwl_add_beacon_time(priv,
-						      priv->ucode_beacon_time,
-						      ucode_switch_time,
-						      beacon_interval);
+		cmd->switch_time =3D iwl_add_beacon_time(priv,
+						       priv->ucode_beacon_time,
+						       ucode_switch_time,
+						       beacon_interval);
 	}
 	IWL_DEBUG_11H(priv, "uCode time for the switch is 0x%x\n",
-		      cmd.switch_time);
-	cmd.expect_beacon =3D ch_switch->channel->flags & IEEE80211_CHAN_RADAR;
+		      cmd->switch_time);
+	cmd->expect_beacon =3D ch_switch->channel->flags & IEEE80211_CHAN_RADAR;
=20
-	return iwl_dvm_send_cmd(priv, &hcmd);
+	err =3D iwl_dvm_send_cmd(priv, &hcmd);
+	kfree(cmd);
+	return err;
 }
=20
 struct iwl_lib_ops iwl6000_lib =3D {
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 1b49890..f8cd4cf 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1218,6 +1218,7 @@ struct cfg80211_deauth_request {
 	const u8 *ie;
 	size_t ie_len;
 	u16 reason_code;
+	bool local_state_change;
 };
=20
 /**
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 8c225ef..2ac8d50 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -32,6 +32,8 @@
=20
 #define SMP_TIMEOUT	msecs_to_jiffies(30000)
=20
+#define AUTH_REQ_MASK   0x07
+
 static inline void swap128(u8 src[16], u8 dst[16])
 {
 	int i;
@@ -230,7 +232,7 @@ static void build_pairing_cmd(struct l2cap_conn *conn,
 		req->max_key_size =3D SMP_MAX_ENC_KEY_SIZE;
 		req->init_key_dist =3D 0;
 		req->resp_key_dist =3D dist_keys;
-		req->auth_req =3D authreq;
+		req->auth_req =3D (authreq & AUTH_REQ_MASK);
 		return;
 	}
=20
@@ -239,7 +241,7 @@ static void build_pairing_cmd(struct l2cap_conn *conn,
 	rsp->max_key_size =3D SMP_MAX_ENC_KEY_SIZE;
 	rsp->init_key_dist =3D 0;
 	rsp->resp_key_dist =3D req->resp_key_dist & dist_keys;
-	rsp->auth_req =3D authreq;
+	rsp->auth_req =3D (authreq & AUTH_REQ_MASK);
 }
=20
 static u8 check_enc_key_size(struct l2cap_conn *conn, __u8 max_key_size)
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 6f8a73c..7de7717 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -853,7 +853,7 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_d=
ata *sdata,
 			struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
 			if (info->control.vif =3D=3D &sdata->vif) {
 				__skb_unlink(skb, &local->pending[i]);
-				dev_kfree_skb_irq(skb);
+				ieee80211_free_txskb(&local->hw, skb);
 			}
 		}
 	}
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e714ed8..1b7eed2 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3099,22 +3099,32 @@ static int ieee80211_prep_channel(struct ieee80211_=
sub_if_data *sdata,
 				   ht_cfreq, ht_oper->primary_chan,
 				   cbss->channel->band);
 			ht_oper =3D NULL;
+		} else {
+			channel_type =3D NL80211_CHAN_HT20;
 		}
 	}
=20
-	if (ht_oper) {
-		channel_type =3D NL80211_CHAN_HT20;
+	if (ht_oper && sband->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40) {
+		/*
+		 * cfg80211 already verified that the channel itself can
+		 * be used, but it didn't check that we can do the right
+		 * HT type, so do that here as well. If HT40 isn't allowed
+		 * on this channel, disable 40 MHz operation.
+		 */
=20
-		if (sband->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40) {
-			switch (ht_oper->ht_param &
-					IEEE80211_HT_PARAM_CHA_SEC_OFFSET) {
-			case IEEE80211_HT_PARAM_CHA_SEC_ABOVE:
+		switch (ht_oper->ht_param & IEEE80211_HT_PARAM_CHA_SEC_OFFSET) {
+		case IEEE80211_HT_PARAM_CHA_SEC_ABOVE:
+			if (cbss->channel->flags & IEEE80211_CHAN_NO_HT40PLUS)
+				ifmgd->flags |=3D IEEE80211_STA_DISABLE_40MHZ;
+			else
 				channel_type =3D NL80211_CHAN_HT40PLUS;
-				break;
-			case IEEE80211_HT_PARAM_CHA_SEC_BELOW:
+			break;
+		case IEEE80211_HT_PARAM_CHA_SEC_BELOW:
+			if (cbss->channel->flags & IEEE80211_CHAN_NO_HT40MINUS)
+				ifmgd->flags |=3D IEEE80211_STA_DISABLE_40MHZ;
+			else
 				channel_type =3D NL80211_CHAN_HT40MINUS;
-				break;
-			}
+			break;
 		}
 	}
=20
@@ -3549,6 +3559,7 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data=
 *sdata,
 {
 	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
 	u8 frame_buf[IEEE80211_DEAUTH_FRAME_LEN];
+	bool tx =3D !req->local_state_change;
=20
 	mutex_lock(&ifmgd->mtx);
=20
@@ -3565,12 +3576,12 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_da=
ta *sdata,
 	if (ifmgd->associated &&
 	    ether_addr_equal(ifmgd->associated->bssid, req->bssid)) {
 		ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DEAUTH,
-				       req->reason_code, true, frame_buf);
+				       req->reason_code, tx, frame_buf);
 	} else {
 		drv_mgd_prepare_tx(sdata->local, sdata);
 		ieee80211_send_deauth_disassoc(sdata, req->bssid,
 					       IEEE80211_STYPE_DEAUTH,
-					       req->reason_code, true,
+					       req->reason_code, tx,
 					       frame_buf);
 	}
=20
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 797dd36..0a4e4c0 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -650,7 +650,7 @@ static bool sta_info_cleanup_expire_buffered_ac(struct =
ieee80211_local *local,
 		 */
 		if (!skb)
 			break;
-		dev_kfree_skb(skb);
+		ieee80211_free_txskb(&local->hw, skb);
 	}
=20
 	/*
@@ -679,7 +679,7 @@ static bool sta_info_cleanup_expire_buffered_ac(struct =
ieee80211_local *local,
 		local->total_ps_buffered--;
 		ps_dbg(sta->sdata, "Buffered frame expired (STA %pM)\n",
 		       sta->sta.addr);
-		dev_kfree_skb(skb);
+		ieee80211_free_txskb(&local->hw, skb);
 	}
=20
 	/*
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 22ca350..94e5868 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -406,7 +406,7 @@ void ieee80211_add_pending_skb(struct ieee80211_local *=
local,
 	int queue =3D info->hw_queue;
=20
 	if (WARN_ON(!info->control.vif)) {
-		kfree_skb(skb);
+		ieee80211_free_txskb(&local->hw, skb);
 		return;
 	}
=20
@@ -431,7 +431,7 @@ void ieee80211_add_pending_skbs_fn(struct ieee80211_loc=
al *local,
 		struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
=20
 		if (WARN_ON(!info->control.vif)) {
-			kfree_skb(skb);
+			ieee80211_free_txskb(&local->hw, skb);
 			continue;
 		}
=20
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index bdb53ab..8bd2f5c 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -106,7 +106,8 @@ ieee80211_rx_h_michael_mic_verify(struct ieee80211_rx_d=
ata *rx)
 		if (status->flag & RX_FLAG_MMIC_ERROR)
 			goto mic_fail;
=20
-		if (!(status->flag & RX_FLAG_IV_STRIPPED) && rx->key)
+		if (!(status->flag & RX_FLAG_IV_STRIPPED) && rx->key &&
+		    rx->key->conf.cipher =3D=3D WLAN_CIPHER_SUITE_TKIP)
 			goto update_iv;
=20
 		return RX_CONTINUE;
@@ -545,14 +546,19 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_dat=
a *rx)
=20
 static void bip_aad(struct sk_buff *skb, u8 *aad)
 {
+	__le16 mask_fc;
+	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
+
 	/* BIP AAD: FC(masked) || A1 || A2 || A3 */
=20
 	/* FC type/subtype */
-	aad[0] =3D skb->data[0];
 	/* Mask FC Retry, PwrMgt, MoreData flags to zero */
-	aad[1] =3D skb->data[1] & ~(BIT(4) | BIT(5) | BIT(6));
+	mask_fc =3D hdr->frame_control;
+	mask_fc &=3D ~cpu_to_le16(IEEE80211_FCTL_RETRY | IEEE80211_FCTL_PM |
+				IEEE80211_FCTL_MOREDATA);
+	put_unaligned(mask_fc, (__le16 *) &aad[0]);
 	/* A1 || A2 || A3 */
-	memcpy(aad + 2, skb->data + 4, 3 * ETH_ALEN);
+	memcpy(aad + 2, &hdr->addr1, 3 * ETH_ALEN);
 }
=20
=20
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 8016fee..904a7f3 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -457,20 +457,14 @@ int __cfg80211_mlme_deauth(struct cfg80211_registered=
_device *rdev,
 		.reason_code =3D reason,
 		.ie =3D ie,
 		.ie_len =3D ie_len,
+		.local_state_change =3D local_state_change,
 	};
=20
 	ASSERT_WDEV_LOCK(wdev);
=20
-	if (local_state_change) {
-		if (wdev->current_bss &&
-		    ether_addr_equal(wdev->current_bss->pub.bssid, bssid)) {
-			cfg80211_unhold_bss(wdev->current_bss);
-			cfg80211_put_bss(&wdev->current_bss->pub);
-			wdev->current_bss =3D NULL;
-		}
-
+	if (local_state_change && (!wdev->current_bss ||
+	    !ether_addr_equal(wdev->current_bss->pub.bssid, bssid)))
 		return 0;
-	}
=20
 	return rdev->ops->deauth(&rdev->wiphy, dev, &req);
 }
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--U+BazGySraz5kW0T
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQgcKiAAoJEJctW/TcYTgGq0YP/3ZGuTjNZHW0TCTRRufA+C+T
WgVcexwMxbyXcqW5Nv2PT+J0ZBYG11vqQAKAZKA7i+7tIed7mI0O/yzNEpdozXRK
9PmchYxWbZk3wxsqZOvKwGjoS4eo53elgeIwjpaF0dmnwjEGT9pfdr67YKIdSpem
9cRl1COLYs/WrvFNvvNxYmtfv0RT9J1iJbuqTh3V6CnP+Zi5JQ4OTddBkxpbGt90
Mp9bZlNBrIhXh34ewUJfl4aFEo0vDbqgdpmYgU7s7JK3+txiA685IEei7Er2nf1a
D9feiTXTqQ1W/9zT1GNdlqvFAq8+ipaHUiAnxH2fzdYrOEU5I9/KMYb5PgQjoLNo
Xg5zZWjyv5Wb44AouWyskS+otigcv6VqOW0gg7k3kBkbHTs/TY8bto9UPWTg4Tcz
hFIKG3KePFoOvhMjSuS5VXLcrd5+vK8tWC6eo6vkjDujcI9hQPnBXM+1S/f6zrWK
PZeBuF4PnFINjl9P8F1WOlphOUd64YMmQCxQ2PkHxLnidNtbUvihi/Laz8k+6+Pm
M/ew/XMeGHSezoH7KJdUXmWBfzXlSVZeBQ1k401VvbPuAo1z4M85OiDzn5+SizRD
HFU1BZ2jm/f6SW/xwn3cGYosAwkTLbXtNSqcU+/mKBeTb5JCsvXUREmRrejgqLq5
Y9D6o2NwovDBH9XiKd2G
=0BDy
-----END PGP SIGNATURE-----

--U+BazGySraz5kW0T--
