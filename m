From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on linux-next
Date: Mon, 22 Dec 2014 16:28:08 +0100
Message-ID: <54983888.4030109@acm.org>
References: <20141029155620.GA4886@kria> <20141029180734.GQ12706@worktop.programming.kicks-ass.net> <alpine.DEB.2.11.1410291918060.5308@nanos> <20141029193603.GS12706@worktop.programming.kicks-ass.net> <20141202163530.GA19420@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Sabrina Dubroca <sd@queasysnail.net>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141202163530.GA19420@kria>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/14 17:35, Sabrina Dubroca wrote:
> Hello, sorry for the delay.
> 
> 2014-10-29, 20:36:03 +0100, Peter Zijlstra wrote:
>> On Wed, Oct 29, 2014 at 07:33:00PM +0100, Thomas Gleixner wrote:
>>> Yuck. No. You are just papering over the problem.
>>>
>>> What happens if you add 'threadirqs' to the kernel command line? Or if
>>> the interrupt line is shared with a real threaded interrupt user?
>>>
>>> The proper solution is to have a poll_lock for e1000 which serializes
>>> the hardware interrupt against netpoll instead of using
>>> disable/enable_irq().
>>>
>>> In fact that's less expensive than the disable/enable_irq() dance and
>>> the chance of contention is pretty low. If done right it will be a
>>> NOOP for the CONFIG_NET_POLL_CONTROLLER=n case.
>>>
>>
>> OK a little something like so then I suppose.. But I suspect most all
>> the network drivers will need this and maybe more, disable_irq() is a
>> popular little thing and we 'just' changed semantics on them.
>>
>> ---
>>  drivers/net/ethernet/intel/e1000/e1000.h      |  2 ++
>>  drivers/net/ethernet/intel/e1000/e1000_main.c | 22 +++++++++++++++++-----
>>  kernel/irq/manage.c                           |  2 +-
>>  3 files changed, 20 insertions(+), 6 deletions(-)
> 
> I've been running with variants of this patch, things seem ok.
> 
> As noted earlier, there are a lot of drivers doing this disable_irq +
> irq_handler + enable_irq sequence.  I found about 60.
> Many already take a lock in the interrupt handler, and look like we
> could just remove the call to disable_irq (example: cp_interrupt,
> drivers/net/ethernet/realtek/8139cp.c).
> 
> Here's how I modified your patch.  The locking compiles away if
> CONFIG_NET_POLL_CONTROLLER=n.
> 
> I can work on converting all the drivers from disable_irq to
> netpoll_irq_lock, if that's okay with you.
> 
> In igb there's also a synchronize_irq() called from the netpoll
> controller (in igb_irq_disable()), I think a similar locking scheme
> would work.
> I also saw a few disable_irq_nosync and disable_percpu_irq. These are
> okay?
> 
> [ ... ]

Hello,

Earlier today I ran into the bug mentioned at the start of this thread
with kernel 3.19-rc1 and the e1000e driver. Can anyone tell me what the
latest status is ?

Thanks,

Bart.
