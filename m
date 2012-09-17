From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [RFC PATCH 3/3] usbnet: support runtime PM triggered by link change
Date: Mon, 17 Sep 2012 21:07:22 +0800
Message-ID: <CACVXFVPw-oeze4Wu12pBKTuydYfQm5JC7g2EB5VAxVbH6i6aBQ@mail.gmail.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
	<1347731299-29898-4-git-send-email-ming.lei@canonical.com>
	<3287943.Bzm0t1oGWG@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fink Dmitry <finik@ti.com>, Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60010 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604Ab2IQNHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 09:07:24 -0400
In-Reply-To: <3287943.Bzm0t1oGWG@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 17, 2012 at 4:50 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Sunday 16 September 2012 01:48:19 Ming Lei wrote:
>
>
>> +void usbnet_link_updated(struct usbnet *dev)
>> +{
>> +     complete(&dev->link_update_completion);
>> +}
>> +EXPORT_SYMBOL_GPL(usbnet_link_updated);
>
> Isn't that a bit too trivial to get the _GPL version?

OK, will use the non GPL version.

>
>> +#define usbnet_link_suspend(dev) do { \
>> +     dev_dbg(&dev->intf->dev, "%s:link suspend", __func__); \
>> +     usb_autopm_put_interface_async(dev->intf); \
>> +} while(0)
>> +
>> +#define usbnet_link_resume(dev) do { \
>> +     dev_dbg(&dev->intf->dev, "%s:link resume", __func__); \
>> +     usb_autopm_get_interface_async(dev->intf); \
>> +} while(0)
>
> Why macros?

Just for easy debug by dumping the caller function name.

>
>
> [..]
>> +/* called by usbnet_open */
>> +static void enable_link_runtime_pm(struct usbnet *dev)
>> +{
>> +     dev->link_rpm_enabled = 1;
>> +
>> +     if (!dev->link_remote_wakeup) {
>> +             dev->old_autosuspend_delay =
>> +                     dev->udev->dev.power.autosuspend_delay;
>> +             pm_runtime_set_autosuspend_delay(&dev->udev->dev, 1);
>
> This is a problem. Suppose the user changes the autosuspend timeout.
> You cannot assume that the old value remains valid.

Good catch, I will fix it in -v1 by reading again the timeout value in
disable_link_runtime_pm().

>> +     }
>> +
>> +     if (!netif_carrier_ok(dev->net)) {
>> +             dev->link_open_suspend = 1;
>> +             usbnet_link_suspend(dev);
>> +     }
>> +}
>
>> +static void update_link_state(struct usbnet *dev)
>> +{
>> +     char            *buf = NULL;
>> +     unsigned        pipe = 0;
>> +     unsigned        maxp;
>> +     int             ret, act_len, timeout;
>> +     struct urb      urb;
>> +
>> +     pipe = usb_rcvintpipe(dev->udev,
>> +                           dev->status->desc.bEndpointAddress
>> +                             & USB_ENDPOINT_NUMBER_MASK);
>> +     maxp = usb_maxpacket(dev->udev, pipe, 0);
>> +
>> +     /*
>> +      * Take default timeout as 2 times of period.
>> +      * It is observed that asix device can update its link
>> +      * state duing one period(128ms). Low level driver can set
>> +      * its default update link time in bind() callback.
>> +      */
>> +     if (!dev->link_update_timeout) {
>> +             timeout = max((int) dev->status->desc.bInterval,
>> +                     (dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
>> +             timeout = 1 << timeout;
>> +             if (dev->udev->speed == USB_SPEED_HIGH)
>> +                     timeout /= 8;
>> +             if (timeout < 128)
>> +                     timeout = 128;
>> +     } else
>> +             timeout = dev->link_update_timeout;
>> +
>> +     buf = kmalloc(maxp, GFP_KERNEL);
>> +     if (!buf)
>> +             return;
>> +
>> +     dev_dbg(&dev->intf->dev, "%s: timeout %dms\n", __func__, timeout);
>> +     ret = usb_interrupt_msg(dev->udev, pipe, buf, maxp,
>> +                     &act_len, timeout);
>> +     if (!ret) {
>> +             urb.status = 0;
>> +             urb.actual_length = act_len;
>> +             urb.transfer_buffer = buf;
>> +             urb.transfer_buffer_length = maxp;
>> +             dev->driver_info->status(dev, &urb);
>> +             if (dev->driver_info->flags &
>> +                 FLAG_LINK_UPDATE_BY_DRIVER)
>> +                     wait_for_completion(&dev->link_update_completion);
>
> If a driver calls usbnet_link_updated() from the same workqueue this
> will deadlock.

Good catch, I will fix it in -v1 by using system_freezable_wq.

>
>> +             dev_dbg(&dev->intf->dev, "%s: link updated\n", __func__);
>> +     } else
>> +             dev_dbg(&dev->intf->dev, "%s: link update failed %d\n",
>> +                             __func__, ret);
>> +     kfree(buf);
>> +}
>
> [..]
>> @@ -795,6 +977,9 @@ int usbnet_open (struct net_device *net)
>>               if (retval < 0)
>>                       goto done_manage_power_error;
>>               usb_autopm_put_interface(dev->intf);
>> +     } else {
>> +             if (need_link_runtime_pm(dev))
>> +                     enable_link_runtime_pm(dev);
>>       }
>>       return retval;
>>
>> @@ -1489,6 +1674,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>>       if (dev->driver_info->flags & FLAG_LINK_INTR)
>>               usbnet_link_change(dev, 0, 0);
>>
>> +     init_link_rpm(dev);
>> +
>>       return 0;
>>
>>  out4:
>> @@ -1538,6 +1725,9 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
>>                * wake the device
>>                */
>>               netif_device_attach (dev->net);
>> +
>> +             if (PMSG_IS_AUTO(message))
>> +                     start_link_detect(dev);
>
> What happens if the device is autosuspended, then the system is suspended
> and the work is executed while the suspension is underway?

IMO we can avoid the problem by scheduling 'link_detect_work' on the
workqueue of 'system_freezable_wq', which will be introduced in -v1.

>
>>       }
>>       return 0;
>>  }
>> @@ -1552,8 +1742,10 @@ int usbnet_resume (struct usb_interface *intf)
>>
>>       if (!--dev->suspend_count) {
>>               /* resume interrupt URBs */
>> -             if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
>> -                     usb_submit_urb(dev->interrupt, GFP_NOIO);
>> +             if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags)) {
>> +                     if (!dev->link_checking)
>
> That is impossible. If the device is resumed the interrupt URB must
> be restarted in every case (if it exists).

The interrupt URB will be submitted later in link_detect_work() under
the situation of being resumed by link detect work.

> You cannot assume that its only function is checking the link state.
> And it introduces a race with the workqueue.

Looks no race because usbnet_resume() will be run in workqueue
task context under the situation of being resumed by link detect work.


Thanks,
--
Ming Lei
