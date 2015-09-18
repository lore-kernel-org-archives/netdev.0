From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2 v2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Fri, 18 Sep 2015 11:54:35 -0500
Message-ID: <1442595275.14759.1.camel@redhat.com>
References: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-15 at 17:18 +0200, Ondrej Zary wrote:
> IW_AUTH_ALG_OPEN_SYSTEM is ambiguous in set_auth for WEP as
> wpa_supplicant uses it for both no encryption and WEP open system.
> Cache the last mode set (only of these two) and use it here.
> 
> This allows wpa_supplicant to work with unencrypted APs.

It seems like this will work; but to make the code clearer, define a
small static function like:

static inline void set_auth_type(struct airo_info *local, int auth_type)
{
	local->config.authType = local->last_auth = auth_type;
}

and call that from everywhere that you're currently setting authType and
last_auth, except for airo_set_auth().  Less code and less probability
to forget to set last_auth in the future.

Dan

> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>  drivers/net/wireless/airo.c |   33 ++++++++++++++++++++++++---------
>  1 file changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index d0c97c2..a8f2767 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -1237,6 +1237,7 @@ struct airo_info {
>  
>  	int			wep_capable;
>  	int			max_wep_idx;
> +	int			last_auth;
>  
>  	/* WPA-related stuff */
>  	unsigned int bssListFirst;
> @@ -3863,6 +3864,7 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
>  		}
>  		ai->config.opmode = adhoc ? MODE_STA_IBSS : MODE_STA_ESS;
>  		ai->config.authType = AUTH_OPEN;
> +		ai->last_auth = AUTH_OPEN;
>  		ai->config.modulation = MOD_CCK;
>  
>  		if (le16_to_cpu(cap_rid.len) >= sizeof(cap_rid) &&
> @@ -6370,6 +6372,7 @@ static int airo_set_encode(struct net_device *dev,
>  		if((index == current_index) && (key.len > 0) &&
>  		   (local->config.authType == AUTH_OPEN)) {
>  			local->config.authType = AUTH_ENCRYPT;
> +			local->last_auth = AUTH_ENCRYPT;
>  		}
>  	} else {
>  		/* Do we want to just set the transmit key index ? */
> @@ -6389,12 +6392,16 @@ static int airo_set_encode(struct net_device *dev,
>  		}
>  	}
>  	/* Read the flags */
> -	if(dwrq->flags & IW_ENCODE_DISABLED)
> +	if (dwrq->flags & IW_ENCODE_DISABLED) {
>  		local->config.authType = AUTH_OPEN;	// disable encryption
> +		local->last_auth = AUTH_OPEN;
> +	}
>  	if(dwrq->flags & IW_ENCODE_RESTRICTED)
>  		local->config.authType = AUTH_SHAREDKEY;	// Only Both
> -	if(dwrq->flags & IW_ENCODE_OPEN)
> +	if (dwrq->flags & IW_ENCODE_OPEN) {
>  		local->config.authType = AUTH_ENCRYPT;	// Only Wep
> +		local->last_auth = AUTH_ENCRYPT;
> +	}
>  	/* Commit the changes to flags if needed */
>  	if (local->config.authType != currentAuthType)
>  		set_bit (FLAG_COMMIT, &local->flags);
> @@ -6549,12 +6556,16 @@ static int airo_set_encodeext(struct net_device *dev,
>  	}
>  
>  	/* Read the flags */
> -	if(encoding->flags & IW_ENCODE_DISABLED)
> +	if (encoding->flags & IW_ENCODE_DISABLED) {
>  		local->config.authType = AUTH_OPEN;	// disable encryption
> +		local->last_auth = AUTH_OPEN;
> +	}
>  	if(encoding->flags & IW_ENCODE_RESTRICTED)
>  		local->config.authType = AUTH_SHAREDKEY;	// Only Both
> -	if(encoding->flags & IW_ENCODE_OPEN)
> +	if (encoding->flags & IW_ENCODE_OPEN) {
>  		local->config.authType = AUTH_ENCRYPT;	// Only Wep
> +		local->last_auth = AUTH_ENCRYPT;
> +	}
>  	/* Commit the changes to flags if needed */
>  	if (local->config.authType != currentAuthType)
>  		set_bit (FLAG_COMMIT, &local->flags);
> @@ -6658,10 +6669,13 @@ static int airo_set_auth(struct net_device *dev,
>  	case IW_AUTH_DROP_UNENCRYPTED:
>  		if (param->value) {
>  			/* Only change auth type if unencrypted */
> -			if (currentAuthType == AUTH_OPEN)
> +			if (currentAuthType == AUTH_OPEN) {
>  				local->config.authType = AUTH_ENCRYPT;
> +				local->last_auth = AUTH_ENCRYPT;
> +			}
>  		} else {
>  			local->config.authType = AUTH_OPEN;
> +			local->last_auth = AUTH_OPEN;
>  		}
>  
>  		/* Commit the changes to flags if needed */
> @@ -6670,13 +6684,14 @@ static int airo_set_auth(struct net_device *dev,
>  		break;
>  
>  	case IW_AUTH_80211_AUTH_ALG: {
> -			/* FIXME: What about AUTH_OPEN?  This API seems to
> -			 * disallow setting our auth to AUTH_OPEN.
> -			 */
>  			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
>  				local->config.authType = AUTH_SHAREDKEY;
>  			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> -				local->config.authType = AUTH_ENCRYPT;
> +				/* We don't know here if WEP open system or
> +				 * unencrypted mode was requested - so use the
> +				 * last mode (of these two) used last time
> +				 */
> +				local->config.authType = local->last_auth;
>  			} else
>  				return -EINVAL;
>  
