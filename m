From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 00:03:00 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609.000300.35030075.davem@redhat.com>
References: <20030608230300.X33412@shell.cyberus.ca>
	<20030608.232537.102562046.davem@redhat.com>
	<20030609065955.GC20613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030609065955.GC20613@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Sun, 8 Jun 2003 23:59:55 -0700

   On Sun, Jun 08, 2003 at 11:25:37PM -0700, David S. Miller wrote:
   
   > I do not believe that slow path is slow.  In fact after I fixed
   > hash table growth in fib_hash.c Simon showed us clearly how DoS
   > performance was _NOT_ tied to the number of routes loaded into
   > the kernel.
   
   Not anymore. :)  Btw, that patch seems to be stable here.  Will we be
   seeing it sneak into 2.4?
   
Yes, 2.4.22-pre1 will get it or somewhere thereabouts.

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

This is simple, by using a generation count.  When route lookup
sees a matching entry with a stale generation count, we pass
this entry as-is into ip_route_{input,output}_slow() and use it
instead of allocating new entry.

It is the same trick as used by the flow cache.
   
I'll code this up as well.

   > kill of route cache GC entriely if this scheme works well.
   
   I asked Alexey about this before and he mentioned it was there because it
   made a big difference in processing latency to postpone cleanup to a GC
   run.

The problem is that GC cannot currently keep up with DoS like traffic
pattern.  As a result, routing latency is not smooth at all, you get
spikes because each GC run goes for up to an entire jiffie because it
has so much work to do.  Meanwhile, during this expensive GC
processing, packet processing is frozen on UP system.

net/core/flow.c:flow_cache_lookup() is instructive, it implements
several of these ideas being discussed today.
