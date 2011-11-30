From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-11-30
Date: Wed, 30 Nov 2011 14:39:07 -0500
Message-ID: <20111130193907.GB2477@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 3b95e9c089d932c11f9ec03f7493f02cceff04ba

Dave,

This is a batch of fixes intended for 3.2.

There is an nl80211 fix for validating user input to prevent a buffer
underrun, a mac80211 race fix to prevent a WARN_ON, a mac80211 fix to
avoid trying to stop a single aggregation session twice, a mac80211 fix
for a race condition that could cause a crash when an addBA response
came late, the partial reversion of an ath9k change that broke wireless
on Ferrari One laptops, and a fix for an rtlwifi deadlock.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5dc5503f5a400be5a7dc611745a034f04b0679b8:

  isdn: avoid copying too long drvid (2011-11-29 18:39:37 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Eliad Peller (1):
      nl80211: fix MAC address validation

Emmanuel Grumbach (1):
      mac80211: fix race between the AGG SM and the Tx data path

Johannes Berg (1):
      mac80211: don't stop a single aggregation session twice

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Nikolay Martynov (1):
      mac80211: fix race condition caused by late addBA response

Rafael J. Wysocki (1):
      ath9k: Revert change that broke AR928X on Acer Ferrari One

Stanislaw Gruszka (1):
      rtlwifi: fix lps_lock deadlock

 drivers/net/wireless/ath/ath9k/hw.c |    3 +-
 drivers/net/wireless/rtlwifi/ps.c   |   17 +++++++------
 net/mac80211/agg-tx.c               |   42 +++++++++++++++++++++++++++++++=
+--
 net/wireless/nl80211.c              |    4 +-
 4 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 2f91acc..8873c6e 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1827,7 +1827,8 @@ static void ath9k_set_power_sleep(struct ath_hw *ah, =
int setChip)
 	}
=20
 	/* Clear Bit 14 of AR_WA after putting chip into Full Sleep mode. */
-	REG_WRITE(ah, AR_WA, ah->WARegVal & ~AR_WA_D3_L1_DISABLE);
+	if (AR_SREV_9300_20_OR_LATER(ah))
+		REG_WRITE(ah, AR_WA, ah->WARegVal & ~AR_WA_D3_L1_DISABLE);
 }
=20
 /*
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwi=
fi/ps.c
index db52628..55c8e50 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -395,7 +395,7 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 	if (mac->link_state !=3D MAC80211_LINKED)
 		return;
=20
-	spin_lock(&rtlpriv->locks.lps_lock);
+	spin_lock_irq(&rtlpriv->locks.lps_lock);
=20
 	/* Idle for a while if we connect to AP a while ago. */
 	if (mac->cnt_after_linked >=3D 2) {
@@ -407,7 +407,7 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 		}
 	}
=20
-	spin_unlock(&rtlpriv->locks.lps_lock);
+	spin_unlock_irq(&rtlpriv->locks.lps_lock);
 }
=20
 /*Leave the leisure power save mode.*/
@@ -416,8 +416,9 @@ void rtl_lps_leave(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
 	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	unsigned long flags;
=20
-	spin_lock(&rtlpriv->locks.lps_lock);
+	spin_lock_irqsave(&rtlpriv->locks.lps_lock, flags);
=20
 	if (ppsc->fwctrl_lps) {
 		if (ppsc->dot11_psmode !=3D EACTIVE) {
@@ -438,7 +439,7 @@ void rtl_lps_leave(struct ieee80211_hw *hw)
 			rtl_lps_set_psmode(hw, EACTIVE);
 		}
 	}
-	spin_unlock(&rtlpriv->locks.lps_lock);
+	spin_unlock_irqrestore(&rtlpriv->locks.lps_lock, flags);
 }
=20
 /* For sw LPS*/
@@ -539,9 +540,9 @@ void rtl_swlps_rf_awake(struct ieee80211_hw *hw)
 		RT_CLEAR_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM);
 	}
=20
-	spin_lock(&rtlpriv->locks.lps_lock);
+	spin_lock_irq(&rtlpriv->locks.lps_lock);
 	rtl_ps_set_rf_state(hw, ERFON, RF_CHANGE_BY_PS);
-	spin_unlock(&rtlpriv->locks.lps_lock);
+	spin_unlock_irq(&rtlpriv->locks.lps_lock);
 }
=20
 void rtl_swlps_rfon_wq_callback(void *data)
@@ -574,9 +575,9 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 	if (rtlpriv->link_info.busytraffic)
 		return;
=20
-	spin_lock(&rtlpriv->locks.lps_lock);
+	spin_lock_irq(&rtlpriv->locks.lps_lock);
 	rtl_ps_set_rf_state(hw, ERFSLEEP, RF_CHANGE_BY_PS);
-	spin_unlock(&rtlpriv->locks.lps_lock);
+	spin_unlock_irq(&rtlpriv->locks.lps_lock);
=20
 	if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_ASPM &&
 		!RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM)) {
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index b3f6552..b064e4d 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -161,6 +161,12 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *s=
ta, u16 tid,
 		return -ENOENT;
 	}
=20
+	/* if we're already stopping ignore any new requests to stop */
+	if (test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
+		spin_unlock_bh(&sta->lock);
+		return -EALREADY;
+	}
+
 	if (test_bit(HT_AGG_STATE_WANT_START, &tid_tx->state)) {
 		/* not even started yet! */
 		ieee80211_assign_tid_tx(sta, tid, NULL);
@@ -169,6 +175,8 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *st=
a, u16 tid,
 		return 0;
 	}
