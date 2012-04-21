From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 10:02:55 +0800
Message-ID: <CACVXFVOc4ZMXJNky78V4dyhmoRhKVXsAF7=cOGvSUrQdDEiHXg@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
	<CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50061 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753622Ab2DUCC4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 22:02:56 -0400
In-Reply-To: <CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 21, 2012 at 9:49 AM, Ming Lei <tom.leiming@gmail.com> wrote=
:
> On Fri, Apr 20, 2012 at 10:56 PM, Huajun Li <huajun.li.lee@gmail.com>=
 wrote:
>> On Fri, Apr 20, 2012 at 10:22 PM, Ming Lei <tom.leiming@gmail.com> w=
rote:
>>> On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee@gmail.com=
> wrote:
>>>>
>>>> Above patch has already been integrated to mainline. However, mayb=
e
>>>> there still exists another potentail use-after-free issue, here is=
 a
>>>> case:
>>>> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may=
 move
>>>> current skb from rxq/txq to dev->done queue, even cause the skb be
>>>> released. Then in next loop cycle, it can't refer to expected skb,=
 and
>>>> may Oops again.
>>>
>>> Could you explain in a bit detail? Why can't the expected skb be re=
fered
>>> to in next loop?
>>
>>
>> =A0 =A0 =A0unlink_urbs() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete handler
>> --------------------------------------
>> -------------------------------------------------
>> =A0 =A0 spin_unlock_irqrestore()
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_compl=
ete()
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0derver_b=
h()
>>
>> =A0__skb_unlink()
>>
>> =A0__skb_queue_tail(&dev->done, skb) =A0 =3D=3D=3D=3D=3D=3D=3D> skb =
is moved to
>> dev->done, and can be freed by usbnet_bh()
>> =A0 =A0 =A0skb_queue_walk_safe()
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp =3D skb->next =A0 =3D=
=3D=3D> refer to freed skb
>
> I see the problem, so looks skb_queue_walk_safe is not safe.
> I don' know why the 2nd ' tmp =3D skb->next' in =A0skb_queue_walk_saf=
e
> is needed and it may become unsafe if skb is freed during current loo=
p.
>
> But removing the 2nd 'tmp =3D skb->next' doesn't help the problem, be=
cause
> tmp still may become freed after releasing lock.
>
>> If its state is x_done/tx_done/rx_cleanup, that means the the skb wi=
ll
>> be released soon, right? If so, it should avoid calling
>> usb_unlink_urb().
>
> Even though you can avoid calling unlink for completed URBs, the skbs
> still may be freed in unlink path because complete handler will be tr=
iggered
> by unlink and the referenced skb may be freed before next loop, so yo=
ur
> patch can't fix the oops.
>
> As far as I can think of, we can hold lock of done queue to forbid sk=
b free
> during unlinking. The below patch may fix the problem, are you OK
> with it?

Sorry, the patch still doesn't work since done.lock can't be held
before calling unlinking.

One simple solution is just always holding q->lock during the whole loo=
p,
like before commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d
(net/usbnet: avoid recursive locking in usbnet_stop()), and take
the per cpu flag trick to avoid holding q->lock in complete handler
called by unlink, see idea in below link:

http://marc.info/?l=3Dlinux-usb&m=3D133491718707499&w=3D2

In theory, it should be simple, just take avoiding policy.

>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index db99536..a9809d4 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -581,7 +581,8 @@ static int unlink_urbs (struct usbnet *dev, struc=
t
> sk_buff_head *q)
> =A0 =A0 =A0 =A0struct sk_buff =A0 =A0 =A0 =A0 =A0*skb, *skbnext;
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D =
0;
>
> - =A0 =A0 =A0 spin_lock_irqsave (&q->lock, flags);
> + =A0 =A0 =A0 spin_lock_irqsave(&dev->done.lock, flags);
> + =A0 =A0 =A0 spin_lock(&q->lock);
> =A0 =A0 =A0 =A0skb_queue_walk_safe(q, skb, skbnext) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct skb_data =A0 =A0 =A0 =A0 *entry=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*urb;
> @@ -598,7 +599,7 @@ static int unlink_urbs (struct usbnet *dev, struc=
t
> sk_buff_head *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * handler(include defer_bh).
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usb_get_urb(urb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&q->lock, flags)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&q->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// during some PM-driven resume scenar=
ios,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// these (async) unlinks complete imme=
diately
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D usb_unlink_urb (urb);
> @@ -607,9 +608,10 @@ static int unlink_urbs (struct usbnet *dev,
> struct sk_buff_head *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usb_put_urb(urb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&q->lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&q->lock);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 spin_unlock_irqrestore (&q->lock, flags);
> + =A0 =A0 =A0 spin_unlock(&q->lock);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&dev->done.lock, flags);
> =A0 =A0 =A0 =A0return count;
> =A0}
>
>
>
> Thanks,
> --
> Ming Lei



--=20
Ming Lei
