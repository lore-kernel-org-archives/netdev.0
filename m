From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: clear heap allocations for privileged ethtool
 actions
Date: Thu, 07 Oct 2010 23:31:25 +0200
Message-ID: <1286487085.3745.99.camel@edumazet-laptop>
References: <20101007211004.GA20267@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Kees Cook <kees.cook@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44625 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab0JGVeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 17:34:00 -0400
In-Reply-To: <20101007211004.GA20267@outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 14:10 -0700, Kees Cook a =C3=A9crit :
> Several other ethtool functions leave heap uncleared (potentially) by
> drivers. Some interfaces appear safe (eeprom, etc), in that the sizes
> are well controlled. In some situations (e.g. unchecked error conditi=
ons),
> the heap will remain unchanged in areas before copying back to usersp=
ace.
> Note that these are less of an issue since these all require CAP_NET_=
ADMIN.

> @@ -775,7 +775,7 @@ static int ethtool_get_regs(struct net_device *de=
v, char __user *useraddr)
>  	if (regs.len > reglen)
>  		regs.len =3D reglen;
> =20
> -	regbuf =3D kmalloc(reglen, GFP_USER);
> +	regbuf =3D kzalloc(reglen, GFP_USER);
>  	if (!regbuf)
>  		return -ENOMEM;
> =20
> --=20
> 1.7.1
>=20

Are you sure this is not hiding a more problematic problem ?

Code does :

reglen =3D ops->get_regs_len(dev);
if (regs.len > reglen)
	regs.len =3D reglen;
regbuf =3D kmalloc(reglen, GFP_USER);

So we can not copy back kernel memory.

However, what happens if user provides regs.len =3D 1 byte, and driver
get_regs() doesnt properly checks regs.len and write past end of regbuf
-> We probably write on other parts of kernel memory

An audit is needed, but first driver I checked is buggy
(drivers/net/qlcnic/qlcnic_ethtool.c)

->
 	memset(p, 0, qlcnic_get_regs_len(dev));



