From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: do shared key auth in workqueue
Date: Wed, 12 Jul 2006 00:49:49 +0200
Message-ID: <200607120049.49601.mb@bu3sch.de>
References: <20060711221634.7B3A58B2E80@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:64407
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932225AbWGKWsK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 18:48:10 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060711221634.7B3A58B2E80@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 July 2006 00:16, you wrote:
> Johann Uhrmann reported a bcm43xx crash and Michael Buesch tracked it down
> to a problem with the new shared key auth code (recursive calls into the driver)
> 
> This patch (effectively Michael's patch with a couple of small modifications)
> solves the problem by sending the authentication challenge response frame
> from a workqueue entry.
> 
> I also removed a lone \n from the bcm43xx messages relating to authentication
> mode - this small change was previously discussed but not patched in.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> Acked-by: Johannes Berg <johannes@sipsolutions.net>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> 
> Index: linux/net/ieee80211/softmac/ieee80211softmac_auth.c
> ===================================================================
> --- linux.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
> +++ linux/net/ieee80211/softmac/ieee80211softmac_auth.c
> @@ -116,6 +116,16 @@ ieee80211softmac_auth_queue(void *data)
>  	kfree(auth);
>  }
>  
> +/* Sends a response to an auth challenge (for shared key auth). */
> +static void
> +ieee80211softmac_auth_challenge_response(void *_aq)
> +{
> +	struct ieee80211softmac_auth_queue_item *aq = _aq;
> +
> +	/* Send our response */
> +	ieee80211softmac_send_mgt_frame(aq->mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
> +}
> +
>  /* Handle the auth response from the AP
>   * This should be registered with ieee80211 as handle_auth 
>   */
> @@ -197,24 +207,30 @@ ieee80211softmac_auth_resp(struct net_de
>  		case IEEE80211SOFTMAC_AUTH_SHARED_CHALLENGE:
>  			/* Check to make sure we have a challenge IE */
>  			data = (u8 *)auth->info_element;
> -			if(*data++ != MFIE_TYPE_CHALLENGE){
> +			if (*data++ != MFIE_TYPE_CHALLENGE) {
>  				printkl(KERN_NOTICE PFX "Shared Key Authentication failed due to a missing challenge.\n");
>  				break;	
>  			}
>  			/* Save the challenge */
>  			spin_lock_irqsave(&mac->lock, flags);
>  			net->challenge_len = *data++; 	
> -			if(net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
> +			if (net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
>  				net->challenge_len = WLAN_AUTH_CHALLENGE_LEN;
> -			if(net->challenge != NULL)
> +			if (net->challenge != NULL)
>  				kfree(net->challenge);
>  			net->challenge = kmalloc(net->challenge_len, GFP_ATOMIC);
>  			memcpy(net->challenge, data, net->challenge_len);
>  			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
> -			spin_unlock_irqrestore(&mac->lock, flags);
>  
> -			/* Send our response */
> -			ieee80211softmac_send_mgt_frame(mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
> +			/* We reuse the work struct from the auth request here.
> +			 * It is safe to do so as each one is per-request, and
> +			 * at this point (dealing with authentication response)
> +			 * we have obviously already sent the initial auth
> +			 * request. */
> +			cancel_delayed_work(&aq->work);
> +			INIT_WORK(&aq->work, &ieee80211softmac_auth_challenge_response, (void *)aq);
> +			schedule_work(&aq->work);
> +			spin_unlock_irqrestore(&mac->lock, flags);
>  			return 0;
>  		case IEEE80211SOFTMAC_AUTH_SHARED_PASS:
>  			kfree(net->challenge);
> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3701,7 +3701,7 @@ static void bcm43xx_ieee80211_set_securi
>  	}
>  	if (sec->flags & SEC_AUTH_MODE) {
>  		secinfo->auth_mode = sec->auth_mode;
> -		dprintk(", .auth_mode = %d\n", sec->auth_mode);
> +		dprintk(", .auth_mode = %d", sec->auth_mode);
>  	}
>  	dprintk("\n");
>  	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
> 

-- 
Greetings Michael.
