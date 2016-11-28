From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] NET: usb: cdc_ncm: adding MBIM RESET_FUNCTION request
 and modifying ncm bind common code
Date: Mon, 28 Nov 2016 12:23:56 +0100
Message-ID: <CAGRyCJFfNj4C_pNXWhMT7tVvdV4ZFzJ5d+LFAatvQmTuWU7OUg@mail.gmail.com>
References: <1479904606-30647-1-git-send-email-dnlplm@gmail.com>
 <1479904606-30647-2-git-send-email-dnlplm@gmail.com> <87k2bq7zn8.fsf@miraculix.mork.no>
 <87fume7xg5.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
        linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87fume7xg5.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2016-11-26 22:17 GMT+01:00 Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>:
> Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:
>
>> Finally, I found my modems (or at least a number of them) again today.
>> But I'm sorry to say, that the troublesome Huawei E3372h-153 is still
>> giving us a hard time.  It does not work with your patch. The symptom is
>> the same as earlier:  The modem returns MBIM frames with 32bit headers.
>>
>> So for now, I have to NAK this patch.
>>
>> I am sure we can find a good solution that makes all of these modems
>> work, but I cannot support a patch that breaks previously working
>> configurations. Sorry.  I'll do a few experiments and see if there is a
>> simple fix for this.  Otherwise we'll probably have to do the quirk
>> game.
>
>
> This is a proof-of-concept only, but it appears to be working.  Please
> test with your device(s) too.  It's still mostly your code, as you can
> see.

