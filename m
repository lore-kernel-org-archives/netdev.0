From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: Sun, 24 Apr 2005 19:37:21 -0700
Message-ID: <20050424193721.01ecb0b2.davem@davemloft.net>
References: <20050305172257.GN31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050305172257.GN31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Mar 2005 18:22:57 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Before I go ahead, putting more effort into it, what is our preferred
> interface for network configuration? My personal preference is to make
> everything available via netlink with the long term plan to extend it
> with distributive remote configuration protocol in userspace. If so,
> shall we continue to push everything into rtnetlink regardless of the
> association to routing? The only drawback of the currently "overloaded"
> rtnetlink is the rtnl semaphore which has grown into something like
> the BKL for networking. I'm not aware of any performance problems or
> other issues because of this except for the module loading over nfs.
> Does anyone?
> 
> Thoughts?

Perhaps we shouldn't try to assosciate the rtnl semaphore with lock_kernel().
It really is more of a write lock than a lock which protects both reads
and writes.  (yes, I realize the rtnl packet processing code holds this
thing for all messages, not just ones which modify config state)

It is always going to be tempting to finer-grain the rtnl semaphore, but
just about every single RTNL state change has some trickle down effect on
some generic network device setting.  So at that moment any attempt to
fine-grain the locking for an RTNL operation fails.

It is tempting to consider a hierarchy of locks, with a locking order
such that generic netdev stuff sits at the bottom.  But welcome to an
AB<-->BA deadlock city as we hit generic device state changes which cause
modification of protocol specific addressing and routing state.

Back to the main topic, Thomas do you plan to complete this rtnetlink'ification
of neigh for the 2.6.13 timeframe?
