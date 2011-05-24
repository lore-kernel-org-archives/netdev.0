From: Joe Perches <joe@perches.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 00:35:07 -0700
Message-ID: <1306222507.2298.23.camel@Joe-Laptop>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
	 <20110524.011330.1077020828173889583.davem@davemloft.net>
	 <1306217837.2638.36.camel@edumazet-laptop>
	 <1306218793.2298.10.camel@Joe-Laptop>  <20110524065715.GB12816@elte.hu>
	 <1306220681.2638.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, tgraf@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1956 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287Ab1EXHfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 03:35:09 -0400
In-Reply-To: <1306220681.2638.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 09:04 +0200, Eric Dumazet wrote:
> Le mardi 24 mai 2011 =C3=A0 08:57 +0200, Ingo Molnar a =C3=A9crit :
> > * Joe Perches <joe@perches.com> wrote:
> > > Maybe for clarity it'd be better to use a switch/case
> > > or something like:
> Here we are, thanks.

Hey Eric.  Just more trivia:

> [PATCH v2] inet_diag: hide socket pointers
> Provide a mayber_hide_ptr() helper and use it in inet_diag to not

typo maybe_hide_ptr

> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> @@ -798,6 +798,26 @@ char *uuid_string(char *buf, char *end, const u8=
 *addr,
>  }
> =20
>  int kptr_restrict __read_mostly;
> +/**
> + * maybe_hide_ptr - Eventually nullify a kernel pointer given to use=
r

Not a great description.
Maybe something like:
 * maybe_hide_ptr - Set user values of kernel pointers to null
 *                  when appropriate
[]
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 6ffe94c..b5646a3 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -84,6 +84,7 @@ static int inet_csk_diag_fill(struct sock *sk,
>  	struct inet_diag_meminfo  *minfo =3D NULL;
>  	unsigned char	 *b =3D skb_tail_pointer(skb);
>  	const struct inet_diag_handler *handler;
> +	u64 ptr;
> =20
>  	handler =3D inet_diag_table[unlh->nlmsg_type];
>  	BUG_ON(handler =3D=3D NULL);
> @@ -114,8 +115,9 @@ static int inet_csk_diag_fill(struct sock *sk,
>  	r->idiag_retrans =3D 0;
> =20
>  	r->id.idiag_if =3D sk->sk_bound_dev_if;
> -	r->id.idiag_cookie[0] =3D (u32)(unsigned long)sk;
> -	r->id.idiag_cookie[1] =3D (u32)(((unsigned long)sk >> 31) >> 1);
> +	ptr =3D (u64)maybe_hide_ptr(sk);
> +	r->id.idiag_cookie[0] =3D (u32)ptr;
> +	r->id.idiag_cookie[1] =3D (u32)(ptr >> 32);

I think it's be better without the casts
using the standard kernel.h macros.

	void *ptr;

	ptr =3D maybe_hide_ptr(sk);
	r->id.idiag_cookie[0] =3D lower_32_bits(ptr);
	r->id.idiag_cookie[1] =3D upper_32_bits(ptr);


