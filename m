From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 7/7] r8169: remove work from irq handler.
Date: Sat, 28 Jan 2012 13:12:38 +0100
Message-ID: <CAHXqBFJOR1U91B72K1SgPTwXVPO1ZuYdJmi_HDMvW5_3Kw5NQA@mail.gmail.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
 <20120127205903.GG24507@electric-eye.fr.zoreil.com> <CAHXqBFJLFYBUnSRbSYyuS5MeuR_vQ_DN0emdwsnGjuz9Xt0BHw@mail.gmail.com>
 <20120128111121.GA32163@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48238 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab2A1MM6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 07:12:58 -0500
Received: by iacb35 with SMTP id b35so3122500iac.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 04:12:58 -0800 (PST)
In-Reply-To: <20120128111121.GA32163@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 28 stycznia 2012 12:11 u=BFytkownik Francois Romieu
<romieu@fr.zoreil.com> napisa=B3:
> Micha=B3 Miros=B3aw <mirqus@gmail.com> :
>> 2012/1/27 Francois Romieu <romieu@fr.zoreil.com>:
> [...]
>> > +static void rtl_schedule_task(struct rtl8169_private *tp, enum rt=
l_flag flag)
>> > +{
>> > + =A0 =A0 =A0 spin_lock(&tp->lock);
>> > + =A0 =A0 =A0 if (!test_and_set_bit(flag, tp->wk.flags))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&tp->wk.work);
>> > + =A0 =A0 =A0 spin_unlock(&tp->lock);
>> > +}
>> > +
>> > +static void rtl_schedule_task_bh(struct rtl8169_private *tp, enum=
 rtl_flag flag)
>> > +{
>> > + =A0 =A0 =A0 local_bh_disable();
>> > + =A0 =A0 =A0 rtl_schedule_task(tp, flag);
>> > + =A0 =A0 =A0 local_bh_enable();
>> > +}
>> > +
>>
>> It might be enough to do:
>>
>> rtl_schedule_task():
>>
>> set_bit(flag, tp->wk.flags);
>> schedule_work(&tp->wk.work);
>>
>> This will guarantee that the work is done at least once (twice in
>> unlikely case that it was being executed just before schedule_work()=
).
>
> If I understand correctly this remark and the following ones, you are
> suggesting to completely avoid the lock to access the bitfield ?

Yes. In case of clearing the enable flag (regardless if you move it
from separate bool to the bitmap) mutex needed though.

BTW, on resume, are the flags always cleared?

> [...]
>> > +/*
>> > + * Workqueue context.
>> > + */
>> > +static void rtl_slow_event_work(struct rtl8169_private *tp)
>> > +{
> [...]
>> > + =A0 =A0 =A0 if (unlikely(status & RxFIFOOver)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (tp->mac_version) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Work around for rx fifo overflow =
*/
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case RTL_GIGA_MAC_VER_11:
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(dev=
);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtl_schedule_task_bh=
(tp, RTL_FLAG_TASK_RESET_PENDING);
>>
>> Since this is running from the same task it schedules, it should be
>> enough to set_bit() and ensure that rtl_slow_event_work() is first o=
n
>> the list in rtl_task().
> I saw "first in list" as mildly maintenable. Ok, I buy it if nobody c=
omplains.

You should add a comment here and in rtl_task(), of course.

Best Regards,
Micha=B3 Miros=B3aw
