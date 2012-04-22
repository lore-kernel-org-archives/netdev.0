From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Sun, 22 Apr 2012 09:45:55 +0800
Message-ID: <CA+v9cxbdQW1idnxes95vHMS+j2XPFw4fDfaDLbJa7enMnyq6LQ@mail.gmail.com>
References: <CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
	<CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
	<20120421.152345.290988116097275353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120421.152345.290988116097275353.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 22, 2012 at 3:23 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wro=
te:
> From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sat, 21 Apr 2012 09:49:51 +0800
>
>> I see the problem, so looks skb_queue_walk_safe is not safe.
>> I don' know why the 2nd ' tmp =3D skb->next' in =A0skb_queue_walk_sa=
fe
>> is needed and it may become unsafe if skb is freed during current lo=
op.
>
> I can't see what the problem is, skb_queue_walk_safe() is perfect
> and does exactly what it advertises to do.
>
> If 'skb' is unlinked inside of an skb_queue_walk_safe() loop, that's
> fine, because we won't touch 'skb' in the loop iteration tail code.
>
> Instead, before the loop contents, we pre-fetch skb->next into 'tmp'
> and then at the end we move 'skb' forward by simply assigning 'tmp'.

In this case, the problem is, 'tmp =3D skb->next' can be moved out of
rxq/txq, and even be freed. Then in next loop cycle, 'skb =3D tmp' will
refer to a freed skb.  You know, in current code stack, unlink_urbs()
releases q->lock in each loop, this gives chance to urb complete
handler to call defer_bh() and cause the problem.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
