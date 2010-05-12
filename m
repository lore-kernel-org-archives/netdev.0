From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [ath5k-devel] [PATCH] [ath5k][leds] Ability to disable leds
 support. If leds support enabled do not force mac802.11 leds layer
 selection.
Date: Wed, 12 May 2010 11:48:56 -0400
Message-ID: <1273679336.10823.15.camel@mj>
References: <4bea1f81.09b6660a.746e.1c12@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	GeunSik Lim <geunsik.lim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Keng-Yu Lin <keng-yu.lin-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Shahar Or <shahar-ThuA2tnqEQ612v9G2T7xgg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Luca Verdesca <magooz-JapBdFJSX0s@public.gmane.org>
To: Dmytro Milinevskyy <milinevskyy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4bea1f81.09b6660a.746e.1c12-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-04-07 at 21:58 +0300, Dmytro Milinevskyy wrote:

> Here is the patch to disable ath5k leds support on build stage.
> However if the leds support was enabled do not force selection of 802.11 leds layer.

The idea is good, but the implementation could be improved.

There are too many preprocessor conditionals in your patch.

> +#ifdef CONFIG_ATH5K_LEDS
>  /*
>   * These match net80211 definitions (not used in
>   * mac80211).
> @@ -939,11 +940,7 @@ enum ath5k_power_mode {
>  #define AR5K_LED_AUTH	2 /*IEEE80211_S_AUTH*/
>  #define AR5K_LED_ASSOC	3 /*IEEE80211_S_ASSOC*/
>  #define AR5K_LED_RUN	4 /*IEEE80211_S_RUN*/

It should be OK to leave the constants defined even if they are not
used.

> +#ifdef CONFIG_ATH5K_LEDS
>  /* LED functions */
>  extern int ath5k_init_leds(struct ath5k_softc *sc);
>  extern void ath5k_led_enable(struct ath5k_softc *sc);
>  extern void ath5k_led_off(struct ath5k_softc *sc);
>  extern void ath5k_unregister_leds(struct ath5k_softc *sc);
> +#endif

You could add inline functions for the case when CONFIG_ATH5K_LEDS is
not defined.  That would avoid may conditionals in the code.

>  /* GPIO Functions */
> +#ifdef CONFIG_ATH5K_LEDS
>  extern void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state);
> +#endif

The same comment applies.

Also, there is nothing wrong with having an external declaration that is
not used in some particular configuration.

> +#ifdef CONFIG_ATH5K_LEDS
>  	/* turn on HW LEDs */
>  	ath5k_hw_set_ledstate(ah, AR5K_LED_INIT);
> +#endif

This is avoidable by having an inline ath5k_hw_set_ledstate() that does
nothing.

> +#ifdef CONFIG_ATH5K_LEDS
>  	struct ieee80211_hw *hw = pci_get_drvdata(to_pci_dev(dev));
>  	struct ath5k_softc *sc = hw->priv;
>  
>  	ath5k_led_off(sc);
> +#endif

Even this is avoidable if ath5k_led_off() does nothing.  gcc should be
smart enough to optimize out unneeded function calls.

> +#ifdef CONFIG_ATH5K_LEDS
>  /*
>   * State for LED triggers
>   */
>  struct ath5k_led
>  {
> +#ifdef CONFIG_LEDS_CLASS

I'm not sure this complexity is needed.  Are you going to support LEDs
if CONFIG_LEDS_CLASS is disabled?

> +#ifdef CONFIG_ATH5K_LEDS
>  	unsigned int		led_pin,	/* GPIO pin for driving LED */
>  				led_on;		/* pin setting for LED on */
> +#endif
>  
>  	struct tasklet_struct	restq;		/* reset tasklet */
>  
> @@ -164,7 +172,9 @@ struct ath5k_softc {
>  	spinlock_t		rxbuflock;
>  	u32			*rxlink;	/* link ptr in last RX desc */
>  	struct tasklet_struct	rxtq;		/* rx intr tasklet */
> +#ifdef CONFIG_ATH5K_LEDS
>  	struct ath5k_led	rx_led;		/* rx led */
> +#endif

You may want to group those fields together to make the code more
readable.

> --- a/drivers/net/wireless/ath/ath5k/led.c
> +++ b/drivers/net/wireless/ath/ath5k/led.c

I wonder if you could omit led.c completely in the Makefile.  If there
are some parts of led.c that are needed without CONFIG_ATH5K_LEDS, maybe
they belong elsewhere?

-- 
Regards,
Pavel Roskin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
