From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-03-30
Date: Fri, 30 Mar 2012 13:55:34 -0400
Message-ID: <20120330175533.GC8273@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit de312db345f9770b64ff39ef5a7f86f6358e93cc

Dave,

I have a few more small fixes, hopefully still in time for 3.4-rc1...

Rajkukmar provides us with a one-line timestamp correction related to
scanning in mac80211.  Sujith gives us a small fixup for a regression
in the handling of HT capability bits for ath9k.  Stanislav Yakovlev
is stepping-up as maintainer for the ipw2x00 drivers, so we'll add
him to MAINTAINERS.  Stanislav also gives us a fix for a thinko
that registers the wrong band information for ipw2200 and 802.11a.
Finally, Santosh Nayak adds some simple error checking to orinoco to
avoid some potential NULL pointer dereferences.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 643c61e119459e9d750087b7b34be94491efebf9:

  rtlwifi: rtl8192ce: rtl8192cu: rtl8192de: Fix low-gain setting when scann=
ing (2012-03-26 15:07:30 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Rajkumar Manoharan (1):
      mac80211: fix oper channel timestamp updation

Santosh Nayak (1):
      net: orinoco: add error handling for failed kmalloc().

Stanislav Yakovlev (2):
      net/wireless: ipw2x00: fix a typo in wiphy struct initilization
      MAINTAINERS: adding maintainer for ipw2x00

Sujith Manoharan (1):
      ath9k: Use HW HT capabilites properly

 MAINTAINERS                            |   12 ++++--------
 drivers/net/wireless/ath/ath9k/main.c  |    4 ++--
 drivers/net/wireless/ipw2x00/ipw2200.c |    4 ++--
 drivers/net/wireless/orinoco/main.c    |    8 ++++++++
 net/mac80211/scan.c                    |    2 +-
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0ddc77fe..09a79f9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3519,17 +3519,13 @@ L:	linux-pm@vger.kernel.org
 S:	Supported
 F:	arch/x86/platform/mrst/pmu.*
=20
-INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
+INTEL PRO/WIRELESS 2100, 2200BG, 2915ABG NETWORK CONNECTION SUPPORT
+M:	Stanislav Yakovlev <stas.yakovlev@gmail.com>
 L:	linux-wireless@vger.kernel.org
-S:	Orphan
+S:	Maintained
 F:	Documentation/networking/README.ipw2100
-F:	drivers/net/wireless/ipw2x00/ipw2100.*
-
-INTEL PRO/WIRELESS 2915ABG NETWORK CONNECTION SUPPORT
-L:	linux-wireless@vger.kernel.org
-S:	Orphan
 F:	Documentation/networking/README.ipw2200
-F:	drivers/net/wireless/ipw2x00/ipw2200.*
+F:	drivers/net/wireless/ipw2x00/
=20
 INTEL(R) TRUSTED EXECUTION TECHNOLOGY (TXT)
 M:	Joseph Cihula <joseph.cihula@intel.com>
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 3879485..215eb25 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -640,7 +640,7 @@ static void ath_node_attach(struct ath_softc *sc, struc=
t ieee80211_sta *sta,
 	an->sta =3D sta;
 	an->vif =3D vif;
=20
-	if (sta->ht_cap.ht_supported) {
+	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT) {
 		ath_tx_node_init(sc, an);
 		an->maxampdu =3D 1 << (IEEE80211_HT_MAX_AMPDU_FACTOR +
 				     sta->ht_cap.ampdu_factor);
@@ -659,7 +659,7 @@ static void ath_node_detach(struct ath_softc *sc, struc=
t ieee80211_sta *sta)
 	an->sta =3D NULL;
 #endif
=20
-	if (sta->ht_cap.ht_supported)
+	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT)
 		ath_tx_node_cleanup(sc, an);
 }
=20
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/=
ipw2x00/ipw2200.c
index 4fcdac6..2b02257 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11507,9 +11507,9 @@ static int ipw_wdev_init(struct net_device *dev)
 			rc =3D -ENOMEM;
 			goto out;
 		}
-		/* translate geo->bg to a_band.channels */
+		/* translate geo->a to a_band.channels */
 		for (i =3D 0; i < geo->a_channels; i++) {
-			a_band->channels[i].band =3D IEEE80211_BAND_2GHZ;
+			a_band->channels[i].band =3D IEEE80211_BAND_5GHZ;
 			a_band->channels[i].center_freq =3D geo->a[i].freq;
 			a_band->channels[i].hw_value =3D geo->a[i].channel;
 			a_band->channels[i].max_power =3D geo->a[i].max_power;
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/ori=
noco/main.c
index dd6c64a..88e3ad2 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1336,6 +1336,10 @@ static void qbuf_scan(struct orinoco_private *priv, =
void *buf,
 	unsigned long flags;
=20
 	sd =3D kmalloc(sizeof(*sd), GFP_ATOMIC);
+	if (!sd) {
+		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+		return;
+	}
 	sd->buf =3D buf;
 	sd->len =3D len;
 	sd->type =3D type;
@@ -1353,6 +1357,10 @@ static void qabort_scan(struct orinoco_private *priv)
 	unsigned long flags;
=20
 	sd =3D kmalloc(sizeof(*sd), GFP_ATOMIC);
+	if (!sd) {
+		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+		return;
+	}
 	sd->len =3D -1; /* Abort */
=20
 	spin_lock_irqsave(&priv->scan_lock, flags);
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 33cd169..c70e176 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -370,7 +370,7 @@ static int ieee80211_start_sw_scan(struct ieee80211_loc=
al *local)
 	 */
 	drv_sw_scan_start(local);
=20
-	local->leave_oper_channel_time =3D 0;
+	local->leave_oper_channel_time =3D jiffies;
 	local->next_scan_state =3D SCAN_DECISION;
 	local->scan_channel_idx =3D 0;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPdfOVAAoJEJctW/TcYTgGHDgP/1ZPkQaqCVKPqT1T+kwKdzVu
mJ8JcgWLhuRZfcuemF4d+xzsE06CFsPRG7ats3AJnjMgdVoa9UP7oQTonKBp+jhF
pROeOwDv2dv9omFWvuJqDZc0l+n1VOIZRaVEjwakXcecHB89I/kTK12vdtI6ncat
O8/C9MCI0Zm7+DQUxVeKsJUw/xKe74IPV3+sd1HK/LsWt7geWGUKeoCYhXjttY39
t8PSoefrf/oeX2EX45jG1JG6s7zGoWYnJOCww2jS8VHB9Y0PADseRNTBASx3kPKX
VGhfqRGZdIGxavQYiOieS+6bUPMC1pzLLzX8BQmayQKE5b4iyZqrQGKzzmWoAI6k
TgqjtOWy+QZh1RjqqCNQP2O6UaKS1LCgYPwzgv8LzbUviQzNQFVUBetDuZGC4pdq
NdIN+DWZesiLpYlwRTu2PKto2Wyme+iZmqnSVuL+1N+6+wygk5mYSMwbSO0vnfh7
OjCY215WhY1Tl9G+BZxaDCXgbEGHfQ24x/itjukjE1ldfCyAu4+lPJjDEsSE3OCt
GNh1Bx14jlKD9ICZSl71jBqmeo5NXgNASxOYiK/5XCrQUMOOorg6D9qM/104FVXM
JoMzoH73MXYAxld2mq2CGv4EIfp40rsT4O0e7zqSIw9Evs43PU5NUOpentpzCZxd
GkTU9JtyFRBTsqnY58G0
=pBlb
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
