From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] netrom: fix info leak via getsockname()
Date: Mon, 15 Oct 2012 00:11:33 +0100
Message-ID: <1350256293.26833.28.camel@deadeye.wl.decadent.org.uk>
References: <CAKSJdACRs5r9bbr=VS25YoQGYyhZDCyejftC+tg6yeeaNMnErg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Cl=E9ment?= Lecigne <clemun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22978 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751409Ab2JNXLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 19:11:40 -0400
In-Reply-To: <CAKSJdACRs5r9bbr=VS25YoQGYyhZDCyejftC+tg6yeeaNMnErg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 20:23 +0200, Cl=C3=A9ment Lecigne wrote:
> The following patch fixes a 3 bytes info leak via getsockname() on
> AF_NETROM socket.
>=20
> Details:
>=20
> typedef struct {
> 	char		ax25_call[7];	/* 6 call + SSID (shifted ascii!) */
> } ax25_address;
>=20
> struct sockaddr_ax25 {
> 	__kernel_sa_family_t sax25_family;
> 	ax25_address	sax25_call;
> 	int		sax25_ndigis;
> 	/* Digipeater ax25_address sets follow */
> };
>=20
> After compilation, gcc will add 3 padding bytes after sax25_call to
> align sax25_ndigis and nr_getname does not clear these padding bytes
> before returning to userland, poc attached.
>=20
> Signed-off-by: Clement Lecigne <clemun@gmail.com>
>=20
> --- a/net/netrom/af_netrom.c
> +++ b/net/netrom/af_netrom.c
> @@ -838,6 +838,8 @@ static int nr_getname(struct socket *sock, struct
> sockaddr *uaddr,
>         struct sock *sk =3D sock->sk;
>         struct nr_sock *nr =3D nr_sk(sk);
>=20
> +    memset(sax, 0, sizeof(struct sockaddr_ax25));

This is not indented correctly.

>         lock_sock(sk);
>         if (peer !=3D 0) {
>                 if (sk->sk_state !=3D TCP_ESTABLISHED) {

On some architectures, structures have a minimum alignment of 4, so
there are 2 bytes of padding before sax25_call and 1 byte within it.
nr_getname() copies complete ax25_address structures, but nr_listen()
does not initialise the 1 byte of padding in user_addr:

		memset(&nr_sk(sk)->user_addr, 0, AX25_ADDR_LEN);

So I think you should address that too.  It appears that other
ax25_address structures are originally copied from userland and
therefore don't leak information, but I'm not sure.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
