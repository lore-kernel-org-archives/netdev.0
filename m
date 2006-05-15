From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 17:12:20 +0200
Message-ID: <200605151712.23639.IvDoorn@gmail.com>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <1147703855.2193.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3818847.DKJECAU11o";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Mark Wallis <mwallis@serialmonkey.com>, netdev@vger.kernel.org,
	David Zeuthen <davidz@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:9432 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964962AbWEOPK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 11:10:27 -0400
Received: by nf-out-0910.google.com with SMTP id p77so19062nfc
        for <netdev@vger.kernel.org>; Mon, 15 May 2006 08:10:26 -0700 (PDT)
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1147703855.2193.47.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3818847.DKJECAU11o
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 15 May 2006 16:37, Dan Williams wrote:
> On Mon, 2006-05-15 at 22:57 +1000, Mark Wallis wrote:
> > Hi everyone,
> >=20
> > Currently, in our rt2x00 (using the devicescape stack) we are firing of=
f an
> > ACPI event so that the hardware button can be handled in userspace. This
> > allows the user to basically do whatever they want when this button is
> > pressed - including bringing down the wireless interface. The problem h=
ere
> > is no distro's currently contain scripts to run from this event so for =
many
> > users it just "doesn't work" without them manually having to write scri=
pts
> > to handle the ACPI even themselves.
> >=20
> > Some people are saying that instead of throwing and ACPI event we shoul=
d be
> > either use hotplug or internally just disable the radio and somehow inf=
orm
> > the dscape stack that the radio has been disabled.
> >=20
> > What are peoples thoughts here, should we=20
> >=20
> > A. be handling this within our drivers and doing "what the user expects=
" and
> > disabling the hardware radio, or=20
>=20
> > B. should we be firing an ACPI event and getting the distro's to add sc=
ripts
> > so when this event is fired they bring down all the wireless interfaces.
>=20
> (had this issue in the back of my head for a while already...)
>=20
> Isn't the rf-kill switch specific to the manufacturer lots of times?  Is
> the switch connected directly to the card, or is it incumbent on the
> driver to notice the event and disable the card via software?  We need
> to handle this for Bluetooth too, in situations where there's both a
> bluetooth and an 802.11 card in the box.  Does the rf-kill apply to
> both?  Or just to one?

The rt2x00 device itself does nothing when the button is pressed, it only
updates certain fields in a register to indicate the button is pressed.
The driver should read from the EEPROM if a hardware button is available,
after that it should poll the register to see if the button has been presse=
d,
and it is up to the driver what to do.

> WRT to disabling the radio, I'm not sure it makes a difference either
> way.  Hitting a button generally means "do this _NOW_", so it makes
> sense for the driver to disable the radio and then send out the event.
> Apps need to be able to deal with these resources going out from
> underneath them, and I'm not sure it makes sense to wait around for some
> scripts to run that just might possibly at some future point disable it,
> but you're never sure.

Well I would think it is cleaner to inform userspace that the button is pre=
ssed
and let userspace sort out what exactly should happen.
But I doubt it will be a good idea when the driver is sending and event _an=
d_
disabled the radio. It could be that the user wants something to be done
before the radio is being disabled.

> In the end, an ACPI event is probably fine.  I must stress that we NEED
> to have a common event structure for this, such that every driver and
> card presents the same interface.  I don't want to have to write stuff
> for each of 3 or 4 different cards to notice the rf-kill stuff.  Witness
> all the extra binaries that each driver has already for this sort of
> thing.  What interface does the ipw[2|3]xxx driver and hardware present?
> What common bits can be drawn out from both?
>=20
> Ideally, here's what would happen:  the driver/card/whatever generates
> an ACPI event, which is noticed by HAL.  HAL sets a property on the
> _exact_ device which the event is for, and propagates the signal out
> over dbus.  Any interested application can listen for, and respond to,
> the rf-kill signal.  (or, the event can be handled by acpid and the
> distro can run scripts for it.  01dsk001.  whatever)

This idea sounds good, but is ACPI the thing to be used.
Escpially since ACPI is a bit architectures dependent.
And the solution should be supported on various architectures.

> But this means a few things.  We need:
>=20
> 1) common interface/signal for _all_ cards and drivers
> 2) Enough information to identify which specific pci/pcmcia/etc device
> the event is for (or system-wide?)

system-wide would not be a good idea, we need something to determine which
driver exactly has triggered the event. Some laptops have several hardware =
buttons
1 for Bluetooth and 1 for Wifi for example.

So we could just pass the name the driver has created for that button to us=
erspace.
At least that is a similar approach to ACPI where the class, bid and name f=
ields
are all names set by the driver.

--nextPart3818847.DKJECAU11o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEaJpXaqndE37Em0gRAocdAKDI4Rv9gUhoJWvcsEFHXflYc5pJwgCg0tDu
hyrEYJ0jB0dMVWbQobYHNec=
=rYQD
-----END PGP SIGNATURE-----

--nextPart3818847.DKJECAU11o--
