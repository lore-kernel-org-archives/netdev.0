From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 2/4] xen-netfront: drop skb when skb->len > 65535
Date: Mon, 18 Mar 2013 14:40:42 +0000
Message-ID: <1363617642.29093.203.camel@zion.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
	 <1363606970.30193.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63621 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671Ab3CROkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 10:40:43 -0400
In-Reply-To: <1363606970.30193.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 11:42 +0000, Ian Campbell wrote:
> On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:
> > The `size' field of Xen network wire format is uint16_t, anything bigger than
> > 65535 will cause overflow.
> > 
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netfront.c |   12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> > 
> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index 5527663..8c3d065 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	unsigned int len = skb_headlen(skb);
> >  	unsigned long flags;
> >  
> > +	/*
> > +	 * wire format of xen_netif_tx_request only supports skb->len
> > +	 * < 64K, because size field in xen_netif_tx_request is
> > +	 * uint16_t.
> 
> Is there some field we can set e.g. in struct ethernet_device which
> would stop this from happening?
> 

struct ethernet_device? I could not find it.

And for struct net_device, there is no field for this AFAICT.


Wei.

> 
> > +	 */
> > +	if (unlikely(skb->len > (uint16_t)(~0))) {
> > +		net_alert_ratelimited(
> > +			"xennet: skb->len = %d, too big for wire format\n",
> > +			skb->len);
> > +		goto drop;
> > +	}
> > +
> >  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> >  		xennet_count_skb_frag_slots(skb);
> >  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> 
> 
