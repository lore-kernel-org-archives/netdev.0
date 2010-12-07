From: Neil Jones <neiljay@gmail.com>
Subject: Fwd: usbnet: Recursive Locking bug ?
Date: Tue, 7 Dec 2010 16:15:38 +0000
Message-ID: <AANLkTi=VB0Kt=2c1C1b-Ps8x_zA5Tnf+tfHjvO8gWgm8@mail.gmail.com>
References: <AANLkTikBjxZEvWu+322qP2v0MU9xFQrgJmq2xA-Zdo32@mail.gmail.com>
	<201012071554.37519.oneukum@suse.de>
	<AANLkTi=Dzc37qxXC0oK48pnuWss9gHJE3ARDEUGfi7QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:50240 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab0LGQPj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 11:15:39 -0500
In-Reply-To: <AANLkTi=Dzc37qxXC0oK48pnuWss9gHJE3ARDEUGfi7QA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But what makes sure that the URB unlinked in unlink_urbs() stays a va=
lid pointer?
> The bottom half may run and free the URB.

I think it may be safe to remove the lock as we are walking a list of
SKBs not URBs,
the BH can remove SKB's from the list but we are doing a safe list walk=
=2E
+ the BH takse the list lock when it does the remove.

I could be wrong though?


On Tue, Dec 7, 2010 at 2:54 PM, Oliver Neukum <oneukum@suse.de> wrote:
> Am Dienstag, 7. Dezember 2010, 15:08:43 schrieb Neil Jones:
>> I think this is due to unlink_urbs():
>
> Definitely.
>
>> static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 flags;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0*skb, *skbnext;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =3D 0;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave (&q->lock, flags);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_queue_walk_safe(q, skb, skbnext) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct skb_d=
ata =C2=A0 =C2=A0 =C2=A0 =C2=A0 *entry;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct urb =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*urb;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 retval;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry =3D (s=
truct skb_data *) skb->cb;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 urb =3D entr=
y->urb;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 // during so=
me PM-driven resume scenarios,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 // these (as=
ync) unlinks complete immediately
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 retval =3D u=
sb_unlink_urb (urb);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (retval !=
=3D -EINPROGRESS && retval !=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 count++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore (&q->lock, flags)=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return count;
>> }
>>
>> I dont think this should hold the list lock when calling usb_unlink_=
urb (urb).
>> The completion for the URBs takes the lock as required in its bottom=
 half:
>
> But what makes sure that the URB unlinked in unlink_urbs() stays a va=
lid pointer?
> The bottom half may run and free the URB.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Regards
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Oliver
>
