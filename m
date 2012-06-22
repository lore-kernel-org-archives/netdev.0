From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Fri, 22 Jun 2012 19:31:47 +0200
Message-ID: <87txy3jlrw.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
	<87mx3vlayl.fsf@nemi.mork.no>
	<CACVXFVOQ3Uh50iJxboD-7=+J55MAW8Wjt3iY0WahauO2PrxT4w@mail.gmail.com>
	<877guzl3qz.fsf@nemi.mork.no>
	<CACVXFVNCAsM5NihpAFLU5rGo5ynr3=XU5gw7nM5Fi2mrrX+hKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNCAsM5NihpAFLU5rGo5ynr3=XU5gw7nM5Fi2mrrX+hKA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Sat, 23 Jun 2012 00:52:05 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Sat, Jun 23, 2012 at 12:18 AM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wro=
te:
>> Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> Yes, intfdata is per interface, but in the case of cdc_ether (and
>> probably other similar minidrivers) there are two interfaces pointin=
g to
>> the *same* usbnet private data.
>
> Yes, the priv pointers of both interface points to the usbnet instanc=
e, but
> the same pointer is stored into two places.
>
>>
>> What about the situation where disconnect is called simultaneously f=
or
>> both interfaces? Or can't that happen? If it can, then we'll do
>
> It can't happen because both parent lock and its lock need to be held=
 in
> hotplug situation or unbind situation.

OK, then it can probably go away.  But then again it doesn't do any har=
m
for any other minidriver.  qmi_wwan is special because of the
cooperation with cdc_wdm.

>> =C2=A0driver->disconnect(intf1) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0driver->disconnect(intf2)
>> =C2=A0 =C2=A0 dev =3D usb_get_intfdata(intf1) =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dev =3D usb_get_intfdata(intf2)
>> =C2=A0 =C2=A0 dev->driver_info->unbind() =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0dev->driver_info->unbind()
>> =C2=A0 =C2=A0 net =3D dev->net =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0net =3D dev->net
>> =C2=A0 =C2=A0 free_netdev(net) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0free_netdev(dev->net)
>>
>> where "dev" and "net" will be pointing to the same private data and
>> netdevice.
>
> Suppose driver->disconnect(intf1) is called first, .ubind() inside
> .disconnect will clear intfdata of another interface(intf2) and call
> usb_driver_release_interface(intf2), which will cause .disconnect(int=
f2)
> called, but it will return immediately.

Yes, if that's the only possible call sequence then I agree that
removing the call won't be a problem.  But I don't see much gain either=
=2E
And it has been there since the beginning of git history, if that count=
s
for anything around here.

>> I assume that is what the code above is trying to protect against. =C2=
=A0But
>
> I don't see the protection in the code, :-)

I am trying my best to be positive :-)


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
