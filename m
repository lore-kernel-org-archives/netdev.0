From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Sat, 28 Jan 2012 10:36:31 +0100
Message-ID: <CAHXqBFJLFYBUnSRbSYyuS5MeuR_vQ_DN0emdwsnGjuz9Xt0BHw@mail.gmail.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com> <20120127205903.GG24507@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38862 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab2A1Jgv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 04:36:51 -0500
Received: by iacb35 with SMTP id b35so3028640iac.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 01:36:51 -0800 (PST)
In-Reply-To: <20120127205903.GG24507@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/27 Francois Romieu <romieu@fr.zoreil.com>:
[...]
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -716,7 +722,10 @@ struct rtl8169_private {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int (*do_ioctl)(struct rtl8169_private *tp=
, struct mii_ioctl_data *data, int cmd);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DECLARE_BITMAP(fla=
gs, RTL_FLAG_MAX);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mutex mutex=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct work_st=
ruct work;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool enabled;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} wk;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned features;
> @@ -768,13 +777,20 @@ static int rtl8169_close(struct net_device *dev=
);
[...]
> +static void rtl_lock_work(struct rtl8169_private *tp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&tp->wk.mutex);
> +}
> +
> +static void rtl_unlock_work(struct rtl8169_private *tp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&tp->wk.mutex);
> +}
> +
[...]
> +static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl_f=
lag flag)
> +{
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&tp->lock);
> + =C2=A0 =C2=A0 =C2=A0 if (!test_and_set_bit(flag, tp->wk.flags))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule_work(&tp-=
>wk.work);
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&tp->lock);
> +}
> +
> +static void rtl_schedule_task_bh(struct rtl8169_private *tp, enum rt=
l_flag flag)
> +{
> + =C2=A0 =C2=A0 =C2=A0 local_bh_disable();
> + =C2=A0 =C2=A0 =C2=A0 rtl_schedule_task(tp, flag);
> + =C2=A0 =C2=A0 =C2=A0 local_bh_enable();
> +}
> +

It might be enough to do:

rtl_schedule_task():

set_bit(flag, tp->wk.flags);
schedule_work(&tp->wk.work);

This will guarantee that the work is done at least once (twice in
unlikely case that it was being executed just before schedule_work()).

[...]
> +/*
> + * Workqueue context.
> + */
> +static void rtl_slow_event_work(struct rtl8169_private *tp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *dev =3D tp->dev;
> + =C2=A0 =C2=A0 =C2=A0 u16 status;
> +
> + =C2=A0 =C2=A0 =C2=A0 status =3D rtl_get_events(tp) & tp->event_slow=
;
> + =C2=A0 =C2=A0 =C2=A0 rtl_ack_events(tp, status);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(statu=
s & SYSErr)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 rtl8169_pcierr_interrupt(dev);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(status & RxFIFOOver)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (tp->mac_ve=
rsion) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Work around for=
 rx fifo overflow */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case RTL_GIGA_MAC_=
VER_11:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 netif_stop_queue(dev);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);

Since this is running from the same task it schedules, it should be
enough to set_bit() and ensure that rtl_slow_event_work() is first on
the list in rtl_task().

[...]

> =C2=A0static void rtl_task(struct work_struct *work)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 static const struct {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int bitnr;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void (*action)(str=
uct rtl8169_private *);
> + =C2=A0 =C2=A0 =C2=A0 } rtl_work[] =3D {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 { RTL_FLAG_TASK_SL=
OW_PENDING, =C2=A0 rtl_slow_event_work },
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 { RTL_FLAG_TASK_RE=
SET_PENDING, =C2=A0rtl_reset_work },
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 { RTL_FLAG_TASK_PH=
Y_PENDING, =C2=A0 =C2=A0rtl_phy_work }
> + =C2=A0 =C2=A0 =C2=A0 };
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rtl8169_private *tp =3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0container_of(w=
ork, struct rtl8169_private, wk.work);
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *dev =3D tp->dev;
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 rtl_lock_work(tp);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!netif_running(dev) || !tp->wk.enabled)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < ARRAY_SIZE(rtl_work); i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool pending;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_bh(&tp->=
lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pending =3D test_a=
nd_clear_bit(rtl_work[i].bitnr, tp->wk.flags);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&tp=
->lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pending)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 rtl_work[i].action(tp);
> + =C2=A0 =C2=A0 =C2=A0 }

This is equivalent to: (the lock does nothing here)

for (...)
   if (test_and_clear_bit(rtl_work[i].bitnr, tp->wk.flags))
      rtl_work[i].action(tp);

This still races with rtl_schedule_task(), but the race is harmless.

[...]
> @@ -5959,7 +5970,11 @@ static int rtl8169_close(struct net_device *de=
v)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Update counters before going down */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtl8169_update_counters(dev);
>
> + =C2=A0 =C2=A0 =C2=A0 rtl_lock_work(tp);
> + =C2=A0 =C2=A0 =C2=A0 tp->wk.enabled =3D false;

clear_bit() would work, too. rtl_lock_work() makes sure the work is
not running (or even if it waits on this lock, i won't run after
seeing !enabled).

> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtl8169_down(dev);
> + =C2=A0 =C2=A0 =C2=A0 rtl_unlock_work(tp);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_irq(dev->irq, dev);
>
[...]
> @@ -6081,7 +6096,9 @@ static void __rtl8169_resume(struct net_device =
*dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rtl_pll_power_up(tp);
>
> - =C2=A0 =C2=A0 =C2=A0 rtl8169_schedule_work(dev);
> + =C2=A0 =C2=A0 =C2=A0 tp->wk.enabled =3D true;

set_bit() would be enough here (as work is guaranteed to not be
running before because of suspend()).

> +
> + =C2=A0 =C2=A0 =C2=A0 rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_P=
ENDING);
> =C2=A0}
>
> =C2=A0static int rtl8169_resume(struct device *device)
[...]

Best Regards,
Micha=C5=82 Miros=C5=82aw
