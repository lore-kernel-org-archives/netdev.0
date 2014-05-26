From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Extend irq_set_affinity_notifier() to use a call chain
Date: Mon, 26 May 2014 15:01:44 +0300
Message-ID: <53832D28.1050207@mellanox.com>
References: <5381DEDC.8050204@gmail.com> <alpine.DEB.2.02.1405261313570.21720@ionos.tec.linutronix.de> <53832472.7070000@gmail.com> <alpine.DEB.2.02.1405261327500.21720@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, <idos@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1405261327500.21720@ionos.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/26/2014 2:34 PM, Thomas Gleixner wrote:
> On Mon, 26 May 2014, Amir Vadai wrote:
>
>> On 5/26/2014 2:15 PM, Thomas Gleixner wrote:
>>> On Sun, 25 May 2014, Amir Vadai wrote:
>>>> In order to do that, I need to add a new irq affinity notification
>>>> callback (In addition to the existing cpu_rmap notification). For
>>>> that I would like to extend irq_set_affinity_notifier() to have a
>>>> notifier call-chain instead of a single notifier callback.
>>>
>>> Why? "I would like" is a non argument.
>>
>> Current implementation enables only one callback to be registered for irq
>> affinity change notifications.
>
> I'm well aware of that.
>
>> cpu_rmap is registered be notified - for RFS purposes.  mlx4_en (and
>> probably other network drivers) needs to be notified too, in order
>> to stop the napi polling on the old cpu and move to the new one.  To
>> enable more than 1 notification callbacks, I suggest to use a
>> notifier call chain.
>
> You are not describing what needs to be notified and why. Please
> explain the details of that and how the RFS (whatever that is) and the
> network driver are connected
The goal of RFS is to increase datacache hitrate by steering
kernel processing of packets in multi-queue devices to the CPU where the 
application thread consuming the packet is running.

In order to select the right queue, the networking stack needs to have a 
reverse map of IRQ affinty. This is the rmap that was added by Ben 
Hutchings [1]. To keep the rmap updated, cpu_rmap registers on the 
affinity notify.

This is the first affinity callback - it is located as a general library 
and not under net/...

The motivation to the second irq affinity callback is:
When traffic starts, first packet fires an interrupt which starts the 
napi polling on the cpu according the irq affinity.
If there is always packets to be consumed by the napi polling, no 
further interrupts will be fired, and napi will consume all the packets 
from the cpu it was started.
If the user changes the irq affinity, napi polling will continue to be 
done from the original cpu.
Only when the traffic will pause, napi session will be finished, and 
when traffic will resume, the new napi session will be done from the new 
cpu.
This is a problematic behavior, because from the user point of view, cpu 
affinity can't be changed in a non-stop traffic scenario.

To solve this, the network driver should be notified on irq affinity 
change event, and restart the napi session. This could be done by 
closing the napi session and arming the interrupts. Next packet arrives 
will trigger an interrupt and napi will session will start, this time on 
the new CPU.

 > and why this notification cannot be
 > propagated inside the network stack itself.

To my understanding, those are two different consumers to the same 
event, one is a general library to maintain a reverse irq affinity map, 
and the other is networking specific, and maybe even a networking driver 
specific.

[1] - c39649c lib: cpu_rmap: CPU affinity reverse-mapping

Thanks,
Amir

>
> notifier chains are almost always a clear sign for a design disaster
> and I'm not going to even think about it before I do not have a
> concice explanation of the problem at hand and why a notifier chain is
> a good solution.
>
> Thanks,
>
> 	tglx
>
>
