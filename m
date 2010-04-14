From: Tom Herbert <therbert@google.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 10:31:34 -0700
Message-ID: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:57444 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab0DNRbl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 13:31:41 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o3EHVbpH017874
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 10:31:38 -0700
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by hpaq2.eem.corp.google.com with ESMTP id o3EHVZIt002202
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 19:31:36 +0200
Received: by pvb32 with SMTP id 32so227663pvb.34
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 10:31:35 -0700 (PDT)
In-Reply-To: <1271245986.3943.55.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The point of RPS is to increase parallelism, but the cost of that is
more overhead per packet.  If you are running a single flow, then
you'll see latency increase for that flow.  With more concurrent flows
the benefits of parallelism kick in and latency gets better.-- we've
seen the break even point around ten connections in our tests.  Also,
I don't think we've made the claim that RPS should generally perform
better than multi-queue, the primary motivation for RPS is make single
queue NICs give reasonable performance.


On Wed, Apr 14, 2010 at 4:53 AM, jamal <hadi@cyberus.ca> wrote:
> Following up like promised:
>
> On Mon, 2010-02-08 at 10:09 -0500, jamal wrote:
>> On Sun, 2010-02-07 at 21:58 -0800, Tom Herbert wrote:
>>
>> > I don't have specific numbers, although we are using this on
>> > application doing forwarding and numbers seem in line with what we=
 see
>> > for an end host.
>> >
>>
>> When i get the chance i will give it a run. I have access to an i7
>> somewhere. It seems like i need some specific nics?
>
> I did step #0 last night on an i7 (single Nehalem). I think more than
> anything i was impressed by the Nehalem's excellent caching system.
> Robert, I am almost tempted to say skb recycling performance will be
> excellent on this =A0machine given the cost of a cache miss is much l=
ower
> than previous generation hardware.
>
> My test was simple: irq affinity on cpu0(core0) and rps redirection t=
o
> cpu1(core 1); tried also to redirect to different SMT threads (aka CP=
Us)
> on different cores with similar results. I base tested against no rps
> being used and a kernel which didnt have any RPS config on.
> [BTW, I had to hand-edit the .config since i couldnt do it from
> menuconfig (Is there any reason for it to be so?)]
>
> Traffic was sent from another machine into the i7 via an el-cheapo sk=
y2
> (dont know how shitty this NIC is, but it seems to know how to do MSI=
 so
> probably capable of multiqueueing); the test was several sets of
> a ping first and then a ping -f (I will get more sophisticated in my
> next test likely this weekend).
>
> Results:
> CPU utilization was about 20-30% higher in the case of rps. On cpu0, =
the
> cpu was being chewed highly by sky2_poll and on the redirected-to-cor=
e
> it was always smp_call_function_single.
> Latency was (consistently) on average 5 microseconds.
> So if i sent 1M ping -f packets, without RPS it took on average
> 176 seconds and with RPS it took 181 seconds to do a round-trip.
> Throughput didnt change but this could be attributed to the low amoun=
ts
> of data i was sending.
> I observed that we were generating, on average, an IPI per packet eve=
n
> with ping -f. (added an extra stat to record when we sent an IPI and
> counted against the number of packets sent).
> In my opinion it is these IPIs that contribute the most to the latenc=
y
> and i think it happens that the Nehalem is just highly improved in th=
is
> area. I wish i had a more commonly used machine to test rps on.
> I expect that rps will perform worse on currently cheaper/older hardw=
are
> for the traffic characteristic i tested.
>
> On IPIs:
> Is anyone familiar with what is going on with Nehalem? Why is it this
> good? I expect things will get a lot nastier with other hardware like
> xeon based or even Nehalem with rps going across QPI.
> Here's why i think IPIs are bad, please correct me if i am wrong:
> - they are synchronous. i.e an IPI issuer has to wait for an ACK (whi=
ch
> is in the form of an IPI).
> - data cache has to be synced to main memory
> - the instruction pipeline is flushed
> - what else did i miss? Andi?
>
> So my question to Tom, Eric and Changli or anyone else who has been
> running RPS:
> What hardware did you use? Is there anyone using older hardware than
> say AMD Opteron or Intel Nehalem?
>
> My impressions of rps so far:
> I think i may end up being impressed when i generate a lot more traff=
ic
> since the cost of IPI will be amortized.
> At this point multiqueue seems a lot more impressive alternative and =
it
> seems to me multiqueu hardware is a lot more commodity (price-point)
> than a Nehalem.
>
> Plan:
> I plan to still attack the app space (and write a basic udp app that
> binds to one or more rps cpus and try blasting a lot of UDP traffic t=
o
> see what happens) my step after that is to move to forwarding tests..
>
> cheers,
> jamal
>
>
