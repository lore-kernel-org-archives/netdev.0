From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 09:23:47 +0200
Message-ID: <2328167.HJRXSHNhKT@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1364832288.3059.12.camel@dcbw.foobar.com> <1365548547.23372.2.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:54555 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964899Ab3DJHYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 03:24:09 -0400
In-Reply-To: <1365548547.23372.2.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 April 2013 18:02:27 Dan Williams wrote:
> Some drivers (sierra_net) need the status interrupt URB
> active even when the device is closed, because they receive
> custom indications from firmware.  Add functions to refcount
> the status interrupt URB submit/kill operation so that
> sub-drivers and the generic driver don't fight over whether
> the status interrupt URB is active or not.
> 
> A sub-driver can call usbnet_status_start() at any time, but
> the URB is only submitted the first time the function is
> called.  Likewise, when the sub-driver is done with the URB,
> it calls usbnet_status_stop() but the URB is only killed when
> all users have stopped it.  The URB is still killed and
> re-submitted for suspend/resume, as before, with the same
> refcount it had at suspend.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
>  drivers/net/usb/usbnet.c   | 79 ++++++++++++++++++++++++++++++++++++++++++----
>  include/linux/usb/usbnet.h |  5 +++
>  2 files changed, 77 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 51f3192..e8b363a 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -42,7 +42,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/mii.h>
>  #include <linux/usb.h>
> -#include <linux/usb/usbnet.h>
> +#include "usbnet.h"
>  #include <linux/slab.h>
>  #include <linux/kernel.h>
>  #include <linux/pm_runtime.h>
> @@ -252,6 +252,70 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
>  	return 0;
>  }
>  
> +/* Submit the interrupt URB if it hasn't been submitted yet */
> +static int __usbnet_status_start(struct usbnet *dev, gfp_t mem_flags,
> +					bool force)
> +{
> +	int ret = 0;
> +	bool submit = false;
> +
> +	if (!dev->interrupt)
> +		return 0;
> +
> +	mutex_lock(&dev->interrupt_mutex);
> +
> +	if (force) {

That design means that interrupt_count isn't accurate if force is used.
That is extremely ugly.

> +		/* Only submit now if the URB was previously submitted */
> +		if (dev->interrupt_count)
> +			submit = true;
> +	} else if (++dev->interrupt_count == 1)
> +		submit = true;
> +
> +	if (submit)
> +		ret = usb_submit_urb(dev->interrupt, mem_flags);
> +
> +	dev_dbg(&dev->udev->dev, "incremented interrupt URB count to %d\n",
> +		dev->interrupt_count);
> +	mutex_unlock(&dev->interrupt_mutex);
> +	return ret;
> +}
> +
> +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> +{
> +	/* Only drivers that implement a status hook should call this */
> +	BUG_ON(dev->interrupt == NULL);
> +
> +	if (test_bit(EVENT_DEV_ASLEEP, &dev->flags))
> +		return -EINVAL;

This looks like a race condition.

> +	return __usbnet_status_start(dev, mem_flags, false);
> +}
> +EXPORT_SYMBOL_GPL(usbnet_status_start);
> +
> +/* Kill the interrupt URB if all submitters want it killed */
> +static void __usbnet_status_stop(struct usbnet *dev, bool force)
> +{
> +	if (dev->interrupt) {
> +		mutex_lock(&dev->interrupt_mutex);
> +		if (!force)
> +			BUG_ON(dev->interrupt_count == 0);
> +
> +		if (force || --dev->interrupt_count == 0)
> +			usb_kill_urb(dev->interrupt);

Why so complicated? If it may be on, kill it unconditionally.

> +
> +		dev_dbg(&dev->udev->dev,
> +			"decremented interrupt URB count to %d\n",
> +			dev->interrupt_count);
> +		mutex_unlock(&dev->interrupt_mutex);
> +	}
> +}
> +

	Regards
		Oliver
