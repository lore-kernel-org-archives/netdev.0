From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-08-08
Date: Thu, 8 Aug 2013 13:29:40 -0400
Message-ID: <20130808172940.GC30925@tuxdriver.com>
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

This is a batch of fixes intended for the 3.11 queue...

Regarding the mac80211 (and related) bits, Johannes says:

"I have a fix from Chris for an infinite loop along with fixes from
myself to prevent it entering the loop to start with (continue using
disabled channels, many thanks to Chris for his debug/test help) and a
workaround for broken APs that advertise a bad HT primary channel in
their beacons. Additionally, a fix for another attrbuf race in mac80211
and a fix to clean up properly while P2P GO interfaces go down."

Along with that...

Solomon Peachy corrects a range check in cw1200 that would lead to
a BUG_ON when starting AP mode.

Stanislaw Gruszka provides an iwl4965 patch to power-up the device
earlier (avoiding microcode errors), and another iwl4965 fix that
resets the firmware after turning rfkill off (resolving a bug in the
Red Hat Bugzilla).

Please let me know if there are problems!

John

---

The following changes since commit 3e3be275851bc6fc90bfdcd732cd95563acd982b:

  ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match =
(2013-08-07 17:17:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 1826ff2357d69d3a2627df51e4ba07d24087b698:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-08-08 13:12:42 -0400)

----------------------------------------------------------------

Chris Wright (1):
      mac80211: fix infinite loop in ieee80211_determine_chantype

Johannes Berg (5):
      nl80211: fix another nl80211_fam.attrbuf race
      mac80211: don't wait for TX status forever
      mac80211: ignore HT primary channel while connected
      cfg80211: fix P2P GO interface teardown
      mac80211: continue using disabled channels while connected

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Solomon Peachy (1):
      cw1200: Fix spurious BUG_ON() trigger when starting AP mode.

Stanislaw Gruszka (2):
      iwl4965: set power mode early
      iwl4965: reset firmware after rfkill off

 drivers/net/wireless/cw1200/sta.c        |  7 ++---
 drivers/net/wireless/iwlegacy/4965-mac.c | 16 +++++-----
 drivers/net/wireless/iwlegacy/common.c   |  1 +
 net/mac80211/mlme.c                      | 54 +++++++++++++++++++++-------=
----
 net/wireless/core.c                      |  1 +
 net/wireless/nl80211.c                   |  6 ++--
 6 files changed, 52 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/cw120=
0/sta.c
index 7365674..010b252 100644
--- a/drivers/net/wireless/cw1200/sta.c
+++ b/drivers/net/wireless/cw1200/sta.c
@@ -1406,11 +1406,8 @@ static void cw1200_do_unjoin(struct cw1200_common *p=
riv)
 	if (!priv->join_status)
 		goto done;
=20
-	if (priv->join_status > CW1200_JOIN_STATUS_IBSS) {
-		wiphy_err(priv->hw->wiphy, "Unexpected: join status: %d\n",
-			  priv->join_status);
-		BUG_ON(1);
-	}
+	if (priv->join_status =3D=3D CW1200_JOIN_STATUS_AP)
+		goto done;
=20
 	cancel_work_sync(&priv->update_filtering_work);
 	cancel_work_sync(&priv->set_beacon_wakeup_period_work);
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireles=
s/iwlegacy/4965-mac.c
index b9b2bb5..f2ed62e 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -4460,12 +4460,12 @@ il4965_irq_tasklet(struct il_priv *il)
 		 * is killed. Hence update the killswitch state here. The
 		 * rfkill handler will care about restarting if needed.
 		 */
