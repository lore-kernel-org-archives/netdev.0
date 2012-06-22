From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Fri, 22 Jun 2012 23:09:36 +0800
Message-ID: <CACVXFVOQ3Uh50iJxboD-7=+J55MAW8Wjt3iY0WahauO2PrxT4w@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
	<87mx3vlayl.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:49952 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755442Ab2FVPJh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 11:09:37 -0400
In-Reply-To: <87mx3vlayl.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 22, 2012 at 9:42 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <tom.leiming@gmail.com> writes:
>
>> On Fri, Jun 22, 2012 at 5:11 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>>> usbnet_disconnect() will set intfdata to NULL before calling
>>> the minidriver unbind function. =A0The cdc_wdm subdriver cannot
>>> know that it is disconnecting until the qmi_wwan unbind
>>> function has called its disconnect function. =A0This means that
>>> we must be able to support the cdc_wdm subdriver operating
>>> normally while usbnet_disconnect() is running, and in
>>> particular that intfdata may be NULL.
>>>
>>> The only place this matters is in qmi_wwan_cdc_wdm_manage_power
>>> which is called from cdc_wdm. =A0Simply testing for NULL
>>> intfdata there is sufficient to allow it to continue working
>>> at all times.
>>>
>>> Fixes this Oops where a cdc-wdm device was closed while the
>>> USB device was disconnecting, causing wdm_release to call
>>> qmi_wwan_cdc_wdm_manage_power after intfdata was set to
>>> NULL by usbnet_disconnect:
>>
>> In fact, it should be a general problem in usbnet, there are races
>> between usbnet_disconnect and .open/.close. Considered that
>> unregister_netdev, which will sync with .open/.close, =A0is called i=
n
>> usbnet_disconnect, =A0the simplest fix is to move usb_set_intfdata(N=
ULL)
>> after unregister_netdev.
>
> Is there really a race there? =A0The usbnet .open/.close don't use th=
e
> intfdata, do they? =A0I looked briefly through usbnet for related

Suppose intfdata is not used in .open/.close, there are no the race.

> potentional problems while fixing this in qmi_wwan, but could only fi=
nd
> suspend/resume. =A0Which I believe are protected against running on
> disconnect.
>
> So I think usbnet in general is OK.

Yes.

Looks I understand the problem incorrectly, your problem is
that qmi_wwan_cdc_wdm_manage_power is called from
wdm_open, not from usbnet_open. It is a problem crossing
2 class drivers.

>
>> Considered that usb_set_intfdata(NULL) will be called after
>> executing .disconnect in unbind path, it can be removed simply.
>>
>> So how about the below?
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index e92c057..2eb9e1e 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -1286,7 +1286,6 @@ void usbnet_disconnect (struct usb_interface *=
intf)
>> =A0 =A0 =A0 struct net_device =A0 =A0 =A0 *net;
>>
>> =A0 =A0 =A0 dev =3D usb_get_intfdata(intf);
>> - =A0 =A0 usb_set_intfdata(intf, NULL);
>> =A0 =A0 =A0 if (!dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>
> I believe that call is there to prevent disconnect from running twice
> for the common two-interface CDC ethernet model, like e.g. cdc_ether.

No, intfdata is per interface, and .unbind will clear it for each inter=
face.

> So I don't think it can be removed. =A0Not without touching the

It can be removed, but not necessary since it can't fix your problem.


Thanks,
--=20
Ming Lei
