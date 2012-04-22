From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Sun, 22 Apr 2012 21:15:36 +0800
Message-ID: <CA+v9cxZfzATWynXGtEe6gvcD2aRsLqAF3ZN_HM_dyU4W_rQSpg@mail.gmail.com>
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
	<CACVXFVNc_S8pTaBqMzQZx6Dt-tSP_9iXepxJzv=iR9BFu=Tj8g@mail.gmail.com>
	<CA+v9cxaqL1V3eyv=dhKbqbnXk6wm1qm93DNFbrbwbd1b1X+3rw@mail.gmail.com>
	<CACVXFVMZKBm_=wL=-T=7z8hc+KGHHSNsoRGwHOL4gZtfsZJ46g@mail.gmail.com>
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
Received: from mail-wi0-f172.google.com ([209.85.212.172]:32995 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab2DVNPj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 09:15:39 -0400
In-Reply-To: <CACVXFVMZKBm_=wL=-T=7z8hc+KGHHSNsoRGwHOL4gZtfsZJ46g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 22, 2012 at 8:05 PM, Ming Lei <tom.leiming@gmail.com> wrote=
:
> On Sun, Apr 22, 2012 at 10:19 AM, Huajun Li <huajun.li.lee@gmail.com>=
 wrote:
>> On Sat, Apr 21, 2012 at 3:45 PM, Ming Lei <tom.leiming@gmail.com> wr=
ote:
>>> Hi Huajun,
>>>
>>> On Sat, Apr 21, 2012 at 3:06 PM, Ming Lei <tom.leiming@gmail.com> w=
rote:
>>>>> Just skip trying this per your following email's comments.
>>>>
>>>> I will prepare a new patch later, if you'd like to try it.
>>>
>>> The below patch reverts the below commits:
>>>
>>> =A0 =A0 =A0 0956a8c20b23d429e79ff86d4325583fc06f9eb4
>>> =A0 =A0 =A0(usbnet: increase URB reference count before usb_unlink_=
urb)
>>>
>>> =A0 =A0 =A04231d47e6fe69f061f96c98c30eaf9fb4c14b96d
>>> =A0 =A0 =A0(net/usbnet: avoid recursive locking in usbnet_stop())
>>>
>>> and keep holding tx/rx queue lock during unlinking, but avoid
>>> to acquire the same queue lock inside complete handler triggered by
>>> usb_unlink_urb.
>>>
>>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>>> index db99536..effb34e 100644
>>> --- a/drivers/net/usb/usbnet.c
>>> +++ b/drivers/net/usb/usbnet.c
>>> @@ -291,9 +291,11 @@ static void defer_bh(struct usbnet *dev, struc=
t
>>> sk_buff *skb, struct sk_buff_hea
>>> =A0{
>>> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
>>>
>>> - =A0 =A0 =A0 spin_lock_irqsave(&list->lock, flags);
>>> + =A0 =A0 =A0 if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&list->lock, flags)=
;
>>> =A0 =A0 =A0 =A0__skb_unlink(skb, list);
>>> - =A0 =A0 =A0 spin_unlock(&list->lock);
>>> + =A0 =A0 =A0 if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&list->lock);
>>> =A0 =A0 =A0 =A0spin_lock(&dev->done.lock);
>>> =A0 =A0 =A0 =A0__skb_queue_tail(&dev->done, skb);
>>> =A0 =A0 =A0 =A0if (dev->done.qlen =3D=3D 1)
>>
>>
>> Then 'flags' may not be initialized, and this will cause problem whi=
le
>> calling spin_unlock_irqrestore(&dev->done.lock, flags), right?
>
> The flag is a percpu variable, so it can't change during the
> above code piece.
>

No, maybe you misunderstood it.
Legacy code stack has 'flags' variable to save irq information, and at
the end defer_bh(), spin_unlock_irqrestore(&dev->done.lock, flags)
will use it. However, the variable may not be initialized in your
patch.

>>
>>
>>> @@ -345,7 +347,8 @@ static int rx_submit (struct usbnet *dev, struc=
t
>>> urb *urb, gfp_t flags)
>>> =A0 =A0 =A0 =A0usb_fill_bulk_urb (urb, dev->udev, dev->in,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->data, size, rx_complete, skb);
>>>
>>> - =A0 =A0 =A0 spin_lock_irqsave (&dev->rxq.lock, lockflags);
>>> + =A0 =A0 =A0 if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave (&dev->rxq.lock, lo=
ckflags);
>>>
>>> =A0 =A0 =A0 =A0if (netif_running (dev->net) &&
>>> =A0 =A0 =A0 =A0 =A0 =A0netif_device_present (dev->net) &&
>>> @@ -377,7 +380,8 @@ static int rx_submit (struct usbnet *dev, struc=
t
>>> urb *urb, gfp_t flags)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_dbg(dev, ifdown, dev->net, "rx=
: stopped\n");
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D -ENOLINK;
>>> =A0 =A0 =A0 =A0}
>>> - =A0 =A0 =A0 spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
>>> + =A0 =A0 =A0 if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore (&dev->rxq.loc=
k, lockflags);
>>> =A0 =A0 =A0 =A0if (retval) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb_any (skb);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usb_free_urb (urb);
>>> @@ -582,6 +586,7 @@ static int unlink_urbs (struct usbnet *dev, str=
uct
>>> sk_buff_head *q)
>>> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D=
 0;
>>>
>>> =A0 =A0 =A0 =A0spin_lock_irqsave (&q->lock, flags);
>>> + =A0 =A0 =A0 set_cpu_bit(URB_UNLINKING, dev->cpuflags);
>>> =A0 =A0 =A0 =A0skb_queue_walk_safe(q, skb, skbnext) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct skb_data =A0 =A0 =A0 =A0 *ent=
ry;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*urb;
>>> @@ -590,15 +595,6 @@ static int unlink_urbs (struct usbnet *dev,
>>> struct sk_buff_head *q)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry =3D (struct skb_data *) skb->c=
b;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb =3D entry->urb;
>>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Get reference count of the URB t=
o avoid it to be
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* freed during usb_unlink_urb, whi=
ch may trigger
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* use-after-free problem inside us=
b_unlink_urb since
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* usb_unlink_urb is always racing =
with .complete
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* handler(include defer_bh).
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_get_urb(urb);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&q->lock, flag=
s);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// during some PM-driven resume scen=
arios,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// these (async) unlinks complete im=
mediately
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D usb_unlink_urb (urb);
>>> @@ -606,9 +602,8 @@ static int unlink_urbs (struct usbnet *dev, str=
uct
>>> sk_buff_head *q)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_dbg(dev->net,=
 "unlink urb err, %d\n", retval);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count++;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_put_urb(urb);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&q->lock, flags);
