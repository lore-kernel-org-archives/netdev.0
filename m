From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Sat, 28 May 2005 14:07:31 +0200
Message-ID: <20050528120731.GP15391@postel.suug.ch>
References: <20050526185526.GZ15391@postel.suug.ch> <1117192464.6688.3.camel@localhost.localdomain> <20050527121503.GN15391@postel.suug.ch> <1117201853.6383.29.camel@localhost.localdomain> <20050527141023.GP15391@postel.suug.ch> <1117205822.6383.68.camel@localhost.localdomain> <20050527151608.GZ15391@postel.suug.ch> <1117209411.6383.104.camel@localhost.localdomain> <20050527163516.GB15391@postel.suug.ch> <1117244567.6251.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117244567.6251.34.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117244567.6251.34.camel@localhost.localdomain> 2005-05-27 21:42
> On Fri, 2005-27-05 at 18:35 +0200, Thomas Graf wrote:
> 
> > I do NOT agree on moving gc_ into this architecture as well,
> > it doesn't belong there.
> 
> Well, you do realize they are part of the in_dev ? ;->

Huh? They cannot be device specific, there is only one gc
per neighbour table. So even _iff_ there was a device specific
setting it wouldn't make much sense ;->

> I see a little main service header with ifindex always no different than
> IFA or IFLINK etc followed by appropriate TLVs which are nested.

I guess we could simply move NDTPA_PARMS into the devconfig family.

> 
> Unfortunately i still cant find the patch - i started with a different
> approach; my immediate interest was to get events when someone made 
> in_device changes. BTW, this is going to be one of the main challenges
> since there are many paths to configure these things.

Right.

> Well, if you look at the structure there is no reason they should really
> be separate; infact theres a comment:
> -----------
>          struct neigh_parms      parms;
>         /* HACK. gc_* shoul follow parms without a gap! */
>         int                     gc_interval;
>         int                     gc_thresh1;
>         int                     gc_thresh2;
> ----------

You do realize the reason for that comment? ;-> The author of
the neighbour procfs code was simply too lazy to put these
into a separate place so he introduced a nasty hack.


> > I understand your architecture and if we follow this thought
> > we'd have a "default" netdevice which repesents all default
> > settings. 
> 
> >From looking at the code, the default stuff seems to be "hardcoded".
> Example in the definition arp_tbl.

These are just the default values for the default parameter set.

> The model like i said is clean. There are some issues i have qualms with
> - such as IP address arrangements and tight integration with netdevices
> - but those can addressed at a later time.

What about this, we move the device specific part into the new devconfig
layer but leave the main configuration, statistics, and gc parameters
in RTM_NEIGHTBL? i.e.

 arp_cache entries 2 reachable-time 23s 993msec retransmit-time 1s
     key-len 4 entry-size 152 last-flush 55m 44s 572msec
     gc threshold 128/512/1024 interval 30s chain-position 3
     hash-rand 0x69650257/0x00000003 last-rand 1m 44s 571msec
?    refcnt 1 pending-queue-limit 3 proxy-delayed-queue-limit 64
?    num-userspace-probes 0 num-unicast-probes 3 num-multicast-probes 3
?    min-age 1s base-reachable-time 30s stale-check-interval 1m
?    initial-probe-delay 5s answer-delay 1s proxy-answer-delay 800msec
     lookups 195 hits 190 failed 0 allocations 3 destroys 1
     hash-grows 1 forced-gc-runs 0 periodic-gc-runs 910
     rcv-unicast-probes 0 rcv-multicast-probes 0

Xarp_cache<eth0> reachable-time 35s 967msec retransmit-time 1s
X    refcnt 3 pending-queue-limit 3 proxy-delayed-queue-limit 64
X    num-userspace-probes 0 num-unicast-probes 3 num-multicast-probes 3
X    min-age 1s base-reachable-time 30s stale-check-interval 1m
X    initial-probe-delay 5s answer-delay 1s proxy-answer-delay 800msec


Everything marked with X is clearly device specific so it will move.
Everything marked with '?' is the default parameter set, we can either
leave it or move it as well and put it under into a 'default' ifindex.
I don't care about the latter, either is fine with me.
