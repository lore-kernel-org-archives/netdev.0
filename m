From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: ingress policying for realtime protocol
Date: Thu, 21 May 2015 20:58:32 +0200
Message-ID: <20150521185831.GC24769@pengutronix.de>
References: <20150519211145.GA23134@pengutronix.de>
 <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
 <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150521070712.GY24769@pengutronix.de>
 <555DDF5C.8080503@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57652 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286AbbEUS6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 14:58:36 -0400
Content-Disposition: inline
In-Reply-To: <555DDF5C.8080503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, May 21, 2015 at 09:36:28AM -0400, Jamal Hadi Salim wrote:
> On 05/21/15 03:07, Uwe Kleine-K=F6nig wrote:
> >On Wed, May 20, 2015 at 05:30:40PM -0700, Eric Dumazet wrote:
> >>On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:
> >>
> >>>There is very little to do on ingress side since there is no queue=
 at all,
> >>>not to mention priority, you could try ifb to see if it fits your =
need.
> >>
> >>Note that if the need is to police traffic, ifb is not really neede=
d :
> >>
> >>TC=3D"tc"
> >>DEV=3D"dev eth0"
> >>IP=3D10.246.11.51/32
> >>$TC qdisc del $DEV ingress 2>/dev/null
> >>$TC qdisc add $DEV ingress
> >>$TC filter add $DEV parent ffff: protocol ip u32 match ip src $IP \
> >>	police rate 1Mbit burst 10Mbit mtu 66000 action drop/continue
> >>
> >>$TC -s filter ls $DEV parent ffff: protocol ip
> >I have something like that (matching on dst mac addresses instead of=
 src ip):
> >
> >	tc qdisc add dev eth0 handle ffff: ingress
> >	tc filter add dev eth0 parent ffff: protocol all prio 10 u32 match =
ether dst 01:15:4E:00:00:01 police pass
> >	tc filter add dev eth0 parent ffff: protocol all prio 50 u32 match =
u32 0 0 at 0 police rate 100kbit burst 10k drop
> >
> >So Cong interpreted my question right and probably I just used the
> >wrong keywords to make you understand the same.
>=20
> I think both Cong and Eric are right.
> You wanted to priotize something thats _realtime_ by using queues, so
> Cong answered your question with ifb which will provide you a queue o=
n
> ingress.
> OTOH, You should really avoid queues of any sort if latency is
My picture of the network stack might be wrong, but if the ethernet
driver queues say 5 packets to the network stack and the fourth is a MR=
P
packet than a priorization that makes the fourth packet processed first
would be nice.
If there is no queue and the first packet is processed before the
ethernet driver has a chance to hand over the second obviously there is
no benefit from using a prio queue because it would always only contain
a single packet.

> important to you - hence what Eric said is correct. Jitter will occur
> when it matters the most for you i.e when congestion kicks in; otherw=
ise
> it will work (when there is no congestion;->)
>=20
> So your requirements are conflicting and the result is two talented
> people are intepretting things differently;->
:-)

> So some questions to you:
> Why is there a 100Kbps limit for everything else? If it has to be at
> 100Kbps, what is wrong with the policy you have?
The 100kbit limit was found by starting with a higher limit and
decrement while scp still made the MRP hiccup. Now what's wrong: It's
annoying that other traffic is cut down that much.

> From my quick reading is it seems this thing has a state machine infa=
ct
> where sometimes you have to drop all other packets and when the state
> machine transitions to a stable state then you just want to accept al=
l
> packets but prioritize its protocol packets. Also the state machine
> seems to involve more than one port (for path redundancy reasons).
> So where is this rate control coming from?
There is only a single port involved but that one is connected to a
Marvell switch. So the packets all come in on eth0 but the userspace
application that handles the MRP stuff still knows on which port of the
switch the packet came in. Also the blocking of a port is done with
configuration of the switch. Does this answer your question?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
