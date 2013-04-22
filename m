From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V5 6/7] xen-netback: coalesce slots in TX path and fix
 regressions
Date: Mon, 22 Apr 2013 10:28:25 +0100
Message-ID: <20130422092825.GN5815@zion.uk.xensource.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
 <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
 <517462D2.8040209@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:46162 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909Ab3DVJ2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 05:28:43 -0400
Content-Disposition: inline
In-Reply-To: <517462D2.8040209@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 21, 2013 at 11:06:10PM +0100, annie li wrote:
[...]
> > -		if (unlikely(frags >= MAX_SKB_FRAGS)) {
> > -			netdev_err(vif->dev, "Too many frags\n");
> > +		/* This guest is really using too many slots and
> > +		 * considered malicious.
> > +		 */
> > +		if (unlikely(slots >= max_skb_slots)) {
> > +			netdev_err(vif->dev,
> > +				   "Malicious frontend using %d slots, threshold %u\n",
> > +				   slots, max_skb_slots);
> >   			netbk_fatal_tx_err(vif);
> >   			return -E2BIG;
> 
> It is possible that vif is freed when packet size is less than 64K here 
> but slots required >= max_skb_slots. Alough max_skb_slots can be 
> configured, this kind of packets would be dropped in following if 
> (!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN).
> 

Yes, because slots required >= max_skb_slots is considered malicious
behavior. The size of the packet doesn't matter here.

> >   		}
> >   
> > -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> > +		/* Xen network protocol had implicit dependency on
> > +		 * MAX_SKB_FRAGS. XEN_NETIF_NR_SLOTS_MIN is set to the
> > +		 * historical MAX_SKB_FRAGS value 18 to honor the same
> > +		 * behavior as before. Any packet using more than 18
> > +		 * slots but less than max_skb_slots slots is dropped
> > +		 */
> > +		if (!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN) {
> > +			if (net_ratelimit())
> > +				netdev_dbg(vif->dev,
> > +					   "Too many slots (%d) exceeding limit (%d), dropping packet\n",
> > +					   slots, XEN_NETIF_NR_SLOTS_MIN);
> > +			drop_err = -E2BIG;
> 
> It is possible to drop packets like above(size < 64K && slot >= 
> XEN_NETIF_NR_SLOTS_MIN). I do not know how frequently this kind of 
> packets appear, maybe some SKBs with compound page(size < 64K && slot >= 
> XEN_NETIF_NR_SLOTS_MIN) are dropped here?
> 

I don't know either, but this is the default behavior of netback so here
we retain the same behavior here to avoid further regression.


Wei.
