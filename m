From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 0/3] Allow postponed netfilter handling for socket
 matches
Date: Thu, 17 Sep 2015 18:00:08 +0200
Message-ID: <20150917160008.GA32700@breakpoint.cc>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
 <20150916212100.GT24810@breakpoint.cc>
 <55FA902F.50006@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55FA902F.50006@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Mack <daniel@zonque.org> wrote:
> Hi Florian,
> 
> On 09/16/2015 11:21 PM, Florian Westphal wrote:
> > Daniel Mack <daniel@zonque.org> wrote:
> >> I'm re-addressing the issue of matching socket meta information for
> >> non-established sockets that has been discussed a while ago:
> >>
> >>   http://article.gmane.org/gmane.comp.security.firewalls.netfilter.devel/56877
> >>
> >> Being able to reliably match on net_cls cgroup ids is crucial in
> >> order to build a per-application or per-container firewall rules
> >> which don't leak ingress packets. Such a feature would be very
> >> useful to have.
> > 
> > Could you clarify what 'which don't leak ingress packets' means?
> 
> Well, currently, the existing cgroups matches only filter packets that
> are sent to an established socket. All other packets are ignored. So
> when users install such matches as advertised by the documented
> examples, and the chain policy is permissive, the firewall 'leaks'
> packets, which is unexpected.

Then 'the documentation' needs fixing.
cgroup (and anything related to sk data, including uid, etc.) is
not guaranteed to work.

We can only match what is available in the packet payload, and
some extra info that the stack can make available to us (e.g.
VLAN id, or skb->sk in some cases on output) and conntrack state plus
whatever extra data conntrack allows to attach.

> >> The patch set is obviously not yet finished, because a lot more
> >> protocol handlers need to be patched. Right now, I only addressed
> >> tcp_ipv4. Before I do that, I want to get some feedback on the
> >> approach, so please let me know what you think.
> > 
> > I think there are several issues.
> > 
> > implementation problems:
> > - i'm not sure its legal to call the hook input with skb->sk locked,
> >   some matches might want to aquire it.
> 
> In the code as it stands after my patch set, I don't see where skb->sk
> is locked?

True.

[..]

> > design issues:
> > The assumption seems to be that a given skb can always be mapped to a
> > particular socket, and hence a cgroup.
> >
> > Thats not necessarily the case, e.g. with broad-/multicasting or when
> > the socket is e.g. in timewait state.
> 
> Yes, that's true. The idea for multicast would be to just drop the
> cloned skb instead of delivering it to the final socket.

-v please.

> > I would much rather see nft_demux_{udp,tcp,sctp,dccp,...}.c which moves
> > early-demux-esque code into the nft ruleset.
> > 
> > Then you could do something like
> > 
> > nft add rule ip filter input meta l4proto tcp demux meta cgroup 42
> 
> Ok, but how would that be different from the unconditional demuxing
> patches we've kicked around earlier, especially when it comes to
> multicast sockets? Could you explain what you have in mind here?

Two things:
- keep it out of core network stack
- make it explicit so we can document that 'demux' keyword is fishy and
will not work reliably.

F.e. I don't see how mcast could ever be made to work except by adding
an entirely new filtering mechanism/new hooks in core stack.

> > The caveat being that even in this case we cannot guarantee
> > that skb->sk is set afterwards, or that a cgroup can be derived from it.
> > 
> > Iff you absolutely need this, I'd seriously entertain the idea of adding
> > NFPROTO_L4_TCP, etc, ... or, maybe better, allow to attach nft ruleset
> > as a socket filter.
> 
> That would be a new netfilter hook then, something that is called after
> LOCAL_IN, for ingress only? In a sense, it would be called from the
> protocol handlers, just as my patches do right now, but instead of
> conditionally re-iterating the same rules again, we would walk a
> different chain?

Yes, something like that.  Obviously, you'll need to dru^W brib^W
convince a LOT of people before that could ever fly.

I think we should not do this and that this 'match on ingress sk
properties' is just bad[tm].

f.e. you'd also have to move all of the stuff you want into
sock_common ... 8-(

> > But really, at that point, a much better question would be wheter net
> > cgroups are the answer to whatever the question was, or what problem we
> > are attempting to address here...
> 
> The idea is simply to have a packet filter which is based on information
> derived from the task that sends or will eventually handle the packet.

Starts to smell like snet (https://lwn.net/Articles/441587/)

> IOW: We want to be able to install netfilter rules that apply to all
> packets received or sent by tasks that match a certain criteria, without
> modifying the sources of those tasks.

Sorry, I think netfilter is wrong tool for this, at least for ingress.
You could use conntrack to stash net_cls id in the connmark, though (for
inbound reply packets).
