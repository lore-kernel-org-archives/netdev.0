From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Mon, 1 Dec 2014 22:10:23 +0100
Message-ID: <20141201221023.79ffb40d@wiggum>
References: <20141201111125.GA11974@localhost.localdomain>
 <1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/05kibT8D9YkPZAXOo9_36Hi"; protocol="application/pgp-signature"
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/05kibT8D9YkPZAXOo9_36Hi
Content-Type: multipart/mixed; boundary="MP_/dXdEufUqr_gri=O3pJ2Y_5H"

--MP_/dXdEufUqr_gri=O3pJ2Y_5H
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Mon,  1 Dec 2014 23:46:38 +0300
Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:

> Wake On Lan was not working on laptop DELL Vostro 1500.
> If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs blinke=
d.
> But the laptop could not be woken up with the Magic Packet. The reason for
> that was that PCIE was not enabled as a system wakeup source and
> therefore the host PCI bridge was not powered up in suspend mode.
> PCIE was not enabled in suspend by PM because no child devices were
> registered as wakeup source during suspend process.
> On laptop BCM4401 is connected through the SSB bus, that is connected to =
the
> PCI-Express bus. SSB and B44 did not use standard PM wakeup functions
> and did not forward wakeup settings to their parents.
> To fix that B44 driver enables PM wakeup and registers new wakeup source
> using device_set_wakeup_enable(). Wakeup is automatically reported to the=
 parent SSB
> bus via power.wakeup_path. SSB bus enables wakeup for the parent PCI brid=
ge, if there is any
> child devices with enabled wakeup functionality. All other steps are
> done by PM core code.

Thanks, this looks good.
I assume you tested this (I currently don't have a device to test this).

Larry, Rafa=C5=82, any other b43 user:
Can you please test whether this doesn't cause regressions for suspend/resu=
me on b43?
(Patch is attached as reference)


> Signed-off-by: Andrey Skvortsov <Andrej.Skvortzov@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/b44.c |    2 ++
>  drivers/ssb/pcihost_wrapper.c       |   33 ++++++++++++++++++++++-------=
----
>  2 files changed, 24 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/b=
roadcom/b44.c
> index 416620f..ffeaf47 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -2104,6 +2104,7 @@ static int b44_set_wol(struct net_device *dev, stru=
ct ethtool_wolinfo *wol)
>  		bp->flags &=3D ~B44_FLAG_WOL_ENABLE;
>  	spin_unlock_irq(&bp->lock);
> =20
> +	device_set_wakeup_enable(bp->sdev->dev, wol->wolopts & WAKE_MAGIC);
>  	return 0;
>  }
> =20
> @@ -2452,6 +2453,7 @@ static int b44_init_one(struct ssb_device *sdev,
>  		}
>  	}
> =20
> +	device_set_wakeup_capable(sdev->dev, true);
>  	netdev_info(dev, "%s %pM\n", DRV_DESCRIPTION, dev->dev_addr);
> =20
>  	return 0;
> diff --git a/drivers/ssb/pcihost_wrapper.c b/drivers/ssb/pcihost_wrapper.c
> index 69161bb..410215c 100644
> --- a/drivers/ssb/pcihost_wrapper.c
> +++ b/drivers/ssb/pcihost_wrapper.c
> @@ -11,15 +11,17 @@
>   * Licensed under the GNU/GPL. See COPYING for details.
>   */
> =20
> +#include <linux/pm.h>
>  #include <linux/pci.h>
>  #include <linux/export.h>
>  #include <linux/slab.h>
>  #include <linux/ssb/ssb.h>
> =20
> =20
> -#ifdef CONFIG_PM
> -static int ssb_pcihost_suspend(struct pci_dev *dev, pm_message_t state)
> +#ifdef CONFIG_PM_SLEEP
> +static int ssb_pcihost_suspend(struct device *d)
>  {
> +	struct pci_dev *dev =3D to_pci_dev(d);
>  	struct ssb_bus *ssb =3D pci_get_drvdata(dev);
>  	int err;
> =20
> @@ -28,17 +30,23 @@ static int ssb_pcihost_suspend(struct pci_dev *dev, p=
m_message_t state)
>  		return err;
>  	pci_save_state(dev);
>  	pci_disable_device(dev);
> -	pci_set_power_state(dev, pci_choose_state(dev, state));
> +
> +	/* if there is a wakeup enabled child device on ssb bus,
> +	   enable pci wakeup posibility. */
> +	device_set_wakeup_enable(d, d->power.wakeup_path);
> +
> +	pci_prepare_to_sleep(dev);
> =20
>  	return 0;
>  }
> =20
> -static int ssb_pcihost_resume(struct pci_dev *dev)
> +static int ssb_pcihost_resume(struct device *d)
>  {
> +	struct pci_dev *dev =3D to_pci_dev(d);
>  	struct ssb_bus *ssb =3D pci_get_drvdata(dev);
>  	int err;
> =20
> -	pci_set_power_state(dev, PCI_D0);
> +	pci_back_from_sleep(dev);
>  	err =3D pci_enable_device(dev);
>  	if (err)
>  		return err;
> @@ -49,10 +57,12 @@ static int ssb_pcihost_resume(struct pci_dev *dev)
> =20
>  	return 0;
>  }
> -#else /* CONFIG_PM */
> -# define ssb_pcihost_suspend	NULL
> -# define ssb_pcihost_resume	NULL
> -#endif /* CONFIG_PM */
> +
> +static const struct dev_pm_ops ssb_pcihost_pm_ops =3D {
> +	SET_SYSTEM_SLEEP_PM_OPS(ssb_pcihost_suspend, ssb_pcihost_resume)
> +};
> +
> +#endif /* CONFIG_PM_SLEEP */
> =20
>  static int ssb_pcihost_probe(struct pci_dev *dev,
>  			     const struct pci_device_id *id)
> @@ -115,8 +125,9 @@ int ssb_pcihost_register(struct pci_driver *driver)
>  {
>  	driver->probe =3D ssb_pcihost_probe;
>  	driver->remove =3D ssb_pcihost_remove;
> -	driver->suspend =3D ssb_pcihost_suspend;
> -	driver->resume =3D ssb_pcihost_resume;
> +#ifdef CONFIG_PM_SLEEP
> +	driver->driver.pm =3D &ssb_pcihost_pm_ops;
> +#endif
> =20
>  	return pci_register_driver(driver);
>  }




