From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe question
Date: Tue, 24 Nov 2009 01:07:53 -0800
Message-ID: <1259053673.2631.30.camel@ppwaskie-mobl2>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	 <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com>
	 <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>
	 <4B0A9E4E.9010804@gmail.com> <19210.54486.353397.804028@gargle.gargle.HOWL>
	 <4B0ABF6D.9000103@gmail.com>
	 <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B0B8F52.3010005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26850 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbZKXJIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 04:08:04 -0500
In-Reply-To: <4B0B8F52.3010005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 00:46 -0700, Eric Dumazet wrote:
> Waskiewicz Jr, Peter P a =C3=A9crit :
> > Ok, I was confused earlier.  I thought you were saying that all pac=
kets=20
> > were headed into a single Rx queue.  This is different.
> >=20
> > Do you know what version of irqbalance you're running, or if it's r=
unning=20
> > at all?  We've seen issues with irqbalance where it won't recognize=
 the=20
> > ethernet device if the driver has been reloaded.  In that case, it =
won't=20
> > balance the interrupts at all.  If the default affinity was set to =
one=20
> > CPU, then well, you're screwed.
> >=20
> > My suggestion in this case is after you reload ixgbe and start your=
 tests,=20
> > see if it all goes to one CPU.  If it does, then restart irqbalance=
=20
> > (service irqbalance restart - or just kill it and restart by hand).=
  Then=20
> > start running your test, and in 10 seconds you should see the inter=
rupts=20
> > move and spread out.
> >=20
> > Let me know if this helps,
>=20
> Sure it helps !
>=20
> I tried without irqbalance and with irqbalance (Ubuntu 9.10 ships irq=
balance 0.55-4)
> I can see irqbalance setting smp_affinities to 5555 or AAAA with no d=
irect effect.
>=20
> I do receive 16 different irqs, but all serviced on one cpu.
>=20
> Only way to have irqs on different cpus is to manualy force irq affin=
ities to be exclusive
> (one bit set in the mask, not several ones), and that is not optimal =
for moderate loads.
>=20
> echo 1 >`echo /proc/irq/*/fiber1-TxRx-0/../smp_affinity`
> echo 1 >`echo /proc/irq/*/fiber1-TxRx-1/../smp_affinity`
> echo 4 >`echo /proc/irq/*/fiber1-TxRx-2/../smp_affinity`
> echo 4 >`echo /proc/irq/*/fiber1-TxRx-3/../smp_affinity`
> echo 10 >`echo /proc/irq/*/fiber1-TxRx-4/../smp_affinity`
> echo 10 >`echo /proc/irq/*/fiber1-TxRx-5/../smp_affinity`
> echo 40 >`echo /proc/irq/*/fiber1-TxRx-6/../smp_affinity`
> echo 40 >`echo /proc/irq/*/fiber1-TxRx-7/../smp_affinity`
> echo 100 >`echo /proc/irq/*/fiber1-TxRx-8/../smp_affinity`
> echo 100 >`echo /proc/irq/*/fiber1-TxRx-9/../smp_affinity`
> echo 400 >`echo /proc/irq/*/fiber1-TxRx-10/../smp_affinity`
> echo 400 >`echo /proc/irq/*/fiber1-TxRx-11/../smp_affinity`
> echo 1000 >`echo /proc/irq/*/fiber1-TxRx-12/../smp_affinity`
> echo 1000 >`echo /proc/irq/*/fiber1-TxRx-13/../smp_affinity`
> echo 4000 >`echo /proc/irq/*/fiber1-TxRx-14/../smp_affinity`
> echo 4000 >`echo /proc/irq/*/fiber1-TxRx-15/../smp_affinity`
>=20
>=20
> One other problem is that after reload of ixgbe driver, link is 95% o=
f the time
> at 1 Gbps speed, and I could not find an easy way to force it being 1=
0 Gbps
>=20

You might have this elsewhere, but it sounds like you're connecting bac=
k
to back with another 82599 NIC.  Our optics in that NIC are dual-rate,
and the software mechanism that tries to "autoneg" link speed gets out
of sync easily in back-to-back setups.

If it's really annoying, and you're willing to run with a local patch t=
o
disable the autotry mechanism, try this:

diff --git a/drivers/net/ixgbe/ixgbe_main.c
b/drivers/net/ixgbe/ixgbe_main.c
index a5036f7..62c0915 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4670,6 +4670,10 @@ static void ixgbe_multispeed_fiber_task(struct
work_struct *work)
        autoneg =3D hw->phy.autoneg_advertised;
        if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
                hw->mac.ops.get_link_capabilities(hw, &autoneg,
&negotiation);
+
+       /* force 10G only */
+       autoneg =3D IXGBE_LINK_SPEED_10GB_FULL;
+
        if (hw->mac.ops.setup_link)
                hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
        adapter->flags |=3D IXGBE_FLAG_NEED_LINK_UPDATE;




Cheers,
-PJ

