From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sat, 23 Jun 2012 10:45:04 +0200
Message-ID: <8762aiju27.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVNmquD6nhcJkumZsnXH7T+Ga3YNt9EAQ=-5HUkYwEdp7w@mail.gmail.com>
	<CACVXFVMJSrLjOyKUnZWr3CY2HJT6Wfm6AugZOhSCRUubV0hNMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVMJSrLjOyKUnZWr3CY2HJT6Wfm6AugZOhSCRUubV0hNMQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Sat, 23 Jun 2012 11:39:22 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> On Sat, Jun 23, 2012 at 11:32 AM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
>> On Fri, Jun 22, 2012 at 5:11 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wro=
te:
>>
>>>
>>> Reported-by: Marius Bj=C3=B8rnstad Kotsbak <marius.kotsbak-Re5JQEeQqe8@public.gmane.org=
m>
>>> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4
>>> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>>> ---
>>> =C2=A0drivers/net/usb/qmi_wwan.c | =C2=A0 =C2=A04 ++++
>>> =C2=A01 file changed, 4 insertions(+)
>>>
>>> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.=
c
>>> index 3767a12..b01960f 100644
>>> --- a/drivers/net/usb/qmi_wwan.c
>>> +++ b/drivers/net/usb/qmi_wwan.c
>>> @@ -197,6 +197,10 @@ err:
>>> =C2=A0static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface=
 *intf, int on)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct usbnet *dev =3D usb_get_intfdata(=
intf);
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 /* can be called while disconnecting */
>>> + =C2=A0 =C2=A0 =C2=A0 if (!dev)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return qmi_wwan_manage_power(dev, on);
>>> =C2=A0}
>>
>
> Considered there isn't any protection between usbnet_disconnet and
> wdm_open/wdm_close, you patch still doesn't work on the race, see
> below:
>
>  =C2=A0 + =C2=A0 =C2=A0 =C2=A0 if (!dev)
>  =C2=A0 + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>
>  =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-> usbnet_disconnect() is t=
riggered and completed here, so
>             dev may point to a freed usbnet instance.

>  =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return qmi_wwan_manage_pow=
er(dev, on);


usbnet_disconnect() cannot continue to the point where it frees the
netdev before wdm_open/wdm_close has completed, because it waits for
qmi_wwan_unbind which waits for wdm_disconnect.  And wdm_disconnect
takes the both read and write mutexes.

So I do not think there is any race there. =20



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
