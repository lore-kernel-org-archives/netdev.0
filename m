From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency between vlan and real devices
Date: Sun, 28 Aug 2011 23:06:28 -0700 (PDT)
Message-ID: <f6ded72b-346d-43af-af47-4edae5060406@tahiti.vyatta.com>
References: <1314540589.3036.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	=?utf-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	yrl pp-manager tt <yrl.pp-manager.tt@hitachi.com>,
	HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53229 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750738Ab1H2GG3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 02:06:29 -0400
In-Reply-To: <1314540589.3036.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> Le dimanche 28 ao=C3=BBt 2011 =C3=A0 22:20 +0900, HAYASAKA Mitsuo a =C3=
=A9crit :
> > Hi Stephen and Herbert
> >=20
> > Thank you for your comments.
> >=20
> > (2011/08/26 15:08), Stephen Hemminger wrote:
> > > I don't think this is the right way to solve the problem.
> > >
> > > The flags are supposed to propagate back from real device to vlan
> > > via network notifications.
> > >
> > > Just doing this for ioctl is not enough, API's other than user
> > > space depend on this.
> > > Also the user may have manually set different flags on vlan than
> > > on
> > > the real device.
> >=20
> > I agreed.
> > I will try another way to solve this problem, as you said.
> >=20
> >=20
> > (2011/08/26 15:45), Herbert Xu wrote:
> > > On Thu, Aug 25, 2011 at 11:08:59PM -0700, Stephen Hemminger
> > > wrote:
> > >> Just doing this for ioctl is not enough, API's other than user
> > >> space depend on this.
> > >> Also the user may have manually set different flags on vlan than
> > >> on
> > >> the real device.
> > > Right, anything that tests netif_carrier_ok directly on the VLAN
> > > device will still be delayed.
> > >
> > > Now I remember discussing this issue in Japan.  However, I can't
> > > recall the exact scenario in which the delay occured.
> > >
> > > Is the issue with the link status going down on the real device,
> > > or the real device coming up?
> > >
> > > IIRC we already have mechanisms in place to ensure that down
> > > events
> > > are not delayed by linkwatch.  Of course it is possible that this
> > > isn't working for some reason, or some other part of the system
> > > is
> > > causing the delay.
> > >
> > > So please clarify the scenario for us Hayasaka-san.  Also please
> > > let us know how you measured the delay.
> > >
> > > Thanks,
> >=20
> > This issue happens when the link status is going down on the real
> > device.
> >=20
> > ex) A cable is broken, or is unplugged from a NIC.
> >=20
> > I measured the delay using ioctl with SIOCGIFFLAGS from userspace
> > in order to check if there is a time-lag of the flag between vlan
> > and real devices.
> >=20
> > Also, you can check it using a script below.
> >=20
> > -------------------------
> > #!/bin/sh
> > t=3D0
> > while :
> > do
> > 	echo $t; t=3D$((t+1))
> > 	echo -n real; ifconfig RealDev | grep UP
> > 	echo -n vlan; ifconfig VlanDev | grep UP
> > 	sleep 0.2
> > done
> > -------------------------
> >=20
> > The result is shown as follows.
> > It is observed that there is a time-lag of RUNNING status between
> > real and vlan devices.
> >=20
> >=20
>=20
> Hi !
>=20
> This reminds me some work done in linkwatch
>=20
> Please take a look at commit e014debecd3ee3832e647 (linkwatch:
> linkwatch_forget_dev() to speedup device dismantle)
>=20
> And more generally, code in net/core/link_watch.c

Maybe the problem is specific to a ethernet driver. Some devices poll
for link changes, and also do a manual check when ioctl was done.
This was mostly typical of older hardware that did not have a PHY
interrupt.
