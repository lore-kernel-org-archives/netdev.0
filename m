From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] cfg80211: Be able to set bss expire time at config
 stage.
Date: Mon, 22 May 2017 11:21:51 -0500
Message-ID: <1495470111.25557.9.camel@redhat.com>
References: <20170522160946.2057-1-enric.balletbo@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Dmitry Shmidt <dimitrysh@google.com>,
        helmut.schaa@googlemail.com
To: Enric Balletbo i Serra <enric.balletbo@collabora.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52770 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935367AbdEVQWA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 12:22:00 -0400
In-Reply-To: <20170522160946.2057-1-enric.balletbo@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-22 at 18:09 +0200, Enric Balletbo i Serra wrote:
> The IEEE80211_SCAN_RESULT_EXPIRE value was modified several times in
> the
> past. Initially was set at 10 seconds (2a51931192), then increased at
> 15
> seconds (09f97e0fc4) and finally to 30 seconds (f9616e0f88) to cover
> the
> use case when a station is having heavy uplink traffic. On some
> devices,
> like Chromebooks, this value is decreased to 7 seconds to avoid stall
> results, and other devices prefer set to 15 seconds.

Couldn't userspace just look at NL80211_BSS_SEEN_MS_AGO to filter and
create its own list?  Given that the kernel provides the information
userspace needs to figure out the age of a particular BSS, it doesn't
seem like there needs to be a kernel tunable for this.  Userspace can
already avoid stale results.

Also, different runtime situations might want different result ages,
which wouldn't be possible if the kernel had a hardcoded maximum. 
Furthermore, different userspace apps might be reading the same scan
list, and they might have different ideas about staleness.

Or perhaps I misunderstand the problem, which could well be the case.

Dan

> This simple patch tries to make the selection of this value a bit
> more
> flexible by being able to set the expire time at config stage. Most
> users
> can leave the default value set as 30 seconds, others can modify the
> value
> at config stage if they want lower or bigger values.
> 
> Signed-off-by: Enric Balletbo i Serra <enric.balletbo@collabora.com>
> ---
>  net/wireless/Kconfig | 11 +++++++++++
>  net/wireless/core.c  |  2 ++
>  net/wireless/core.h  |  1 +
>  net/wireless/scan.c  |  6 ++----
>  4 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
> index 6c60612..2a54e28 100644
> --- a/net/wireless/Kconfig
> +++ b/net/wireless/Kconfig
> @@ -29,6 +29,17 @@ config CFG80211
>  
>  	  When built as a module it will be called cfg80211.
>  
> +config CFG80211_SCAN_RESULT_EXPIRE
> +	int "Scan completion time" if CFG80211
> +	default 30
> +	---help---
> +	  This value is the time in seconds the mac80211 scan method
> needs
> +	  to finish. An expiration time to 30 seconds should be
> sufficient
> +	  for most cases but for some other cases we might be
> interested in
> +	  tweak this value.
> +
> +	  If unsure, leave the default of 30.
> +
>  config NL80211_TESTMODE
>  	bool "nl80211 testmode command"
>  	depends on CFG80211
> diff --git a/net/wireless/core.c b/net/wireless/core.c
> index 83ea164..2a5742c 100644
> --- a/net/wireless/core.c
> +++ b/net/wireless/core.c
> @@ -499,6 +499,8 @@ struct wiphy *wiphy_new_nm(const struct
> cfg80211_ops *ops, int sizeof_priv,
>  
>  	init_waitqueue_head(&rdev->dev_wait);
>  
> +	rdev->scan_result_expire =
> CONFIG_CFG80211_SCAN_RESULT_EXPIRE;
> +
>  	/*
>  	 * Initialize wiphy parameters to IEEE 802.11 MIB default
> values.
>  	 * Fragmentation and RTS threshold are disabled by default
> with the
> diff --git a/net/wireless/core.h b/net/wireless/core.h
> index 6e809325..6a8a164 100644
> --- a/net/wireless/core.h
> +++ b/net/wireless/core.h
> @@ -72,6 +72,7 @@ struct cfg80211_registered_device {
>  	struct rb_root bss_tree;
>  	u32 bss_generation;
>  	u32 bss_entries;
> +	unsigned int scan_result_expire;
>  	struct cfg80211_scan_request *scan_req; /* protected by RTNL
> */
>  	struct sk_buff *scan_msg;
>  	struct list_head sched_scan_req_list;
> diff --git a/net/wireless/scan.c b/net/wireless/scan.c
> index 14d5f0c..f0b55a9 100644
> --- a/net/wireless/scan.c
> +++ b/net/wireless/scan.c
> @@ -70,8 +70,6 @@ module_param(bss_entries_limit, int, 0644);
>  MODULE_PARM_DESC(bss_entries_limit,
>                   "limit to number of scan BSS entries (per wiphy,
> default 1000)");
>  
> -#define IEEE80211_SCAN_RESULT_EXPIRE	(30 * HZ)
> -
>  static void bss_free(struct cfg80211_internal_bss *bss)
>  {
>  	struct cfg80211_bss_ies *ies;
> @@ -476,7 +474,7 @@ void cfg80211_bss_age(struct
> cfg80211_registered_device *rdev,
>  
>  void cfg80211_bss_expire(struct cfg80211_registered_device *rdev)
>  {
> -	__cfg80211_bss_expire(rdev, jiffies -
> IEEE80211_SCAN_RESULT_EXPIRE);
> +	__cfg80211_bss_expire(rdev, jiffies - rdev-
> >scan_result_expire);
>  }
>  
>  const u8 *cfg80211_find_ie_match(u8 eid, const u8 *ies, int len,
> @@ -737,7 +735,7 @@ struct cfg80211_bss *cfg80211_get_bss(struct
> wiphy *wiphy,
>  		if (!is_valid_ether_addr(bss->pub.bssid))
>  			continue;
>  		/* Don't get expired BSS structs */
> -		if (time_after(now, bss->ts +
> IEEE80211_SCAN_RESULT_EXPIRE) &&
> +		if (time_after(now, bss->ts + rdev-
> >scan_result_expire) &&
>  		    !atomic_read(&bss->hold))
>  			continue;
>  		if (is_bss(&bss->pub, bssid, ssid, ssid_len)) {
