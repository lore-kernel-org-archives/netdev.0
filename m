From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net V2] xen-netback: don't move event pointer
 in TX credit timeout callback
Date: Thu, 15 May 2014 14:40:58 +0100
Message-ID: <5374C3EA.1080807@citrix.com>
References: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <paul.durrant@citrix.com>, <jajcus@jajcus.net>
To: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4133 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbaEONlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 09:41:00 -0400
In-Reply-To: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/05/14 12:59, Wei Liu wrote:
> ... otherwise the frontend will try to send TX event all the time, even
> if no progress can be made. The pointer should only be advanced by the
> routine that actually processes the ring (that is, xenvif_poll).

No it does not.  RING_FINAL_CHECK_FOR_REQUESTS() only advances the event
index if the ring is empty.

This will also result in xenvif_up() failing to properly enable the event.

I think Jacek's bug may be that netback fails to call napi_complete()
when credit is exceeded and there still outstanding requests on the
from-guest ring and thus napi repeatedly polls.

David

> 
> Reported-by: Jacek Konieczny <jajcus@jajcus.net>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 7666540..8e2cbeb 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -658,7 +658,7 @@ void xenvif_check_rx_xenvif(struct xenvif *vif)
>  {
>  	int more_to_do;
>  
> -	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
> +	more_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
>  
>  	if (more_to_do)
>  		napi_schedule(&vif->napi);
> 
