From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency
 between vlan and real devices
Date: Sun, 28 Aug 2011 16:09:49 +0200
Message-ID: <1314540589.3036.12.camel@edumazet-laptop>
References: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp>
	 <20110825230859.11b2b132@nehalam.ftrdhcpuser.net>
	 <20110826064553.GA5874@gondor.apana.org.au>  <4E5A40A9.2000404@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E5A40A9.2000404@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 28 ao=C3=BBt 2011 =C3=A0 22:20 +0900, HAYASAKA Mitsuo a =C3=
=A9crit :
> Hi Stephen and Herbert
>=20
> Thank you for your comments.
>=20
> (2011/08/26 15:08), Stephen Hemminger wrote:
> > I don't think this is the right way to solve the problem.
> >
> > The flags are supposed to propagate back from real device to vlan
> > via network notifications.
> >
> > Just doing this for ioctl is not enough, API's other than user spac=
e depend on this.
> > Also the user may have manually set different flags on vlan than on
> > the real device.
>=20
> I agreed.
> I will try another way to solve this problem, as you said.
>=20
>=20
> (2011/08/26 15:45), Herbert Xu wrote:
> > On Thu, Aug 25, 2011 at 11:08:59PM -0700, Stephen Hemminger wrote:
> >> Just doing this for ioctl is not enough, API's other than user spa=
ce depend on this.
> >> Also the user may have manually set different flags on vlan than o=
n
> >> the real device.
> > Right, anything that tests netif_carrier_ok directly on the VLAN
> > device will still be delayed.
> >
> > Now I remember discussing this issue in Japan.  However, I can't
> > recall the exact scenario in which the delay occured.
> >
> > Is the issue with the link status going down on the real device,
> > or the real device coming up?
> >
> > IIRC we already have mechanisms in place to ensure that down events
> > are not delayed by linkwatch.  Of course it is possible that this
> > isn't working for some reason, or some other part of the system is
> > causing the delay.
> >
> > So please clarify the scenario for us Hayasaka-san.  Also please
> > let us know how you measured the delay.
> >
> > Thanks,
>=20
> This issue happens when the link status is going down on the real=20
> device.
>=20
> ex) A cable is broken, or is unplugged from a NIC.
>=20
> I measured the delay using ioctl with SIOCGIFFLAGS from userspace=20
> in order to check if there is a time-lag of the flag between vlan=20
> and real devices.
>=20
> Also, you can check it using a script below.
>=20
> -------------------------
> #!/bin/sh
> t=3D0
> while :
> do
> 	echo $t; t=3D$((t+1))
> 	echo -n real; ifconfig RealDev | grep UP
> 	echo -n vlan; ifconfig VlanDev | grep UP
> 	sleep 0.2
> done
> -------------------------
>=20
> The result is shown as follows.
> It is observed that there is a time-lag of RUNNING status between=20
> real and vlan devices.
>=20
>=20

Hi !

This reminds me some work done in linkwatch

Please take a look at commit e014debecd3ee3832e647 (linkwatch:
linkwatch_forget_dev() to speedup device dismantle)

And more generally, code in net/core/link_watch.c
