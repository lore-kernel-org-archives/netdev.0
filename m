From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: Frequent spurious tx_timeouts for libertas
Date: Tue, 03 May 2011 17:47:40 +0100
Message-ID: <1304441260.2873.8.camel@bwh-desktop>
References: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg@mail.gmail.com>
	 <1304303082.2833.159.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1304303082.2833.159.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-02 at 03:24 +0100, Ben Hutchings wrote:
[...]
> And now, for the specific case of libertas:
> 
> It appears that libertas reports carrier off (link down) while scanning,
> so that should mean the watchdog does not fire.  However:
> 
> 1. The watchdog will only check the current link state, which might be
> up again when it runs.
[...]

However, netif_carrier_on() will reset the watchdog timer, so the link
really does have to be reported up continuously for 5 seconds before the
watchdog will fire.

There is a small race condition though...

void netif_carrier_on(struct net_device *dev)
{
	if (test_and_clear_bit(__LINK_STATE_NOCARRIER, &dev->state)) {
/*
 * If the device is running and the link has been down for exactly
 * dev->watchdog_timeo ticks, the watchdog can fire now.
 */
		if (dev->reg_state == NETREG_UNINITIALIZED)
			return;
		linkwatch_fire_event(dev);
		if (netif_running(dev))
/*
 * The watchdog timer is reset here:
 */
			__netdev_watchdog_up(dev);
	}
}

However, given the timing of channel scanning that you described, I
don't think this would explain the watchdog firing for libertas.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
