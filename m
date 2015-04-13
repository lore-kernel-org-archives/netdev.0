From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Mon, 13 Apr 2015 21:19:14 +0100
Message-ID: <20150413201913.GD20275@acer.localdomain>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
 <20150410200901.GB5968@salvia>
 <20150412.211421.1771298417488412635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39506 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932424AbbDMUTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 16:19:25 -0400
Content-Disposition: inline
In-Reply-To: <20150412.211421.1771298417488412635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.04, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Fri, 10 Apr 2015 22:09:01 +0200
> 
> >> > This patchset adds the Netfilter hook at the ingress path, in a per-device
> >> > fashion. This also comes with the new nf_tables 'netdev' family support to
> >> > provide access to users to the existing nf_tables features. This includes the
> >> > transactional netlink API and the enhanced set infrastructure.  Several patches
> >> > come in first place to prepare this support, including the refactoring of
> >> > __netif_receive_skb_core() to accomodate the new hook.
> 
> It's always been the case that if you want to do L2 or lower level
> stuff, you use the ingress classifier, packet actions, and qdiscs.
> 
> If you want to do higher level things, NF hooks provide that facility.
> 
> The only example I've seen is packet counting, and one could do that
> just as easily with the ingress qdisc.
> 
> So given what I've been shown so far I'm very far from convinced that
> this new hook in an already over polluted, most critical of all
> critical code paths, is justified at all.

I'm going to jump in here since I think a good case for this can be
made. It's going to be a bit longer, sorry. You can skip to the
examples after the first three paragraphs since it's just a lot of
TC bashing :)

First, lets start with the ingress qdisc hook, since it is somewhat
related. The ingress qdisc is basically a hack to get filters to run
at ingress. There is no queue, its a workaround for the fact that
we don't have any other way to filter at ingress, and in my opinion
not a nice one.

Its is today implemented as an enqueue call in netif_receive_skb(),
but it used to register with IPv4/IPv6 netfilter to receive packets.
If it is actually used, there is full serialization since a global
lock is used. If it is not used, the cost is pretty minimal except
for the quite large amount of code.

Now, if we had a netfilter hook at ingress *without* the okfn, the
cost when disabled would simply be a static key, when enabled a
hook invocation, pretty much comparable to ingress. Given that
ingress used to be implemented on top of netfilter, there's no
reason why we couldn't do that again. I'm pretty much convinced
that we could easily make the impact smaller than it is now.

Now, given the features. Ingress filtering is mainly used for
TC actions, which are in my opinion the most horible way imaginable
to so something like that. tc is a horrible mess and tc actions
are the worst part of it. The fact that people over time have still
added some TC actions is in my opinion telling that a better
way to do this stuff would be appreciated, its hard to imagine this
being the first choice of anyone.

Looking at the TC actions, some are directly related to using
netfilter (ipt, connmark). ipt is actually dangerous in that
it can easily crash your kernel, from a quick look connmark
looks equally unsafe in that it doesn't perform even basic
header validation that conntrack relies on. We can obviously
take care of the netfilter related actions easily. skbedit is
like a very primitive meta expression from nftables, stateless
NAT and pedit are something that can easily be supported using
nftables and we need that (generic) support anyways. The VLAN
action and policing is something I'm unsure about, but all
the remaining ones we don't already support basically come for
free since we need that functionality (packet editing) anyway.

Now the advantages of being able to use nft. First, the obvious
one is that we have a nice userspace tool, a well defined
grammar, and that people would be able to use the same tool for
very similar tasks. nftables in the kernel is almost completely
lockless, we support way more possibilites already and we won't
have to add new special case TC actions anymore. Look at the
connmark action for example. It can set a value. How long until
someone wants to use a bitmask? We support all operations
(assignment, bit operations) for all types, we have sets for fast
lookups, maps for associating values quickly, we have a nice and
readable syntax and full translation back to the readable
representation and much more.

Now you asked for some examples :)

As I mentioned, we can set meta data in various ways, we will
be able to do stateless NAT and pedit, of course very flexible
classification etc etc, but some of the cool stuff which would
be useful especially in ingress:

Are you wondering why CPUs are used unbalanced and want to
see what kind of traffic is causing it? With the dynamic
expression instantiation queued in nf-next, you could do:

nft add ingress filter \
	flow table debug cpu . ether saddr counter

To dynamically create a table of counters called "debug" for
all CPU + MAC source combinations. Listing it will show you

	0 . 20:1a:06:e5:cb:be ... bytes ... packets
	0 . 9c:d2:1e:74:eb:75 ... bytes ... packets
	1 . 52:54:00:79:83:a2 ... bytes ... packets
	...

I'm currently working on various ways to sort it in every
dimension so you can easily find the information you're looking
for.

If it doesn't seem to be unevenly distributed based on MACs,
you could try IP source and IP destination address instead:

nft add ingress filter \
	flow table debug cpu . ip saddr . ip daddr counter

Which will give you a table of counters for every CPU + saddr + daddr
combination. You can combine any kind of key we support, which
are a lot. This could be a nice help for debugging performance
problems.

So, in short, I think this makes a lot of sense to have, but
in order to avoid performance impact, ingress should be moved
back to netfilter (since its the more generic approach) and
the async resumption (okfn) should be avoided completely.
