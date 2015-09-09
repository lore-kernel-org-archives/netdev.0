From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Wed, 9 Sep 2015 21:08:05 +0200
Message-ID: <20150909190805.GA26699@calimero.vinschen.de>
References: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de>
 <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de>
 <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com>
 <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de>
 <55F07BBC.9020308@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:53082 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbIITII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:08:08 -0400
Content-Disposition: inline
In-Reply-To: <55F07BBC.9020308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  9 20:34, poma wrote:
> On 09/09/2015 05:55 PM, Corinna Vinschen wrote:
> > On Sep  9 17:54, Corinna Vinschen wrote:
> >> On Sep  9 17:24, poma wrote:
> >>> [PATCH net] r8169: Fix sleeping function called during get_stats64
> >>> http://marc.info/?l=3Dlinux-netdev&m=3D144180123410135&q=3Draw
> >>> - the noise is still present
> >>
> >> Are you really sure?  The entire dma_alloc/dma_free stuff has been mov=
ed
> >> away.  There's no locking or sleeping involved different from what was
> >> there before my original patch when calling .ndo_get_stats64.
> >>
>=20
>=20
> It is literally the kernel ring buffer output,
> so I really can not understand your question.

I'm asking because I'm wondering if you're actually testing the
right r8169.ko module, the one with the patch applied.  See below.

> >> How would I be able to reproduce this on the command line?
>=20
> This I have already written, here's once more for you,
> <quote>
>  This noise is induced via userspace, xfce4-netload-plugin,
>  http://goodies.xfce.org/projects/panel-plugins/xfce4-netload-plugin
>=20
>  $ grep -i device .config/xfce4/panel/netload-16.rc
>  Network_Device=3Denp3s0
>=20
>  $ ethtool -i enp3s0 | grep driver
>  driver: r8169
> </quote>
>=20
> Therefore, to try to reproduce this issue, 'xfce4-netload-plugin' must ru=
n within 'xfce4-panel',
> moreover 'xfce4-netload-plugin' must be configured to monitor affected ne=
twork interface.

I'lll see if I can try this tomorrow.

> No command line this time, hombre.

If it has to be spanish, I'd prefer mujer, but whatever.

> > It would also be interesting to see the "noise" as it looks after
> > applying the above patch...
>=20
> The "noise" after applying "r8169: Fix sleeping function called during ge=
t_stats64":
> [...]
> [  215.049067] Call Trace:
> [  215.049078]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
> [  215.049090]  [<ffffffff81100d77>] lockdep_rcu_suspicious+0xd7/0x110
> [  215.049099]  [<ffffffff810d5377>] ___might_sleep+0xa7/0x230
> [  215.049107]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
> [  215.049121]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
> [  215.049130]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
> [  215.049141]  [<ffffffff81024b29>] ? sched_clock+0x9/0x10
> [  215.049149]  [<ffffffff810e258c>] ? local_clock+0x1c/0x20
> [  215.049157]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
> [  215.049168]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
> [  215.049178]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
> [  215.049193]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
> [  215.049208]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r816=
9]

This is very certainly not the r8169.ko driver with my patch applied.
There is no rtl8169_map_counters function anymore, just as with
Francois' patch.  I'm not sure what you're doing wrong there, but this
stack dump definitely cannot be produced with either Francois or my
patch, so you're apparently testing the unpatched upstream driver all
the time.

> ...
> etc.
>   etc.
>     etc.
>=20
> This looks the same as at the beginning, as if you were dealing with
> an entirely different problem, hombre.

No, sorry, it's you running the wrong kernel module, and a single
occurence of the stack dump would have been sufficient, but thanks
all the same.


Corinna

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8IOVAAoJEPU2Bp2uRE+g2h0QAJdU0qzkCrg1whpZbJuWN47z
+c7IpcQBgjbR/Sv695P6cBEVO+koN7f2tM1CY+RFgyEpRLEDLZuvN0Z9c9ZSSprb
rufjXotGNEgBmca+9rvr9KnpzkS3avjylkEgY/dEUpav1IHcZjjiPCfmSblvUokO
enyerdgwFK6RzxN7Vm8nNdCliP1dN0dn/20tASkcAnipuTm0b9KXo7xdXTBzs7Yp
GeU16D3IqZmUJAq0gTm/RFKO7WVOuC5lk9+rzKOgcFrY/bUxVeMYyQ65jFu36FTY
4Ms3h0aeuGqycawdIoyWAOajiL+Et1z8bwEsISZBF/hJXuCUoxMLFVtwLt1EQXKX
IcT76qr61iX3LridFazN3M3mrn0sLDzuUJAQYc9bk/ypH7EO+Fv/N2EBiDQY/4Tx
B/rIhpk/POi4ffAXvkyD7igSR9gE46mtIUqeTUi/OaWHaOkBHRSCl6KQMXga/GRg
rY3CXye7Or2AB8dOlyVhBRCUOygICNBajOnNKuzx+wxC2hNM19slDgNd5clgI5JB
Mg0coVKih94FPbiyaS4PEnYR7uInaDWn2zfJsayTsXSBz9yQwOLKGiRITPjd06jF
hi7QB2qj8Nhk9oShc1wvOKLYDkmNDifSUmzC9mFRsDg8uM65qEtMjDCh53HZoT8h
lDOD1E0vmX317N22GC0N
=588j
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
