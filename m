From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Tue, 27 Jan 2004 12:59:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040127115917.GA19166@louise.pinerecords.com>
References: <1075058539.1747.92.camel@jzny.localdomain> <20040125202148.GA10599@usr.lcm.msu.ru> <1075074316.1747.115.camel@jzny.localdomain> <20040126001102.GA12303@usr.lcm.msu.ru> <1075086588.1732.221.camel@jzny.localdomain> <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru> <20040126152409.GA10053@louise.pinerecords.com> <1075173275.1039.53.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vladimir B. Savkin" <master@sectorb.msk.ru>, netdev@oss.sgi.com,
        volf@dragon.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075173275.1039.53.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Jan-26 2004, Mon, 22:14 -0500
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2004-01-26 at 10:24, Tomas Szepe wrote:
> [..]
> > Actually, this is very much like what we're using IMQ for:
> > 
> >                   +-----------+ eth1 --- \
> >                   | shaper    + eth2 ---
> > Internet --- eth0 + in bridge + .    ---    ... WAN (10 C's of customer IPs)
> >                   | setup     + .    ---
> >                   +-----------+ ethN --- /
> > 
> > We're shaping single IPs and groups of IPs, applying tariff rates
> > on the sum of inbound and outbound flow (this last point, I'm told,
> > is the primary reason for our use of IMQ).]
> 
> This does not IMQ. I am going to type an example at the end of the
> email.

Thanks for your reply, Jamal.  Unfortunately, we don't really understand
your example.  Please see below.

[snip]
> BTW, how are you going to do SNAT with bridging?

We aren't.  :) We won't need bridging on those firewalls, it's only
necessary for the main shaper box.  I apologize for not making that
clear in my previous post.

> The example below tries to show many things. Example sharing of
> policers across many flows within a device, and across devices.
> Also shows how to do it so that inbound and outbound are summed up.
> [snip]

What's the mechanism for matching the IPs?  We need to insert
thousands of these rules and shape constant 20+ Mbit flow of
traffic.  If it doesn't use a hash or similar, we're back to
where we started.

> # On the return path from internet to eth1, packets from
> # internet to 10.0.0.21 are forced to use policer index 1
> # and therefore ensuring that the bandwidth is allocated
> # is the sum of inbound and outbound for that flow ..
> # 
> #
> #add ingress qdisc
> tc qdisc add dev eth1 ingress
> #
> tc filter add dev eth1 parent ffff: protocol ip prio 1 \
> u32 match ip src 10.0.0.21/32 flowid 1:15 \
> # first give it a mark of 1
> action ipt -j mark --set-mark 1 index 2 \
> # ensure policer index 1 is used
> action police index 1 rate 1kbit burst 9k pipe \
> # exceeded flows bound rate ..
> action ipt -j mark --set-mark 2 \
> #
> action police index 200 mtu 5000 rate 1kbit burst 10k pipe \
> action ipt -j mark --set-mark 3 \
> action police index 300 mtu 5000 rate 1kbit burst 90k drop
> #
> #
> # do something on eth0 with these firewall marks
> # example use them to send packets to different classes/queue
> # give priority to marks 1 then 2 then 3
> #
> .
> .
> .
> # now the return path to 10.0.0.21 ...
> tc qdisc add dev eth1 handle 1:0 root prio 
> #
> # note how exactly the same policer is used ("index 1")
> tc filter add dev eth1 parent 1:0 protocol ip prio 1 \
> u32 match ip dst 10.0.0.21/32 flowid 1:25 \
> action police index 1 rate 1kbit burst 9k pipe 

Would you know of any real documentation on tc/ingress that
we could use to deconstruct this example and understand it?

At this moment we can only guess at what's happening. :(

-- 
Tomas Szepe <szepe@pinerecords.com>
