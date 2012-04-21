From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 15:50:41 +0800
Message-ID: <CA+v9cxa+fyzMOD-=oLLczpu1FDtTwcok+y2FkC=mHzDH3JYJ2A@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
	<CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
	<CA+v9cxZZpL5soSga=MX_bD45KNve-Lnr2Qb6+gr7Mv6Txyh-fA@mail.gmail.com>
	<CACVXFVN6kvXk7s4Sc0d_-yKSM=rV3qcuPPBHVZYzoQjnwkGX+Q@mail.gmail.com>
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
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41218 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab2DUHun convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 03:50:43 -0400
In-Reply-To: <CACVXFVN6kvXk7s4Sc0d_-yKSM=rV3qcuPPBHVZYzoQjnwkGX+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 21, 2012 at 3:06 PM, Ming Lei <tom.leiming@gmail.com> wrote=
:
> Hi Huajun,
>
> On Sat, Apr 21, 2012 at 2:39 PM, Huajun Li <huajun.li.lee@gmail.com> =
wrote:
>
>> Hi Ming,
>> =A0 =A0 That's why my patch uses skb_queue_walk() to traverse the qu=
eue,
>> it guarantees the skb available in each loop. =A0Is this what you
>> expected?
>>
>> =A0 =A0 The main idea of my patch(it is based on current mainline: 3=
=2E4.0-rc3) is:
>> =A0 =A0 1. If the skb in txq/rxq, then it must be available,
>> unlink_urbs() can refer to it safely while it holds =A0q->lock;
>> =A0 =A0 2. If the skb in txq/rxq and its state is
>> rx_done/tx_done/rx_cleanup, that means the skb's URB is complete, th=
en
>> don't need to unlink it again;
>
> As I said before, at least current code is not mistaken, since unlink
> can handle the case correctly.
>
>> =A0 =A0 3. Before releasing =A0q->lock in unlink_urbs(), it will inc=
rease
>> the URB's refercount, so even the related skb is freed in future, th=
e
>> URB is still available.
>
> No, increasing URB's reference count does not prevent the referenced =
skb
> from being freed, see usbnet_bh(), so 'tmp =3D skb->next' in skb_queu=
e_walk_safe
> still may reference a freed pointer.
>

Did we on the same page, could you please review my patch again?

My draft patch was based on current mainline( 3.4.0-rc3)  which had
already integrated your previous patch. And in my patch, it replaced
skb_queue_walk_safe() with skb_queue_walk(), so you will not see  'tmp
=3D skb->next'  any more.

>>> As far as I can think of, we can hold lock of done queue to forbid =
skb free
>>> during unlinking. The below patch may fix the problem, are you OK
>>> with it?
>>
>> Just skip trying this per your following email's comments.
>
> I will prepare a new patch later, if you'd like to try it.
>
>
> Thanks
> --
> Ming Lei
