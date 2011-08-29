From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency
 between vlan and real devices
Date: Mon, 29 Aug 2011 08:23:05 +0200
Message-ID: <1314598985.3036.15.camel@edumazet-laptop>
References: <f6ded72b-346d-43af-af47-4edae5060406@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	yrl pp-manager tt <yrl.pp-manager.tt@hitachi.com>,
	HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f6ded72b-346d-43af-af47-4edae5060406@tahiti.vyatta.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 28 ao=C3=BBt 2011 =C3=A0 23:06 -0700, Stephen Hemminger a =C3=
=A9crit :
>=20
> ----- Original Message -----
> > Le dimanche 28 ao=C3=BBt 2011 =C3=A0 22:20 +0900, HAYASAKA Mitsuo a=
 =C3=A9crit :
> > > Hi Stephen and Herbert
> > >=20
> > > Thank you for your comments.
> > >=20
> > > (2011/08/26 15:08), Stephen Hemminger wrote:
> > > > I don't think this is the right way to solve the problem.
> > > >
> > > > The flags are supposed to propagate back from real device to vl=
an
> > > > via network notifications.
> > > >
> > > > Just doing this for ioctl is not enough, API's other than user
> > > > space depend on this.
> > > > Also the user may have manually set different flags on vlan tha=
n
> > > > on
> > > > the real device.
> > >=20
> > > I agreed.
> > > I will try another way to solve this problem, as you said.
> > >=20
> > >=20
> > > (2011/08/26 15:45), Herbert Xu wrote:
> > > > On Thu, Aug 25, 2011 at 11:08:59PM -0700, Stephen Hemminger
> > > > wrote:
> > > >> Just doing this for ioctl is not enough, API's other than user
> > > >> space depend on this.
> > > >> Also the user may have manually set different flags on vlan th=
an
> > > >> on
> > > >> the real device.
> > > > Right, anything that tests netif_carrier_ok directly on the VLA=
N
> > > > device will still be delayed.
> > > >
> > > > Now I remember discussing this issue in Japan.  However, I can'=
t
> > > > recall the exact scenario in which the delay occured.
> > > >
> > > > Is the issue with the link status going down on the real device=
,
> > > > or the real device coming up?
> > > >
> > > > IIRC we already have mechanisms in place to ensure that down
> > > > events
> > > > are not delayed by linkwatch.  Of course it is possible that th=
is
> > > > isn't working for some reason, or some other part of the system
> > > > is
> > > > causing the delay.
> > > >
> > > > So please clarify the scenario for us Hayasaka-san.  Also pleas=
e
> > > > let us know how you measured the delay.
> > > >
> > > > Thanks,
> > >=20
> > > This issue happens when the link status is going down on the real
> > > device.
> > >=20
> > > ex) A cable is broken, or is unplugged from a NIC.
> > >=20
> > > I measured the delay using ioctl with SIOCGIFFLAGS from userspace
> > > in order to check if there is a time-lag of the flag between vlan
> > > and real devices.
> > >=20
> > > Also, you can check it using a script below.
> > >=20
> > > -------------------------
> > > #!/bin/sh
> > > t=3D0
> > > while :
> > > do
> > > 	echo $t; t=3D$((t+1))
> > > 	echo -n real; ifconfig RealDev | grep UP
> > > 	echo -n vlan; ifconfig VlanDev | grep UP
> > > 	sleep 0.2
> > > done
> > > -------------------------
> > >=20
> > > The result is shown as follows.
> > > It is observed that there is a time-lag of RUNNING status between
> > > real and vlan devices.
> > >=20
> > >=20
> >=20
> > Hi !
> >=20
> > This reminds me some work done in linkwatch
> >=20
> > Please take a look at commit e014debecd3ee3832e647 (linkwatch:
> > linkwatch_forget_dev() to speedup device dismantle)
> >=20
> > And more generally, code in net/core/link_watch.c
>=20
> Maybe the problem is specific to a ethernet driver. Some devices poll
> for link changes, and also do a manual check when ioctl was done.
> This was mostly typical of older hardware that did not have a PHY
> interrupt.

Hmm, I just tried the script on my laptop, and reproduced the problem
with a tg3 driver, considered as a reference one ;)

the 'carrier is on' event is immediately present on both devices, but
the 'carrier is off' is delayed by one second.

09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M
Gigabit Ethernet PCI Express (rev 02)
	Subsystem: Dell Device 01f9
	Flags: bus master, fast devsel, latency 0, IRQ 45
	Memory at f1ef0000 (64-bit, non-prefetchable) [size=3D64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: <access denied>
	Kernel driver in use: tg3
	Kernel modules: tg3
