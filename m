From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: unix: Align send data_len up to PAGE_SIZE
Date: Thu, 15 May 2014 08:41:05 -0700
Message-ID: <1400168465.7973.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399906332.31472.1.camel@tkhai>
	 <20140514.151504.1740922429122469259.davem@davemloft.net>
	 <1400144080.3782.23.camel@tkhai>
	 <1400160440.7973.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1400164076.3782.32.camel@tkhai>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com
To: Kirill Tkhai <ktkhai@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:38482 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbaEOPlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 11:41:18 -0400
Received: by mail-pb0-f45.google.com with SMTP id um1so1257120pbc.18
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 08:41:17 -0700 (PDT)
In-Reply-To: <1400164076.3782.32.camel@tkhai>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 18:27 +0400, Kirill Tkhai wrote:
> =D0=92 =D0=A7=D1=82, 15/05/2014 =D0=B2 06:27 -0700, Eric Dumazet =D0=BF=
=D0=B8=D1=88=D0=B5=D1=82:
> > On Thu, 2014-05-15 at 12:54 +0400, Kirill Tkhai wrote:
> >=20
> > >=20
> > > And I assumed it's OK to allocate skbs with zero header size like=
 this:
> > >=20
> > > sock_alloc_send_pskb(sk, 0, data_len)
> > >=20
> > > Please say, if it's wrong.
> > >=20
> >=20
> > Its OK
> >=20
>=20
> Thanks for the reply. So, new version is below.
>=20
> [PATCH]net: unix: Align send data_len up to PAGE_SIZE
>    =20
> Using whole of allocated pages reduces requested skb->data size.
> This is just a little more thriftily allocation.
>    =20
> netperf does not show difference with the current performance.
>    =20
> Signed-off-by: Kirill Tkhai <ktkhai@parallels.com>
> ---
>  net/unix/af_unix.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 749f80c..65d67c2 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1492,10 +1492,12 @@ static int unix_dgram_sendmsg(struct kiocb *k=
iocb, struct socket *sock,
>  	if (len > sk->sk_sndbuf - 32)
>  		goto out;
> =20
> -	if (len > SKB_MAX_ALLOC)
> +	if (len > SKB_MAX_ALLOC) {
>  		data_len =3D min_t(size_t,
>  				 len - SKB_MAX_ALLOC,
>  				 MAX_SKB_FRAGS * PAGE_SIZE);
> +		data_len =3D PAGE_ALIGN(data_len);


I would add a BUILD_BUG_ON(SKB_MAX_ALLOC < PAGE_SIZE); just to make sur=
e
nobody ever tries to=20

#define SKB_MAX_ALLOC (SKB_MAX_ORDER(0, 0))

Also please send a fresh message, do not append a new patch like you
did : http://patchwork.ozlabs.org/patch/349243/

Title should be

[PATCH net-next v3] net: unix: ....
