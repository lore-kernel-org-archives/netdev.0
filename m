From: Mike Krinkin <krinkin.m.u@gmail.com>
Subject: [PATCH v3] rfkill: Add rfkill-any LED trigger
Date: Mon, 2 Jan 2017 14:47:59 +0300
Message-ID: <20170102114757.GA2776@gmail.com>
References: <20161221084533.27006-1-kernel@kempniu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBLxJlwaWXFhA==?= <kernel@kempniu.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161221084533.27006-1-kernel@kempniu.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 09:45:33AM +0100, Michał Kępień wrote:
> Add a new "global" (i.e. not per-rfkill device) LED trigger, rfkill-any,
> which may be useful on laptops with a single "radio LED" and multiple
> radio transmitters.  The trigger is meant to turn a LED on whenever
> there is at least one radio transmitter active and turn it off
> otherwise.
> 
> This requires taking rfkill_global_mutex before calling
> rfkill_set_block() in rfkill_resume(): since
> rfkill_any_led_trigger_event(true) is called from rfkill_set_block()
> unconditionally, each caller of the latter needs to take care of locking
> rfkill_global_mutex.
> 
> Signed-off-by: Michał Kępień <kernel@kempniu.pl>
> ---
> Jonathan, I refrained from resending patch 1/2 from v2 as part of this
> series as it is currently applied in mac80211-next/master along with
> Arnd's fix.  Please let me know if you would like me to handle this
> differently.
> 
> Mike, could you please test whether this version works fine on your
> machine?  Thanks!

Sorry for the delay, patch works fine for me.

