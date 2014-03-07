From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-03-07
Date: Fri, 7 Mar 2014 16:12:39 -0500
Message-ID: <20140307211239.GC12787@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intende for the 3.14 stream...

For the mac80211 bits, Johannes says:

"Here I have a fix from Eliad for the minimal channel width calculation
in the mac80211 code which lead to monitor mode not working at all for
drivers using that. One of my fixes is for an issue noticed by Michal,
we clear an already cleared value but do it without locking, so just
remove that. The other is for a data leak - we leak two bytes of kernel
memory out over the air in QoS NULL frames because those don't get a
sequence number assigned in the TX path."

For the iwlwifi bits, Emmanuel says:

"One more fix and an update for device IDs.
There is a bugzilla reported for the fix which is mentioned in the commit m=
essage."

Along with those...

Amitkumar Karwar provides two mwifiex fixes, both correcting some
data transcription problems.

Ivaylo Dimitrov uses skb_trim in the wl1251 driver to avoid
HAVE_EFFICIENT_UNALIGNED_ACCESS problems.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c88507fbad8055297c1d1e21e599f46960cbee39:

  ipv6: don't set DST_NOCOUNT for remotely added routes (2014-03-06 17:29:2=
7 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 97bd5f0054ee879d778f4c7501ee2f88a9981ce2:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-03-07 15:09:32 -0500)

----------------------------------------------------------------

Amitkumar Karwar (2):
      mwifiex: copy AP's HT capability info correctly
      mwifiex: save and copy AP's VHT capability info correctly

Eliad Peller (1):
      mac80211: consider virtual mon when calculating min_def

Emmanuel Grumbach (1):
      iwlwifi: mvm: don't WARN when statistics are handled late

Ivaylo Dimitrov (1):
      wl1251: use skb_trim to make skb shorter

Johannes Berg (2):
      cfg80211: remove racy beacon_interval assignment
      mac80211: clear sequence/fragment number in QoS-null frames

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Oren Givon (1):
      iwlwifi: fix and add 7265 series HW IDs

 drivers/net/wireless/iwlwifi/mvm/bt-coex.c | 7 +++++--
 drivers/net/wireless/iwlwifi/pcie/drv.c    | 5 ++---
 drivers/net/wireless/mwifiex/11ac.c        | 3 +--
 drivers/net/wireless/mwifiex/11n.c         | 3 +--
 drivers/net/wireless/mwifiex/scan.c        | 8 ++++----
 drivers/net/wireless/ti/wl1251/rx.c        | 2 +-
 net/mac80211/chan.c                        | 6 ++++++
 net/mac80211/mesh_ps.c                     | 1 +
 net/mac80211/sta_info.c                    | 1 +
 net/wireless/core.c                        | 2 --
 10 files changed, 22 insertions(+), 16 deletions(-)
