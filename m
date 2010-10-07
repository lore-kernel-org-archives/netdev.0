From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: clear heap allocations for privileged ethtool
 actions
Date: Thu, 07 Oct 2010 22:40:07 +0100
Message-ID: <1286487607.2271.42.camel@achroite.uk.solarflarecom.com>
References: <20101007211004.GA20267@outflux.net>
	 <1286487085.3745.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286487085.3745.99.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-10-07 at 23:31 +0200, Eric Dumazet wrote:
> Le jeudi 07 octobre 2010 =C3=A0 14:10 -0700, Kees Cook a =C3=A9crit :
> > Several other ethtool functions leave heap uncleared (potentially) =
by
> > drivers. Some interfaces appear safe (eeprom, etc), in that the siz=
es
> > are well controlled. In some situations (e.g. unchecked error condi=
tions),
> > the heap will remain unchanged in areas before copying back to user=
space.
> > Note that these are less of an issue since these all require CAP_NE=
T_ADMIN.
>=20
> > @@ -775,7 +775,7 @@ static int ethtool_get_regs(struct net_device *=
dev, char __user *useraddr)
> >  	if (regs.len > reglen)
> >  		regs.len =3D reglen;
> > =20
> > -	regbuf =3D kmalloc(reglen, GFP_USER);
> > +	regbuf =3D kzalloc(reglen, GFP_USER);

Actually, I recently changed this to vmalloc() so your patch won't
apply.

> >  	if (!regbuf)
> >  		return -ENOMEM;
> > =20
> > --=20
> > 1.7.1
> >=20
>=20
> Are you sure this is not hiding a more problematic problem ?
>=20
> Code does :
>=20
> reglen =3D ops->get_regs_len(dev);
> if (regs.len > reglen)
> 	regs.len =3D reglen;
> regbuf =3D kmalloc(reglen, GFP_USER);
>=20
> So we can not copy back kernel memory.
>=20
> However, what happens if user provides regs.len =3D 1 byte, and drive=
r
> get_regs() doesnt properly checks regs.len and write past end of regb=
uf
> -> We probably write on other parts of kernel memory
[...]

Why should the driver's get_regs() check regs.len?  The buffer is
allocated based on reglen which is provided by the driver, not the user=
=2E

reglen (length of the kernel buffer) is not reduced; regs.len (length o=
f
the user buffer) is.  That lets the user know how much of the user
buffer was actually used.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