> 
> Changes from v2:
> 
>   - Handle the global mutex properly when rfkill_set_{hw,sw}_state() or
>     rfkill_set_states() is called from within an rfkill callback.  v2
>     always tried to lock the global mutex in such a case, which led to a
>     deadlock when an rfkill driver called one of the above functions
>     from its query or set_block callback.  This is solved by defining a
>     new bitfield, RFKILL_BLOCK_SW_HASLOCK, which is set before the above
>     callbacks are invoked and cleared afterwards; the functions listed
>     above use this bitfield to tell rfkill_any_led_trigger_event()
>     whether the global mutex is currently held or not.
>     RFKILL_BLOCK_SW_SETCALL cannot be reused for this purpose as setting
>     it before invoking the query callback would cause any calls to
>     rfkill_set_sw_state() made from within that callback to work on
>     RFKILL_BLOCK_SW_PREV instead of RFKILL_BLOCK_SW and thus change the
>     way rfkill_set_block() behaves.
> 
>   - As rfkill_any_led_trigger_event() now takes a boolean argument which
>     tells it whether the global mutex was already taken by the caller,
>     all calls to __rfkill_any_led_trigger_event() outside
>     rfkill_any_led_trigger_event() have been replaced with calls to
>     rfkill_any_led_trigger_event(true).
> 
>  net/rfkill/core.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 86 insertions(+), 4 deletions(-)
> 
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index afa4f71b4c7b..688eac7b97ef 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -44,6 +44,7 @@
>  #define RFKILL_BLOCK_ANY	(RFKILL_BLOCK_HW |\
>  				 RFKILL_BLOCK_SW |\
>  				 RFKILL_BLOCK_SW_PREV)
> +#define RFKILL_BLOCK_SW_HASLOCK	BIT(30)
>  #define RFKILL_BLOCK_SW_SETCALL	BIT(31)
>  
>  struct rfkill {
> @@ -176,6 +177,51 @@ static void rfkill_led_trigger_unregister(struct rfkill *rfkill)
>  {
>  	led_trigger_unregister(&rfkill->led_trigger);
>  }
> +
> +static struct led_trigger rfkill_any_led_trigger;
> +
> +static void __rfkill_any_led_trigger_event(void)
> +{
> +	enum led_brightness brightness = LED_OFF;
> +	struct rfkill *rfkill;
> +
> +	list_for_each_entry(rfkill, &rfkill_list, node) {
> +		if (!(rfkill->state & RFKILL_BLOCK_ANY)) {
> +			brightness = LED_FULL;
> +			break;
> +		}
> +	}
> +
> +	led_trigger_event(&rfkill_any_led_trigger, brightness);
> +}
> +
> +static void rfkill_any_led_trigger_event(bool global_locked)
> +{
> +	if (global_locked) {
> +		__rfkill_any_led_trigger_event();
> +	} else {
> +		mutex_lock(&rfkill_global_mutex);
> +		__rfkill_any_led_trigger_event();
> +		mutex_unlock(&rfkill_global_mutex);
> +	}
> +}
> +
> +static void rfkill_any_led_trigger_activate(struct led_classdev *led_cdev)
> +{
> +	rfkill_any_led_trigger_event(false);
> +}
> +
> +static int rfkill_any_led_trigger_register(void)
> +{
> +	rfkill_any_led_trigger.name = "rfkill-any";
> +	rfkill_any_led_trigger.activate = rfkill_any_led_trigger_activate;
> +	return led_trigger_register(&rfkill_any_led_trigger);
> +}
> +
> +static void rfkill_any_led_trigger_unregister(void)
> +{
> +	led_trigger_unregister(&rfkill_any_led_trigger);
> +}
>  #else
>  static void rfkill_led_trigger_event(struct rfkill *rfkill)
>  {
> @@ -189,6 +235,19 @@ static inline int rfkill_led_trigger_register(struct rfkill *rfkill)
>  static inline void rfkill_led_trigger_unregister(struct rfkill *rfkill)
>  {
>  }
> +
> +static void rfkill_any_led_trigger_event(bool global_locked)
> +{
> +}
> +
> +static int rfkill_any_led_trigger_register(void)
> +{
> +	return 0;
> +}
> +
> +static void rfkill_any_led_trigger_unregister(void)
> +{
> +}
>  #endif /* CONFIG_RFKILL_LEDS */
>  
>  static void rfkill_fill_event(struct rfkill_event *ev, struct rfkill *rfkill,
> @@ -253,6 +312,10 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
>  	if (unlikely(rfkill->dev.power.power_state.event & PM_EVENT_SLEEP))
>  		return;
>  
> +	spin_lock_irqsave(&rfkill->lock, flags);
> +	rfkill->state |= RFKILL_BLOCK_SW_HASLOCK;
> +	spin_unlock_irqrestore(&rfkill->lock, flags);
> +
>  	/*
>  	 * Some platforms (...!) generate input events which affect the
>  	 * _hard_ kill state -- whenever something tries to change the
> @@ -292,11 +355,13 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
>  			rfkill->state &= ~RFKILL_BLOCK_SW;
>  	}
>  	rfkill->state &= ~RFKILL_BLOCK_SW_SETCALL;
> +	rfkill->state &= ~RFKILL_BLOCK_SW_HASLOCK;
>  	rfkill->state &= ~RFKILL_BLOCK_SW_PREV;
>  	curr = rfkill->state & RFKILL_BLOCK_SW;
>  	spin_unlock_irqrestore(&rfkill->lock, flags);
>  
>  	rfkill_led_trigger_event(rfkill);
> +	rfkill_any_led_trigger_event(true);
>  
>  	if (prev != curr)
>  		rfkill_event(rfkill);
> @@ -463,7 +528,7 @@ bool rfkill_get_global_sw_state(const enum rfkill_type type)
>  bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
>  {
>  	unsigned long flags;
> -	bool ret, prev;
> +	bool ret, prev, global_locked;
>  
>  	BUG_ON(!rfkill);
>  
> @@ -474,9 +539,11 @@ bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
>  	else
>  		rfkill->state &= ~RFKILL_BLOCK_HW;
>  	ret = !!(rfkill->state & RFKILL_BLOCK_ANY);
> +	global_locked = !!(rfkill->state & RFKILL_BLOCK_SW_HASLOCK);
>  	spin_unlock_irqrestore(&rfkill->lock, flags);
>  
>  	rfkill_led_trigger_event(rfkill);
> +	rfkill_any_led_trigger_event(global_locked);
>  
>  	if (rfkill->registered && prev != blocked)
>  		schedule_work(&rfkill->uevent_work);
> @@ -502,7 +569,7 @@ static void __rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
>  bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
>  {
>  	unsigned long flags;
> -	bool prev, hwblock;
> +	bool prev, hwblock, global_locked;
>  
>  	BUG_ON(!rfkill);
>  
> @@ -511,6 +578,7 @@ bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
>  	__rfkill_set_sw_state(rfkill, blocked);
>  	hwblock = !!(rfkill->state & RFKILL_BLOCK_HW);
>  	blocked = blocked || hwblock;
> +	global_locked = !!(rfkill->state & RFKILL_BLOCK_SW_HASLOCK);
>  	spin_unlock_irqrestore(&rfkill->lock, flags);
>  
>  	if (!rfkill->registered)
> @@ -520,6 +588,7 @@ bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
>  		schedule_work(&rfkill->uevent_work);
>  
>  	rfkill_led_trigger_event(rfkill);
> +	rfkill_any_led_trigger_event(global_locked);
>  
>  	return blocked;
>  }
> @@ -542,7 +611,7 @@ EXPORT_SYMBOL(rfkill_init_sw_state);
>  void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
>  {
>  	unsigned long flags;
> -	bool swprev, hwprev;
> +	bool swprev, hwprev, global_locked;
>  
>  	BUG_ON(!rfkill);
>  
> @@ -559,6 +628,7 @@ void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
>  		rfkill->state |= RFKILL_BLOCK_HW;
>  	else
>  		rfkill->state &= ~RFKILL_BLOCK_HW;
> +	global_locked = !!(rfkill->state & RFKILL_BLOCK_SW_HASLOCK);
>  
>  	spin_unlock_irqrestore(&rfkill->lock, flags);
>  
> @@ -569,6 +639,7 @@ void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
>  			schedule_work(&rfkill->uevent_work);
>  
>  		rfkill_led_trigger_event(rfkill);
> +		rfkill_any_led_trigger_event(global_locked);
>  	}
>  }
>  EXPORT_SYMBOL(rfkill_set_states);
> @@ -812,8 +883,10 @@ static int rfkill_resume(struct device *dev)
>  	rfkill->suspended = false;
>  
>  	if (!rfkill->persistent) {
> +		mutex_lock(&rfkill_global_mutex);
>  		cur = !!(rfkill->state & RFKILL_BLOCK_SW);
>  		rfkill_set_block(rfkill, cur);
> +		mutex_unlock(&rfkill_global_mutex);
>  	}
>  
>  	if (rfkill->ops->poll && !rfkill->polling_paused)
> @@ -985,6 +1058,7 @@ int __must_check rfkill_register(struct rfkill *rfkill)
>  #endif
>  	}
>  
> +	rfkill_any_led_trigger_event(true);
>  	rfkill_send_events(rfkill, RFKILL_OP_ADD);
>  
>  	mutex_unlock(&rfkill_global_mutex);
> @@ -1017,6 +1091,7 @@ void rfkill_unregister(struct rfkill *rfkill)
>  	mutex_lock(&rfkill_global_mutex);
>  	rfkill_send_events(rfkill, RFKILL_OP_DEL);
>  	list_del_init(&rfkill->node);
> +	rfkill_any_led_trigger_event(true);
>  	mutex_unlock(&rfkill_global_mutex);
>  
>  	rfkill_led_trigger_unregister(rfkill);
> @@ -1269,6 +1344,10 @@ static int __init rfkill_init(void)
>  	if (error)
>  		goto error_misc;
>  
> +	error = rfkill_any_led_trigger_register();
> +	if (error)
> +		goto error_led_trigger;
> +
>  #ifdef CONFIG_RFKILL_INPUT
>  	error = rfkill_handler_init();
>  	if (error)
> @@ -1279,8 +1358,10 @@ static int __init rfkill_init(void)
>  
>  #ifdef CONFIG_RFKILL_INPUT
>  error_input:
> -	misc_deregister(&rfkill_miscdev);
> +	rfkill_any_led_trigger_unregister();
>  #endif
> +error_led_trigger:
> +	misc_deregister(&rfkill_miscdev);
>  error_misc:
>  	class_unregister(&rfkill_class);
>  error_class:
> @@ -1293,6 +1374,7 @@ static void __exit rfkill_exit(void)
>  #ifdef CONFIG_RFKILL_INPUT
>  	rfkill_handler_exit();
>  #endif
> +	rfkill_any_led_trigger_unregister();
>  	misc_deregister(&rfkill_miscdev);
>  	class_unregister(&rfkill_class);
>  }
> -- 
> 2.11.0
> 
