From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Sun, 8 Jun 2003 23:59:55 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609065955.GC20613@netnation.com>
References: <001001c32e19$81bc7ea0$4a00000a@badass> <20030608230300.X33412@shell.cyberus.ca> <20030608.232537.102562046.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030608.232537.102562046.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Sun, Jun 08, 2003 at 11:25:37PM -0700, David S. Miller wrote:

> I do not believe that slow path is slow.  In fact after I fixed
> hash table growth in fib_hash.c Simon showed us clearly how DoS
> performance was _NOT_ tied to the number of routes loaded into
> the kernel.

Not anymore. :)  Btw, that patch seems to be stable here.  Will we be
seeing it sneak into 2.4?

> My main current quick idea is to make rt_intern_hash() attempt
> to flush out entries in the same hash chain instead of allocating
> new entries.
> 
> I also question the setting of ip_rt_max_size in relation to the
> number of hash chains (it's set to n_hashchains * 16 currently,
> that sounds wrong, maybe something more like n_hashchains * 2 or
> even n_hashchains * 3).

The route cache on our routers here grows to several thousand entries
most of the time because of the quantity of traffic we route, and then
all gets happily blown away when the next BGP table change comes along,
which seems to happen about 10-20 times per miunte (!).  It would
probably be beneficial for us to reduce the amount of work required when
blowing it away and keep it as small as possible.

> I'll try to cook up a patch to test.  We might even be able to

Woohoo!

> kill of route cache GC entriely if this scheme works well.

I asked Alexey about this before and he mentioned it was there because it
made a big difference in processing latency to postpone cleanup to a GC
run.  It should be possible to do recycling only when the table is full
(when the box is getting smashed).  This way latencies would be lowest in
the common case and it would recycle and not have spurts of GC latency in
the DoS case.

Simon-
