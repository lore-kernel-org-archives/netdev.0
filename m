From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH wireless-dev 5/5] airo: Switch to d80211.h
Date: Sun, 23 Jul 2006 23:59:49 -0400
Message-ID: <44C445B5.1030300@garzik.org>
References: <200607232050.32467.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:1448 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751396AbWGXEAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 00:00:04 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607232050.32467.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> airo: Switch to d80211.h
> 
> This patch "converts" the airo driver to use d80211.h instead of
> ieee80211.h. It also adds struct ieee80211_info_element and
> modifies d80211 to use that.
> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>
> ---
> 
>  drivers/net/wireless/airo.c |   15 ++++----
>  include/net/d80211.h        |    6 +++
>  net/d80211/ieee80211_sta.c  |   85 +++++++++++++++++++++----------------------
>  3 files changed, 54 insertions(+), 52 deletions(-)
> 
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index a4dd139..c08767a 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -46,7 +46,8 @@ #include <linux/if_arp.h>
>  #include <linux/ioport.h>
>  #include <linux/pci.h>
>  #include <asm/uaccess.h>
> -#include <net/ieee80211.h>
> +#include <net/d80211.h>
> +#include <net/d80211_mgmt.h>
>  
>  #include "airo.h"
>  
> @@ -7317,31 +7318,29 @@ static inline char *airo_translate_scan(
>  			}
>  
>  			switch (info_element->id) {
> -			case MFIE_TYPE_SSID:
> +			case WLAN_EID_SSID:
>  				/* Two zero-length SSID elements
>  				 * mean we're done parsing elements */
>  				if (!info_element->len)
>  					num_null_ies++;
>  				break;
>  
> -			case MFIE_TYPE_GENERIC:
> +			case WLAN_EID_GENERIC:
>  				if (info_element->len >= 4 &&
>  				    info_element->data[0] == 0x00 &&
>  				    info_element->data[1] == 0x50 &&
>  				    info_element->data[2] == 0xf2 &&
>  				    info_element->data[3] == 0x01) {
>  					iwe.cmd = IWEVGENIE;
> -					iwe.u.data.length = min(info_element->len + 2,
> -								  MAX_WPA_IE_LEN);
> +					iwe.u.data.length = min(info_element->len + 2, 64);

nak:  converts named constant to magic number


>  					current_ev = iwe_stream_add_point(current_ev, end_buf,
>  							&iwe, (char *) info_element);
>  				}
>  				break;
>  
> -			case MFIE_TYPE_RSN:
> +			case WLAN_EID_RSN:
>  				iwe.cmd = IWEVGENIE;
> -				iwe.u.data.length = min(info_element->len + 2,
> -							  MAX_WPA_IE_LEN);
> +				iwe.u.data.length = min(info_element->len + 2, 64);

ditto


>  				current_ev = iwe_stream_add_point(current_ev, end_buf,
>  						&iwe, (char *) info_element);
>  				break;
> diff --git a/include/net/d80211.h b/include/net/d80211.h
> index 6bf1b08..10ef570 100644
> --- a/include/net/d80211.h
> +++ b/include/net/d80211.h
> @@ -977,6 +977,12 @@ struct ieee80211_hdr {
>  	u8 addr4[6];
>  } __attribute__ ((packed));
>  
> +struct ieee80211_info_element {
> +	u8 id;
> +	u8 len;
> +	u8 data[0];
> +} __attribute__ ((packed));
> +
>  /* return a pointer to the source address (SA) */
>  static inline u8 *ieee80211_get_SA(struct ieee80211_hdr *hdr)
>  {
> diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
> index b0cfff1..d206b16 100644
> --- a/net/d80211/ieee80211_sta.c
> +++ b/net/d80211/ieee80211_sta.c
> @@ -110,91 +110,88 @@ static ParseRes ieee802_11_parse_elems(u
>  				       struct ieee802_11_elems *elems)
>  {
>  	size_t left = len;
> -	u8 *pos = start;
> +	struct ieee80211_info_element *info = (struct ieee80211_info_element *) start;
>  	int unknown = 0;
>  
>  	memset(elems, 0, sizeof(*elems));
>  
>  	while (left >= 2) {
> -		u8 id, elen;
> -
> -		id = *pos++;
> -		elen = *pos++;
>  		left -= 2;
>  
> -		if (elen > left) {
> +		if (info->len > left) {
>  #if 0
>  			if (net_ratelimit())
>  				printk(KERN_DEBUG "IEEE 802.11 element parse "
>  				       "failed (id=%d elen=%d left=%d)\n",
> -				       id, elen, left);
> +				       info->id, info->len, left);
>  #endif
>  			return ParseFailed;
>  		}
>  
> -		switch (id) {
> +		switch (info->id) {
>  		case WLAN_EID_SSID:
> -			elems->ssid = pos;
> -			elems->ssid_len = elen;
> +			elems->ssid = info->data;
> +			elems->ssid_len = info->len;
>  			break;
>  		case WLAN_EID_SUPP_RATES:
> -			elems->supp_rates = pos;
> -			elems->supp_rates_len = elen;
> +			elems->supp_rates = info->data;
> +			elems->supp_rates_len = info->len;
>  			break;
>  		case WLAN_EID_FH_PARAMS:
> -			elems->fh_params = pos;
> -			elems->fh_params_len = elen;
> +			elems->fh_params = info->data;
> +			elems->fh_params_len = info->len;
>  			break;
>  		case WLAN_EID_DS_PARAMS:
> -			elems->ds_params = pos;
> -			elems->ds_params_len = elen;
> +			elems->ds_params = info->data;
> +			elems->ds_params_len = info->len;
>  			break;
>  		case WLAN_EID_CF_PARAMS:
> -			elems->cf_params = pos;
> -			elems->cf_params_len = elen;
> +			elems->cf_params = info->data;
> +			elems->cf_params_len = info->len;
>  			break;
>  		case WLAN_EID_TIM:
> -			elems->tim = pos;
> -			elems->tim_len = elen;
> +			elems->tim = info->data;
> +			elems->tim_len = info->len;
>  			break;
>  		case WLAN_EID_IBSS_PARAMS:
> -			elems->ibss_params = pos;
> -			elems->ibss_params_len = elen;
> +			elems->ibss_params = info->data;
> +			elems->ibss_params_len = info->len;
>  			break;
>  		case WLAN_EID_CHALLENGE:
> -			elems->challenge = pos;
> -			elems->challenge_len = elen;
> +			elems->challenge = info->data;
> +			elems->challenge_len = info->len;
>  			break;
>  		case WLAN_EID_WPA:
> -			if (elen >= 4 && pos[0] == 0x00 && pos[1] == 0x50 &&
> -			    pos[2] == 0xf2) {
> +			if (info->len >= 4 && info->data[0] == 0x00 &&
> +			    info->data[1] == 0x50 && info->data[2] == 0xf2) {
>  				/* Microsoft OUI (00:50:F2) */
> -				if (pos[3] == 1) {
> +				if (info->data[3] == 1) {
>  					/* OUI Type 1 - WPA IE */
> -					elems->wpa = pos;
> -					elems->wpa_len = elen;
> -				} else if (elen >= 5 && pos[3] == 2) {
> -					if (pos[4] == 0) {
> -						elems->wmm_info = pos;
> -						elems->wmm_info_len = elen;
> -					} else if (pos[4] == 1) {
> -						elems->wmm_param = pos;
> -						elems->wmm_param_len = elen;
> +					elems->wpa = info->data;
> +					elems->wpa_len = info->len;
> +				} else if (info->len >= 5 &&
> +					   info->data[3] == 2) {
> +					if (info->data[4] == 0) {
> +						elems->wmm_info = info->data;
> +						elems->wmm_info_len = info->len;
> +					} else if (info->data[4] == 1) {
> +						elems->wmm_param = info->data;
> +						elems->wmm_param_len = info->len;
>  					}
>  				}
>  			}
>  			break;
>  		case WLAN_EID_RSN:
> -			elems->rsn = pos;
> -			elems->rsn_len = elen;
> +			elems->rsn = info->data;
> +			elems->rsn_len = info->len;
>  			break;
>  		case WLAN_EID_ERP_INFO:
> -			elems->erp_info = pos;
> -			elems->erp_info_len = elen;
> +			elems->erp_info = info->data;
> +			elems->erp_info_len = info->len;
>  			break;
>  		case WLAN_EID_EXT_SUPP_RATES:
> -			elems->ext_supp_rates = pos;
> -			elems->ext_supp_rates_len = elen;
> +			elems->ext_supp_rates = info->data;
> +			elems->ext_supp_rates_len = info->len;

A lot of this patch would go away, if you simply assigned 'pos' and 
'elen' local variables to values info->data and info->len, before all 
these assignments.

	Jeff


