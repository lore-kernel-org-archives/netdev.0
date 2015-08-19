From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Wed, 19 Aug 2015 21:24:14 +0200
Message-ID: <20150819192414.GC30904@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
 <20150819091318.GV17917@calimero.vinschen.de>
 <0835B3720019904CB8F7AA43166CEEB2F4BF49@RTITMBSV03.realtek.com.tw>
 <20150819130744.GA24832@calimero.vinschen.de>
 <20150819142416.GA26271@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Pd0ReVV5GZGQvF3a"
Cc: Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	nic_swsd <nic_swsd@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:37157 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbHSTYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:24:17 -0400
Content-Disposition: inline
In-Reply-To: <20150819142416.GA26271@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Pd0ReVV5GZGQvF3a
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 19 16:24, Corinna Vinschen wrote:
> On Aug 19 15:07, Corinna Vinschen wrote:
> > On Aug 19 09:31, Hayes Wang wrote:
> > > Corinna Vinschen [mailto:vinschen@redhat.com]
> > > > Sent: Wednesday, August 19, 2015 5:13 PM
> > > [...]
> > > > > It could be cleared by setting bit 0, such as rtl_tally_reset() o=
f r8152.
> > > >=20
> > > > Is it safe to assume that this is implemented in all NICs covered b=
y r8169?=20
> > >=20
> > > It is supported from RTL8111C. That is, RTL_GIGA_MAC_VER_19 and later.
> >=20
> > Thanks.  In that case I would prefer the same generic method for all
> > chip versions, so I'd opt for storing the offset values at rtl_open
> > time as my patch is doing right now.  Is that acceptable?
> >=20
> > If so, wouldn't it make even more sense to use the hardware collected
> > information in @get_stats64 throughout, except for the numbers collected
> > *only* in software? =20
> >=20
> > I would be willing to propose a matching patch.
>=20
> It just occured to me that the combination of resetting the counters on
> post-RTL_GIGA_MAC_VER_19 chips plus offset handling would be quite
> nice, because it would reset also the small 16 and 32 bit counters.
>=20
> So I'd like to propose a patch which combines both techniques, if that's
> an acceptable way to go forward.
>=20
> Btw., does setting the reset bit in CounterAddrLow work the same way as
> setting the CounterDump flag?  I.e, does the driver have to wait for the
> hardware to set the bit to 0 again to be sure the reset is finished?

Here's a preliminary implementation of the counter reset code.  It's
based on my previous patch.  It calls the new rtl8169_reset_counters
prior to rtl8169_update_counters from rtl_open.

I tested the patch successfully on a RTL8111f NIC (RTL_GIGA_MAC_VER_35).

This isn't an official patch submission, I'm just sending this for
further discussion.  I'll make a full patch submission if the code is
acceptable. =20

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/re=
altek/r8169.c
index e7c7955..204f7e7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -637,6 +637,9 @@ enum rtl_register_content {
 	/* _TBICSRBit */
 	TBILinkOK	=3D 0x02000000,
=20
+	/* ResetCounterCommand */
+	CounterReset	=3D 0x1,
+
 	/* DumpCounterCommand */
 	CounterDump	=3D 0x8,
=20
@@ -2188,6 +2191,31 @@ static int rtl8169_get_sset_count(struct net_device =
*dev, int sset)
 	}
 }
=20
+DECLARE_RTL_COND(rtl_reset_counters_cond)
+{
+	void __iomem *ioaddr =3D tp->mmio_addr;
+
+	return RTL_R32(CounterAddrLow) & CounterReset;
+}
+
+static void rtl8169_reset_counters(struct net_device *dev)
+{
+	struct rtl8169_private *tp =3D netdev_priv(dev);
+	void __iomem *ioaddr =3D tp->mmio_addr;
+
+	/*
+	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
+	 * tally counters.
+	 */
+	if (tp->mac_version >=3D RTL_GIGA_MAC_VER_19) {
+		RTL_W32(CounterAddrHigh, 0);
+		RTL_W32(CounterAddrLow, CounterReset);
+		if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond,
+					      10, 1000))
+			netif_warn(tp, hw, dev, "counter reset failed\n");
+	}
+}
+
 DECLARE_RTL_COND(rtl_counters_cond)
 {
 	void __iomem *ioaddr =3D tp->mmio_addr;
@@ -2234,11 +2262,10 @@ static void rtl8169_init_tc_counter_offset(struct n=
et_device *dev)
 	struct rtl8169_private *tp =3D netdev_priv(dev);
=20
 	/*
-	 * rtl8169_init_tc_counter_offset is called from rtl_open.  The tally
-	 * counters are only reset by a power cycle, while the counter values
-	 * collected by the driver are reset at every driver unload/load cycle.
-	 * There's also no (documented?) way to reset the tally counters
-	 * programatically.
+	 * rtl8169_init_tc_counter_offset is called from rtl_open.  On chip
+	 * versions prior to RTL_GIGA_MAC_VER_19 the tally counters are only
+	 * reset by a power cycle, while the counter values collected by the
+	 * driver are reset at every driver unload/load cycle.
 	 *
 	 * To make sure the HW values returned by @get_stats64 match the SW
 	 * values, we collect the initial values at first open(*) and use them
@@ -2252,6 +2279,8 @@ static void rtl8169_init_tc_counter_offset(struct net=
_device *dev)
 	if (tp->tc_offset.inited)
 		return;
=20
+	rtl8169_reset_counters(dev);
+
 	rtl8169_update_counters(dev);
=20
 	tp->tc_offset.tx_errors =3D tp->counters.tx_errors;


Thanks,
Corinna

--Pd0ReVV5GZGQvF3a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1NfeAAoJEPU2Bp2uRE+gucQP/23dkOQDYhYMojyl6Lzsrq+J
GIXCSVEmpZqnxFcdHqIGn3PvP3V93h205bE5SXZsgqGX6xQgLyoPRQIDWiwM0z2p
BGQa560OPV9sLs5FNlgg1+3xh8aUs4w2Brgr0L0v4zsUjWyAL7QKEsVoqe6VEakl
0evOEimkgfxBogfEpN7FZQi55dALkgnMbUcCBkVX1/5ltQCLk6g/wMhvfonCnQsr
u8gA64YGpJu34MiH0yf3ADspqaQa1zOEGe6n1X7kc0ILvGuJwL0bpLhv4igTLClX
yvVhwJQ5QcZEFQAI0PcCG3vJV+r05YKmYtn5frTIapERleVzEZxOGgbCxIxxRGOF
T1vR7DDB3b4vQ/g1hYczY7NkvwSpHn1ie6fkXV4UuhF25hWxXsnZoQZBrRn0iWuQ
pwo46C27GWlagCCKM8dB0bCiIGe44YDnc3JFc9F/u13ZONQRmxcryw7wPEVbyIzW
xcyIn/gj/84qkLLPHTgfbNH5M4rB10hYZBCYJF5afhf0MI3kbVS56hVBw0ZDCfgz
TBHpFJhtf6984mqwZxfkVkX7gHm+Mi1nbX/eFUk7up9vzLSmn1ltFh+Pzpy+cMQK
r5nkZITvj4SyNUo8PQAFZLpNtdWx7DG9HIlvW2959b0318QQlj3a4TXIuq8jrd2/
4+uWE0Vd0ZVQpvJn9Khz
=MvZf
-----END PGP SIGNATURE-----

--Pd0ReVV5GZGQvF3a--
