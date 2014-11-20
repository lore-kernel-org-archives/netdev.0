From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-11-20
Date: Thu, 20 Nov 2014 16:00:30 -0500
Message-ID: <20141120210030.GD31881@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41044 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756658AbaKTVPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 16:15:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please full this little batch of fixes intended for the 3.18 stream!

For the mac80211 patch, Johannes says:

"Here's another last minute fix, for minstrel HT crashing
depending on the value of some uninitialised stack."

On top of that...

Ben Greear fixes an ath9k regression in which a BSSID mask is
miscalculated.

Dmitry Torokhov corrects an error handling routing in brcmfmac which
was checking an unsigned variable for a negative value.

Johannes Berg avoids a build problem in brcmfmac for arches where
linux/unaligned/access_ok.h and asm/unaligned.h conflict.

Mathy Vanhoef addresses another brcmfmac issue so as to eliminate a
use-after-free of the URB transfer buffer if a timeout occurs.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4e6ce4dc7ce71d0886908d55129d5d6482a27ff9:

  ath9k: Fix RTC_DERIVED_CLK usage (2014-11-11 16:24:18 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-11-20

for you to fetch changes up to a1d69c60c44134f64945bbf6a6dfda22eaf4a214:

  brcmfmac: don't include linux/unaligned/access_ok.h (2014-11-20 14:46:45 =
-0500)

----------------------------------------------------------------
Ben Greear (1):
      ath9k: fix regression in bssidmask calculation

Dmitry Torokhov (1):
      brcmfmac: fix error handling of irq_of_parse_and_map

Felix Fietkau (1):
      mac80211: minstrel_ht: fix a crash in rate sorting

Johannes Berg (1):
      brcmfmac: don't include linux/unaligned/access_ok.h

John W. Linville (1):
      Merge tag 'mac80211-for-john-2014-11-18' of git://git.kernel.org/.../=
jberg/mac80211

