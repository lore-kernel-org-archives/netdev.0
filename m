From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Fri, 28 Oct 2016 13:28:39 +0200
Message-ID: <20161028112839.GA29798@salvia>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia>
 <20161027033502.GA43960@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161027033502.GA43960-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Wed, Oct 26, 2016 at 08:35:04PM -0700, Alexei Starovoitov wrote:
> On Wed, Oct 26, 2016 at 09:59:33PM +0200, Pablo Neira Ayuso wrote:
> > On Tue, Oct 25, 2016 at 12:14:08PM +0200, Daniel Mack wrote:
> > [...]
> > >   Dumping programs once they are installed is problematic because of
> > >   the internal optimizations done to the eBPF program during its
> > >   lifetime. Also, the references to maps etc. would need to be
> > >   restored during the dump.
> > > 
> > >   Just exposing whether or not a program is attached would be
> > >   trivial to do, however, most easily through another bpf(2)
> > >   command. That can be added later on though.
> > 
> > I don't know if anyone told you, but during last netconf, this topic
> > took a bit of time of discussion and it was controversial, I would say
> > 1/3 of netdev hackers there showed their concerns, and that's
> > something that should not be skipped IMO.
> 
> Though I attended netconf over hangouts, I think it was pretty
> clear that bpf needs 'introspection' of loaded bpf programs and it
> was a universal desire of everyone. Not 1/3 of hackers.

Introspection is a different thing, very useful, no doubt. But this
infrastructure is allowing way more than simple innocuous introspection.

> As commit log says it's an orthogonal work and over the last
> month we've been discussing pros and cons of different approaches.
> The audit infra, tracepoints and other ideas.
> We kept the discussion in private because, unfortunately, public
> discussions are not fruitful due to threads like this one.

We need to understand what people are trying to solve and it what way.
That's why we have all those conferences and places to meet and
discuss too. Please, don't think like that, this is sending the wrong
message to everyone here, that is kind of: bypass public discussions
and don't take time to describe what you're doing since it is a waste
of time. That's not good.

> The further points below were disputed many times in the past.
> Let's address them one more time:
> 
> > path. But this is adding hooks to push bpf programs in the middle of
> > our generic stack, this is way different domain.
> 
> incorrect. look at socket filters, cls_bpf.

Classic socket filters don't allow you to deploy a global policy in
such a fine grain way as this is doing. Then, cls_bpf is fine since it
is visible via tc command, so sysadmins can use tools they are
familiar with to inspect policies and say "oh look, some of the
processes I'm deploying have installed filters via cls_bpf". However,
this approach is visible in no way.

[...]
> > around this socket code in functions so we can invoke it. I guess
> > filtering of UDP and TCP should be good for you at this stage.
> 
> DanielM mentioned few times that it's not only about UDP and TCP.

OK, since this is limited to the scope of inet sockets, let's revisit
what we have around: DCCP is hopeless, who cares. We also have SCTP,
that is deployed by telcos in datacenters, it cannot reach that domain
because many Internet gateways are broken for it, so you may not get
too far with it. Arguably it would be good to have SCTP support at
some point, but I guess this is not a priority now. Then, UDPlite
almost comes for free since it relies on the existing UDP
infrastructure, it's basically UDP with a bit more features. What
else?

> > This would require more work though, but this would come with no
> > hooks in the stack and packets will not have to consume *lots of
> > cycles* just to be dropped before entering the socket queue.
> 
> packets don't consume 'lost of cycles'. This is not a typical
> n-tuple firewall framework. Not a DoS mitigation either. Please read
> the cover letter and earlier submissions.
> It's a framework centered around cgroups.
> _Nothing_ in the current stack provides cgroup based monitoring
> and application protection. Earlier cgroupv1 controllers don't
> scale and we really cannot have more of v1 net controllers.
> At the same time we've been brainstorming how this patch set
> can work with v1. It's not easy. We're not giving up though.
> For now it's v2 only.
> Note that another two patchsets depend on this core cgroup+bpf framework.

I saw those, I would really like to have a closer look at David
Ahern's usecase since that skb iif mangling looks kludgy to me, and
given this is exposing a new helper for general use, not only vrf, it
would be good to make sure helpers provide something useful for
everyone. So that new helper is questionable at this stage IMO. I'm
concerned that people may start using bpf as the adhesive tape to glue
things to solve probably design problems.

The other patchset, I guess you refer to the new lsm module: I would
suggest we address one thing at a time, I guess he can starts without
relying on this chunk, as it can follow up later anyway.

In general, I think bpf is very useful, but I think we have to
accomodate new things in a way that makes sense into what we have. We
have traditionally followed an "add in-kernel infrastructured +
provide userspace interface as control plane" approach for long time.
I have concerns (and my impression is that others were concerned in
netconf too) on if we can go from the existing approach to a fully
uninfrastructured use-bpf-everywhere, from one day to another without
even taking the time to discuss the consequences of this decision.

Thanks.
