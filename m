From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 15:09:17 +0100
Message-ID: <1268834957.2899.352.camel@edumazet-laptop>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	 <20100316.141311.262178287.davem@davemloft.net>
	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	 <1268809673.2932.62.camel@edumazet-laptop>
	 <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:33568 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013Ab0CQOJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 10:09:25 -0400
Received: by bwz4 with SMTP id 4so1065483bwz.39
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 07:09:23 -0700 (PDT)
In-Reply-To: <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 mars 2010 =C3=A0 15:59 +0800, Changli Gao a =C3=A9crit :
> On Wed, Mar 17, 2010 at 3:07 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mercredi 17 mars 2010 =C3=A0 09:54 +0800, Changli Gao a =C3=A9cr=
it :
> >> On Wed, Mar 17, 2010 at 5:13 AM, David Miller <davem@davemloft.net=
> wrote:
> >> >
> >> > I'll integrate this as soon as I open up net-next-2.6
> >>
> >> It is really a good news. Now linux also can dispatch packets as
> >> FreeBSD does via netisr. Can we walk farer, and support weighted
> >> distribution?
> >>
> >
> > May I ask why ? What would be the goal ?
> >
>=20
> For example, I have a firewall with dual core CPU, and use core 0 for
> IRQ and dispatching. If I use both core 0 and core 1 for the left
> processing, core 0 will be overloaded, and if I use core 1 for the
> left processing, core 0 will be light load. In order to take full of
> advantage of hardware, I need weighted the packet distribution.

I would not use RPS at all, weighted or not, unless your firewall must
perform heavy duty work (l7 or complex rules)

If the firewall setup is expensive, then IRQ processing has minor cost,
and RPS fits the bill (cpu handling IRQ will be a bit more loaded than
its buddy).

RPS is a win when _some_ TCP/UDP processing occurs, and we try to do
this processing on a cpu that will also run user space thread with data
in cpu cache (if process scheduler does a good job)
Not much applicable for routers...


Anyway, current sysfs RPS interface exposes
a /sys/class/net/eth0/queues/rx-0/rps_cpus bitmap,

I guess we could expose another file,
/sys/class/net/eth0/queues/rx-0/rps_map
to give different weight to cpus :

echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_map

cpu0 would get 30% of the postprocessing load, cpu1 70%

Using /sys/class/net/eth0/queues/rx-0/rps_cpus interface would give an
equal weight to each cpu :


# echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_map
# cat /sys/class/net/eth0/queues/rx-0/rps_cpus
3
# cat /sys/class/net/eth0/queues/rx-0/rps_map
0 1 0 1 0 1 1 1 1 1
# echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
# cat /sys/class/net/eth0/queues/rx-0/rps_map
0 1



