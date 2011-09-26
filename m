From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Disable false positive memory leak report
Date: Mon, 26 Sep 2011 07:29:18 +0200
Message-ID: <1317014958.2853.0.camel@edumazet-laptop>
References: <CA+v9cxao_66a1Jb2L4M3fmUvNv8+QzWTFMqu7Dxnh7a5Zyqt0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42163 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab1IZF3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 01:29:22 -0400
Received: by wwf22 with SMTP id 22so6227369wwf.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 22:29:21 -0700 (PDT)
In-Reply-To: <CA+v9cxao_66a1Jb2L4M3fmUvNv8+QzWTFMqu7Dxnh7a5Zyqt0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 24 septembre 2011 =C3=A0 23:57 +0800, Huajun Li a =C3=A9crit =
:
> Memory leak detector reports following false positive memory leak, th=
e
> patch disables it.
>=20
> unreferenced object 0xffff880073a70000 (size 8192):
>   comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff8124db64>] create_object+0x144/0x360
>     [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
>     [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
>     [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
>     [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
>     [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
>     [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
>     [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
>     [<ffffffffffffffff>] 0xffffffffffffffff
> unreferenced object 0xffff880073a74290 (size 8192):
>   comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff8124db64>] create_object+0x144/0x360
>     [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
>     [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
>     [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
>     [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
>     [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
>     [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
>     [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
>     [<ffffffffffffffff>] 0xffffffffffffffff
>=20
>=20
> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
> ---
>  net/core/flow.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 555a456..ba3e617 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -365,6 +365,13 @@ static int __cpuinit
> flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
>=20
>  	if (!fcp->hash_table) {
>  		fcp->hash_table =3D kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu))=
;
> +		/*
> +		 * Avoid a kmemleak false positive. The pointer to this block
> +		 * is refferenced by per-CPU varaible, here just mark it as not
> +		 * being a leak.
> +		 */
> +		kmemleak_not_leak(fcp->hash_table);
> +
>  		if (!fcp->hash_table) {
>  			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
>  			return -ENOMEM;

This makes no sense to me.

per-cpu variables are taken into account by kmemleak.

If not, you should report this problem to kmemleak maintainer.
