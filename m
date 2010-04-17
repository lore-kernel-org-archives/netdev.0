From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sat, 17 Apr 2010 13:31:59 -0400
Message-ID: <1271525519.3929.3.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:47489 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab0DQRcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 13:32:05 -0400
Received: by qyk34 with SMTP id 34so4432470qyk.22
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:32:02 -0700 (PDT)
In-Reply-To: <1271489739.16881.4586.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-04-17 at 09:35 +0200, Eric Dumazet wrote:

> I did some tests on a dual quad core machine (E5450  @ 3.00GHz), not
> nehalem. So a 3-4 years old design.

Eric, I thank you kind sir for going out of your way to do this - it is
certainly a good processor to compare against 

> For all test, I use the best time of 3 runs of "ping -f -q -c 100000
> 192.168.0.2". Yes ping is not very good, but its available ;)

It is a reasonable quick test, no fancy setup required ;->

> Note: I make sure all 8 cpus of target are busy, eating cpu cycles in
> user land. 

I didnt keep the cpus busy. I should re-run with such a setup, any
specific app that you used to keep them busy? Keeping them busy could
have consequences;  I am speculating you probably ended having greater
than one packet/IPI ratio i.e amortization benefit..
  
> I dont want to tweak acpi or whatever smart power saving
> mechanisms.

I should mention i turned off acpi as well in the bios; it was consuming
more cpu cycles than net-processing and was interfering in my tests.

> When RPS off
> 100000 packets transmitted, 100000 received, 0% packet loss, time 4160ms
> 
> RPS on, but directed on the cpu0 handling device interrupts (tg3, napi)
> (echo 01 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
> 100000 packets transmitted, 100000 received, 0% packet loss, time 4234ms
> 
> So the cost of queing the packet into our own queue (netif_receive_skb
> -> enqueue_to_backlog) is about 0.74 us  (74 ms / 100000)
> 

Excellent analysis.

> I personally think we should process packet instead of queeing it, but
> Tom disagree with me.

Sorry - I am gonna have to turn on some pedagogy and offer my
Canadian 2 cents;->
I would lean on agreeing with Tom, but maybe go one step further (sans
packet-reordering): we should never process packets to socket layer on
the demuxing cpu.
enqueue everything you receive on a different cpu - so somehow receiving
cpu becomes part of a hashing decision ...

The reason is derived from queueing theory - of which i know dangerously
little - but refer you to mr. little his-self[1] (pun fully
intended;->):
i.e fixed serving time provides more predictable results as opposed to
once in a while a spike as you receive packets destined to "our cpu".
Queueing packets and later allocating cycles to processing them adds to
variability, but is not as bad as processing to completion to socket
layer.

> RPS on, directed on cpu1 (other socket)
> (echo 02 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
> 100000 packets transmitted, 100000 received, 0% packet loss, time 4542ms

Good test - should be worst case scenario. But there are two other 
scenarios which will give different results in my opinion.
On your setup i think each socket has two dies, each with two cores. So
my feeling is you will get different numbers if you go within same die
and across dies within same socket. If i am not mistaken, the mapping
would be something like socket0/die0{core0/2}, socket0/die1{core4/6},
socket1/die0{core1/3}, socket1{core5/7}.
If you have cycles can you try the same socket+die but different cores
and same socket but different die test?

> So extra cost to enqueue to a remote cpu queue, IPI, softirq handling...
> is 3 us. Note this cost is in case we receive a single packet.

Which is not too bad if amortized. Were you able to check if you
processed a packet/IPI? One way to achieve that is just standard ping.
In the nehalem my number for going to a different core was in the range
of 5 microseconds effect on RTT when system was not busy. I think it
would be higher going across QPI.

> I suspect IPI itself is in the 1.5 us range, not very far from the
> queing to ourself case.

Sound about right maybe 2 us in my case. I am still mystified by "what
damage does an IPI make?" to the system harmony. I have to do some
reading. Andi mentioned the APIC connection - but my gut feeling is you
probably end up going to main memory and invalidate cache.

> For me RPS use cases are :
> 
> 1) Value added apps handling lot of TCP data, where the costs of cache
> misses in tcp stack easily justify to spend 3 us to gain much more.
> 
> 2) Network appliance, where a single cpu is filled 100% to handle one
> device hardware and software/RPS interrupts, delegating all higher level
> works to a pool of cpus.
> 

Agreed on both. 
The caveat to note:
- what hardware would be reasonable
- within same hardware what setups would be good to use 
- when it doesnt benefit even with the everything correct (eg low tcp
throughput)

> I'll try to do these tests on a Nehalem target.

Thanks again Eric.

cheers,
jamal 

[1]http://en.wikipedia.org/wiki/Little's_law

