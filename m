From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net/flow: Fix potential memory leak
Date: Tue, 27 Sep 2011 14:11:30 +0200
Message-ID: <1317125490.2541.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+v9cxZMwTPXw-_pWc-SRsTs5GqmqK2-46Mr06HxhVN4aH93Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56539 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab1I0MLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 08:11:18 -0400
Received: by gyg10 with SMTP id 10so5100580gyg.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 05:11:18 -0700 (PDT)
In-Reply-To: <CA+v9cxZMwTPXw-_pWc-SRsTs5GqmqK2-46Mr06HxhVN4aH93Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 18:34 +0800, Huajun Li a =C3=A9crit :
> While preparing net flow caches, once fail may cause potential memory
> leak , fix it.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


Hmm, please dont add "Acked-by" yourself, when submitting a new patch
version. Let us review the new version and ACK it eventually.

> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
> ---
>  net/core/flow.c |   16 +++++++++++++++-
>  1 files changed, 15 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 555a456..4e60fce 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -413,7 +413,7 @@ static int __init flow_cache_init(struct flow_cac=
he *fc)
>=20
>  	for_each_online_cpu(i) {
>  		if (flow_cache_cpu_prepare(fc, i))
> -			return -ENOMEM;
> +			goto err;
>  	}
>  	fc->hotcpu_notifier =3D (struct notifier_block){
>  		.notifier_call =3D flow_cache_cpu,
> @@ -426,6 +426,20 @@ static int __init flow_cache_init(struct flow_ca=
che *fc)
>  	add_timer(&fc->rnd_timer);
>=20
>  	return 0;
> +
> +err:
> +	for_each_possible_cpu(i) {
> +		struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, i);
> +		kfree(fcp->hash_table);
> +		fcp->hash_table =3D NULL;
> +	}
> +
> +	if (fc->percpu) {

test not needed here, fc->percpu is not NULL


> +		free_percpu(fc->percpu);
> +		fc->percpu =3D NULL;
> +	}
> +
> +	return -ENOMEM;
>  }
>=20
>  static int __init flow_cache_init_global(void)
