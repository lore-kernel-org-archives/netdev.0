From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Fri, 19 Aug 2016 18:21:58 +0200
Message-ID: <20160819162158.GA25083@salvia>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60130 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753990AbcHSQWF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 12:22:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 836F1165ABE
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 18:22:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 72DD76DB3B
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 18:22:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0E919FC61A
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 18:21:59 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Fri, Aug 19, 2016 at 12:35:14PM +0200, Daniel Mack wrote:
> Hi Pablo,
> 
> On 08/19/2016 11:19 AM, Pablo Neira Ayuso wrote:
> > On Wed, Aug 17, 2016 at 04:00:43PM +0200, Daniel Mack wrote:
> >> I'd appreciate some feedback on this. Pablo has some remaining concerns
> >> about this approach, and I'd like to continue the discussion we had
> >> off-list in the light of this patchset.
> > 
> > OK, I'm going to summarize them here below:
> > 
> > * This new hook
> 
> "This" refers to your alternative to my patch set, right?
>
> > allows us to enforce an *administrative filtering
> >   policy* that must be visible to anyone with CAP_NET_ADMIN. This is
> >   easy to display in nf_tables as you can list the ruleset via the nft
> >   userspace tool. Otherwise, in your approach if a misconfigured
> >   filtering policy causes connectivity problems, I don't see how the
> >   sysadmin is going to have an easy way to troubleshoot what is going on.
> 
> True. That's the downside of bpf.
> 
> > * Interaction with other software. As I could read from your patch,
> >   what you propose will detach any previous existing filter. So I
> >   don't see how you can attach multiple filtering policies from
> >   different processes that don't cooperate each other.
> 
> Also true. A cgroup can currently only hold one bpf program for each
> direction, and they are supposed to be set from one controlling instance
> in the system. However, it is possible to create subcgroups, and install
> own programs in them, which will then be effective instead of the one in
> the parent. They will, however, replace each other in runtime behavior,
> and not be stacked. This is a fundamentally different approach than how
> nf_tables works of course.

I see, this looks problematic indeed, thanks for confirming this.

> > In nf_tables
> >   this is easy since they can create their own tables so they keep their
> >   ruleset in separate spaces. If the interaction is not OK, again the
> >   sysadmin can very quickly debug this since the policies would be
> >   visible via nf_tables ruleset listing.
> 
> True. Debugging would be much easier that way.
> 
> > So what I'm proposing goes in the direction of using the nf_tables
> > infrastructure instead:
> > 
> > * Add a new socket family for nf_tables with an input hook at
> >   sk_filter(). This just requires the new netfilter hook there and
> >   the boiler plate code to allow creating tables for this new family.
> >   And then we get access to many of the existing features in
> >   nf_tables for free.
> 
> Yes. However, when I proposed more or less exactly that back in
> September last year ("NF_INET_LOCAL_SOCKET_IN"), the concern raised by
> you and Florian Westphal was that this type of decision making is out of
> scope for netfilter, mostly because
>
> a) whether a userspace process is running should not have any influence
> in the netfilter behavior (which it does, because the rules are not
> processed when the local socket is cannot be determined)

We always have a socket at sk_filter(). This new socket family retains
this specific semantics.

> b) it is asymmetric, as it only exists for the input path

Unless strictly necessary, I would not add another earlier socket
egress hook if ipv4 and ipv6 LOCAL_OUT hook is enough for this.

> c) it's a change in netfilter paradigm, because rules for multicast
> receivers are run multiple times (once for each receiving task)

This is part of the semantics of this new socket family, so the user
is aware of this particular expensive multicast behaviour in this new
family.

> d) it was considered a sledgehammer solution for a something that very
> few people really need

I don't see why the current RFC is less heavyweight. I guess this was
true with the "hooks spread all over the transport layer" approach was
discussed, but not with the single sk_filter() hook we're discussing.

