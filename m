From: Marcus Meissner <meissner@suse.de>
Subject: Re: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 5 Jul 2004 14:45:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705124511.GA17193@suse.de>
References: <E1BhRda-0001Rs-00@gondolin.me.apana.org.au> <20040705113555.GA28665@suse.de> <20040705120610.GA5728@gondor.apana.org.au> <20040705.212522.126409437.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040705.212522.126409437.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2004 at 09:25:22PM +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=
=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20040705120610.GA5728@gondor.apana.org.au> (at Mon, 5 Jul 2=
004 22:06:10 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
>=20
> > On Mon, Jul 05, 2004 at 01:35:55PM +0200, Marcus Meissner wrote:
> > >=20
> > > Oh, and NETLINK+TCP_DIAG seems to have the same readlock contention=
 problem,
> > > see tcpdiag_dump().
> >=20
> > Then you wouldn't mind adding this optimisation for tcp_diag as well,
> > right? :)
>=20
> here it is. :-)
>=20
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>=20
> =3D=3D=3D=3D=3D net/ipv4/tcp_diag.c 1.15 vs edited =3D=3D=3D=3D=3D
> --- 1.15/net/ipv4/tcp_diag.c	2004-06-08 07:27:58 +09:00
> +++ edited/net/ipv4/tcp_diag.c	2004-07-05 21:18:17 +09:00
> @@ -522,9 +522,13 @@
>  		if (i > s_i)
>  			s_num =3D 0;
> =20
> -		read_lock_bh(&head->lock);
> -
>  		num =3D 0;
> +
> +		if (hlist_empty(&head->chain) &&
> +		    (!(r->tcpdiag_states&TCPF_TIME_WAIT) || hlist_empty(&head->chain=
)))
> +			continue;

The second hlist_empty is bad, you should be checking &tcp_ehash[i +
tcp_ehash_size].chain ((head+tcp_ehash_size) I think).


Ciao, Marcus
