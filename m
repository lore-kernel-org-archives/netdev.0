From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: r8189 mac address changes persist across reboot (was:
	duplicate MAC addresses)
Date: Wed, 2 Sep 2009 18:32:53 +0400
Message-ID: <20090902143253.GA3239@newmaster.mivlgu.local>
References: <9b2b86520908230314q37d07da6mbde9dc48ad5a17ce@mail.gmail.com> <4A9CD443.6030603@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+HP7ph2BbKc20aGI"
Cc: Alan Jenkins <sourcejedi.lkml@googlemail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	marty <marty@goodoldmarty.com>, linux-hotplug@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Mikael Pettersson <mikpe@it.uu.se>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mivlgu.ru ([195.20.195.134]:44415 "EHLO mail.mivlgu.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339AbZIBO4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 10:56:47 -0400
Content-Disposition: inline
In-Reply-To: <4A9CD443.6030603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 01, 2009 at 09:58:59AM +0200, Ivan Vecera wrote:
> Alan Jenkins napsal(a):
[...]
> > Looking at r8169.c confirms this.  It doesn't appear to initialize the
> > MAC address register from elsewhere; it just uses the current value.
> > It will also report this initial value as the "permanent" MAC address,
> > which your report suggests is wrong.  I think your problem is a bug in
> > r8169.
> >=20
> > Francois, I found a datasheet for the 8139; it was claimed to be
> > similar and it does indeed appear so.  The datasheet suggests that the
> > driver needs to provoke "auto-load" from the EEPROM at load time.
> > Could you please have a look at fixing this, so that MAC address
> > changes do not persist over a reboot?
> >=20
> Using auto-loading method is not possible for all new Realtek products
> (mainly for PCI-E chipsets). I asked the Realtek engineers and this
> is the answer:
> Q: Is it possible to use HW register at offset 50h to reload the MAC
>    address from EEPROM or somewhere else? I mean the usage of Auto-load
>    mode (bits EEM1=3D0 and EEM0=3D1 in 50h HW reg).
> A: Current new LANs don't load mac address throught autoload command.
>    You need to read it out from external eeprom or internal efuse then
>    put it back to ID0~ID5.
>=20
> So you need to read the MAC address from the EEPROM and then write it into
> ID0-ID5 registers. I already created the patch that initializes the MAC
> address from EEPROM but there were some issues with this patch so it was
> reverted. Mikael reported that the MAC address from its adapter (on Thecus
> n2100) is read only partly (first 3 bytes were correct but the rest were
> zeros). Later we found that the MAC address is correct and there are real=
ly
> 3 correct bytes + 3 zeros in EEPROM. The Thecus n2100 system probably uses
> only these 3 bytes and the remaining 3 bytes fills in by itself (they are
> probably stored somewhere in the firmware).

Unfortunately, this kind of crap (crucial information such as MAC
addresses stored in places known only to some proprietary firmware) is
too common with recent devices (e.g., forcedeth has the same problem
even on PCs).

> I have tested my patch with several different realtek NICs without any
> problem but what should we do with embedded system like the n2100 that
> initializes the MAC in other way.
>=20
> There are 2 possibilities:
> 1) There could be an additional module param to enable/disable the MAC
>    initialization
> 2) The MAC address read from EEPROM will be checked against the current
>    MAC address in ID0-5 registers. And the current MAC will be replaced
>    by the one from EEPROM only if the first 3 bytes (OUI part) are
>    different.

 3) Try the same solution as forcedeth does - save original contents
    of MAC address registers in rtl8169_init_one() (we already have
    perm_addr available for this; forcedeth uses a separate variable
    due to its "reversed MAC" brain damage), then restore MAC to its
    initial state in rtl8169_remove_one() (to handle module reload)
    and rtl_shutdown() (for soft reboot or kexec), and hope that on an
    unexpected hard reboot the firmware will reinit the chip properly.

--+HP7ph2BbKc20aGI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFKnoIVW82GfkQfsqIRAt1pAJ4x41t5E82cG7pJNfjvUIuuI1LC7wCeI0FN
2rlUL3Pg/PpX+H1LGvrgsvA=
=WWtd
-----END PGP SIGNATURE-----

--+HP7ph2BbKc20aGI--
