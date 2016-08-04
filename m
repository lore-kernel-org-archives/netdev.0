From: Vaishali Thakkar <vaishali.thakkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wl3501_cs: Add spinlock to wl3501_reset
Date: Thu, 4 Aug 2016 10:31:41 +0530
Message-ID: <57A2CC35.60808@oracle.com>
References: <1470130913-5218-1-git-send-email-andrianov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470130913-5218-1-git-send-email-andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Tuesday 02 August 2016 03:11 PM, Pavel Andrianov wrote:
> Likely wl3501_reset should acquire spinlock as wl3501_{open, close}.
> One of calls of wl3501_reset has been already protected.
> The others were unprotected and might lead to a race condition.
> The patch adds spinlock into the wl3501_reset and removes it from 
> wl3501_tx_timeout.
> 
> Found by Linux Driver Verification project (linuxtesting.org)
> 
> Signed-off-by: Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>

Acked-by: Vaishali Thakkar <vaishali.thakkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

> ---
>  drivers/net/wireless/wl3501_cs.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
> index 13fd734..196f13c 100644
> --- a/drivers/net/wireless/wl3501_cs.c
> +++ b/drivers/net/wireless/wl3501_cs.c
> @@ -1247,7 +1247,9 @@ static int wl3501_reset(struct net_device *dev)
>  {
>  	struct wl3501_card *this = netdev_priv(dev);
>  	int rc = -ENODEV;
> +	unsigned long flags;
>  
> +	spin_lock_irqsave(&this->lock, flags);
>  	wl3501_block_interrupt(this);
>  
>  	if (wl3501_init_firmware(this)) {
> @@ -1269,20 +1271,17 @@ static int wl3501_reset(struct net_device *dev)
>  	pr_debug("%s: device reset", dev->name);
>  	rc = 0;
>  out:
> +	spin_unlock_irqrestore(&this->lock, flags);
>  	return rc;
>  }
>  
>  static void wl3501_tx_timeout(struct net_device *dev)
>  {
> -	struct wl3501_card *this = netdev_priv(dev);
>  	struct net_device_stats *stats = &dev->stats;
> -	unsigned long flags;
>  	int rc;
>  
>  	stats->tx_errors++;
> -	spin_lock_irqsave(&this->lock, flags);
>  	rc = wl3501_reset(dev);
> -	spin_unlock_irqrestore(&this->lock, flags);
>  	if (rc)
>  		printk(KERN_ERR "%s: Error %d resetting card on Tx timeout!\n",
>  		       dev->name, rc);
> 

-- 
Vaishali
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
