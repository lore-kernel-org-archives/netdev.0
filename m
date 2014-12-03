From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Wed, 3 Dec 2014 16:18:55 +0100
Message-ID: <20141203161855.50951aa8@wiggum>
References: <20141201111125.GA11974@localhost.localdomain>
	<1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
	<20141201221023.79ffb40d@wiggum>
	<20141202200129.GA4580@crion89>
	<20141202211211.7e08b935@wiggum>
	<547E3BF5.5060201@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Smtp5ohLhjRegDtU_y.qeRA"; protocol="application/pgp-signature"
Cc: Andrey Skvortsov <andrej.skvortzov@gmail.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547E3BF5.5060201@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Smtp5ohLhjRegDtU_y.qeRA
Content-Type: multipart/mixed; boundary="MP_/QT/kNMJ7KvKRApIb7eh/F3c"

--MP_/QT/kNMJ7KvKRApIb7eh/F3c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tue, 02 Dec 2014 16:23:49 -0600
Larry Finger <Larry.Finger@lwfinger.net> wrote:

> On 12/02/2014 02:12 PM, Michael B=C3=BCsch wrote:
> > On Tue, 2 Dec 2014 23:01:29 +0300
> > Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> >
> >> On Mon, Dec 01, 2014 at 10:10:23PM +0100, Michael B=C3=BCsch wrote:
> >>> On Mon,  1 Dec 2014 23:46:38 +0300
> >>> Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> >>>
> >>>> Wake On Lan was not working on laptop DELL Vostro 1500.
> >>>> If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs b=
linked.
> >>>> But the laptop could not be woken up with the Magic Packet. The reas=
on for
> >>>> that was that PCIE was not enabled as a system wakeup source and
> >>>> therefore the host PCI bridge was not powered up in suspend mode.
> >>>> PCIE was not enabled in suspend by PM because no child devices were
> >>>> registered as wakeup source during suspend process.
> >>>> On laptop BCM4401 is connected through the SSB bus, that is connecte=
d to the
> >>>> PCI-Express bus. SSB and B44 did not use standard PM wakeup functions
> >>>> and did not forward wakeup settings to their parents.
> >>>> To fix that B44 driver enables PM wakeup and registers new wakeup so=
urce
> >>>> using device_set_wakeup_enable(). Wakeup is automatically reported t=
o the parent SSB
> >>>> bus via power.wakeup_path. SSB bus enables wakeup for the parent PCI=
 bridge, if there is any
> >>>> child devices with enabled wakeup functionality. All other steps are
> >>>> done by PM core code.
> >>>
> >>> Thanks, this looks good.
> >>> I assume you tested this (I currently don't have a device to test thi=
s).
> >>
> >> Sure, I've tested it. WOL from suspend is working and after resume fro=
m hibernate Ethernet is working too.
> >
> > That sounds good, indeed.
> > I'd still prefer, if someone with b43 (wireless) would test it, too.
>=20
> I did a partial test with my PowerBook G4. With the patch installed, it w=
ould=20
> both suspend and hibernate, but WOL would be impossible. This computer us=
es a=20
> PCMCIA version of the BCM4318, and power is turned off to the PCMCIA card=
 when=20
> suspended or hibernating.

Thanks for testing.

John, can you take this one? Or do we need to split the b44 part out?
I added my Signed-off.

--=20
Michael

--MP_/QT/kNMJ7KvKRApIb7eh/F3c
Content-Type: text/x-patch
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=b44_wol.patch

From: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Subject: [PATCH] SSB / B44: fix WOL for BCM4401

Wake On Lan was not working on laptop DELL Vostro 1500.
If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs blinked.
But the laptop could not be woken up with the Magic Packet. The reason for
that was that PCIE was not enabled as a system wakeup source and
therefore the host PCI bridge was not powered up in suspend mode.
PCIE was not enabled in suspend by PM because no child devices were
registered as wakeup source during suspend process.
On laptop BCM4401 is connected through the SSB bus, that is connected to the
PCI-Express bus. SSB and B44 did not use standard PM wakeup functions
and did not forward wakeup settings to their parents.
To fix that B44 driver enables PM wakeup and registers new wakeup source
using device_set_wakeup_enable(). Wakeup is automatically reported to the p=
arent SSB
bus via power.wakeup_path. SSB bus enables wakeup for the parent PCI bridge=
, if there is any
child devices with enabled wakeup functionality. All other steps are
done by PM core code.

Signed-off-by: Andrey Skvortsov <Andrej.Skvortzov@gmail.com>
Signed-off-by: Michael Buesch <m@bues.ch>
---
 drivers/net/ethernet/broadcom/b44.c |    2 ++
 drivers/ssb/pcihost_wrapper.c       |   33 ++++++++++++++++++++++---------=
--
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/bro=
adcom/b44.c
index 416620f..ffeaf47 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2104,6 +2104,7 @@ static int b44_set_wol(struct net_device *dev, struct=
 ethtool_wolinfo *wol)
 		bp->flags &=3D ~B44_FLAG_WOL_ENABLE;
 	spin_unlock_irq(&bp->lock);
=20
+	device_set_wakeup_enable(bp->sdev->dev, wol->wolopts & WAKE_MAGIC);
 	return 0;
 }
=20
@@ -2452,6 +2453,7 @@ static int b44_init_one(struct ssb_device *sdev,
 		}
 	}
