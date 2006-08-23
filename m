From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 02/3] d80211:  iwlist scan
Date: Wed, 23 Aug 2006 17:46:31 +0200
Message-ID: <20060823174631.42c19a2d@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075158.728615077@sipsolutions.net>
	<44EA501E.4010605@linux.intel.com>
	<44EA5180.2080701@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:914 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964988AbWHWPqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 11:46:34 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
In-Reply-To: <44EA5180.2080701@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 17:36:16 -0700, Mohamed Abbas wrote:
> This patch enhance iwlist scan to dispaly supported rate with readable 
> format. It also add a macro to convert channel to freq value. this macro 
> is needed in ieee80211_rx_bss_info. In 3945 we issues a host scan 
> command to perform scanning which will cause in setting the freq to the 
> wrong value.

Please (this apply also to your other patches):
- use more descriptive subject
- append Signed-off-by: line
- Cc: me on d80211 patches
- indent with tabs

> [...]
> --- a/net/d80211/ieee80211_sta.c
> +++ b/net/d80211/ieee80211_sta.c
> @@ -1329,6 +1329,11 @@ void ieee80211_rx_bss_list_deinit(struct
>  	}
>  }
>  
> +/* macro to convert channel to freq value */
> +#define ieee80211chan2mhz(x) \

#defined identifiers should be in upper case.

> +        (((x) <= 14) ? \
> +        (((x) == 14) ? 2484 : ((x) * 5) + 2407) : \
> +        ((x) + 1000) * 5)
>  
>  static void ieee80211_rx_bss_info(struct net_device *dev,
>  				  struct ieee80211_mgmt *mgmt,
> @@ -1547,18 +1552,7 @@ #endif
>  	bss->hw_mode = local->conf.phymode;
>  	bss->channel = channel;
>  	bss->freq = local->conf.freq;
> -	if (channel != local->conf.channel &&
> -	    (local->conf.phymode == MODE_IEEE80211G ||
> -	     local->conf.phymode == MODE_IEEE80211B) &&
> -	    channel >= 1 && channel <= 14) {
> -		static const int freq_list[] = {
> -			2412, 2417, 2422, 2427, 2432, 2437, 2442,
> -			2447, 2452, 2457, 2462, 2467, 2472, 2484
> -		};
> -		/* IEEE 802.11g/b mode can receive packets from neighboring
> -		 * channels, so map the channel into frequency. */
> -		bss->freq = freq_list[channel - 1];
> -	}
> +	bss->freq = ieee80211chan2mhz(channel);

This must depend on current phymode. No hackish macros trying to guess
phymode depending on channel number, please.

>  	bss->timestamp = timestamp;
>  	bss->last_update = jiffies;
>  	bss->rssi = rx_status->ssi;
> @@ -2724,16 +2719,33 @@ ieee80211_sta_scan_result(struct net_dev
>  		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
>  						  buf);
>  
> -		p = buf;
> -		p += sprintf(p, "supp_rates=");
> -		for (i = 0; i < bss->supp_rates_len; i++)
> -			p+= sprintf(p, "%02x", bss->supp_rates[i]);
> -		memset(&iwe, 0, sizeof(iwe));
> -		iwe.cmd = IWEVCUSTOM;
> -		iwe.u.data.length = strlen(buf);
> -		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
> -						  buf);
> -
> +		/* dispaly all support rates in readable format */
> +		if ((local->scan_flags & IEEE80211_SCAN_SUPP_RATE_INFO)) {

No need to have this in scan_flags. Just use this unconditionally and
drop the else part.

> +        		p = current_ev + IW_EV_LCP_LEN;
> +        		iwe.cmd = SIOCGIWRATE;
> +        		/* Those two flags are ignored... */
> +        		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
> +
> +                	for (i = 0; i < bss->supp_rates_len; i++) {
> +				iwe.u.bitrate.value = ((bss->supp_rates[i] & 
> +							      0x7f) * 500000);
> +				p = iwe_stream_add_value(current_ev, p, 
> +					      end_buf, &iwe, IW_EV_PARAM_LEN);
> +			}
> +        		/* Check if we added any rate */
> +	        	if((p - current_ev) > IW_EV_LCP_LEN)
> +                		current_ev = p;
> +		} else {
> +			p = buf;
> +			p += sprintf(p, "supp_rates=");
> +			for (i = 0; i < bss->supp_rates_len; i++)
> +				p+= sprintf(p, "%02x", bss->supp_rates[i]);
> +			memset(&iwe, 0, sizeof(iwe));
> +			iwe.cmd = IWEVCUSTOM;
> +			iwe.u.data.length = strlen(buf);
> +			current_ev = iwe_stream_add_point(current_ev, end_buf, 
> +						  &iwe, buf);
> +		}
>  		kfree(buf);
>  		break;
>  	} while (0);

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
