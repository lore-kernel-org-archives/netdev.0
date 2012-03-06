From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-03-06
Date: Tue, 6 Mar 2012 15:15:28 -0500
Message-ID: <20120306201528.GC3353@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0OAP2g/MAC+5xKAE"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 7f466cff75f16ac545f34c7876e6f80225a36a6d

Dave,

Here are a few more squeakers hoping for 3.3...

Two of them are for carl9170: a one-line fix for a memory accounting
leak; and a fix that corrects the handling of frames with a couple of
status flags set by mac80211 (enabling delivery to sleeping stations).
Also included is a one-liner for mwifiex that should have been included
in "mwifiex: clear previous security setting during association".
Finally, a one-line fix from Johannes Berg for an iwlwifi regression
brings-up the rear.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5cb917bc4f3882ecee87064483111023086757d3:

  tg3: Fix to use multi queue BQL interfaces (2012-03-06 01:19:08 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Amitkumar Karwar (1):
      mwifiex: reset encryption mode flag before association

Christian Lamparter (1):
      carl9170: fix frame delivery if sta is in powersave mode

Johannes Berg (1):
      iwlwifi: fix wowlan suspend

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Nicolas Cavallari (1):
      carl9170: Fix memory accounting when sta is in power-save mode.

 drivers/net/wireless/ath/carl9170/tx.c     |    9 ++++++---
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c    |    1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/=
ath/carl9170/tx.c
index d19a9ee..bbc813d 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -1234,6 +1234,7 @@ static bool carl9170_tx_ps_drop(struct ar9170 *ar, st=
ruct sk_buff *skb)
 {
 	struct ieee80211_sta *sta;
 	struct carl9170_sta_info *sta_info;
+	struct ieee80211_tx_info *tx_info;
=20
 	rcu_read_lock();
 	sta =3D __carl9170_get_tx_sta(ar, skb);
@@ -1241,16 +1242,18 @@ static bool carl9170_tx_ps_drop(struct ar9170 *ar, =
struct sk_buff *skb)
 		goto out_rcu;
=20
 	sta_info =3D (void *) sta->drv_priv;
-	if (unlikely(sta_info->sleeping)) {
-		struct ieee80211_tx_info *tx_info;
+	tx_info =3D IEEE80211_SKB_CB(skb);
=20
+	if (unlikely(sta_info->sleeping) &&
+	    !(tx_info->flags & (IEEE80211_TX_CTL_POLL_RESPONSE |
+				IEEE80211_TX_CTL_CLEAR_PS_FILT))) {
 		rcu_read_unlock();
=20
-		tx_info =3D IEEE80211_SKB_CB(skb);
 		if (tx_info->flags & IEEE80211_TX_CTL_AMPDU)
 			atomic_dec(&ar->tx_ampdu_upload);
=20
 		tx_info->flags |=3D IEEE80211_TX_STAT_TX_FILTERED;
+		carl9170_release_dev_space(ar, skb);
 		carl9170_tx_status(ar, skb, false);
 		return true;
 	}
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wirel=
ess/iwlwifi/iwl-agn-lib.c
index 64cf439..ca78e91 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1240,7 +1240,7 @@ int iwlagn_suspend(struct iwl_priv *priv,
 				.flags =3D CMD_SYNC,
 				.data[0] =3D key_data.rsc_tsc,
 				.dataflags[0] =3D IWL_HCMD_DFL_NOCOPY,
-				.len[0] =3D sizeof(key_data.rsc_tsc),
+				.len[0] =3D sizeof(*key_data.rsc_tsc),
 			};
=20
 			ret =3D iwl_trans_send_cmd(trans(priv), &rsc_tsc_cmd);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index 5b2972b..2210a0f 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -846,6 +846,7 @@ mwifiex_cfg80211_assoc(struct mwifiex_private *priv, si=
ze_t ssid_len, u8 *ssid,
 	priv->sec_info.wpa_enabled =3D false;
 	priv->sec_info.wpa2_enabled =3D false;
 	priv->wep_key_curr_index =3D 0;
+	priv->sec_info.encryption_mode =3D 0;
 	ret =3D mwifiex_set_encode(priv, NULL, 0, 0, 1);
=20
 	if (mode =3D=3D NL80211_IFTYPE_ADHOC) {
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--0OAP2g/MAC+5xKAE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPVnBgAAoJEJctW/TcYTgGv0sP/3FZMpNXM4i5CXMsuxIj7rFM
okuAB3Ba1GlJoYWtFM8Phs2Wx/ePVrlEFPsilhfjvN+hyF9vLLWgJzYMU5+tlxAJ
mwXGnVZtHDM3x4LVQXcQLec7uz5l/BJj/bFCA1/E/z/YnXxFaBgiBAEZn9VURqqi
oAuDt0nSFauJznewMVbHhAo+a/ByzQnW6cx31CHUlTb+zEdNN+QE0GwBhsuszT0b
az6vdHaCyQtqUbPhmPkbCykbBjOnVgxOEFOJechpT0QhaR1kPUEkB8lQNFjv7FyO
rory/lqLZ1NBllYYnJalQ2eJhkm+65RI3AfS6+hNozeZ4CjvbRB/MCo22bTa3efP
GzXRatrgR6ZemyYhUe5UwumBdUZs8+CvK2SevDadszeVHJ+zyJn6KRWeODekINN9
Q7qYK6R6ECckoX2t38IUEIFE7kKC7G5bqEpI8YRc0Yw4aRLyYs4z1lCNJ77a81fg
2ZRbr7kTHCTiQY2dmMLyz4bVEwSKzX163+J2hWQqmVI5e9ky1ImMykebe739IOlP
uu9GW/p2exAcBIhPMjpupB3hgo41LIjzaIpXowvShY2frgIKWmL8YQ5w+BcxmJb4
hlx01vPinu/psau4OqShvJaHm8a+cP6KO5HMuCZkosAmcA/xF4eD0wEXDa6GhsKe
Xs6xz0RUJsc715RPKCd8
=aUV3
-----END PGP SIGNATURE-----

--0OAP2g/MAC+5xKAE--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