-		if (!test_bit(S_ALIVE, &il->status)) {
-			if (hw_rf_kill)
-				set_bit(S_RFKILL, &il->status);
-			else
-				clear_bit(S_RFKILL, &il->status);
+		if (hw_rf_kill) {
+			set_bit(S_RFKILL, &il->status);
+		} else {
+			clear_bit(S_RFKILL, &il->status);
 			wiphy_rfkill_set_hw_state(il->hw->wiphy, hw_rf_kill);
+			il_force_reset(il, true);
 		}
=20
 		handled |=3D CSR_INT_BIT_RF_KILL;
@@ -5334,6 +5334,9 @@ il4965_alive_start(struct il_priv *il)
=20
 	il->active_rate =3D RATES_MASK;
=20
+	il_power_update_mode(il, true);
+	D_INFO("Updated power mode\n");
+
 	if (il_is_associated(il)) {
 		struct il_rxon_cmd *active_rxon =3D
 		    (struct il_rxon_cmd *)&il->active;
@@ -5364,9 +5367,6 @@ il4965_alive_start(struct il_priv *il)
 	D_INFO("ALIVE processing complete.\n");
 	wake_up(&il->wait_command_queue);
=20
-	il_power_update_mode(il, true);
-	D_INFO("Updated power mode\n");
-
 	return;
=20
 restart:
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/=
iwlegacy/common.c
index 3195aad..b03e22e 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4660,6 +4660,7 @@ il_force_reset(struct il_priv *il, bool external)
=20
 	return 0;
 }
+EXPORT_SYMBOL(il_force_reset);
=20
 int
 il_mac_change_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index ae31968..cc9e02d 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -31,10 +31,12 @@
 #include "led.h"
=20
 #define IEEE80211_AUTH_TIMEOUT		(HZ / 5)
+#define IEEE80211_AUTH_TIMEOUT_LONG	(HZ / 2)
 #define IEEE80211_AUTH_TIMEOUT_SHORT	(HZ / 10)
 #define IEEE80211_AUTH_MAX_TRIES	3
 #define IEEE80211_AUTH_WAIT_ASSOC	(HZ * 5)
 #define IEEE80211_ASSOC_TIMEOUT		(HZ / 5)
+#define IEEE80211_ASSOC_TIMEOUT_LONG	(HZ / 2)
 #define IEEE80211_ASSOC_TIMEOUT_SHORT	(HZ / 10)
 #define IEEE80211_ASSOC_MAX_TRIES	3
=20
@@ -209,8 +211,9 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_da=
ta *sdata,
 			     struct ieee80211_channel *channel,
 			     const struct ieee80211_ht_operation *ht_oper,
 			     const struct ieee80211_vht_operation *vht_oper,
-			     struct cfg80211_chan_def *chandef, bool verbose)
+			     struct cfg80211_chan_def *chandef, bool tracking)
 {
+	struct ieee80211_if_managed *ifmgd =3D &sdata->u.mgd;
 	struct cfg80211_chan_def vht_chandef;
 	u32 ht_cfreq, ret;
=20
@@ -229,7 +232,7 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_da=
ta *sdata,
 	ht_cfreq =3D ieee80211_channel_to_frequency(ht_oper->primary_chan,
 						  channel->band);
 	/* check that channel matches the right operating channel */
-	if (channel->center_freq !=3D ht_cfreq) {
+	if (!tracking && channel->center_freq !=3D ht_cfreq) {
 		/*
 		 * It's possible that some APs are confused here;
 		 * Netgear WNDR3700 sometimes reports 4 higher than
@@ -237,11 +240,10 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_=
data *sdata,
 		 * since we look at probe response/beacon data here
 		 * it should be OK.
 		 */
-		if (verbose)
-			sdata_info(sdata,
-				   "Wrong control channel: center-freq: %d ht-cfreq: %d ht->primary_ch=
an: %d band: %d - Disabling HT\n",
-				   channel->center_freq, ht_cfreq,
-				   ht_oper->primary_chan, channel->band);
+		sdata_info(sdata,
+			   "Wrong control channel: center-freq: %d ht-cfreq: %d ht->primary_cha=
n: %d band: %d - Disabling HT\n",
+			   channel->center_freq, ht_cfreq,
+			   ht_oper->primary_chan, channel->band);
 		ret =3D IEEE80211_STA_DISABLE_HT | IEEE80211_STA_DISABLE_VHT;
 		goto out;
 	}
@@ -295,7 +297,7 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_da=
ta *sdata,
 				channel->band);
 		break;
 	default:
-		if (verbose)
+		if (!(ifmgd->flags & IEEE80211_STA_DISABLE_VHT))
 			sdata_info(sdata,
 				   "AP VHT operation IE has invalid channel width (%d), disable VHT\n",
 				   vht_oper->chan_width);
@@ -304,7 +306,7 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_da=
ta *sdata,
 	}
