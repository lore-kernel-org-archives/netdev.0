From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC/RFT 4/4] mac80211: use multi-queue master netdevice
Date: Wed, 30 Apr 2008 12:39:04 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904FE144F@orsmsx414.amr.corp.intel.com>
References: <20080430124055.091382000@sipsolutions.net> <20080430130051.397094000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Rindjunsky, Ron" <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Ivo van Doorn" <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080430130051.397094000-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> --- everything.orig/net/mac80211/util.c	2008-04-30 
> 14:02:31.000000000 +0200
> +++ everything/net/mac80211/util.c	2008-04-30 
> 14:20:06.000000000 +0200
> @@ -323,18 +323,28 @@ __le16 ieee80211_ctstoself_duration(stru
>  }
>  EXPORT_SYMBOL(ieee80211_ctstoself_duration);
>  
> +void ieee80211_start_queue(struct ieee80211_hw *hw, int queue)
> +{
> +	struct ieee80211_local *local = hw_to_local(hw);
> +#ifdef CONFIG_MAC80211_QOS
> +	netif_start_subqueue(local->mdev, queue);
> +#else
> +	WARN_ON(queue != 0);
> +	netif_start_queue(local->mdev);
> +#endif
> +}
> +EXPORT_SYMBOL(ieee80211_start_queue);
> +

I would suggest that you enable the netdev feature flag for
NETIF_F_MULTI_QUEUE on devices when you create them.  That way you can
have things like ieee80211_start_queue() key on that instead of a
compile-time option, in case wireless devices come along that won't
support multiple queues, if that's possible.  So something like this:

+void ieee80211_start_queue(struct ieee80211_hw *hw, int queue)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+	if (netif_is_multiqueue(local->mdev) {
+		netif_start_subqueue(local->mdev, queue);
+	} else {
+		WARN_ON(queue != 0);
+		netif_start_queue(local->mdev);
+	}
+}
+EXPORT_SYMBOL(ieee80211_start_queue);
+

If you think this is a decent idea, I'd suggest that any function that
has a compile-time check for multiqueue being changed to use the runtime
check.  Then in your device setup, where you call netdev_alloc_mq(),
there you set the flag NETIF_F_MULTI_QUEUE based on the device features.

Other than that, this patch looks great.  Exciting to see this starting
to take flight.

Cheers,
-PJ Waskiewicz
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
