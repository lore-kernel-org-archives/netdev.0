From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Wed, 12 Apr 2017 21:20:38 -0700
Message-ID: <20170413042036.GA46229@ast-mbp.thefacebook.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36198 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdDMEUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 00:20:43 -0400
Content-Disposition: inline
In-Reply-To: <20170412.145415.1441440342830198148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 02:54:15PM -0400, David Miller wrote:
> 
> This provides a generic SKB based non-optimized XDP path which is used
> if either the driver lacks a specific XDP implementation, or the user
> requests it via a new IFLA_XDP_FLAGS value named XDP_FLAGS_SKB_MODE.
> 
> It is arguable that perhaps I should have required something like
> this as part of the initial XDP feature merge.
> 
> I believe this is critical for two reasons:
> 
> 1) Accessibility.  More people can play with XDP with less
>    dependencies.  Yes I know we have XDP support in virtio_net, but
>    that just creates another depedency for learning how to use this
>    facility.
> 
>    I wrote this to make life easier for the XDP newbies.
> 
> 2) As a model for what the expected semantics are.  If there is a pure
>    generic core implementation, it serves as a semantic example for
>    driver folks adding XDP support.
> 
> This is just a rough draft and is untested.
> 
> One thing I have not tried to address here is the issue of
> XDP_PACKET_HEADROOM, thanks to Daniel for spotting that.  It seems
> incredibly expensive to do a skb_cow(skb, XDP_PACKET_HEADROOM) or
> whatever even if the XDP program doesn't try to push headers at all.
> I think we really need the verifier to somehow propagate whether
> certain XDP helpers are used or not.

Looks like we need to relax the headroom requirement.
I really wanted to simplify the life of program writers,
but intel drivers insist on 192 headroom already, then for skb
every driver does 64 and netronome doesn't have the room by default at all
even for XDP and relies on expensive copy when xdp_adjust_head is used
so that dream isn't going to come true.
I guess for now every driver should _try_ to give XDP_PACKET_HEADROOM
bytes, but the driver can omit it completely if xdp_adjust_head()
is not used for performance reasons.

> +static inline bool netif_elide_gro(const struct net_device *dev)
> +{
> +	if (!(dev->features & NETIF_F_GRO) || dev->xdp_prog)
> +		return true;
> +	return false;
> +}

I think that's the rigth call.
I've been thinking back and forth about it.
On one side it's not cool to disable it and not inform user
about it in ethtool, so it might feel that doing
ethtool_set_one_feature(~GRO) may be cleaner, but then
we'd need to remember the current gro on/off status and
restore that after prog is detached.
And while the prog is attached the user shouldn't be able
to change gro via ethtool -K, so we'd need extra boolean
flag anyway. If we go with this netif_elide_gro() approach,
we don't need to mess with ndo_fix_features() and only
need to hack ethtool_get_features() to report GRO disabled
if (dev->xdp_prog) and mark it as [fixed].
So overall imo it's cleaner than messing with dev->features
directly while attaching/detaching the prog.

> +	if (skb_linearize(skb))
> +		goto do_drop;

when we discussed supporting jumbo frames in XDP, the idea
was that the program would need to look at first 3+k bytes only
and the rest of the packet will be in non-contiguous pages.
If we do that, it means that XDP program would have to assume
that the packet is more than [data, data_end] and this range
only covers linear part.
If that's the future, we don't need to linearize the skb here
and can let the program access headlen only.
It means that we'd need to add 'len' field to 'struct xdp_md' uapi.
For our existing programs (ddos and l4lb) it's not a problem,
since for MTU < 3.xK and physical XDP the driver guarantees that
data_end - data == len, so nothing will break.
So I'm proposing to do two things:
- drop skb_linearize here
- introduce 'len' to 'struct xdp_md' and update it here and
in the existing drivers that support xdp.

> +				if (act == XDP_TX)
> +					dev_queue_xmit(skb);

this will go through qdisc which is not a problem per-se,
but may mislead poor users that XDP_TX goes through qdisc
even for in-driver XDP which is not the case.
So I think we need to bypass qdisc somehow. Like
txq = netdev_pick_tx(skb,..
HARD_TX_LOCK(dev, txq..
if (!netif_xmit_stopped(txq)) {
  dev_hard_start_xmit(skb, dev, txq,
} else {
  kfree_skb(skb);
  txq->xdp_tx_full++;
}
HARD_TX_UNLOCK(dev, txq);

this way it will be similar to in-driver XDP which
also has xdp_tx_full counter when HW TX queue is full.

Re: csum and skb->encapsulate issues that were raised in the previous thread

Today all cls_bpf csum helpers are currently disabled for XDP
and if the program mangles the packet and then does XDP_PASS,
the packet will be dropped by the stack due to incorrect csum.
So we're no better here and need a solution for both in-driver XDP and generic XDP.

I think the green light to apply this patch will be when
samples/bpf/xdp1, xdp2 and xdp_tx_iptunnel
work just like they do in in-driver XDP and I think we're pretty close.

If desired I can start hacking on this patch and testing mid next week.
