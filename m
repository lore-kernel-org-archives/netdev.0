From: Matt Mackall <mpm@selenic.com>
Subject: Re: serious netpoll bug w/NAPI
Date: Tue, 15 Feb 2005 21:07:22 -0800
Message-ID: <20050216050722.GC3358@waste.org>
References: <20050208201634.03074349.davem@davemloft.net> <20050209183219.GA2366@waste.org> <20050209164658.409f8950.davem@davemloft.net> <20050210011104.GF2366@waste.org> <16914.31886.665975.522710@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Jeff Moyer <jmoyer@redhat.com>
Content-Disposition: inline
In-Reply-To: <16914.31886.665975.522710@segfault.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 15, 2005 at 05:49:50PM -0500, Jeff Moyer wrote:
> ==> Regarding Re: serious netpoll bug w/NAPI; Matt Mackall <mpm@selenic.com> adds:
> 
> Sorry, Matt, I'm just now getting to this.
> 
> mpm> On Wed, Feb 09, 2005 at 04:46:58PM -0800, David S. Miller wrote:
> >> On Wed, 9 Feb 2005 10:32:19 -0800 Matt Mackall <mpm@selenic.com> wrote:
> >> 
> >> > On closer inspection, there's a couple other related failure cases >
> >> with the new ->poll logic in netpoll. I'm afraid it looks like >
> >> CONFIG_NETPOLL will need to guard ->poll() with a per-device spinlock >
> >> on netpoll-enabled devices.
> >> > 
> >> > This will mean putting a pointer to struct netpoll in struct >
> >> net_device (which I should have done in the first place) and will take >
> >> a few patches to sort out.
> >> 
> >> Will this ->poll() guarding lock be acquired only in the netpoll code or
> >> system-wide?  If the latter, this introduced an incredible performance
> >> regression for devices using the LLTX locking scheme (ie. the most
> >> important high-performance gigabit drivers in the tree use this).
> 
> mpm> The lock will only be taken in net_rx_action iff netpoll is enabled
> mpm> for the given device. Lock contention should be basically nil.
> 
> mpm> Here's my current patch (on top of -mm), which I'm struggling to find
> mpm> an appropriate test box for (my dual box with NAPI got pressed into
> mpm> service as a web server a couple weeks ago). I've attached the other
> mpm> two patches it relies on as well.
> 
> mpm> --------------
> 
> mpm> Introduce a per-client poll lock and flag. The lock assures we never
> mpm> have more than one caller in dev->poll(). The flag provides recursion
> mpm> avoidance on UP where the lock disappears.
> 
> ,----
> |  /*
> | - * Check whether delayed processing was scheduled for our current CPU,
> | - * and then manually invoke NAPI polling to pump data off the card.
> | + * Check whether delayed processing was scheduled for our NIC. If so,
> | + * we attempt to grab the poll lock and use ->poll() to pump the card.
> | + * If this fails, either we've recursed in ->poll() or it's already
> | + * running on another CPU.
> | + *
> | + * Note: we don't mask interrupts with this lock because we're using
> | + * trylock here and interrupts are already disabled in the softirq
> | + * case. Further, we test the poll_flag to avoid recursion on UP
> | + * systems where the lock doesn't exist.
> |   *
> |   * In cases where there is bi-directional communications, reading only
> |   * one message at a time can lead to packets being dropped by the
> | @@ -74,13 +80,9 @@
> |  static void poll_napi(struct netpoll *np)
> |  {
> |  	int budget = 16;
> | -	unsigned long flags;
> | -	struct softnet_data *queue;
> |  
> | -	spin_lock_irqsave(&netpoll_poll_lock, flags);
> | -	queue = &__get_cpu_var(softnet_data);
> |  	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
> | -	    !list_empty(&queue->poll_list)) {
> | +	    !np->poll_flag && spin_trylock(&np->poll_lock)) {
> |  		np->rx_flags |= NETPOLL_RX_DROP;
> |  		atomic_inc(&trapped);
> |  
> | @@ -88,8 +90,8 @@
> |  
> |  		atomic_dec(&trapped);
> |  		np->rx_flags &= ~NETPOLL_RX_DROP;
> | +		spin_unlock(&np->poll_lock);
> |  	}
> | -	spin_unlock_irqrestore(&netpoll_poll_lock, flags);
> |  }
> 
> Okay, I've only taken a quick glance at this, but I don't quite understand
> why it's safe to take out the check for the per-cpu queue.  Realize that an
> interrupt may have been serviced on another processor, and a NAPI poll may
> have been scheduled there.

Because dev->np->poll_lock now serializes all access to ->poll (when
netpoll is enabled on said device).

> Also, could you use the -p flag to diff when you generate your next patch?
> It makes it *much* easier to review.

Hmm, somehow my QUILT_DIFF_OPTS got lost, thanks.

I've just now recovered my SMP+NAPI box, so I can take a stab at
actually testing this shortly.

-- 
Mathematics is the supreme nostalgia of our time.
