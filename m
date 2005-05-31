From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Tue, 31 May 2005 13:42:51 +0200
Message-ID: <20050531114251.GC15391@postel.suug.ch>
References: <20050527121503.GN15391@postel.suug.ch> <1117201853.6383.29.camel@localhost.localdomain> <20050527141023.GP15391@postel.suug.ch> <1117205822.6383.68.camel@localhost.localdomain> <20050527151608.GZ15391@postel.suug.ch> <1117209411.6383.104.camel@localhost.localdomain> <20050527163516.GB15391@postel.suug.ch> <1117244567.6251.34.camel@localhost.localdomain> <20050528120731.GP15391@postel.suug.ch> <1117533847.6134.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117533847.6134.32.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117533847.6134.32.camel@localhost.localdomain> 2005-05-31 06:04
> Probably a good start. This would still be missing the gc thresholds
> etc, no?

Yes, this only includes the parts that I marked with 'X' and '?' below.

> > What about this, we move the device specific part into the new devconfig
> > layer but leave the main configuration, statistics, and gc parameters
> > in RTM_NEIGHTBL? i.e.
> > 
> >  arp_cache entries 2 reachable-time 23s 993msec retransmit-time 1s
> >      key-len 4 entry-size 152 last-flush 55m 44s 572msec
> >      gc threshold 128/512/1024 interval 30s chain-position 3
> >      hash-rand 0x69650257/0x00000003 last-rand 1m 44s 571msec
> > ?    refcnt 1 pending-queue-limit 3 proxy-delayed-queue-limit 64
> > ?    num-userspace-probes 0 num-unicast-probes 3 num-multicast-probes 3
> > ?    min-age 1s base-reachable-time 30s stale-check-interval 1m
> > ?    initial-probe-delay 5s answer-delay 1s proxy-answer-delay 800msec
> >      lookups 195 hits 190 failed 0 allocations 3 destroys 1
> >      hash-grows 1 forced-gc-runs 0 periodic-gc-runs 910
> >      rcv-unicast-probes 0 rcv-multicast-probes 0
> > 
> > Xarp_cache<eth0> reachable-time 35s 967msec retransmit-time 1s
> > X    refcnt 3 pending-queue-limit 3 proxy-delayed-queue-limit 64
> > X    num-userspace-probes 0 num-unicast-probes 3 num-multicast-probes 3
> > X    min-age 1s base-reachable-time 30s stale-check-interval 1m
> > X    initial-probe-delay 5s answer-delay 1s proxy-answer-delay 800msec
> > 
> > 
> > Everything marked with X is clearly device specific so it will move.
> > Everything marked with '?' is the default parameter set, we can either
> > leave it or move it as well and put it under into a 'default' ifindex.
> > I don't care about the latter, either is fine with me.
> > 
> 
> All "stuffs" (your bases is mine) accessible via in_devxx abstraction
> should be devconfig configurable. I do concur that some of it may not
> make sense - but that should be the exception rules...
> Ok, lets say these tables are one such exception, but note:
> In the future there could be multiple ARP tables for example (very
> likely given all the virtualization approaches happening). In other
> words different devices may point to different tables...

Let's assume for a moment that there are no device specific parameters,
just the default parameter set, e.g everything in the "arp_cache" block.
According do your idea, everything would be part of a faked in_dev entry
with ifindex==0 (or alike). We'd have the exact same issues as with
RTM_NEIGHTBL, the requirement of unique table ids stays the same. There
is one big difference though, what if we ever have neighbour tables which
do not care about inet devices at all? Maybe some kind of new virtual
devices for in-kernel communication? ;-> Sounds scary and not realistic,
but my point is basically that neighbour tables itself have a global scope,
the assignment to the device and device specific parameters is on the
level of the neighbours itself. The connection to in_dev/... is one
level higher with a scope of the relevant neighbour table. A neighbour
table implementation is not required to support device specific
parameters, the code neighbour code will always assign the default
parameter set and leaves it up to the constructor of the implementation
level to reassign a device specific parameter set. Which means that what
the procfs and now also neightbl code does it kind of a hack anyway
since the core neighbour code is not aware of device specific stuff
anyway, all it does is provide an easy method to manage them in a
efficient matter.  I would like to stay consistent to this architecture
if possible to be able to follow every new additions.

I hope my point is now clear, I wasn't so sure until now ;-> However,
I think you have a good point, parameter sets have a strong relation
to inet devices at the moment. If you still think that we should move
_everything_ into a devconfig layer then I'll do it but I still support
my initial prospoal.
