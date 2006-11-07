From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Rewrite e100_phys_id
Date: Tue, 07 Nov 2006 10:33:14 -0800
Message-ID: <4550D16A.1090008@intel.com>
References: <20061026191154.GG5591@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22656 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1754260AbWKGSdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 13:33:23 -0500
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061026191154.GG5591@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> The motivator for this was to fix the sparse warning:
> 
> drivers/net/e100.c:2418:48: warning: cast truncates bits from constant
> value (83126e978d4fdf becomes 978d4fdf)
> drivers/net/e100.c:2419:37: warning: cast truncates bits from constant
> value (83126e978d4fdf becomes 978d4fdf)
> 
> Initially, I tried a quick fix, but when it ran into difficulties, I
> looked at tg3.c to see how it does it.  I liked their way better, so I
> rewrote e100.c to be similar.  It shaves ~700 bytes off the size of the
> driver, and a few bytes off the size of struct nic, so I think it's a
> win all round.  Tested on the internal interface of an HP Integrity rx2600.

bad news, it's completely hosed. The adapter does some indistinguishable blinking for a 
second, then stops blinking alltogether.

I might revert the code to the old situation. I guess I should have tested it initially 
right away.

I'm not even going to touch the e1000 patch for now ;)

Auke

> 
> Signed-off-by: Matthew Wilcox <matthew@wil.cx>
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index a3a08a5..aade1e9 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -556,7 +556,6 @@ struct nic {
>  	struct params params;
>  	struct net_device_stats net_stats;
>  	struct timer_list watchdog;
> -	struct timer_list blink_timer;
>  	struct mii_if_info mii;
>  	struct work_struct tx_timeout_task;
>  	enum loopback loopback;
> @@ -581,7 +580,6 @@ struct nic {
>  	u32 rx_over_length_errors;
>  
>  	u8 rev_id;
> -	u16 leds;
>  	u16 eeprom_wc;
>  	u16 eeprom[256];
>  	spinlock_t mdio_lock;
> @@ -2168,23 +2166,6 @@ err_clean_rx:
>  	return err;
>  }
>  
> -#define MII_LED_CONTROL	0x1B
> -static void e100_blink_led(unsigned long data)
> -{
> -	struct nic *nic = (struct nic *)data;
> -	enum led_state {
> -		led_on     = 0x01,
> -		led_off    = 0x04,
> -		led_on_559 = 0x05,
> -		led_on_557 = 0x07,
> -	};
> -
> -	nic->leds = (nic->leds & led_on) ? led_off :
> -		(nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559;
> -	mdio_write(nic->netdev, nic->mii.phy_id, MII_LED_CONTROL, nic->leds);
> -	mod_timer(&nic->blink_timer, jiffies + HZ / 4);
> -}
> -
>  static int e100_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
>  {
>  	struct nic *nic = netdev_priv(netdev);
> @@ -2411,16 +2392,32 @@ static void e100_diag_test(struct net_de
>  	msleep_interruptible(4 * 1000);
>  }
>  
> +#define MII_LED_CONTROL	0x1B
>  static int e100_phys_id(struct net_device *netdev, u32 data)
>  {
>  	struct nic *nic = netdev_priv(netdev);
> +	int i;
> +
> +	enum led_state {
> +		led_off    = 0x04,
> +		led_on_559 = 0x05,
> +		led_on_557 = 0x07,
> +	};
> +	u16 leds = led_off;
> +
> +	if (data == 0)
> +		data = 2;
> +
> +	for (i = 0; i < (data * 2); i++) {
> +		leds = (leds == led_off) ?
> +			(nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559 :
> +			led_off;
> +		mdio_write(nic->netdev, nic->mii.phy_id, MII_LED_CONTROL, leds);
> +		if (msleep_interruptible(500))
> +			break;
> +	}
>  
> -	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
> -		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
> -	mod_timer(&nic->blink_timer, jiffies);
> -	msleep_interruptible(data * 1000);
> -	del_timer_sync(&nic->blink_timer);
> -	mdio_write(netdev, nic->mii.phy_id, MII_LED_CONTROL, 0);
> +	mdio_write(netdev, nic->mii.phy_id, MII_LED_CONTROL, led_off);
>  
>  	return 0;
>  }
> @@ -2633,9 +2630,6 @@ #endif
>  	init_timer(&nic->watchdog);
>  	nic->watchdog.function = e100_watchdog;
>  	nic->watchdog.data = (unsigned long)nic;
> -	init_timer(&nic->blink_timer);
> -	nic->blink_timer.function = e100_blink_led;
> -	nic->blink_timer.data = (unsigned long)nic;
>  
>  	INIT_WORK(&nic->tx_timeout_task,
>  		(void (*)(void *))e100_tx_timeout_task, netdev);
