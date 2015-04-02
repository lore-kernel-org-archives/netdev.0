From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 02/14] net: untangle ip_fragment and bridge
 netfilter
Date: Thu, 2 Apr 2015 14:16:09 +0200
Message-ID: <20150402121609.GC21789@breakpoint.cc>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
 <1427920600-20366-3-git-send-email-fw@strlen.de>
 <20150401.230921.232085782289557923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150401.230921.232085782289557923.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Wed,  1 Apr 2015 22:36:28 +0200
> 
> > Add mtu arguments to ip_fragment and remove the bridge netfilter mtu
> > helper.
> 
> I told you I disagree with this approach.  Anything that adds
> an 'mtu' argument to ip_fragment() I am not even going to look
> at seriously, there must be device context when you call that
> function.

Not sure.  There is one case where we must not use device mtu:
if DF was set on one of the fragments, we must not increase fragment
size, thats why I added the MTU argument to make sure that largest
fragment size will be the upper boundary.

I don't see where we break PMTUD or induce any other kind of
breakage after this change.

For the non-df case the original sizes of the fragments
don't matter since any device in the path will (re)fragment.

> Furthermore, and even more importantly, right now what bridge
> netfilter does with fragmentation is _terminally_ broken.

I didn't claim it wasn't :-]

> This is why you must use something like GRO/GSO, which is built
> to positively and provably preserve the geometry of SKBs as they
> are packed and unpacked.

Thats not as trivial as it sounds.
GRO only aggregates same-size packets.

All the fragments might have different sizes.

Futhermore we need to handle overlapping fragments, duplicates and
arrival of fragments in any order.

Preserving the original skbs and sending those instead of
refragmentation doesn't work either since the reassembled skb might have
been subject to NAT.

So the only possible compromise I see is to record/store all fragment sizes
in the correct logical order (according to offset) and use that as
'replay split points', i.e. we'd still end up not using the device mtu
when undoing the defrag operation.

We'd also not have full transparency unless we would also re-create
the overlapping and duplicate packets that we might have seen, and
send the refragmented skbs in the same order as we received them.

I don't think thats something we want in ip stack, so we'd have
to (re)implement ip (de|re)-fragmentation for the bridge in bridge
netfilter.

Is that what you had in mind?

Or do you see some way to re-use existing implementation without
fuglifying normal defrag operations?

Thanks.
