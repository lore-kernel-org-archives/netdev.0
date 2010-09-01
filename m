From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Wed, 01 Sep 2010 15:19:28 +0200
Message-ID: <1283347168.2556.319.camel@edumazet-laptop>
References: <1282024802.2487.687.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
	 <1282050920.2448.47.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
	 <1282055659.2448.58.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se>
	 <20100817171115.GA4134@mcarlson.broadcom.com>
	 <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se>
	 <20100817183112.GA4351@mcarlson.broadcom.com>
	 <alpine.DEB.1.10.1008172035520.21857@red.crap.retrofitta.se>
	 <20100818012318.GA4630@mcarlson.broadcom.com>
	 <alpine.DEB.1.10.1008180900350.21857@red.crap.retrofitta.se>
	 <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 septembre 2010 =C3=A0 11:21 +0200, Thomas Habets a =C3=A9=
crit :
> I've continued this a bit off-list but thought I would summarize for =
the=20
> archives.
>=20
>=20
> Summary
> -------
> It looks like a firmware issue on the network card. When ILO is enabl=
ed it=20
> shares the first network card with the OS. When it does this multicas=
t=20
> is broken. When multicast (on a L2 level) is broken IPv6 neighbor=20
> discovery breaks. Only eth0 breaks, eth1 is unaffected.
>=20
>=20
> System
> ------
> HP Proliant DL320 G5p
> Xeon 3GHz
> 1GB RAM
> Arch: amd64
> NIC: Broadcom Corporation NetXtreme BCM5715 Gigabit Ethernet (rev a3)
> Debian Lenny (5.0.5)
> Kernels: 2.6.35 mainline, 2.6.33.6
> Config: http://pastebin.com/raw.php?i=3DY6S8iKW7
>=20
>=20
> Problem
> -------
> Buggy box will not answer IPv6 ND or ping to ff02::1. May work at som=
e=20
> point in the boot process, but once box is fully booted it does not.
>=20
> If I on the neighboring Cisco router run "clear ipv6 neighbors" (or i=
t=20
> times out) that router cannot re-acquire the neigborship with the bug=
gy=20
> box. Instant IPv6 breakage until I do one of:
> * Turn on promisc mode long enough for IPv6 ND to do its thing
> * ip ne del <address of neighbor> on the buggy host.
>=20
>=20
> Workarounds
> -----------
> Either one of these will hide the problem:
> * Set promisc mode on interface (ip link set promisc on eth0) forever
> * Disable ILO
> * Use eth1 instead of eth0.
>=20
>=20
> Troubleshooting
> ---------------
> Got patch for kernel from Eric Dumazet (eric.dumazet@gmail.com) to ou=
tput=20
> what MAC addresses are being subscribed to, and some registers from t=
he=20
> card. Output is earlier in this thread, along with "ethtool -i eth0" =
and=20
> some other data.
>=20
> Managed to get diagnostic tool[1] booting from stick (no CD drive in=20
> server), but did not set up memory (himem.sys etc..). Running b57udia=
g=20
> it therefore failed due to insufficient memory at test "Group D. Driv=
er=20
> Associated tests". Card is assumed to be OK anyway.
>=20
> Matt Carlson (mcarlson@broadcom.com) suspected firmware bug and asked=
 me=20
> to try disabling ASF and/or IPMI using the diagnostic tool, but runni=
ng=20
> "setasf -d" and "setipmi -d" inside "b57udiag -cmd" did not seem to s=
tick=20
> across reboot. It stuck properly before reboot (confirmed with setasf=
 -q).=20
> Also tried "b57udiag -u 0". Tried both C-A-D reboot and powercycling =
(by=20
> power cord).
>=20
> At boot Linux still said ASF[1] for eth0 and ASF[0] for eth1:
> tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOc=
ap[1]
> tg3 0000:03:04.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOc=
ap[1]
> (this output never changed throughout the process)
> ethtool -d eth1 | grep 0x047 did not change either.
>=20
> Then I disabled ILO and PXE in ILO bios and BIOS respectively. That f=
ixed=20
> it. eth0 now works with multicast.
>=20
> I don't use ILO on this server so in this case that fixes it for me, =
but=20
> the bug is still there.
>=20
> At this point Matt thinks I should file a bug report with HP. I will=20
> attempt to do that.
>=20
> I have more detailed logs of what I did and when, and what the effect=
 was.
>=20
>=20
> Related
> -------
> May be the same issue as this:
>    https://bugs.launchpad.net/ubuntu/+source/linux/+bug/263260
> Which means it's the same with Ubuntu kernels 2.6.26.3, 2.6.26-5-gene=
ric=20
> and 2.6.27-2-generic, and mainline kernels 2.6.25, 2.6.26 and 2.6.27.
>=20
>=20
> [1] http://www.broadcom.com/support/ethernet_nic/netxtreme_server.php
>=20


Thanks a lot Thomas for this very detailed report !
