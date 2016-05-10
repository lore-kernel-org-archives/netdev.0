From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 17:57:17 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1605101655100.3540@nanos>
References: <cover.1462886866.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1462886866.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 May 2016, Paolo Abeni wrote:

Nice patch set and very promising results! 

> At this point we are not really sure if we should go with this simpler
> approach by putting NAPI itself into kthreads or leverage the threadirqs
> function by putting the whole interrupt into a thread and signaling NAPI
> that it does not reschedule itself in a softirq but to simply run at
> this particular context of the interrupt handler.
> 
> While the threaded irq way seems to better integrate into the kernel and
> also other devices could move their interrupts into the threads easily
> on a common policy, we don't know how to really express the necessary
> knobs with the current device driver model (module parameters, sysfs
> attributes, etc.). This is where we would like to hear some opinions.
> NAPI would e.g. have to query the kernel if the particular IRQ/MSI if it
> should be scheduled in a softirq or in a thread, so we don't have to
> rewrite all device drivers. This might even be needed on a per rx-queue
> granularity.

Utilizing threaded irqs should be halfways simple even without touching the
device driver at all.

We can do the switch to threading in two ways:

1) Let the driver request the interrupt(s) as it does now and then have a
   /proc/irq/NNN/threaded file which converts it to a threaded interrupt on
   the fly. That should be fairly trivial.

2) Let the driver request the interrupt(s) as it does now and retrieve the
   interrupt number which belongs to the device/queue from the network core
   and let the irq core switch it over to threaded.

So the interrupt flow of the device would be:

interrupt
    IRQ_WAKE_THREAD
    
irq thread()
{ 
    local_bh_disable();
    action->thread_fn(action->irq, action->dev_id); <-- driver handler
    irq_finalize_oneshot(desc, action);
    local_bh_enable();
}

The driver irq handler calls napi_schedule(). So if your napi_struct is
flagged POLL_IRQ_THREAD then you can call your polling machinery from there
instead of raising the softirq.

You surely need some way to figure out whether the interrupt is threaded when
you set up the device in order to flag your napi struct, but that should be
not too hard to achieve.

Thanks,

	tglx



   
