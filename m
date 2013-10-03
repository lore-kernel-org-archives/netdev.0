From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-10-03
Date: Thu, 3 Oct 2013 16:10:24 -0400
Message-ID: <20131003201023.GC3142@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here is another batch of fixes intended for the 3.12 stream...

For the mac80211 bits, Johannes says:

"This time I have two fixes for IBSS (including one for wext, hah), a fix
for extended rates IEs, an active monitor checking fix and a sysfs
registration race fix."

On top of those...

Amitkumar Karwar brings an mwifiex fix for an interrupt loss issue
w/ SDIO devices.  The problem was due to a command timeout issue
introduced by an earlier patch.

Felix Fietkau a stall in the ath9k driver.  This patch fixes the
regression introduced in the commit "ath9k: use software queues for
un-aggregated data packets".

Stanislaw Gruszka reverts an rt2x00 patch that was found to cause
connection problems with some devices.

Please let me know if there are problems!

John

---

The following changes since commit 569943d0639c85a451ea853087cbd5f738247dd9:

  Merge branch 'mv643xx' (2013-10-02 17:11:50 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 1eea72f03a139146f341e450cf56934b2e01a4d3:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-10-03 16:00:03 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: fix SDIO interrupt lost issue

Bruno Randolf (1):
      cfg80211: fix warning when using WEXT for IBSS

Chun-Yeow Yeoh (1):
      mac80211: fix the setting of extended supported rate IE

Felix Fietkau (2):
      mac80211: drop spoofed packets in ad-hoc mode
      ath9k: fix powersave response handling for BA session packets

Johannes Berg (1):
      cfg80211: fix sysfs registration race

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Luciano Coelho (1):
      cfg80211: use the correct macro to check for active monitor support

Stanislaw Gruszka (1):
      Revert "rt2x00pci: Use PCI MSIs whenever possible"

 drivers/net/wireless/ath/ath9k/xmit.c   |  9 ++++++---
 drivers/net/wireless/mwifiex/main.c     |  6 ++++--
 drivers/net/wireless/rt2x00/rt2x00pci.c |  9 +--------
 net/mac80211/rx.c                       |  3 +++
 net/mac80211/util.c                     |  5 +----
 net/wireless/core.c                     | 21 +++++++++++++--------
 net/wireless/ibss.c                     |  3 +++
 net/wireless/nl80211.c                  |  4 ++--
 8 files changed, 33 insertions(+), 27 deletions(-)
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 5ac713d..dd30452 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1969,15 +1969,18 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, =
struct ath_txq *txq,
 static void ath_tx_send_normal(struct ath_softc *sc, struct ath_txq *txq,
 			       struct ath_atx_tid *tid, struct sk_buff *skb)
 {
+	struct ieee80211_tx_info *tx_info =3D IEEE80211_SKB_CB(skb);
 	struct ath_frame_info *fi =3D get_frame_info(skb);
 	struct list_head bf_head;
-	struct ath_buf *bf;
-
-	bf =3D fi->bf;
+	struct ath_buf *bf =3D fi->bf;
=20
 	INIT_LIST_HEAD(&bf_head);
 	list_add_tail(&bf->list, &bf_head);
 	bf->bf_state.bf_type =3D 0;
+	if (tid && (tx_info->flags & IEEE80211_TX_CTL_AMPDU)) {
+		bf->bf_state.bf_type =3D BUF_AMPDU;
+		ath_tx_addto_baw(sc, tid, bf);
+	}
=20
 	bf->bf_next =3D NULL;
 	bf->bf_lastbf =3D bf;
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index fd77833..c2b91f5 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -358,10 +358,12 @@ process_start:
 		}
 	} while (true);
=20
-	if ((adapter->int_status) || IS_CARD_RX_RCVD(adapter))
+	spin_lock_irqsave(&adapter->main_proc_lock, flags);
+	if ((adapter->int_status) || IS_CARD_RX_RCVD(adapter)) {
+		spin_unlock_irqrestore(&adapter->main_proc_lock, flags);
 		goto process_start;
+	}
=20
-	spin_lock_irqsave(&adapter->main_proc_lock, flags);
 	adapter->mwifiex_processing =3D false;
 	spin_unlock_irqrestore(&adapter->main_proc_lock, flags);
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless=
/rt2x00/rt2x00pci.c
index 76d95de..dc49e52 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -105,13 +105,11 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const st=
ruct rt2x00_ops *ops)
 		goto exit_release_regions;
 	}
