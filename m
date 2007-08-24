From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 18:16:45 +0100
Message-ID: <46CF127D.1090609@katalix.com>
References: <200708241559.17055.ossthema@de.ibm.com>	<20070824153703.GN5592@sgi.com>	<200708241747.16592.ossthema@de.ibm.com> <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>, akepner@sgi.com,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:40698 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbXHXRQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 13:16:57 -0400
In-Reply-To: <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 24 Aug 2007 17:47:15 +0200
> Jan-Bernd Themann <ossthema@de.ibm.com> wrote:
> 
>> Hi,
>>
>> On Friday 24 August 2007 17:37, akepner@sgi.com wrote:
>>> On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:
>>>> .......
>>>> 3) On modern systems the incoming packets are processed very fast. Especially
>>>>    on SMP systems when we use multiple queues we process only a few packets
>>>>    per napi poll cycle. So NAPI does not work very well here and the interrupt 
>>>>    rate is still high. What we need would be some sort of timer polling mode 
>>>>    which will schedule a device after a certain amount of time for high load 
>>>>    situations. With high precision timers this could work well. Current
>>>>    usual timers are too slow. A finer granularity would be needed to keep the
>>>>    latency down (and queue length moderate).
>>>>
>>> We found the same on ia64-sn systems with tg3 a couple of years 
>>> ago. Using simple interrupt coalescing ("don't interrupt until 
>>> you've received N packets or M usecs have elapsed") worked 
>>> reasonably well in practice. If your h/w supports that (and I'd 
>>> guess it does, since it's such a simple thing), you might try 
>>> it.
>>>
>> I don't see how this should work. Our latest machines are fast enough that they
>> simply empty the queue during the first poll iteration (in most cases).
>> Even if you wait until X packets have been received, it does not help for
>> the next poll cycle. The average number of packets we process per poll queue
>> is low. So a timer would be preferable that periodically polls the 
>> queue, without the need of generating a HW interrupt. This would allow us
>> to wait until a reasonable amount of packets have been received in the meantime
>> to keep the poll overhead low. This would also be useful in combination
>> with LRO.
>>
> 
> You need hardware support for deferred interrupts. Most devices have it (e1000, sky2, tg3)
> and it interacts well with NAPI. It is not a generic thing you want done by the stack,
> you want the hardware to hold off interrupts until X packets or Y usecs have expired.

Does hardware interrupt mitigation really interact well with NAPI? In my 
experience, holding off interrupts for X packets or Y usecs does more 
harm than good; such hardware features are useful only when the OS has 
no NAPI-like mechanism.

When tuning NAPI drivers for packets/sec performance (which is a good 
indicator of driver performance), I make sure that the driver stays in 
NAPI polled mode while it has any rx or tx work to do. If the CPU is 
fast enough that all work is always completed on each poll, I have the 
driver stay in polled mode until dev->poll() is called N times with no 
work being done. This keeps interrupts disabled for reasonable traffic 
levels, while minimizing packet processing latency. No need for hardware 
interrupt mitigation.

> The parameters for controlling it are already in ethtool, the issue is finding a good
> default set of values for a wide range of applications and architectures. Maybe some
> heuristic based on processor speed would be a good starting point. The dynamic irq
> moderation stuff is not widely used because it is too hard to get right.

I agree. It would be nice to find a way for the typical user to derive 
best values for these knobs for his/her particular system. Perhaps a 
tool using pktgen and network device phy internal loopback could be 
developed?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

