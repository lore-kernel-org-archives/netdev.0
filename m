From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 1/3] ps3: gelic: scan_lock semaphore to mutex
Date: Tue, 27 May 2008 16:24:31 +0900
Message-ID: <20080527161710.0149.40F06B3A@sm.sony.co.jp>
References: <20080522195404.061391772@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matthew-Ztpu424NOJ8@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Walker <dwalker-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080522195404.061391772-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added CC: linux-wireless

On Thu, 22 May 2008 00:00:01 -0700
Daniel Walker <dwalker-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org> wrote:

> Signed-off-by: Daniel Walker <dwalker-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
> 

patches #1 - #3:

Acked-by: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>

> ---
>  drivers/net/ps3_gelic_wireless.c |   18 +++++++++---------
>  drivers/net/ps3_gelic_wireless.h |    2 +-
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> Index: linux-2.6.25/drivers/net/ps3_gelic_wireless.c
> ===================================================================
> --- linux-2.6.25.orig/drivers/net/ps3_gelic_wireless.c
> +++ linux-2.6.25/drivers/net/ps3_gelic_wireless.c
> @@ -695,7 +695,7 @@ static int gelic_wl_get_scan(struct net_
>  	unsigned long this_time = jiffies;
>  
>  	pr_debug("%s: <-\n", __func__);
> -	if (down_interruptible(&wl->scan_lock))
> +	if (mutex_lock_interruptible(&wl->scan_lock))
>  		return -EAGAIN;
>  
>  	switch (wl->scan_stat) {
> @@ -733,7 +733,7 @@ static int gelic_wl_get_scan(struct net_
>  	wrqu->data.length = ev - extra;
>  	wrqu->data.flags = 0;
>  out:
> -	up(&wl->scan_lock);
> +	mutex_unlock(&wl->scan_lock);
>  	pr_debug("%s: -> %d %d\n", __func__, ret, wrqu->data.length);
>  	return ret;
>  }
> @@ -1554,7 +1554,7 @@ static int gelic_wl_start_scan(struct ge
>  	int ret = 0;
>  
>  	pr_debug("%s: <- always=%d\n", __func__, always_scan);
> -	if (down_interruptible(&wl->scan_lock))
> +	if (mutex_lock_interruptible(&wl->scan_lock))
>  		return -ERESTARTSYS;
>  
>  	/*
> @@ -1588,7 +1588,7 @@ static int gelic_wl_start_scan(struct ge
>  	}
>  	kfree(cmd);
>  out:
> -	up(&wl->scan_lock);
> +	mutex_unlock(&wl->scan_lock);
>  	pr_debug("%s: ->\n", __func__);
>  	return ret;
>  }
> @@ -1610,7 +1610,7 @@ static void gelic_wl_scan_complete_event
>  	DECLARE_MAC_BUF(mac);
>  
>  	pr_debug("%s:start\n", __func__);
> -	down(&wl->scan_lock);
> +	mutex_lock(&wl->scan_lock);
>  
>  	if (wl->scan_stat != GELIC_WL_SCAN_STAT_SCANNING) {
>  		/*
> @@ -1727,7 +1727,7 @@ static void gelic_wl_scan_complete_event
>  			    NULL);
>  out:
>  	complete(&wl->scan_done);
> -	up(&wl->scan_lock);
> +	mutex_unlock(&wl->scan_lock);
>  	pr_debug("%s:end\n", __func__);
>  }
>  
> @@ -2282,7 +2282,7 @@ static void gelic_wl_assoc_worker(struct
>  	wait_for_completion(&wl->scan_done);
>  
>  	pr_debug("%s: scan done\n", __func__);
> -	down(&wl->scan_lock);
> +	mutex_lock(&wl->scan_lock);
>  	if (wl->scan_stat != GELIC_WL_SCAN_STAT_GOT_LIST) {
>  		gelic_wl_send_iwap_event(wl, NULL);
>  		pr_info("%s: no scan list. association failed\n", __func__);
> @@ -2302,7 +2302,7 @@ static void gelic_wl_assoc_worker(struct
>  	if (ret)
>  		pr_info("%s: association failed %d\n", __func__, ret);
>  scan_lock_out:
> -	up(&wl->scan_lock);
> +	mutex_unlock(&wl->scan_lock);
>  out:
>  	up(&wl->assoc_stat_lock);
>  }
> @@ -2431,7 +2431,7 @@ static struct net_device *gelic_wl_alloc
>  
>  	INIT_DELAYED_WORK(&wl->event_work, gelic_wl_event_worker);
>  	INIT_DELAYED_WORK(&wl->assoc_work, gelic_wl_assoc_worker);
> -	init_MUTEX(&wl->scan_lock);
> +	mutex_init(&wl->scan_lock);
>  	init_MUTEX(&wl->assoc_stat_lock);
>  
>  	init_completion(&wl->scan_done);
> Index: linux-2.6.25/drivers/net/ps3_gelic_wireless.h
> ===================================================================
> --- linux-2.6.25.orig/drivers/net/ps3_gelic_wireless.h
> +++ linux-2.6.25/drivers/net/ps3_gelic_wireless.h
> @@ -241,7 +241,7 @@ enum gelic_wl_assoc_state {
>  #define GELIC_WEP_KEYS 4
>  struct gelic_wl_info {
>  	/* bss list */
> -	struct semaphore scan_lock;
> +	struct mutex scan_lock;
>  	struct list_head network_list;
>  	struct list_head network_free_list;
>  	struct gelic_wl_scan_info *networks;
> 
> -- 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Masakazu Mokuno

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