diff --git a/drivers/net/wireless/iwlwifi/mvm/bt-coex.c b/drivers/net/wirel=
ess/iwlwifi/mvm/bt-coex.c
index 76cde6ce6551..18a895a949d4 100644
--- a/drivers/net/wireless/iwlwifi/mvm/bt-coex.c
+++ b/drivers/net/wireless/iwlwifi/mvm/bt-coex.c
@@ -872,8 +872,11 @@ void iwl_mvm_bt_rssi_event(struct iwl_mvm *mvm, struct=
 ieee80211_vif *vif,
=20
 	lockdep_assert_held(&mvm->mutex);
=20
-	/* Rssi update while not associated ?! */
-	if (WARN_ON_ONCE(mvmvif->ap_sta_id =3D=3D IWL_MVM_STATION_COUNT))
+	/*
+	 * Rssi update while not associated - can happen since the statistics
+	 * are handled asynchronously
+	 */
+	if (mvmvif->ap_sta_id =3D=3D IWL_MVM_STATION_COUNT)
 		return;
=20
 	/* No BT - reports should be disabled */
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index f47bcbe2945a..3872ead75488 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -359,13 +359,12 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 /* 7265 Series */
 	{IWL_PCI_DEVICE(0x095A, 0x5010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5110, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095A, 0x5112, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5100, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095A, 0x510A, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5310, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095B, 0x5302, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x5302, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5210, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5012, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5412, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5410, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5400, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x1010, iwl7265_2ac_cfg)},
diff --git a/drivers/net/wireless/mwifiex/11ac.c b/drivers/net/wireless/mwi=
fiex/11ac.c
index 5e0eec4d71c7..5d9a8084665d 100644
--- a/drivers/net/wireless/mwifiex/11ac.c
+++ b/drivers/net/wireless/mwifiex/11ac.c
@@ -189,8 +189,7 @@ int mwifiex_cmd_append_11ac_tlv(struct mwifiex_private =
*priv,
 		vht_cap->header.len  =3D
 				cpu_to_le16(sizeof(struct ieee80211_vht_cap));
 		memcpy((u8 *)vht_cap + sizeof(struct mwifiex_ie_types_header),
-		       (u8 *)bss_desc->bcn_vht_cap +
-		       sizeof(struct ieee_types_header),
+		       (u8 *)bss_desc->bcn_vht_cap,
 		       le16_to_cpu(vht_cap->header.len));
=20
 		mwifiex_fill_vht_cap_tlv(priv, vht_cap, bss_desc->bss_band);
diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwif=
iex/11n.c
index 6261f8c53d44..7db1a89fdd95 100644
--- a/drivers/net/wireless/mwifiex/11n.c
+++ b/drivers/net/wireless/mwifiex/11n.c
@@ -308,8 +308,7 @@ mwifiex_cmd_append_11n_tlv(struct mwifiex_private *priv,
 		ht_cap->header.len =3D
 				cpu_to_le16(sizeof(struct ieee80211_ht_cap));
 		memcpy((u8 *) ht_cap + sizeof(struct mwifiex_ie_types_header),
-		       (u8 *) bss_desc->bcn_ht_cap +
-		       sizeof(struct ieee_types_header),
+		       (u8 *)bss_desc->bcn_ht_cap,
 		       le16_to_cpu(ht_cap->header.len));
=20
 		mwifiex_fill_cap_info(priv, radio_type, ht_cap);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwi=
fiex/scan.c
index 0a8a26e10f01..668547c2de84 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -2101,12 +2101,12 @@ mwifiex_save_curr_bcn(struct mwifiex_private *priv)
 			 curr_bss->ht_info_offset);
=20
 	if (curr_bss->bcn_vht_cap)
-		curr_bss->bcn_ht_cap =3D (void *)(curr_bss->beacon_buf +
-						curr_bss->vht_cap_offset);
+		curr_bss->bcn_vht_cap =3D (void *)(curr_bss->beacon_buf +
+						 curr_bss->vht_cap_offset);
=20
 	if (curr_bss->bcn_vht_oper)
-		curr_bss->bcn_ht_oper =3D (void *)(curr_bss->beacon_buf +
-						 curr_bss->vht_info_offset);
+		curr_bss->bcn_vht_oper =3D (void *)(curr_bss->beacon_buf +
+						  curr_bss->vht_info_offset);
=20
 	if (curr_bss->bcn_bss_co_2040)
 		curr_bss->bcn_bss_co_2040 =3D
diff --git a/drivers/net/wireless/ti/wl1251/rx.c b/drivers/net/wireless/ti/=
wl1251/rx.c
index 123c4bb50e0a..cde0eaf99714 100644
--- a/drivers/net/wireless/ti/wl1251/rx.c
+++ b/drivers/net/wireless/ti/wl1251/rx.c
@@ -180,7 +180,7 @@ static void wl1251_rx_body(struct wl1251 *wl,
 	wl1251_mem_read(wl, rx_packet_ring_addr, rx_buffer, length);
=20
 	/* The actual length doesn't include the target's alignment */
-	skb->len =3D desc->length  - PLCP_HEADER_LENGTH;
+	skb_trim(skb, desc->length - PLCP_HEADER_LENGTH);
=20
 	fc =3D (u16 *)skb->data;
=20
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index f43613a97dd6..0c1ecfdf9a12 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -100,6 +100,12 @@ ieee80211_get_chanctx_max_required_bw(struct ieee80211=
_local *local,
 		}
 		max_bw =3D max(max_bw, width);
 	}
+
+	/* use the configured bandwidth in case of monitor interface */
+	sdata =3D rcu_dereference(local->monitor_sdata);
+	if (sdata && rcu_access_pointer(sdata->vif.chanctx_conf) =3D=3D conf)
+		max_bw =3D max(max_bw, conf->def.width);
+
 	rcu_read_unlock();
=20
 	return max_bw;
diff --git a/net/mac80211/mesh_ps.c b/net/mac80211/mesh_ps.c
index 2802f9d9279d..ad8b377b4b9f 100644
--- a/net/mac80211/mesh_ps.c
+++ b/net/mac80211/mesh_ps.c
@@ -36,6 +36,7 @@ static struct sk_buff *mps_qos_null_get(struct sta_info *=
sta)
 				      sdata->vif.addr);
 	nullfunc->frame_control =3D fc;
 	nullfunc->duration_id =3D 0;
+	nullfunc->seq_ctrl =3D 0;
 	/* no address resolution for this frame -> set addr 1 immediately */
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
 	memset(skb_put(skb, 2), 0, 2); /* append QoS control field */
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index a023b432143b..137a192e64bc 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1206,6 +1206,7 @@ static void ieee80211_send_null_response(struct ieee8=
0211_sub_if_data *sdata,
 	memcpy(nullfunc->addr1, sta->sta.addr, ETH_ALEN);
 	memcpy(nullfunc->addr2, sdata->vif.addr, ETH_ALEN);
 	memcpy(nullfunc->addr3, sdata->vif.addr, ETH_ALEN);
+	nullfunc->seq_ctrl =3D 0;
=20
 	skb->priority =3D tid;
 	skb_set_queue_mapping(skb, ieee802_1d_to_ac[tid]);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 010892b81a06..a3bf18d11609 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -788,8 +788,6 @@ void cfg80211_leave(struct cfg80211_registered_device *=
rdev,
 	default:
 		break;
 	}
-
-	wdev->beacon_interval =3D 0;
 }
=20
 static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTGjZHAAoJEJctW/TcYTgGhVAP/2DVrE5tHF5nKcgPJzlPrs8c
e7/dng/O0hfV/dh41K+veuhEeWuXlYBkkSjoxtTvei2Z6JhniTKpbPzv3r3yXvrS
qZESsj+q1USKFSaanD1zjKonak0RSHuzzC/kbDDlFX1Qq+h0e0WUMp6oW4qWaFT9
aBsCQOspSoqN2A1bFw0QVdM9V66w5EdPj0SuzWroMLGGrveRoUqR6IiCKFdcV2uB
ZFxp9kFyFLEwLmfGLSzsOyFu/VmcBSaEUuuj7Aa6ctngeOyRSDf3y36TtwEy5RBX
qJuxndBDDQMjfNWpyaYnjCR0sa9hVr8QiaazTdYY7ATyKELZgo85QfE4Pu/SCak9
7EmYV6K8d0XXtJbOVixlVaPJiJTqQzjTNGMv8qNSKsOftEuEl2BsfOnpNiSiIWaS
P/FlqM+i1ZVlEkzaCLdRRTxmQuoz2sv66yAoS/hCE/WV55cvA8PZFBX0phi4Ljc9
29wdnU6XinB8ouOwieVgSLsLuBCg/NauqfaY/lHLRc2c2XFxfPOCO3+fELSmRusR
qeBcm9MNvL8cQSC3BPLtxFQwSY6gTLEX/u1t9cR5Lv5dOhltFRfHKnPnLyKRP/AN
jAY9X7l3lY23HxbhkXtvCOdE8nE7X/ABzNyfQkWyQH8qv9zr/F86Rq7v91QMkIYa
lttO7GHf+J/tdAXOhm4m
=7wxX
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
