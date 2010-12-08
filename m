From: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Fwd: usbnet: Recursive Locking bug ?
Date: Wed, 8 Dec 2010 09:58:54 +0000
Message-ID: <AANLkTimu-MiTHofLyZ8JLQc0umO9J+t2xt24FDhiQUyP@mail.gmail.com>
References: <AANLkTi=VB0Kt=2c1C1b-Ps8x_zA5Tnf+tfHjvO8gWgm8@mail.gmail.com>
	<917120.68161.qm@web180301.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <917120.68161.qm-g47maUHHHF+ORdMXk8NaZPu2YVrzzGjVVpNB7YpNyf8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>though I seem to have missed a post with the diagnostic saying
>>what lock is being recursed.

[ INFO: possible recursive locking detected ]
2.6.37-rc4+ #1695
---------------------------------------------
ifconfig/536 is trying to acquire lock:
 (&(&list->lock)->rlock#2){-.-...}, at: [<401a63bc>] _defer_bh+0x24/0x1=
24

but task is already holding lock:
 (&(&list->lock)->rlock#2){-.-...}, at: [<401a5f28>] _unlink_urbs+0x1c/=
0xa8

other info that might help us debug this:
2 locks held by ifconfig/536:
 #0:  (rtnl_mutex){+.+.+.}, at: [<4026b4f8>] _rtnl_lock+0x1c/0x2c
 #1:  (&(&list->lock)->rlock#2){-.-...}, at: [<401a5f28>] _unlink_urbs+=
0x1c/0xa8


We are using an OTG controller which isn't EHCI compliant and it has to
manage all the queues in software, thus unlinking URBs effectively
becomes synchronous. I cant see an easy solution to this short of modif=
ying
the OTG-HCD driver to defer the unlinking to a workqueue, but even
then its still
possible to get this scenario.

Cheers

Neil


On Wed, Dec 8, 2010 at 4:55 AM, David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> wr=
ote:
> I'll look at this some later, though I seem to
> have missed a post with the diagnostic saying
> what lock is being recursed.
>
> That particular chunk of code has periodically
> turned up problems, and isn't very pretty. =C2=A0But
> the most curious aspect of it is that it seemed
> to shake out HCD-specific behaviors. =C2=A0(We've
> gotten rid of most such code by now, this is a
> slight exception.
>
> Specifically, HCDs that could unlink speedily
> without certain locking patterns (ISTR OHCI and
> EHCI, if not also UHCI) didn't trigger oddness.
> But some other HCDs, with different approaches
> to unlinking URBs, were less happy. =C2=A0( I was
> likely working with MUSB at the time.)
>
> I spent some time trying to rework that code in
> "usbnet", but no clean-and-obvious solutions
> became apparent when I did that (a few years
> back). =C2=A0Plus, ISTR being the only person to
> find issues (back then), so I couldn't make
> an argument to spend much more time on it.
>
> Hope that helps anyone trying to fix this.
>
> - Dave
>
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
