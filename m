From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Rewrite e100_phys_id
Date: Fri, 27 Oct 2006 07:44:18 -0700
Message-ID: <45421B42.60405@intel.com>
References: <20061026191154.GG5591@parisc-linux.org> <20061026191937.GB11312@havoc.gtf.org> <454114D0.6050900@intel.com> <20061027025148.GI5591@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, Jeff Garzik <jeff@garzik.org>,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15765 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1752199AbWJ0Oqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 10:46:50 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061027025148.GI5591@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Thu, Oct 26, 2006 at 01:04:32PM -0700, Auke Kok wrote:
>> no objections, so I'll ACK it with the notion that I'm going to let our 
>> labs do some more testing on it with all the latest changes to it.
> 
> Thanks, Auke.  Here's the equivalent patch for e1000.  I don't have a
> convenient machine to test it on, but it reduces the size of the driver
> by 1.5k.

this is a bit (!) more complex than e100, so I'm going to take a bit of time to review 
this patch.

thanks,

Auke



> 
> diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
> index 7ecce43..1e22da6 100644
> --- a/drivers/net/e1000/e1000.h
> +++ b/drivers/net/e1000/e1000.h
> @@ -257,9 +257,6 @@ #endif
>  	struct work_struct reset_task;
>  	uint8_t fc_autoneg;
>  
> -	struct timer_list blink_timer;
> -	unsigned long led_status;
> -
>  	/* TX */
>  	struct e1000_tx_ring *tx_ring;      /* One per active queue */
>  	unsigned long tx_queue_len;
> diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
> index 773821e..620afa5 100644
> --- a/drivers/net/e1000/e1000_ethtool.c
> +++ b/drivers/net/e1000/e1000_ethtool.c
> @@ -1819,61 +1819,15 @@ e1000_set_wol(struct net_device *netdev,
>  	return 0;
>  }
>  
> -/* toggle LED 4 times per second = 2 "blinks" per second */
> -#define E1000_ID_INTERVAL	(HZ/4)
> -
> -/* bit defines for adapter->led_status */
> -#define E1000_LED_ON		0
> -
> -static void
> -e1000_led_blink_callback(unsigned long data)
> -{
> -	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
> -
> -	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
> -		e1000_led_off(&adapter->hw);
> -	else
> -		e1000_led_on(&adapter->hw);
> -
> -	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
> -}
> -
>  static int
>  e1000_phys_id(struct net_device *netdev, uint32_t data)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  
> -	if (!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
> -		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
> -
> -	if (adapter->hw.mac_type < e1000_82571) {
> -		if (!adapter->blink_timer.function) {
> -			init_timer(&adapter->blink_timer);
> -			adapter->blink_timer.function = e1000_led_blink_callback;
> -			adapter->blink_timer.data = (unsigned long) adapter;
> -		}
> -		e1000_setup_led(&adapter->hw);
> -		mod_timer(&adapter->blink_timer, jiffies);
> -		msleep_interruptible(data * 1000);
> -		del_timer_sync(&adapter->blink_timer);
> -	} else if (adapter->hw.phy_type == e1000_phy_ife) {
> -		if (!adapter->blink_timer.function) {
> -			init_timer(&adapter->blink_timer);
> -			adapter->blink_timer.function = e1000_led_blink_callback;
> -			adapter->blink_timer.data = (unsigned long) adapter;
> -		}
> -		mod_timer(&adapter->blink_timer, jiffies);
> -		msleep_interruptible(data * 1000);
> -		del_timer_sync(&adapter->blink_timer);
> -		e1000_write_phy_reg(&(adapter->hw), IFE_PHY_SPECIAL_CONTROL_LED, 0);
> -	} else {
> -		e1000_blink_led_start(&adapter->hw);
> -		msleep_interruptible(data * 1000);
> -	}
> +	if (data == 0)
> +		data = 2;
>  
> -	e1000_led_off(&adapter->hw);
> -	clear_bit(E1000_LED_ON, &adapter->led_status);
> -	e1000_cleanup_led(&adapter->hw);
> +	e1000_blink_led(&adapter->hw, data);
>  
>  	return 0;
>  }
> diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
> index 65077f3..db5e999 100644
> --- a/drivers/net/e1000/e1000_hw.c
> +++ b/drivers/net/e1000/e1000_hw.c
> @@ -6071,7 +6071,7 @@ e1000_id_led_init(struct e1000_hw * hw)
>   *
>   * hw - Struct containing variables accessed by shared code
>   *****************************************************************************/
> -int32_t
> +static int32_t
>  e1000_setup_led(struct e1000_hw *hw)
>  {
>      uint32_t ledctl;
> @@ -6123,50 +6123,11 @@ e1000_setup_led(struct e1000_hw *hw)
>  
>  
>  /******************************************************************************
> - * Used on 82571 and later Si that has LED blink bits.
> - * Callers must use their own timer and should have already called
> - * e1000_id_led_init()
> - * Call e1000_cleanup led() to stop blinking
> - *
> - * hw - Struct containing variables accessed by shared code
> - *****************************************************************************/
> -int32_t
> -e1000_blink_led_start(struct e1000_hw *hw)
> -{
> -    int16_t  i;
> -    uint32_t ledctl_blink = 0;
> -
> -    DEBUGFUNC("e1000_id_led_blink_on");
> -
> -    if (hw->mac_type < e1000_82571) {
> -        /* Nothing to do */
> -        return E1000_SUCCESS;
> -    }
> -    if (hw->media_type == e1000_media_type_fiber) {
> -        /* always blink LED0 for PCI-E fiber */
> -        ledctl_blink = E1000_LEDCTL_LED0_BLINK |
> -                     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
> -    } else {
> -        /* set the blink bit for each LED that's "on" (0x0E) in ledctl_mode2 */
> -        ledctl_blink = hw->ledctl_mode2;
> -        for (i=0; i < 4; i++)
> -            if (((hw->ledctl_mode2 >> (i * 8)) & 0xFF) ==
> -                E1000_LEDCTL_MODE_LED_ON)
> -                ledctl_blink |= (E1000_LEDCTL_LED0_BLINK << (i * 8));
> -    }
> -
> -    E1000_WRITE_REG(hw, LEDCTL, ledctl_blink);
> -
> -    return E1000_SUCCESS;
> -}
> -
> -/******************************************************************************
>   * Restores the saved state of the SW controlable LED.
>   *
>   * hw - Struct containing variables accessed by shared code
>   *****************************************************************************/
> -int32_t
> -e1000_cleanup_led(struct e1000_hw *hw)
> +static int32_t e1000_cleanup_led(struct e1000_hw *hw)
>  {
>      int32_t ret_val = E1000_SUCCESS;
>  
> @@ -6207,8 +6168,7 @@ e1000_cleanup_led(struct e1000_hw *hw)
>   *
>   * hw - Struct containing variables accessed by shared code
>   *****************************************************************************/
> -int32_t
> -e1000_led_on(struct e1000_hw *hw)
> +static int32_t e1000_led_on(struct e1000_hw *hw)
>  {
>      uint32_t ctrl = E1000_READ_REG(hw, CTRL);
>  
> @@ -6258,8 +6218,7 @@ e1000_led_on(struct e1000_hw *hw)
>   *
>   * hw - Struct containing variables accessed by shared code
>   *****************************************************************************/
> -int32_t
> -e1000_led_off(struct e1000_hw *hw)
> +static int32_t e1000_led_off(struct e1000_hw *hw)
>  {
>      uint32_t ctrl = E1000_READ_REG(hw, CTRL);
>  
> @@ -6304,6 +6263,69 @@ e1000_led_off(struct e1000_hw *hw)
>      return E1000_SUCCESS;
>  }
>  
> +static void e1000_blink_led_auto(struct e1000_hw *hw, unsigned int seconds)
> +{
> +    int16_t  i;
> +    uint32_t ledctl_blink = 0;
> +
> +    DEBUGFUNC("e1000_blink_led");
> +
> +    if (hw->media_type == e1000_media_type_fiber) {
> +        /* always blink LED0 for PCI-E fiber */
> +        ledctl_blink = E1000_LEDCTL_LED0_BLINK |
> +                     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
> +    } else {
> +        /* set the blink bit for each LED that's "on" (0x0E) in ledctl_mode2 */
> +        ledctl_blink = hw->ledctl_mode2;
> +        for (i=0; i < 4; i++)
> +            if (((hw->ledctl_mode2 >> (i * 8)) & 0xFF) ==
> +                E1000_LEDCTL_MODE_LED_ON)
> +                ledctl_blink |= (E1000_LEDCTL_LED0_BLINK << (i * 8));
> +    }
> +
> +    E1000_WRITE_REG(hw, LEDCTL, ledctl_blink);
> +
> +    msleep_interruptible(seconds * HZ);
> +
> +    e1000_led_off(hw);
> +    e1000_cleanup_led(hw);
> +}
> +
> +static void e1000_blink_led_manually(struct e1000_hw *hw, unsigned int seconds)
> +{
> +	unsigned int i;
> +	e1000_setup_led(hw);
> +
> +	for (i = 0; i < (seconds * 4); i++) {
> +		if (i & 1)
> +			e1000_led_off(hw);
> +		else
> +			e1000_led_on(hw);
> +		if (msleep_interruptible(250))
> +			break;
> +	}
> +
> +	e1000_led_off(hw);
> +	e1000_cleanup_led(hw);
> +}
> +
> +/******************************************************************************
> + * Blink the LED for the given number of seconds. 
> + *
> + * hw - Struct containing variables accessed by shared code
> + * seconds - Length of time to blink LED for
> + *****************************************************************************/
> +void e1000_blink_led(struct e1000_hw *hw, unsigned int seconds)
> +{
> +	if (hw->mac_type < e1000_82571) {
> +		e1000_blink_led_manually(hw, seconds);
> +	} else if (hw->phy_type == e1000_phy_ife) {
> +		e1000_blink_led_manually(hw, seconds);
> +	} else {
> +		e1000_blink_led_auto(hw, seconds);
> +	}
> +}
> +
>  /******************************************************************************
>   * Clears all hardware statistics counters.
>   *
> diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
> index 112447f..1efedb7 100644
> --- a/drivers/net/e1000/e1000_hw.h
> +++ b/drivers/net/e1000/e1000_hw.h
> @@ -404,11 +404,7 @@ void e1000_rar_set(struct e1000_hw *hw, 
>  void e1000_write_vfta(struct e1000_hw *hw, uint32_t offset, uint32_t value);
>  
>  /* LED functions */
> -int32_t e1000_setup_led(struct e1000_hw *hw);
> -int32_t e1000_cleanup_led(struct e1000_hw *hw);
> -int32_t e1000_led_on(struct e1000_hw *hw);
> -int32_t e1000_led_off(struct e1000_hw *hw);
> -int32_t e1000_blink_led_start(struct e1000_hw *hw);
> +void e1000_blink_led(struct e1000_hw *hw, unsigned int seconds);
>  
>  /* Adaptive IFS Functions */
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
