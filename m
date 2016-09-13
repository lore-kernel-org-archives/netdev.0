From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Tue, 13 Sep 2016 15:31:20 +0200
Message-ID: <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160913115627.GA4898@salvia>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/13/2016 01:56 PM, Pablo Neira Ayuso wrote:
> On Mon, Sep 12, 2016 at 06:12:09PM +0200, Daniel Mack wrote:
>> This is v5 of the patch set to allow eBPF programs for network
>> filtering and accounting to be attached to cgroups, so that they apply
>> to all sockets of all tasks placed in that cgroup. The logic also
>> allows to be extendeded for other cgroup based eBPF logic.
> 
> 1) This infrastructure can only be useful to systemd, or any similar
>    orchestration daemon. Look, you can only apply filtering policies
>    to processes that are launched by systemd, so this only works
>    for server processes.

Sorry, but both statements aren't true. The eBPF policies apply to every
process that is placed in a cgroup, and my example program in 6/6 shows
how that can be done from the command line. Also, systemd is able to
control userspace processes just fine, and it not limited to 'server
processes'.

> For client processes this infrastructure is
>    *racy*, you have to add new processes in runtime to the cgroup,
>    thus there will be time some little time where no filtering policy
>    will be applied. For quality of service, this may be an acceptable
>    race, but this is aiming to deploy a filtering policy.

That's a limitation that applies to many more control mechanisms in the
kernel, and it's something that can easily be solved with fork+exec.

> 2) This aproach looks uninfrastructured to me. This provides a hook
>    to push a bpf blob at a place in the stack that deploys a filtering
>    policy that is not visible to others.

That's just as transparent as SO_ATTACH_FILTER. What kind of
introspection mechanism do you have in mind?

> We have interfaces that allows
>    us to dump the filtering policy that is being applied, report events
>    to enable cooperation between several processes with similar
>    capabilities and so on.

Well, in practice, for netfilter, there can only be one instance in the
system that acts as central authoritative, otherwise you'll end up with
orphaned entries or with situation where some client deletes rules
behind the back of the one that originally installed it. So I really
think there is nothing wrong with demanding a single, privileged
controller to manage things.

>> After chatting with Daniel Borkmann and Alexei off-list, we concluded
>> that __dev_queue_xmit() is the place where the egress hooks should live
>> when eBPF programs need access to the L2 bits of the skb.
> 
> 3) This egress hook is coming very late, the only reason I find to
>    place it at __dev_queue_xmit() is that bpf naturally works with
>    layer 2 information in place. But this new hook is placed in
>    _everyone's output ath_ that only works for the very specific
>    usecase I exposed above.

It's about filtering outgoing network packets of applications, and
providing them with L2 information for filtering purposes. I don't think
that's a very specific use-case.

When the feature is not used at all, the added costs on the output path
are close to zero, due to the use of static branches. If used somewhere
in the system but not for the packet in flight, costs are slightly
higher but acceptable. In fact, it's not even measurable in my tests
here. How is that different from the netfilter OUTPUT hook, btw?

That said, limiting it to L3 is still an option. It's just that we need
ingress and egress to be in sync, so both would be L3 then. So far, the
possible advantages for future use-cases having access to L2 outweighed
the concerns of putting the hook to dev_queue_xmit(), but I'm open to
discussing that.

> The main concern during the workshop was that a hook only for cgroups
> is too specific, but this is actually even more specific than this.

This patch set merely implements an infrastructure that can accommodate
many more things as well in the future. We could, in theory, even add
hooks for forwarded packets specifically, or other eBPF programs, not
even for network filtering etc.

> I have nothing against systemd or the needs for more
> programmability/flexibility in the stack, but I think this needs to
> fulfill some requirements to fit into the infrastructure that we have
> in the right way.

Well, as I explained already, this patch set results from endless
discussions that went nowhere, about how such a thing can be achieved
with netfilter.


Thanks,
Daniel
