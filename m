From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Fri, 16 May 2014 10:05:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17247362@AcuExch.aculab.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com>
 <1400143605.1006.1.camel@kazak.uk.xensource.com>
 <20140515110410.GD1117@zion.uk.xensource.com>
 <5374AF88.2070608@canonical.com>
 <20140516094842.GA18551@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	netdev <netdev@vger.kernel.org>
To: 'Wei Liu' <wei.liu2@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50277 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756596AbaEPKGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 06:06:03 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22623-06 for <netdev@vger.kernel.org>;
 Fri, 16 May 2014 11:05:54 +0100 (BST)
In-Reply-To: <20140516094842.GA18551@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu
> On Thu, May 15, 2014 at 02:14:00PM +0200, Stefan Bader wrote:
> [...]
> > > Wei.
> > >
> > Reading more of the code I would agree. The definition of MAX_SKB_FRAGS (at
> > least now with compound pages) cannot be used in any way to derive the number of
> > 4k slots a transfer will require.
> >
> > Zoltan already commented on worst cases. Not sure it would get as bad as that or
> > "just" 16*4k frags all in the middle of compound pages. That would then end in
> > around 33 or 34 slots, depending on the header.
> >
> > Zoltan wrote:
> > > I think the worst case scenario is when every frag and the linear buffer contains 2 bytes,
> > > which are overlapping a page boundary (that's (17+1)*2=36 so far), plus 15 of
> > them have a 4k
> > > page in the middle of them, so, a 1+4096+1 byte buffer can span over 3 page.
> > > That's 51 individual pages.
> >
> > I cannot claim to really know what to expect worst case. Somewhat I was thinking
> > of a worst case of (16+1)*2, which would be inconvenient enough.
> >
> > So without knowing exactly how to do it, but as Ian said it sounds best to come
> > up with some sort of exception coalescing in cases the slot count goes over 18
> > and we know the data size is below 64K.
> >
> 
> I took a stab at it this morning and came up with this patch. Ran
> redis-benchmark, it seemed to fix that for me -- only saw one "failed to
> linearize skb" during
> 
>   redis-benchmark -h XXX -d 1000 -t lrange
> 
> And before this change, a lot of "rides rocket" were triggered.
> 
> Thought?
> 
> ---8<---
> From 743495a2b2d338fc6cfe9bfd4b6e840392b87f4a Mon Sep 17 00:00:00 2001
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Fri, 16 May 2014 10:39:01 +0100
> Subject: [PATCH] xen-netfront: linearize SKB if it occupies too many slots
> 
> Some workload, such as Redis can generate SKBs which make use of compound
> pages. Netfront doesn't quite like that because it doesn't want to send
> exessive slots to the backend as backend might deem it malicious. On the
> flip side these packets are actually legit, the size check at the
> beginning of xennet_start_xmit ensures that packet size is below 64K.
> 
> So we linearize SKB if it occupies too many slots. If the linearization
> fails then the SKB is dropped.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 895355d..0361fc5 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -573,9 +573,21 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> -		net_alert_ratelimited(
> -			"xennet: skb rides the rocket: %d slots\n", slots);
> -		goto drop;
> +		if (skb_linearize(skb)) {

You don't need to actually linearize the skb here.
One with multiple fragments is fine.
I'm not sure there is a standard function to 'copy and refragment'
the skb data though.

> +			net_alert_ratelimited(
> +				"xennet: failed to linearize skb, skb dropped\n");
> +			goto drop;
> +		}
> +		data = skb->data;
> +		offset = offset_in_page(data);
> +		len = skb_headlen(skb);
> +		slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> +			xennet_count_skb_frag_slots(skb);

IIRC If you have called skb_linearize then there shouldn't be any fragments.

> +		if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> +			net_alert_ratelimited(
> +				"xennet: still too many slots after linerization: %d", slots);
> +			goto drop;
> +		}
>  	}
> 
>  	spin_lock_irqsave(&np->tx_lock, flags);
> --
> 1.7.10.4

	David
