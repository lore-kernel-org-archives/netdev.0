From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Tue, 18 Dec 2012 15:26:38 +0000
Message-ID: <1355844398.14620.254.camel@zakaz.uk.xensource.com>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:26093 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab2LRP0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 10:26:41 -0500
In-Reply-To: <1355843525.9380.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 15:12 +0000, Eric Dumazet wrote:
> On Tue, 2012-12-18 at 13:51 +0000, Ian Campbell wrote:
> > Using RX_COPY_THRESHOLD is incorrect if the SKB is actually smaller
> > than that. We have already accounted for this in
> > NETFRONT_SKB_CB(skb)->pull_to so use that instead.
> > 
> > Fixes WARN_ON from skb_try_coalesce.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: Sander Eikelenboom <linux@eikelenboom.it>
> > Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Cc: annie li <annie.li@oracle.com>
> > Cc: xen-devel@lists.xensource.com
> > Cc: netdev@vger.kernel.org
> > Cc: stable@kernel.org # 3.7.x only
> > ---
> >  drivers/net/xen-netfront.c |   15 +++++----------
> >  1 files changed, 5 insertions(+), 10 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index caa0110..b06ef81 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -971,17 +971,12 @@ err:
> >  		 * overheads. Here, we add the size of the data pulled
> >  		 * in xennet_fill_frags().
> >  		 *
> > -		 * We also adjust for any unused space in the main
> > -		 * data area by subtracting (RX_COPY_THRESHOLD -
> > -		 * len). This is especially important with drivers
> > -		 * which split incoming packets into header and data,
> > -		 * using only 66 bytes of the main data area (see the
> > -		 * e1000 driver for example.)  On such systems,
> > -		 * without this last adjustement, our achievable
> > -		 * receive throughout using the standard receive
> > -		 * buffer size was cut by 25%(!!!).
> > +		 * We also adjust for the __pskb_pull_tail done in
> > +		 * handle_incoming_queue which pulls data from the
> > +		 * frags into the head area, which is already
> > +		 * accounted in RX_COPY_THRESHOLD.
> >  		 */
> > -		skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
> > +		skb->truesize += skb->data_len - NETFRONT_SKB_CB(skb)->pull_to;
> >  		skb->len += skb->data_len;
> >  
> >  		if (rx->flags & XEN_NETRXF_csum_blank)
> 
> 
> But skb truesize is not what you think.

Indeed, it seems I was completely backwards about what it means!

> You must account the exact memory used by this skb, not only the used
> part of it.
> 
> At the very minimum, it should be
> 
> skb->truesize += skb->data_len;
> 
> But it really should be the allocated size of the fragment.
> 
> If its a page, then its a page, even if you use one single byte in it.

So actually we want += PAGE_SIZE * skb_shinfo(skb)->nr_frags ?

Sander, can you try that change?

Ian.
