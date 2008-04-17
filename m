From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Fri, 18 Apr 2008 00:42:07 +0300
Message-ID: <4807C42F.9050409@teltonika.lt>
References: <200804161428.18066.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:45765 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165AbYDQVmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 17:42:23 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jmbs5-0006dR-Cc
	for netdev@vger.kernel.org; Thu, 17 Apr 2008 21:42:21 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 21:42:21 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 21:42:21 +0000
In-Reply-To: <200804161428.18066.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
>  /* called once for each interface upon device insertion */
>  static int hso_probe(struct usb_interface *interface,
>  		     const struct usb_device_id *id)
>  {
>  	int mux, i, if_num, port_spec;
>  	unsigned char port_mask;
> +	char *rfkn;
>  	struct hso_device *hso_dev = NULL;
>  	struct hso_shared_int *shared_int = NULL;
>  	struct hso_device *tmp_dev = NULL;
> @@ -2747,6 +2706,27 @@ static int hso_probe(struct usb_interfac
>  		goto exit;
>  	}
>  
> +	hso_dev->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
> +				RFKILL_TYPE_WLAN);

What will happen if rfkill is not enabled on kernel? I think HSO should
not depend on rfkill. Solution should be to do #ifdef CONFIG_RFKILL..?

> +	if (!hso_dev->rfkill)
> +		goto exit;
> +	rfkn = kzalloc(20, GFP_KERNEL);
> +	if (!rfkn) {
> +		rfkill_free(hso_dev->rfkill);
> +		goto exit;
> +	}
> +	snprintf(rfkn, 20, "hso-%d", if_num);
> +	hso_dev->rfkill->name = rfkn;
> +	hso_dev->rfkill->state = RFKILL_STATE_ON;
> +	hso_dev->rfkill->data = hso_dev;
> +	hso_dev->rfkill->toggle_radio = hso_radio_toggle;
> +	if (rfkill_register(hso_dev->rfkill) < 0) {
> +		kfree(rfkn);
> +		hso_dev->rfkill->name = NULL;
> +		rfkill_free(hso_dev->rfkill);
> +		goto exit;
> +	}
> +
>  	usb_driver_claim_interface(&hso_driver, interface, hso_dev);

Looks like it is possible to disable RF part of devices through sysfs...
Tomorrow I will upgrade to 2.6.25 and I will try to test it.

Paulius

