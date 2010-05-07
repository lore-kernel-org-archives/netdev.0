From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: avoid one atomic in enqueue_to_backlog
Date: Fri, 7 May 2010 18:01:09 +0800
Message-ID: <m2x412e6f7f1005070301h627d5c76z35b3277f3a369c69@mail.gmail.com>
References: <1273136322.2357.15.camel@edumazet-laptop> <20100506.220759.25136752.davem@davemloft.net>
	<1273209375.2222.37.camel@edumazet-laptop> <1273225881.2261.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:36277 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756315Ab0EGKB3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 06:01:29 -0400
Received: by pxi5 with SMTP id 5so439455pxi.19
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 03:01:29 -0700 (PDT)
In-Reply-To: <1273225881.2261.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 7, 2010 at 5:51 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 07 mai 2010 =C3=A0 07:16 +0200, Eric Dumazet a =C3=A9crit=
 :
>> Le jeudi 06 mai 2010 =C3=A0 22:07 -0700, David Miller a =C3=A9crit :
>>
>> > Looks great, applied, thanks Eric.
>>
>> Thanks, I have a followup to avoid one atomic in enqueue phase too ;=
)
>>
>
> [PATCH net-next-2.6] rps: avoid one atomic in enqueue_to_backlog
>
> If CONFIG_SMP=3Dy, then we own a queue spinlock, we can avoid the ato=
mic
> test_and_set_bit() from napi_schedule_prep().
>
> We now have same number of atomic ops per netif_rx() calls than with
> pre-RPS kernel.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 32611c8..49fa5a6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2426,8 +2426,10 @@ enqueue:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return NET_RX_SUCCESS;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Schedule NAPI f=
or backlog device */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (napi_schedule_=
prep(&sd->backlog)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Schedule NAPI f=
or backlog device
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* We can use=
 non atomic operation since we own the queue lock
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!__test_and_se=
t_bit(NAPI_STATE_SCHED, &sd->backlog.state)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (!rps_ipi_queued(sd))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0____napi_schedule(sd, &sd->ba=
cklog);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>

Why not use a wrapper function?

sth. like:

static inline int __napi_schedule_prep(struct napi_struct *n)
{
   return (!__test_and_set_bit(NAPI_STATE_SCHED, &n->state)
}

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
