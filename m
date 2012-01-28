From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Sat, 28 Jan 2012 12:11:21 +0100
Message-ID: <20120128111121.GA32163@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com> <20120127205903.GG24507@electric-eye.fr.zoreil.com> <CAHXqBFJLFYBUnSRbSYyuS5MeuR_vQ_DN0emdwsnGjuz9Xt0BHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42529 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab2A1LWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 06:22:22 -0500
Content-Disposition: inline
In-Reply-To: <CAHXqBFJLFYBUnSRbSYyuS5MeuR_vQ_DN0emdwsnGjuz9Xt0BHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> :
> 2012/1/27 Francois Romieu <romieu@fr.zoreil.com>:
[...]
> > +static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl=
_flag flag)
> > +{
> > + =C2=A0 =C2=A0 =C2=A0 spin_lock(&tp->lock);
> > + =C2=A0 =C2=A0 =C2=A0 if (!test_and_set_bit(flag, tp->wk.flags))
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule_work(&t=
p->wk.work);
> > + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&tp->lock);
> > +}
> > +
> > +static void rtl_schedule_task_bh(struct rtl8169_private *tp, enum =
rtl_flag flag)
> > +{
> > + =C2=A0 =C2=A0 =C2=A0 local_bh_disable();
> > + =C2=A0 =C2=A0 =C2=A0 rtl_schedule_task(tp, flag);
> > + =C2=A0 =C2=A0 =C2=A0 local_bh_enable();
> > +}
> > +
>=20
> It might be enough to do:
>=20
> rtl_schedule_task():
>=20
> set_bit(flag, tp->wk.flags);
> schedule_work(&tp->wk.work);
>=20
> This will guarantee that the work is done at least once (twice in
> unlikely case that it was being executed just before schedule_work())=
=2E

If I understand correctly this remark and the following ones, you are
suggesting to completely avoid the lock to access the bitfield ?=20

[...]
> > +/*
> > + * Workqueue context.
> > + */
> > +static void rtl_slow_event_work(struct rtl8169_private *tp)
> > +{
[...]
> > + =C2=A0 =C2=A0 =C2=A0 if (unlikely(status & RxFIFOOver)) {
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (tp->mac_=
version) {
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Work around f=
or rx fifo overflow */
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case RTL_GIGA_MA=
C_VER_11:
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 netif_stop_queue(dev);
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
>=20
> Since this is running from the same task it schedules, it should be
> enough to set_bit() and ensure that rtl_slow_event_work() is first on
> the list in rtl_task().

I saw "first in list" as mildly maintenable. Ok, I buy it if nobody com=
plains.

--=20
Ueimor
