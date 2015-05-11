From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-drivers-next tree with the
 net-next tree
Date: Mon, 11 May 2015 12:33:17 +1000
Message-ID: <20150511123317.2fe9dd4c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/YZk8JAF+gfb8BXW=uqHUGrP"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	Michal Kazior <michal.kazior@tieto.com>,
	Vasanthakumar Thiagarajan <vthiagar@qti.qualcomm.com>
To: Kalle Valo <kvalo@codeaurora.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/YZk8JAF+gfb8BXW=uqHUGrP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Kalle,

Today's linux-next merge of the wireless-drivers-next tree got a
conflict in drivers/net/wireless/ath/ath10k/mac.c between commits
41fbf6e4f317 ("ath10k: enable IEEE80211_HW_SUPPORT_FAST_XMIT") and
df1404650ccb ("mac80211: remove support for IFF_PROMISC") from the
net-next tree and commits 548462133d98 ("ath10k: fix interrupt storm"),
cc9904e694fa ("ath10k: add hw connection monitor support") and
500ff9f9389d ("ath10k: implement chanctx API") (and a few others) from
the wireless-drivers-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ath/ath10k/mac.c
index fcd08b2f8d26,eaa0182e001d..000000000000
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@@ -766,9 -1031,68 +1031,48 @@@ static int ath10k_monitor_stop(struct a
  	return 0;
  }
 =20
 -static bool ath10k_mac_should_disable_promisc(struct ath10k *ar)
 -{
 -	struct ath10k_vif *arvif;
 -
 -	if (!(ar->filter_flags & FIF_PROMISC_IN_BSS))
 -		return true;
 -
 -	if (!ar->num_started_vdevs)
 -		return false;
 -
 -	list_for_each_entry(arvif, &ar->arvifs, list)
 -		if (arvif->vdev_type !=3D WMI_VDEV_TYPE_AP)
 -			return false;
 -
 -	ath10k_dbg(ar, ATH10K_DBG_MAC,
 -		   "mac disabling promiscuous mode because vdev is started\n");
 -	return true;
 -}
 -
+ static bool ath10k_mac_monitor_vdev_is_needed(struct ath10k *ar)
+ {
+ 	int num_ctx;
+=20
+ 	/* At least one chanctx is required to derive a channel to start
+ 	 * monitor vdev on.
+ 	 */
+ 	num_ctx =3D ath10k_mac_num_chanctxs(ar);
+ 	if (num_ctx =3D=3D 0)
+ 		return false;
+=20
+ 	/* If there's already an existing special monitor interface then don't
+ 	 * bother creating another monitor vdev.
+ 	 */
+ 	if (ar->monitor_arvif)
+ 		return false;
+=20
+ 	return ar->monitor ||
 -	       !ath10k_mac_should_disable_promisc(ar) ||
+ 	       test_bit(ATH10K_CAC_RUNNING, &ar->dev_flags);
+ }
+=20
+ static bool ath10k_mac_monitor_vdev_is_allowed(struct ath10k *ar)
+ {
+ 	int num_ctx;
+=20
+ 	num_ctx =3D ath10k_mac_num_chanctxs(ar);
+=20
+ 	/* FIXME: Current interface combinations and cfg80211/mac80211 code
+ 	 * shouldn't allow this but make sure to prevent handling the following
+ 	 * case anyway since multi-channel DFS hasn't been tested at all.
+ 	 */
+ 	if (test_bit(ATH10K_CAC_RUNNING, &ar->dev_flags) && num_ctx > 1)
+ 		return false;
+=20
+ 	return true;
+ }
+=20
  static int ath10k_monitor_recalc(struct ath10k *ar)
  {
- 	bool should_start;
+ 	bool needed;
+ 	bool allowed;
+ 	int ret;
 =20
  	lockdep_assert_held(&ar->conf_mutex);
 =20
@@@ -5499,9 -6915,14 +6894,15 @@@ int ath10k_mac_register(struct ath10k *
  			IEEE80211_HW_AP_LINK_PS |
  			IEEE80211_HW_SPECTRUM_MGMT |
  			IEEE80211_HW_SW_CRYPTO_CONTROL |
- 			IEEE80211_HW_SUPPORT_FAST_XMIT;
++			IEEE80211_HW_SUPPORT_FAST_XMIT |
+ 			IEEE80211_HW_CONNECTION_MONITOR |
+ 			IEEE80211_HW_SUPPORTS_PER_STA_GTK |
+ 			IEEE80211_HW_WANT_MONITOR_VIF |
+ 			IEEE80211_HW_CHANCTX_STA_CSA |
+ 			IEEE80211_HW_QUEUE_CONTROL;
 =20
  	ar->hw->wiphy->features |=3D NL80211_FEATURE_STATIC_SMPS;
+ 	ar->hw->wiphy->flags |=3D WIPHY_FLAG_IBSS_RSN;
 =20
  	if (ar->ht_cap_info & WMI_HT_CAP_DYNAMIC_SMPS)
  		ar->hw->wiphy->features |=3D NL80211_FEATURE_DYNAMIC_SMPS;

--Sig_/YZk8JAF+gfb8BXW=uqHUGrP
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVUBTxAAoJEMDTa8Ir7ZwVzNYP+gNqTuTXyFERCgF1O6IZjfhb
aiBysQq5EdfsyVkODIIMW/MW/fac6x1wD9nmv4qQ3Q5XGEqIKZCdomIpRZDFkTU8
dwlCXTWOAz+VGsEOENCr62hs4/ZjpXfndbTkvSShblYBi6olZ7o45lqzBP3AUpX3
4Ry3CL+nvgQylmcIsOJ1aOLzWBIRiYaMgU7AOZxgpuMD6d06VFYFMF01R+/rNlO/
HKFBRp9CVFUWW38DlgY5N192z/3vZjXNHh/ZSRVRuK8YANtHu/Q/46vR3IpX6M6a
5wCqMmgnwJHzCtMU2qS9xxKLaD+rOwHvpUFM96dg/1aHprPE9A25zFr2DM7rGnQe
7J+A8KyRr9ziJqq0cgtjAXzFACdEIsLMNjcpbMM62rAiClznJiY9h0f5L/OdnxTT
G3qFtvz4m6Py2jhYaJu+hJJdx5eXFczjIedP4BfL5cogL32DwMe3gr1KmIGbB+z5
VORo+of6MIUAEWMLKrosFcxnLN27g4O2MWbr9vlWs1ADAP7Ka8OrgeCafjxmiq7q
p5IUAq3IAh15a9neTF2YUvQ5Fw9KaVh9YGT3k1t2+NSNy1aqDzctiNfCUJVtNMvL
uzdqO3MT6wONN+JHg+zzsl8Va9zdCIWVcFfm5D8OjWGIyUKVEb27vFc7Z2YQ9O30
idModk5QOIcs876oPbtS
=LcIx
-----END PGP SIGNATURE-----

--Sig_/YZk8JAF+gfb8BXW=uqHUGrP--
