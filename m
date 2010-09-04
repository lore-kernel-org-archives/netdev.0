From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 04 Sep 2010 09:11:09 +0200
Message-ID: <1283584269.3402.9.camel@edumazet-laptop>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	 <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
	 <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
	 <1283370450.2484.19.camel@edumazet-laptop>
	 <201009040658.o846wxnU028775@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58574 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab0IDHLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 03:11:16 -0400
Received: by fxm13 with SMTP id 13so1689498fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 00:11:15 -0700 (PDT)
In-Reply-To: <201009040658.o846wxnU028775@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 septembre 2010 =C3=A0 15:58 +0900, Tetsuo Handa a =C3=A9cr=
it :
> From a67ccbb8033993df29f26bde9944e37bffe4fc1b Mon Sep 17 00:00:00 200=
1
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 4 Sep 2010 15:22:22 +0900
> Subject: [PATCH] UNIX: Do not loop forever at unix_autobind().
>=20
> We assumed that unix_autobind() never fails if kzalloc() succeeded.
> But unix_autobind() allows only 1048576 names. If /proc/sys/fs/file-m=
ax is
> larger than 1048576 (e.g. systems with more than 10GB of RAM), a loca=
l user can
> consume all names using fork()/socket()/bind().
>=20
> If all names are in use, those who call bind() with addr_len =3D=3D s=
izeof(short)
> or connect()/sendmsg() with setsockopt(SO_PASSCRED) will continue
>=20
>   while (1)
>   	yield();
>=20
> loop at unix_autobind() till a name becomes available.
> This patch changes unix_autobind() to fail if all names are in use.
>=20
> Note that currently a local user can consume 2GB of kernel memory if =
the user
> is allowed to create and autobind 1048576 UNIX domain sockets. We sho=
uld
> consider adding some restriction for autobind operation.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/unix/af_unix.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 4414a18..46fc6b2 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -692,6 +692,7 @@ static int unix_autobind(struct socket *sock)
>  	static u32 ordernum =3D 1;
>  	struct unix_address *addr;
>  	int err;
> +	u32 stop_ordernum;
> =20
>  	mutex_lock(&u->readlock);
> =20
> @@ -706,6 +707,7 @@ static int unix_autobind(struct socket *sock)
> =20
>  	addr->name->sun_family =3D AF_UNIX;
>  	atomic_set(&addr->refcnt, 1);
> +	stop_ordernum =3D ordernum;
> =20
>  retry:
>  	addr->len =3D sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1=
 + sizeof(short);
> @@ -720,6 +722,12 @@ retry:
>  		/* Sanity yield. It is unusual case, but yet... */
>  		if (!(ordernum&0xFF))
>  			yield();
> +		/* Give up if all names are in use. */
> +		if (ordernum =3D=3D stop_ordernum) {
> +			err =3D -ENOMEM;
> +			kfree(addr);
> +			goto out;
> +		}
>  		goto retry;
>  	}
>  	addr->hash ^=3D sk->sk_type;


Sorry, this wont work very well if you have many processes using
autobind(). Some of them will loop many time before hitting
"stop_ordernum".

unsigned int counter;

=2E..

if (++maxtries =3D=3D 1<<20) {
	...
}


This is a pathological situation. We are not forced to give a successfu=
l
autobind() when so many sockets are in use, even if some slots are
available.

Thanks


