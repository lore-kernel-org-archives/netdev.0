From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/2]d80211: fix wpa_supplicant reassoc problem
Date: Wed, 30 Aug 2006 18:57:10 +0200
Message-ID: <20060830185710.2f6b300f@griffin.suse.cz>
References: <1156494728.21483.12.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:22244 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751055AbWH3Q5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 12:57:12 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1156494728.21483.12.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006 16:32:08 +0800, Hong Liu wrote:
> After key negotiation completed using wpa_supplicant, wpa_supplicant
> can't reassoc with the AP if we reboot the AP. It always fails at the
> 4-way handshake.
> The problem is the key info is not cleared correctly. Thus when
> wpa_supplicant send the EAPOL-KEY packet, the d80211 stack finds the old
> key and uses it to encrypt the packet.
> 
> The patch removes the sta_info when we disassociate with AP.

Please:
- add proper Signed-off-by line
- do not send patches as an attachment
- Cc: John Linville <linville@tuxdriver.com> as well as me on d80211
  patches

> diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
> index 8caf352..2144b34 100644
> --- a/net/d80211/ieee80211_sta.c
> +++ b/net/d80211/ieee80211_sta.c
> @@ -739,6 +739,14 @@ static void ieee80211_associated(struct 
>  		wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
>  		mod_timer(&ifsta->timer,
>  			  jiffies + IEEE80211_MONITORING_INTERVAL + 30 * HZ);
> +
> +		sta = sta_info_get(local, ifsta->bssid);
> +		if (sta) {
> +			sta_info_free(sta, 0);
> +			sta_info_put(sta);
> +		}
> +
> +		ifsta->probereq_poll = 0;

Wouldn't it be better to move this into the 'else' branch of previous
'if' statement (i.e. just before sta_info_put call in the
ieee80211_associated function)?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
