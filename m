From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: ipv4: fix potential memory leak by
 assigning uhash_entries
Date: Wed, 22 Jun 2011 07:04:46 +0200
Message-ID: <1308719087.2713.4.camel@edumazet-laptop>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
	 <1308689020-1873-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Mark Asselstine <mark.asselstine@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63470 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1FVFEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 01:04:51 -0400
Received: by wyb38 with SMTP id 38so291979wyb.19
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2011 22:04:49 -0700 (PDT)
In-Reply-To: <1308689020-1873-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 juin 2011 =C3=A0 16:43 -0400, Paul Gortmaker a =C3=A9crit :
> From: Mark Asselstine <mark.asselstine@windriver.com>
>=20
> Commit f86dcc5a [udp: dynamically size hash tables at boot time]
> introduced the uhash_entries boot option and made sure to keep
> it set within acceptable limits -- if used.  It did not assign a
> default value, however, so it defaults to zero.  This results in
> alloc_large_system_hash() being relied upon to specify an acceptable
> number of hash entries, something it can't be relied on to always do
> correctly. For example, when it fails to set an acceptable minimum
> (UDP_HTABLE_SIZE_MIN) we get a second allocation and a memory leak.
> So we need to set a default value for uhash_entries to ensure we get
> the required minimum and prevent a second allocation.
>=20
> This was found by using DEBUG_KMEMLEAK, producing the following log:
>=20
> unreferenced object 0xc1b0d000 (size 4096):
>   comm "swapper", pid 1, jiffies 4294667562 (age 136.225s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<c10e9027>] create_object+0xd7/0x210
>     [<c15d73d7>] kmemleak_alloc+0x27/0x50
>     [<c1877032>] alloc_large_system_hash+0x16d/0x1f7
>     [<c189121d>] udp_table_init+0x43/0xf8
>     [<c18912e4>] udp_init+0x12/0x74
>     [<c1891637>] inet_init+0x179/0x250
>     [<c10011f0>] do_one_initcall+0x30/0x160
>     [<c18607c9>] kernel_init+0xb9/0x14e
>     [<c15fcff6>] kernel_thread_helper+0x6/0xd
>     [<ffffffff>] 0xffffffff
>=20
> This is fairly easy to reproduce using ARCH=3Dx86 defconfig (i386_def=
config)
> enabling DEBUG_KMEMLEAK and running on a system with 32MB of memory
> (qemu -m 32). With systems with larger amounts of memory we may not
> see this leak since the logic in alloc_large_system_hash() will resul=
t
> in a large enough (>UDP_HTABLE_SIZE_MIN) number of entries being set.
>=20
> Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/ipv4/udp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index abca870..6f53a5a 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2155,7 +2155,7 @@ void udp4_proc_exit(void)
>  }
>  #endif /* CONFIG_PROC_FS */
> =20
> -static __initdata unsigned long uhash_entries;
> +static __initdata unsigned long uhash_entries =3D UDP_HTABLE_SIZE_MI=
N;
>  static int __init set_uhash_entries(char *str)
>  {
>  	if (!str)

Arg no, I really wanted to get more hash slots in my 32bit machines,
with 4Gbytes of memory.

Here is what I currently have (without your patch)

[    1.903086] UDP hash table entries: 512 (order: 2, 16384 bytes)


I mean, this kmemleak was already reported.

32MB machines are things of the past.

If you really care, please add a change to alloc_large_system_hash() ?



