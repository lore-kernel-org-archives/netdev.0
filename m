From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 6/7] xen-netback: coalesce slots and fix
 regressions
Date: Tue, 9 Apr 2013 13:48:45 +0100
Message-ID: <20130409124845.GG16998@zion.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-7-git-send-email-wei.liu2@citrix.com>
 <5164221302000078000CBBF2@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23803 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759219Ab3DIMsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 08:48:46 -0400
Content-Disposition: inline
In-Reply-To: <5164221302000078000CBBF2@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 01:13:39PM +0100, Jan Beulich wrote:
> >>> On 09.04.13 at 13:07, Wei Liu <wei.liu2@citrix.com> wrote:
[...]
> > +
> > +static struct kernel_param_ops max_skb_slots_param_ops = {
> 
> __moduleparam_const

TBH I don't see any driver makes use of this. Probably a simple "const"
can do?

> 
> > +	.set = max_skb_slots_set,
> > +	.get = param_get_ulong,
> 
> param_get_uint
> 

Done.

> > @@ -251,7 +291,7 @@ static int max_required_rx_slots(struct xenvif *vif)
> >  	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
> >  
> >  	if (vif->can_sg || vif->gso || vif->gso_prefix)
> > -		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> > +		max += XEN_NETIF_NR_SLOTS_MIN + 1; /* extra_info + frags */
> >  
> >  	return max;
> >  }
> > @@ -657,7 +697,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
> >  		__skb_queue_tail(&rxq, skb);
> >  
> >  		/* Filled the batch queue? */
> > -		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
> > +		if (count + XEN_NETIF_NR_SLOTS_MIN >= XEN_NETIF_RX_RING_SIZE)
> >  			break;
> >  	}
> >  
> 
> Are the two changes above really correct? You're having an skb as
> input here, and hence you want to use all the frags, and nothing
> beyond. Another question is whether the frontend can handle
> those, but that aspect isn't affected by the code being modified
> here.
> 

This patch tries to remove dependency on MAX_SKB_FRAGS. Writing the
protocol-defined value here is OK IMHO.

[...]
> >  			return -E2BIG;
> >  		}
> >  
> > -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> > +		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
> >  		       sizeof(*txp));
> >  		if (txp->size > first->size) {
> > -			netdev_err(vif->dev, "Frag is bigger than frame.\n");
> > +			netdev_err(vif->dev, "Packet is bigger than frame.\n");
> 
> I don't think "packet" is the right term here.
> 

Maybe just "Invalid tx request" and dump all information?


Wei.

> Jan
