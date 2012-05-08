From: Thomas Pilarski <thomas.pi@arcor.de>
Subject: Re: [PATCH] r8169: fix problem with TSO (TX_BUFFS_AVAIL negative
 value)
Date: Tue, 08 May 2012 12:21:26 +0200
Message-ID: <4FA8F3A6.2070305@arcor.de>
References: <1336430367.11363.38.camel@blackbone.local> <20120507234205.GA2230@electric-eye.fr.zoreil.com> <20120508100657.GA10744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@fiec.espol.edu.ec>, Thomas Pilarski <thomas.pi@arcor.de>,
	Julien Ducourthial <jducourt@free.fr>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120508100657.GA10744@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have already tested the patch with the kernel 3.3.4 and the module
from bugzilla (https://bugzilla.kernel.org/attachment.cgi?id=72682). The
iommu error still occurs.

Am 08.05.2012 12:06, schrieb Francois Romieu:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> Alex, Thomas, can you check if Julien's patch below fixes your broken
>> kernels as well ? 
> You will have better luck with a patch whose lines are correctly formed.
>
> Patch below applies on top of 3.4-rc6.
>
> (Julien, please check your mail user agent)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index f545093..d1e3c51 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -61,8 +61,12 @@
>  #define R8169_MSG_DEFAULT \
>  	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
>  
> -#define TX_BUFFS_AVAIL(tp) \
> -	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
> +#define TX_SLOTS_AVAIL(tp) \
> +	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx)
> +
> +/* A skbuff with nr_frags needs nr_frags+1 entries in the tx queue */
> +#define TX_FRAGS_READY_FOR(tp,nr_frags) \
> +	(TX_SLOTS_AVAIL(tp) >= (nr_frags + 1))
>  
>  /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
>     The RTL chips use a 64 element hash table based on the Ethernet CRC. */
> @@ -5115,7 +5119,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
>  	u32 opts[2];
>  	int frags;
>  
> -	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
> +	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
>  		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
>  		goto err_stop_0;
>  	}
> @@ -5169,7 +5173,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
>  
>  	mmiowb();
>  
> -	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
> +	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
>  		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
>  		 * not miss a ring update when it notices a stopped queue.
>  		 */
> @@ -5183,7 +5187,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
>  		 * can't.
>  		 */
>  		smp_mb();
> -		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
> +		if (TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS))
>  			netif_wake_queue(dev);
>  	}
>  
> @@ -5306,7 +5310,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
>  		 */
>  		smp_mb();
>  		if (netif_queue_stopped(dev) &&
> -		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
> +		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
>  			netif_wake_queue(dev);
>  		}
>  		/*
