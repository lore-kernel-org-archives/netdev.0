From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 6/6] xen-netback: don't disconnect frontend
 when seeing oversize frame
Date: Mon, 25 Mar 2013 13:52:03 +0000
Message-ID: <20130325135203.GA3339@zion.uk.xensource.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
 <515056F502000078000C8184@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61220 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754738Ab3CYNwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 09:52:05 -0400
Content-Disposition: inline
In-Reply-To: <515056F502000078000C8184@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 25, 2013 at 12:53:57PM +0000, Jan Beulich wrote:
> >>> On 25.03.13 at 12:08, Wei Liu <wei.liu2@citrix.com> wrote:
> > @@ -947,10 +949,21 @@ static int netbk_count_requests(struct xenvif *vif,
> >  
> >  		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
> >  		       sizeof(*txp));
> > -		if (txp->size > first->size) {
> > -			netdev_err(vif->dev, "Packet is bigger than frame.\n");
> > -			netbk_fatal_tx_err(vif);
> > -			return -EIO;
> > +
> > +		/* If the guest submitted a frame >= 64 KiB then
> > +		 * first->size overflowed and following slots will
> > +		 * appear to be larger than the frame.
> > +		 *
> > +		 * This cannot be fatal error as there are buggy
> > +		 * frontends that do this.
> > +		 *
> > +		 * Consume all slots and drop the packet.
> > +		 */
> > +		if (!drop && txp->size > first->size) {
> > +			if (net_ratelimit())
> > +				netdev_dbg(vif->dev,
> > +					   "Packet is bigger than frame.\n");
> > +			drop = true;
> 
> So this deals with one half of the problem, but shouldn't we also
> revert the disconnect when slots would exceed MAX_SKB_FRAGS
> (or max_skb_slots after patch 5)? Afaict you could trivially extend
> this patch to also cover that case...
> 

I don't think we should do that. IMO a guest using too many slots should
be considered malicious and disconnected.


Wei.

> Jan
