From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Mon, 7 Sep 2015 16:44:12 +0200
Message-ID: <20150907144412.GA26524@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
To: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pomidorabelisima@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:40835 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbIGOoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 10:44:16 -0400
Content-Disposition: inline
In-Reply-To: <20150906103732.GF30539@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  6 12:37, Corinna Vinschen wrote:
> On Sep  5 14:18, romieu@fr.zoreil.com wrote:
> > From: Francois Romieu <romieu@fr.zoreil.com>
> >=20
> > net/core/net-sysfs.c::netstat_show retrieves stats with spinlock held.
> >=20
> > This change avoids sleepable allocation and performs some housekeeping:
> > - receive ring, transmit ring and counters dump area allocation failures
> >   are all considered fatal during open()
> > - netif_warn is now redundant with rtl_reset_counters_cond built-in
> >   failure message.
> > - rtl_reset_counters_cond induced failures in open() are also considered
> >   fatal: it takes acceptable work to unwind comfortably.
>=20
> Why?  The counter reset is not a fatal condition for the operation of
> the NIC.  Even if the counters show incorrect values, the normal
> operation of the NIC is not affected.  And to top that off, even if
> resetting the counters actually doesn't work, the driver keeps the
> offset values, so a failed reset won't even harm the statistics.  It
> just doesn't make sense to break the NIC operation for such a minor
> problem.  And worse:
>=20
> > -static bool rtl8169_reset_counters(struct net_device *dev)
> > +static int rtl8169_reset_counters(struct net_device *dev)
> >  {
> >  	struct rtl8169_private *tp =3D netdev_priv(dev);
> > -	struct rtl8169_counters *counters;
> > -	dma_addr_t paddr;
> > -	bool ret =3D true;
> > =20
> >  	/*
> >  	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
> >  	 * tally counters.
> >  	 */
> >  	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
> > -		return true;
> > -
> > -	counters =3D rtl8169_map_counters(dev, &paddr, CounterReset);
> > -	if (!counters)
> > -		return false;
> > -
> > -	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
> > -		ret =3D false;
> > -
> > -	rtl8169_unmap_counters(dev, paddr, counters);
> > +		return -EINVAL;
>=20
> This returns -EINVAL even for older chip versions which are not capable
> of resetting the counters.  The result is, this driver will not work at
> all on chip versions prior to RTL_GIGA_MAC_VER_19 anymore, because
> rtl_open will always fail.
>=20
> Other then that, I can test the patch probably tomorrow.

I have a bit of a problem with this patch.  It crashes when loading the
driver manually w/ modprobe.  For some reason dev_get_stats is called
during rtl_init_one and at that time the counters pointer is NULL, so
the kernel gets a SEGV.  After I worked around that I got a SEGV in
rtl_remove_one, which I still have to find out why.  I didn't test with
the latest kernel, though, so I still have to check if that's the reason
for the crashes.  That takes a bit longer, I just wanted to let you
know.

There's also a problem with rtl8169_cmd_counters:  It always calls
rtl_udelay_loop_wait_low w/ rtl_reset_counters_cond, even when called
=66rom rtl8169_update_counters, where it should call
rtl_udelay_loop_wait_low w/ rtl_counters_cond to check for the
CounterDump flag, rather than for the CounterReset flag.

For now I applied the below patch, but I think it's a bit ugly to
conditionalize the rtl_cond struct by the incoming flag value.


Corinna


diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/re=
altek/r8169.c
index ae07567..cd7adbf 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2200,6 +2200,13 @@ DECLARE_RTL_COND(rtl_reset_counters_cond)
 	return RTL_R32(CounterAddrLow) & CounterReset;
 }
=20
+DECLARE_RTL_COND(rtl_counters_cond)
+{
+	void __iomem *ioaddr =3D tp->mmio_addr;
+
+	return RTL_R32(CounterAddrLow) & CounterDump;
+}
+
 static int rtl8169_cmd_counters(struct net_device *dev, u32 counter_cmd)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
@@ -2212,7 +2219,10 @@ static int rtl8169_cmd_counters(struct net_device *d=
ev, u32 counter_cmd)
 	RTL_W32(CounterAddrLow, cmd);
 	RTL_W32(CounterAddrLow, cmd | counter_cmd);
=20
-	return rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000);
+	return rtl_udelay_loop_wait_low(tp,
+		counter_cmd =3D=3D CounterDump ? &rtl_counters_cond :
+					     &rtl_reset_counters_cond,
+		10, 1000);
 }
=20
 static int rtl8169_reset_counters(struct net_device *dev)
@@ -2229,13 +2239,6 @@ static int rtl8169_reset_counters(struct net_device =
*dev)
 	return rtl8169_cmd_counters(dev, CounterReset);
 }
=20
-DECLARE_RTL_COND(rtl_counters_cond)
-{
-	void __iomem *ioaddr =3D tp->mmio_addr;
-
-	return RTL_R32(CounterAddrLow) & CounterDump;
-}
-
 static int rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
@@ -7800,8 +7803,11 @@ rtl8169_get_stats64(struct net_device *dev, struct r=
tnl_link_stats64 *stats)
=20
 	/*
 	 * Fetch additonal counter values missing in stats collected by driver
-	 * from tally counters.
+	 * from tally counters, but only if we're already initialized.
 	 */
+	if (!counters)
+	  return stats;
+
 	rtl8169_update_counters(dev);
=20
 	/*

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7aK8AAoJEPU2Bp2uRE+gmJkP/iCt9knHh7GQT89Xb7i8gD9U
UXnaf857i4j40kS+sxwE/i7NG2kFlYAAaqjn7ReNOtjKshLr5C1JBQxSDoIvrRcc
msw3sITCY1s/dBhXAYtT42pNGLbd83P7K+gayyMNUDD9vGnoHfUn7oRQl7BavT7X
rnADyrnL+8AC2d1k+la8XbtMClUTkz8VO+yfi7vz923tO6stJ+5ZzvaqLYnhcJwd
m6Cv9ZmXmEcfofdAkxPbYYPDKbb4uuvVep92YP/maHrLreMYQFj5AuhbT/uPSPxQ
9drmjboBoji0TZCGgVUXBeczhTEg9mKo9JVL11vQVUPFGY4QMqC0Ad3L5TMPs19y
gD2S6QlScelMeB9WC6Zf/SsxHV1H4EzoND4dh3ihxzVjSV9fO8pVsB++XIYqTc7R
nuxDQq/O9NkTU32DEDfwXMikD153NGnCpmTmDju2CBOkXbTzUobMVxpCx7t/ZNkI
mcr3Hw9h7pflsFjsk8I0QYoOL/OadH6wYsgjfgTvM8xXioPAOLMi4bDfAEND7BAV
9bwa6BEgyVpzjUqp4I5UM63dgAH1om/j3Gy/qN4ua+NTRARaMEuHwlKD05Y8VGrN
wmQ8fdb2I8cmgjLdz4NUWPW0tNfvPGTt0AwvoIN0WbD8AH6KhnVcy0vg8uIxpIwl
Wqq4wLsHPG68JmFtBB4g
=XlMR
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
