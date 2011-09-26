From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: Fix potential memory leak
Date: Mon, 26 Sep 2011 08:09:13 +0200
Message-ID: <1317017353.2853.13.camel@edumazet-laptop>
References: <CA+v9cxYuFArVUh9gc-be-Lmy4TOTxp72VaCC4QeCEE3p1j2Ykg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49015 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab1IZGJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 02:09:19 -0400
Received: by wwf22 with SMTP id 22so6261622wwf.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 23:09:18 -0700 (PDT)
In-Reply-To: <CA+v9cxYuFArVUh9gc-be-Lmy4TOTxp72VaCC4QeCEE3p1j2Ykg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 24 septembre 2011 =C3=A0 23:57 +0800, Huajun Li a =C3=A9crit =
:
> While preparing flow caches, once fail may cause potential memory lea=
k , fix it.
>=20
> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
> ---
>  net/core/flow.c |   19 ++++++++++++++++++-
>  1 files changed, 18 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/flow.c b/net/core/flow.c
> index ba3e617..2dcaa03 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -420,7 +420,7 @@ static int __init flow_cache_init(struct flow_cac=
he *fc)
>=20
>  	for_each_online_cpu(i) {
>  		if (flow_cache_cpu_prepare(fc, i))
> -			return -ENOMEM;
> +			goto err;
>  	}
>  	fc->hotcpu_notifier =3D (struct notifier_block){
>  		.notifier_call =3D flow_cache_cpu,
> @@ -433,6 +433,23 @@ static int __init flow_cache_init(struct flow_ca=
che *fc)
>  	add_timer(&fc->rnd_timer);
>=20
>  	return 0;
> +err:
> +	if (fc->percpu) {
> +		free_percpu(fc->percpu);
> +		fc->percpu =3D NULL;
> +	}
> +
> +	/*
> +	 * Check each possible CPUs rather than online ones because they ma=
y be
> +	 * offline before the notifier is registered.
> +	 */

Please remove this comment.


> +	for_each_possible_cpu(i) {
> +		struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, i);
> +		kfree(fcp->hash_table);
> +		fcp->hash_table =3D NULL;
> +	}

You access fc->percpu after freeing it...

> +
> +	return -ENOMEM;
>  }
>=20
>  static int __init flow_cache_init_global(void)

Previous to 2.6.37 (commit 83b6b1f5d134), a memory allocation at this
stage was panicing the box, so no worry about mem leak :)

Now I wonder if a proper patch would not print a nice message in
flow_cache_init_global() if flow_cache_init() returns an error, instead
of silently panicing or something worse...

Before submitting a new patch, could you test this case (injecting a
memalloc error in flow_cache_cpu_prepare() for example.
