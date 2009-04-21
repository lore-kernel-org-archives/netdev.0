From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: Re: [PATCH] e100: do not go D3 in shutdown unless system is
	powering off
Date: Tue, 21 Apr 2009 18:52:48 -0300
Message-ID: <20090421215248.GF6147@vespa.holoscopio.com>
References: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com> <200904202114.01932.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pyE8wggRBhVBcj8z"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.18.203]:51467 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbZDUVw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 17:52:56 -0400
Content-Disposition: inline
In-Reply-To: <200904202114.01932.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pyE8wggRBhVBcj8z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 20, 2009 at 09:13:59PM +0200, Rafael J. Wysocki wrote:
> On Monday 20 April 2009, Thadeu Lima de Souza Cascardo wrote:
> > After experimenting with kexec with the last merges after 2.6.29, I've
> > had some problems when probing e100. It would not read the eeprom. After
> > some bisects, I realized this has been like that since forever (at least
> > 2.6.18). The problem is that shutdown is doing the same thing that
> > suspend does and puts the device in D3 state. I couldn't find a way to
> > get the device back to a sane state in the probe function. So, based on
> > some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
> > I wrote this one for e100.
> >=20
> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> > ---
> >  drivers/net/e100.c |   27 +++++++++++++++++++++------
> >  1 files changed, 21 insertions(+), 6 deletions(-)
> >=20
> > diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> > index c0f8443..3db7b29 100644
> > --- a/drivers/net/e100.c
> > +++ b/drivers/net/e100.c
> > @@ -2728,7 +2728,7 @@ static void __devexit e100_remove(struct pci_dev =
*pdev)
> >  #define E100_82552_SMARTSPEED   0x14   /* SmartSpeed Ctrl register */
> >  #define E100_82552_REV_ANEG     0x0200 /* Reverse auto-negotiation */
> >  #define E100_82552_ANEG_NOW     0x0400 /* Auto-negotiate now */
> > -static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
> > +static int __e100_shutdown(struct pci_dev *pdev, bool *enable_wake)
> >  {
> >  	struct net_device *netdev =3D pci_get_drvdata(pdev);
> >  	struct nic *nic =3D netdev_priv(netdev);
> > @@ -2749,19 +2749,31 @@ static int e100_suspend(struct pci_dev *pdev, p=
m_message_t state)
> >  			           E100_82552_SMARTSPEED, smartspeed |
> >  			           E100_82552_REV_ANEG | E100_82552_ANEG_NOW);
> >  		}
> > -		if (pci_enable_wake(pdev, PCI_D3cold, true))
> > -			pci_enable_wake(pdev, PCI_D3hot, true);
> > +		*enable_wake =3D true;
> >  	} else {
> > -		pci_enable_wake(pdev, PCI_D3hot, false);
> > +		*enable_wake =3D false;
> >  	}
> > =20
> >  	pci_disable_device(pdev);
> > -	pci_set_power_state(pdev, PCI_D3hot);
> > =20
> >  	return 0;
> >  }
> > =20
> > +static void __e100_power_off(struct pci_dev *pdev, bool wake)
> > +{
> > +	pci_enable_wake(pdev, PCI_D3hot, wake);
> > +	pci_set_power_state(pdev, PCI_D3hot);
> > +}
> > +
> >  #ifdef CONFIG_PM
> > +static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
> > +{
> > +	bool wake;
> > +	int retval =3D __e100_shutdown(pdev, &wake);
>=20
> I'd call pci_prepare_to_sleep() here if wake is 'true' instead of the
> __e100_power_off(), because there is a chance the platform will prefer so=
me
> other power state to put the device into.
>=20
> In fact, looking at the entire driver's code, I think you could just call
> pci_prepare_to_sleep(pdev) here instead of __e100_power_off(pdev, wake)
> and discard the value of wake.
>=20

If there is no advantage in using pci_enable_wake with false in the case
the device cannot WOL or ASF, I will just use pci_prepare_to_sleep and
drop this enable_wake/wake variable in both suspend and shutdown. Any
reason we should use pci_enable_wake with false?

> > +	__e100_power_off(pdev, wake);
>=20
> Also, retval will always be 0 as far as I can see and if it could be diff=
erent
> from 0, it would be a good idea to return the error code before putting t=
he
> device into a low power state (.resume() won't be called for this device =
if
> .suspend() fails).
>=20
> Apart from this, the patch looks fine to me.
>=20
> > +	return retval;
> > +}
> > +
> >  static int e100_resume(struct pci_dev *pdev)
> >  {
> >  	struct net_device *netdev =3D pci_get_drvdata(pdev);
> > @@ -2792,7 +2804,10 @@ static int e100_resume(struct pci_dev *pdev)
> > =20
> >  static void e100_shutdown(struct pci_dev *pdev)
> >  {
> > -	e100_suspend(pdev, PMSG_SUSPEND);
> > +	bool wake;
> > +	__e100_shutdown(pdev, &wake);
> > +	if (system_state =3D=3D SYSTEM_POWER_OFF)
> > +		__e100_power_off(pdev, wake);
> >  }
> > =20
> >  /* ------------------ PCI Error Recovery infrastructure  -------------=
- */
>=20
> Best,
> Rafael

--pyE8wggRBhVBcj8z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknuQDAACgkQyTpryRcqtS0MBACdEMNotwOrFJuyPhk66aV6iZgp
dMwAn3YWh7IbDvdQAV6KWqm9gW8QL6OQ
=Unx6
-----END PGP SIGNATURE-----

--pyE8wggRBhVBcj8z--
