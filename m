From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Tue, 13 Sep 2016 19:24:08 +0200
Message-ID: <20160913172408.GC6138@salvia>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <da300784-284c-0d1f-a82e-aa0a0f8ae116-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2016 at 03:31:20PM +0200, Daniel Mack wrote:
> Hi,
> 
> On 09/13/2016 01:56 PM, Pablo Neira Ayuso wrote:
> > On Mon, Sep 12, 2016 at 06:12:09PM +0200, Daniel Mack wrote:
> >> This is v5 of the patch set to allow eBPF programs for network
> >> filtering and accounting to be attached to cgroups, so that they apply
> >> to all sockets of all tasks placed in that cgroup. The logic also
> >> allows to be extendeded for other cgroup based eBPF logic.
> > 
> > 1) This infrastructure can only be useful to systemd, or any similar
> >    orchestration daemon. Look, you can only apply filtering policies
> >    to processes that are launched by systemd, so this only works
> >    for server processes.
> 
> Sorry, but both statements aren't true. The eBPF policies apply to every
> process that is placed in a cgroup, and my example program in 6/6 shows
> how that can be done from the command line.

Then you have to explain me how can anyone else than systemd use this
infrastructure?

> Also, systemd is able to control userspace processes just fine, and
> it not limited to 'server processes'.

My main point is that those processes *need* to be launched by the
orchestrator, which is was refering as 'server processes'.

> > For client processes this infrastructure is
> >    *racy*, you have to add new processes in runtime to the cgroup,
> >    thus there will be time some little time where no filtering policy
> >    will be applied. For quality of service, this may be an acceptable
> >    race, but this is aiming to deploy a filtering policy.
> 
> That's a limitation that applies to many more control mechanisms in the
> kernel, and it's something that can easily be solved with fork+exec.

As long as you have control to launch the processes yes, but this
will not work in other scenarios. Just like cgroup net_cls and friends
are broken for filtering for things that you have no control to
fork+exec.

To use this infrastructure from a non-launcher process, you'll have to
rely on the proc connection to subscribe to new process events, then
echo that pid to the cgroup, and that interface is asynchronous so
*adding new processes to the cgroup is subject to races*.

> > 2) This aproach looks uninfrastructured to me. This provides a hook
> >    to push a bpf blob at a place in the stack that deploys a filtering
> >    policy that is not visible to others.
> 
> That's just as transparent as SO_ATTACH_FILTER. What kind of
> introspection mechanism do you have in mind?

SO_ATTACH_FILTER is called from the process itself, so this is a local
filtering policy that you apply to your own process.

In this case, this filtering policy is *global*, other processes with
similar capabilities can get just a bpf blob at best...

[...]
> >> After chatting with Daniel Borkmann and Alexei off-list, we concluded
> >> that __dev_queue_xmit() is the place where the egress hooks should live
> >> when eBPF programs need access to the L2 bits of the skb.
> > 
> > 3) This egress hook is coming very late, the only reason I find to
> >    place it at __dev_queue_xmit() is that bpf naturally works with
> >    layer 2 information in place. But this new hook is placed in
> >    _everyone's output ath_ that only works for the very specific
> >    usecase I exposed above.
> 
> It's about filtering outgoing network packets of applications, and
> providing them with L2 information for filtering purposes. I don't think
> that's a very specific use-case.
> 
> When the feature is not used at all, the added costs on the output path
> are close to zero, due to the use of static branches.

*You're proposing a socket filtering facility that hooks layer 2
output path*!

[...]
> > I have nothing against systemd or the needs for more
> > programmability/flexibility in the stack, but I think this needs to
> > fulfill some requirements to fit into the infrastructure that we have
> > in the right way.
> 
> Well, as I explained already, this patch set results from endless
> discussions that went nowhere, about how such a thing can be achieved
> with netfilter.

That is only a rough ~30 lines kernel patchset to support this in
netfilter and only one extra input hook, with potential access to
conntrack and better integration with other existing subsystems.
