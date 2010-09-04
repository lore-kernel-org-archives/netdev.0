From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 04 Sep 2010 10:24:07 +0200
Message-ID: <1283588647.3402.12.camel@edumazet-laptop>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	 <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
	 <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
	 <1283370450.2484.19.camel@edumazet-laptop>
	 <201009040658.o846wxnU028775@www262.sakura.ne.jp>
	 <1283584269.3402.9.camel@edumazet-laptop>
	 <201009040740.o847eB4f040772@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40974 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab0IDIYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 04:24:12 -0400
Received: by fxm13 with SMTP id 13so1707081fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 01:24:11 -0700 (PDT)
In-Reply-To: <201009040740.o847eB4f040772@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 septembre 2010 =C3=A0 16:40 +0900, Tetsuo Handa a =C3=A9cr=
it :
> Eric Dumazet wrote:
> > Sorry, this wont work very well if you have many processes using
> > autobind(). Some of them will loop many time before hitting
> > "stop_ordernum".
>=20
> I see. Then, we should use local counter rather than global counter f=
or yield()
> checking in case there are multiple threads hitting this loop.
> ----------------------------------------
> From 57a49c7b5a39de58d4538b85c60c758be3d2ce4f Mon Sep 17 00:00:00 200=
1
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 4 Sep 2010 16:23:46 +0900
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
> This patch adds a loop counter in order to give up after 1048576 atte=
mpts and
> use the loop counter in order to count yield() interval more reliably=
 when
> there are many threads hitting this loop.
>=20
> Note that currently a local user can consume 2GB of kernel memory if =
the user
> is allowed to create and autobind 1048576 UNIX domain sockets. We sho=
uld
> consider adding some restriction for autobind operation.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/unix/af_unix.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 4414a18..eedfe50 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -692,6 +692,7 @@ static int unix_autobind(struct socket *sock)
>  	static u32 ordernum =3D 1;
>  	struct unix_address *addr;
>  	int err;
> +	unsigned int retries =3D 0;
> =20
>  	mutex_lock(&u->readlock);
> =20
> @@ -717,8 +718,14 @@ retry:
>  	if (__unix_find_socket_byname(net, addr->name, addr->len, sock->typ=
e,
>  				      addr->hash)) {
>  		spin_unlock(&unix_table_lock);
> +		/* Give up if all names seems to be in use. */
> +		if (retries++ =3D=3D 0xFFFFF) {
> +			err =3D -ENOMEM;
> +			kfree(addr);
> +			goto out;
> +		}
>  		/* Sanity yield. It is unusual case, but yet... */
> -		if (!(ordernum&0xFF))
> +		if (!(retries & 0xFF))
>  			yield();
>  		goto retry;
>  	}


Quite frankly, given __unix_find_socket_byname() can take quite a long
time with one million entries in table, we should just remove

if (whatever)
	yield();

and use a more friendly :

cond_resched();



