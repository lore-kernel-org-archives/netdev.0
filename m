From: Matt Mackall <mpm@selenic.com>
Subject: Re: serious netpoll bug w/NAPI
Date: Wed, 16 Feb 2005 15:44:06 -0800
Message-ID: <20050216234406.GA3120@waste.org>
References: <20050208201634.03074349.davem@davemloft.net> <20050209183219.GA2366@waste.org> <20050209164658.409f8950.davem@davemloft.net> <20050210011104.GF2366@waste.org> <16914.31886.665975.522710@segfault.boston.redhat.com> <20050216050722.GC3358@waste.org> <20050216150236.61ca5faf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmoyer@redhat.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050216150236.61ca5faf.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 16, 2005 at 03:02:36PM -0800, David S. Miller wrote:
> On Tue, 15 Feb 2005 21:07:22 -0800
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > Because dev->np->poll_lock now serializes all access to ->poll (when
> > netpoll is enabled on said device).
> 
> I think there is still a problem.
> 
> Sure, we won't recurse into ->poll(), but instead we'll loop forever
> in netpoll_send_skb() in this case when netif_queue_stopped() is true.
> We can't get into the ->poll() routine, so the TX queue can't make
> forward progress, yet we keep looping to the "repeat" label over
> and over again.

I'm not distinguishing between recursion and race with another CPU
yet. Hrmm.

> So we've replaced a crash via ->poll() re-entry with a deadlock
> in netpoll_send_skb() :-)
> 
> I also think that taking a global spinlock for every ->poll()
> call is a huge price to pay on SMP.

Ok. We've got a few cases:

1) recursion on cpu1
2) netpoll on cpu1 starts after softirq ->poll on cpu2
3) netpoll on cpu1 starts before softirq ->poll on cpu2

We could do lock-free recursion detection with:

 dev->np->poll_owner = smp_processor_id().

This can replace the suggested np->poll_flag. This also helps with
case 2 where I'm currently doing trylock in netpoll. But this doesn't
help with case 3, and a solution that isn't the equivalent of a
spinlock doesn't jump out at me.

-- 
Mathematics is the supreme nostalgia of our time.
