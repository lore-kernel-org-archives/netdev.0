From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netback: add gso_segs calculation
Date: Mon, 16 Dec 2013 10:23:57 -0800
Message-ID: <1387218237.19078.247.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387214429-4778-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:50021 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017Ab3LPSYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 13:24:01 -0500
Received: by mail-yh0-f44.google.com with SMTP id f64so4025776yha.3
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 10:24:00 -0800 (PST)
In-Reply-To: <1387214429-4778-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 17:20 +0000, Paul Durrant wrote:
> netback already has code which parses IPv4 and v6 headers to set up checksum
> offsets and these are always applied to GSO packets being sent from
> frontends. It's therefore suboptimal that GSOs are being marked
> SKB_GSO_DODGY to defer the gso_segs calculation when netback already has all
> necessary information to hand to do the calculation. This patch adds that
> calculation.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 904e497..0af8d97 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1043,10 +1043,7 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
>  	}
>  
>  	skb_shinfo(skb)->gso_size = gso->u.gso.size;
> -
> -	/* Header must be checked, and gso_segs computed. */
> -	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
> -	skb_shinfo(skb)->gso_segs = 0;
> +	/* gso_segs will be calculated later */
>  
>  	return 0;
>  }
> @@ -1582,6 +1579,18 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
>  
>  		skb_probe_transport_header(skb, 0);
>  
> +		/* If the packet is GSO then we will have just set up the
> +		 * transport header offset in checksum_setup so it's now
> +		 * straightforward to calculate gso_segs.
> +		 */
> +		if (skb_is_gso(skb)) {
> +			int mss = skb_shinfo(skb)->gso_size;
> +			int hdrlen = skb->transport_header + tcp_hdrlen(skb);

This means there is no headroom ?

This is not what I am seeing in this driver, as it uses :

skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);

> +
> +			skb_shinfo(skb)->gso_segs =
> +				DIV_ROUND_UP(skb->len - hdrlen, mss);
> +		}
> +
>  		vif->dev->stats.rx_bytes += skb->len;
>  		vif->dev->stats.rx_packets++;
>  
