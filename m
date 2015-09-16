From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 0/3] Allow postponed netfilter handling for socket
 matches
Date: Wed, 16 Sep 2015 23:21:00 +0200
Message-ID: <20150916212100.GT24810@breakpoint.cc>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Mack <daniel@zonque.org> wrote:
> I'm re-addressing the issue of matching socket meta information for
> non-established sockets that has been discussed a while ago:
> 
>   http://article.gmane.org/gmane.comp.security.firewalls.netfilter.devel/56877
> 
> Being able to reliably match on net_cls cgroup ids is crucial in
> order to build a per-application or per-container firewall rules
> which don't leak ingress packets. Such a feature would be very
> useful to have.

Could you clarify what 'which don't leak ingress packets' means?

> A previous attempt to fix the currently existing issues was to call
> out to the early demuxing helper functions from the meta matching
> callbacks, but that doesn't suffice because it doesn't address the
> case of multicast UDP and other, more complex lookup methods
> implemented in various protocol handlers.

Yes, but see below.

> This patch set outlines a different approach by adding a flag to
> 'struct sk_buff' called 'nf_postponed'. This flag is set by
> nft_meta_get_eval() in case a decision cannot be made due to a missing
> skb->sk. skbs flagged that way will then be ran through the netfilter
> chain processor again after the protocol handlers did the real socket
> lookup. A small addition to 'struct nft_pktinfo' is needed so that the
> matching callbacks can access the socket that was passed into
> nf_hook().
> 
> Note that the new flag does not actually bloat 'struct skb_buff',
> because it still fits into the 'flags1' bitfield. Also, the extra
> netfilter chain iteration will not be done by any subsequent packet in
> the same stream, as for those, the early demux code will set skb->sk.
> 
> The patch set is obviously not yet finished, because a lot more
> protocol handlers need to be patched. Right now, I only addressed
> tcp_ipv4. Before I do that, I want to get some feedback on the
> approach, so please let me know what you think.

I think there are several issues.

implementation problems:
- i'm not sure its legal to call the hook input with skb->sk locked,
  some matches might want to aquire it.
- what makes NFT_META_CGROUP special? (or was that just an example?)

design issues:
The assumption seems to be that a given skb can always be mapped to a
particular socket, and hence a cgroup.

Thats not necessarily the case, e.g. with broad-/multicasting or when
the socket is e.g. in timewait state.

Some skbs will now travel INPUT hooks twice.

And once you'd extend this so that we re-invoke nf hooks for mcast
packets, for each socket they've been received on, you change netfilter
behaviour again (one skb, one traversal -> n traversals of ruleset, one
for each sk).

I think that this makes it a non-starter, sorry.

I would much rather see nft_demux_{udp,tcp,sctp,dccp,...}.c which moves
early-demux-esque code into the nft ruleset.

Then you could do something like

nft add rule ip filter input meta l4proto tcp demux meta cgroup 42

The caveat being that even in this case we cannot guarantee
that skb->sk is set afterwards, or that a cgroup can be derived from it.

Iff you absolutely need this, I'd seriously entertain the idea of adding
NFPROTO_L4_TCP, etc, ... or, maybe better, allow to attach nft ruleset
as a socket filter.

But really, at that point, a much better question would be wheter net
cgroups are the answer to whatever the question was, or what problem we
are attempting to address here...
