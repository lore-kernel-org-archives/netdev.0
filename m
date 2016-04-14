From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 01/15] wcn36xx: Clean up wcn36xx_smd_send_beacon
Date: Wed, 13 Apr 2016 17:59:35 -0700
Message-ID: <20160414005935.GO391@tuxbot>
References: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1459721806-11817-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun 03 Apr 15:16 PDT 2016, Bjorn Andersson wrote:

> From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Needed for coming improvements. No functional changes.
> 

Kalle, Eugene,

Have you picked up these patches yet?

As I was debugging a firmware crash when trying to start hostap on the
DragonBoard410c I found an issue with this patch, would like to know if
I should send an incremental patch or resend this one.

> Signed-off-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/wireless/ath/wcn36xx/hal.h |  7 +++++--
>  drivers/net/wireless/ath/wcn36xx/smd.c | 12 +++++-------
>  2 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
> index b947de0fb2e5..4fd77ccc2287 100644
> --- a/drivers/net/wireless/ath/wcn36xx/hal.h
> +++ b/drivers/net/wireless/ath/wcn36xx/hal.h
> @@ -51,8 +51,8 @@
>  #define WALN_HAL_STA_INVALID_IDX 0xFF
>  #define WCN36XX_HAL_BSS_INVALID_IDX 0xFF
>  
> -/* Default Beacon template size */
> -#define BEACON_TEMPLATE_SIZE 0x180
> +/* Default Beacon template size. */
> +#define BEACON_TEMPLATE_SIZE 0x17C

This affects the wcn36xx_hal_send_probe_resp_req_msg as well, making the
firmware on DB410c crash upon receiving the UPDATE_PROBE_RSP_TEMPLATE_REQ.

I think we should keep it at 0x180 and subtract sizeof(u32) from the
template size in send_beacon_req_msg, because the second length is
really part of the buffer.

>  
>  /* Param Change Bitmap sent to HAL */
>  #define PARAM_BCN_INTERVAL_CHANGED                      (1 << 0)
> @@ -2884,6 +2884,9 @@ struct update_beacon_rsp_msg {
>  struct wcn36xx_hal_send_beacon_req_msg {
>  	struct wcn36xx_hal_msg_header header;
>  
> +	/* length of the template + 6. Only qcom knows why */
> +	u32 beacon_length6;
> +
>  	/* length of the template. */
>  	u32 beacon_length;
>  
> diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
> index 74f56a81ad9a..ff3ed2461a69 100644
> --- a/drivers/net/wireless/ath/wcn36xx/smd.c
> +++ b/drivers/net/wireless/ath/wcn36xx/smd.c
> @@ -1380,19 +1380,17 @@ int wcn36xx_smd_send_beacon(struct wcn36xx *wcn, struct ieee80211_vif *vif,
>  	mutex_lock(&wcn->hal_mutex);
>  	INIT_HAL_MSG(msg_body, WCN36XX_HAL_SEND_BEACON_REQ);
>  
> -	/* TODO need to find out why this is needed? */
> -	msg_body.beacon_length = skb_beacon->len + 6;
> +	msg_body.beacon_length = skb_beacon->len;
> +	/* TODO need to find out why + 6 is needed */
> +	msg_body.beacon_length6 = msg_body.beacon_length + 6;

As far as I can tell from the prima code and SMD dumps this should be 4,
as in sizeof(u32). This looks like a mishap in the layering of prima.

>  
> -	if (BEACON_TEMPLATE_SIZE > msg_body.beacon_length) {
> -		memcpy(&msg_body.beacon, &skb_beacon->len, sizeof(u32));
> -		memcpy(&(msg_body.beacon[4]), skb_beacon->data,
> -		       skb_beacon->len);
> -	} else {
> +	if (msg_body.beacon_length > BEACON_TEMPLATE_SIZE) {
>  		wcn36xx_err("Beacon is to big: beacon size=%d\n",
>  			      msg_body.beacon_length);
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> +	memcpy(msg_body.beacon, skb_beacon->data, skb_beacon->len);
>  	memcpy(msg_body.bssid, vif->addr, ETH_ALEN);
>  
>  	/* TODO need to find out why this is needed? */

PS. I confirmed that the update_beacon_rsp_msg does not come with the
prepended length...for some reason.

Regards,
Bjorn
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
