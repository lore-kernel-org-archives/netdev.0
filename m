From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Extend irq_set_affinity_notifier() to use a call chain
Date: Mon, 26 May 2014 14:39:54 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1405261412110.21720@ionos.tec.linutronix.de>
References: <5381DEDC.8050204@gmail.com> <alpine.DEB.2.02.1405261313570.21720@ionos.tec.linutronix.de> <53832472.7070000@gmail.com> <alpine.DEB.2.02.1405261327500.21720@ionos.tec.linutronix.de> <53832D28.1050207@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, idos@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53832D28.1050207@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 May 2014, Amir Vadai wrote:
> On 5/26/2014 2:34 PM, Thomas Gleixner wrote:
> > You are not describing what needs to be notified and why. Please
> > explain the details of that and how the RFS (whatever that is) and the
> > network driver are connected
> The goal of RFS is to increase datacache hitrate by steering
> kernel processing of packets in multi-queue devices to the CPU where the
> application thread consuming the packet is running.
> 
> In order to select the right queue, the networking stack needs to have a
> reverse map of IRQ affinty. This is the rmap that was added by Ben Hutchings
> [1]. To keep the rmap updated, cpu_rmap registers on the affinity notify.
> 
> This is the first affinity callback - it is located as a general library and
> not under net/...
>
> The motivation to the second irq affinity callback is:
> When traffic starts, first packet fires an interrupt which starts the napi
> polling on the cpu according the irq affinity.
> If there is always packets to be consumed by the napi polling, no further
> interrupts will be fired, and napi will consume all the packets from the cpu
> it was started.
> If the user changes the irq affinity, napi polling will continue to be done
> from the original cpu.
> Only when the traffic will pause, napi session will be finished, and when
> traffic will resume, the new napi session will be done from the new cpu.
> This is a problematic behavior, because from the user point of view, cpu
> affinity can't be changed in a non-stop traffic scenario.
> 
> To solve this, the network driver should be notified on irq affinity change
> event, and restart the napi session. This could be done by closing the napi
> session and arming the interrupts. Next packet arrives will trigger an
> interrupt and napi will session will start, this time on the new CPU.
> 
> > and why this notification cannot be
> > propagated inside the network stack itself.
> 
> To my understanding, those are two different consumers to the same event, one
> is a general library to maintain a reverse irq affinity map, and the other is
> networking specific, and maybe even a networking driver specific.

The rmap _IS_ instantiated by the driver, and both the driver and the
networking core know about it.

So it's not completely different consumers. Just because it's a
library does not mean it's disjunct from the code which uses it.

Aside of the fact, that maintaining a per irq notifier chain is going
to be ugly as hell due to life time and locking issues, it's just
opening a can of worms. How do you make sure that the invocation order
is correct? What are the dependency rules of the driver restarting the
napi session versus updating the rmap?

Even if you'd solve that and have a callback in the driver, then the
callback never can restart the napi session directly. All it can do is
set a flag which needs to be checked in the RX path, right?

So what's the point of adding notifier call chain complexity, ordering
problems etc., if you can simply note the fact that the affinity
changed in the rmap itself and check that in the RX path?

Thanks,

	tglx
