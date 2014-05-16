From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Fri, 16 May 2014 11:22:52 +0100
Message-ID: <20140516102252.GE18551@zion.uk.xensource.com>
References: <537262AB.5010408@canonical.com>
 <5373C8D4.2010803@citrix.com>
 <1400143605.1006.1.camel@kazak.uk.xensource.com>
 <20140515110410.GD1117@zion.uk.xensource.com>
 <5374AF88.2070608@canonical.com>
 <20140516094842.GA18551@zion.uk.xensource.com>
 <063D6719AE5E284EB5DD2968C1650D6D17247362@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: 'Wei Liu' <wei.liu2@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6495 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756813AbaEPKYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 06:24:30 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17247362@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 10:05:46AM +0000, David Laight wrote:
[...]
> > ---8<---
> > From 743495a2b2d338fc6cfe9bfd4b6e840392b87f4a Mon Sep 17 00:00:00 2001
> > From: Wei Liu <wei.liu2@citrix.com>
> > Date: Fri, 16 May 2014 10:39:01 +0100
> > Subject: [PATCH] xen-netfront: linearize SKB if it occupies too many slots
> > 
> > Some workload, such as Redis can generate SKBs which make use of compound
> > pages. Netfront doesn't quite like that because it doesn't want to send
> > exessive slots to the backend as backend might deem it malicious. On the
> > flip side these packets are actually legit, the size check at the
> > beginning of xennet_start_xmit ensures that packet size is below 64K.
> > 
> > So we linearize SKB if it occupies too many slots. If the linearization
> > fails then the SKB is dropped.
> > 
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netfront.c |   18 +++++++++++++++---
> >  1 file changed, 15 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index 895355d..0361fc5 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -573,9 +573,21 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> >  		xennet_count_skb_frag_slots(skb);
> >  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> > -		net_alert_ratelimited(
> > -			"xennet: skb rides the rocket: %d slots\n", slots);
> > -		goto drop;
> > +		if (skb_linearize(skb)) {
> 
> You don't need to actually linearize the skb here.
> One with multiple fragments is fine.

Yes I know; but my idea is to get a SKB that doesn't use up too many
slots -- a linearized SKB will not use too many slots.

> I'm not sure there is a standard function to 'copy and refragment'
> the skb data though.
> 

That can only help if we can control how the fragment page is allocated.

> > +			net_alert_ratelimited(
> > +				"xennet: failed to linearize skb, skb dropped\n");
> > +			goto drop;
> > +		}
> > +		data = skb->data;
> > +		offset = offset_in_page(data);
> > +		len = skb_headlen(skb);
> > +		slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> > +			xennet_count_skb_frag_slots(skb);
> 
> IIRC If you have called skb_linearize then there shouldn't be any fragments.
> 

Plain copy-n-paste from code above. I will pay more attention if it's a
formal patch. ;-)

Wei.
