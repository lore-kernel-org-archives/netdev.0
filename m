From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Thu, 06 Sep 2007 19:06:59 -0400
Message-ID: <1189120020.4259.68.camel@localhost>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:15493 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbXIFXHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 19:07:06 -0400
Received: by an-out-0708.google.com with SMTP id d31so54014and
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2007 16:07:05 -0700 (PDT)
In-Reply-To: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-06-09 at 15:16 +0100, James Chapman wrote:

> First, do we need to encourage consistency in NAPI poll drivers? A 
> survey of current NAPI drivers shows different strategies being used 
> in their poll(). Some such as r8169 do the napi_complete() if poll() 
> does less work than their allowed budget. Others such as e100 and tg3 
> do napi_complete() only if they do no work at all. And some drivers use 
> NAPI only for receive handling, perhaps setting txdone interrupts for 
> 1 in N transmitted packets, while others do all "interrupt" processing in 
> their poll(). Should we encourage more consistency? Should we encourage more 
> NAPI driver maintainers to minimize interrupts by doing all rx _and_ tx 
> processing in the poll(), and do napi_complete() only when the poll does _no_ work?

not to stiffle the discussion, but Stephen Hemminger is planning to
write a new howto; that would be a good time to bring up the topic. The 
challenge is that there may be hardware issues that will result in small
deviations.

> Clearly, keeping a device in polled mode for 1-2 jiffies after it would otherwise 
> have gone idle means 
> that it might be called many times by the NAPI softirq while it has no work to do. 
> This wastes CPU cycles. It would be important therefore to implement the driver's 
> poll() to make this case as efficient as possible, perhaps testing for it early.

> When a device is in polled mode while idle, there are 2 scheduling cases to consider:-
> 
> 1. One or more other netdevs is not idle and is consuming quota on each poll. The net_rx 
> softirq 
> will loop until the next jiffy tick or when quota is exceeded, calling each device 
> in its polled 
> list. Since the idle device is still in the poll list, it will be polled very rapidly.

One suggestion on limiting the amount of polls is to actually have the
driver chew something off the quota even on empty polls - easier by just
changing the driver. A simple case will be say 1 packet (more may make
more sense, machine dependent) every time poll is invoked by the core.
This way the core algorithm continues to be fair and when the jiffies
are exceeded you bail out from the driver.

> 2. No other active device is in the poll list. The net_rx softirq will poll 
> the idle device twice 
> and then exit the softirq processing loop as if quota is exceeded. See the 
> net_rx_action() changes 
> in the patch which force the loop to exit if no work is being done by any 
> device in the poll list.
> 
> In both cases described above, the scheduler will continue NAPI processing 
> from ksoftirqd. This 
> might be very soon, especially if the system is otherwise idle. But if the 
> system is idle, do we 
> really care that idle network devices will be polled for 1-2 jiffies? 

Unfortunately the folks who have brought this up as an issue would
answer affirmatively. 
OTOH, if you can demonstrate that you spend less cycles polling rather
than letting NAPI do its thing, you will be able to make a compelling
case.

> If the system is otherwise 
> busy, ksoftirqd will share the CPU with other threads/processes which will reduce the poll rate 
> anyway.
> 
> In testing, I see significant reduction in interrupt rate for typical traffic patterns. A flood ping, 
> for example, keeps the device in polled mode, generating no interrupts. 

Must be a fast machine.

> In a test, 8510 packets are sent/received versus 6200 previously; 

The other packets are dropped? What are the rtt numbers like?

> CPU load is 100% versus 62% previously; 

not good.

> and 1 netdev interrupt occurs versus 12400 previously. 

good - maybe ;->

> Performance and CPU load under extreme 
> network load (using pktgen) is unchanged, as expected. 
> Most importantly though, it is no longer possible to find a combination 
> of CPU performance and traffic pattern that induce high interrupt rates. 
> And because hardware interrupt mitigation isn't used, packet latency is minimized.

I dont think youd find much win against NAPI in this case; 

> The increase in CPU load isn't surprising for a flood ping test since the CPU 
> is working to bounce packets as fast as it can. The increase in packet rate 
> is a good indicator of how much the interrupt and NAPI scheduling overhead is. 

Your results above showed decreased tput and increased cpu - did you
mistype that?

> The CPU load shows 100% because ksoftirqd is always wanting the CPU for the duration 
> of the flood ping. The beauty of NAPI is that the scheduler gets to decide which thread 
> gets the CPU, not hardware CPU interrupt priorities. On my desktop system, I perceive 
> _better_ system response (smoother X cursor movement etc) during the flood ping test, 

interesting - i think i did not notice something similar on my laptop
but i couldnt quantify it and it didnt seem to make sense.

> despite the CPU load being increased. For a system whose main job is processing network 
> traffic quickly, like an embedded router or a network server, this approach might be very 
> beneficial.

I am not sure i buy that James;-> The router types really have not much
of a challenge in this area.

>  For a desktop, I'm less sure, although as I said above, I've noticed no performance 
> issues in my setups to date.

> Is this worth pursuing further? I'm considering doing more work to measure the effects at 
> various relatively low packet rates. 

The standard litmus test applies since this is about performance.
Ignoring memory, the three standard net resources to worry about are
cpu, throughput and latency.  If you can show one or more of those
resources got better consistently without affecting the others across
different scenarios - you have a case to make.
For example in my experiments:
At high traffic rates, i didnt affect any of those axes.
At low rates, I was able to reduce cpu abuse, make throughput consistent
but make latency a lot worse. So this meant it was not fit to push
forward.

> I also want to investigate using High Res Timers rather 
> than jiffy sampling to reduce the idle poll time.

Mandeep also mentioned tickless - it would be interesting to see both.

>  Perhaps it is also worth trying HRT in the 
> net_rx softirq too. 

You may wanna also try the approach i did with hrt+/tickless by changing
only the driver and not the core.

> I thought it would be worth throwing the ideas out there 
> first to get early feedback.

You are doing the right thing by following the path on perfomance
analysis. I hope you dont get discouraged because the return on
investment may be very low in such work - the majority of the work is in
the testing and analysis (not in puking code endlessly). 

cheers,
jamal

