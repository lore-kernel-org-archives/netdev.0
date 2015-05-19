From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Tue, 19 May 2015 14:34:15 +0200
Message-ID: <20150519123415.GC5063@breakpoint.cc>
References: <20150518204049.GC20709@breakpoint.cc>
 <20150518.165550.359134808190719687.davem@davemloft.net>
 <20150518213329.GA2335@breakpoint.cc>
 <20150518.195105.2072041210798369557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56461 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755743AbbESMeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 08:34:18 -0400
Content-Disposition: inline
In-Reply-To: <20150518.195105.2072041210798369557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 18 May 2015 23:33:29 +0200
> 
> > Thanks for spending time on this.
> 
> Ok, I've heard what you have to say.
> 
> Of the fixes you've proposed already, I prefer the device MTU one
> because it doesn't penalize the ip_fragment.c optimizations just
> because a netfilter module is loaded.

True, OTOH it only allows removing the br_nf hacks, it doesn't fix
a few corner cases (see below).

> Which of your already proposed patches do you prefer, and why?

The IPCB one, main change from that set:
http://patchwork.ozlabs.org/patch/460252/

> I'm happy to apply one or the other as an interim step to make
> forward progress.  However, I really want to seriously consider
> our long term handling of fragments in netfilter meanwhile.

Here is a summary of the two.

Both allow removal of bridge netfilter mtu kludge that we have in
ip_fragment, but they have different pros and cons.

A. Add mtu argument to ip_fragment.
 pro: actual change is small (most is refactoring)
 pro: obvious code flow for bridge netfilter, we can
  pass device_mtu - reserved_mtu (encap overhead for ppp, vlan, etc)
  as 'new' device mtu, effectively moving this hack from ip_fragment to
  br_netfilter.

 cons: doesn't resolve hypothetical(?) router edge cases:
   #1. if we'd receive e.g. fragment size 1000 and fragment size
   200, where both fragments have DF bit set, we will currently
   send a single 1200 byte DF packet, if outdevice has mtu >= 1200.

   This is because ip_finish_output() only fragments if skb->len > mtu.

   #2 iff we do refragment (e.g. out mtu is 1000), we re-create fragments
   of size 1000 and 200, but DF bit gets lost in the process.

Neither seems to be a big problem, #2 doesn't break end-to-end connectivity,
and #1 doesn't seem to happen in practice; else we should have seen
bug reports by now.  However, I do feel uneasy about it and think we should
fix it.

last A series diffstat:
 include/linux/netfilter_bridge.h |    7 -------
 include/net/ip.h                 |    2 +-
 net/bridge/br_netfilter.c        |   34 +++++++++++++++++++++++++++++++---
 net/ipv4/ip_output.c             |   29 ++++++++++++++++++-----------
 4 files changed, 50 insertions(+), 22 deletions(-)

B. store largest fragment size in IPCB and use that.
  pro: we already do this to reject refragmented skbs that had DF set if
  the largest original fragment is larger than the outdevice mtu, so this
  change is not as big as one might think.

  The main aspects of this change is that ip_fragment will do

  mtu = IPCB(skb)->largest_frag_size;
  if (!mtu)
	mtu = ip_skb_dst_mtu(skb);

  instead of just calling ip_skb_dst_mtu(), and that we will call
  ip_fragment on all skbs that have new IPSKB_FRAG_PMTU flag set, i.e.

  if ((IPCB(skb)->flags & IPSKB_FRAG_PMTU) || skb->len > mtu)
	ip_fragment()

  This will prevent us from sending packets that are larger than
  the biggest original fragment we originally got.

  bridge netfilter can make use of this; since we store largest
  size seen we can just remove the mtu encap overhead calculations.

  For ipv6, bridge netfilter will have to be fixed
  to preserve IP6CB largest size, just like we do for IPCB.
  This will be a bridge netfilter specific change only.

last B series had this diffstat:
 include/net/inet_frag.h |    2 +-
 include/net/ip.h        |    1 +
 net/ipv4/ip_forward.c   |   18 +++++++++++-------
 net/ipv4/ip_fragment.c  |   31 ++++++++++++++++++++++++++-----
 net/ipv4/ip_output.c    |   37 ++++++++++++++++++++++++++++---------
 net/ipv6/ip6_output.c   |   29 ++++++++++++++++++-----------
 6 files changed, 85 insertions(+), 33 deletions(-)

My suggestion would be to go with #B.  Its a more intrusive change compared to A,
but it allows to get rid of br netfilter hack while also resolving silly and/or
rare corner cases, such as e.g. reassembling two ipv6 fragments and then failing
to undo it on forward.

Neither approach prevents us from making skb_has_frag_list() fast-path
in ip_fragment work again at a later point.

I can rebase and resubmit both proposals if you prefer so you can review
them in more detail.

Thanks.