=20
-	pci_enable_msi(pci_dev);
-
 	hw =3D ieee80211_alloc_hw(sizeof(struct rt2x00_dev), ops->hw);
 	if (!hw) {
 		rt2x00_probe_err("Failed to allocate hardware\n");
 		retval =3D -ENOMEM;
-		goto exit_disable_msi;
+		goto exit_release_regions;
 	}
=20
 	pci_set_drvdata(pci_dev, hw);
@@ -152,9 +150,6 @@ exit_free_reg:
 exit_free_device:
 	ieee80211_free_hw(hw);
=20
-exit_disable_msi:
-	pci_disable_msi(pci_dev);
-
 exit_release_regions:
 	pci_release_regions(pci_dev);
=20
@@ -179,8 +174,6 @@ void rt2x00pci_remove(struct pci_dev *pci_dev)
 	rt2x00pci_free_reg(rt2x00dev);
 	ieee80211_free_hw(hw);
=20
-	pci_disable_msi(pci_dev);
-
 	/*
 	 * Free the PCI device data.
 	 */
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 54395d7..674eac1 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -3056,6 +3056,9 @@ static int prepare_for_handlers(struct ieee80211_rx_d=
ata *rx,
 	case NL80211_IFTYPE_ADHOC:
 		if (!bssid)
 			return 0;
+		if (ether_addr_equal(sdata->vif.addr, hdr->addr2) ||
+		    ether_addr_equal(sdata->u.ibss.bssid, hdr->addr2))
+			return 0;
 		if (ieee80211_is_beacon(hdr->frame_control)) {
 			return 1;
 		} else if (!ieee80211_bssid_match(bssid, sdata->u.ibss.bssid)) {
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index e1b34a1..9c3200b 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -2103,7 +2103,7 @@ int ieee80211_add_ext_srates_ie(struct ieee80211_sub_=
if_data *sdata,
 {
 	struct ieee80211_local *local =3D sdata->local;
 	struct ieee80211_supported_band *sband;
-	int rate, skip, shift;
+	int rate, shift;
 	u8 i, exrates, *pos;
 	u32 basic_rates =3D sdata->vif.bss_conf.basic_rates;
 	u32 rate_flags;
@@ -2131,14 +2131,11 @@ int ieee80211_add_ext_srates_ie(struct ieee80211_su=
b_if_data *sdata,
 		pos =3D skb_put(skb, exrates + 2);
 		*pos++ =3D WLAN_EID_EXT_SUPP_RATES;
 		*pos++ =3D exrates;
-		skip =3D 0;
 		for (i =3D 8; i < sband->n_bitrates; i++) {
 			u8 basic =3D 0;
 			if ((rate_flags & sband->bitrates[i].flags)
 			    !=3D rate_flags)
 				continue;
-			if (skip++ < 8)
-				continue;
 			if (need_basic && basic_rates & BIT(i))
 				basic =3D 0x80;
 			rate =3D DIV_ROUND_UP(sband->bitrates[i].bitrate,
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 6715396..fe8d4f2 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -566,18 +566,13 @@ int wiphy_register(struct wiphy *wiphy)
 	/* check and set up bitrates */
 	ieee80211_set_bitrate_flags(wiphy);
=20
-
+	rtnl_lock();
 	res =3D device_add(&rdev->wiphy.dev);
-	if (res)
-		return res;
-
-	res =3D rfkill_register(rdev->rfkill);
 	if (res) {
-		device_del(&rdev->wiphy.dev);
+		rtnl_unlock();
 		return res;
 	}
=20
-	rtnl_lock();
 	/* set up regulatory info */
 	wiphy_regulatory_register(wiphy);
=20
@@ -606,6 +601,15 @@ int wiphy_register(struct wiphy *wiphy)
=20
 	rdev->wiphy.registered =3D true;
 	rtnl_unlock();
+
+	res =3D rfkill_register(rdev->rfkill);
+	if (res) {
+		rfkill_destroy(rdev->rfkill);
+		rdev->rfkill =3D NULL;
+		wiphy_unregister(&rdev->wiphy);
+		return res;
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL(wiphy_register);
@@ -640,7 +644,8 @@ void wiphy_unregister(struct wiphy *wiphy)
 		rtnl_unlock();
 		__count =3D=3D 0; }));
=20
-	rfkill_unregister(rdev->rfkill);
+	if (rdev->rfkill)
+		rfkill_unregister(rdev->rfkill);
=20
 	rtnl_lock();
 	rdev->wiphy.registered =3D false;
diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index 39bff7d..403fe29 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -263,6 +263,8 @@ int cfg80211_ibss_wext_join(struct cfg80211_registered_=
device *rdev,
 				if (chan->flags & IEEE80211_CHAN_DISABLED)
 					continue;
 				wdev->wext.ibss.chandef.chan =3D chan;
+				wdev->wext.ibss.chandef.center_freq1 =3D
+					chan->center_freq;
 				break;
 			}
=20
@@ -347,6 +349,7 @@ int cfg80211_ibss_wext_siwfreq(struct net_device *dev,
 	if (chan) {
 		wdev->wext.ibss.chandef.chan =3D chan;
 		wdev->wext.ibss.chandef.width =3D NL80211_CHAN_WIDTH_20_NOHT;
+		wdev->wext.ibss.chandef.center_freq1 =3D freq;
 		wdev->wext.ibss.channel_fixed =3D true;
 	} else {
 		/* cfg80211_ibss_wext_join will pick one if needed */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index af8d84a..626dc3b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2421,7 +2421,7 @@ static int nl80211_set_interface(struct sk_buff *skb,=
 struct genl_info *info)
 		change =3D true;
 	}
=20
-	if (flags && (*flags & NL80211_MNTR_FLAG_ACTIVE) &&
+	if (flags && (*flags & MONITOR_FLAG_ACTIVE) &&
 	    !(rdev->wiphy.features & NL80211_FEATURE_ACTIVE_MONITOR))
 		return -EOPNOTSUPP;
=20
@@ -2483,7 +2483,7 @@ static int nl80211_new_interface(struct sk_buff *skb,=
 struct genl_info *info)
 				  info->attrs[NL80211_ATTR_MNTR_FLAGS] : NULL,
 				  &flags);
=20
-	if (!err && (flags & NL80211_MNTR_FLAG_ACTIVE) &&
+	if (!err && (flags & MONITOR_FLAG_ACTIVE) &&
 	    !(rdev->wiphy.features & NL80211_FEATURE_ACTIVE_MONITOR))
 		return -EOPNOTSUPP;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSTc8vAAoJEJctW/TcYTgGRMkP/jHko7gbIztebWfgawIynXgI
y8UpzRxsbr41VGUI1b15NeLiANOF0bp7HVDv2LS6mEdZLNSi3YobSnxX22PtUJR4
stfv/jKWFQfj/SXBXPWniNbxNgmqEZlT2AFb2/VFyWOruLWCP03Nwv8Tt0gnZEHQ
rGpslJtGDYwgrxBMoiJbRue1h7ik8Z71iZL2YxkMXaE4KDDeROFH0eADfxvbqq7j
1qhWOblKp/KwKhbIgZuuxlP3JSH/g+ozeN9pfH69Q1EQ6q5tNZWDJMIr0fOmJspl
78vVxlZZl5Cs+jK0nkG7PQb/AW59qrGruvuJn8A0qBTZVrRIrQ2DA3BMaq4D9CSF
05mbe53352pg3wNTDmbtvOGy87hUfIIZtu3eM+no0AsZiOenoMdAaWnci96W8/rR
kumJfFfNZp84Xhsx6Yb7CrehJltXVC2FLhChM2TZPnLhQgb4oR3hjiHABnJamcgy
N7W8NAZzo07gy3UmgeLf9BTUlxDxR4LOXQFFBCEuKMjja9F/Pz7iWd6MeAE4bRGs
KpcldKd9xodgf6roWnLtRSwze2ZNfguXScozQX4rVGrCzX0LgE0vj+KPkZhBPM9M
gDU3fAtbvXmwr29yv16ee/NYHiAK2oTQBwqctl+HZ6H252AnckPG0yE+Gd8vYaiC
1on6SBxXDyrsCFvj+G7M
=C7Ft
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
