From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in	xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 11:20:49 +0000
Message-ID: <52D66F11.204@citrix.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>
To: Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50314 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbaAOLUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 06:20:53 -0500
In-Reply-To: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 22:48, Annie Li wrote:
> Current netfront only grants pages for grant copy, not for grant transfer, so
> remove corresponding transfer code and add receiving copy code in
> xennet_release_rx_bufs.

While netfront only supports a copying backend, I don't see anything
preventing the backend from retaining mappings to netfront's Rx buffers...

> Signed-off-by: Annie Li <Annie.li@oracle.com>
> ---
>  drivers/net/xen-netfront.c |   60 ++-----------------------------------------
>  1 files changed, 3 insertions(+), 57 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index e59acb1..692589e 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1134,78 +1134,24 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
>  
>  static void xennet_release_rx_bufs(struct netfront_info *np)
>  {
[...]
> -		mfn = gnttab_end_foreign_transfer_ref(ref);
> +		gnttab_end_foreign_access_ref(ref, 0);

... the gnttab_end_foreign_access_ref() may then fail and...

>  		gnttab_release_grant_reference(&np->gref_rx_head, ref);
>  		np->grant_rx_ref[id] = GRANT_INVALID_REF;
[...]
> +		kfree_skb(skb);

... this could then potentially free pages that the backend still has
mapped.  If the pages are then reused, this would leak information to
the backend.

Since only a buggy backend would result in this, leaking the skbs and
grant refs would be acceptable here.  I would also print an error.

While checking blkfront for how it handles this, it also doesn't appear
to do the right thing either.

David
