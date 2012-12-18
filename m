From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Tue, 18 Dec 2012 14:15:25 +0000
Message-ID: <1355840125.14620.227.camel@zakaz.uk.xensource.com>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <20121218141048.GC4518@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:61853 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846Ab2LROPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 09:15:30 -0500
In-Reply-To: <20121218141048.GC4518@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 14:10 +0000, Konrad Rzeszutek Wilk wrote:
> On Tue, Dec 18, 2012 at 01:51:51PM +0000, Ian Campbell wrote:
> > Using RX_COPY_THRESHOLD is incorrect if the SKB is actually smaller
> > than that. We have already accounted for this in
> > NETFRONT_SKB_CB(skb)->pull_to so use that instead.
> > 
> > Fixes WARN_ON from skb_try_coalesce.
> 
> This should probably be also on the stable tree for 3.7 at least?

Yes, hence "Cc: stable@kernel.org # 3.7.x only" below ;-)

> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: Sander Eikelenboom <linux@eikelenboom.it>
>   ^^ - Reported-by: 
> 
> > Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>   ^^ - Acked-by:
> 
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
> > -- 
> > 1.7.2.5
> > 
