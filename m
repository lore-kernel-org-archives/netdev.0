From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Fix sock freeing before sock_init_data() with
	__sk_free()
Date: Mon, 31 Aug 2009 07:07:33 +0000
Message-ID: <20090831070733.GC5005@ff.dom.local>
References: <20090830222340.GA17454@ami.dom.local> <4A9B6D23.9090505@gmail.com> <20090831063648.GB5005@ff.dom.local> <4A9B72B1.2040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:54711 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbZHaHHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 03:07:36 -0400
Received: by fxm17 with SMTP id 17so2583534fxm.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 00:07:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A9B72B1.2040908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 08:50:25AM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Mon, Aug 31, 2009 at 08:26:43AM +0200, Eric Dumazet wrote:
> >> Jarek Poplawski a =E9crit :
> >>> After recent changes sk_free() frees socks conditionally and depe=
nds
> >>> on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
> >>> cases sk_free() is called earlier, usually after other alloc erro=
rs.
> >>> This patch fixes it by exporting and using __sk_free() directly.
> > ...
> >> Very nice catch Jarek, but dont you think it would be cleaner to m=
ake sure
> >> we can call sk_free() right after sk_alloc() instead, and not expo=
rting
> >> __sk_free() ?
> >>
> >> ie initialize wmem_alloc in sk_alloc() instead of initializing it =
in=20
> >> sock_init_data() ?
> >>
> >=20
> > Most probably it should be better. But I meant this fix for -net an=
d
> > didn't wan't to break too much... So, if you're sure it's OK feel f=
ree
> > to send your version. (Or it could be changed like this in the -nex=
t.)
>=20
> Well, patch is yours, not mine, and I am confident it is OK.

Well, it's from you, and I guess you'll sign off too, but if you
think so...
=20
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Thanks,
Jarek P.

>=20
> We should check that no sk_alloc() user did a blind memset() or somet=
hing
> strange like that, before calling sock_init_data() or sk_free()
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index bbb25be..7633422 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1025,6 +1025,7 @@ struct sock *sk_alloc(struct net *net, int fami=
ly, gfp_t priority,
>  		sk->sk_prot =3D sk->sk_prot_creator =3D prot;
>  		sock_lock_init(sk);
>  		sock_net_set(sk, get_net(net));
> +		atomic_set(&sk->sk_wmem_alloc, 1);
>  	}
> =20
>  	return sk;
> @@ -1872,7 +1873,6 @@ void sock_init_data(struct socket *sock, struct=
 sock *sk)
>  	 */
>  	smp_wmb();
>  	atomic_set(&sk->sk_refcnt, 1);
> -	atomic_set(&sk->sk_wmem_alloc, 1);
>  	atomic_set(&sk->sk_drops, 0);
>  }
>  EXPORT_SYMBOL(sock_init_data);
>=20
