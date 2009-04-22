From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH v2 fixed] e100: do not go D3 in shutdown unless system is
	powering off
Date: Wed, 22 Apr 2009 01:38:28 -0300
Message-ID: <20090422043828.GB3979@vespa.holoscopio.com>
References: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com> <200904202114.01932.rjw@sisk.pl> <20090421215248.GF6147@vespa.holoscopio.com> <200904220017.19670.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.18.203]:37982 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbZDVEif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 00:38:35 -0400
Content-Disposition: inline
In-Reply-To: <200904220017.19670.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

After experimenting with kexec with the last merges after 2.6.29, I've
had some problems when probing e100. It would not read the eeprom. After
some bisects, I realized this has been like that since forever (at least
2.6.18). The problem is that shutdown is doing the same thing that
suspend does and puts the device in D3 state. I couldn't find a way to
get the device back to a sane state in the probe function. So, based on
some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
I wrote this one for e100.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/net/e100.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c0f8443..68e3b79 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2728,7 +2728,7 @@ static void __devexit e100_remove(struct pci_dev *pde=
v)
 #define E100_82552_SMARTSPEED   0x14   /* SmartSpeed Ctrl register */
 #define E100_82552_REV_ANEG     0x0200 /* Reverse auto-negotiation */
 #define E100_82552_ANEG_NOW     0x0400 /* Auto-negotiate now */
-static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
+static void __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct nic *nic =3D netdev_priv(netdev);
@@ -2749,19 +2749,32 @@ static int e100_suspend(struct pci_dev *pdev, pm_me=
ssage_t state)
 			           E100_82552_SMARTSPEED, smartspeed |
 			           E100_82552_REV_ANEG | E100_82552_ANEG_NOW);
 		}
-		if (pci_enable_wake(pdev, PCI_D3cold, true))
-			pci_enable_wake(pdev, PCI_D3hot, true);
+		*enable_wake =3D true;
 	} else {
-		pci_enable_wake(pdev, PCI_D3hot, false);
+		*enable_wake =3D false;
 	}
=20
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+}
=20
-	return 0;
+static int __e100_power_off(struct pci_dev *pdev, bool wake)
+{
+	if (wake) {
+		return pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		return pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
=20
 #ifdef CONFIG_PM
+static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	bool wake;
+	__e100_shutdown(pdev, &wake);
+	return __e100_power_off(pdev, wake);
+}
+
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
@@ -2792,7 +2805,10 @@ static int e100_resume(struct pci_dev *pdev)
=20
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	e100_suspend(pdev, PMSG_SUSPEND);
+	bool wake;
+	__e100_shutdown(pdev, &wake);
+	if (system_state =3D=3D SYSTEM_POWER_OFF)
+		__e100_power_off(pdev, wake);
 }
=20
 /* ------------------ PCI Error Recovery infrastructure  -------------- */
--=20
1.6.2.3


--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknun0QACgkQyTpryRcqtS1zjgCfXjDpOFWGopfZQPnQkZKWQcb7
pukAnjPGozUIYuBUF3uSuBRHSZ8QmRjo
=lUIw
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
