From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-03-03
Date: Mon, 3 Mar 2014 14:44:32 -0500
Message-ID: <20140303194432.GD26300@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59047 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239AbaCCTpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 14:45:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.14 stream...

For the mac80211 bits, Johannes says:

"This time I have a fix to get out of an 'infinite error state' in case
regulatory domain updates failed and two fixes for VHT associations: one
to not disconnect immediately when the AP uses more bandwidth than the
new regdomain would allow after a change due to association country
information getting used, and one for an issue in the code where
mac80211 doesn't correctly ignore a reserved field and then uses an HT
instead of VHT association."

For the iwlwifi bits, Emmanuel says:

"Johannes fixes a long standing bug in the AMPDU status reporting.
Max fixes the listen time which was way too long and causes trouble
to several APs."

Along with those, Bing Zhao marks the mwifiex_usb driver as _not_
supporting USB autosuspend after a number of problems with that have
been reported.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 635d61a3735e05c8da72740006670f819e5b6a5f:

  USB AX88179/178A: Support D-Link DUB-1312 (2014-03-02 20:29:30 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 0c6a4812a0e1879daa6c8ac88e566dbb85e1ea70:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-03-03 14:34:45 -0500)

----------------------------------------------------------------

Bing Zhao (1):
      mwifiex: do not advertise usb autosuspend support

Janusz Dziedzic (1):
      cfg80211: regulatory: reset regdomain in case of error

Johannes Berg (3):
      mac80211: don't validate unchanged AP bandwidth while tracking
      iwlwifi: fix TX status for aggregated packets
      mac80211: fix association to 20/40 MHz VHT networks

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fix=
es
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Max Stepanov (1):
      iwlwifi: mvm: change of listen interval from 70 to 10

 drivers/net/wireless/iwlwifi/dvm/tx.c  | 14 +++++++++-----
 drivers/net/wireless/iwlwifi/mvm/mvm.h |  2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c  | 18 +++++++++---------
 drivers/net/wireless/mwifiex/usb.c     |  8 --------
 net/mac80211/mlme.c                    | 23 +++++++++++++++++++++++
 net/wireless/reg.c                     | 10 +++++++++-
 6 files changed, 51 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/i=
