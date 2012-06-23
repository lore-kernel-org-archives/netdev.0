From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sat, 23 Jun 2012 11:39:22 +0800
Message-ID: <CACVXFVMJSrLjOyKUnZWr3CY2HJT6Wfm6AugZOhSCRUubV0hNMQ@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVNmquD6nhcJkumZsnXH7T+Ga3YNt9EAQ=-5HUkYwEdp7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64018 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab2FWDjX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 23:39:23 -0400
In-Reply-To: <CACVXFVNmquD6nhcJkumZsnXH7T+Ga3YNt9EAQ=-5HUkYwEdp7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for mistaken triggered sending, :-(

On Sat, Jun 23, 2012 at 11:32 AM, Ming Lei <tom.leiming@gmail.com> wrot=
e:
> On Fri, Jun 22, 2012 at 5:11 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>
>>
>> Reported-by: Marius Bj=F8rnstad Kotsbak <marius.kotsbak@gmail.com>
>> Cc: <stable@vger.kernel.org> # v3.4
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>> ---
>> =A0drivers/net/usb/qmi_wwan.c | =A0 =A04 ++++
>> =A01 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
>> index 3767a12..b01960f 100644
>> --- a/drivers/net/usb/qmi_wwan.c
>> +++ b/drivers/net/usb/qmi_wwan.c
>> @@ -197,6 +197,10 @@ err:
>> =A0static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *in=
tf, int on)
>> =A0{
>> =A0 =A0 =A0 =A0struct usbnet *dev =3D usb_get_intfdata(intf);
>> +
>> + =A0 =A0 =A0 /* can be called while disconnecting */
>> + =A0 =A0 =A0 if (!dev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0return qmi_wwan_manage_power(dev, on);
>> =A0}
>

Considered there isn't any protection between usbnet_disconnet and
wdm_open/wdm_close, you patch still doesn't work on the race, see
below:

 =A0 + =A0 =A0 =A0 if (!dev)
 =A0 + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;

 =A0 =A0 =A0 =A0 =A0 =A0-> usbnet_disconnect() is triggered and complet=
ed here, so
            dev may point to a freed usbnet instance.

 =A0 =A0 =A0 =A0 =A0 =A0 return qmi_wwan_manage_power(dev, on);

One fix I can think of is to export wdm_mutex or its lock/unlock
functions, and introduce the function of qmi_wwan_disconnect, which
will call usbnet_disconnect with holding wdm_mutex.


Thanks,
--=20
Ming Lei
