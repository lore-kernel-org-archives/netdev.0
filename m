From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH net V3] xen-netback: use jiffies_64 value to calculate
 credit timeout
Date: Tue, 29 Oct 2013 10:39:57 +0800
Message-ID: <526F1FFD.4040101@oracle.com>
References: <1382962077-13406-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	david.vrabel@citrix.com, jbeulich@suse.com,
	Ian Campbell <ian.campbell@citrix.com>,
	Jason Luan <jianhai.luan@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47940 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757559Ab3J2CkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 22:40:17 -0400
In-Reply-To: <1382962077-13406-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-28 20:07, Wei Liu wrote:
> time_after_eq() only works if the delta is < MAX_ULONG/2.
>
> For a 32bit Dom0, if netfront sends packets at a very low rate, the time
> between subsequent calls to tx_credit_exceeded() may exceed MAX_ULONG/2
> and the test for timer_after_eq() will be incorrect. Credit will not be
> replenished and the guest may become unable to send packets (e.g., if
> prior to the long gap, all credit was exhausted).
>
> Use jiffies_64 variant to mitigate this problem for 32bit Dom0.
>
> Suggested-by: Jan Beulich <jbeulich@suse.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Jason Luan <jianhai.luan@oracle.com>
> ---
>   drivers/net/xen-netback/common.h    |    1 +
>   drivers/net/xen-netback/interface.c |    3 +--
>   drivers/net/xen-netback/netback.c   |   10 +++++-----
>   3 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 5715318..400fea1 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -163,6 +163,7 @@ struct xenvif {
>   	unsigned long   credit_usec;
>   	unsigned long   remaining_credit;
>   	struct timer_list credit_timeout;
> +	u64 credit_window_start;
>   
>   	/* Statistics */
>   	unsigned long rx_gso_checksum_fixup;
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 01bb854..459935a 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -312,8 +312,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>   	vif->credit_bytes = vif->remaining_credit = ~0UL;
>   	vif->credit_usec  = 0UL;
>   	init_timer(&vif->credit_timeout);
> -	/* Initialize 'expires' now: it's used to track the credit window. */
> -	vif->credit_timeout.expires = jiffies;
> +	vif->credit_window_start = get_jiffies_64();
>   
>   	dev->netdev_ops	= &xenvif_netdev_ops;
>   	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index f3e591c..900da4b 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1185,9 +1185,8 @@ out:
>   
>   static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>   {
> -	unsigned long now = jiffies;
> -	unsigned long next_credit =
> -		vif->credit_timeout.expires +
> +	u64 now = get_jiffies_64();
> +	u64 next_credit = vif->credit_window_start +
>   		msecs_to_jiffies(vif->credit_usec / 1000);
>   
>   	/* Timer could already be pending in rare cases. */
> @@ -1195,8 +1194,8 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>   		return true;
>   
>   	/* Passed the point where we can replenish credit? */
> -	if (time_after_eq(now, next_credit)) {
> -		vif->credit_timeout.expires = now;
> +	if (time_after_eq64(now, next_credit)) {
> +		vif->credit_window_start = now;
>   		tx_add_credit(vif);
>   	}
>   
> @@ -1208,6 +1207,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>   			tx_credit_callback;
>   		mod_timer(&vif->credit_timeout,
>   			  next_credit);
> +		vif->credit_window_start = next_credit;
>   
>   		return true;
>   	}

This patch looks good, thanks Wei.

Thanks
Annie
