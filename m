From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 2 Jun 2003 08:18:52 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030602151852.GA6070@netnation.com>
References: <20030522.015815.91322249.davem@redhat.com> <20030522.034058.71558626.davem@redhat.com> <20030522114438.GD2961@netnation.com> <20030522.153330.74735095.davem@redhat.com> <20030529205125.GA30058@netnation.com> <16091.11735.721251.925522@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16091.11735.721251.925522@robur.slu.se>
List-Id: netdev.vger.kernel.org

On Mon, Jun 02, 2003 at 12:58:31PM +0200, Robert Olsson wrote:

>  New dst is coming all the time first seached in hash (ip_route_input) and not found
>  so ip_route_input_slow/fn_hash_lookup/dst_alloc/rt_intern_hash path is taken to add
>  a new dst entry...
> 
>  And later GC have to remove all enties with spin_lock_bh hold (no packet processing 
>  runs). I see packet drops exactly when GC runs. Tuning GC might help but it's something 
>  to observe.
> 
>  I had some idea to rate-limit new flows and try to isolate the device causing the DoS 
>  Something like (ip_route_input):
...
>                         if (net_ratelimit())
>                                 printk(KERN_WARNING "dst creation throttled\n");
> 
>                         return -ECONNREFUSED;

This reminds me of the situation we experienced with the dst cache
overflowing in early 2.2 kernels.  This was a long time ago, when our
traffic was only about 10 Mbits/second.  We had recently upgraded from a
2.0 kernel.  The dst cache was overflowing due to a bug in the garbage
collector, and at the time, no messages were printed.  It took me a
_long_ time to figure out why connections to a server I hadn't previously
connected to in a while would only work every so often, and not
immediately like they should.  I'm affraid this approach will have a
similar effect, albeit (hopefully) only under an attack.

Is it possible to have a dst LRU or a simpler approximation of such and
recycle dst entries rather than deallocating/reallocating them?  This
would relieve a lot of work from the garbage collector and avoid the
periodic large garbage collection latency.  It could be tuned to only
occur in an attack (I remember Alexey saying that the deferred garbage
collection was implemented to reduce latency in normal opreation).

Would this work?  Cross-CPU thrashing issues?

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