> I still think such a hook would be a good thing to have. As far as
> implementation goes, my patch set back then patched each of the
> protocols individually (ipv4, ipv6, dccp, sctp), while your idea to hook
> in to sk_filter sound much more reasonable.

That's it. Instead of having hooks spread all over the place per
protocol, the idea is to add a new socket family with a hook like
NF_SOCKET_INGRESS at sk_filter(), this new family encloses this new
specific socket semantics, that differs from the ip, ip6 and inet
family semantics.

> If the opinions on the previously raised concerns have changed, I'm
> happy to revisit.
> 
> > * We can quickly find a verdict on the packet using using any combination
> >   of selectors through concatenations and maps in nf_tables. In
> >   nf_tables we can express the policy with a non-linear ruleset.
> 
> That's another interesting detail that was discussed on NFWS, yes. We
> need a way to dispatch incoming packets without walking a linear
> dispatcher list. In the eBPF approach, that's very easy because the
> cgroup is directly associated with the receiving socket, so the lookup
> of the effective eBPF programs is really fast.
> 
> If we can achieve similar things with nf_tables and maps, then that
> should be applicable as well.

Yes, we can indeed.

> >   On top of this, by delaying the nf_reset() calls we can reach the
> >   conntrack information from sk_filter(). That would be useful to skip
> >   evaluating packets that belong to already established flows. Thus, we
> >   incur the performance penalty in classifying only for the first
> >   packet of the flow.
> 
> If that's possible, that's an interesting feature, but at least for
> accounting, we need to run the rules for all packets, always.

We can build flow tables that looks like:

        nft add rule x y flow table whatever-name { meta skuid "apache" counter }

Then, we can list its content using @whatever-name as handle. The
table is dynamically populated. This accounts for all incoming traffic
for apache. We can actually use any concatenation of packet selectors
there.

This flow table thing uses the generic set infrastructure, and more
specifically, the rhashtable implementation, so looking up for the
entry scales up.

> > * We can skip the socket egress hook (that you don't know where to place
> >   yet) since you can use the existing local output hook in netfilter that
> >   is available for IPv4 and IPv6.
> 
> If asymmetry is not a no-go anymore, that sounds fine to me.

Unless strictly necessary, I would not add a new hook if we can make
it with the ip/ip6 local out hook.

> > * This new hook would fit into the existing netfilter set of hooks,
> >   the sysadmin is already familiarized with the administrative
> >   infrastructure to define filtering policies in our stack, so adding this
> >   new hook to what we have looks natural to me.
> 
> At least for inspecting the rules, this is certainly a benefit. On the
> other hand, it's always been a pain to handle competing entities in the
> system that both alter netfilter configurations, as ownership of rules
> is suddenly not clear anymore.
> 
> Another concern I have with cgroup matching in netfilter (at least as
> enforced by cgroup v2) is that every such rule has to carry a
> char[PATH_MAX] struct member, and the matching is done via that path
> string. I guess we need to come up with some solution in that area
> that's less expensive here, but that could be solved separately.

Good.

> So - I don't know. The whole 'eBPF in cgroups' idea was born because
> through the discussions over the past months we had on all this, it
> became clear to me that netfilter is not the right place for filtering
> on local tasks. I agree the solution I am proposing in my patch set has
> its downsides, mostly when it comes to transparency to users, but I
> considered that acceptable. After all, we have eBPF users all over the
> place in the kernel already, and seccomp, for instance, isn't any better
> in that regard.

But seccomp, like socket filters, are requested by the process itself,
so we are not attaching a global policy, instead this a per-process
policy. Since the process has attached this filter itself via
setsockopt() he is aware of what has done. As I said, this is
different when applied globally.

> That said, if there is a better solution for the problem, I can as well
> ditch my patches. It's ultimately your call anyway I guess :) Do you
> have any plans on working on this new netfilter hook or do you want me
> to have look?

I would look into this, yes. Thanks.
