From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 11:37:22 -0400 (EDT)
Message-ID: <20170413.113722.2174945057832588335.davem@davemloft.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <20170413042036.GA46229@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdDMPh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:37:26 -0400
In-Reply-To: <20170413042036.GA46229@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 12 Apr 2017 21:20:38 -0700

> On Wed, Apr 12, 2017 at 02:54:15PM -0400, David Miller wrote:
>> One thing I have not tried to address here is the issue of
>> XDP_PACKET_HEADROOM, thanks to Daniel for spotting that.  It seems
>> incredibly expensive to do a skb_cow(skb, XDP_PACKET_HEADROOM) or
>> whatever even if the XDP program doesn't try to push headers at all.
>> I think we really need the verifier to somehow propagate whether
>> certain XDP helpers are used or not.
> 
> Looks like we need to relax the headroom requirement.
> I really wanted to simplify the life of program writers,
> but intel drivers insist on 192 headroom already, then for skb
> every driver does 64 and netronome doesn't have the room by default at all
> even for XDP and relies on expensive copy when xdp_adjust_head is used
> so that dream isn't going to come true.
> I guess for now every driver should _try_ to give XDP_PACKET_HEADROOM
> bytes, but the driver can omit it completely if xdp_adjust_head()
> is not used for performance reasons.

If the capability is variable, it must be communicated to the user
somehow at program load time.

We are consistently finding that there is this real need to
communicate XDP capabilities, or somehow verify that the needs
of an XDP program can be satisfied by a given implementation.

Maximum headroom is just one.

Simply having bpf_xdp_adjust_head() fail and therefore drop packets
isn't good behavior at all.  But that is the situation we have
right now.

>> +	if (skb_linearize(skb))
>> +		goto do_drop;
> 
> when we discussed supporting jumbo frames in XDP, the idea
> was that the program would need to look at first 3+k bytes only
> and the rest of the packet will be in non-contiguous pages.
> If we do that, it means that XDP program would have to assume
> that the packet is more than [data, data_end] and this range
> only covers linear part.
> If that's the future, we don't need to linearize the skb here
> and can let the program access headlen only.
> It means that we'd need to add 'len' field to 'struct xdp_md' uapi.
> For our existing programs (ddos and l4lb) it's not a problem,
> since for MTU < 3.xK and physical XDP the driver guarantees that
> data_end - data == len, so nothing will break.
> So I'm proposing to do two things:
> - drop skb_linearize here
> - introduce 'len' to 'struct xdp_md' and update it here and
> in the existing drivers that support xdp.

I don't think this is reasonable.  The amount of inconsistency will be
quite huge.

First of all, every driver pulls a different amount of bytes into the
linear area when building frag based SKBs on receive.  There are
drivers that only put the MAC header in the linear area, and depend
upon the logic in the stack which does pskb_may_pull() before touching
deeper headers.

Of course, such drivers should be using eth_get_headlen().  But they
don't, and what they are doing is not a bug.

And eth_get_headlen() only pulls protocol headers, which precludes XDP
inspecting anything below TCP/UDP/etc.  This is also not reasonable.

Right now, as it stands, we have to assume the program can potentially
be interested in the entire packet.

We can only optimize this and elide things when we have a facility in
the future for the program to express it's needs precisely.  I think
we will have to add some control structure to XDP programs that can
be filled in for this purpose.

Right now the two things we know would need to be expressed are 1)
maximum headroom needed and 2) parsing depth.  I'm not %100 clear on
how #2 should be specified, but in it's simplest sense it could take
on two values, either "what eth_get_headlen() returns" or "entire
packet" to start with.

> 
>> +				if (act == XDP_TX)
>> +					dev_queue_xmit(skb);
> 
> this will go through qdisc which is not a problem per-se,
> but may mislead poor users that XDP_TX goes through qdisc
> even for in-driver XDP which is not the case.
> So I think we need to bypass qdisc somehow. Like
> txq = netdev_pick_tx(skb,..
> HARD_TX_LOCK(dev, txq..
> if (!netif_xmit_stopped(txq)) {
>   dev_hard_start_xmit(skb, dev, txq,
> } else {
>   kfree_skb(skb);
>   txq->xdp_tx_full++;
> }
> HARD_TX_UNLOCK(dev, txq);
> 
> this way it will be similar to in-driver XDP which
> also has xdp_tx_full counter when HW TX queue is full.

Ok, this makes sense.  I'll work on that.

> Re: csum and skb->encapsulate issues that were raised in the previous thread
> 
> Today all cls_bpf csum helpers are currently disabled for XDP
> and if the program mangles the packet and then does XDP_PASS,
> the packet will be dropped by the stack due to incorrect csum.
> So we're no better here and need a solution for both in-driver XDP and generic XDP.

I'm not so sure how I feel about checksums, I've been busy following
the thread started by Tom.  I want to strive for something simple.

> I think the green light to apply this patch will be when
> samples/bpf/xdp1, xdp2 and xdp_tx_iptunnel
> work just like they do in in-driver XDP and I think we're pretty close.
> 
> If desired I can start hacking on this patch and testing mid next week.

I'll try to accomplish what I can today...
