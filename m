From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Tue, 13 Sep 2005 15:14:48 -0700
Message-ID: <20050913221448.GD15704@netnation.com>
References: <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se> <20050907162854.GB24735@netnation.com> <20050907195911.GA8382@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050907195911.GA8382@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 11:59:11PM +0400, Alexey Kuznetsov wrote:

> Hello!
> 
> > Yes, setting maxbatch to 10000 also results in working gc,
> 
> Could you try lower values? F.e. I guess 300 or a little more
> (it is netdev_max_backlog) should be enough.

300 seems to be sufficient, but I'm not sure what this depends on (load,
HZ, timing of some sort?).  See below for full tests.

> > for the normal case also hurts the DoS case...and it really hurts when
> > the when the DoS case is the normal case.
> 
> 5.7% is not "really hurts" yet. :-)

I decided to try out FreeBSD in comparison as I've heard people saying
that it handles this case quite well.  The results are interesting.

FreeBSD seems to have a route cache; however, it keys only on
destination.  When a new destination is seen, the route table entry that
matched is "cloned" so that the MTU, etc., is copied, the dst rewritten
to the exact IP (as opposed to a network route), and path MTU discovery
results are maintained in this entry, keyed by destination address only.

I'm not sure if Linux could work in the same way with the source routing
tables enabled, but perhaps it's possible to either disable the source
side of the route cache when policy routing is disabled.  Or perhaps a
route cache hash could be instantiated per route table or something.

Actually, is there ever a valid case where the source needs to be tracked
in the route cache when policy routing is disabled?  A local socket will
track MSS correctly while a forwarded packet will create or use an entry
without touching it, so I don't see why not.

Anyway, spoofed source or not go the same speed through FreeBSD.  Also,
there is a "fastforwarding" sysctl that sends forwarded packets from
the input interrupt/poll without queueing them in a soft interrupt
("NETISR").

Polling mode on FreeBSD isn't as nice as NAPI in that it's fully manual
on or off, and when it's on it triggers entirely from the timer interrupt
unless told to also trigger from the idle loop.  The user/kernel balancing
is also manual but I can't seem to get it to forward as fast as with it
disabled no matter how I adjust it.


TEST RESULTS
------------

All Linux tests with NAPI enabled and the e1000 driver native to that
kernel unless otherwise specified.  maxbatch does not exist in kernels
< 2.6.9, and rhash_size does not exist in 2.4.


Sender: 367 Mbps, 717883 pps valid src/dst, 64 byte (Ethernet) packets

2.4.27-rc1: 297 Mbps forwarded (w/idle time?!)
2.4.31: 296 Mbps forwarded (w/idle time?!)
2.6.13-rc6: 173 Mbps forwarded
FreeBSD 5.4-RELEASE (HZ=1000): 103 Mbps forwarded (dead userland)
`- net.inet.ip.fastforwarding=1: 282 Mbps forwarded (dead userland)
   `- kern.polling.enable=1: 75.3 Mbps forwarded
      `- kern.polling.idle_poll=1: 226 Mbps forwarded


Sender: 348 Mbps, 680416 pps random src, valid dst, 64 bytes

(All FreeBSD tests have identical results.)

2.4.27-rc1: 122 Mbps forwarded
2.4.27-rc1 gc_elasticity=1: 182 Mbps forwarded
2.4.27-rc1+2.4.31_e1000: 117 Mbps forwarded
2.4.27-rc1+2.4.31_e1000 gc_elasticity=1: 170 Mbps forwarded
2.4.31: 95.1 Mbps forwarded
2.4.31 gc_elasticity=1: 122 Mbps forwarded

2.6.13-rc6: <1 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=30: <1 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=60: 1.5 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=100: 2.6 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=150: 3.8 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=200: 6.9 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=250: 15.4 Mbps forwarded (dst overflow)
2.6.13-rc6 maxbatch=300: 58.6 Mbps forwarded (gc balanced)
2.6.13-rc6 maxbatch=350: 60.5 Mbps forwarded
2.6.13-rc6 maxbatch=400: 59.4 Mbps forwarded
2.6.13-rc6 maxbatch=450: 59.1 Mbps forwarded
2.6.13-rc6 maxbatch=500: 62.0 Mbps forwarded
2.6.13-rc6 maxbatch=550: 61.9 Mbps forwarded
2.6.13-rc6 maxbatch=1000: 61.4 Mbps forwarded
2.6.13-rc6 maxbatch=2000: 60.2 Mbps forwarded
2.6.13-rc6 maxbatch=3000: 60.1 Mbps forwarded
2.6.13-rc6 maxbatch=5000: 59.1 Mbps forwarded
2.6.13-rc6 maxbatch=MAXINT: 59.1 Mbps forwarded
2.6.13-rc6 dst_free: 66.0 Mbps forwarded
2.6.13-rc6 dst_free max_size=rhash_size: 79.2 Mbps forwarded

------------

2.6 definitely has better dst cache gc balancing than 2.4.  I can set
the max_size=rhash_size in 2.6.13-rc6 and it will just work, even without
adjusting gc_elasticity or gc_thresh.  In 2.4.27 and 2.4.31, the only
parameter that appears to help is gc_elasticity.  If I just adjust
max_size, it overflows and falls over.

I note that the actual read copy update "maxbatch" limit was added in
2.6.9.  Before then, it seems there was no limit (infinite).  Was it
added for latency reasons?

Time permitting, I'd also like to run some profiles.  It's interesting
to note that 2.6 is slower at forwarding even straight duplicate small
packets.  We should definitely get to the bottom of that.

Simon-
