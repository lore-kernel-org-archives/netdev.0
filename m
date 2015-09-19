From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/7] Phy and mdiobus fixes
Date: Sat, 19 Sep 2015 13:49:35 -0700
Message-ID: <55FDCA5F.9090604@gmail.com>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Robert Richter <rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?Q?S=c3=b6ren_Brinkmann?= <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Sunil Goutham <sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150918094625.GB21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 09/18/15 02:46, Russell King - ARM Linux a =C3=A9crit :
> Hi,
>=20
> While looking at the phy code, I identified a number of weaknesses
> where refcounting on device structures was being leaked, where
> modules could be removed while in-use, and where the fixed-phy could
> end up having unintended consequences caused by incorrect calls to
> fixed_phy_update_state().
>=20
> This patch series resolves those issues, some of which were discovere=
d
> with testing on an Armada 388 board.  Not all patches are fully teste=
d,
> particularly the one which touches several network drivers.
>=20
> When resolving the struct device refcounting problems, several differ=
ent
> solutions were considered before settling on the implementation here =
-
> one of the considerations was to avoid touching many network drivers.
> The solution here is:
>=20
> 	phy_attach*() - takes a refcount
> 	phy_detach*() - drops the phy_attach refcount
>=20
> Provided drivers always attach and detach their phys, which they shou=
ld
> already be doing, this should change nothing, even if they leak a ref=
count.
>=20
> 	of_phy_find_device() and of_* functions which use that take
> 	a refcount.  Arrange for this refcount to be dropped once
> 	the phy is attached.
>=20
> This is the reason why the previous change is important - we can't dr=
op
> this refcount taken by of_phy_find_device() until something else hold=
s
> a reference on the device.  This resolves the leaked refcount caused =
by
> using of_phy_connect() or of_phy_attach().
>=20
> Even without the above changes, these drivers are leaking by calling
> of_phy_find_device().  These drivers are addressed by adding the
> appropriate release of that refcount.
>=20
> The mdiobus code also suffered from the same kind of leak, but thankf=
ully
> this only happened in one place - the mdio-mux code.
>=20
> I also found that the try_module_get() in the phy layer code was utte=
rly
> useless: phydev->dev.driver was guaranteed to always be NULL, so
> try_module_get() was always being called with a NULL argument.  I pro=
ved
> this with my SFP code, which declares its own MDIO bus - the module u=
se
> count was never incremented irrespective of how I set the MDIO bus up=
=2E
> This allowed the MDIO bus code to be removed from the kernel while th=
ere
> were still PHYs attached to it.
>=20
> One other bug was discovered: while using in-band-status with mvneta,=
 it
> was found that if a real phy is attached with in-band-status enabled,
> and another ethernet interface is using the fixed-phy infrastructure,=
 the
> interface using the fixed-phy infrastructure is configured according =
to
> the other interface using the in-band-status - which is caused by the
> fixed-phy code not verifying that the phy_device passed in is actuall=
y
> a fixed-phy device, rather than a real MDIO phy.
>=20
> Lastly, having mdio_bus reversing phy_device_register() internals see=
ms
> like a layering violation - it's trivial to move that code to the phy
> device layer.

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks!
--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
