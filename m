From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-12-15
Date: Thu, 15 Dec 2011 14:15:24 -0500
Message-ID: <20111215191523.GA2561@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 42a3b63bb2ca4996a3d1210a004eae2333f1119e

Dave,

Here are a few more fixes intended for the 3.2 release.  They are
all small and narrowly focused.

First is a one liner fix for a signedness problem in NFC that could
lead to an incorrect return code being propogated.  Next are two
iwlwifi regression fixes that received some recent attention on the
linux-wireless mailing list.  A third iwlwifi fix corrects a sequence
numbering error, which can cause a lot of bad behaviour in the wireless
network.  The ath9k fix corrects a potential for an array underrun.
Finally, the mwifiex fix corrects a double list deletion.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3f1e6d3fd37bd4f25e5b19f1c7ca21850426c33f:

  sch_gred: should not use GFP_KERNEL while holding a spinlock (2011-12-12 =
19:08:54 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Dan Carpenter (1):
      nfc: signedness bug in __nci_request()

Johannes Berg (1):
      iwlwifi: tx_sync only on PAN context

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Rajkumar Manoharan (1):
      ath9k: fix max phy rate at rate control init

Wey-Yi Guy (2):
      iwlwifi: do not set the sequence control bit is not needed
      iwlwifi: allow to switch to HT40 if not associated

Yogesh Ashok Powar (1):
      mwifiex: avoid double list_del in command cancel path

 drivers/net/wireless/ath/ath9k/rc.c         |    4 +++-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |    5 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 ++++++
 drivers/net/wireless/mwifiex/cmdevt.c       |    9 ++-------
 net/nfc/nci/core.c                          |    2 +-
 6 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath=
/ath9k/rc.c
index 888abc2..528d5f3 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1271,7 +1271,9 @@ static void ath_rc_init(struct ath_softc *sc,
=20
 	ath_rc_priv->max_valid_rate =3D k;
 	ath_rc_sort_validrates(rate_table, ath_rc_priv);
-	ath_rc_priv->rate_max_phy =3D ath_rc_priv->valid_rate_index[k-4];
+	ath_rc_priv->rate_max_phy =3D (k > 4) ?
+					ath_rc_priv->valid_rate_index[k-4] :
+					ath_rc_priv->valid_rate_index[k-1];
 	ath_rc_priv->rate_table =3D rate_table;
=20
 	ath_dbg(common, ATH_DBG_CONFIG,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wire=
less/iwlwifi/iwl-agn-rxon.c
index a7a6def..5c7c17c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -606,8 +606,8 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 chan=
ged)
 			if (ctx->ht.enabled) {
 				/* if HT40 is used, it should not change
 				 * after associated except channel switch */
-				if (iwl_is_associated_ctx(ctx) &&
-				     !ctx->ht.is_40mhz)
+				if (!ctx->ht.is_40mhz ||
+						!iwl_is_associated_ctx(ctx))
 					iwlagn_config_ht40(conf, ctx);
 			} else
 				ctx->ht.is_40mhz =3D false;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wirele=
ss/iwlwifi/iwl-agn-tx.c
index 35a6b71..df1540c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -91,7 +91,10 @@ static void iwlagn_tx_cmd_build_basic(struct iwl_priv *p=
riv,
 		tx_cmd->tid_tspec =3D qc[0] & 0xf;
 		tx_flags &=3D ~TX_CMD_FLG_SEQ_CTL_MSK;
 	} else {
-		tx_flags |=3D TX_CMD_FLG_SEQ_CTL_MSK;
+		if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ)
+			tx_flags |=3D TX_CMD_FLG_SEQ_CTL_MSK;
+		else
+			tx_flags &=3D ~TX_CMD_FLG_SEQ_CTL_MSK;
 	}
=20
 	iwlagn_tx_cmd_protection(priv, info, fc, &tx_flags);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/=
iwlwifi/iwl-agn.c
index bacc06c..e0e9a3d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2850,6 +2850,9 @@ static int iwlagn_mac_tx_sync(struct ieee80211_hw *hw,
 	int ret;
 	u8 sta_id;
=20
+	if (ctx->ctxid !=3D IWL_RXON_CTX_PAN)
+		return 0;
+
 	IWL_DEBUG_MAC80211(priv, "enter\n");
 	mutex_lock(&priv->shrd->mutex);
=20
@@ -2898,6 +2901,9 @@ static void iwlagn_mac_finish_tx_sync(struct ieee8021=
1_hw *hw,
 	struct iwl_vif_priv *vif_priv =3D (void *)vif->drv_priv;
 	struct iwl_rxon_context *ctx =3D vif_priv->ctx;
=20
+	if (ctx->ctxid !=3D IWL_RXON_CTX_PAN)
+		return;
+
 	IWL_DEBUG_MAC80211(priv, "enter\n");
 	mutex_lock(&priv->shrd->mutex);
=20
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index ac27815..6e0a3ea 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -939,7 +939,6 @@ mwifiex_cancel_pending_ioctl(struct mwifiex_adapter *ad=
apter)
 {
 	struct cmd_ctrl_node *cmd_node =3D NULL, *tmp_node =3D NULL;
 	unsigned long cmd_flags;
-	unsigned long cmd_pending_q_flags;
 	unsigned long scan_pending_q_flags;
 	uint16_t cancel_scan_cmd =3D false;
=20
@@ -949,12 +948,9 @@ mwifiex_cancel_pending_ioctl(struct mwifiex_adapter *a=
dapter)
 		cmd_node =3D adapter->curr_cmd;
 		cmd_node->wait_q_enabled =3D false;
 		cmd_node->cmd_flag |=3D CMD_F_CANCELED;
-		spin_lock_irqsave(&adapter->cmd_pending_q_lock,
-				  cmd_pending_q_flags);
-		list_del(&cmd_node->list);
-		spin_unlock_irqrestore(&adapter->cmd_pending_q_lock,
-				       cmd_pending_q_flags);
 		mwifiex_insert_cmd_to_free_q(adapter, cmd_node);
+		mwifiex_complete_cmd(adapter, adapter->curr_cmd);
+		adapter->curr_cmd =3D NULL;
 		spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, cmd_flags);
 	}
=20
@@ -981,7 +977,6 @@ mwifiex_cancel_pending_ioctl(struct mwifiex_adapter *ad=
apter)
 		spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, cmd_flags);
 	}
 	adapter->cmd_wait_q.status =3D -1;