=20
+	device_set_wakeup_capable(sdev->dev, true);
 	netdev_info(dev, "%s %pM\n", DRV_DESCRIPTION, dev->dev_addr);
=20
 	return 0;
diff --git a/drivers/ssb/pcihost_wrapper.c b/drivers/ssb/pcihost_wrapper.c
index 69161bb..410215c 100644
--- a/drivers/ssb/pcihost_wrapper.c
+++ b/drivers/ssb/pcihost_wrapper.c
@@ -11,15 +11,17 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
=20
+#include <linux/pm.h>
 #include <linux/pci.h>
 #include <linux/export.h>
 #include <linux/slab.h>
 #include <linux/ssb/ssb.h>
=20
=20
-#ifdef CONFIG_PM
-static int ssb_pcihost_suspend(struct pci_dev *dev, pm_message_t state)
+#ifdef CONFIG_PM_SLEEP
+static int ssb_pcihost_suspend(struct device *d)
 {
+	struct pci_dev *dev =3D to_pci_dev(d);
 	struct ssb_bus *ssb =3D pci_get_drvdata(dev);
 	int err;
=20
@@ -28,17 +30,23 @@ static int ssb_pcihost_suspend(struct pci_dev *dev, pm_=
message_t state)
 		return err;
 	pci_save_state(dev);
 	pci_disable_device(dev);
-	pci_set_power_state(dev, pci_choose_state(dev, state));
+
+	/* if there is a wakeup enabled child device on ssb bus,
+	   enable pci wakeup posibility. */
+	device_set_wakeup_enable(d, d->power.wakeup_path);
+
+	pci_prepare_to_sleep(dev);
=20
 	return 0;
 }
=20
-static int ssb_pcihost_resume(struct pci_dev *dev)
+static int ssb_pcihost_resume(struct device *d)
 {
+	struct pci_dev *dev =3D to_pci_dev(d);
 	struct ssb_bus *ssb =3D pci_get_drvdata(dev);
 	int err;
=20
-	pci_set_power_state(dev, PCI_D0);
+	pci_back_from_sleep(dev);
 	err =3D pci_enable_device(dev);
 	if (err)
 		return err;
@@ -49,10 +57,12 @@ static int ssb_pcihost_resume(struct pci_dev *dev)
=20
 	return 0;
 }
-#else /* CONFIG_PM */
-# define ssb_pcihost_suspend	NULL
-# define ssb_pcihost_resume	NULL
-#endif /* CONFIG_PM */
+
+static const struct dev_pm_ops ssb_pcihost_pm_ops =3D {
+	SET_SYSTEM_SLEEP_PM_OPS(ssb_pcihost_suspend, ssb_pcihost_resume)
+};
+
+#endif /* CONFIG_PM_SLEEP */
=20
 static int ssb_pcihost_probe(struct pci_dev *dev,
 			     const struct pci_device_id *id)
@@ -115,8 +125,9 @@ int ssb_pcihost_register(struct pci_driver *driver)
 {
 	driver->probe =3D ssb_pcihost_probe;
 	driver->remove =3D ssb_pcihost_remove;
-	driver->suspend =3D ssb_pcihost_suspend;
-	driver->resume =3D ssb_pcihost_resume;
+#ifdef CONFIG_PM_SLEEP
+	driver->driver.pm =3D &ssb_pcihost_pm_ops;
+#endif
=20
 	return pci_register_driver(driver);
 }
--=20
1.7.2.5



--MP_/QT/kNMJ7KvKRApIb7eh/F3c--

--Sig_/Smtp5ohLhjRegDtU_y.qeRA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUfynhAAoJEPUyvh2QjYsOAv4QAIPve5oTD2MzWFR03PG1Xl2Z
Xqci1oYJ5iRkLHU6moW2lbZLjQvhig0vco65r9Vma9IRa5B0rqpEk9CDkwur3IWs
3uLVkW9E4g4VE2JjxSYn0qAoeqe4z2kKd7cGUECYJts4ckDbqohxgmdglHKFnpfA
fHPMX40fLe2aluuKs/Xr06k5gWcddMdp0bFkmLtanKiRcKFQizlAN08py0SJWlR8
cGmCjn0RcTb9OweEKmoj0NUc3JUNWFp8EaAWzRvnYRmyVmJ6QSDtDa9oauK0gHmz
m/79QrOtAKu7F1TKpMvkKDSMBiyQJLyS4THN5GO3+nGr8XEumVUpa9WF8lUuHcm/
0AR/dViWAr4j8/7vTHYpthXx7H0luS3Z7RcojeJPTU9I0s1bTvcVs18XZ6VpXvwF
IkGnz9Fez9FhPTf9mJUkO9zjrjjDbu08abAoukwoOrS+VEhRLcVdBiO9Ph7n6XEC
1WxtYhGdpsausIrLrumNXJXMuToGYsjFSO9ilNCgUNUeUz30Al4kkhmZnpJ2JT6Q
/nCsv6wmuBnWWdih5S0RBZIRvJ7arS4Pzklt1G3LOH5d7AC3qGxFFvNHCV7gnQdz
mIzfXEQ8URtlLwgsePbYFaaAhZhZaapZiFL7Z7ZKQ3FPJsatJPDpCbgBRgzcuptf
Ht88nRXA+C1b2qeedEAd
=BzqB
-----END PGP SIGNATURE-----

--Sig_/Smtp5ohLhjRegDtU_y.qeRA--
