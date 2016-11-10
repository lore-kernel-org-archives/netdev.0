From: Kai-Heng Feng <kai.heng.feng@canonical.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe function
Date: Thu, 10 Nov 2016 12:06:31 +0800
Message-ID: <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
References: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
 <1478692735.2428.10.camel@suse.com> <8760nwj0l3.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oneukum@suse.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760nwj0l3.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Nov 9, 2016 at 8:32 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Oliver Neukum <oneukum@suse.com> writes:
>
>> On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:
>>
>>> These problems could very well be caused by running at SuperSpeed
>>> (USB-3) instead of high speed (USB-2).

Yes, it's running at SuperSpeed, on a Kabylake laptop.

It does not have this issue on a Broadwell laptop, also running at SuperSpe=
ed.

>>>
>>> Is there any way to test what happens when the device is attached to
>>> the computer by a USB-2 cable?  That would prevent it from operating at
>>> SuperSpeed.

I recall old Intel PCH can change the USB host from XHCI to EHCI,
newer PCH does not have this option.

Is there a way to force XHCI run at HighSpeed?

>>>
>>> The main point, however, is that the proposed patch doesn't seem to
>>> address the true problem, which is that the device gets suspended
>>> between probes.  The patch only tries to prevent it from being
>>> suspended during a probe -- which is already prevented by the USB core.
>>
>> But why doesn't it fail during normal operation?
>>
>> I suspect that its firmware requires the altsetting
>>
>>         /* should we change control altsetting on a NCM/MBIM function? *=
/
>>         if (cdc_ncm_select_altsetting(intf) =3D=3D CDC_NCM_COMM_ALTSETTI=
NG_MBIM) {
>>                 data_altsetting =3D CDC_NCM_DATA_ALTSETTING_MBIM;
>>                 ret =3D cdc_mbim_set_ctrlalt(dev, intf, CDC_NCM_COMM_ALT=
SETTING_MBIM);
>>
>> to be set before it accepts a suspension.
>
> Could be, but I don't think so.  The above code is effectively a noop
> unless the function is a combined NCM/MBIM function.  Something I've
> never seen on a Sierra Wireless device (ignoring the infamous EM7345,
> which really is an Intel device).
>
> This is a typical example of a Sierra Wireless modem configured for
> MBIM:
>
> P:  Vendor=3D1199 ProdID=3D9079 Rev=3D 0.06
> S:  Manufacturer=3DSierra Wireless, Incorporated
> S:  Product=3DSierra Wireless EM7455 Qualcomm Snapdragon X7 LTE-A
> S:  SerialNumber=3DLF615126xxxxxxx
> C:* #Ifs=3D 2 Cfg#=3D 1 Atr=3Da0 MxPwr=3D500mA
> A:  FirstIf#=3D12 IfCount=3D 2 Cls=3D02(comm.) Sub=3D0e Prot=3D00
> I:* If#=3D12 Alt=3D 0 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0e Prot=3D00 Driver=
=3D(none)
> E:  Ad=3D82(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D32ms
> I:* If#=3D13 Alt=3D 0 #EPs=3D 0 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driver=
=3D(none)
> I:  If#=3D13 Alt=3D 1 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driver=
=3D(none)
> E:  Ad=3D81(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
> E:  Ad=3D01(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
>
>
> The control interface of plain MBIM functions will always have a single
> altsetting, like the example above. So cdc_ncm_select_altsetting(intf)
> returns "0", while CDC_NCM_COMM_ALTSETTING_MBIM is "1".
>
>
> Just for reference, using the Intel^H^H^H^H^HEM7345 as example, this is
> what a combined NCM/MBIM function looks like:
>
>
> P:  Vendor=3D1199 ProdID=3Da001 Rev=3D17.29
> S:  Manufacturer=3DSierra Wireless Inc.
> S:  Product=3DSierra Wireless EM7345 4G LTE
> S:  SerialNumber=3D013937000xxxxxx
> C:* #Ifs=3D 4 Cfg#=3D 1 Atr=3De0 MxPwr=3D100mA
> A:  FirstIf#=3D 0 IfCount=3D 2 Cls=3D02(comm.) Sub=3D0d Prot=3D00
> A:  FirstIf#=3D 2 IfCount=3D 2 Cls=3D02(comm.) Sub=3D02 Prot=3D01
> I:  If#=3D 0 Alt=3D 0 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0d Prot=3D00 Driver=
=3Dcdc_mbim
> E:  Ad=3D81(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D1ms
> I:* If#=3D 0 Alt=3D 1 #EPs=3D 1 Cls=3D02(comm.) Sub=3D0e Prot=3D00 Driver=
=3Dcdc_mbim
> E:  Ad=3D81(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D1ms
> I:  If#=3D 1 Alt=3D 0 #EPs=3D 0 Cls=3D0a(data ) Sub=3D00 Prot=3D01 Driver=
=3Dcdc_mbim
> I:  If#=3D 1 Alt=3D 1 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D01 Driver=
=3Dcdc_mbim
> E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
> E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
> I:* If#=3D 1 Alt=3D 2 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D02 Driver=
=3Dcdc_mbim
> E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
> E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
> I:* If#=3D 2 Alt=3D 0 #EPs=3D 1 Cls=3D02(comm.) Sub=3D02 Prot=3D01 Driver=
=3D(none)
> E:  Ad=3D83(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D1ms
> I:* If#=3D 3 Alt=3D 0 #EPs=3D 2 Cls=3D0a(data ) Sub=3D00 Prot=3D00 Driver=
=3D(none)
> E:  Ad=3D84(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
> E:  Ad=3D04(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
>
>
> And this is what the code you quote is trying to deal with.  Note the
> different subclass of altsetting 0 and 1.... This is incredibly ugly.
>
> FWIW, the modem in question cannot be an EM7345. That modem does not
> have the static interface numbering oddity.  Another sign that it isn't
> a true Sierra device.

Yes, this modem is an EM7445.

>
>
>
>
> Bj=C3=B8rn
