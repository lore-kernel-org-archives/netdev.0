From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Route cache performance
Date: Fri, 16 Sep 2005 01:04:32 +0400
Message-ID: <20050915210432.GD28925@yakov.inr.ac.ru>
References: <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se> <20050907162854.GB24735@netnation.com> <20050907195911.GA8382@yakov.inr.ac.ru> <20050913221448.GD15704@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
Content-Disposition: inline
In-Reply-To: <20050913221448.GD15704@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> 300 seems to be sufficient, but I'm not sure what this depends on (load,
> HZ, timing of some sort?).

It should be enough not depending on anything but sysctl
net/core/netdev_max_backlog.


> I'm not sure if Linux could work in the same way

It could, but it does not. Still.


> Actually, is there ever a valid case where the source needs to be tracked
> in the route cache when policy routing is disabled?

Unfortunately. It caches lots of information depeding on incoming
interface and address. All this is mostly useless and can be eliminated,
but it is not so trivial.


> there is a "fastforwarding" sysctl that sends forwarded packets from
> the input interrupt/poll without queueing them in a soft interrupt
> ("NETISR").

We used to experiment with this too. "fastroute" was killed completely,
napi is a little slower, but much better from viewpoint of maintainability.


>2.4.27-rc1: 297 Mbps forwarded (w/idle time?!)
vs
>2.6.13-rc6: 173 Mbps forwarded

and

> 2.4.27-rc1 gc_elasticity=1: 182 Mbps forwarded
vs
> 2.6.13-rc6 maxbatch=300: 58.6 Mbps forwarded (gc balanced)

No clue! There should be no such big difference. It is some disaster.

Something is very wrong and most of loss is even not related to routing cache.
Most likely it is driver or something is seriously screwed up in softirq
processing. Profiling is really required...

Robert, did you not see anything like this?


> 2.6 definitely has better dst cache gc balancing than 2.4.  I can set
> the max_size=rhash_size in 2.6.13-rc6 and it will just work, even without
> adjusting gc_elasticity or gc_thresh.  In 2.4.27 and 2.4.31, the only
> parameter that appears to help is gc_elasticity.  If I just adjust
> max_size, it overflows and falls over.

I have no idea why it works. Size of cache is determined by gc_elasticity
both in 2.4 and 2.6. Nothing changed.

The only difference in 2.4 is that it used to have wrong default
5 second value for gc_min_interval (0.5 sec in 2.6). Unless this is fixed,
gc just does not work at high rates.

Both in 2.6 and 2.4 you must not touch max_size unless you want to _increase_
it, default value is minimum allowed by sanity. Actually there is a hard
constraint: gc_elasticity*rhash_size <= max_size/2,
if you break this condition, it must break. Probably, you do not see
this because you do not change routing tables while testing.


> I note that the actual read copy update "maxbatch" limit was added in
> 2.6.9.  Before then, it seems there was no limit (infinite).  Was it
> added for latency reasons?

Before 2.6.9 rcu worked differently. It run very rarely and had to do
lots of work each run, effectively unlimited. Apparently, when RCU folks
finally implemented new better mechanism they also added some job limit
and did this wrong, 10 is ridiculously low limit.

Alexey