>>> =A0 =A0 =A0 =A0}
>>> + =A0 =A0 =A0 clear_cpu_bit(URB_UNLINKING, dev->cpuflags);
>>> =A0 =A0 =A0 =A0spin_unlock_irqrestore (&q->lock, flags);
>>> =A0 =A0 =A0 =A0return count;
>>> =A0}
>>> @@ -1283,6 +1278,7 @@ void usbnet_disconnect (struct usb_interface =
*intf)
>>> =A0 =A0 =A0 =A0usb_kill_urb(dev->interrupt);
>>> =A0 =A0 =A0 =A0usb_free_urb(dev->interrupt);
>>>
>>> + =A0 =A0 =A0 free_percpu(dev->cpuflags);
>>> =A0 =A0 =A0 =A0free_netdev(net);
>>> =A0 =A0 =A0 =A0usb_put_dev (xdev);
>>> =A0}
>>> @@ -1353,6 +1349,13 @@ usbnet_probe (struct usb_interface *udev, co=
nst
>>> struct usb_device_id *prod)
>>> =A0 =A0 =A0 =A0SET_NETDEV_DEV(net, &udev->dev);
>>>
>>> =A0 =A0 =A0 =A0dev =3D netdev_priv(net);
>>> +
>>> + =A0 =A0 =A0 dev->cpuflags =3D alloc_percpu(unsigned long);
>>> + =A0 =A0 =A0 if (!dev->cpuflags) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -ENOMEM;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out1;
>>> + =A0 =A0 =A0 }
>>> +
>>> =A0 =A0 =A0 =A0dev->udev =3D xdev;
>>> =A0 =A0 =A0 =A0dev->intf =3D udev;
>>> =A0 =A0 =A0 =A0dev->driver_info =3D info;
>>> @@ -1396,7 +1399,7 @@ usbnet_probe (struct usb_interface *udev, con=
st
>>> struct usb_device_id *prod)
>>> =A0 =A0 =A0 =A0if (info->bind) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D info->bind (dev, udev);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (status < 0)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out1;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out2;
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// heuristic: =A0"usb%d" for links w=
e know are two-host,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// else "eth%d" when there's reasona=
ble doubt. =A0userspace
>>> @@ -1465,6 +1468,8 @@ usbnet_probe (struct usb_interface *udev, con=
st
>>> struct usb_device_id *prod)
>>> =A0out3:
>>> =A0 =A0 =A0 =A0if (info->unbind)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->unbind (dev, udev);
>>> +out2:
>>> + =A0 =A0 =A0 free_percpu(dev->cpuflags);
>>> =A0out1:
>>> =A0 =A0 =A0 =A0free_netdev(net);
>>> =A0out:
>>> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.=
h
>>> index 605b0aa..2dc46f5 100644
>>> --- a/include/linux/usb/usbnet.h
>>> +++ b/include/linux/usb/usbnet.h
>>> @@ -69,8 +69,28 @@ struct usbnet {
>>> =A0# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_WAKING 6
>>> =A0# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_ASLEEP 7
>>> =A0# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_OPEN =A0 8
>>> + =A0 =A0 =A0 unsigned long __percpu *cpuflags;
>>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define URB_UNLINKING =A0 =A00
>>
>> Is it possible using a simple bool variable to track whether q->lock
>> is hold by unlink_urb() ? =A0If yes, it can avoid introducing follow=
ing
>> new codes into current code stack.
>
> It should be defined as percpu variable. The URB complete handler
> may be triggered inside unlink path, or it can be triggered in hardir=
q path
> from other CPUs at the same time.
>

Then the potential issue is,  in defer_bh(),  __skb_unlink() may be
called without holding the lock. This can cause current issue too,
because __skb_unlink() may move 'skb->next' out of txq/rxq, and even
free it.

>>
>>> =A0};
>>>
>>> +static inline void set_cpu_bit(int nr, unsigned long __percpu *add=
r)
>>> +{
>>> + =A0 =A0 =A0 unsigned long *fl =3D __this_cpu_ptr(addr);
>>> + =A0 =A0 =A0 set_bit(nr, fl);
>>> +}
>>> +
>>> +static inline void clear_cpu_bit(int nr, unsigned long __percpu *a=
ddr)
>>> +{
>>> + =A0 =A0 =A0 unsigned long *fl =3D __this_cpu_ptr(addr);
>>> + =A0 =A0 =A0 clear_bit(nr, fl);
>>> +}
>>> +
>>> +static inline int test_cpu_bit(int nr, unsigned long __percpu *add=
r)
>>> +{
>>> + =A0 =A0 =A0 unsigned long *fl =3D __this_cpu_ptr(addr);
>>> + =A0 =A0 =A0 return test_bit(nr, fl);
>>> +}
>>> +
>>> =A0static inline struct usb_driver *driver_of(struct usb_interface =
*intf)
>>> =A0{
>>> =A0 =A0 =A0 =A0return to_usb_driver(intf->dev.driver);
>>>
>>>
>>> Thanks,
>>> --
>>> Ming Lei
>
>
>
> --
> Ming Lei
