From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [RFC] back on nf_tables (plus compatibility layer)
Date: Thu, 25 Oct 2012 19:06:32 +0200
Message-ID: <20121025170632.GA4890@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've been working for a while to recover nf_tables kernel patches and
to implement a compatibility layer so it can be used with existing
x_tables target/match extensions. These are the main reasons that
motivated me to follow this approach:

1) nf_tables already provides a netlink interface, which has been a
   longstanding demand from users.

2) Provide a fast path to merge this into mainstream. We'll have both
   iptables and nftables interfaces during some time in the Linux kernel,
   then remove iptables infrastructure at some point. iptables scripts
   would not break as we'll have the iptables emulation over nftables.

3) Regarding the compatibility layer: To provide a working command
   line utility with the same syntax of iptables. The idea is that users
   don't notice that they are working with the nf_tables kernel
   infrastructure. We did that during the transition from ipchains to
   iptables.

4) Several extensions for x_tables still need to be ported to
   nf_tables. With the compatibility layer, we can use non-native
   x_tables extensions with nf_tables until it fully provides a
   replacement for all existing features.

5) The compatibility layer provides a way to hook existing x_tables
   matches/targets with nftables. So we can use all existing features
   from nftables until we provide native nftables expressions /
   user-space code that replace them.

The compatibility layer has limitations to emulate struct ipt_entry,
hookmask, protocol and inversion passed to xt->checkentry(). But this
can be mostly workaround by relaxing some of the checking in
kernel-space that prevent users from doing stupid things (like trying
to use the TCPMSS target for non-TCP traffic / non-syn packets). In my
list, the affected targets are ECN, CLUSTERIP, TCPMSS, REJECT and CT.
I have some proposals on how to workaround those.

You can access the preliminary iptables over nftables code from:

http://1984.lsi.us.es/git/iptables-nftables/

The name of the utilities are xtables, xtables-save and
xtables-restore.

There are several missing features in that iptables over nftables
code: -Z, -R, -E, rule insertion at position and -f are not yet
working. IPv6 support is also still missing.

It requires this user-space library:

http://1984.lsi.us.es/git/libnftables/

And the following Linux kernel code with several experimental patches
of mine:

http://1984.lsi.us.es/git/nf-next/log/?h=nf_tables-experiments

I see several things that need to be improved in the nftables kernel
side:

1) Improve rule addition and deletion timing, currently it is not
very good compared to iptables. To improve deletions I think we
have to modify the current locking approach based on RCU. To improve
additions, we have to improve the unique handle allocation (probably
using a 64-bits handle number so we forget about wrap-arounds and we
just incrementally assign new handles).

2) No built-in nat and route tables. Better allow from user-space
configure one table with the nat / route property. If we provide
documentation on how to use them appropriately, I would not worry too
much if the user uses wrongly.

3) Add operation to obtain chain counters, following the same approach
of iptables (iterate over the entire rule-set and accumulate packets
and bytes, like in get_counters()).

4) Add native support for TRACE, it seems to be missing in nf_tables.

5) Changes to allow to add rules at positions and replace them, since
iptables allows this.

6) To speed up packet matching, we can compile nftables expressions to
some internal bytecode (that could be even compiled to native assembly
instructions like Eric Dumazet did for BPF).

Several of these things can be improved while we already have this in
mainline.

One final thing: nftables does not support atomic table commit. The
point here is if we really need this for the emulation utility or we
can live without that. Implementing atomic table replacement in
nftables is not trivial. I have hard time to find this commit table
feature useful.

That's all by now. By resolving most of these things and having the
compatibility layer ready, we should get nftables into mainstream
anytime soon IMO.

Comments welcome.

Regards.
