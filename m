From: "David S. Miller" <davem@davemloft.net>
Subject: Re: serious netpoll bug w/NAPI
Date: Wed, 9 Feb 2005 16:46:58 -0800
Message-ID: <20050209164658.409f8950.davem@davemloft.net>
References: <20050208201634.03074349.davem@davemloft.net>
	<20050209183219.GA2366@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmoyer@redhat.com, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050209183219.GA2366@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Feb 2005 10:32:19 -0800
Matt Mackall <mpm@selenic.com> wrote:

> On closer inspection, there's a couple other related failure cases
> with the new ->poll logic in netpoll. I'm afraid it looks like
> CONFIG_NETPOLL will need to guard ->poll() with a per-device spinlock
> on netpoll-enabled devices.
> 
> This will mean putting a pointer to struct netpoll in struct
> net_device (which I should have done in the first place) and will take
> a few patches to sort out.

Will this ->poll() guarding lock be acquired only in the netpoll
code or system-wide?  If the latter, this introduced an incredible
performance regression for devices using the LLTX locking scheme
(ie. the most important high-performance gigabit drivers in the
tree use this).

Please detail your fix idea so that I can analyze a concrete idea
instead of some guess on my part :-)

I know you want to do anything except drop the packet.  What you
may do instead, therefore, is add the packet to the normal device
mid-layer queue and kick NET_TX_ACTION if netif_queue_stopped() is
true.

Sure, the packet still might get dropped in extreme cases, but
this idea seems to eliminate all of this locking complexity netpoll
is trying to handle.

As an aside, ipt_LOG is a great stress test for netpoll, because 4
incoming packets can generate 8 outgoing packets worth of netconsole
traffic :-)
