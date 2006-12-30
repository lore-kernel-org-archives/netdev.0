From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Interrogate hardware-enable switch and update
	LEDs
Date: Sat, 30 Dec 2006 15:05:39 +0100
Message-ID: <200612301505.39848.mb@bu3sch.de>
References: <459573c1.dAoB7uQ5YZxgTh00%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <459573c1.dAoB7uQ5YZxgTh00%Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Friday 29 December 2006 21:00, Larry Finger wrote:
> The current bcm43xx driver ignores any wireless-enable switches on mini-PCI
> and mini-PCI-E cards. This patch implements a new routine to interrogate the
> radio hardware enabled bit in the interface, logs the initial state and any
> changes in the switch (if debugging enabled), activates the LED to show the
> state, and changes the periodic work handler to provide 1 second response
> to switch changes and to account for changes in the periodic work specs.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
> 
> John,
> 
> This should be applied to wireless-2.6. It is a new feature and is
> not appropriate for 2.6.20-rcX. These changes have been tested on
> a PCMCIA card with no wireless switch, A BCM4306 mini-PCI card, and
> a BCM4311 mini-PCIE card.
> 
> Larry
> 
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -2441,6 +2441,9 @@ static int bcm43xx_chip_init(struct bcm4
>  	if (err)
>  		goto err_gpio_cleanup;
>  	bcm43xx_radio_turn_on(bcm);
> +	bcm->radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
> +	dprintk(KERN_INFO PFX "Radio %s by hardware\n",
> +		(bcm->radio_hw_enable == 0) ? "disabled" : "enabled");
>  
>  	bcm43xx_write16(bcm, 0x03E6, 0x0000);
>  	err = bcm43xx_phy_init(bcm);
> @@ -3174,9 +3177,24 @@ static void bcm43xx_periodic_every30sec(
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
> @@ -3200,21 +3218,21 @@ static void bcm43xx_periodic_every15sec(
>  			//TODO: implement rev1 workaround
>  		}
>  	}
> -	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
> -	//TODO for APHY (temperature?)
>  }
>  
>  static void do_periodic_work(struct bcm43xx_private *bcm)
>  {
> -	if (bcm->periodic_state % 8 == 0)
> +	if (bcm->periodic_state % 120 == 0)
>  		bcm43xx_periodic_every120sec(bcm);
> -	if (bcm->periodic_state % 4 == 0)
> +	if (bcm->periodic_state % 60 == 0)
>  		bcm43xx_periodic_every60sec(bcm);
> -	if (bcm->periodic_state % 2 == 0)
> +	if (bcm->periodic_state % 30 == 0)
>  		bcm43xx_periodic_every30sec(bcm);
> -	bcm43xx_periodic_every15sec(bcm);
> +	if (bcm->periodic_state % 15 == 0)
> +		bcm43xx_periodic_every15sec(bcm);
> +	bcm43xx_periodic_every1sec(bcm);
>  
> -	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
> +	schedule_delayed_work(&bcm->periodic_work, HZ);
>  }
>  
>  static void bcm43xx_periodic_work_handler(struct work_struct *work)
> @@ -3227,7 +3245,7 @@ static void bcm43xx_periodic_work_handle
>  	unsigned long orig_trans_start = 0;
>  
>  	mutex_lock(&bcm->mutex);
> -	if (unlikely(bcm->periodic_state % 4 == 0)) {
> +	if (unlikely(bcm->periodic_state % 60 == 0)) {
>  		/* Periodic work will take a long time, so we want it to
>  		 * be preemtible.
>  		 */
> @@ -3259,7 +3277,7 @@ static void bcm43xx_periodic_work_handle
>  
>  	do_periodic_work(bcm);
>  
> -	if (unlikely(bcm->periodic_state % 4 == 0)) {
> +	if (unlikely(bcm->periodic_state % 60 == 0)) {
>  		spin_lock_irqsave(&bcm->irq_lock, flags);
>  		tasklet_enable(&bcm->isr_tasklet);
>  		bcm43xx_interrupt_enable(bcm, savedirqs);
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_radio.h
> @@ -65,6 +65,22 @@ void bcm43xx_radio_init2060(struct bcm43
>  void bcm43xx_radio_turn_on(struct bcm43xx_private *bcm);
>  void bcm43xx_radio_turn_off(struct bcm43xx_private *bcm);
>  
> +static inline
> +int bcm43xx_is_hw_radio_enabled(struct bcm43xx_private *bcm)
> +{
> +	/* function to return state of hardware enable of radio
> +	 * returns 0 if radio disabled, 1 if radio enabled
> +	 */
> +	if (likely(bcm->current_core->rev >= 3))

This is not likely.

> +		return ((bcm43xx_read32(bcm, BCM43xx_MMIO_RADIO_HWENABLED_HI)
> +					& BCM43xx_MMIO_RADIO_HWENABLED_HI_MASK)
> +					== 0) ? 1 : 0;
> +	else
> +		return ((bcm43xx_read16(bcm, BCM43xx_MMIO_RADIO_HWENABLED_LO)
> +					& BCM43xx_MMIO_RADIO_HWENABLED_LO_MASK)
> +					== 0) ? 0 : 1;
> +}
> +

-- 
Greetings Michael.
