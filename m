From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [PATCH] timers: consider slack value in mod_timer()
Date: Thu, 26 May 2011 14:19:01 +0800
Message-ID: <BANLkTikW9cm75ZJg-=4Ab647-D3vAHHYdg@mail.gmail.com>
References: <20110521105828.GA29442@Chamillionaire.breakpoint.cc>
	<BANLkTinGZ0L4oQkBYo9H=R==X5Z+efjRaQ@mail.gmail.com>
	<20110524121343.GA17312@Chamillionaire.breakpoint.cc>
	<BANLkTikNSa9otE_cFKRcThUZ5ZCtE7Kyxw@mail.gmail.com>
	<alpine.LFD.2.02.1105251126590.3078@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	LKML <linux-kernel@vger.kernel.org>,
	Arjan van de Ven <arjan@infradead.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.02.1105251126590.3078@ionos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 6:17 PM, Thomas Gleixner <tglx@linutronix.de> w=
rote:
>> Hmmm, so the reason is for a timer whose timer->slack is not set
>> explicitly. when we recalculate expires, we will get different value
>> sometimes.
>
> No, that's not the problem.
>
>> Could you please try the attached patch(webmail will mangle it)
>
> Grrr. gmail allows usage of real mail clients, doesn't it ?

Yeah, but sometimes I can only access webmail due to some reason

>
>> diff --git a/kernel/timer.c b/kernel/timer.c
>> index fd61986..73af53c 100644
>> --- a/kernel/timer.c
>> +++ b/kernel/timer.c
>> @@ -749,6 +749,10 @@ unsigned long apply_slack(struct timer_list *ti=
mer, unsigned long expires)
>> =C2=A0 =C2=A0 =C2=A0 unsigned long expires_limit, mask;
>> =C2=A0 =C2=A0 =C2=A0 int bit;
>>
>> + =C2=A0 =C2=A0 /* no need to account slack again for a same-expire =
pending timer */
>> + =C2=A0 =C2=A0 if (timer_pending(timer) && time_after_eq(timer->exp=
ires, expires))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return timer->expires;
>
> That's total crap. Assume some code sets the timer with 5 seconds for
> some purpose and after a second it wants it to fire in 50ms from now
> because some state change happened. The above will keep the original =
5
> seconds timeout no matter what, so the requested 50ms timeout will
> fire about 4 seconds late.

Indeed. I forgot that case
=2E
>
>> =C2=A0 =C2=A0 =C2=A0 expires_limit =3D expires;
>>
>> =C2=A0 =C2=A0 =C2=A0 if (timer->slack >=3D 0) {
>> @@ -795,6 +799,8 @@ unsigned long apply_slack(struct timer_list *tim=
er, unsigned long expires)
>> =C2=A0 */
>> =C2=A0int mod_timer(struct timer_list *timer, unsigned long expires)
>> =C2=A0{
>> + =C2=A0 =C2=A0 expires =3D apply_slack(timer, expires);
>> +
>
> We need to analyse the problem thoroughly and not slap random changes
> into the code without knowing about the consequences. And the problem
> is mostly in the call sites because they are not aware of the slack
> effect.
>
> The sunrpc code is one of those which are affected by the slack magic
> simply because it makes the mod_timer() call basically unconditional
> even if the jiffies value is unchanged.
>
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index ce5eb68..cb0574f 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1053,10 +1053,12 @@ void xprt_release(struct rpc_task *task)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0xprt->ops->rel=
ease_request(task);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!list_empty(&req->rq_list))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&req-=
>rq_list);
> - =C2=A0 =C2=A0 =C2=A0 xprt->last_used =3D jiffies;
> - =C2=A0 =C2=A0 =C2=A0 if (list_empty(&xprt->recv) && xprt_has_timer(=
xprt))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mod_timer(&xprt->t=
imer,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xprt->last_used + xprt->idle_timeou=
t);
> + =C2=A0 =C2=A0 =C2=A0 if (xprt->last_used =3D jiffies) {

Typo? s/=3D/!=3D/?

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xprt->last_used =3D=
 jiffies;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (list_empty(&xp=
rt->recv) && xprt_has_timer(xprt))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 mod_timer(&xprt->timer,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xprt->last_used + xprt->idle=
_timeout);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_bh(&xprt->transport_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (req->rq_buffer)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0xprt->ops->buf=
_free(req->rq_buffer);
>
> The above patch does not solve the problem when the resulting new
> timeout is rounded up to the same expiry value after the slack is
> applied, which is not unlikely when jiffies only advanced by a small
> amount.
>
> So we must check after apply_slack() and the reason why the first
> check before apply_slack triggers very often is that auto slack only
> changes the expiry value for timeouts >=3D 256 jiffies.
>
> And the main caller is the networking code via
> tcp_send_delayed_ack(). The standard delay we see from there is 40ms
> (10 jiffies for HZ=3D250) and that falls below the 256 jiffies tresho=
ld.
>
> The patch below is a reasonable compromise between overhead and
> correctness.

Yup, I think it could smooth Sebastian's issue.

Thanks,
Yong

>
> Thanks,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tglx
>
> diff --git a/kernel/timer.c b/kernel/timer.c
> index fd61986..458fd81 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -749,16 +749,15 @@ unsigned long apply_slack(struct timer_list *ti=
mer, unsigned long expires)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long expires_limit, mask;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int bit;
>
> - =C2=A0 =C2=A0 =C2=A0 expires_limit =3D expires;
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (timer->slack >=3D 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0expires_limit =
=3D expires + timer->slack;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long now =
=3D jiffies;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 long delta =3D exp=
ires - jiffies;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (delta < 256)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return expires;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* No slack, if al=
ready expired else auto slack 0.4% */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (time_after(exp=
ires, now))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 expires_limit =3D expires + (expires - now)/256;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 expires_limit =3D =
expires + (expires - now)/256;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mask =3D expires ^ expires_limit;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mask =3D=3D 0)
> @@ -795,6 +794,8 @@ unsigned long apply_slack(struct timer_list *time=
r, unsigned long expires)
> =C2=A0*/
> =C2=A0int mod_timer(struct timer_list *timer, unsigned long expires)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 expires =3D apply_slack(timer, expires);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * This is a common optimization triggered=
 by the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * networking code - if the timer is re-mo=
dified
> @@ -803,8 +804,6 @@ int mod_timer(struct timer_list *timer, unsigned =
long expires)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (timer_pending(timer) && timer->expires=
 =3D=3D expires)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
>
> - =C2=A0 =C2=A0 =C2=A0 expires =3D apply_slack(timer, expires);
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __mod_timer(timer, expires, false, =
TIMER_NOT_PINNED);
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(mod_timer);
>



--=20
Only stand for myself
