From: "David S. Miller" <davem@davemloft.net>
Subject: Re: serious netpoll bug w/NAPI
Date: Wed, 16 Feb 2005 15:02:36 -0800
Message-ID: <20050216150236.61ca5faf.davem@davemloft.net>
References: <20050208201634.03074349.davem@davemloft.net>
	<20050209183219.GA2366@waste.org>
	<20050209164658.409f8950.davem@davemloft.net>
	<20050210011104.GF2366@waste.org>
	<16914.31886.665975.522710@segfault.boston.redhat.com>
	<20050216050722.GC3358@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmoyer@redhat.com, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050216050722.GC3358@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 21:07:22 -0800
Matt Mackall <mpm@selenic.com> wrote:

> Because dev->np->poll_lock now serializes all access to ->poll (when
> netpoll is enabled on said device).

I think there is still a problem.

Sure, we won't recurse into ->poll(), but instead we'll loop forever
in netpoll_send_skb() in this case when netif_queue_stopped() is true.
We can't get into the ->poll() routine, so the TX queue can't make
forward progress, yet we keep looping to the "repeat" label over
and over again.

So we've replaced a crash via ->poll() re-entry with a deadlock
in netpoll_send_skb() :-)

I also think that taking a global spinlock for every ->poll()
call is a huge price to pay on SMP.
