From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 23:11:56 +0200
Message-ID: <46CF499C.60009@de.ibm.com>
References: <8VHRR-45R-17@gated-at.bofh.it> <8VKwj-8ke-27@gated-at.bofh.it> <E1IOeSm-0000bm-Jo@be1.lrz> <20070824204243.GI4282@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bodo Eggert <7eggert@gmx.de>, netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:65112 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbXHXVMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:12:39 -0400
In-Reply-To: <20070824204243.GI4282@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas schrieb:
> On Fri, Aug 24, 2007 at 09:04:56PM +0200, Bodo Eggert wrote:
>   
>> Linas Vepstas <linas@austin.ibm.com> wrote:
>>     
>>> On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:
>>>       
>>>> 3) On modern systems the incoming packets are processed very fast. Especially
>>>> on SMP systems when we use multiple queues we process only a few packets
>>>> per napi poll cycle. So NAPI does not work very well here and the interrupt
>>>> rate is still high.
>>>>         
>>> worst-case network ping-pong app: send one
>>> packet, wait for reply, send one packet, etc.
>>>       
>> Possible solution / possible brainfart:
>>
>> Introduce a timer, but don't start to use it to combine packets unless you
>> receive n packets within the timeframe. If you receive less than m packets
>> within one timeframe, stop using the timer. The system should now have a
>> decent response time when the network is idle, and when the network is
>> busy, nobody will complain about the latency.-)
>>     
>
> Ohh, that was inspirational. Let me free-associate some wild ideas.
>
> Suppose we keep a running average of the recent packet arrival rate,
> Lets say its 10 per millisecond ("typical" for a gigabit eth runnning
> flat-out).  If we could poll the driver at a rate of 10-20 per
> millisecond (i.e. letting the OS do other useful work for 0.05 millisec),
> then we could potentially service the card without ever having to enable 
> interrupts on the card, and without hurting latency.
>
> If the packet arrival rate becomes slow enough, we go back to an
> interrupt-driven scheme (to keep latency down).
>
> The main problem here is that, even for HZ=1000 machines, this amounts 
> to 10-20 polls per jiffy.  Which, if implemented in kernel, requires 
> using the high-resolution timers. And, umm, don't the HR timers require
> a cpu timer interrupt to make them go? So its not clear that this is much
> of a win.
>   
That is indeed a good question. At least for 10G eHEA we see
that the average number of packets/poll cycle is very low.
With high precision timers we could control the poll interval
better and thus make sure we get enough packets on the queue in
high load situations to benefit from LRO while keeping the
latency moderate. When the traffic load is low we could just
stick to plain NAPI. I don't know how expensive hp timers are,
we probably just have to test it (when they are available for
POWER in our case). However, having more packets
per poll run would make LRO more efficient and thus the total
CPU utilization would decrease.

I guess on most systems there are not many different network
cards working in parallel. So if the driver could set the poll
interval for its devices, it could be well optimized depending
on the NICs characteristics.

Maybe it would be good enough to have a timer that schedules
the device for NAPI (and thus triggers SoftIRQs, which will
trigger NAPI). Whether this timer would be used via a generic
interface or would be implemented as a proprietary solution
would depend on whether other drivers want / need this feature
as well. Drivers / NICs that work fine with plain NAPI don't
have to use timer :-)

I tried to implement something with "normal" timers, but the result
was everything but great. The timers seem to be far too slow.
I'm not sure if it helps to increase it from 1000HZ to 2500HZ
or more.

Regards,
Jan-Bernd

