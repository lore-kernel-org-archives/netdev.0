From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Fri, 07 Sep 2007 10:31:13 +0100
Message-ID: <46E11A61.9030409@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <1189120020.4259.68.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:48981 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964794AbXIGJbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 05:31:17 -0400
In-Reply-To: <1189120020.4259.68.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2007-06-09 at 15:16 +0100, James Chapman wrote:
> 
 >> First, do we need to encourage consistency in NAPI poll drivers?

> not to stiffle the discussion, but Stephen Hemminger is planning to
> write a new howto; that would be a good time to bring up the topic. The 
> challenge is that there may be hardware issues that will result in small
> deviations.

Ok.

>> When a device is in polled mode while idle, there are 2 scheduling cases to consider:-
>>
>> 1. One or more other netdevs is not idle and is consuming quota on each poll. The net_rx 
>> softirq 
>> will loop until the next jiffy tick or when quota is exceeded, calling each device 
>> in its polled 
>> list. Since the idle device is still in the poll list, it will be polled very rapidly.
> 
> One suggestion on limiting the amount of polls is to actually have the
> driver chew something off the quota even on empty polls - easier by just
> changing the driver. A simple case will be say 1 packet (more may make
> more sense, machine dependent) every time poll is invoked by the core.

I wanted to minimize the impact on devices that do have work to do. But 
it's worth investigating. Thanks for the suggestion.

>> In testing, I see significant reduction in interrupt rate for typical traffic patterns. A flood ping, 
>> for example, keeps the device in polled mode, generating no interrupts. 
> 
> Must be a fast machine.

Not really. I used 3-year-old, single CPU x86 boxes with e100 
interfaces. The idle poll change keeps them in polled mode. Without idle 
poll, I get twice as many interrupts as packets, one for txdone and one 
for rx. NAPI is continuously scheduled in/out.

>> In a test, 8510 packets are sent/received versus 6200 previously; 
> 
> The other packets are dropped? 

No. Since I did a flood ping from the machine under test, the improved 
latency meant that the ping response was handled more quickly, causing 
the next packet to be sent sooner. So more packets were transmitted in 
the allotted time (10 seconds).

> What are the rtt numbers like?

With current NAPI:
rtt min/avg/max/mdev = 0.902/1.843/101.727/4.659 ms, pipe 9, ipg/ewma 
1.611/1.421 ms

With idle poll changes:
rtt min/avg/max/mdev = 0.898/1.117/28.371/0.689 ms, pipe 3, ipg/ewma 
1.175/1.236 ms

>> CPU load is 100% versus 62% previously; 
> 
> not good.

But the CPU has done more work. The flood ping will always show 
increased CPU with these changes because the driver always stays in the 
NAPI poll list. For typical LAN traffic, the average CPU usage doesn't 
increase as much, though more measurements would be useful.

> Your results above showed decreased tput and increased cpu - did you
> mistype that?

I didn't use clear English. :) I'm seeing increased throughput, mostly 
because latency is improved. The increased cpu is partly because of the 
increased throughput, and partly because ksoftirqd stays busy longer.

>> despite the CPU load being increased. For a system whose main job is processing network 
>> traffic quickly, like an embedded router or a network server, this approach might be very 
>> beneficial.
> 
> I am not sure i buy that James;-> The router types really have not much
> of a challenge in this area.

The problem I started thinking about was the one where NAPI thrashes 
in/out of polled mode at higher and higher rates as network interface 
speeds and CPU speeds increase. A flood ping demonstrates this even on 
100M links on my boxes. Networking boxes want consistent 
performance/latency for all traffic patterns and they need to avoid 
interrupt livelock. Current practice seems to be to use hardware 
interrupt mitigation or timers to limit interrupt rate but this just 
hurts latency, as you noted. So I'm trying to find a way to limit the 
NAPI interrupt rate without increasing latency. My comment about this 
approach being suitable for routers and networked servers is that these 
boxes care more about minimizing packet latency than they do about 
wasting CPU cycles by polling idle devices.

> You are doing the right thing by following the path on perfomance
> analysis. I hope you dont get discouraged because the return on
> investment may be very low in such work - the majority of the work is in
> the testing and analysis (not in puking code endlessly). 

Thanks for your feedback. The challenge will be finding the time to do 
this work. :)

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

