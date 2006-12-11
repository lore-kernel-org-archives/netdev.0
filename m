From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw-d80211: Use LED class
Date: Mon, 11 Dec 2006 23:55:38 +0100
Message-ID: <20061211225538.GA30512@p15091797.pureserver.info>
References: <200612110044.12205.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:50818 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbWLKWzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 17:55:40 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612110044.12205.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-11 00:44 Michael Wu wrote:

> This makes zd1211rw-d80211 register an LED class to control the link LED
> instead of trying to determine when the LED should be on based on the
> current bssid. No default trigger is set since d80211 doesn't currently
> have a link on/off LED trigger.

I cannot accknowledge this patch. Michael, the LED does not only
show the link status, but also indicate that packets are sent,
which is done by the firmware. However the LED flags have to be
reset every second, because if an odd number of packets have been
transmitted, the LED stays dark. This is done by accessing
registers of the device, which requires process context to
implement synchronous access. From my point of view workqueue
functions are the only way to support this.

I even don't think, that the upper d80211 layers should care for
LED controlling. The LEDs are part of the device and should be
controlled by the device driver. I have a ZD1211 device, which has
two LEDs. Now suddenly the upper layer must know about the two
LEDs. But there could be WLAN devices who would have 6 LEDs for
whatever reason. Should the upper layer know about all those LEDs
and their semantics? The better design would be, that the driver
could register for upper layer events and control it's LEDs
accordingly. 

The zd1211rw driver has it's own workqueue to prevent crashes or
locks in our workqueue functions from taking the kernel down.
However a single workqueue is shared by all zd1211 devices
connected to the system. After the driver has stabilized we could
use the global Linux workqueues.

If you would also have taken the time to look at my out-of-tree
driver, you would have seen the other housekeeping/workqueue
functions for handling strong signals. These changes are still
missing from the kernel, because I have still to resolve issues
with AL2230 RFs. This again can only be implemented in workqueues,
because the register accesses require process context.

Regards,

Uli

> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>
> ---
>  drivers/net/wireless/d80211/zd1211rw/zd_chip.c |    2 +-
>  drivers/net/wireless/d80211/zd1211rw/zd_chip.h |    2 +-
>  drivers/net/wireless/d80211/zd1211rw/zd_mac.c  |   90 
> ++++++++++--------------
>  drivers/net/wireless/d80211/zd1211rw/zd_mac.h  |   23 +++++--
>  drivers/net/wireless/d80211/zd1211rw/zd_usb.c  |   19 +++---
>  drivers/net/wireless/d80211/zd1211rw/zd_usb.h  |    2 -
>  6 files changed, 65 insertions(+), 73 deletions(-)
> 
> diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_chip.c 
> b/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
> index daec7b6..97ff136 100644
> --- a/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
> +++ b/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
> @@ -1321,7 +1321,7 @@ int zd_chip_control_leds(struct zd_chip
>  	other_led = chip->link_led == LED1 ? LED2 : LED1;
>  
>  	switch (status) {
> -	case LED_OFF:
> +	case LED_DISABLED:
>  		ioreqs[0].value = FW_LINK_OFF;
>  		ioreqs[1].value = v[1] & ~(LED1|LED2);
>  		break;
> diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_chip.h 
> b/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
> index b9c225d..970b920 100644
> --- a/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
> +++ b/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
> @@ -821,7 +821,7 @@ int zd_chip_lock_phy_regs(struct zd_chip
>  int zd_chip_unlock_phy_regs(struct zd_chip *chip);
>  
>  enum led_status {
> -	LED_OFF = 0,
> +	LED_DISABLED = 0, /* linux/leds.h took LED_OFF.. */
>  	LED_SCANNING = 1,
>  	LED_ASSOCIATED = 2,
>  };
> diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c 
> b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
> index 6ee650f..1c76e62 100644
> --- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
> +++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
> @@ -29,10 +29,6 @@
>  #include "zd_rf.h"
>  #include "zd_util.h"
>  
> -static void housekeeping_init(struct zd_mac *mac);
> -static void housekeeping_enable(struct zd_mac *mac);
> -static void housekeeping_disable(struct zd_mac *mac);
> -
>  int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type)
>  {
>  	int r;
> @@ -137,7 +133,9 @@ static int zd_mac_open(struct ieee80211_
>  	if (r < 0)
>  		goto disable_rx;
>  
> -	housekeeping_enable(mac);
> +#ifdef CONFIG_LEDS_CLASS
> +	led_classdev_resume(&mac->link_led);
> +#endif
>  	return 0;
>  disable_rx:
>  	zd_chip_disable_rx(chip);
> @@ -161,8 +159,10 @@ static int zd_mac_stop(struct ieee80211_
>  	 * frames to be processed by softmac after we have stopped it.
>  	 */
>  
> +#ifdef CONFIG_LEDS_CLASS
> +	led_classdev_suspend(&mac->link_led);
> +#endif
>  	zd_chip_disable_rx(chip);
> -	housekeeping_disable(mac);
>  
>  	zd_chip_disable_hwint(chip);
>  	zd_chip_switch_radio_off(chip);
> @@ -552,10 +552,6 @@ static int zd_mac_config(struct ieee8021
>  static int zd_mac_config_interface(struct ieee80211_hw *dev, int if_id,
>  				   struct ieee80211_if_conf *conf)
>  {
> -	struct zd_mac *mac = zd_dev_mac(dev);
> -
> -	mac->associated = is_valid_ether_addr(conf->bssid);
> -
>  	/* TODO: do hardware bssid filtering */
>  	return 0;
>  }
> @@ -570,6 +566,37 @@ static struct ieee80211_ops zd_ops = {
>  	.config_interface	= zd_mac_config_interface,
>  };
>  
> +#ifdef CONFIG_LEDS_CLASS
> +static void set_link_led(struct led_classdev *led_cdev,
> +			 enum led_brightness brightness)
> +{
> +	struct zd_mac *mac = container_of(led_cdev, struct zd_mac, link_led);
> +	int r;
> +
> +	r = zd_chip_control_leds(&mac->chip,
> +		                 brightness ? LED_ASSOCIATED : LED_DISABLED);
> +	if (r)
> +		dev_err(zd_mac_dev(mac), "zd_chip_control_leds error %d\n", r);
> +}
> +
> +int zd_mac_register_led(struct ieee80211_hw *dev)
> +{
> +	struct zd_mac *mac = zd_dev_mac(dev);
> +	snprintf(mac->link_led_name, sizeof(mac->link_led_name),
> +	         "wiphy%dlink", dev->index);
> +	mac->link_led.name = mac->link_led_name;
> +	mac->link_led.brightness_set = set_link_led;
> +	mac->link_led.flags = LED_SUSPENDED;
> +	return led_classdev_register(dev->dev, &mac->link_led);
> +}
> +
> +void zd_mac_unregister_led(struct ieee80211_hw *dev)
> +{
> +	struct zd_mac *mac = zd_dev_mac(dev);
> +	led_classdev_unregister(&mac->link_led);
> +}
> +#endif
> +
>  struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf)
>  {
>  	struct zd_mac *mac;
> @@ -616,51 +643,8 @@ struct ieee80211_hw *zd_mac_alloc(struct
>  
>  	skb_queue_head_init(&mac->tx_queue);
>  	zd_chip_init(&mac->chip, dev, intf);
> -	housekeeping_init(mac);
>  
>  	SET_MODULE_OWNER(dev);
>  	dev->dev = &intf->dev;
>  	return dev;
>  }
> -
> -#define LINK_LED_WORK_DELAY HZ
> -
> -static void link_led_handler(void *p)
> -{
> -	struct zd_mac *mac = p;
> -	struct zd_chip *chip = &mac->chip;
> -	int is_associated;
> -	int r;
> -
> -	spin_lock_irq(&mac->lock);
> -	is_associated = mac->associated;
> -	spin_unlock_irq(&mac->lock);
> -
> -	r = zd_chip_control_leds(chip,
> -		                 is_associated ? LED_ASSOCIATED : LED_SCANNING);
> -	if (r)
> -		dev_err(zd_mac_dev(mac), "zd_chip_control_leds error %d\n", r);
> -
> -	queue_delayed_work(zd_workqueue, &mac->housekeeping.link_led_work,
> -		           LINK_LED_WORK_DELAY);
> -}
> -
> -static void housekeeping_init(struct zd_mac *mac)
> -{
> -	INIT_WORK(&mac->housekeeping.link_led_work, link_led_handler, mac);
> -}
> -
> -static void housekeeping_enable(struct zd_mac *mac)
> -{
> -	dev_dbg_f(zd_mac_dev(mac), "\n");
> -	queue_delayed_work(zd_workqueue, &mac->housekeeping.link_led_work,
> -			   0);
> -}
> -
> -static void housekeeping_disable(struct zd_mac *mac)
> -{
> -	dev_dbg_f(zd_mac_dev(mac), "\n");
> -	cancel_rearming_delayed_workqueue(zd_workqueue,
> -		&mac->housekeeping.link_led_work);
> -	zd_chip_control_leds(&mac->chip, LED_OFF);
> -}
> diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h 
> b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
> index e2ba410..f5817aa 100644
> --- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
> +++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
> @@ -19,6 +19,7 @@
>  #define _ZD_MAC_H
>  
>  #include <linux/kernel.h>
> +#include <linux/leds.h>
>  #include <net/d80211.h>
>  
>  #include "zd_chip.h"
> @@ -118,22 +119,20 @@ enum mac_flags {
>  	MAC_FIXED_CHANNEL = 0x01,
>  };
>  
> -struct housekeeping {
> -	struct work_struct link_led_work;
> -};
> -
>  #define ZD_MAC_STATS_BUFFER_SIZE 16
>  
>  struct zd_mac {
>  	struct zd_chip chip;
>  	spinlock_t lock;
>  	struct ieee80211_hw *dev;
> -	struct housekeeping housekeeping;
> +#ifdef CONFIG_LEDS_CLASS
> +	char link_led_name[32];
> +	struct led_classdev link_led;
> +#endif
>  	u8 regdomain;
>  	u8 default_regdomain;
>  	u8 requested_channel;
>  	int mode;
> -	int associated;
>  	u8 *hwaddr;
>  	struct sk_buff_head tx_queue;
>  	struct ieee80211_channel channels[14];
> @@ -159,6 +158,18 @@ static inline struct zd_mac *zd_usb_to_m
>  #define zd_mac_dev(mac) (zd_chip_dev(&(mac)->chip))
>  
>  struct ieee80211_hw *zd_mac_alloc(struct usb_interface *intf);
> +#ifdef CONFIG_LEDS_CLASS
> +int zd_mac_register_led(struct ieee80211_hw *dev);
> +void zd_mac_unregister_led(struct ieee80211_hw *dev);
> +#else
> +static inline int zd_mac_register_led(struct ieee80211_hw *dev)
> +{
> +	return 0;
> +}
> +static inline void zd_mac_unregister_led(struct ieee80211_hw *dev)
> +{
> +}
> +#endif
>  void zd_mac_clear(struct zd_mac *mac);
>  
>  int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type);
> diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c 
> b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
> index bacb019..171fb93 100644
> --- a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
> +++ b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
> @@ -24,7 +24,6 @@
>  #include <linux/errno.h>
>  #include <linux/skbuff.h>
>  #include <linux/usb.h>
> -#include <linux/workqueue.h>
>  #include <net/d80211.h>
>  
>  #include "zd_def.h"
> @@ -1058,6 +1057,14 @@ static int probe(struct usb_interface *i
>  		goto error;
>  	}
>  
> +	r = zd_mac_register_led(dev);
> +	if (r) {
> +		dev_dbg_f(&intf->dev,
> +			 "couldn't register LED. Error number %d\n", r);
> +		ieee80211_unregister_hw(dev);
> +		goto error;
> +	}
> +
>  	dev_dbg_f(&intf->dev, "successful\n");
>  	dev_info(&intf->dev,"wiphy%d\n", dev->index);
>  	return 0;
> @@ -1083,6 +1090,7 @@ static void disconnect(struct usb_interf
>  
>  	dev_dbg_f(zd_usb_dev(usb), "\n");
>  
> +	zd_mac_unregister_led(dev);
>  	ieee80211_unregister_hw(dev);
>  
>  	/* Just in case something has gone wrong! */
> @@ -1108,20 +1116,12 @@ static struct usb_driver driver = {
>  	.disconnect	= disconnect,
>  };
>  
> -struct workqueue_struct *zd_workqueue;
> -
>  static int __init usb_init(void)
>  {
>  	int r;
>  
>  	pr_debug("%s usb_init()\n", driver.name);
>  
> -	zd_workqueue = create_singlethread_workqueue(driver.name);
> -	if (zd_workqueue == NULL) {
> -		printk(KERN_ERR "%s couldn't create workqueue\n", driver.name);
> -		return -ENOMEM;
> -	}
> -
>  	r = usb_register(&driver);
>  	if (r) {
>  		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
> @@ -1137,7 +1137,6 @@ static void __exit usb_exit(void)
>  {
>  	pr_debug("%s usb_exit()\n", driver.name);
>  	usb_deregister(&driver);
> -	destroy_workqueue(zd_workqueue);
>  }
>  
>  module_init(usb_init);
> diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.h 
> b/drivers/net/wireless/d80211/zd1211rw/zd_usb.h
> index 1379e48..cda2259 100644
> --- a/drivers/net/wireless/d80211/zd1211rw/zd_usb.h
> +++ b/drivers/net/wireless/d80211/zd1211rw/zd_usb.h
> @@ -238,6 +238,4 @@ int zd_usb_iowrite16v(struct zd_usb *usb
>  
>  int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
>  
> -extern struct workqueue_struct *zd_workqueue;
> -
>  #endif /* _ZD_USB_H */
> -- 
> 1.4.4.1
> 



-- 
Uli Kunitz
