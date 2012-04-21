From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 17:40:16 +0800
Message-ID: <CACVXFVOemJqfT9OPRer3qzbVEsGyUOupoOUNCBzC4deNRsksQw@mail.gmail.com>
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
	<CA+v9cxa+fyzMOD-=oLLczpu1FDtTwcok+y2FkC=mHzDH3JYJ2A@mail.gmail.com>
	<CACVXFVOMTbq0zbmsZAt-Pyc=3oqQ=UcWV5HgNryu7s6oMhKpQg@mail.gmail.com>
	<CA+v9cxZRpthaZ=64tLzKf=AGOqaRVwe5o0UMadiXGuiuXiA7uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxZRpthaZ=64tLzKf=AGOqaRVwe5o0UMadiXGuiuXiA7uA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Huajun,

On Sat, Apr 21, 2012 at 4:23 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
> On Sat, Apr 21, 2012 at 3:56 PM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:
>> Hi Huajun,
>>
>> On Sat, Apr 21, 2012 at 3:50 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
>>
>>> Did we on the same page, could you please review my patch again?
>>>
>>> My draft patch was based on current mainline( 3.4.0-rc3) =A0which h=
ad
>>> already integrated your previous patch. And in my patch, it replace=
d
>>> skb_queue_walk_safe() with skb_queue_walk(), so you will not see =A0=
'tmp
>>> =3D skb->next' =A0any more.
>>
>> Replace skb_queue_walk_safe with skb_queue_walk doesn't improve
>> the problem, since 'skb =3D skb->next' in skb_queue_walk still may t=
rigger
>> the oops, does it?
>>
>
> No.
> In each loop, my patch traverse the queue from its head, and it alway=
s
> holds =A0q->lock when it need refer "skb->next", this can make sure t=
he
> right skb is not moved out of rxq/txq.

OK, your patch can avoid the oops, sorry for miss the point.

>
> Can this fix what you concern? If so, IMO, there is no need to revert
> your previous patch.

But your patch may introduce another problem, in fact, what your patch =
does
is basically same with the below change[1]:

So we can find easily that one same URB may be unlinked more than one
time with your patch because usb_unlink_urb is asynchronous even though
it behaves synchronously sometimes.

I remembered that is not allowed, at least usb_unlink_urb's comment say=
s so:

          URBs complete only once per submission, and may be canceled o=
nly
          once per submission.


[1], against 3.4.0-rc3
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index db99536..aadf009 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -578,15 +578,19 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
 static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 {
 	unsigned long		flags;
-	struct sk_buff		*skb, *skbnext;
+	struct sk_buff		*skb;
 	int			count =3D 0;

 	spin_lock_irqsave (&q->lock, flags);
-	skb_queue_walk_safe(q, skb, skbnext) {
+	while (1) {
 		struct skb_data		*entry;
 		struct urb		*urb;
 		int			retval;

+		skb =3D q->next;
+		if (skb =3D=3D (struct sk_buff *)q)
+			break;
+
 		entry =3D (struct skb_data *) skb->cb;
 		urb =3D entry->urb;


Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
