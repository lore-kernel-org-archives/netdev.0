From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 20 Jan 2005 09:42:49 -0500
Message-ID: <1106232168.1041.125.camel@jzny.localdomain>
References: <20050117152312.GC26856@postel.suug.ch>
	 <1105976711.1078.1.camel@jzny.localdomain>
	 <20050117160539.GD26856@postel.suug.ch>
	 <1105979807.1078.16.camel@jzny.localdomain>
	 <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
	 <1106058592.1035.95.camel@jzny.localdomain>
	 <20050118145830.GS26856@postel.suug.ch>
	 <1106144009.1047.989.camel@jzny.localdomain>
	 <20050119165421.GB26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050119165421.GB26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-19 at 11:54, Thomas Graf wrote:
> * jamal <1106144009.1047.989.camel@jzny.localdomain> 2005-01-19 09:13
> > What i mean is that we should probably leave iproute2 code alone so that
> > people can run old scripts etc with it.  i.e the netsh tool should just
> > either reuse libnetlink and add any things to it or create a brand new
> > library.
> 
> Inspected some more code and I've finished already more than I thought.
> The architecture currently allows specifying the grammar with macros
> like this:

[.. good stuff was here ..]

I like it. Assuming we can have arbitrary hierachies; you just show one
level - but that may be just the example at hand. Given that should be
able to meet the layout requirements that Lennert alluded to earlier.

> Looks a bit complicated but is actually quite easy, you can do it the
> linux way. 

I get it, like it and yes TheLinuxWay is the OnlyWay ;->

[..]

> The status of the whole thing: link and neighbour are finished,
> core architecture finished as well, route is half done, addresses
> are half done (both easy to finish). libnl has net/sched/
> finished but is still missing code for a lot of modules. 

This is the part i am a little uncomfortable with. If you can make that
library maybe part of iproute2 it would ease maintanance. Extend
libnetlink or have another layer on top of it. 
I know you have already put the effort, but consider this thought.

> Session
> management (commit/rollback) was once in but was too unstable,
> needs a partial rewrite (design flaws) but should fit in quite
> easly because libnl was designed to support it. It will basically
> look like: nl_session_start(); ... any high level operations ..
> if (nl_session_commit() < 0) nl_session_rollback();
> 

Looks right.

> Problems? Keeping the cache valid (multiple netlink programs).
> The final update just before the commit and the commit itself
> must be atomic.
> 

Indeed.

> Solutions:
>  - Use ATOMIC flag (dangerous)

Would really need a kernel hack to do right. And .. would slow down
traffic while you hold the "atomic lock". 

>  - Seq counter in netlink, increased evertime a netlink message
>    gets processed and returned in ack. A netlink request may contain
>    a flag and the expected sequence number and the request gets only
>    processed if they match, otherwise the request fails. (my favourite)
>  - Lock file in userspace (how to enfroce everyone to use it?)
>  - Try to detect changes from third party after commit. Quite
>    hard but possible, reduces race window but doesn't close it
>    completely.
> 

Other apps changing things will screw you. If that gets handled then we
are set. I actually did start working on a netlink redirect(hook) for a
very different reason, but it should serve this purpose. Essentially you
register to be the proxy for netlink and all messages go via you. You
can then munge them, etc before issuing the response or allowing it to
go on to configure things. With this your "lock" would be to ask for
certain things to be redirected to you during an update phase.
Ok, maybe i will put more effort on it over the weekend (Sunday). 

> Background: I keep 2 caches, 1 cache represents the current state
> in the kernel, it gets updated when required. The second cache
> contains the local caches. The first cache gets merged into the
> second before the update and then gets commited. In case of a
> failure the first cache is used to restore things.
> 

Looks like the right way forward.

cheers,
jamal
