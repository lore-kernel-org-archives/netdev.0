From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 05/16] wl1251: implement hardware ARP filtering
Date: Wed, 30 Oct 2013 12:28:54 +0100
Message-ID: <20131030112854.GB8204@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-6-git-send-email-pali.rohar@gmail.com>
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
In-Reply-To: <1382819655-30430-6-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> Update hardware ARP filter configuration on BSS_CHANGED_ARP_FILTER
> notification from mac80211.
> Ported from wl1271 driver.
> 
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>
> ---
>  drivers/net/wireless/ti/wl1251/acx.c  |   31 +++++++++++++++++++++++++++++++
>  drivers/net/wireless/ti/wl1251/acx.h  |   15 +++++++++++++++
>  drivers/net/wireless/ti/wl1251/main.c |   13 +++++++++++++
>  3 files changed, 59 insertions(+)
> 
> diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
> index cce50e2..9295090 100644
> --- a/drivers/net/wireless/ti/wl1251/acx.c
> +++ b/drivers/net/wireless/ti/wl1251/acx.c
> @@ -1062,6 +1062,37 @@ out:
>  	return ret;
>  }
>  
> +int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 address)
> +{
> +	struct wl1251_acx_arp_filter *acx;
> +	int ret;
> +
> +	wl1251_debug(DEBUG_ACX, "acx arp ip filter, enable: %d", enable);
> +
> +	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
> +	if (!acx) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}

I'd do "return -ENOMEM;" here. Trying to free NULL pointer is
unneccessary complication.

> +	acx->version = ACX_IPV4_VERSION;
> +	acx->enable = enable;
> +
> +	if (enable == true)

if (enable) would be C way of writing stuff.

> +		memcpy(acx->address, &address, ACX_IPV4_ADDR_SIZE);
> +
> +	ret = wl1251_cmd_configure(wl, ACX_ARP_IP_FILTER,
> +				   acx, sizeof(*acx));
> +	if (ret < 0) {
> +		wl1251_warning("failed to set arp ip filter: %d", ret);
> +		goto out;
> +	}
> +
> +out:

No need for the out label now.

> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
> index 46a2494..9752745 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -1078,6 +1078,19 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
>  		}
>  	}
>  
> +	if (changed & BSS_CHANGED_ARP_FILTER) {
> +		__be32 addr = bss_conf->arp_addr_list[0];
> +		WARN_ON(wl->bss_type != BSS_TYPE_STA_BSS);
> +
> +		if (bss_conf->arp_addr_cnt == 1 && bss_conf->assoc)
> +			ret = wl1251_acx_arp_ip_filter(wl, true, addr);
> +		else
> +			ret = wl1251_acx_arp_ip_filter(wl, false, addr);


  		enable = bss_conf->arp_addr_cnt == 1 && bss_conf->assoc;
		ret = wl1251_acx_arp_ip_filter(wl, enable, addr);

?

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
