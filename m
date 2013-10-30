From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 08/16] wl1251: implement multicast address filtering
Date: Wed, 30 Oct 2013 12:41:44 +0100
Message-ID: <20131030114144.GB8763@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-9-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382819655-30430-9-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> Port multicast address filtering from wl1271 driver.
> It sets up the hardware multicast address filter in configure_filter() with
> addresses supplied through prepare_multicast().

> +static u64 wl1251_op_prepare_multicast(struct ieee80211_hw *hw,
> +				       struct netdev_hw_addr_list *mc_list)
> +{
> +	struct wl1251_filter_params *fp;
> +	struct netdev_hw_addr *ha;
> +	struct wl1251 *wl = hw->priv;
> +
> +	if (unlikely(wl->state == WL1251_STATE_OFF))
> +		return 0;
> +
> +	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
> +	if (!fp) {
> +		wl1251_error("Out of memory setting filters.");
> +		return 0;
> +	}

So if there's not enough memory, we return 0.

> +	/* update multicast filtering parameters */
> +	fp->mc_list_length = 0;
> +	if (netdev_hw_addr_list_count(mc_list) > ACX_MC_ADDRESS_GROUP_MAX) {
> +		fp->enabled = false;
> +	} else {
> +		fp->enabled = true;
> +		netdev_hw_addr_list_for_each(ha, mc_list) {
> +			memcpy(fp->mc_list[fp->mc_list_length],
> +					ha->addr, ETH_ALEN);
> +			fp->mc_list_length++;
> +		}
> +	}
> +
> +	return (u64)(unsigned long)fp;
> +}

Hiding pointers into u64 is not exactly nice, but I guess that's how
interface is designed? :-(.

> @@ -737,6 +779,15 @@ static void wl1251_op_configure_filter(struct ieee80211_hw *hw,
>  	if (ret < 0)
>  		goto out;
>  
> +	if (*total & FIF_ALLMULTI || *total & FIF_PROMISC_IN_BSS)
> +		ret = wl1251_acx_group_address_tbl(wl, false, NULL, 0);
> +	else if (fp)
> +		ret = wl1251_acx_group_address_tbl(wl, fp->enabled,
> +						   fp->mc_list,
> +						     	fp->mc_list_length);

Is it correct not to call anything in !fp case (for example because we
were out of memory?)

> +	if (ret < 0)
> +		goto out;
> +
>  	/* send filters to firmware */
>  	wl1251_acx_rx_config(wl, wl->rx_config, wl->rx_filter);
>  
> @@ -744,6 +795,7 @@ static void wl1251_op_configure_filter(struct ieee80211_hw *hw,
>  
>  out:
>  	mutex_unlock(&wl->mutex);
> +	kfree(fp);
>  }

Umm, this is interesting. Who frees the memory in the success case?

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