=20
 	if (!cfg80211_chandef_valid(&vht_chandef)) {
-		if (verbose)
+		if (!(ifmgd->flags & IEEE80211_STA_DISABLE_VHT))
 			sdata_info(sdata,
 				   "AP VHT information is invalid, disable VHT\n");
 		ret =3D IEEE80211_STA_DISABLE_VHT;
@@ -317,7 +319,7 @@ ieee80211_determine_chantype(struct ieee80211_sub_if_da=
ta *sdata,
 	}
=20
 	if (!cfg80211_chandef_compatible(chandef, &vht_chandef)) {
-		if (verbose)
+		if (!(ifmgd->flags & IEEE80211_STA_DISABLE_VHT))
 			sdata_info(sdata,
 				   "AP VHT information doesn't match HT, disable VHT\n");
 		ret =3D IEEE80211_STA_DISABLE_VHT;
@@ -333,18 +335,27 @@ out:
 	if (ret & IEEE80211_STA_DISABLE_VHT)
 		vht_chandef =3D *chandef;
=20
+	/*
+	 * Ignore the DISABLED flag when we're already connected and only
+	 * tracking the APs beacon for bandwidth changes - otherwise we
+	 * might get disconnected here if we connect to an AP, update our
+	 * regulatory information based on the AP's country IE and the
+	 * information we have is wrong/outdated and disables the channel
+	 * that we're actually using for the connection to the AP.
+	 */
 	while (!cfg80211_chandef_usable(sdata->local->hw.wiphy, chandef,
-					IEEE80211_CHAN_DISABLED)) {
+					tracking ? 0 :
+						   IEEE80211_CHAN_DISABLED)) {
 		if (WARN_ON(chandef->width =3D=3D NL80211_CHAN_WIDTH_20_NOHT)) {
 			ret =3D IEEE80211_STA_DISABLE_HT |
 			      IEEE80211_STA_DISABLE_VHT;
-			goto out;
+			break;
 		}
=20
 		ret |=3D chandef_downgrade(chandef);
 	}
=20
-	if (chandef->width !=3D vht_chandef.width && verbose)
+	if (chandef->width !=3D vht_chandef.width && !tracking)
 		sdata_info(sdata,
 			   "capabilities/regulatory prevented using AP HT/VHT configuration, do=
wngraded\n");
=20
@@ -384,7 +395,7 @@ static int ieee80211_config_bw(struct ieee80211_sub_if_=
data *sdata,
=20
 	/* calculate new channel (type) based on HT/VHT operation IEs */
 	flags =3D ieee80211_determine_chantype(sdata, sband, chan, ht_oper,
-					     vht_oper, &chandef, false);
+					     vht_oper, &chandef, true);
=20
 	/*
 	 * Downgrade the new channel if we associated with restricted
@@ -3394,10 +3405,13 @@ static int ieee80211_probe_auth(struct ieee80211_su=
b_if_data *sdata)
=20
 	if (tx_flags =3D=3D 0) {
 		auth_data->timeout =3D jiffies + IEEE80211_AUTH_TIMEOUT;
-		ifmgd->auth_data->timeout_started =3D true;
+		auth_data->timeout_started =3D true;
 		run_again(sdata, auth_data->timeout);
 	} else {
-		auth_data->timeout_started =3D false;
+		auth_data->timeout =3D
+			round_jiffies_up(jiffies + IEEE80211_AUTH_TIMEOUT_LONG);
+		auth_data->timeout_started =3D true;
+		run_again(sdata, auth_data->timeout);
 	}
=20
 	return 0;
@@ -3434,7 +3448,11 @@ static int ieee80211_do_assoc(struct ieee80211_sub_i=
f_data *sdata)
 		assoc_data->timeout_started =3D true;
 		run_again(sdata, assoc_data->timeout);
 	} else {
-		assoc_data->timeout_started =3D false;
+		assoc_data->timeout =3D
+			round_jiffies_up(jiffies +
+					 IEEE80211_ASSOC_TIMEOUT_LONG);
+		assoc_data->timeout_started =3D true;
+		run_again(sdata, assoc_data->timeout);
 	}
=20
 	return 0;
@@ -3829,7 +3847,7 @@ static int ieee80211_prep_channel(struct ieee80211_su=
b_if_data *sdata,
 	ifmgd->flags |=3D ieee80211_determine_chantype(sdata, sband,
 						     cbss->channel,
 						     ht_oper, vht_oper,
-						     &chandef, true);
+						     &chandef, false);
=20
 	sdata->needed_rx_chains =3D min(ieee80211_ht_vht_rx_chains(sdata, cbss),
 				      local->rx_chains);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 4f9f216..a8c29fa 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -765,6 +765,7 @@ void cfg80211_leave(struct cfg80211_registered_device *=
rdev,
 		cfg80211_leave_mesh(rdev, dev);
 		break;
 	case NL80211_IFTYPE_AP:
+	case NL80211_IFTYPE_P2P_GO:
 		cfg80211_stop_ap(rdev, dev);
 		break;
 	default:
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 25d217d..3fcba69 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -441,10 +441,12 @@ static int nl80211_prepare_wdev_dump(struct sk_buff *=
skb,
 			goto out_unlock;
 		}
 		*rdev =3D wiphy_to_dev((*wdev)->wiphy);
-		cb->args[0] =3D (*rdev)->wiphy_idx;
+		/* 0 is the first index - add 1 to parse only once */
+		cb->args[0] =3D (*rdev)->wiphy_idx + 1;
 		cb->args[1] =3D (*wdev)->identifier;
 	} else {
-		struct wiphy *wiphy =3D wiphy_idx_to_wiphy(cb->args[0]);
+		/* subtract the 1 again here */
+		struct wiphy *wiphy =3D wiphy_idx_to_wiphy(cb->args[0] - 1);
 		struct wireless_dev *tmp;
=20
 		if (!wiphy) {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJSA9WDAAoJEJctW/TcYTgGw0IP/iRFmNAB8Z5rP7UtE0bXfrHs
CQqXfWKh7SxP7jjjZYkf2gp94nSHggkikWtSb5bZmLNlPU31Oiik1RD92g9O+s8l
NJ0lKj8tbPcA2EDHCWW+C13iL1LvjLmiOZIiRe3p1OWlMyAb5VP5KFZYNUzJLx8+
/CQBwqj/zRsoXaoTv+X0ERh0WqTxSF3foBsLsd88IUWlW18jmyCfRSm90wh/iiwy
c4Pj8rve2yc0F971LLS9Aaz06YdQMX2Y3SLOdtauTX2b4YiVYbcHzt2k+LaFzdRs
IwDp5kL6KFx1kuqGlbdfxXtfgjc4hQTEhjwfqItYfEFQ/xWPXkXed4t0Qdhg2TgV
vvlabEK4G61sG2sUfYAmmbscNHvlCiqIBOzCCZngla7rg9EDlQSRFwRZDySf3TF8
4MgLpYfYtPkLcatqpqNYqwJjnC5vqSo8ZLD+1L9nGX7V0xAhMmtgk2mOMDkhWiUV
28siF3nea6k1N0KYtLNTQjcsD51jSJoGQgu//ijNlVy2oZIoax8knVguNObLmgGY
cvNZXQQDpQcrc2hr9vuWzds3LI/+tpaXwhsPtTfym1gte0AimodWildpoBKCdrid
pjGmUnzxEw6rhtjyaJhDl5g2nKf4UR8pdh9aTNX4BYcYmkqoRP6MCNx8KLTHPb4Z
pw3sCh5ldrWOakBH0IfR
=eTnb
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--