--=20
Michael

--MP_/dXdEufUqr_gri=O3pJ2Y_5H
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



--MP_/dXdEufUqr_gri=O3pJ2Y_5H--

--Sig_/05kibT8D9YkPZAXOo9_36Hi
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUfNk/AAoJEPUyvh2QjYsObEgQAL/O0yBdZCOsVTJgTcevSD/j
7L6NiE546W7SNmqK1RmIBPE6nijIxJzZ4YlSUnb5ppiRV7UIVte5Zfdv/oJJ6GjQ
ov1FvRPy15fk0qanoJP+r5ebV1fsgyPUgVatbNKmWx+FLcK1nYCNTao85eS9AgcH
xjXO07jzHtSFLxhLWqScOCeGuIkS4VUvHHlp1Ne/UR9O81G5USR2CNLyS9QsMMn2
6yQU3ITyzLHfY1fGFOgwN1JGmBU8ovVglby5Ixpeac03oM2ZM2UELWtLQoxShXfl
lHBX+jwPicoPcNVXBBqcI8ocEJmYcQChBHHB/0eYK84xR4O37k0l9I5apP9O9oIS
RehHlr/SiJCTfRc7MkevgChViGJjXvVfyrSKxoOVyxlfBUdb6xMEUo64Os/fpVMf
31ClOObdBiPvrSzLGEYzrFcrzsO8MUeILwhK96M3JuK+8cs6oehgNUi+0dqonc/0
qBjXIEcp38eAgeEYToHOJnaJw1IZfkdtMKdcsEOhZSRwcPGr2nwB3sJB2RTOwmTk
vykdR6loAGiHvAewNP5qDT4krEpHvjKASOf7sThKETMDFlozdbsOmnAi1recND4Q
MKQa1roZf0TLB0tsliLcjaXN+1cBTjzzU/kSJ1z+YttqfI2NsLkoyWM+CZhlcKMP
gRIdjL7dKMU8KQNGjE3V
=neWB
-----END PGP SIGNATURE-----

--Sig_/05kibT8D9YkPZAXOo9_36Hi--
