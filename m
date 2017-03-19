From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: Add USB IDs for MDM6600 modem on Motorola Droid 4
Date: Sun, 19 Mar 2017 18:20:59 +0100
Message-ID: <87fui95gjo.fsf@miraculix.mork.no>
References: <20170319161957.6625-1-tony@atomide.com>
        <87lgs15iun.fsf@miraculix.mork.no>
        <20170319170254.GB20572@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, Marcel Partap <mpartap@gmx.net>,
        Michael Scott <michael.scott@linaro.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38835 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752242AbdCSRVP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 13:21:15 -0400
In-Reply-To: <20170319170254.GB20572@atomide.com> (Tony Lindgren's message of
        "Sun, 19 Mar 2017 10:02:55 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tony Lindgren <tony@atomide.com> writes:
> * Bj=C3=B8rn Mork <bjorn@mork.no> [170319 09:33]:
>> Tony Lindgren <tony@atomide.com> writes:
>>=20
>> > This gets qmicli working with the MDM6600 modem.
>> >
>> > Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
>> > Reviewed-by: Sebastian Reichel <sre@kernel.org>
>> > Tested-by: Sebastian Reichel <sre@kernel.org>
>> > Signed-off-by: Tony Lindgren <tony@atomide.com>
>> > ---
>> >  drivers/net/usb/qmi_wwan.c | 4 ++++
>> >  1 file changed, 4 insertions(+)
>> >
>> > diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
>> > --- a/drivers/net/usb/qmi_wwan.c
>> > +++ b/drivers/net/usb/qmi_wwan.c
>> > @@ -580,6 +580,10 @@ static const struct usb_device_id products[] =3D {
>> >  		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SP=
EC, 0x01, 0x69),
>> >  		.driver_info        =3D (unsigned long)&qmi_wwan_info,
>> >  	},
>> > +	{	/* Motorola Mapphone devices with MDM6600 */
>> > +		USB_VENDOR_AND_INTERFACE_INFO(0x22b8, USB_CLASS_VENDOR_SPEC, 0xfb, =
0xff),
>>=20
>>=20
>> This is a bit unusual, so I'd like to verify that it is correct.  Do you
>> happen to have a "lsusb -v" or /sys/kernel/debug/usb/devices dump for
>> this device?  Is this usage of vendor + class consistent with the
>> Windows driver *.inf data?  Are you sure that the ff/fb/ff class is only
>> used for QMI functions by this vendor ID?=20
>
> Well this is based on what the earlier Motorola mapphone v3.8 kernel has
> for in drivers/net/usb/qcusbnet/qcusbnet.c driver:
>
> +       { /* Motorola Xoom */
> +       USB_DEVICE_AND_INTERFACE_INFO(0x22B8, 0x2A70, 0xff, 0xfb, 0xff),
> +       .driver_info =3D (unsigned long)&xoom_qc_netinfo
> +       },
> +       { /* MDM9600 */
> +       USB_DEVICE_AND_INTERFACE_INFO(0x22B8, 0x2E0A, 0xff, 0xfb, 0xff),
> +       .driver_info =3D (unsigned long)&mdm9600_qc_netinfo
> +       },

That helps a lot. Was not aware of this driver.

> Where the "Motorola Xoom" id is also used for all mapphone devices
> with MDM6600 variants.
>
> Then xoom_qc_netinfo in the mapphone kernel has:
>
> +static const struct driver_info xoom_qc_netinfo =3D {
> +       .description   =3D "Xoom QCUSBNet Ethernet Device",
> +       .flags         =3D FLAG_ETHER|FLAG_SEND_ZLP,
> +       .bind          =3D xoom_qcnet_bind,
> +       .unbind        =3D qcnet_unbind,
> +       .data          =3D 0,
> +       .manage_power  =3D qcnet_manage_power,
> +};
>
> And the v3.8 kernel also has drivers/usb/serial/mdm6600.c:
>
> +static const struct usb_device_id mdm6600_id_table[] =3D {
> +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a70, 0xff, 0xff, 0xff)=
 },
> +        /* MDM9600 */
> +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2e0a, 0xff, 0xff, 0xff)=
 },
> +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x900e, 0xff, 0xff, 0xff)=
 },
> +       { },
> +};


Yes, looks like they consitently use ff/ff/ff for serial functions and
ff/fb/ff for QMI functions.  So adding a vendor rule seems appropriate.


> And then in drivers/usb/serial/moto_flashqsc.c:
>
> +static struct usb_device_id id_table[] =3D {
> +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a63, 0x0a, 0, 0)},
> +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x4281, 0x0a, 0, 0xfc)},
> +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2db4, 0x0a, 0, 0xfc)},
> +       {USB_DEVICE(0x22b8, 0x4260)},
> +       {USB_DEVICE(0x22b8, 0x426D)},
> +       {},
> +};

This on the other hand, is something I hope I don't have to review :)
The 0x0a class (CDC Data) is always part of a multi-interface function,
and you would normally match on the control interface.

> Where the 0x4260 and 0x426d seem to be for the flash mode of the
> Wrigley3GLTE modem.
>
> See also lsusb -v output below. No idea if there's a Windows driver
> .inf file for this. Most likely whatever Windows driver is just using the
> generic Android USB driver(s). I know the USB on droid 4 can be multiplex=
ed
> to have MDM6600 directly accessed, but I think that's only used for
> debugging the modem as that mode needs to be selected in the bootloader
> temporarily using volume keys.
>
> With the configuration in my patch, modprobe of qmi_wwan produces four
> wwan interfaces if that matters.

And I assume they all work?

>> The reason I ask is that I'd hate to have reports of other Motorola
>> devices where ff/fb/ff was used for some other USB function.  Yes, that
>> would be stupid.  But still... Experience shows that we cannot rule out
>> stupid when we consider USB descriptors.
>
> Yes thanks for checking. If you prefer to set it up in some other
> way, or need more info, please let me know.

No, it all looks very sane to me, given your explanation. Just wanted to
be absolutely sure. Thanks a lot.


Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>



Bj=C3=B8rn
