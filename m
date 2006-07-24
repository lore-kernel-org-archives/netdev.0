From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH wireless-dev 2/5] orinoco: Switch to d80211.h
Date: Mon, 24 Jul 2006 00:01:34 -0400
Message-ID: <44C4461E.2050909@garzik.org>
References: <200607232040.37823.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, proski@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:4520 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751398AbWGXEBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 00:01:41 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607232040.37823.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> orinoco: Switch to d80211.h
> 
> This patch "converts" the orinoco driver to use d80211.h instead of
> ieee80211.h. It also copies the IEEE80211_DATA_LEN definition to
> d80211.h for use by the stack and drivers.
> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>
> ---
> 
>  drivers/net/wireless/orinoco.c |   37 +++++++++++++++++++------------------
>  include/net/d80211.h           |    9 +++++++++
>  net/d80211/ieee80211.c         |    4 ++--
>  3 files changed, 30 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
> index d6ed578..bdc8d37 100644
> --- a/drivers/net/wireless/orinoco.c
> +++ b/drivers/net/wireless/orinoco.c
> @@ -83,8 +83,9 @@ #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/ethtool.h>
>  #include <linux/wireless.h>
> +#include <linux/if_arp.h>
>  #include <net/iw_handler.h>
> -#include <net/ieee80211.h>
> +#include <net/d80211.h>
>  
>  #include "hermes_rid.h"
>  #include "orinoco.h"
> @@ -400,7 +401,7 @@ static int orinoco_change_mtu(struct net
>  	if ( (new_mtu < ORINOCO_MIN_MTU) || (new_mtu > ORINOCO_MAX_MTU) )
>  		return -EINVAL;
>  
> -	if ( (new_mtu + ENCAPS_OVERHEAD + IEEE80211_HLEN) >
> +	if ( (new_mtu + ENCAPS_OVERHEAD + sizeof(struct ieee80211_hdr)) >
>  	     (priv->nicbuf_size - ETH_HLEN) )
>  		return -EINVAL;
>  
> @@ -720,29 +721,29 @@ static void orinoco_rx_monitor(struct ne
>  
>  	/* Determine the size of the header and the data */
>  	fc = le16_to_cpu(desc->frame_ctl);
> -	switch (fc & IEEE80211_FCTL_FTYPE) {
> -	case IEEE80211_FTYPE_DATA:
> -		if ((fc & IEEE80211_FCTL_TODS)
> -		    && (fc & IEEE80211_FCTL_FROMDS))
> +	switch (WLAN_FC_GET_TYPE(fc)) {
> +	case WLAN_FC_TYPE_DATA:
> +		if ((fc & WLAN_FC_TODS)
> +		    && (fc & WLAN_FC_FROMDS))
>  			hdrlen = 30;
>  		else
>  			hdrlen = 24;
>  		datalen = len;
>  		break;
> -	case IEEE80211_FTYPE_MGMT:
> +	case WLAN_FC_TYPE_MGMT:
>  		hdrlen = 24;
>  		datalen = len;
>  		break;
> -	case IEEE80211_FTYPE_CTL:
> -		switch (fc & IEEE80211_FCTL_STYPE) {
> -		case IEEE80211_STYPE_PSPOLL:
> -		case IEEE80211_STYPE_RTS:
> -		case IEEE80211_STYPE_CFEND:
> -		case IEEE80211_STYPE_CFENDACK:
> +	case WLAN_FC_TYPE_CTRL:
> +		switch (WLAN_FC_GET_STYPE(fc)) {
> +		case WLAN_FC_STYPE_PSPOLL:
> +		case WLAN_FC_STYPE_RTS:
> +		case WLAN_FC_STYPE_CFEND:
> +		case WLAN_FC_STYPE_CFENDACK:
>  			hdrlen = 16;
>  			break;
> -		case IEEE80211_STYPE_CTS:
> -		case IEEE80211_STYPE_ACK:
> +		case WLAN_FC_STYPE_CTS:
> +		case WLAN_FC_STYPE_ACK:
>  			hdrlen = 10;
>  			break;
>  		}
> @@ -908,7 +909,7 @@ static void __orinoco_ev_rx(struct net_d
>  		hdr->h_proto = htons(length);
>  	}
>  	memcpy(hdr->h_dest, desc.addr1, ETH_ALEN);
> -	if (fc & IEEE80211_FCTL_FROMDS)
> +	if (fc & WLAN_FC_FROMDS)
>  		memcpy(hdr->h_source, desc.addr3, ETH_ALEN);
>  	else
>  		memcpy(hdr->h_source, desc.addr2, ETH_ALEN);
> @@ -917,7 +918,7 @@ static void __orinoco_ev_rx(struct net_d
>  	skb->dev = dev;
>  	skb->protocol = eth_type_trans(skb, dev);
>  	skb->ip_summed = CHECKSUM_NONE;
> -	if (fc & IEEE80211_FCTL_TODS)
> +	if (fc & WLAN_FC_TODS)

Rather than have a great symbol renaming, it seems better to change the 
out-of-tree stuff to match the in-tree stuff.

	Jeff



