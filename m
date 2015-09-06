From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Sun, 6 Sep 2015 12:37:32 +0200
Message-ID: <20150906103732.GF30539@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="EgVrEAR5UttbsTXg"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:51348 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbIFKhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 06:37:35 -0400
Content-Disposition: inline
In-Reply-To: <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EgVrEAR5UttbsTXg
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  5 14:18, romieu@fr.zoreil.com wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
>=20
> net/core/net-sysfs.c::netstat_show retrieves stats with spinlock held.
>=20
> This change avoids sleepable allocation and performs some housekeeping:
> - receive ring, transmit ring and counters dump area allocation failures
>   are all considered fatal during open()
> - netif_warn is now redundant with rtl_reset_counters_cond built-in
>   failure message.
> - rtl_reset_counters_cond induced failures in open() are also considered
>   fatal: it takes acceptable work to unwind comfortably.

Why?  The counter reset is not a fatal condition for the operation of
the NIC.  Even if the counters show incorrect values, the normal
operation of the NIC is not affected.  And to top that off, even if
resetting the counters actually doesn't work, the driver keeps the
offset values, so a failed reset won't even harm the statistics.  It
just doesn't make sense to break the NIC operation for such a minor
problem.  And worse:

> -static bool rtl8169_reset_counters(struct net_device *dev)
> +static int rtl8169_reset_counters(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp =3D netdev_priv(dev);
> -	struct rtl8169_counters *counters;
> -	dma_addr_t paddr;
> -	bool ret =3D true;
> =20
>  	/*
>  	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
>  	 * tally counters.
>  	 */
>  	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
> -		return true;
> -
> -	counters =3D rtl8169_map_counters(dev, &paddr, CounterReset);
> -	if (!counters)
> -		return false;
> -
> -	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
> -		ret =3D false;
> -
> -	rtl8169_unmap_counters(dev, paddr, counters);
> +		return -EINVAL;

This returns -EINVAL even for older chip versions which are not capable
of resetting the counters.  The result is, this driver will not work at
all on chip versions prior to RTL_GIGA_MAC_VER_19 anymore, because
rtl_open will always fail.

Other then that, I can test the patch probably tomorrow.


Corinna

--EgVrEAR5UttbsTXg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7BdsAAoJEPU2Bp2uRE+gCOwQAIJGUGeqk48vwmhfVO+suZH6
CyKv/X35E+yeKkktqk7eIe4e7Jm5WYXUM1Aa06VWOyB7cnoS6oW94X5xNW0UKHWO
PjKYP8FZQLS33FJdraHXKX9UcPDfDEzW1MhA9wereAdgntExLEJe3QShhjdnapiM
Wzu4XuQSRiXgtMZVdR7R2pIL96mvLOxDuQiJW4rrAnLagYExSg1QIwuj248puqlC
tE0zUuFYNEQCE6BoQQ+Ikhxr1cV37Youyt3O80uFFsihcGeI04u+vJj7TatMtEiT
Z6P8cy9a9kIvTd0Mk3Mj3lSql8EIyLAVRbjDXblLRWtbZI1u1DpXnvxCdTwt2DPu
2twgRKPx4WReXmLkoSu8mthZGon0FlLWc4OfqcOekPs8Dq58gpHWEvpjGz9vo0OB
xwjqBT51nToULE9tyHTE75Uw8QYpuRXh02uMrjPIdhSMFG1k8qj++5CJl+J4dpY3
stew4IDv5dgvPh5AckO5fTkOn3SuRsuGyGprrFJRg+mH0fSBrd2REUOwmufJSCfC
jxESVt9oFSSi/XW0d276VTrdibCB8FE1uUKx0pzFWUdWKsF1y7uOUrcALI6f2Gtr
gtaSu53iGLaROaikerRv9IszIAYpAyQhV/k3TQydDqM+fnD7vir/3mb2DCr2tGHa
kItwHhJ6k9RIpG5zvPM7
=1SAZ
-----END PGP SIGNATURE-----

--EgVrEAR5UttbsTXg--
