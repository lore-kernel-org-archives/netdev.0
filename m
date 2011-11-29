From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Tue, 29 Nov 2011 10:31:33 +0100
Message-ID: <1322559093.2970.102.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
	 <1322511796-6908-2-git-send-email-igorm@etf.rs>
	 <1322512426.2970.15.camel@edumazet-laptop>
	 <1322515010.2970.24.camel@edumazet-laptop>
	 <fba9911084786bf04747c0350e774615.squirrel@kondor.etf.bg.ac.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35244 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188Ab1K2Jbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 04:31:39 -0500
Received: by vbbfc26 with SMTP id fc26so4557450vbb.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 01:31:38 -0800 (PST)
In-Reply-To: <fba9911084786bf04747c0350e774615.squirrel@kondor.etf.bg.ac.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 10:03 +0100, "Igor Maravi=C4=87" a =C3=
=A9crit :
> >
> > Could you test following patch ?
> >
>=20
> I've just put it to compile. I'l let you know soon as it finishes com=
piling.
>=20
> I have one proposition for your patch. To put WARN_ON before in ifdef=
 endif,
> because we don't needed if we don't have HAVE_JUMP_LABEL, and also to=
 check it
> before using jump_label_dec.
>=20
> Also I have few questions :)
>=20
> First - why can't we use spin_lock on jump_label?
>=20
> I know that You said that is because we are using mutex_lock in
> arch_jump_label_transform() or text_poke_smp(), but I don't see why c=
ouldn't
> we use mutex_lock inside spin_lock.
>=20


Try it, you'll see how bad it is.

> To me using spin_lock_irqsave and spin_lock_irqrestore does sound lik=
e as most logical solution.
> With that lock, we would be sure that our mutex_lock in arch_jump_lab=
el_transform() or text_poke_smp()
> isn't going to be interrupted.
> Please correct if I'm wrong.
>=20
> Also I saw that you put calling of net_enable_timestamp outside of sp=
in_lock_bh
> Why?
>=20

Because its the same problem. We want to be allowed to sleep.

> BR
> Igor
>=20
> [PATCH 1/1] jump_label warning if_interrupt
>=20
> Move warning on the top of function net_enable_timestamp,
> so we would be also warn if we are going to jump_label_dec in interru=
pt
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
>=20
> :100644 100644 45eab03... ef23cf7... M	net/core/dev.c
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 45eab03..ef23cf7 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1453,6 +1453,7 @@ void net_enable_timestamp(void)
>  {
>  #ifdef HAVE_JUMP_LABEL
>  	int deferred =3D atomic_xchg(&netstamp_needed_deferred, 0);
> +	WARN_ON(in_interrupt());
>=20
>  	if (deferred) {
>  		while (--deferred)
> @@ -1460,7 +1461,6 @@ void net_enable_timestamp(void)
>  		return;
>  	}
>  #endif
> -	WARN_ON(in_interrupt());
>  	jump_label_inc(&netstamp_needed);
>  }
>  EXPORT_SYMBOL(net_enable_timestamp);

Its better to have coverage of the test, even on machines with no
HAVE_JUMP_LABEL.

So move the test before the=20
#ifdef HAVE_JUMP_LABEL
