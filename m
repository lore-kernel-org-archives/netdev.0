From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] net/cdc_ncm: fix null pointer panic at usbnet_link_change
Date: Thu, 31 Oct 2013 10:02:56 +0100
Message-ID: <87sivhdd8f.fsf@nemi.mork.no>
References: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
	<87wqkwii4p.fsf@nemi.mork.no>
	<0C18FE92A7765D4EB9EE5D38D86A563A019F6384@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "oliver\@neukum.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Du\, ChangbinX" <changbinx.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0C18FE92A7765D4EB9EE5D38D86A563A019F6384-0J0gbvR4kTggGBtAFL8yw7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
	(ChangbinX Du's message of "Thu, 31 Oct 2013 03:06:03 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Du, ChangbinX" <changbinx.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

>> From: Bj=C3=B8rn Mork [mailto:bjorn-yOkvZcmFvRU@public.gmane.org]
>> Sent: Tuesday, October 29, 2013 4:41 PM
>> To: Du, ChangbinX
>> Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TZUIDd8j+nm9g@public.gmane.org=
=2Eorg;
>> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Subject: Re: [PATCH] net/cdc_ncm: fix null pointer panic at usbnet_l=
ink_change
>>=20
>> "Du, ChangbinX" <changbinx.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>>=20
>> > From: "Du, Changbin" <changbinx.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> >
>> > In cdc_ncm_bind() function, it call cdc_ncm_bind_common() to setup=
 usb.
>> > But cdc_ncm_bind_common() may meet error and cause usbnet_disconne=
ct()
>> > be called which calls free_netdev(net).
>>=20
>> I am sure you are right, but I really don't see how that can happen.
>>=20
>> AFAICS, we ensure that the intfdata is set to NULL before calling
>> usb_driver_release_interface() in the error cleanup in
>> cdc_ncm_bind_common():
>>=20
>>=20
>> error2:
>> 	usb_set_intfdata(ctx->control, NULL);
>> 	usb_set_intfdata(ctx->data, NULL);
>> 	if (ctx->data !=3D ctx->control)
>> 		usb_driver_release_interface(driver, ctx->data);
>> error:
>> 	cdc_ncm_free((struct cdc_ncm_ctx *)dev->data[0]);
>> 	dev->data[0] =3D 0;
>> 	dev_info(&dev->udev->dev, "bind() failure\n");
>> 	return -ENODEV;
>>=20
>>=20
>> Thus we hit the test in disconnect, and usbnet_disconnect() is never
>> called:
>>=20
>> static void cdc_ncm_disconnect(struct usb_interface *intf)
>> {
>> 	struct usbnet *dev =3D usb_get_intfdata(intf);
>>=20
>> 	if (dev =3D=3D NULL)
>> 		return;		/* already disconnected */
>>=20
>> 	usbnet_disconnect(intf);
>> }
>>=20
>> So we should really be OK, but we are not????  I would appreciate it=
 if
>> anyone took the time to feed me why, with a very small spoon...
>>=20
>
> Yes, you are right. It should not happen if cdc_ncm_disconnect is not
> called. But this really happened.  It produced on kernel 3.10.

Yes, I do not doubt it.  I just don't understand it.  There is no
contradiction there. I believe lots of stuff I don't understand :-)

The version this happened is very useful, although I don't think there
are any relevant changes after v3.10.

> Here is the full panic message for you to refer. I will get a method =
try to=20
> reproduce it.

That would be great if you were able to.  Otherwise it will be difficul=
t
to verify that the proposed fix works.

In any case, as I said: I believe a fix which avoids the call to
usbnet_link_change() in case of bind failure is correct and
appropriate.  But I suggest that you do it by removing the call and
comment from cdc_ncm_bind() and instead set the FLAG_LINK_INTR in the
driver_info.  That's how this should have been implemented from the
beginning.

> [   15.635727] BUG: Bad page state in process khubd  pfn:31994
> [   15.641989] page:f3ad9280 count:0 mapcount:0 mapping:00000020 inde=
x:0x0
> [   15.649384] page flags: 0x40000000()
> [   15.670096] BUG: unable to handle kernel NULL pointer dereference =
at 00000078
> [   15.678078] IP: [<c24b7f5e>] usbnet_link_change+0x1e/0x80
> [   15.684120] *pde =3D 00000000=20
> [   15.687339] Oops: 0000 [#1] SMP=20
> [   15.690953] Modules linked in: atmel_mxt_ts vxd392 videobuf_vmallo=
c videobuf_core bcm_bt_lpm bcm432)
> [   15.702658] CPU: 0 PID: 573 Comm: khubd Tainted: G    B   W  O 3.1=
0.1+ #1
> [   15.710241] task: f27e8f30 ti: f2084000 task.ti: f2084000
> [   15.716270] EIP: 0060:[<c24b7f5e>] EFLAGS: 00010246 CPU: 0
> [   15.722396] EIP is at usbnet_link_change+0x1e/0x80
> [   15.727747] EAX: f18524c0 EBX: 00000000 ECX: f18524c0 EDX: 0000000=
0
> [   15.734746] ESI: f18524c0 EDI: 00000000 EBP: f2085b7c ESP: f2085b7=
0
> [   15.741746] DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [   15.747775] CR0: 8005003b CR2: 00000078 CR3: 02c3b000 CR4: 001007d=
0
> [   15.754774] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 0000000=
0
> [   15.761774] DR6: ffff0ff0 DR7: 00000400
> [   15.766054] Stack:
> [   15.768295]  00000000 f18524c0 c2a03818 f2085b8c c24bc69a f1852000=
 f1f52e00 f2085be0
> [   15.776991]  c24b8d32 00000000 00000001 00000000 c2167f2c f2085bb4=
 c2821253 f2085bec
> [   15.785687]  00000246 00000246 f18d8088 f1f52e1c f1fce464 f1fce400=
 f18524c0 c28a06e0
> [   15.794376] Call Trace:
> [   15.797109]  [<c24bc69a>] cdc_ncm_bind+0x3a/0x50
> [   15.802267]  [<c24b8d32>] usbnet_probe+0x282/0x7d0
> [   15.807621]  [<c2167f2c>] ? sysfs_new_dirent+0x6c/0x100
> [   15.813460]  [<c2821253>] ? mutex_lock+0x13/0x40
> [   15.818618]  [<c24bb278>] cdc_ncm_probe+0x8/0x10
> [   15.823777]  [<c24e0ef7>] usb_probe_interface+0x187/0x2c0

I still do not understand how this happens, but usbnet_link_change will
schedule some delayed work which absolutely is not appropriate if
usbnet_probe fails.  There are no cancel_work calls in the usbnet_probe
exit path....

So the call should definitely be avoided if bind fails.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
