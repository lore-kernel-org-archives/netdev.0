From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Fri, 28 Oct 2016 13:53:11 +0200
Message-ID: <20161028115311.GB29798@salvia>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia>
 <c9683122-d770-355b-e275-7c446e6d1d0f@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c9683122-d770-355b-e275-7c446e6d1d0f-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2016 at 10:40:14AM +0200, Daniel Mack wrote:
> On 10/26/2016 09:59 PM, Pablo Neira Ayuso wrote:
> > On Tue, Oct 25, 2016 at 12:14:08PM +0200, Daniel Mack wrote:
> > [...]
> >>   Dumping programs once they are installed is problematic because of
> >>   the internal optimizations done to the eBPF program during its
> >>   lifetime. Also, the references to maps etc. would need to be
> >>   restored during the dump.
> >>
> >>   Just exposing whether or not a program is attached would be
> >>   trivial to do, however, most easily through another bpf(2)
> >>   command. That can be added later on though.
> > 
> > I don't know if anyone told you, but during last netconf, this topic
> > took a bit of time of discussion and it was controversial, I would say
> > 1/3 of netdev hackers there showed their concerns, and that's
> > something that should not be skipped IMO.
> > 
> > While xdp is pushing bpf programs at the very early packet path, not
> > interfering with the stack, before even entering the generic ingress
> > path. But this is adding hooks to push bpf programs in the middle of
> > our generic stack, this is way different domain.
> 
> It's not anything new. These hooks live on the very same level as
> SO_ATTACH_FILTER. The only differences are that the BPF programs are
> stored in the cgroup, and not in the socket, and that they exist for
> egress as well.

Can we agree this is going further than SO_ATTACH_FILTER?

> > I would really like to explore way earlier filtering, by extending
> > socket lookup facilities. So far the problem seems to be that we need
> > to lookup for broadcast/multicast UDP sockets and those cannot be
> > attach via the usual skb->sk.
> 
> We've been there. We've discussed all that. And we concluded that doing
> early demux in the input filter path is not the right approach. That was
> my very first take on that issue back in June 2015 (!), and it was
> rightfully turned down for good reasons.
> 
> Adding it there would mean we need to early-demux *every* packet as soon
> as there is *any* such rule installed, and that renders many
> optimizations in the kernel to drop traffic that has no local receiver
> useless.

I think such concern applies to doing early demux inconditionally in
all possible scenarios (such as UDP broadcast/multicast), that implies
wasted cycles for people not requiring this.

If we can do what demuxing in an optional way, ie. only when socket
filtering is required, then only those that need it would pay that
price. Actually, if we can do this demux very early, from ingress,
performance numbers would be also good to perform any socket-based
filtering.

[...]
> > I think it would be possible to wrap
> > around this socket code in functions so we can invoke it. I guess
> > filtering of UDP and TCP should be good for you at this stage. This
> > would require more work though, but this would come with no hooks in
> > the stack and packets will not have to consume *lots of cycles* just
> > to be dropped before entering the socket queue.
> >
> > How useful can be to drop lots of unwanted traffic at such a late
> > stage? How would the performance numbers to drop packets would look
> > like? Extremely bad, I predict.
> 
> I fear I'm repeating myself here, but this is unfounded. I'm not sure
> why you keep bringing it up. As I said weeks ago - just loading the
> netfilter modules without any rules deployed has more impact than
> running the example program in 6/6 on every packet in the test traffic.

I guess you're using an old kernel and refering to iptables, this is
not true for some time, so we don't have any impact now with loaded
iptables modules.
