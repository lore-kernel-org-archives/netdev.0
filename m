From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Fri, 27 Apr 2012 00:30:49 +0800
Message-ID: <CA+v9cxahbc7W0jPZsGOyE-ky1SxHc80kLk7e44aPgtg-4Eqv3g@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVOFGA-Rn3X2HGGM-AYSygiysNnRo0RiRzmJhZ=swtZz_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40175 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757815Ab2DZQav convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 12:30:51 -0400
In-Reply-To: <CACVXFVOFGA-Rn3X2HGGM-AYSygiysNnRo0RiRzmJhZ=swtZz_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 26, 2012 at 1:02 PM, Ming Lei <tom.leiming@gmail.com> wrote=
:
> Hi Huajun,
>
> On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee@gmail.com> =
wrote:
>>
>>
>> Above patch has already been integrated to mainline. However, maybe
>> there still exists another potentail use-after-free issue, here is a
>> case:
>> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may m=
ove
>> current skb from rxq/txq to dev->done queue, even cause the skb be
>> released. Then in next loop cycle, it can't refer to expected skb, a=
nd
>> may Oops again.
>>
>> To easily reproduce it, in unlink_urbs(), you can delay a short time
>> after usb_put_urb(urb), then disconnect your device while transferri=
ng
>> data, and repeat it times you will find errors on your screen.
>>
>> Following is a draft patch to guarantee the queue consistent, and
>> refer to expected skb in each loop cycle:
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index b7b3f5b..6da0141 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -578,16 +578,28 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
>> =A0static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *=
q)
>> =A0{
>> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
>> - =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb, *skbnext;
>> + =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb;
>> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D=
 0;
>>
>> =A0 =A0 =A0 =A0spin_lock_irqsave (&q->lock, flags);
>> - =A0 =A0 =A0 skb_queue_walk_safe(q, skb, skbnext) {
>> + =A0 =A0 =A0 while (!skb_queue_empty(q)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct skb_data =A0 =A0 =A0 =A0 *entr=
y;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*urb;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 retval;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_data *) skb->cb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk(q, skb) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_=
data *)skb->cb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->state =3D=3D=
 rx_done ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry-=
>state =3D=3D tx_done ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry-=
>state =3D=3D rx_cleanup)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 contin=
ue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D (struct sk_buff *)(q))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb =3D entry->urb;
>>
>>
>
> After thinking about the issue further, the basic idea of your patch =
is good,
> but not safe(double unlink, also races on accessing entry->state), so=
 I write
> a new one based on your patch.
>
> Are you OK this new one?
>

Yes,  no more issue that I can see by now, thanks.

> Thanks,
> --
> Ming Lei
>
> From 89eb41968caa9523c90c1cf7b7e2259db00e04b8 Mon Sep 17 00:00:00 200=
1
> From: Ming Lei <tom.leiming@gmail.com>
> Date: Thu, 26 Apr 2012 11:33:46 +0800
> Subject: [PATCH] usbnet: fix skb traversing races during unlink
>
> Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
> recursive locking in usbnet_stop()) fixes the recursive locking
> problem by releasing the skb queue lock before unlink, but may
> cause skb traversing races:
> =A0 =A0 =A0 =A0- after URB is unlinked and the queue lock is released=
,
> =A0 =A0 =A0 =A0the refered skb and skb->next may be moved to done que=
ue,
> =A0 =A0 =A0 =A0even be released
> =A0 =A0 =A0 =A0- in skb_queue_walk_safe, the next skb is still obtain=
ed
> =A0 =A0 =A0 =A0by next pointer of the last skb
> =A0 =A0 =A0 =A0- so maybe trigger oops or other problems
>
> This patch extends the usage of entry->state to describe 'start_unlin=
k'
> state, so always holding the queue(rx/tx) lock to change the state if
> the referd skb is in rx or tx queue because we need to know if the
> refered urb has been started unlinking in unlink_urbs.
>
> Also the patch uses usb_block_urb introduced by Oliver to block
> URB resubmit in complete handler if the URB will be unlinked.
>
> The other part of this patch is based on Hugjun's patch:

s/Hugjun/Huajun

> always traverse from head of the tx/rx queue to get skb which is
> to be unlinked but not been started unlinking.
> ---
