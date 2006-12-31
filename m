From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-d80211: Interrogate hardware-enable switch and
	update LEDs
Date: Sun, 31 Dec 2006 13:03:11 +0100
Message-ID: <200612311303.11402.mb@bu3sch.de>
References: <459749bb.q8/+AsgXLhurTs3u%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <459749bb.q8/+AsgXLhurTs3u%Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 31 December 2006 06:25, Larry Finger wrote:
> The current bcm43xx driver ignores any wireless-enable switches on mini-PCI
> and mini-PCI-E cards. This patch implements a new routine to interrogate the
> radio hardware enabled bit in the interface, logs the initial state and any
> changes in the switch (if debugging enabled), activates the LED to show the
> state, and changes the periodic work handler to provide 1 second response
> to switch changes and to account for changes in the periodic work specs. It
> also incorporates changes in the LED state that were accepted into mainline
> some time ago.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

> ---
> 
> Michael,
> 
> This patch is for wireless-idev, and is the same as the patch recently
> submitted for bcm43xx-softmac.  These changes have been tested on
> a PCMCIA card with no wireless switch, A BCM4306 mini-PCI card, and
> a BCM4311 mini-PCIE card.
> 
> Larry
> 
> 
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
> @@ -26,6 +26,7 @@
>  */
>  
>  #include "bcm43xx_leds.h"
> +#include "bcm43xx_radio.h"
>  #include "bcm43xx.h"
>  
>  #include <asm/bitops.h>
> @@ -108,6 +109,7 @@ static void bcm43xx_led_init_hardcoded(s
>  	switch (led_index) {
>  	case 0:
>  		led->behaviour = BCM43xx_LED_ACTIVITY;
> +		led->activelow = 1;
>  		if (bcm->board_vendor == PCI_VENDOR_ID_COMPAQ)
>  			led->behaviour = BCM43xx_LED_RADIO_ALL;
>  		break;
> @@ -189,26 +191,31 @@ void bcm43xx_leds_update(struct bcm43xx_
>  		case BCM43xx_LED_INACTIVE:
>  			continue;
>  		case BCM43xx_LED_OFF:
> +		case BCM43xx_LED_BCM4303_3:
>  			break;
>  		case BCM43xx_LED_ON:
>  			turn_on = 1;
>  			break;
>  		case BCM43xx_LED_ACTIVITY:
> +		case BCM43xx_LED_BCM4303_0:
>  			turn_on = activity;
>  			break;
>  		case BCM43xx_LED_RADIO_ALL:
> -			turn_on = radio->enabled;
> +			turn_on = radio->enabled && bcm43xx_is_hw_radio_enabled(bcm);
>  			break;
>  		case BCM43xx_LED_RADIO_A:
> -			turn_on = (radio->enabled && phy->type == BCM43xx_PHYTYPE_A);
> +		case BCM43xx_LED_BCM4303_2:
> +			turn_on = (radio->enabled && bcm43xx_is_hw_radio_enabled(bcm) &&
> +				   phy->type == BCM43xx_PHYTYPE_A);
>  			break;
>  		case BCM43xx_LED_RADIO_B:
> -			turn_on = (radio->enabled &&
> +		case BCM43xx_LED_BCM4303_1:
> +			turn_on = (radio->enabled && bcm43xx_is_hw_radio_enabled(bcm) &&
>  				   (phy->type == BCM43xx_PHYTYPE_B ||
>  				    phy->type == BCM43xx_PHYTYPE_G));
>  			break;
>  		case BCM43xx_LED_MODE_BG:
> -			if (phy->type == BCM43xx_PHYTYPE_G &&
> +			if (phy->type == BCM43xx_PHYTYPE_G && bcm43xx_is_hw_radio_enabled(bcm) &&
>  			    1/*FIXME: using G rates.*/)
>  				turn_on = 1;
>  			break;
> @@ -257,7 +264,8 @@ void bcm43xx_leds_update(struct bcm43xx_
>  			continue;
>  #endif /* CONFIG_BCM43XX_DEBUG */
>  		default:
> -			assert(0);
> +			dprintkl(KERN_INFO PFX "Bad value in leds_update,"
> +				" led->behaviour: 0x%x\n", led->behaviour);
>  		};
>  
>  		if (led->activelow)
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.h
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.h
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.h
> @@ -46,6 +46,12 @@ enum { /* LED behaviour values */
>  	BCM43xx_LED_TEST_BLINKSLOW,
>  	BCM43xx_LED_TEST_BLINKMEDIUM,
>  	BCM43xx_LED_TEST_BLINKFAST,
> +
> +	/* Misc values for BCM4303 */
> +	BCM43xx_LED_BCM4303_0 = 0x2B,
> +	BCM43xx_LED_BCM4303_1 = 0x78,
> +	BCM43xx_LED_BCM4303_2 = 0x2E,
> +	BCM43xx_LED_BCM4303_3 = 0x19,
>  };
>  
>  int bcm43xx_leds_init(struct bcm43xx_private *bcm);
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -2243,6 +2243,9 @@ static int bcm43xx_chip_init(struct bcm4
>  	if (err)
>  		goto err_gpio_cleanup;
>  	bcm43xx_radio_turn_on(bcm);
> +	bcm->radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
> +	dprintk(KERN_INFO PFX "Radio %s by hardware\n",
> +		(bcm->radio_hw_enable == 0) ? "disabled" : "enabled");
>  
>  	bcm43xx_write16(bcm->wlcore, 0x03E6, 0x0000);
>  	err = bcm43xx_phy_init(bcm);
> @@ -2488,9 +2491,24 @@ static void bcm43xx_periodic_every30sec(
>  
>  static void bcm43xx_periodic_every15sec(struct bcm43xx_private *bcm)
>  {
> +	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
> +	//TODO for APHY (temperature?)
> +}
> +
> +static void bcm43xx_periodic_every1sec(struct bcm43xx_private *bcm)
> +{
>  	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
>  	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
> +	int radio_hw_enable;
>  
> +	/* check if radio hardware enabled status changed */
> +	radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
> +	if (unlikely(bcm->radio_hw_enable != radio_hw_enable)) {
> +		bcm->radio_hw_enable = radio_hw_enable;
> +		dprintk(KERN_INFO PFX "Radio hardware status changed to %s\n",
> +		       (radio_hw_enable == 0) ? "disabled" : "enabled");
> +		bcm43xx_leds_update(bcm, 0);
> +	}
>  	if (phy->type == BCM43xx_PHYTYPE_G) {
>  		//TODO: update_aci_moving_average
>  		if (radio->aci_enable && radio->aci_wlan_automatic) {
> @@ -2514,8 +2532,6 @@ static void bcm43xx_periodic_every15sec(
>  			//TODO: implement rev1 workaround
>  		}
>  	}
> -	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
> -	//TODO for APHY (temperature?)
>  }
>  
>  static void do_periodic_work(struct bcm43xx_private *bcm)
> @@ -2523,17 +2539,19 @@ static void do_periodic_work(struct bcm4
>  	unsigned int state;
>  
>  	state = bcm->periodic_state;
> -	if (state % 8 == 0)
> +	if (state % 120 == 0)
>  		bcm43xx_periodic_every120sec(bcm);
> -	if (state % 4 == 0)
> +	if (state % 60 == 0)
>  		bcm43xx_periodic_every60sec(bcm);
> -	if (state % 2 == 0)
> +	if (state % 30 == 0)
>  		bcm43xx_periodic_every30sec(bcm);
> -	if (state % 1 == 0)
> +	if (state % 15 == 0)
>  		bcm43xx_periodic_every15sec(bcm);
> +	bcm43xx_periodic_every1sec(bcm);
> +
>  	bcm->periodic_state = state + 1;
>  
> -	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
> +	schedule_delayed_work(&bcm->periodic_work, HZ);
>  }
>  
>  /* Estimate a "Badness" value based on the periodic work
> @@ -2544,13 +2562,13 @@ static int estimate_periodic_work_badnes
>  {
>  	int badness = 0;
>  
> -	if (state % 8 == 0) /* every 120 sec */
> +	if (state % 120 == 0) /* every 120 sec */
>  		badness += 10;
> -	if (state % 4 == 0) /* every 60 sec */
> +	if (state % 60 == 0) /* every 60 sec */
>  		badness += 5;
> -	if (state % 2 == 0) /* every 30 sec */
> +	if (state % 30 == 0) /* every 30 sec */
>  		badness += 1;
> -	if (state % 1 == 0) /* every 15 sec */
> +	if (state % 15 == 0) /* every 15 sec */
>  		badness += 1;
>  
>  #define BADNESS_LIMIT	4
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.h
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.h
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.h
> @@ -66,6 +66,22 @@ void bcm43xx_radio_init2060(struct bcm43
>  void bcm43xx_radio_turn_on(struct bcm43xx_private *bcm);
>  void bcm43xx_radio_turn_off(struct bcm43xx_private *bcm);
>  
> +static inline
> +int bcm43xx_is_hw_radio_enabled(struct bcm43xx_private *bcm)
> +{
> +	/* function to return state of hardware enable of radio
> +	 * returns 0 if radio disabled, 1 if radio enabled
> +	 */
> +	if (bcm->wlcore->rev >= 3)
> +		return ((bcm43xx_read32(bcm->wlcore, BCM43xx_MMIO_RADIO_HWENABLED_HI)
> +					& BCM43xx_MMIO_RADIO_HWENABLED_HI_MASK)
> +					== 0) ? 1 : 0;
> +	else
> +		return ((bcm43xx_read16(bcm->wlcore, BCM43xx_MMIO_RADIO_HWENABLED_LO)
> +					& BCM43xx_MMIO_RADIO_HWENABLED_LO_MASK)
> +					== 0) ? 0 : 1;
> +}
> +
>  int bcm43xx_radio_selectchannel(struct bcm43xx_private *bcm, u8 channel,
>  				int synthetic_pu_workaround);
>  
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
> @@ -1991,6 +1991,7 @@ void bcm43xx_radio_turn_on(struct bcm43x
>  	}
>  	radio->enabled = 1;
>  	dprintk(KERN_INFO PFX "Radio turned on\n");
> +	bcm43xx_leds_update(bcm, 0);
>  }
>  	
>  void bcm43xx_radio_turn_off(struct bcm43xx_private *bcm)
> @@ -2011,6 +2012,7 @@ void bcm43xx_radio_turn_off(struct bcm43
>  		bcm43xx_phy_write(bcm, 0x0015, 0xAA00);
>  	radio->enabled = 0;
>  	dprintk(KERN_INFO PFX "Radio turned off\n");
> +	bcm43xx_leds_update(bcm, 0);
>  }
>  
>  void bcm43xx_radio_clear_tssi(struct bcm43xx_private *bcm)
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
> @@ -324,6 +324,10 @@ enum {
>  #define BCM43xx_UCODEFLAG_UNKPACTRL	0x0040
>  #define BCM43xx_UCODEFLAG_JAPAN		0x0080
>  
> +/* Hardware Radio Enable masks */
> +#define BCM43xx_MMIO_RADIO_HWENABLED_HI_MASK (1 << 16)
> +#define BCM43xx_MMIO_RADIO_HWENABLED_LO_MASK (1 << 4)
> +
>  /* Generic-Interrupt reasons. */
>  #define BCM43xx_IRQ_MAC_SUSPENDED	0x00000001
>  #define BCM43xx_IRQ_BEACON		0x00000002
> @@ -695,7 +699,8 @@ struct bcm43xx_private {
>  	    reg124_set_0x4:1,		/* Some variable to keep track of IRQ stuff. */
>  	    short_preamble:1,		/* TRUE, if short preamble is enabled. */
>  	    short_slot:1,		/* TRUE, if short slot timing is enabled. */
> -	    firmware_norelease:1;	/* Do not release the firmware. Used on suspend. */
> +	    firmware_norelease:1,	/* Do not release the firmware. Used on suspend. */
> +	    radio_hw_enable:1;		/* saved state of radio hardware enabled state */
>  
>  	/* One physical device can have one operating interface
>  	 * and a virtually infinite amount of monitoring interfaces.
> 
> 

-- 
Greetings Michael.
