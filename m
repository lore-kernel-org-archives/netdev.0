From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Wed, 21 Sep 2016 17:45:33 +0200
Message-ID: <20160921154533.GA13656@salvia>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Tue, Sep 20, 2016 at 06:43:35PM +0200, Daniel Mack wrote:
> Hi Pablo,
> 
> On 09/20/2016 04:29 PM, Pablo Neira Ayuso wrote:
> > On Mon, Sep 19, 2016 at 10:56:14PM +0200, Daniel Mack wrote:
> > [...]
> >> Why would we artificially limit the use-cases of this implementation if
> >> the way it stands, both filtering and introspection are possible?
> > 
> > Why should we place infrastructure in the kernel to filter packets so
> > late, and why at postrouting btw, when we can do this way earlier
> > before any packet is actually sent?
> 
> The point is that from an application's perspective, restricting the
> ability to bind a port and dropping packets that are being sent is a
> very different thing. Applications will start to behave differently if
> they can't bind to a port, and that's something we do not want to happen.

What is exactly the problem? Applications are not checking for return
value from bind? They should be fixed. If you want to collect
statistics, I see no reason why you couldn't collect them for every
EACCESS on each bind() call.

> Looking at packets and making a verdict on them is the only way to
> implement what we have in mind. Given that's in line with what netfilter
> does, it can't be all that wrong, can it?

That output hook was added ~20 years ago... At that time we didn't
have anything better than dropping locally generated packets. Today we
can probably do something better.

> > No performance impact, no need for
> > skbuff allocation and *no cycles wasted to evaluate if every packet is
> > wanted or not*.
> 
> Hmm, not sure why this keeps coming up. As I said - for accounting,
> there is no other option than to look at every packet and its size.
> 
> Regarding the performance concerns, are you saying a netfilter based
> implementation that uses counters for that purpose would be more
> efficient?

> Because in my tests, just loading the netfilter modules with no
> rules in place at all has more impact than running the code from 6/6
> on every packet.

You must be talking on iptables. When did you test this? We now have
on-demand hook registration per-netns, anyway, in nftables you only
register what you need.

Everytime you mention about performance, it sounds like there is no
room to improve what we have... and we indeed have room and ideas to
get this flying faster, but keeping in mind good integration with our
generic network stack and extensible interfaces, that's important too.
On top of that, I started working on some preliminary patches to add
nftables jit, will be talking on this during NetDev 1.2
netfilter/nftables workshop. I would expect numbers close to what
you're observing with this solution.
