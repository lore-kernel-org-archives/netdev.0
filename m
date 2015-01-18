From: Pat Erley <pat-lkml-Jx9fsTfDDR3YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 2/7] net: wireless: wcn36xx: get chip type from platform
 ops
Date: Sun, 18 Jan 2015 02:36:50 -0600
Message-ID: <54BB70A2.8070305@erley.org>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net> <20150118051049.31866.47265.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150118051049.31866.47265.stgit-FDDIDLfWL9/T9rR/E2HzMujRB4CPm7EUkgzjau31qRg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/17/2015 11:10 PM, Andy Green wrote:
> Autodetecting the chip type does not work well.
> Stop attempting to do it and require a platform op
> that tells us what the chip is.
>
> Signed-off-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>   drivers/net/wireless/ath/wcn36xx/main.c    |   18 +++++-------------
>   drivers/net/wireless/ath/wcn36xx/wcn36xx.h |    1 +
>   2 files changed, 6 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
> index 7dd8873..c4178c7 100644
> --- a/drivers/net/wireless/ath/wcn36xx/main.c
> +++ b/drivers/net/wireless/ath/wcn36xx/main.c
> @@ -221,17 +221,6 @@ static void wcn36xx_feat_caps_info(struct wcn36xx *wcn)
>   	}
>   }
>
> -static void wcn36xx_detect_chip_version(struct wcn36xx *wcn)
> -{
> -	if (get_feat_caps(wcn->fw_feat_caps, DOT11AC)) {
> -		wcn36xx_info("Chip is 3680\n");
> -		wcn->chip_version = WCN36XX_CHIP_3680;
> -	} else {
> -		wcn36xx_info("Chip is 3660\n");
> -		wcn->chip_version = WCN36XX_CHIP_3660;
> -	}
> -}
> -
>   static int wcn36xx_start(struct ieee80211_hw *hw)
>   {
>   	struct wcn36xx *wcn = hw->priv;
> @@ -286,8 +275,6 @@ static int wcn36xx_start(struct ieee80211_hw *hw)
>   			wcn36xx_feat_caps_info(wcn);
>   	}
>
> -	wcn36xx_detect_chip_version(wcn);
> -
>   	/* DMA channel initialization */
>   	ret = wcn36xx_dxe_init(wcn);
>   	if (ret) {
> @@ -1023,6 +1010,11 @@ static int wcn36xx_probe(struct platform_device *pdev)
>   	wcn->hw = hw;
>   	wcn->dev = &pdev->dev;
>   	wcn->ctrl_ops = pdev->dev.platform_data;
> +	if (!wcn->ctrl_ops->get_chip_type) {
> +		dev_err(&pdev->dev, "Missing ops->get_chip_type\n");
> +		return -EINVAL;
> +	}
> +	wcn->chip_version = wcn->ctrl_ops->get_chip_type();
>
>   	mutex_init(&wcn->hal_mutex);
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> index a5366b6..04793c6 100644
> --- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> +++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
> @@ -110,6 +110,7 @@ struct wcn36xx_platform_ctrl_ops {
>   	void (*close)(void);
>   	int (*tx)(char *buf, size_t len);
>   	int (*get_hw_mac)(u8 *addr);
> +	int (*get_chip_type)(void);
>   	int (*smsm_change_state)(u32 clear_mask, u32 set_mask);
>   };
>

(This all assumes this driver is currently actually being used)

Doesn't this change break any current users of wcn36xx?  Couldn't you
just take the old wcn36xx_detect_chip_version and either add the check
for get_chip_type to the beginning and make it use it and return, or
fall back to the old 'broken' way?

Another alternative would be to update wcn36xx_detect_chip_version to
behave like you expect get_chip_type to, and make it the default and let
platforms override it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
