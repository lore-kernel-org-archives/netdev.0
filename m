From: Kees Cook <kees.cook@canonical.com>
Subject: Re: [PATCH] net: clear heap allocations for privileged ethtool
 actions
Date: Thu, 7 Oct 2010 14:40:21 -0700
Message-ID: <20101007214021.GL14666@outflux.net>
References: <20101007211004.GA20267@outflux.net>
 <1286487085.3745.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1286487085.3745.99.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Thu, Oct 07, 2010 at 11:31:25PM +0200, Eric Dumazet wrote:
> Le jeudi 07 octobre 2010 =E0 14:10 -0700, Kees Cook a =E9crit :
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

This code is basically a max() call from what I see.

regbuf =3D kmalloc(max(regs.len, ops->get_regs_len(dev)), GFP_USER);

If the user passes regs.len =3D 1, it will be ignored in favor of regle=
n,
so we'll not write past the end of regbuf, unless I'm misunderstanding.

-Kees

--=20
Kees Cook
Ubuntu Security Team