Sorry, this does not work :-(

The problem is always in the altsetting toggle: if I comment that
part, your patch is working fine.

I'm now wondering if the safest thing is to add a very simple quirk in
cdc_mbim that makes this toggle not to be applied with the buggy
modems and then unconditionally add the RESET_FUNCTION request in
cdc_mbim_bind after cdc_ncm_bind_common has been executed.

Daniele

>
> If this turns out to work, then I believe we should refactor
> cdc_ncm_init() and cdc_ncm_bind_common() to make the whole
> initialisation sequence a bit cleaner.  And maybe also include
> cdc_mbim_bind().  Ideally, the MBIM specific RESET should happen there
> instead of "polluting" the NCM driver with MBIM specific code.
>
> But anyway:  The sequence that seems to work for both the  E3372h-153
> and the EM7455 is
>
>  USB_CDC_GET_NTB_PARAMETERS
>  USB_CDC_RESET_FUNCTION
>  usb_set_interface(dev->udev, 'data interface no', 0);
>  remaining parts of cdc_ncm_init(), excluding USB_CDC_GET_NTB_PARAMETERS
>  usb_set_interface(dev->udev, 'data interface no', 'data alt setting');
>
> without any additional delay between the two usb_set_interface() calls.
> So the major difference from your patch is that I moved the two control
> requests out of cdc_ncm_init() to allow running them _before_ setting
> the data interface to altsetting 0.
>
> But maybe I was just lucky.  This was barely proof tested.  Needs a lot
> more testing and cleanups as suggested.  I'd appreciate it if you
> continued that, as I don't really have any time for it...
>
> FWIW, I also ran a quick test with a D-Link DWM-156A7 (Mediatek MBIM
> firmware) and a Huawei E367 (Qualcomm device with early Huawei MBIM
> firmware, distinctly different from the E3372h-153 and most other
> MBIM devices I've seen)
>
>
>
> Bj=C3=B8rn
>
> ---
>  drivers/net/usb/cdc_ncm.c    | 48 ++++++++++++++++++++++++++++----------=
------
>  include/uapi/linux/usb/cdc.h |  1 +
>  2 files changed, 32 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 877c9516e781..be019cbf1719 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -488,16 +488,6 @@ static int cdc_ncm_init(struct usbnet *dev)
>         u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumb=
er;
>         int err;
>
> -       err =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
> -                             USB_TYPE_CLASS | USB_DIR_IN
> -                             |USB_RECIP_INTERFACE,
> -                             0, iface_no, &ctx->ncm_parm,
> -                             sizeof(ctx->ncm_parm));
> -       if (err < 0) {
> -               dev_err(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
> -               return err; /* GET_NTB_PARAMETERS is required */
> -       }
> -
>         /* set CRC Mode */
>         if (cdc_ncm_flags(dev) & USB_CDC_NCM_NCAP_CRC_MODE) {
>                 dev_dbg(&dev->intf->dev, "Setting CRC mode off\n");
> @@ -837,12 +827,43 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct =
usb_interface *intf, u8 data_
>                 }
>         }
>
> +       iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumber;
> +       temp =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
> +                              USB_TYPE_CLASS | USB_DIR_IN
> +                              | USB_RECIP_INTERFACE,
> +                              0, iface_no, &ctx->ncm_parm,
> +                              sizeof(ctx->ncm_parm));
> +       if (temp < 0) {
> +               dev_err(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
> +               goto error; /* GET_NTB_PARAMETERS is required */
> +       }
> +
> +       /* Some modems (e.g. Telit LE922A6) need to reset the MBIM functi=
on
> +        * or they will fail to work properly.
> +        * For details on RESET_FUNCTION request see document
> +        * "USB Communication Class Subclass Specification for MBIM"
> +        * RESET_FUNCTION should be harmless for all the other MBIM modem=
s
> +        */
> +       if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
> +               temp =3D usbnet_write_cmd(dev, USB_CDC_RESET_FUNCTION,
> +                                       USB_TYPE_CLASS | USB_DIR_OUT
> +                                       | USB_RECIP_INTERFACE,
> +                                       0, iface_no, NULL, 0);
> +               if (temp < 0)
> +                       dev_err(&dev->intf->dev, "failed RESET_FUNCTION\n=
");
> +       }
> +
>         iface_no =3D ctx->data->cur_altsetting->desc.bInterfaceNumber;
>
>         /* Reset data interface. Some devices will not reset properly
>          * unless they are configured first.  Toggle the altsetting to
>          * force a reset
> +        * This is applied only to ncm devices, since it has been verifie=
d
> +        * to cause issues with some MBIM modems (e.g. Telit LE922A6).
> +        * MBIM devices reset is achieved using MBIM request RESET_FUNCTI=
ON
> +        * in cdc_ncm_init
>          */
> +
>         usb_set_interface(dev->udev, iface_no, data_altsetting);
>         temp =3D usb_set_interface(dev->udev, iface_no, 0);
>         if (temp) {
> @@ -854,13 +875,6 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct u=
sb_interface *intf, u8 data_
>         if (cdc_ncm_init(dev))
>                 goto error2;
>
> -       /* Some firmwares need a pause here or they will silently fail
> -        * to set up the interface properly.  This value was decided
> -        * empirically on a Sierra Wireless MC7455 running 02.08.02.00
> -        * firmware.
> -        */
> -       usleep_range(10000, 20000);
> -
>         /* configure data interface */
>         temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
>         if (temp) {
> diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cdc.h
> index e2bc417b243b..30258fb229e6 100644
> --- a/include/uapi/linux/usb/cdc.h
> +++ b/include/uapi/linux/usb/cdc.h
> @@ -231,6 +231,7 @@ struct usb_cdc_mbim_extended_desc {
>
>  #define USB_CDC_SEND_ENCAPSULATED_COMMAND      0x00
>  #define USB_CDC_GET_ENCAPSULATED_RESPONSE      0x01
> +#define USB_CDC_RESET_FUNCTION                 0x05
>  #define USB_CDC_REQ_SET_LINE_CODING            0x20
>  #define USB_CDC_REQ_GET_LINE_CODING            0x21
>  #define USB_CDC_REQ_SET_CONTROL_LINE_STATE     0x22
> --
> 2.10.2
>
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
