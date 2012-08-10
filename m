From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-08-10
Date: Fri, 10 Aug 2012 14:33:51 -0400
Message-ID: <20120810183351.GD1950@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 039aafba1b57ed39acb3abc290c11be37402feb2

Dave,

Here is a handful of fixes intended for 3.6.

Daniel Drake offers a cfg80211 fix to consume pending events before
taking a wireless device down.  This prevents a resource leak.

Stanislaw Gruszka gives us a fix for a NULL pointer dereference in
rt61pci.

Johannes Berg provides an iwlwifi patch to disable "greenfield" mode.
Use of that mode was causing a rate scaling problem in for iwlwifi.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 63d02d157ec4124990258d66517b6c11fd6df0cf:

  net: tcp: ipv6_mapped needs sk_rx_dst_set method (2012-08-09 20:56:09 -07=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 039aafba1b57ed39acb3abc290c11be37402feb2:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-08-10 14:05:38 -0400)

----------------------------------------------------------------

Daniel Drake (1):
      cfg80211: process pending events when unregistering net device

Johannes Berg (1):
      iwlwifi: disable greenfield transmissions as a workaround

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Stanislaw Gruszka (1):
      rt61pci: fix NULL pointer dereference in config_lna_gain

 drivers/net/wireless/iwlwifi/dvm/rs.c |   13 ++++++++-----
 drivers/net/wireless/rt2x00/rt61pci.c |    3 +--
 net/wireless/core.c                   |    5 +++++
 net/wireless/core.h                   |    1 +
 net/wireless/util.c                   |    2 +-
 5 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/rs.c b/drivers/net/wireless/i=
wlwifi/dvm/rs.c
index 6fddd27..a82f46c 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rs.c
@@ -707,11 +707,14 @@ static int rs_toggle_antenna(u32 valid_ant, u32 *rate=
_n_flags,
  */
 static bool rs_use_green(struct ieee80211_sta *sta)
 {
-	struct iwl_station_priv *sta_priv =3D (void *)sta->drv_priv;
-	struct iwl_rxon_context *ctx =3D sta_priv->ctx;
-
-	return (sta->ht_cap.cap & IEEE80211_HT_CAP_GRN_FLD) &&
-		!(ctx->ht.non_gf_sta_present);
+	/*
+	 * There's a bug somewhere in this code that causes the
+	 * scaling to get stuck because GF+SGI can't be combined
+	 * in SISO rates. Until we find that bug, disable GF, it
+	 * has only limited benefit and we still interoperate with
+	 * GF APs since we can always receive GF transmissions.
+	 */
+	return false;
 }
=20
 /**
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/r=
t2x00/rt61pci.c
index f322596..3f7bc5c 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2243,8 +2243,7 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00d=
ev)
=20
 static void rt61pci_wakeup(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_conf conf =3D { .flags =3D 0 };
-	struct rt2x00lib_conf libconf =3D { .conf =3D &conf };
+	struct rt2x00lib_conf libconf =3D { .conf =3D &rt2x00dev->hw->conf };
=20
 	rt61pci_config(rt2x00dev, &libconf, IEEE80211_CONF_CHANGE_PS);
 }
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 31b40cc..dcd64d5 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -952,6 +952,11 @@ static int cfg80211_netdev_notifier_call(struct notifi=
er_block *nb,
 		 */
 		synchronize_rcu();
 		INIT_LIST_HEAD(&wdev->list);
+		/*
+		 * Ensure that all events have been processed and
+		 * freed.
+		 */
+		cfg80211_process_wdev_events(wdev);
 		break;
 	case NETDEV_PRE_UP:
 		if (!(wdev->wiphy->interface_modes & BIT(wdev->iftype)))
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 5206c68..bc7430b 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -426,6 +426,7 @@ int cfg80211_change_iface(struct cfg80211_registered_de=
vice *rdev,
 			  struct net_device *dev, enum nl80211_iftype ntype,
 			  u32 *flags, struct vif_params *params);
 void cfg80211_process_rdev_events(struct cfg80211_registered_device *rdev);
+void cfg80211_process_wdev_events(struct wireless_dev *wdev);
=20
 int cfg80211_can_use_iftype_chan(struct cfg80211_registered_device *rdev,
 				 struct wireless_dev *wdev,
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 26f8cd3..994e2f0 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -735,7 +735,7 @@ void cfg80211_upload_connect_keys(struct wireless_dev *=
wdev)
 	wdev->connect_keys =3D NULL;
 }
=20
-static void cfg80211_process_wdev_events(struct wireless_dev *wdev)
+void cfg80211_process_wdev_events(struct wireless_dev *wdev)
 {
 	struct cfg80211_event *ev;
 	unsigned long flags;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQJVQOAAoJEJctW/TcYTgGfVAP/jcU1mCB9Jp6JYhzd3ZW6nSc
ThHtOv7NKOdsWFxRey7xCksuDCo524bMb/+O4JZwRG/fBFjoFIjuY42BQm2eNyfS
xPjOEar2Ota18TD5Bm3nmHlGhyOXYKxeEjVkcXQjh5ixV6PQg2WYJAyV//yAD5DE
VtV8c7SoDRQZKARc4TMfurY7L8rm014PNtFwwWRWZrOAxRHuDubjn9UXOKh/70CX
qU89j2DIOMB3BvwFR3FX0YuZPCscdxMfwMkRdPrwJXVSzk5IeShhBs/bJ7Zv1AB3
Os6dQQQkmD6htCF+EnmB1fVC1OUkrbQ7M0TktmDpY1ygbwTw7MSsslzwBA3UTVCM
4//C2k4jAXkjMJsXav/01L5SZISO1qd5u+1jTrsTJ+v8Qf/hB0Gr/FvGgCR6Yij/
2tfwNqlXQ+ZrzK5wBVW3oux2ywchsA5wU1Pq1Fsed1VbgqC0NvC+H3Zl1NTL6V6+
MYtNspqDBRyyAiYJ+U/dh17njM2kNGbzM22wZ0595U0QqVz/UUidHHSJKaAvaejT
NeCU8TDugHTNBXOlAscbz2PZkEc4989g9CRGHqvBfVGCH2nyYXcSesXAiw5jZUTf
P2niihF+lyw20Fjwk8QG8cUAgfBUbNuhEq2oxHcCcTX1YEWK3Jt5T9vf+F5rOU70
b6ErgLfuvkrNOGiQIAVK
=58gT
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--
