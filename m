From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: af_unix should disable preempt around	sock_prot_inuse_add()
Date: Mon, 24 Nov 2008 14:06:42 +0100
Message-ID: <492AA6E2.7020405@cosmosbay.com>
References: <20081124125457.GA6255@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55459 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbYKXNGs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:06:48 -0500
In-Reply-To: <20081124125457.GA6255@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Beregalov a =E9crit :
>=20
> BUG: using smp_processor_id() in preemptible [00000000] code: ini
>=20
> caller is sock_prot_inuse_add+0x24/0x42
> Pid: 738, comm: init-early.sh Tainted: G        W  2.6.28-rc6-nex
>=20
> Call Trace:
>  [<ffffffff8037fb72>] debug_smp_processor_id+0xca/0xe0
>  [<ffffffff8046afc9>] sock_prot_inuse_add+0x24/0x42
>  [<ffffffff804baf2c>] unix_create1+0x161/0x176
>  [<ffffffff804bb03d>] unix_stream_connect+0x94/0x3b0
>  [<ffffffff80468a84>] sys_connect+0x68/0x8e
>  [<ffffffff8020b75b>] system_call_fastpath+0x16/0x1b
>=20
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>=20
>  net/unix/af_unix.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index a9b3c90..f7a1d46 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -361,7 +361,9 @@ static void unix_sock_destructor(struct sock *sk)
>  		unix_release_addr(u->addr);
> =20
>  	atomic_dec(&unix_nr_socks);
> +	preempt_disable();
>  	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> +	preempt_enable();
>  #ifdef UNIX_REFCNT_DEBUG
>  	printk(KERN_DEBUG "UNIX %p is destroyed, %d are still alive.\n", sk=
,
>  		atomic_read(&unix_nr_socks));
> @@ -612,9 +614,11 @@ static struct sock *unix_create1(struct net *net=
, struct socket *sock)
>  out:
>  	if (sk =3D=3D NULL)
>  		atomic_dec(&unix_nr_socks);
> -	else
> +	else {
> +		preempt_disable();
>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
> -
> +		preempt_enable();
> +	}
>  	return sk;
>  }
> =20
>=20
>=20

Thanks Alexander, but this problem (and others) was fixed few
hours ago by two commits on net-next-2.6

commit 6f756a8c36bf54d0afb1d457082b3e3033d951a7

net: Make sure BHs are disabled in sock_prot_inuse_add()

The rule of calling sock_prot_inuse_add() is that BHs must
be disabled.  Some new calls were added where this was not
true and this tiggers warnings as reported by Ilpo.

=46ix this by adding explicit BH disabling around those call sites.

Signed-off-by: David S. Miller <davem@davemloft.net>

commit 920de804bca61f88643bc9171bcd06f1a56c6258

net: Make sure BHs are disabled in sock_prot_inuse_add()

The rule of calling sock_prot_inuse_add() is that BHs must
be disabled.  Some new calls were added where this was not
true and this tiggers warnings as reported by Ilpo.

=46ix this by adding explicit BH disabling around those call sites,
or moving sock_prot_inuse_add() call inside an existing BH disabled
section.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

