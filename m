From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] hso: fix refcnt leak in recent patch.
Date: Tue, 14 Apr 2015 17:35:27 +1000
Message-ID: <20150414173527.2e85be0e@notabene.brown>
References: <20150414093634.4fe24ba3@notabene.brown>
	<20150414110303.66edcfee@notabene.brown>
	<20150414065001.GA23791@thinkoso.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Z/uiD.wEuJTlQbnRKM=mXsF"; protocol="application/pgp-signature"
Cc: "David S. Miller" <davem@davemloft.net>,
	Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	GTA04 owners <gta04-owner@goldelico.com>
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34661 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbbDNHfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 03:35:38 -0400
In-Reply-To: <20150414065001.GA23791@thinkoso.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/Z/uiD.wEuJTlQbnRKM=mXsF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 14 Apr 2015 08:50:01 +0200 Olivier Sobrie <olivier@sobrie.be> wrote:

> Hello Neil,
>=20
> On Tue, Apr 14, 2015 at 11:03:03AM +1000, NeilBrown wrote:
> > On Tue, 14 Apr 2015 09:36:34 +1000 NeilBrown <neilb@suse.de> wrote:
> >=20
> > >=20
> > >=20
> > > Prior to
> > > commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> > >     hso: fix crash when device disappears while serial port is open
> > >=20
> > > hso_serial_open would always kref_get(&serial->parent->ref) before
> > > returning zero.
> > > Since that commit, it only calls kref_get when returning 0 if
> > > serial->port.count was zero.
> > >=20
> > > This results in calls to
> > >        kref_put(&serial->parent->ref, hso_serial_ref_free);
> > >=20
> > > after hso_serial_ref_free has been called, which dereferences a freed
> > > pointer.
> > >=20
> > > This patch adds the missing kref_get().
> > >=20
> > > Fixes: commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> > > Cc: stable@vger.kernel.org (v4.0)
> > > Cc: Olivier Sobrie <olivier@sobrie.be>
> > > Signed-off-by: NeilBrown <neilb@suse.de>
> > >=20
> > > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > > index 75befc1bd816..6848fc903340 100644
> > > --- a/drivers/net/usb/hso.c
> > > +++ b/drivers/net/usb/hso.c
> > > @@ -1299,6 +1299,7 @@ static int hso_serial_open(struct tty_struct *t=
ty, struct file *filp)
> > >  		}
> > >  	} else {
> > >  		D1("Port was already open");
> > > +		kref_get(&serial->parent->ref);
> > >  	}
> > > =20
> > >  	usb_autopm_put_interface(serial->parent->interface);
> >=20
> >=20
> > Sorry - that was wrong.
> > I'm getting crashes which strongly suggest the kref_put is being called=
 extra
> > times, but I misunderstood the code and was hasty.
> >=20
> > Maybe this instead?
>=20
> Indeed, if I undestand correctly the code in tty_io.c, cleanup() method
> is also called when the open fails while kref_get is only done if the
> open succeeds. Sorry for that mess.
> I assume you get that crash when hso_start_serial_device() returns
> an error?

Yes, that's correct.

>=20
> At first sight, the patch below looks good to me.
> I'll test it in the next days.

Thanks.

NeilBrown

>=20
> Thank you,
>=20
> Olivier
>=20
> >=20
> > Thanks,
> > NeilBrown
> >=20
> > From: NeilBrown <neil@brown.name>
> > Date: Tue, 14 Apr 2015 09:33:03 +1000
> > Subject: [PATCH] hso: fix refcnt leak in recent patch.
> >=20
> > Prior to
> > commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> >     hso: fix crash when device disappears while serial port is open
> >=20
> > a kref_get on serial->parent->ref would be taken on each open,
> > and it would be kref_put on each close.
> >=20
> > Now the kref_put happens when the tty_struct is finally put (via
> > the 'cleanup') providing tty->driver_data has been set.
> > So the kref_get must be called exact once when tty->driver_data is
> > set.
> >=20
> > With the current code, if the first open fails the kref_get() is never
> > called, but the kref_put() is called, leaving to a crash.
> >=20
> > So change the kref_get call to happen exactly when ->driver_data is
> > changed from NULL to non-NULL.
> >=20
> > Fixes: commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
> > Cc: stable@vger.kernel.org (v4.0)
> > Cc: Olivier Sobrie <olivier@sobrie.be>
> > Signed-off-by: NeilBrown <neil@brown.name>
> >=20
> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > index 75befc1bd816..17fd3820263a 100644
> > --- a/drivers/net/usb/hso.c
> > +++ b/drivers/net/usb/hso.c
> > @@ -1278,6 +1278,8 @@ static int hso_serial_open(struct tty_struct *tty=
, struct file *filp)
> >  	D1("Opening %d", serial->minor);
> > =20
> >  	/* setup */
> > +	if (tty->driver_data =3D=3D NULL)
> > +		kref_get(&serial->parent->ref);
> >  	tty->driver_data =3D serial;
> >  	tty_port_tty_set(&serial->port, tty);
> > =20
> > @@ -1294,8 +1296,6 @@ static int hso_serial_open(struct tty_struct *tty=
, struct file *filp)
> >  		if (result) {
> >  			hso_stop_serial_device(serial->parent);
> >  			serial->port.count--;
> > -		} else {
> > -			kref_get(&serial->parent->ref);
> >  		}
> >  	} else {
> >  		D1("Port was already open");
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--Sig_/Z/uiD.wEuJTlQbnRKM=mXsF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVSzDPznsnt1WYoG5AQLcSA//dFN7CKQ/FmIMy8p3xrNQ6fDVmMvDIq2n
pnEHRiPW31xbIWifKBHKfel96FIB0X8hehzfNTOmma16Ygz+MgAYLfdZLV2hXKj0
8K9XsFspl5gFoGGL2p0l80+Z3IZak/02cT9kJ4mzaWSSgVQFRDneX9e1hPofJQZa
7r1I2peWpAQqqBZYa4q0tn6kUrReRq7rs5YGu3LXIU83YzAj1eGoWJSHEleiLsg5
OrGEXom+RvQ/a7CBpwCZACK9bG6cuXvoPSrJwOjN9FOX/ln9I5Db1Y5JJvUFnz3T
nG2wRbokDwsHMBNSD4rx7zHzlLwHauJxRqi9JjrXKsTYqXYIu/uLFPAnbX76mRFb
5c/HE7Xxw6eGI7oWRfrSY7BL0gUMBeuLGPi3D7l2hFOnA80cfHCDVw5KRoXx1Loz
tgHtotmV639iV9wXDNXEAyqbKBsT19XLn2moaYD7BRRVXeN4x5vmwl9mSJioPJG/
Si0RMtwFxxKwJDDxcV3FXL7DiRjeLuAhQkF/Pfj6i/kv+W3+alYU51uVsrTHAE1m
qKg6X9V9j2ru0eEQVxYBaNQ+OzFsgCKR8Z1E3yIR2LaQe2Ei5ZdOFAdZ3jM+mqcF
YTdCaZKwo7TBJUosW3PKW/6Sc9ezZv4ypAac3G/3msv55JJIlPq/U4SteQizXpKw
wXkoRF6eryg=
=b4zS
-----END PGP SIGNATURE-----

--Sig_/Z/uiD.wEuJTlQbnRKM=mXsF--
