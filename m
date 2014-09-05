From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2014-09-05
Date: Fri, 5 Sep 2014 11:04:53 -0400
Message-ID: <20140905150453.GB3454@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.17 stream...

For the mac80211 bits, Johannes says:

"Here are a few fixes for mac80211. One has been discussed for a while
and adds a terminating NUL-byte to the alpha2 sent to userspace, which
shouldn't be necessary but since many places treat it as a string we
couldn't move to just sending two bytes.

In addition to that, we have two VLAN fixes from Felix, a mesh fix, a
fix for the recently introduced RX aggregation offload, a revert for
a broken patch (that luckily didn't really cause any harm) and a small
fix for alignment in debugfs."

For the iwlwifi bits, Emmanuel says:

"I revert a patch that disabled CTS to self in dvm because users
reported issues. The revert is CCed to stable since the offending
patch was sent to stable too. I also bump the firmware API versions
since a new firmware is coming up. On top of that, Marcel fixes a
bug I introduced while fixing a bug in our Kconfig file."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c66517165610b911e4c6d268f28d8c640832dbd1:

  rtlwifi: rtl8192cu: Add new ID (2014-08-25 15:39:23 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-09-04

for you to fetch changes up to 1bd3fa7b8c9b2936c16c6e6452f9cc991c405872:

  Merge branch 'for-john' of git://git.kernel.org/pub/scm/linux/kernel/git/=
iwlwifi/iwlwifi-fixes (2014-09-04 13:12:02 -0400)

----------------------------------------------------------------

Bob Copeland (1):
      mac80211: mesh_plink: handle confirm frames with new plid

Denton Gentry (1):
      mac80211: fix start_seq_num in Rx reorder offload

Eliad Peller (1):
      regulatory: add NUL to alpha2

Emmanuel Grumbach (2):
      Revert "iwlwifi: dvm: don't enable CTS to self"
      iwlwifi: bump firmware API version to 10 for 7000 and 8000

Felix Fietkau (2):
      mac80211: ignore AP_VLAN in ieee80211_recalc_chanctx_chantype
      mac80211: fix smps mode check for AP_VLAN

Johannes Berg (2):
      Revert "mac80211: disable uAPSD if all ACs are under ACM"
      mac80211: fix agg_status debugfs file alignment

John W. Linville (2):
      Merge tag 'mac80211-for-john-2014-08-29' of git://git.kernel.org/.../=
jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes

Marcel Holtmann (1):
      iwlwifi: Remove module build requirement for Intel Wireless WiFi

 drivers/net/wireless/iwlwifi/Kconfig    |  2 --
 drivers/net/wireless/iwlwifi/dvm/rxon.c | 12 ++++++++++++
 drivers/net/wireless/iwlwifi/iwl-7000.c |  4 ++--
 drivers/net/wireless/iwlwifi/iwl-8000.c |  2 +-
 include/net/regulatory.h                |  2 +-
 net/mac80211/chan.c                     |  2 ++
 net/mac80211/debugfs_sta.c              |  2 +-
 net/mac80211/iface.c                    |  4 ++--
 net/mac80211/mesh_plink.c               |  7 ++++++-
 net/mac80211/mlme.c                     |  3 +--
 net/mac80211/sta_info.c                 |  7 +++++--
 11 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iw=
lwifi/Kconfig
index 6451d2b6abcf..824f5e287783 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -51,7 +51,6 @@ config IWLWIFI_LEDS
=20
 config IWLDVM
 	tristate "Intel Wireless WiFi DVM Firmware support"
-	depends on m
 	default IWLWIFI
 	help
 	  This is the driver that supports the DVM firmware which is
@@ -60,7 +59,6 @@ config IWLDVM
=20
 config IWLMVM
 	tristate "Intel Wireless WiFi MVM Firmware support"
-	depends on m
 	help
 	  This is the driver that supports the MVM firmware which is
 	  currently only available for 7260 and 3160 devices.
diff --git a/drivers/net/wireless/iwlwifi/dvm/rxon.c b/drivers/net/wireless=
/iwlwifi/dvm/rxon.c
index 6dc5dd3ced44..ed50de6362ed 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rxon.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rxon.c
@@ -1068,6 +1068,13 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct=
 iwl_rxon_context *ctx)
 	/* recalculate basic rates */
 	iwl_calc_basic_rates(priv, ctx);
=20
+	/*
+	 * force CTS-to-self frames protection if RTS-CTS is not preferred
+	 * one aggregation protection method
+	 */
+	if (!priv->hw_params.use_rts_for_aggregation)
+		ctx->staging.flags |=3D RXON_FLG_SELF_CTS_EN;
+
 	if ((ctx->vif && ctx->vif->bss_conf.use_short_slot) ||
 	    !(ctx->staging.flags & RXON_FLG_BAND_24G_MSK))
 		ctx->staging.flags |=3D RXON_FLG_SHORT_SLOT_MSK;
@@ -1473,6 +1480,11 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
 	else
 		ctx->staging.flags &=3D ~RXON_FLG_TGG_PROTECT_MSK;
=20
+	if (bss_conf->use_cts_prot)
+		ctx->staging.flags |=3D RXON_FLG_SELF_CTS_EN;
+	else
+		ctx->staging.flags &=3D ~RXON_FLG_SELF_CTS_EN;
+
 	memcpy(ctx->staging.bssid_addr, bss_conf->bssid, ETH_ALEN);
=20
 	if (vif->type =3D=3D NL80211_IFTYPE_AP ||
diff --git a/drivers/net/wireless/iwlwifi/iwl-7000.c b/drivers/net/wireless=
/iwlwifi/iwl-7000.c
index 48730064da73..d67a37a786aa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-7000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-7000.c
@@ -67,8 +67,8 @@
 #include "iwl-agn-hw.h"
=20
 /* Highest firmware API version supported */
-#define IWL7260_UCODE_API_MAX	9
-#define IWL3160_UCODE_API_MAX	9
+#define IWL7260_UCODE_API_MAX	10
+#define IWL3160_UCODE_API_MAX	10
=20
 /* Oldest version we won't warn about */
 #define IWL7260_UCODE_API_OK	9
diff --git a/drivers/net/wireless/iwlwifi/iwl-8000.c b/drivers/net/wireless=
/iwlwifi/iwl-8000.c
index 44b19e015102..e93c6972290b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-8000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-8000.c
@@ -67,7 +67,7 @@
 #include "iwl-agn-hw.h"
=20
 /* Highest firmware API version supported */
-#define IWL8000_UCODE_API_MAX	9
+#define IWL8000_UCODE_API_MAX	10
=20
 /* Oldest version we won't warn about */
 #define IWL8000_UCODE_API_OK	8
diff --git a/include/net/regulatory.h b/include/net/regulatory.h
index 259992444e80..dad7ab20a8cb 100644
--- a/include/net/regulatory.h
+++ b/include/net/regulatory.h
@@ -167,7 +167,7 @@ struct ieee80211_reg_rule {
 struct ieee80211_regdomain {
 	struct rcu_head rcu_head;
 	u32 n_reg_rules;
-	char alpha2[2];
+	char alpha2[3];
 	enum nl80211_dfs_regions dfs_region;
 	struct ieee80211_reg_rule reg_rules[];
 };
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index 0375009ddc0d..399ad82c997f 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -541,6 +541,8 @@ static void ieee80211_recalc_chanctx_chantype(struct ie=
ee80211_local *local,
 			continue;
 		if (rcu_access_pointer(sdata->vif.chanctx_conf) !=3D conf)
 			continue;
+		if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+			continue;
=20
 		if (!compat)
 			compat =3D &sdata->vif.bss_conf.chandef;
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index 3db96648b45a..86173c0de40e 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -167,7 +167,7 @@ static ssize_t sta_agg_status_read(struct file *file, c=
har __user *userbuf,
 	p +=3D scnprintf(p, sizeof(buf) + buf - p, "next dialog_token: %#02x\n",
 			sta->ampdu_mlme.dialog_token_allocator + 1);
 	p +=3D scnprintf(p, sizeof(buf) + buf - p,
-		       "TID\t\tRX active\tDTKN\tSSN\t\tTX\tDTKN\tpending\n");
+		       "TID\t\tRX\tDTKN\tSSN\t\tTX\tDTKN\tpending\n");
=20
 	for (i =3D 0; i < IEEE80211_NUM_TIDS; i++) {
 		tid_rx =3D rcu_dereference(sta->ampdu_mlme.tid_rx[i]);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 01eede7406a5..f75e5f132c5a 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1175,8 +1175,8 @@ static void ieee80211_iface_work(struct work_struct *=
work)
 			if (sta) {
 				u16 last_seq;
=20
-				last_seq =3D le16_to_cpu(
-					sta->last_seq_ctrl[rx_agg->tid]);
+				last_seq =3D IEEE80211_SEQ_TO_SN(le16_to_cpu(
+					sta->last_seq_ctrl[rx_agg->tid]));
=20
 				__ieee80211_start_rx_ba_session(sta,
 						0, 0,
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 63b874101b27..c47194d27149 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -959,7 +959,8 @@ mesh_plink_get_event(struct ieee80211_sub_if_data *sdat=
a,
 		if (!matches_local)
 			event =3D CNF_RJCT;
 		if (!mesh_plink_free_count(sdata) ||
-		    (sta->llid !=3D llid || sta->plid !=3D plid))
+		    sta->llid !=3D llid ||
+		    (sta->plid && sta->plid !=3D plid))
 			event =3D CNF_IGNR;
 		else
 			event =3D CNF_ACPT;
@@ -1080,6 +1081,10 @@ mesh_process_plink_frame(struct ieee80211_sub_if_dat=
a *sdata,
 		goto unlock_rcu;
 	}
=20
+	/* 802.11-2012 13.3.7.2 - update plid on CNF if not set */
+	if (!sta->plid && event =3D=3D CNF_ACPT)
+		sta->plid =3D plid;
+
 	changed |=3D mesh_plink_fsm(sdata, sta, event);
=20
 unlock_rcu:
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 31a8afaf7332..b82a12a9f0f1 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -4376,8 +4376,7 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data =
*sdata,
 	rcu_read_unlock();
=20
 	if (bss->wmm_used && bss->uapsd_supported &&
-	    (sdata->local->hw.flags & IEEE80211_HW_SUPPORTS_UAPSD) &&
-	    sdata->wmm_acm !=3D 0xff) {
+	    (sdata->local->hw.flags & IEEE80211_HW_SUPPORTS_UAPSD)) {
 		assoc_data->uapsd =3D true;
 		ifmgd->flags |=3D IEEE80211_STA_UAPSD_ENABLED;
 	} else {
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index c6ee2139fbc5..441875f03750 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1094,8 +1094,11 @@ void ieee80211_sta_ps_deliver_wakeup(struct sta_info=
 *sta)
 	unsigned long flags;
 	struct ps_data *ps;
=20
-	if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP ||
-	    sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+	if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN)
+		sdata =3D container_of(sdata->bss, struct ieee80211_sub_if_data,
+				     u.ap);
+
+	if (sdata->vif.type =3D=3D NL80211_IFTYPE_AP)
 		ps =3D &sdata->bss->ps;
 	else if (ieee80211_vif_is_mesh(&sdata->vif))
 		ps =3D &sdata->u.mesh.ps;
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUCdEVAAoJEJctW/TcYTgG8Q4P/iilQ3IwOQpW0QRqXdk4ZxPe
lmHCc1XJHkR5KZSK5llsmf7Rr+kgpDCf9JHt9qIJCS+yD96l2p8LmTSbwGn87VI2
uS399TrDnTyxdm9iQt3KVT98ZdvbCWzx09nENLYEShZ6c2bt8VOcFnmCqm2ZflXD
hYhisDie5wvGKkYGZ1JgIYN0vBToEi0qAGgFUNgC/xhpBEWNiGS9PS2fRJx3L7td
K+oX691/88fTq3DtFCvA0TfDmvFD4RjmYjlx+TQeRL4vFiDxziwWqAfqibMx1GC1
ePtQAB3CY0Cp4SM0jA/HRuahmDuASpNA+AI3xTlpfXsr17wi8zEeiQMrVjplIUjI
QUTEN80Fc3K5Xj0xx4nDx64BiZgBznZKdqrtSPp8SZhGuCf9pxC+S+F1jtoemQey
XNNS4mUZYYdFPJi7RvPQ8pjkLNxi7WZ3YF0q/SoI4mseAqwFBp3L3lBKR71R/OV7
kgGzkrj4vNSDvK+3009WNxwb1Axv7WqeYPyRh77uHTGuRNkPOcYw4fKGAqAZm2CY
MV1U8OTKPCyr18fQxDxx2F0UAwaDWDLNHLt9v5HMC+jOvZqB0vTvexxwiEgU1Zoa
dbX9jjFM1ue/HNMQlnFlQtXNtScrsolNs+KT+apEIMamw7ONzxYxmove0vY4QgV8
KOwbzem3qmcefWWfwx1y
=FTE9
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
