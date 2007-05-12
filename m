From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] tbf scheduler: TSO support
Date: Sat, 12 May 2007 18:09:41 +0900 (JST)
Message-ID: <20070512.180941.01974230.taka@valinux.co.jp>
References: <20070511.130142.16832866.taka@valinux.co.jp>
	<4644B259.5060400@trash.net>
	<20070512.174930.80276554.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:42139 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753720AbXELJJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 05:09:42 -0400
In-Reply-To: <20070512.174930.80276554.taka@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > I think the concept of TBF is quit good but the userspace tools have
> > > become old that it doesn't fit to Gb ethernet environment.
> > > The tools should be updated to care about much faster network and
> > > GbE jumbo frames. I agree with you at this point.
> > > 
> > > On the other hand, handling TSO packet should be a kernel issue.
> > > A TSO packet is logically just a multiple segmented packet
> > > including several ordinary packets. This feature should be kept
> > > invisible from userspace.
> > 
> > 
> > Putting aside this question, this cannot work properly without userspace
> > since the rate table is only built for the given MTU. Your patch tries
> > to work around that by summing up the result of L2T in q->max_size
> > steps, which gives incorrect results with MPU or overhead settings.
> 
> You have a point. sch->dev->mtu should be used instead of q->max_size,
> which gives precisely correct results.

Oops, this isn't really true because TSO supporting controllers will
probably add some headers to the split packets.
So I'd say "it will give almost correct results".

> Every TSO packet will be split
> into several packets with sch->dev->mtu length, which administrators
> specify. The splitting is automatically done by TSO supporting controllers.
> 
> To minimize the overhead of the calculation I'd re-implement it like:
> 
>    segs = skb->len/sch->dev->mtu;
>    rest = skb->len - sch->dev->mtu*segs;
>    toks -= L2T(q, sch->dev->mtu) * segs;
>    if (rest)
>         toks -= L2T(q, rest);
> 
> I think the problem is that sch->dev->mtu might not be set correctly,
> so some error checking is needed.
> 
> > I think we can only do two things without userspace support:
> > 
> > - disable TSO (not a good idea)
> 
> This is just what I'm doing now as a workaround.
> 
> > - split the skb into q->max_size chunks on dequeue
> 
> It sure is difficult because the splitting deeply depends on the
> protocol stack which made the skb and it will make some overhead,
> which is why TSO and other offloading features are introduced.
> 
> I'm now thinking I can make it just hold a TSO packet until p->tokens
> reaches the size of the packet. I think it is straightforward
> implementation. I'll try this.
> 
> > The later would allow people to take full advantage of TSO with properly
> > configured TBF, but it would still at least work with a too small mtu
> > value.
> 
> Thanks,
> Hirokazu Takahashi.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
