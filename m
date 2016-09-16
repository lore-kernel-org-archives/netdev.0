From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Fri, 16 Sep 2016 12:57:29 -0700
Message-ID: <20160916195728.GA14736@ircssh.c.rugged-nimbus-611.internal>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35396 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935021AbcIPT5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:57:32 -0400
Received: by mail-io0-f181.google.com with SMTP id m186so36874097ioa.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:57:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 01:13:16PM +0200, Daniel Mack wrote:
> Hi Pablo,
> 
> On 09/13/2016 07:24 PM, Pablo Neira Ayuso wrote:
> > On Tue, Sep 13, 2016 at 03:31:20PM +0200, Daniel Mack wrote:
> >> On 09/13/2016 01:56 PM, Pablo Neira Ayuso wrote:
> >>> On Mon, Sep 12, 2016 at 06:12:09PM +0200, Daniel Mack wrote:
> >>>> This is v5 of the patch set to allow eBPF programs for network
> >>>> filtering and accounting to be attached to cgroups, so that they apply
> >>>> to all sockets of all tasks placed in that cgroup. The logic also
> >>>> allows to be extendeded for other cgroup based eBPF logic.
> >>>
> >>> 1) This infrastructure can only be useful to systemd, or any similar
> >>>    orchestration daemon. Look, you can only apply filtering policies
> >>>    to processes that are launched by systemd, so this only works
> >>>    for server processes.
> >>
> >> Sorry, but both statements aren't true. The eBPF policies apply to every
> >> process that is placed in a cgroup, and my example program in 6/6 shows
> >> how that can be done from the command line.
> > 
> > Then you have to explain me how can anyone else than systemd use this
> > infrastructure?
> 
> I have no idea what makes you think this is limited to systemd. As I
> said, I provided an example for userspace that works from the command
> line. The same limitation apply as for all other users of cgroups.
> 
So, at least in my work, we have Mesos, but on nearly every machine that Mesos 
runs, people also have systemd. Now, there's recently become a bit of a battle 
of ownership of things like cgroups on these machines. We can usually solve it 
by nesting under systemd cgroups, and thus so far we've avoided making too many 
systemd-specific concessions.

The reason this works (mostly), is because everything we touch has a sense of 
nesting, where we can apply policy at a place lower in the hierarchy, and yet 
systemd's monitoring and policy still stays in place. 

Now, with this patch, we don't have that, but I think we can reasonably add some 
flag like "no override" when applying policies, or alternatively something like 
"no new privileges", to prevent children from applying policies that override 
top-level policy. I realize there is a speed concern as well, but I think for 
people who want nested policy, we're willing to make the tradeoff. The cost
of traversing a few extra pointers still outweighs the overhead of network
namespaces, iptables, etc.. for many of us. 

What do you think Daniel?

> > My main point is that those processes *need* to be launched by the
> > orchestrator, which is was refering as 'server processes'.
> 
> Yes, that's right. But as I said, this rule applies to many other kernel
> concepts, so I don't see any real issue.
>
Also, cgroups have become such a big part of how applications are managed
that many of us have solved this problem.

> >> That's a limitation that applies to many more control mechanisms in the
> >> kernel, and it's something that can easily be solved with fork+exec.
> > 
> > As long as you have control to launch the processes yes, but this
> > will not work in other scenarios. Just like cgroup net_cls and friends
> > are broken for filtering for things that you have no control to
> > fork+exec.
> 
> Probably, but that's only solvable with rules that store the full cgroup
> path then, and do a string comparison (!) for each packet flying by.
>
> >> That's just as transparent as SO_ATTACH_FILTER. What kind of
> >> introspection mechanism do you have in mind?
> > 
> > SO_ATTACH_FILTER is called from the process itself, so this is a local
> > filtering policy that you apply to your own process.
> 
> Not necessarily. You can as well do it the inetd way, and pass the
> socket to a process that is launched on demand, but do SO_ATTACH_FILTER
> + SO_LOCK_FILTER  in the middle. What happens with payload on the socket
> is not transparent to the launched binary at all. The proposed cgroup
> eBPF solution implements a very similar behavior in that regard.
> 
It would be nice to be able to see whether or not a filter is attached to a 
cgroup, but given this is going through syscalls, at least introspection
is possible as opposed to something like netlink.

> >> It's about filtering outgoing network packets of applications, and
> >> providing them with L2 information for filtering purposes. I don't think
> >> that's a very specific use-case.
> >>
> >> When the feature is not used at all, the added costs on the output path
> >> are close to zero, due to the use of static branches.
> > 
> > *You're proposing a socket filtering facility that hooks layer 2
> > output path*!
> 
> As I said, I'm open to discussing that. In order to make it work for L3,
> the LL_OFF issues need to be solved, as Daniel explained. Daniel,
> Alexei, any idea how much work that would be?
> 
> > That is only a rough ~30 lines kernel patchset to support this in
> > netfilter and only one extra input hook, with potential access to
> > conntrack and better integration with other existing subsystems.
> 
> Care to share the patches for that? I'd really like to have a look.
> 
> And FWIW, I agree with Thomas - there is nothing wrong with having
> multiple options to use for such use-cases.
Right now, for containers, we have netfilter and network namespaces.
There's a lot of performance overhead that comes with this. Not only
that, but iptables doesn't really have a simple way of usage by
automated infrastructure. We (firewalld, systemd, dockerd, mesos)
end up fighting with one another for ownership over firewall rules.

Although, I have problems with this approach, I think that it's
a good baseline where we can have top level owned by systemd,
docker underneath that, and Mesos underneath that. We can add
additional hooks for things like Checmate and Landlock, and
with a little more work, we can do compositition, solving
all of our problems.

> 
> 
> Thanks,
> Daniel
> 
