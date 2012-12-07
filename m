From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] netfilter: add xt_bpf xtables match
Date: Fri, 7 Dec 2012 14:16:38 +0100
Message-ID: <20121207131638.GA3019@1984>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
 <1354735339-13402-3-git-send-email-willemb@google.com>
 <20121205194854.GB28730@1984>
 <CA+FuTSfoYmTNyJnUW4shzb7V1TXpSunbOOORdViXw4DoZ4aibA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, kaber <kaber@trash.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50957 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030204Ab2LGNQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 08:16:47 -0500
Content-Disposition: inline
In-Reply-To: <CA+FuTSfoYmTNyJnUW4shzb7V1TXpSunbOOORdViXw4DoZ4aibA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2012 at 03:10:13PM -0500, Willem de Bruijn wrote:
> On Wed, Dec 5, 2012 at 2:48 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > Hi Willem,
> >
> > On Wed, Dec 05, 2012 at 02:22:19PM -0500, Willem de Bruijn wrote:
> >> A new match that executes sk_run_filter on every packet. BPF filters
> >> can access skbuff fields that are out of scope for existing iptables
> >> rules, allow more expressive logic, and on platforms with JIT support
> >> can even be faster.
> >>
> >> I have a corresponding iptables patch that takes `tcpdump -ddd`
> >> output, as used in the examples below. The two parts communicate
> >> using a variable length structure. This is similar to ebt_among,
> >> but new for iptables.
> >>
> >> Verified functionality by inserting an ip source filter on chain
> >> INPUT and an ip dest filter on chain OUTPUT and noting that ping
> >> failed while a rule was active:
> >>
> >> iptables -v -A INPUT -m bpf --bytecode '4,32 0 0 12,21 0 1 $SADDR,6 0 0 96,6 0 0 0,' -j DROP
> >> iptables -v -A OUTPUT -m bpf --bytecode '4,32 0 0 16,21 0 1 $DADDR,6 0 0 96,6 0 0 0,' -j DROP
> >
> > I like this BPF idea for iptables.
> >
> > I made a similar extension time ago, but it was taking a file as
> > parameter. That file contained in BPF code. I made a simple bison
> > parser that takes BPF code and put it into the bpf array of
> > instructions. It would be a bit more intuitive to define a filter and
> > we can distribute it with iptables.
> 
> That's cleaner, indeed. I actually like how tcpdump operates as a
> code generator if you pass -ddd. Unfortunately, it generates code only
> for link layer types of its supported devices, such as DLT_EN10MB and
> DLT_LINUX_SLL. The network layer interface of basic iptables
> (forgetting device dependent mechanisms as used in xt_mac) is DLT_RAW,
> but that is rarely supported.

Indeed, you'll have to hack on tcpdump to select the offset. In
iptables the base is the layer 3 header. With that change you could
use tcpdump for generate code automagically from their syntax.

> > Let me check on my internal trees, I can put that user-space code
> > somewhere in case you're interested.
> 
> Absolutely. I'll be happy to revise to get it in. I'm also considering
> sending a patch to tcpdump to make it generate code independent of the
> installed hardware when specifying -y.

I found a version of the old parser code I made:

http://1984.lsi.us.es/git/nfbpf/

It interprets a filter expressed in a similar way to tcpdump -dd but
it's using the BPF constants. It's quite preliminary and simple if you
look at the code.

Extending it to interpret some syntax similar to tcpdump -d would even
make more readable the BPF filter.

Time ago I also thought about taking the kernel code that checks that
the filter is correct. Currently you get -EINVAL if you pass a
handcrafted filter which is incorrect, so it's hard task to debug what
you made wrong.

It could be added to the iptables tree. Or if generic enough for BPF
and the effort is worth, just provide some small library that iptables
can link with and a small compiler/checker to help people develop BPF
filters.

Back to your xt_bpf thing, we can use the file containing the code
instead:

iptables -v -A INPUT -m bpf --bytecode-file filter1.bpf -j DROP
iptables -v -A OUTPUT -m bpf --bytecode-file filter2.bpf -j DROP

We can still allow the inlined filter via --bytecode if you want.
