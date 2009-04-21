From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Tue, 21 Apr 2009 11:48:43 +0200
Message-ID: <49ED967B.4070105@cosmosbay.com>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>	 <87eivnpqde.fsf@basil.nowhere.org> <65634d660904202026r7d73f810s700bacb8756e0967@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38025 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756978AbZDUJsy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:48:54 -0400
In-Reply-To: <65634d660904202026r7d73f810s700bacb8756e0967@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> On Mon, Apr 20, 2009 at 3:32 AM, Andi Kleen <andi@firstfloor.org> wro=
te:
>> Tom Herbert <therbert@google.com> writes:
>>
>>> +static int netif_cpu_for_rps(struct net_device *dev, struct sk_buf=
f *skb)
>>> +{
>>> +     cpumask_t mask;
>>> +     unsigned int hash;
>>> +     int cpu, count =3D 0;
>>> +
>>> +     cpus_and(mask, dev->soft_rps_cpus, cpu_online_map);
>>> +     if (cpus_empty(mask))
>>> +             return smp_processor_id();
>> There's a race here with CPU hotunplug I think. When a CPU is hotunp=
lugged
>> in parallel you can still push packets to it even though they are no=
t
>> drained. You probably need some kind of drain callback in a CPU hotu=
nplug
>> notifier that eats all packets left over.
>>
> We will look at that, the hotplug support may very well be lacking in=
 the patch.
>=20
>>> +got_hash:
>>> +     hash %=3D cpus_weight_nr(mask);
>> That looks rather heavyweight even on modern CPUs. I bet it's 40-50+=
 cycles
>> alone forth the hweight and the division. Surely that can be done be=
tter?
>>
> Agreed, I will try to pull in the RX hash from Dave Miller's remote
> softirq patch.
>=20
>> Also I suspect some kind of runtime switch for this would be useful.
>>
>> Also the manual set up of the receive mask seems really clumpsy. Cou=
ldn't
>> you set that up dynamically based on where processes executing recvm=
sg()
>> are running?
>>
> We have done exactly that.  It works very well in many cases
> (application + platform combinations), but I haven't found it to be
> better than doing the hash in all cases.  I could provide the patch,
> but it might be more of a follow patch to this base one.

Hello Tom

I was thinking about your patch (and David's one), and thought it could=
 be
possible to spread packets to other cpus only if current one is under s=
tress.

A posssible metric would be to test if softirq is handled by ksoftirqd
(stress situation) or not.

Under moderate load, we could have one active cpu (and fewer cache line
transferts), keeping good latencies.

I tried alternative approach to solve the Multicast problem raised some=
 time ago,
but still have one cpu handling one device. Only wakeups were defered t=
o a
workqueue (and possibly another cpu) if running from ksoftirq only.
Patch not yet ready for review, but based on a previous patch that was =
more
intrusive (touching kernel/softirq.c)

Under stress, your idea permits to use more cpus for a fast NIC and get=
 better
throughput. Its more generic.


