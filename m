From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Fri, 20 Apr 2012 23:07:40 +0800
Message-ID: <CA+v9cxajCyBg4-MeW50_emD96-ujTXXx+q+Pv2gcK2DQGzT_RA@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 20, 2012 at 10:56 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> w=
rote:
> On Fri, Apr 20, 2012 at 10:22 PM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
>> On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
>>>
>>> Above patch has already been integrated to mainline. However, maybe
>>> there still exists another potentail use-after-free issue, here is =
a
>>> case:
>>> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may =
move
>>> current skb from rxq/txq to dev->done queue, even cause the skb be
>>> released. Then in next loop cycle, it can't refer to expected skb, =
and
>>> may Oops again.
>>
>> Could you explain in a bit detail? Why can't the expected skb be ref=
ered
>> to in next loop?
>
>
> =A0 =A0 =A0unlink_urbs() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete handler
> --------------------------------------
> -------------------------------------------------
> =A0 =A0 spin_unlock_irqrestore()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_complete=
()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0derver_bh()
>
> =A0__skb_unlink()
>
> =A0__skb_queue_tail(&dev->done, skb) =A0 =3D=3D=3D=3D=3D=3D=3D> skb i=
s moved to
> dev->done, and can be freed by usbnet_bh()
> =A0 =A0 =A0skb_queue_walk_safe()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp =3D skb->next =A0 =3D=3D=
=3D> refer to freed skb
>

Sorry, email client messed up these lines, resend it:

  unlink_urbs()                    complete handler
------------------------               ------------------------------
spin_unlock_irqrestore()
                                       rx_complete()
                                       derver_bh()
                                          __skb_unlink()
                                          __skb_queue_tail(&dev->done, =
skb)
                                          =3D=3D=3D=3D=3D=3D=3D> skb is=
 moved to dev->done,
                                        and can be freed by usbnet_bh()

skb_queue_walk_safe()
        tmp =3D skb->next   =3D=3D=3D> refer to freed skb
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
