From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Thu, 6 Sep 2007 15:37:00 +0100
Message-ID: <20070906153700.57a0c448@oldman>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, mandeep.baines@gmail.com, ossthema@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59797 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753638AbXIFOhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 10:37:20 -0400
In-Reply-To: <200709061416.l86EG0Vb017675@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Sep 2007 15:16:00 +0100
James Chapman <jchapman@katalix.com> wrote:

> This RFC suggests some possible improvements to NAPI in the area of minimizing interrupt rates. A possible scheme to reduce interrupt rate for the low packet rate / fast CPU case is described. 
> 
> First, do we need to encourage consistency in NAPI poll drivers? A survey of current NAPI drivers shows different strategies being used in their poll(). Some such as r8169 do the napi_complete() if poll() does less work than their allowed budget. Others such as e100 and tg3 do napi_complete() only if they do no work at all. And some drivers use NAPI only for receive handling, perhaps setting txdone interrupts for 1 in N transmitted packets, while others do all "interrupt" processing in their poll(). Should we encourage more consistency? Should we encourage more NAPI driver maintainers to minimize interrupts by doing all rx _and_ tx processing in the poll(), and do napi_complete() only when the poll does _no_ work?
> 
> One well known issue with NAPI is that it is possible with certain traffic patterns for NAPI drivers to schedule in and out of polled mode very quickly. Worst case, a NAPI driver might get 1 interrupt per packet. With fast CPUs and interfaces, this can happen at high rates, causing high CPU loads and poor packet processing performance. Some drivers avoid this by using hardware interrupt mitigation features of the network device in tandem with NAPI to throttle the max interrupt rate per device. But this adds latency. Jamal's paper http://kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf discusses this problem in some detail.
> 
> By making some small changes to the NAPI core, I think it is possible to prevent high interrupt rates with NAPI, regardless of traffic patterns and without using per-device hardware interrupt mitigation. The basic idea is that instead of immediately exiting polled mode when it finds no work to do, the driver's poll() keeps itself in active polled mode for 1-2 jiffies and only does napi_complete() when it does no work in that time period. When it does no work in its poll(), the driver can return 0 while leaving itself in the NAPI poll list. This means it is possible for the softirq processing to spin around its active device list, doing no work, since no quota is consumed. A change is therefore also needed in the NAPI core to detect the case when the only devices that are being actively p
 olled in softirq processing are doing no work on each poll and to exit the softirq loop rather than wasting CPU cycles.
> 
> The code changes are shown in the patch below. The patch is against the latest NAPI rework posted by DaveM http://marc.info/?l=linux-netdev&m=118829721407289&w=2. I used e100 and tg3 drivers to test. Since a driver that returns 0 from its poll() while leaving itself in polled mode would now used by the NAPI core as a condition for exiting the softirq poll loop, all existing NAPI drivers would need to conform to this new invariant. Some drivers, e.g. e100, can return 0 even if they do tx work in their poll().
> 
> Clearly, keeping a device in polled mode for 1-2 jiffies after it would otherwise have gone idle means that it might be called many times by the NAPI softirq while it has no work to do. This wastes CPU cycles. It would be important therefore to implement the driver's poll() to make this case as efficient as possible, perhaps testing for it early.
> 
> When a device is in polled mode while idle, there are 2 scheduling cases to consider:-
> 
> 1. One or more other netdevs is not idle and is consuming quota on each poll. The net_rx softirq will loop until the next jiffy tick or when quota is exceeded, calling each device in its polled list. Since the idle device is still in the poll list, it will be polled very rapidly.
> 
> 2. No other active device is in the poll list. The net_rx softirq will poll the idle device twice and then exit the softirq processing loop as if quota is exceeded. See the net_rx_action() changes in the patch which force the loop to exit if no work is being done by any device in the poll list.
> 
> In both cases described above, the scheduler will continue NAPI processing from ksoftirqd. This might be very soon, especially if the system is otherwise idle. But if the system is idle, do we really care that idle network devices will be polled for 1-2 jiffies? If the system is otherwise busy, ksoftirqd will share the CPU with other threads/processes which will reduce the poll rate anyway.
> 
> In testing, I see significant reduction in interrupt rate for typical traffic patterns. A flood ping, for example, keeps the device in polled mode, generating no interrupts. In a test, 8510 packets are sent/received versus 6200 previously; CPU load is 100% versus 62% previously; and 1 netdev interrupt occurs versus 12400 previously. Performance and CPU load under extreme network load (using pktgen) is unchanged, as expected. Most importantly though, it is no longer possible to find a combination of CPU performance and traffic pattern that induce high interrupt rates. And because hardware interrupt mitigation isn't used, packet latency is minimized.
> 
> The increase in CPU load isn't surprising for a flood ping test since the CPU is working to bounce packets as fast as it can. The increase in packet rate is a good indicator of how much the interrupt and NAPI scheduling overhead is. The CPU load shows 100% because ksoftirqd is always wanting the CPU for the duration of the flood ping. The beauty of NAPI is that the scheduler gets to decide which thread gets the CPU, not hardware CPU interrupt priorities. On my desktop system, I perceive _better_ system response (smoother X cursor movement etc) during the flood ping test, despite the CPU load being increased. For a system whose main job is processing network traffic quickly, like an embedded router or a network server, this approach might be very beneficial. For a desktop, I'm less sure, 
 although as I said above, I've noticed no performance issues in my setups to date.
> 
> 
> Is this worth pursuing further? I'm considering doing more work to measure the effects at various relatively low packet rates. I also want to investigate using High Res Timers rather than jiffy sampling to reduce the idle poll time. Perhaps it is also worth trying HRT in the net_rx softirq too. I thought it would be worth throwing the ideas out there first to get early feedback.
> 


What about the latency that NAPI imposes? Right now there are certain applications that
don't like NAPI because it add several more microseconds, and this may make it worse.
Maybe a per-device flag or tuning parameters (like weight sysfs value)? or some other
way to set low-latency values.
