From: jamal <hadi@cyberus.ca>
Subject: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 07:53:06 -0400
Message-ID: <1271245986.3943.55.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:41281 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab0DNLxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 07:53:09 -0400
Received: by qyk27 with SMTP id 27so66576qyk.23
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 04:53:08 -0700 (PDT)
In-Reply-To: <1265641748.3688.56.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following up like promised:

On Mon, 2010-02-08 at 10:09 -0500, jamal wrote:
> On Sun, 2010-02-07 at 21:58 -0800, Tom Herbert wrote:
> 
> > I don't have specific numbers, although we are using this on
> > application doing forwarding and numbers seem in line with what we see
> > for an end host.
> > 
> 
> When i get the chance i will give it a run. I have access to an i7
> somewhere. It seems like i need some specific nics?

I did step #0 last night on an i7 (single Nehalem). I think more than
anything i was impressed by the Nehalem's excellent caching system.
Robert, I am almost tempted to say skb recycling performance will be
excellent on this  machine given the cost of a cache miss is much lower
than previous generation hardware.

My test was simple: irq affinity on cpu0(core0) and rps redirection to
cpu1(core 1); tried also to redirect to different SMT threads (aka CPUs)
on different cores with similar results. I base tested against no rps
being used and a kernel which didnt have any RPS config on.
[BTW, I had to hand-edit the .config since i couldnt do it from
menuconfig (Is there any reason for it to be so?)]

Traffic was sent from another machine into the i7 via an el-cheapo sky2
(dont know how shitty this NIC is, but it seems to know how to do MSI so
probably capable of multiqueueing); the test was several sets of 
a ping first and then a ping -f (I will get more sophisticated in my
next test likely this weekend).

Results:
CPU utilization was about 20-30% higher in the case of rps. On cpu0, the
cpu was being chewed highly by sky2_poll and on the redirected-to-core
it was always smp_call_function_single.
Latency was (consistently) on average 5 microseconds. 
So if i sent 1M ping -f packets, without RPS it took on average
176 seconds and with RPS it took 181 seconds to do a round-trip.
Throughput didnt change but this could be attributed to the low amounts
of data i was sending.
I observed that we were generating, on average, an IPI per packet even
with ping -f. (added an extra stat to record when we sent an IPI and
counted against the number of packets sent).
In my opinion it is these IPIs that contribute the most to the latency
and i think it happens that the Nehalem is just highly improved in this 
area. I wish i had a more commonly used machine to test rps on.
I expect that rps will perform worse on currently cheaper/older hardware
for the traffic characteristic i tested.

On IPIs:
Is anyone familiar with what is going on with Nehalem? Why is it this
good? I expect things will get a lot nastier with other hardware like
xeon based or even Nehalem with rps going across QPI.
Here's why i think IPIs are bad, please correct me if i am wrong:
- they are synchronous. i.e an IPI issuer has to wait for an ACK (which
is in the form of an IPI).
- data cache has to be synced to main memory
- the instruction pipeline is flushed
- what else did i miss? Andi?

So my question to Tom, Eric and Changli or anyone else who has been
running RPS:
What hardware did you use? Is there anyone using older hardware than
say AMD Opteron or Intel Nehalem?

My impressions of rps so far:
I think i may end up being impressed when i generate a lot more traffic
since the cost of IPI will be amortized. 
At this point multiqueue seems a lot more impressive alternative and it
seems to me multiqueu hardware is a lot more commodity (price-point)
than a Nehalem.

Plan:
I plan to still attack the app space (and write a basic udp app that
binds to one or more rps cpus and try blasting a lot of UDP traffic to
see what happens) my step after that is to move to forwarding tests..
 
cheers,
jamal

