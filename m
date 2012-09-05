From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Wed, 5 Sep 2012 08:30:52 +0800
Message-ID: <CACVXFVPEDs8ZMU9Fvkf6=R7dwpb+oKY-igYsCKm9JC+_5Nq9bA@mail.gmail.com>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
	<CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A@mail.gmail.com>
	<87y5kqcjnp.fsf@nemi.mork.no>
	<CACVXFVMEqF9+e10oRuTHjkKQOnPnJMXxapXZ9rYG9qWRpZPLKw@mail.gmail.com>
	<877gsacbws.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b344100c81d9904c8e97cec
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877gsacbws.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--047d7b344100c81d9904c8e97cec
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 4, 2012 at 6:36 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>
> I believe any Ericsson or Gobi modem would do, and most likely other USB
> networking devices too.
>
> I haven't explored the gadget.  Doesn't it support remote wakeup?  Well,

No.

> it doesn't really have to just for testing this.  You just have to fake
> the remote wakeup support, either in the gadget or in the device
> driver.  It doesn't matter whether it works or not.  The point is making
> the driver suspend the USB device while the network device is running.

The attachment patch is what I have been using to make it support remote
wakeup, and looks it works wrt. runtime PM.


>
>
>
> So the code trigging this seems to be
>
>
> static enum skb_state defer_bh(struct usbnet *dev, struct sk_buff *skb,
>                 struct sk_buff_head *list, enum skb_state state)
> {
>         unsigned long           flags;
>         enum skb_state          old_state;
>         struct skb_data *entry =3D (struct skb_data *) skb->cb;
>
>         spin_lock_irqsave(&list->lock, flags);
>         old_state =3D entry->state;
>         entry->state =3D state;
>         __skb_unlink(skb, list);
>         spin_unlock(&list->lock);
>         spin_lock(&dev->done.lock);
>         __skb_queue_tail(&dev->done, skb);
>         if (dev->done.qlen =3D=3D 1)
>                 tasklet_schedule(&dev->bh);
>         spin_unlock_irqrestore(&dev->done.lock, flags);
>         return old_state;
> }
>
>
> Hmm, I should probably dump stack here as well.. Anyway, it's a start.

Maybe a debug message in defer_bh is enough, :-)


Thanks,
--
Ming Lei

--047d7b344100c81d9904c8e97cec
Content-Type: application/octet-stream;
	name="usb-gadget-remote-wakeup.patch"
Content-Disposition: attachment; filename="usb-gadget-remote-wakeup.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h6poxalc0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvdXNiL2dhZGdldC9ldGhlci5jIGIvZHJpdmVycy91c2IvZ2Fk
Z2V0L2V0aGVyLmMKaW5kZXggYTI4ZjZmZi4uNjk0ZjYzOSAxMDA2NDQKLS0tIGEvZHJpdmVycy91
c2IvZ2FkZ2V0L2V0aGVyLmMKKysrIGIvZHJpdmVycy91c2IvZ2FkZ2V0L2V0aGVyLmMKQEAgLTIz
Niw2ICsyMzYsNyBAQCBzdGF0aWMgaW50IF9faW5pdCBybmRpc19kb19jb25maWcoc3RydWN0IHVz
Yl9jb25maWd1cmF0aW9uICpjKQogCQljLT5kZXNjcmlwdG9ycyA9IG90Z19kZXNjOwogCQljLT5i
bUF0dHJpYnV0ZXMgfD0gVVNCX0NPTkZJR19BVFRfV0FLRVVQOwogCX0KKwljLT5ibUF0dHJpYnV0
ZXMgfD0gVVNCX0NPTkZJR19BVFRfV0FLRVVQOwogCiAJcmV0dXJuIHJuZGlzX2JpbmRfY29uZmln
KGMsIGhvc3RhZGRyKTsKIH0KQEAgLTI2OCw2ICsyNjksNyBAQCBzdGF0aWMgaW50IF9faW5pdCBl
dGhfZG9fY29uZmlnKHN0cnVjdCB1c2JfY29uZmlndXJhdGlvbiAqYykKIAkJYy0+ZGVzY3JpcHRv
cnMgPSBvdGdfZGVzYzsKIAkJYy0+Ym1BdHRyaWJ1dGVzIHw9IFVTQl9DT05GSUdfQVRUX1dBS0VV
UDsKIAl9CisJYy0+Ym1BdHRyaWJ1dGVzIHw9IFVTQl9DT05GSUdfQVRUX1dBS0VVUDsKIAogCWlm
ICh1c2VfZWVtKQogCQlyZXR1cm4gZWVtX2JpbmRfY29uZmlnKGMpOwpkaWZmIC0tZ2l0IGEvZHJp
dmVycy91c2IvZ2FkZ2V0L3VfZXRoZXIuYyBiL2RyaXZlcnMvdXNiL2dhZGdldC91X2V0aGVyLmMK
aW5kZXggNDdjZjQ4Yi4uMTk3ZmNjMCAxMDA2NDQKLS0tIGEvZHJpdmVycy91c2IvZ2FkZ2V0L3Vf
ZXRoZXIuYworKysgYi9kcml2ZXJzL3VzYi9nYWRnZXQvdV9ldGhlci5jCkBAIC00OTcsNiArNDk3
LDcgQEAgc3RhdGljIG5ldGRldl90eF90IGV0aF9zdGFydF94bWl0KHN0cnVjdCBza19idWZmICpz
a2IsCiAJc3RydWN0IHVzYl9lcAkJKmluOwogCXUxNgkJCWNkY19maWx0ZXI7CiAKKwl1c2JfZ2Fk
Z2V0X3dha2V1cChkZXYtPmdhZGdldCk7CiAJc3Bpbl9sb2NrX2lycXNhdmUoJmRldi0+bG9jaywg
ZmxhZ3MpOwogCWlmIChkZXYtPnBvcnRfdXNiKSB7CiAJCWluID0gZGV2LT5wb3J0X3VzYi0+aW5f
ZXA7Cg==
--047d7b344100c81d9904c8e97cec--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
