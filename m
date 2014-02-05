From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: Re: [PATCHv1 net] tg3: fix deadlock in tg3_change_mtu()
Date: Wed, 5 Feb 2014 14:09:54 -0800
Message-ID: <52F2B6B2.1020901@broadcom.com>
References: <1391540487-31207-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>
To: David Vrabel <david.vrabel@citrix.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:20265 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbaBEWKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 17:10:18 -0500
In-Reply-To: <1391540487-31207-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/04/2014 11:01 AM, David Vrabel wrote:
> 5780 cards cannot have jumbo frames and TSO enabled together.  When
> jumbo frames are enabled by setting the MTU, the TSO feature must be
> cleared.  This is done indirectly by calling netdev_update_features()
> which will call tg3_fix_features() to actually clear the flags.
>
> netdev_update_features() will also trigger a new netlink message for
> the feature change event which will result in a call to
> tg3_get_stats64() which deadlocks on the tg3 lock.
>
> Fix this by dropping the tg3 lock while calling
> netdev_update_features().  This is safe as the device is down and the
> hardware is stopped.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>   drivers/net/ethernet/broadcom/tg3.c |   18 +++++++++++-------
>   1 files changed, 11 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index e2ca03e..0b344c0 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14077,17 +14077,13 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
>   	dev->mtu = new_mtu;
>
>   	if (new_mtu > ETH_DATA_LEN) {
> -		if (tg3_flag(tp, 5780_CLASS)) {
> -			netdev_update_features(dev);
> +		if (tg3_flag(tp, 5780_CLASS))
>   			tg3_flag_clear(tp, TSO_CAPABLE);
> -		} else {
> +		else
>   			tg3_flag_set(tp, JUMBO_RING_ENABLE);
> -		}
>   	} else {
> -		if (tg3_flag(tp, 5780_CLASS)) {
> +		if (tg3_flag(tp, 5780_CLASS))
>   			tg3_flag_set(tp, TSO_CAPABLE);
> -			netdev_update_features(dev);
> -		}
>   		tg3_flag_clear(tp, JUMBO_RING_ENABLE);
>   	}
>   }
> @@ -14119,6 +14115,14 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
>
>   	tg3_set_mtu(dev, tp, new_mtu);
>
> +	tg3_full_unlock(tp);
> +
> +	/* Adjusting MTU may add/remove TSO feature. */
> +	if (tg3_flag(tp, 5780_CLASS))
> +		netdev_update_features(dev);
> +
> +	tg3_full_lock(tp, 0);
> +
>   	/* Reset PHY, otherwise the read DMA engine will be in a mode that
>   	 * breaks all requests to 256 bytes.
>   	 */
>

David,
Rather than doing it this way, I think it's sufficient to move the call to 
tg3_set_mtu() between tg3_netif_stop() and tg3_full_lock().

Before tg3 started using set_bit() for flags, tg3_set_mtu() needed to be under a 
lock, but that's not the case anymore.

Can you try this patch?

diff --git a/drivers/net/ethernet/broadcom/tg3.c 
b/drivers/net/ethernet/broadcom/tg3.c
index e2ca03e..0bb79b8 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14113,12 +14113,12 @@ static int tg3_change_mtu(struct net_device *dev, int 
new_mtu)

         tg3_netif_stop(tp);

+       tg3_set_mtu(dev, tp, new_mtu);
+
         tg3_full_lock(tp, 1);

         tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);

-       tg3_set_mtu(dev, tp, new_mtu);
-
         /* Reset PHY, otherwise the read DMA engine will be in a mode that
          * breaks all requests to 256 bytes.
          */

Nithin.