=20
+	set_bit(HT_AGG_STATE_STOPPING, &tid_tx->state);
+
 	spin_unlock_bh(&sta->lock);
=20
 #ifdef CONFIG_MAC80211_HT_DEBUG
@@ -176,8 +184,6 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *st=
a, u16 tid,
 	       sta->sta.addr, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
=20
-	set_bit(HT_AGG_STATE_STOPPING, &tid_tx->state);
-
 	del_timer_sync(&tid_tx->addba_resp_timer);
=20
 	/*
@@ -187,6 +193,20 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *s=
ta, u16 tid,
 	 */
 	clear_bit(HT_AGG_STATE_OPERATIONAL, &tid_tx->state);
=20
+	/*
+	 * There might be a few packets being processed right now (on
+	 * another CPU) that have already gotten past the aggregation
+	 * check when it was still OPERATIONAL and consequently have
+	 * IEEE80211_TX_CTL_AMPDU set. In that case, this code might
+	 * call into the driver at the same time or even before the
+	 * TX paths calls into it, which could confuse the driver.
+	 *
+	 * Wait for all currently running TX paths to finish before
+	 * telling the driver. New packets will not go through since
+	 * the aggregation session is no longer OPERATIONAL.
+	 */
+	synchronize_net();
+
 	tid_tx->stop_initiator =3D initiator;
 	tid_tx->tx_stop =3D tx;
=20
@@ -757,11 +777,27 @@ void ieee80211_process_addba_resp(struct ieee80211_lo=
cal *local,
 		goto out;
 	}
=20
-	del_timer(&tid_tx->addba_resp_timer);
+	del_timer_sync(&tid_tx->addba_resp_timer);
=20
 #ifdef CONFIG_MAC80211_HT_DEBUG
 	printk(KERN_DEBUG "switched off addBA timer for tid %d\n", tid);
 #endif
+
+	/*
+	 * addba_resp_timer may have fired before we got here, and
+	 * caused WANT_STOP to be set. If the stop then was already
+	 * processed further, STOPPING might be set.
+	 */
+	if (test_bit(HT_AGG_STATE_WANT_STOP, &tid_tx->state) ||
+	    test_bit(HT_AGG_STATE_STOPPING, &tid_tx->state)) {
+#ifdef CONFIG_MAC80211_HT_DEBUG
+		printk(KERN_DEBUG
+		       "got addBA resp for tid %d but we already gave up\n",
+		       tid);
+#endif
+		goto out;
+	}
+
 	/*
 	 * IEEE 802.11-2007 7.3.1.14:
 	 * In an ADDBA Response frame, when the Status Code field
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index b3a476f..ffafda5 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -89,8 +89,8 @@ static const struct nla_policy nl80211_policy[NL80211_ATT=
R_MAX+1] =3D {
 	[NL80211_ATTR_IFINDEX] =3D { .type =3D NLA_U32 },
 	[NL80211_ATTR_IFNAME] =3D { .type =3D NLA_NUL_STRING, .len =3D IFNAMSIZ-1=
 },
=20
-	[NL80211_ATTR_MAC] =3D { .type =3D NLA_BINARY, .len =3D ETH_ALEN },
-	[NL80211_ATTR_PREV_BSSID] =3D { .type =3D NLA_BINARY, .len =3D ETH_ALEN },
+	[NL80211_ATTR_MAC] =3D { .len =3D ETH_ALEN },
+	[NL80211_ATTR_PREV_BSSID] =3D { .len =3D ETH_ALEN },
=20
 	[NL80211_ATTR_KEY] =3D { .type =3D NLA_NESTED, },
 	[NL80211_ATTR_KEY_DATA] =3D { .type =3D NLA_BINARY,
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO1oZaAAoJEJctW/TcYTgGWQEP/050ZAJ/+A4qUCBhIQanwnBe
1blCPu12xMD5cgZkk+1ngdRG2v1/sKBleKNxMsuL6HegIJCbhUKibiORI6KFWQPn
hB3BWtaEJASSsgkODToLgl9Ggvzb4BchZOgPsJ1NhOSr2086NDjqeC58+iN/IaHQ
Mhb9o2e/F/4lbqriSrA9kFLEh/A5kP/s77fO+oD1/8Kd5uV6c0/Mxw0Xy2CbvvCf
Uk/5AiX9UrqoeApiadGdtPaexHECNT/bEDoTV9baYUg4P9BlsUOI9CN1j70vR4jL
aT149DtpOoa5k7RpDEKFFJtaHBolCk2abWfKdCUpecDlIaYVk3vyEPD7r3HsfSsI
UYBNQMDfDa0xd1xPo9z/EjRFI+AxlTdyIPo2Qe5WEhjFtfRJSQ9gD4jvpLbD71eB
/uN0zErEI7hyo2+cMaB2dxW5lxIOesnyhMykBU6AFq/nlPIYOFxJUjvCaoxqvO4X
pNBWt82FSf69JCHucORekhMBAT9Ti2c7b8Yj/1f/Dvys+6Eg0P5JqR8s9VXHP8NS
Ct9/u5jtTXqvryhNoZHgq5u8iBKHkXoe8ZPmsZOf3e5fdiTPuqRngKyftwBG6HRe
4FNxyFHfFhhKLFrGGhIpRmq/Ft1enk4tV68hrCPz/bYyUj5hF87lFCVKFHl4dZ+f
SjwE11rCO/IsInPqS3hP
=j2EB
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--
