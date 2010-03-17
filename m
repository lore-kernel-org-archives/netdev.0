From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 08:01:22 -0700
Message-ID: <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com>
	 <1268773227.2932.34.camel@edumazet-laptop>
	 <20100316.141311.262178287.davem@davemloft.net>
	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	 <1268809673.2932.62.camel@edumazet-laptop>
	 <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	 <1268834957.2899.352.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:16557 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab0CQPB1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 11:01:27 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o2HF1Pwt028632
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 16:01:25 +0100
Received: from fxm1 (fxm1.prod.google.com [10.184.13.1])
	by wpaz1.hot.corp.google.com with ESMTP id o2HF1NT8003997
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 08:01:24 -0700
Received: by fxm1 with SMTP id 1so1175054fxm.33
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 08:01:23 -0700 (PDT)
In-Reply-To: <1268834957.2899.352.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 7:09 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 17 mars 2010 =E0 15:59 +0800, Changli Gao a =E9crit :
>> On Wed, Mar 17, 2010 at 3:07 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le mercredi 17 mars 2010 =E0 09:54 +0800, Changli Gao a =E9crit :
>> >> On Wed, Mar 17, 2010 at 5:13 AM, David Miller <davem@davemloft.ne=
t> wrote:
>> >> >
>> >> > I'll integrate this as soon as I open up net-next-2.6
>> >>
>> >> It is really a good news. Now linux also can dispatch packets as
>> >> FreeBSD does via netisr. Can we walk farer, and support weighted
>> >> distribution?
>> >>
>> >
>> > May I ask why ? What would be the goal ?
>> >
>>
>> For example, I have a firewall with dual core CPU, and use core 0 fo=
r
>> IRQ and dispatching. If I use both core 0 and core 1 for the left
>> processing, core 0 will be overloaded, and if I use core 1 for the
>> left processing, core 0 will be light load. In order to take full of
>> advantage of hardware, I need weighted the packet distribution.
>
> I would not use RPS at all, weighted or not, unless your firewall mus=
t
> perform heavy duty work (l7 or complex rules)
>
> If the firewall setup is expensive, then IRQ processing has minor cos=
t,
> and RPS fits the bill (cpu handling IRQ will be a bit more loaded tha=
n
> its buddy).
>
> RPS is a win when _some_ TCP/UDP processing occurs, and we try to do
> this processing on a cpu that will also run user space thread with da=
ta
> in cpu cache (if process scheduler does a good job)
> Not much applicable for routers...
>
>
> Anyway, current sysfs RPS interface exposes
> a /sys/class/net/eth0/queues/rx-0/rps_cpus bitmap,
>
> I guess we could expose another file,
> /sys/class/net/eth0/queues/rx-0/rps_map
> to give different weight to cpus :
>
> echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_map
>
> cpu0 would get 30% of the postprocessing load, cpu1 70%
>
> Using /sys/class/net/eth0/queues/rx-0/rps_cpus interface would give a=
n
> equal weight to each cpu :
>
>
> # echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_map
> # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
> 3
> # cat /sys/class/net/eth0/queues/rx-0/rps_map
> 0 1 0 1 0 1 1 1 1 1
> # echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
> # cat /sys/class/net/eth0/queues/rx-0/rps_map
> 0 1

Alternatively, the rps_map could be specified explicitly, which will
allow weighting.  For example "0 0 0 0 2 10 10 10"  would select CPUs
0, 2, 10 for the map with weights four, one, and three respectively.
This would go back to have sysfs files with multiple values in them,
so it might not be the right interface.

Tom
