From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] marvell sky2 driver: fix so it works without unaligned
 accesses
Date: Tue, 03 Apr 2012 18:18:36 +0200
Message-ID: <1333469916.18626.284.camel@edumazet-glaptop>
References: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-03 at 11:13 -0400, Chris Metcalf wrote:
> The driver uses a receive_new() routine that ends up requiring unaligned
> accesses in IP header processing.  If the architecture doesn't support
> efficient unaligned accesses, just copy all ingress packets to the bounce
> buffers instead.
> 
> This allows the driver to be used on the Tilera TILEmpower-Gx, since
> the tile architecture doesn't currently handle kernel unaligned accesses,
> just userspace.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
>  drivers/net/ethernet/marvell/sky2.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 879b0a4..7a15482 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -2490,6 +2490,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
>  	return skb;
>  }
>  
> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
>  /* Adjust length of skb with fragments to match received data */
>  static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
>  			  unsigned int length)
> @@ -2555,6 +2556,7 @@ nomap:
>  nobuf:
>  	return NULL;
>  }
> +#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
>  
>  /*
>   * Receive one packet.
> @@ -2598,10 +2600,12 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
>  		goto error;
>  
>  okay:
> -	if (length < copybreak)
> -		skb = receive_copy(sky2, re, length);
> -	else
> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	if (length >= copybreak)
>  		skb = receive_new(sky2, re, length);
> +	else
> +#endif
> +		skb = receive_copy(sky2, re, length);
>  
>  	dev->stats.rx_dropped += (skb == NULL);
>  

The (expensive ?) copy should be done only if (sky2->hw->flags &
SKY2_HW_RAM_BUFFER)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index b806d9b..3da3cdc 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2599,7 +2599,11 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 		goto error;
 
 okay:
-	if (length < copybreak)
+	if ((length < copybreak) 
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+		|| (sky2->hw->flags & SKY2_HW_RAM_BUFFER)
+#endif
+		)
 		skb = receive_copy(sky2, re, length);
 	else
 		skb = receive_new(sky2, re, length);
