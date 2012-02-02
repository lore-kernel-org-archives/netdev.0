From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V4 01/13] netback: page pool version 1
Date: Thu, 02 Feb 2012 18:26:05 +0100
Message-ID: <1328203565.13262.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34258 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab2BBR0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 12:26:08 -0500
Received: by werb13 with SMTP id b13so2027816wer.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 09:26:07 -0800 (PST)
In-Reply-To: <1328201363-13915-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 16:49 +0000, Wei Liu a =C3=A9crit =
:
> A global page pool. Since we are moving to 1:1 model netback, it is
> better to limit total RAM consumed by all the vifs.
>=20
> With this patch, each vif gets page from the pool and puts the page
> back when it is finished with the page.
>=20
> This pool is only meant to access via exported interfaces. Internals
> are subject to change when we discover new requirements for the pool.
>=20
> Current exported interfaces include:
>=20
> page_pool_init: pool init
> page_pool_destroy: pool destruction
> page_pool_get: get a page from pool
> page_pool_put: put page back to pool
> is_in_pool: tell whether a page belongs to the pool
>=20
> Current implementation has following defects:
>  - Global locking
>  - No starve prevention mechanism / reservation logic
>=20
> Global locking tends to cause contention on the pool. No reservation
> logic may cause vif to starve. A possible solution to these two
> problems will be each vif maintains its local cache and claims a
> portion of the pool. However the implementation will be tricky when
> coming to pool management, so let's worry about that later.
>=20
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---

Hmm, this kind of stuff should be discussed on lkml.

I doubt we want yet another memory allocator, with a global lock
(contended), and no NUMA properties.


> +int page_pool_init()
> +{
> +	int cpus =3D 0;
> +	int i;
> +
> +	cpus =3D num_online_cpus();
> +	pool_size =3D cpus * ENTRIES_PER_CPU;
> +
> +	pool =3D vzalloc(sizeof(struct page_pool_entry) * pool_size);
> +
> +	if (!pool)
> +		return -ENOMEM;
> +
> +	for (i =3D 0; i < pool_size - 1; i++)
> +		pool[i].u.fl =3D i+1;
> +	pool[pool_size-1].u.fl =3D INVALID_ENTRY;
> +	free_count =3D pool_size;
> +	free_head =3D 0;
> +
> +	return 0;
> +}
> +

num_online_cpus() disease once again.

code depending on num_online_cpus() is always suspicious.
