From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 4/4] xen-netback: coalesce slots before copying
Date: Thu, 21 Mar 2013 18:37:05 +0000
Message-ID: <1363891025.17509.1.camel@zion.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
	 <1363608462.30193.34.camel@zakaz.uk.xensource.com>
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
Received: from smtp.citrix.com ([66.165.176.89]:35358 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979Ab3CUShH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 14:37:07 -0400
In-Reply-To: <1363608462.30193.34.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 12:07 +0000, Ian Campbell wrote:

> >  	/* Skip first skb fragment if it is on same page as header fragment. */
> >  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
> >  
> > -	for (i = start; i < shinfo->nr_frags; i++, txp++) {
> > -		struct page *page;
> > -		pending_ring_idx_t index;
> > +	/* Coalesce tx requests, at this point the packet passed in
> > +	 * should be <= 64K. Any packets larger than 64K has been
> > +	 * dropped / caused fatal error early on.
> 
> Whereabouts is this? Since the size field is u16 how do we even detect
> this case. Since (at least prior to your other fix in this series) it
> would have overflowed when the guest constructed the request.
> 

This is done in netbk_count_requests(). I will fix the comment here.

> 
> > @@ -1025,6 +1108,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
> >  	struct gnttab_copy *gop = *gopp;
> >  	u16 pending_idx = *((u16 *)skb->data);
> >  	struct skb_shared_info *shinfo = skb_shinfo(skb);
> > +	struct pending_tx_info *tx_info;
> >  	int nr_frags = shinfo->nr_frags;
> >  	int i, err, start;
> >  
> > @@ -1037,12 +1121,17 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
> >  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
> >  
> >  	for (i = start; i < nr_frags; i++) {
> > -		int j, newerr;
> > +		int j, newerr = 0, n;
> >  
> >  		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
> > +		tx_info = &netbk->pending_tx_info[pending_idx];
> >  
> >  		/* Check error status: if okay then remember grant handle. */
> > -		newerr = (++gop)->status;
> > +		for (n = 0; n < tx_info->nr_tx_req; n++) {
> struct pending_tx_info is used in some arrays which can have a fair few
> elements so if there are ways to reduce the size that is worth
> considering I think.
> 
> So rather than storing both nr_tx_req and start_idx can we just store
> start_idx and loop while start_idx != 0 (where the first one has
> start_idx == zero)?
> 
> This might fall out more naturally if you were to instead store next_idx
> in each pending tx with a suitable terminator at the end? Or could be
> last_idx if it is convenient to count that way round, you don't need to
> respond in-order.
> 

Done shrinking this structure.


Wei.
