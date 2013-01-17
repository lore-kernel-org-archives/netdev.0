From: Wei Shuai <cpuwolf@gmail.com>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem platform
Date: Thu, 17 Jan 2013 14:44:14 +0800
Message-ID: <CACa7zyntkL4egpO-XAKe=rmf=A3Zd2WmB4PO0XfHv7KsOb464Q@mail.gmail.com>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
	<1358372743.8713.0.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34353 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab3AQGwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 01:52:24 -0500
In-Reply-To: <1358372743.8713.0.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, I will follow up. after add FLAG_NOARP, how should I handle
IFF_NOARP? will I do it in cdc_ncm.c or usb_net.c?

2013/1/17 Dan Williams <dcbw@redhat.com>:
> On Sat, 2013-01-12 at 19:34 +0800, Wei Shuai wrote:
>> Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in driver_info:data. so later on, if more such buggy devices are found, they could use same flag to handle.
>
> So given that Dave now approves of IFF_NOARP, let's change your original
> patch to add a FLAG_NOARP for the .flags structure instead of inventing
> another mechanism for .data.
>
> Dan
>
>> Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
>> ---
>>  drivers/net/usb/cdc_ncm.c |   29 +++++++++++++++++++++++++++++
>>  1 files changed, 29 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
>> index 71b6e92..6093e07 100644
>> --- a/drivers/net/usb/cdc_ncm.c
>> +++ b/drivers/net/usb/cdc_ncm.c
>> @@ -55,6 +55,9 @@
>>
>>  #define      DRIVER_VERSION                          "14-Mar-2012"
>>
>> +/* Flags for driver_info::data */
>> +#define CDC_NCM_DRIVER_DATA_NOARP  1
>> +
>>  static void cdc_ncm_txpath_bh(unsigned long param);
>>  static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
>>  static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
>> @@ -573,6 +576,10 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
>>               return -ENODEV;
>>  #endif
>>
>> +     if (dev->driver_info->data & CDC_NCM_DRIVER_DATA_NOARP) {
>> +             /* some buggy device cannot do ARP*/
>> +             dev->net->flags |= IFF_NOARP;
>> +     }
>>       /* NCM data altsetting is always 1 */
>>       ret = cdc_ncm_bind_common(dev, intf, 1);
>>
>> @@ -1155,6 +1162,21 @@ static const struct driver_info wwan_info = {
>>       .tx_fixup = cdc_ncm_tx_fixup,
>>  };
>>
>> +/* Same as wwan_info, but with IFF_NOARP  */
>> +static const struct driver_info wwan_noarp_info = {
>> +     .description = "Mobile Broadband Network Device (NO ARP)",
>> +     .flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
>> +                     | FLAG_WWAN,
>> +     .data = CDC_NCM_DRIVER_DATA_NOARP,
>> +     .bind = cdc_ncm_bind,
>> +     .unbind = cdc_ncm_unbind,
>> +     .check_connect = cdc_ncm_check_connect,
>> +     .manage_power = usbnet_manage_power,
>> +     .status = cdc_ncm_status,
>> +     .rx_fixup = cdc_ncm_rx_fixup,
>> +     .tx_fixup = cdc_ncm_tx_fixup,
>> +};
>> +
>>  static const struct usb_device_id cdc_devs[] = {
>>       /* Ericsson MBM devices like F5521gw */
>>       { .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
>> @@ -1194,6 +1216,13 @@ static const struct usb_device_id cdc_devs[] = {
>>         .driver_info = (unsigned long)&wwan_info,
>>       },
>>
>> +     /* Infineon(now Intel) HSPA Modem platform */
>> +     { USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
>> +             USB_CLASS_COMM,
>> +             USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
>> +       .driver_info = (unsigned long)&wwan_noarp_info,
>> +     },
>> +
>>       /* Generic CDC-NCM devices */
>>       { USB_INTERFACE_INFO(USB_CLASS_COMM,
>>               USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
>
>