-	mwifiex_complete_cmd(adapter, adapter->curr_cmd);
 }
=20
 /*
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 3925c65..ea66034 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -69,7 +69,7 @@ static int __nci_request(struct nci_dev *ndev,
 	__u32 timeout)
 {
 	int rc =3D 0;
-	unsigned long completion_rc;
+	long completion_rc;
=20
 	ndev->req_status =3D NCI_REQ_PEND;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO6kdLAAoJEJctW/TcYTgGR5YP/1NwMqJLk6CPo8ItrAyDkyvd
e5bi7bY96ybDWWtTMUKnFLOxE5sjv/7b15gzN418YoiivYhqoLvW+s52aop2/z68
rrmLc5j8R+GcnHzWfi9lIcNG2mnTRAr22vjCmMjyuWuZdQDVVp/zZ6Wx/PpbAVep
OkTFk9FEV5b111I+fZlzPVGlPgLNlX7Dk7jc4/fquKk+77nlQ2usdZwjwylPKrvH
iySxbdLdOKYGWLcdM0HlgLNJgLf19rnhYIhJuFKs2yZ++0yDLKb7hLmn8W1u6YIg
yTuviA7mLzHjah/sGMXOMzNJJuDiXOUisK5dGnf5e68g+MiZLmWuN50THmKoW/Hb
j2dzrqTFVDu5aNm13AT5yqPlhxC2td7Nu2y62gg4LE7Im+3kp6GJgSauFk3gBxnR
/GEN/ZiYJ19CiEZcDLFJX913pNry7Xk5Of8s81ILMKIpJw8Wbu4MHgyLE1FA8phJ
yLHaCcX0heA8fuFz2Ago21GV7ZStqOTHQU7ykH+CIu4vA4bFqMfTMzUuWKWSgEPo
evLiCPE9sDQ1NRJAKWQWZpGLM7yQuHDj4iCeetBT6jYsvDj+v2khe4/2QsJj/bWr
N/ANaxlGzlNSTXAoGee3gVblqWi7HPW9epH7iNP8Buwyw9eKY2RovM5gURb7pUxL
q3O2Ja+euyiBoshqQkm2
=paKK
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--