wlwifi/dvm/tx.c
index a6839dfcb82d..398dd096674c 100644
--- a/drivers/net/wireless/iwlwifi/dvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
@@ -1291,8 +1291,6 @@ int iwlagn_rx_reply_compressed_ba(struct iwl_priv *pr=
iv,
 	struct iwl_compressed_ba_resp *ba_resp =3D (void *)pkt->data;
 	struct iwl_ht_agg *agg;
 	struct sk_buff_head reclaimed_skbs;
-	struct ieee80211_tx_info *info;
-	struct ieee80211_hdr *hdr;
 	struct sk_buff *skb;
 	int sta_id;
 	int tid;
@@ -1379,22 +1377,28 @@ int iwlagn_rx_reply_compressed_ba(struct iwl_priv *=
priv,
 	freed =3D 0;
=20
 	skb_queue_walk(&reclaimed_skbs, skb) {
-		hdr =3D (struct ieee80211_hdr *)skb->data;
+		struct ieee80211_hdr *hdr =3D (void *)skb->data;
+		struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
=20
 		if (ieee80211_is_data_qos(hdr->frame_control))
 			freed++;
 		else
 			WARN_ON_ONCE(1);
=20
-		info =3D IEEE80211_SKB_CB(skb);
 		iwl_trans_free_tx_cmd(priv->trans, info->driver_data[1]);
=20
+		memset(&info->status, 0, sizeof(info->status));
+		/* Packet was transmitted successfully, failures come as single
+		 * frames because before failing a frame the firmware transmits
+		 * it without aggregation at least once.
+		 */
+		info->flags |=3D IEEE80211_TX_STAT_ACK;
+
 		if (freed =3D=3D 1) {
 			/* this is the first skb we deliver in this batch */
 			/* put the rate scaling data there */
 			info =3D IEEE80211_SKB_CB(skb);
 			memset(&info->status, 0, sizeof(info->status));
-			info->flags |=3D IEEE80211_TX_STAT_ACK;
 			info->flags |=3D IEEE80211_TX_STAT_AMPDU;
 			info->status.ampdu_ack_len =3D ba_resp->txed_2_done;
 			info->status.ampdu_len =3D ba_resp->txed;
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/=
iwlwifi/mvm/mvm.h
index e4ead86f06d6..2b0ba1fc3c82 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -152,7 +152,7 @@ enum iwl_power_scheme {
 	IWL_POWER_SCHEME_LP
 };
=20
-#define IWL_CONN_MAX_LISTEN_INTERVAL	70
+#define IWL_CONN_MAX_LISTEN_INTERVAL	10
 #define IWL_UAPSD_AC_INFO		(IEEE80211_WMM_IE_STA_QOSINFO_AC_VO |\
 					 IEEE80211_WMM_IE_STA_QOSINFO_AC_VI |\
 					 IEEE80211_WMM_IE_STA_QOSINFO_AC_BK |\
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/i=
wlwifi/mvm/tx.c
index 4df12fa9d336..76ee486039d7 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -822,16 +822,12 @@ int iwl_mvm_rx_ba_notif(struct iwl_mvm *mvm, struct i=
wl_rx_cmd_buffer *rxb,
 	struct iwl_mvm_ba_notif *ba_notif =3D (void *)pkt->data;
 	struct sk_buff_head reclaimed_skbs;
 	struct iwl_mvm_tid_data *tid_data;
-	struct ieee80211_tx_info *info;
 	struct ieee80211_sta *sta;
 	struct iwl_mvm_sta *mvmsta;
-	struct ieee80211_hdr *hdr;
 	struct sk_buff *skb;
 	int sta_id, tid, freed;
-
 	/* "flow" corresponds to Tx queue */
 	u16 scd_flow =3D le16_to_cpu(ba_notif->scd_flow);
-
 	/* "ssn" is start of block-ack Tx window, corresponds to index
 	 * (in Tx queue's circular buffer) of first TFD/frame in window */
 	u16 ba_resp_scd_ssn =3D le16_to_cpu(ba_notif->scd_ssn);
@@ -888,22 +884,26 @@ int iwl_mvm_rx_ba_notif(struct iwl_mvm *mvm, struct i=
wl_rx_cmd_buffer *rxb,
 	freed =3D 0;
=20
 	skb_queue_walk(&reclaimed_skbs, skb) {
-		hdr =3D (struct ieee80211_hdr *)skb->data;
+		struct ieee80211_hdr *hdr =3D (void *)skb->data;
+		struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
=20
 		if (ieee80211_is_data_qos(hdr->frame_control))
 			freed++;
 		else
 			WARN_ON_ONCE(1);
=20
-		info =3D IEEE80211_SKB_CB(skb);
 		iwl_trans_free_tx_cmd(mvm->trans, info->driver_data[1]);
=20
+		memset(&info->status, 0, sizeof(info->status));
+		/* Packet was transmitted successfully, failures come as single
+		 * frames because before failing a frame the firmware transmits
+		 * it without aggregation at least once.
+		 */
+		info->flags |=3D IEEE80211_TX_STAT_ACK;
+
 		if (freed =3D=3D 1) {
 			/* this is the first skb we deliver in this batch */
 			/* put the rate scaling data there */
-			info =3D IEEE80211_SKB_CB(skb);
-			memset(&info->status, 0, sizeof(info->status));
-			info->flags |=3D IEEE80211_TX_STAT_ACK;
 			info->flags |=3D IEEE80211_TX_STAT_AMPDU;
 			info->status.ampdu_ack_len =3D ba_notif->txed_2_done;
 			info->status.ampdu_len =3D ba_notif->txed;
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwif=
iex/usb.c
index cb6b70a1b34d..208748804a55 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -525,13 +525,6 @@ static int mwifiex_usb_resume(struct usb_interface *in=
tf)
 						   MWIFIEX_BSS_ROLE_ANY),
 				  MWIFIEX_ASYNC_CMD);
=20
-#ifdef CONFIG_PM
-	/* Resume handler may be called due to remote wakeup,
-	 * force to exit suspend anyway
-	 */
-	usb_disable_autosuspend(card->udev);
-#endif /* CONFIG_PM */
-
 	return 0;
 }
=20
@@ -571,7 +564,6 @@ static struct usb_driver mwifiex_usb_driver =3D {
 	.id_table =3D mwifiex_usb_table,
 	.suspend =3D mwifiex_usb_suspend,
 	.resume =3D mwifiex_usb_resume,
-	.supports_autosuspend =3D 1,
 };
=20
 static int mwifiex_usb_tx_init(struct mwifiex_adapter *adapter)
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 57d5482b10fa..245dce969b31 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -222,6 +222,7 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_da=
ta *sdata,
 	switch (vht_oper->chan_width) {
 	case IEEE80211_VHT_CHANWIDTH_USE_HT:
 		vht_chandef.width =3D chandef->width;
+		vht_chandef.center_freq1 =3D chandef->center_freq1;
 		break;
 	case IEEE80211_VHT_CHANWIDTH_80MHZ:
 		vht_chandef.width =3D NL80211_CHAN_WIDTH_80;
@@ -271,6 +272,28 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_d=
ata *sdata,
 	ret =3D 0;
=20
 out:
+	/*
+	 * When tracking the current AP, don't do any further checks if the
+	 * new chandef is identical to the one we're currently using for the
+	 * connection. This keeps us from playing ping-pong with regulatory,
+	 * without it the following can happen (for example):
+	 *  - connect to an AP with 80 MHz, world regdom allows 80 MHz
+	 *  - AP advertises regdom US
+	 *  - CRDA loads regdom US with 80 MHz prohibited (old database)
+	 *  - the code below detects an unsupported channel, downgrades, and
+	 *    we disconnect from the AP in the caller
+	 *  - disconnect causes CRDA to reload world regdomain and the game
+	 *    starts anew.
+	 * (see https://bugzilla.kernel.org/show_bug.cgi?id=3D70881)
+	 *
+	 * It seems possible that there are still scenarios with CSA or real
+	 * bandwidth changes where a this could happen, but those cases are
+	 * less common and wouldn't completely prevent using the AP.
+	 */
+	if (tracking &&
+	    cfg80211_chandef_identical(chandef, &sdata->vif.bss_conf.chandef))
+		return ret;
+
 	/* don't print the message below for VHT mismatch if VHT is disabled */
 	if (ret & IEEE80211_STA_DISABLE_VHT)
 		vht_chandef =3D *chandef;
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 4c50c21d6f52..f0541370e68e 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2373,6 +2373,7 @@ static int reg_set_rd_country_ie(const struct ieee802=
11_regdomain *rd,
 int set_regdom(const struct ieee80211_regdomain *rd)
 {
 	struct regulatory_request *lr;
+	bool user_reset =3D false;
 	int r;
=20
 	if (!reg_is_valid_request(rd->alpha2)) {
@@ -2389,6 +2390,7 @@ int set_regdom(const struct ieee80211_regdomain *rd)
 		break;
 	case NL80211_REGDOM_SET_BY_USER:
 		r =3D reg_set_rd_user(rd, lr);
+		user_reset =3D true;
 		break;
 	case NL80211_REGDOM_SET_BY_DRIVER:
 		r =3D reg_set_rd_driver(rd, lr);
@@ -2402,8 +2404,14 @@ int set_regdom(const struct ieee80211_regdomain *rd)
 	}
=20
 	if (r) {
-		if (r =3D=3D -EALREADY)
+		switch (r) {
+		case -EALREADY:
 			reg_set_request_processed();
+			break;
+		default:
+			/* Back to world regulatory in case of errors */
+			restore_regulatory_settings(user_reset);
+		}
=20
 		kfree(rd);
 		return r;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFNugAAoJEJctW/TcYTgGBL4P/jmP/zpuuLLpQElKLDe+coxY
LNHEh7I98r2z5geRrvHHFbBzAvuRdUdEHqeln8exw3Sn6hqKjqsNyk/xTRQmrGua
Hdvz+2/HZewCylBfbpILDzg/B1+oXS2WejxnXF0+U5AiJJbcIt0WVJeAAETm0yEe
v6X66X8YvrziCop46m/XLMbnV/VTGUjzRpKCh7XSJfR6levfq2EuoC4e2DXV2r/r
zAq5fE0nK8fbcoet3ir/kpCecZeIRlez4k21N5jaAdLSqy8p+hVDoCEX5ze++tHX
G/HA5nvaviUofg2RHUWmSwk7Hd7n4/beQsJqZgvyrweWqKuLfcuDNXfbqvkd1qqM
tzTqOdK/o3vOAvyDAIL14F/ita1F1T/8P540vFhoxU/Kla9gvdrO35eyHUQy5w0W
KsHuZH8i2W7zg3TuRRBdYDhZcsQNyS/EhzJlqF81rSbvcHYTJ8Mcy8nQ6EP+ZeH0
gd0h339h7fFbmg4Gx2OMZQrRU34+scLURq0ljpzRN36VHrF2IWczltjJvCGN/gl9
2j9lYFpU4m+yAif7wwG2S5UTSh4ukSXNy7OFicb1lCiMBaL+bHUPoTzSDEMo+3Qg
0F7FyUKdp+vaJeCICMa6Cz0E6mEEpExU8EhkUFaRA+9WfKMwIwlCLrHerj6rdd0E
h209SV+t/J/jm0JfQOFt
=KHan
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
