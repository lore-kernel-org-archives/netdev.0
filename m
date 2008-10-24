From: Per Hallsmark <per.hallsmark-8A+B91M1NdOzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Fri, 24 Oct 2008 11:21:22 +0200
Message-ID: <49019392.3050306@t2data.se>
References: <Pine.LNX.4.44L0.0810231455020.18234-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.0810231455020.18234-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alan Stern wrote:
> On Thu, 23 Oct 2008, Per Hallsmark wrote:
>
>   
>> Enable more aggressive autosuspend in usbnet.
>> Some commenting and cleanups done.
>> Signed-off-by: Per Hallsmark <per-46Ss7X5r2El6nIa31vAvqA@public.gmane.org>
>>     
>
> I've been considering submitting the patch below.  It would help your 
> work; you could remove all the "waker" stuff.
>   
So, if I understand the patch correctly, the waker's in cdc-acm, cdc-wdm 
and usbnet
could then be removed and a change to use *_async() should be done?
I work with a module that have usb interfaces driven by above three 
drivers so it
could be a good testing case I guess.
Generic solutions are the best so if this approach would work then of 
course a
change should be made I think. I have no time to test it in near time 
though,
perhaps later next week.
> Do you think it would be worthwhile?
>
> Alan Stern
>
>
>
> Index: usb-2.6/Documentation/usb/power-management.txt
> ===================================================================
> --- usb-2.6.orig/Documentation/usb/power-management.txt
> +++ usb-2.6/Documentation/usb/power-management.txt
> @@ -313,11 +313,13 @@ three of the methods listed above.  In a
>  that it supports autosuspend by setting the .supports_autosuspend flag
>  in its usb_driver structure.  It is then responsible for informing the
>  USB core whenever one of its interfaces becomes busy or idle.  The
> -driver does so by calling these three functions:
> +driver does so by calling these five functions:
>  
>  	int  usb_autopm_get_interface(struct usb_interface *intf);
>  	void usb_autopm_put_interface(struct usb_interface *intf);
>  	int  usb_autopm_set_interface(struct usb_interface *intf);
> +	int  usb_autopm_get_interface_async(struct usb_interface *intf);
> +	void usb_autopm_put_interface_async(struct usb_interface *intf);
>  
>  The functions work by maintaining a counter in the usb_interface
>  structure.  When intf->pm_usage_count is > 0 then the interface is
> @@ -330,10 +332,12 @@ associated with the device itself rather
>  This field is used only by the USB core.)
>  
>  The driver owns intf->pm_usage_count; it can modify the value however
> -and whenever it likes.  A nice aspect of the usb_autopm_* routines is
> -that the changes they make are protected by the usb_device structure's
> -PM mutex (udev->pm_mutex); however drivers may change pm_usage_count
> -without holding the mutex.
> +and whenever it likes.  A nice aspect of the non-async usb_autopm_*
> +routines is that the changes they make are protected by the usb_device
> +structure's PM mutex (udev->pm_mutex); however drivers may change
> +pm_usage_count without holding the mutex.  Drivers using the async
> +routines are responsible for their own synchronization and mutual
> +exclusion.
>  
>  	usb_autopm_get_interface() increments pm_usage_count and
>  	attempts an autoresume if the new value is > 0 and the
> @@ -348,6 +352,14 @@ without holding the mutex.
>  	is suspended, and it attempts an autosuspend if the value is
>  	<= 0 and the device isn't suspended.
>  
> +	usb_autopm_get_interface_async() and
> +	usb_autopm_put_interface_async() do almost the same things as
> +	their non-async counterparts.  The differences are: they do
> +	not acquire the PM mutex, and they use a workqueue to do their
> +	jobs.  As a result they can be called in an atomic context,
> +	such as an URB's completion handler, but when they return the
> +	device will not generally not yet be in the desired state.
> +
>  There also are a couple of utility routines drivers can use:
>  
>  	usb_autopm_enable() sets pm_usage_cnt to 0 and then calls
> Index: usb-2.6/include/linux/usb.h
> ===================================================================
> --- usb-2.6.orig/include/linux/usb.h
> +++ usb-2.6/include/linux/usb.h
> @@ -396,6 +396,7 @@ struct usb_tt;
>   * @urbnum: number of URBs submitted for the whole device
>   * @active_duration: total time device is not suspended
>   * @autosuspend: for delayed autosuspends
> + * @autoresume: for autoresumes requested while in_interrupt
>   * @pm_mutex: protects PM operations
>   * @last_busy: time of last use
>   * @autosuspend_delay: in jiffies
> @@ -474,6 +475,7 @@ struct usb_device {
>  
>  #ifdef CONFIG_PM
>  	struct delayed_work autosuspend;
> +	struct work_struct autoresume;
>  	struct mutex pm_mutex;
>  
>  	unsigned long last_busy;
> @@ -511,6 +513,8 @@ extern struct usb_device *usb_find_devic
>  extern int usb_autopm_set_interface(struct usb_interface *intf);
>  extern int usb_autopm_get_interface(struct usb_interface *intf);
>  extern void usb_autopm_put_interface(struct usb_interface *intf);
> +extern int usb_autopm_get_interface_async(struct usb_interface *intf);
> +extern void usb_autopm_put_interface_async(struct usb_interface *intf);
>  
>  static inline void usb_autopm_enable(struct usb_interface *intf)
>  {
> @@ -537,8 +541,13 @@ static inline int usb_autopm_set_interfa
>  static inline int usb_autopm_get_interface(struct usb_interface *intf)
>  { return 0; }
>  
> +static inline int usb_autopm_get_interface_async(struct usb_interface *intf)
> +{ return 0; }
> +
>  static inline void usb_autopm_put_interface(struct usb_interface *intf)
>  { }
> +static inline void usb_autopm_put_interface_async(struct usb_interface *intf)
> +{ }
>  static inline void usb_autopm_enable(struct usb_interface *intf)
>  { }
>  static inline void usb_autopm_disable(struct usb_interface *intf)
> Index: usb-2.6/drivers/usb/core/usb.h
> ===================================================================
> --- usb-2.6.orig/drivers/usb/core/usb.h
> +++ usb-2.6/drivers/usb/core/usb.h
> @@ -45,6 +45,7 @@ extern int usb_suspend(struct device *de
>  extern int usb_resume(struct device *dev);
>  
>  extern void usb_autosuspend_work(struct work_struct *work);
> +extern void usb_autoresume_work(struct work_struct *work);
>  extern int usb_port_suspend(struct usb_device *dev);
>  extern int usb_port_resume(struct usb_device *dev);
>  extern int usb_external_suspend_device(struct usb_device *udev,
> Index: usb-2.6/drivers/usb/core/usb.c
> ===================================================================
> --- usb-2.6.orig/drivers/usb/core/usb.c
> +++ usb-2.6/drivers/usb/core/usb.c
> @@ -402,6 +402,7 @@ struct usb_device *usb_alloc_dev(struct 
>  #ifdef	CONFIG_PM
>  	mutex_init(&dev->pm_mutex);
>  	INIT_DELAYED_WORK(&dev->autosuspend, usb_autosuspend_work);
> +	INIT_WORK(&dev->autoresume, usb_autoresume_work);
>  	dev->autosuspend_delay = usb_autosuspend_delay * HZ;
>  	dev->connect_time = jiffies;
>  	dev->active_duration = -jiffies;
> Index: usb-2.6/drivers/usb/core/hub.c
> ===================================================================
> --- usb-2.6.orig/drivers/usb/core/hub.c
> +++ usb-2.6/drivers/usb/core/hub.c
> @@ -1362,8 +1362,9 @@ static void usb_stop_pm(struct usb_devic
>  		usb_autosuspend_device(udev->parent);
>  	usb_pm_unlock(udev);
>  
> -	/* Stop any autosuspend requests already submitted */
> -	cancel_rearming_delayed_work(&udev->autosuspend);
> +	/* Stop any autosuspend or autoresume requests already submitted */
> +	cancel_delayed_work_sync(&udev->autosuspend);
> +	cancel_work_sync(&udev->autoresume);
>  }
>  
>  #else
> Index: usb-2.6/drivers/usb/core/driver.c
> ===================================================================
> --- usb-2.6.orig/drivers/usb/core/driver.c
> +++ usb-2.6/drivers/usb/core/driver.c
> @@ -1339,6 +1339,19 @@ void usb_autosuspend_work(struct work_st
>  	usb_autopm_do_device(udev, 0);
>  }
>  
> +/* usb_autoresume_work - callback routine to autoresume a USB device */
> +void usb_autoresume_work(struct work_struct *work)
> +{
> +	struct usb_device *udev =
> +		container_of(work, struct usb_device, autoresume);
> +
> +	/* Wake it up, let the drivers do their thing, and then put it
> +	 * back to sleep.
> +	 */
> +	if (usb_autopm_do_device(udev, 1) == 0)
> +		usb_autopm_do_device(udev, -1);
> +}
> +
>  /**
>   * usb_autosuspend_device - delayed autosuspend of a USB device and its interfaces
>   * @udev: the usb_device to autosuspend
> @@ -1490,6 +1503,45 @@ void usb_autopm_put_interface(struct usb
>  EXPORT_SYMBOL_GPL(usb_autopm_put_interface);
>  
>  /**
> + * usb_autopm_put_interface_async - decrement a USB interface's PM-usage counter
> + * @intf: the usb_interface whose counter should be decremented
> + *
> + * This routine does essentially the same thing as
> + * usb_autopm_put_interface(): it decrements @intf's usage counter and
> + * queues a delayed autosuspend request if the counter is <= 0.  The
> + * difference is that it does not acquire the device's pm_mutex;
> + * callers must handle all synchronization issues themselves.
> + *
> + * Typically a driver would call this routine during an URB's completion
> + * handler, if no more URBs were pending.
> + *
> + * This routine can run in atomic context.
> + */
> +void usb_autopm_put_interface_async(struct usb_interface *intf)
> +{
> +	struct usb_device	*udev = interface_to_usbdev(intf);
> +	int			status = 0;
> +
> +	if (intf->condition == USB_INTERFACE_UNBOUND) {
> +		status = -ENODEV;
> +	} else {
> +		udev->last_busy = jiffies;
> +		--intf->pm_usage_cnt;
> +		if (udev->autosuspend_disabled || udev->autosuspend_delay < 0)
> +			status = -EPERM;
> +		else if (intf->pm_usage_cnt <= 0 &&
> +				!timer_pending(&udev->autosuspend.timer)) {
> +			queue_delayed_work(ksuspend_usb_wq, &udev->autosuspend,
> +					round_jiffies_relative(
> +						udev->autosuspend_delay));
> +		}
> +	}
> +	dev_vdbg(&intf->dev, "%s: status %d cnt %d\n",
> +			__func__, status, intf->pm_usage_cnt);
> +}
> +EXPORT_SYMBOL_GPL(usb_autopm_put_interface_async);
> +
> +/**
>   * usb_autopm_get_interface - increment a USB interface's PM-usage counter
>   * @intf: the usb_interface whose counter should be incremented
>   *
> @@ -1535,6 +1587,37 @@ int usb_autopm_get_interface(struct usb_
>  EXPORT_SYMBOL_GPL(usb_autopm_get_interface);
>  
>  /**
> + * usb_autopm_get_interface_async - increment a USB interface's PM-usage counter
> + * @intf: the usb_interface whose counter should be incremented
> + *
> + * This routine does much the same thing as
> + * usb_autopm_get_interface(): it increments @intf's usage counter and
> + * queues an autoresume request if the result is > 0.  The differences
> + * are that it does not acquire the device's pm_mutex (callers must
> + * handle all synchronization issues themselves), and it does not
> + * autoresume the device directly (it only queues a request).  After a
> + * successful call, the device will generally not yet be resumed.
> + *
> + * This routine can run in atomic context.
> + */
> +int usb_autopm_get_interface_async(struct usb_interface *intf)
> +{
> +	struct usb_device	*udev = interface_to_usbdev(intf);
> +	int			status = 0;
> +
> +	if (intf->condition == USB_INTERFACE_UNBOUND)
> +		status = -ENODEV;
> +	else if (udev->autoresume_disabled)
> +		status = -EPERM;
> +	else if (++intf->pm_usage_cnt > 0 && udev->state == USB_STATE_SUSPENDED)
> +		queue_work(ksuspend_usb_wq, &udev->autoresume);
> +	dev_vdbg(&intf->dev, "%s: status %d cnt %d\n",
> +			__func__, status, intf->pm_usage_cnt);
> +	return status;
> +}
> +EXPORT_SYMBOL_GPL(usb_autopm_get_interface_async);
> +
> +/**
>   * usb_autopm_set_interface - set a USB interface's autosuspend state
>   * @intf: the usb_interface whose state should be set
>   *
>
>   


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
