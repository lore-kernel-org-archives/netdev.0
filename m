From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 11:42:09 +0000
Message-ID: <20140115114208.GK5698@zion.uk.xensource.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
 <52D66F11.204@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Annie Li <Annie.li@oracle.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51232 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbaAOLmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 06:42:33 -0500
Content-Disposition: inline
In-Reply-To: <52D66F11.204@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 11:20:49AM +0000, David Vrabel wrote:
> On 09/01/14 22:48, Annie Li wrote:
> > Current netfront only grants pages for grant copy, not for grant transfer, so
> > remove corresponding transfer code and add receiving copy code in
> > xennet_release_rx_bufs.
> 
> While netfront only supports a copying backend, I don't see anything
> preventing the backend from retaining mappings to netfront's Rx buffers...
> 

Correct.

> > Signed-off-by: Annie Li <Annie.li@oracle.com>
> > ---
> >  drivers/net/xen-netfront.c |   60 ++-----------------------------------------
> >  1 files changed, 3 insertions(+), 57 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index e59acb1..692589e 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -1134,78 +1134,24 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
> >  
> >  static void xennet_release_rx_bufs(struct netfront_info *np)
> >  {
> [...]
> > -		mfn = gnttab_end_foreign_transfer_ref(ref);
> > +		gnttab_end_foreign_access_ref(ref, 0);
> 
> ... the gnttab_end_foreign_access_ref() may then fail and...
> 

Oh, I see. Andrew was actually referencing this function. Yes, it can
fail. Since he omitted "_ref" I looked at the other function when I
replied to him...

> >  		gnttab_release_grant_reference(&np->gref_rx_head, ref);
> >  		np->grant_rx_ref[id] = GRANT_INVALID_REF;
> [...]
> > +		kfree_skb(skb);
> 
> ... this could then potentially free pages that the backend still has
> mapped.  If the pages are then reused, this would leak information to
> the backend.
> 
> Since only a buggy backend would result in this, leaking the skbs and
> grant refs would be acceptable here.  I would also print an error.
> 

How about using gnttab_end_foreign_access. The deferred queue looks like
a right solution -- pending page won't get freed until gref is
quiescent.

Wei.

> While checking blkfront for how it handles this, it also doesn't appear
> to do the right thing either.
> 
> David
