From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] adm8211: fix suspend code
Date: Thu, 2 Nov 2006 21:01:23 -0500
Message-ID: <200611022101.27562.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4544658.CWLGrMaTV0";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:47822 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1752463AbWKCCBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 21:01:38 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4544658.CWLGrMaTV0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

adm8211: fix suspend code

Apparently, I forgot to port the suspend and resume code in the
d80211 port of adm8211. Thanks to Johannes Berg for finding this.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index bc0c8b6..fcfd05a 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2135,26 +2135,31 @@ #ifdef CONFIG_PM
 static int adm8211_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
=2D	netif_device_detach(dev);
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
=20
=2D	if (dev->flags & IFF_UP)
=2D		dev->stop(dev);
+	if (priv->mode !=3D IEEE80211_IF_TYPE_MGMT) {
+		ieee80211_stop_queues(dev);
+		adm8211_stop(dev);
+	}
=20
 	pci_save_state(pdev);
=2D	pci_set_power_state(pdev, PCI_D3hot);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 	return 0;
 }
=20
 static int adm8211_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
+
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
=20
=2D	if (dev->flags & IFF_UP)
=2D		dev->open(dev);
+	if (priv->mode !=3D IEEE80211_IF_TYPE_MGMT) {
+		adm8211_open(dev);
+		ieee80211_start_queues(dev);
+	}
=20
=2D	netif_device_attach(dev);
 	return 0;
 }
 #endif /* CONFIG_PM */

--nextPart4544658.CWLGrMaTV0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFSqL3T3Oqt9AH4aERAnZsAKC06pMj+q5zvBxCxxuayF2/JUZshQCgkrtN
LKfMgBkl8GZz50nugoEfyiA=
=ZRFT
-----END PGP SIGNATURE-----

--nextPart4544658.CWLGrMaTV0--