Mathy Vanhoef (1):
      brcmfmac: kill URB when request timed out

 drivers/net/wireless/ath/ath9k/main.c          |  9 ++++++---
 drivers/net/wireless/brcm80211/brcmfmac/of.c   |  4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c  |  6 ++++--
 net/mac80211/rc80211_minstrel_ht.c             | 15 ++++++---------
 5 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 30c66dfcd7a0..4f18a6be0c7d 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -974,9 +974,8 @@ void ath9k_calculate_iter_data(struct ath_softc *sc,
 	struct ath_vif *avp;
=20
 	/*
-	 * Pick the MAC address of the first interface as the new hardware
-	 * MAC address. The hardware will use it together with the BSSID mask
-	 * when matching addresses.
+	 * The hardware will use primary station addr together with the
+	 * BSSID mask when matching addresses.
 	 */
 	memset(iter_data, 0, sizeof(*iter_data));
 	memset(&iter_data->mask, 0xff, ETH_ALEN);
@@ -1205,6 +1204,8 @@ static int ath9k_add_interface(struct ieee80211_hw *h=
w,
 		list_add_tail(&avp->list, &avp->chanctx->vifs);
 	}
=20
+	ath9k_calculate_summary_state(sc, avp->chanctx);
+
 	ath9k_assign_hw_queues(hw, vif);
=20
 	an->sc =3D sc;
@@ -1274,6 +1275,8 @@ static void ath9k_remove_interface(struct ieee80211_h=
w *hw,
=20
 	ath_tx_node_cleanup(sc, &avp->mcast_node);
=20
+	ath9k_calculate_summary_state(sc, avp->chanctx);
+
 	mutex_unlock(&sc->mutex);
 }
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/of.c b/drivers/net/wir=
eless/brcm80211/brcmfmac/of.c
index f05f5270fec1..927bffd5be64 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/of.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/of.c
@@ -40,8 +40,8 @@ void brcmf_of_probe(struct brcmf_sdio_dev *sdiodev)
 		return;
=20
 	irq =3D irq_of_parse_and_map(np, 0);
-	if (irq < 0) {
-		brcmf_err("interrupt could not be mapped: err=3D%d\n", irq);
+	if (!irq) {
+		brcmf_err("interrupt could not be mapped\n");
 		devm_kfree(dev, sdiodev->pdata);
 		return;
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c b/drivers/net/w=
ireless/brcm80211/brcmfmac/pcie.c
index 8c0632ec9f7a..16fef3382019 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/pcie.c
@@ -19,10 +19,10 @@
 #include <linux/pci.h>
 #include <linux/vmalloc.h>
 #include <linux/delay.h>
-#include <linux/unaligned/access_ok.h>
 #include <linux/interrupt.h>
 #include <linux/bcma/bcma.h>
 #include <linux/sched.h>
+#include <asm/unaligned.h>
=20
 #include <soc.h>
 #include <chipcommon.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index dc135915470d..875d1142c8b0 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -669,10 +669,12 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info =
*devinfo, u8 cmd,
 		goto finalize;
 	}
=20
-	if (!brcmf_usb_ioctl_resp_wait(devinfo))
+	if (!brcmf_usb_ioctl_resp_wait(devinfo)) {
+		usb_kill_urb(devinfo->ctl_urb);
 		ret =3D -ETIMEDOUT;
-	else
+	} else {
 		memcpy(buffer, tmpbuf, buflen);
+	}
=20
 finalize:
 	kfree(tmpbuf);
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_mins=
trel_ht.c
index df90ce2db00c..408fd8ab4eef 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -252,19 +252,16 @@ minstrel_ht_sort_best_tp_rates(struct minstrel_ht_sta=
 *mi, u8 index,
 	cur_thr =3D mi->groups[cur_group].rates[cur_idx].cur_tp;
 	cur_prob =3D mi->groups[cur_group].rates[cur_idx].probability;
=20
-	tmp_group =3D tp_list[j - 1] / MCS_GROUP_RATES;
-	tmp_idx =3D tp_list[j - 1] % MCS_GROUP_RATES;
-	tmp_thr =3D mi->groups[tmp_group].rates[tmp_idx].cur_tp;
-	tmp_prob =3D mi->groups[tmp_group].rates[tmp_idx].probability;
-
-	while (j > 0 && (cur_thr > tmp_thr ||
-	      (cur_thr =3D=3D tmp_thr && cur_prob > tmp_prob))) {
-		j--;
+	do {
 		tmp_group =3D tp_list[j - 1] / MCS_GROUP_RATES;
 		tmp_idx =3D tp_list[j - 1] % MCS_GROUP_RATES;
 		tmp_thr =3D mi->groups[tmp_group].rates[tmp_idx].cur_tp;
 		tmp_prob =3D mi->groups[tmp_group].rates[tmp_idx].probability;
-	}
+		if (cur_thr < tmp_thr ||
+		    (cur_thr =3D=3D tmp_thr && cur_prob <=3D tmp_prob))
+			break;
+		j--;
+	} while (j > 0);
=20
 	if (j < MAX_THR_RATES - 1) {
 		memmove(&tp_list[j + 1], &tp_list[j], (sizeof(*tp_list) *
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUblZuAAoJEJctW/TcYTgGdSIP+gNHqyOviVT8wgmqE97rddXG
w/78+1VUo86OK20+7/r9VZo2UdPyhr6t0bw3wdfS3tYvA9axGpOd531Ugh7d+QJB
4WoObqj5e2xTTm1/o5I/k1G7bqC4LvyAX6XDJhGO7+sooHqFNowMojOXMm4+M27r
r6pv/67AjZYER+n5whCinYc1eM9BEAoR47cqXBSM8oSB9K7EJnG7M57hSv1Vzicx
UQJqBukhjSapzaPxkc23ZxGy6zFMn0BDlB0WhV90qzrBKnjTTi9pDyzMp6ar/8CO
HEZ72IYCIE/wjKddd16QrXJYsZI5Bk/V9rUKf3w1b8OqmDW+gqAILNikQI4kYYmb
988f7igRpMza6DasXmSwJ0TLAVZQulwhaAVEOUE45aS5b2R27/ZJ51gaAvoFxRzl
CgiigtlPn9J4NOkbXos5oFgT6qnXzgGlhYeJ6nDnWFbM5Rif2NpLCxHR2T93/vDu
VNIqtXQePQxqPMvGOIqAHx6UkSIIqr7qtqYtsGtPNKx4gd85FPJ9Qj5SKH3rnQX8
jRtgz9p/ZfVcebAsyo/c+CLJ05jNLSMd1Z96T3Ns9ammB1I3zMPeZyPKYsqgX/Zx
hnaI1pr+PpvzgTkLOe7BwSIKf0bH8IVAJwSYP9yYflFag50p4O3dF5qfKywvwQ4M
UBCwqkh2fA1U3lgxYzcm
=+vF+
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
