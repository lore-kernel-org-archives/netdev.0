From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Fri, 07 Sep 2007 09:22:50 -0400
Message-ID: <1189171370.4234.38.camel@localhost>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	 <1189120020.4259.68.camel@localhost>  <46E11A61.9030409@katalix.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:34833 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965371AbXIGNWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 09:22:55 -0400
Received: by wr-out-0506.google.com with SMTP id 36so181912wra
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2007 06:22:55 -0700 (PDT)
In-Reply-To: <46E11A61.9030409@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-09 at 10:31 +0100, James Chapman wrote:
> Not really. I used 3-year-old, single CPU x86 boxes with e100 
> interfaces. 
> The idle poll change keeps them in polled mode. Without idle 
> poll, I get twice as many interrupts as packets, one for txdone and one 
> for rx. NAPI is continuously scheduled in/out.

Certainly faster than the machine in the paper (which was about 2 years
old in 2005).
I could never get ping -f to do that for me - so things must be getting
worse with newer machines then.

> No. Since I did a flood ping from the machine under test, the improved 
> latency meant that the ping response was handled more quickly, causing 
> the next packet to be sent sooner. So more packets were transmitted in 
> the allotted time (10 seconds).

ok.

> With current NAPI:
> rtt min/avg/max/mdev = 0.902/1.843/101.727/4.659 ms, pipe 9, ipg/ewma 
> 1.611/1.421 ms
> 
> With idle poll changes:
> rtt min/avg/max/mdev = 0.898/1.117/28.371/0.689 ms, pipe 3, ipg/ewma 
> 1.175/1.236 ms

Not bad in terms of latency. The deviation certainly looks better.

> But the CPU has done more work. 

I am going to be the devil's advocate[1]:
If the problem i am trying to solve is "reduce cpu use at lower rate",
then this is not the right answer because your cpu use has gone up.
Your latency numbers have not improved that much (looking at the avg)
and your throughput is not that much higher. Will i be willing to pay
more cpu (of an already piggish cpu use by NAPI at that rate with 2
interupts per packet)?

Another test: try a simple ping and compare the rtts.

> The problem I started thinking about was the one where NAPI thrashes 
> in/out of polled mode at higher and higher rates as network interface 
> speeds and CPU speeds increase. A flood ping demonstrates this even on 
> 100M links on my boxes. 

things must be getting worse in the state of average hardware out there.
It will be worthwile exercise to compare on an even faster machine
and see what transpires there.
 
> Networking boxes want consistent 
> performance/latency for all traffic patterns and they need to avoid 
> interrupt livelock. Current practice seems to be to use hardware 
> interrupt mitigation or timers to limit interrupt rate but this just 
> hurts latency, as you noted. So I'm trying to find a way to limit the 
> NAPI interrupt rate without increasing latency. My comment about this 
> approach being suitable for routers and networked servers is that these 
> boxes care more about minimizing packet latency than they do about 
> wasting CPU cycles by polling idle devices.

I think the arguement of "who cares about a little more cpu" is valid
for the case of routers. It is a double edged sword, because it applies
to the case of "who cares if NAPI uses a little more cpu at low rates"
and "who cares if James turns on polling and abuses a little more-more
cpu". Since NAPI is the incumbent, the onus(sp?) is to do better. You
must do better sir!

Look at the timers, she said - that way you may be able to cut the cpu
abuse.

cheers,
jamal

[1] historically the devils advocate was a farce really ;->

