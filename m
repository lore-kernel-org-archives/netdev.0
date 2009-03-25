From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] gianfar: reallocate skb when headroom is not enough for
 fcb
Date: Wed, 25 Mar 2009 08:53:33 -0700
Message-ID: <20090325085333.4bb73f55@nehalam>
References: <20090325.000643.55804624.davem@davemloft.net>
	<1237972533-11195-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40536 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762332AbZCYPxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 11:53:41 -0400
In-Reply-To: <1237972533-11195-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Mar 2009 17:15:33 +0800
Li Yang <leoli@freescale.com> wrote:

> Gianfar uses a hardware header FCB for offloading.  However when used
> with bridging or IP forwarding, TX skb might not have enough headroom
> for the FCB.  Reallocate skb for such cases.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/net/gianfar.c |   31 +++++++++++++++++++++----------
>  1 files changed, 21 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 9831b3f..29dc4ee 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -1206,10 +1206,19 @@ static int gfar_enet_open(struct net_device *dev)
>  	return err;
>  }
>  
> -static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
> +static inline struct txfcb *gfar_add_fcb(struct sk_buff **skbp)
>  {
> -	struct txfcb *fcb = (struct txfcb *)skb_push (skb, GMAC_FCB_LEN);
> -
> +	struct txfcb *fcb;
> +	struct sk_buff *skb = *skbp;
> +
> +	if (unlikely(skb_headroom(skb) < GMAC_FCB_LEN)) {
> +		struct sk_buff *old_skb = skb;
> +		skb = skb_realloc_headroom(old_skb, GMAC_FCB_LEN);

> +		if (!skb)
> +			return NULL;
> +		dev_kfree_skb_any(old_skb);
> +	}
> +	fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
>  	cacheable_memzero(fcb, GMAC_FCB_LEN);
> 

Overall, this looks like the wrong code (not copying back new skb)
and in awkward place. Also your version doesn't handle case where
skb headroom is not writable.

Why not:

--- a/drivers/net/gianfar.c	2009-03-25 08:39:03.890718197 -0700
+++ b/drivers/net/gianfar.c	2009-03-25 08:51:39.733279404 -0700
@@ -1309,6 +1309,17 @@ static int gfar_start_xmit(struct sk_buf
 	unsigned long flags;
 	unsigned int nr_frags, length;
 
+	/* make sure there is space and can write FCB */
+	if (!skb_clone_writeable(skb, GMAC_FCB_LEN)) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_realloc_headroom(skb, GMAC_FCB_LEN);
+		kfree_skb(skb);
+		if (!skb2)
+			return NETDEV_TX_OK;
+		skb = skb2;
+	}
+
 	base = priv->tx_bd_base;
 
 	/* total number of fragments in the SKB */

