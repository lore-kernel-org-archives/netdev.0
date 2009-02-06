From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Fri, 6 Feb 2009 16:20:43 -0500
Message-ID: <20090206212043.GA1216@fieldses.org>
References: <Pine.LNX.4.64.0902062247500.31842@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0902062251501.31842@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34550 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbZBFVUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 16:20:41 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902062251501.31842@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 10:53:32PM +0200, Ilpo J=C3=A4rvinen wrote:
> Grr, forgot to cc sunrpc maintainer... Added. Just ask if somebody wa=
nts
> a complete resend.

You probably wanted Trond, actually.  (And did this patch have a
changelog?)

--b.

>=20
> On Fri, 6 Feb 2009, Ilpo J=C3=A4rvinen wrote:
>=20
> >
> > $ diff-funcs xs_udp_write_space net/sunrpc/xprtsock.c
> > net/sunrpc/xprtsock.c xs_tcp_write_space
> >  --- net/sunrpc/xprtsock.c:xs_udp_write_space()
> >  +++ net/sunrpc/xprtsock.c:xs_tcp_write_space()
> > @@ -1,4 +1,4 @@
> > - * xs_udp_write_space - callback invoked when socket buffer space
> > + * xs_tcp_write_space - callback invoked when socket buffer space
> >   *                             becomes available
> >   * @sk: socket whose state has changed
> >   *
> > @@ -7,12 +7,12 @@
> >   * progress, otherwise we'll waste resources thrashing kernel_send=
msg
> >   * with a bunch of small requests.
> >   */
> > -static void xs_udp_write_space(struct sock *sk)
> > +static void xs_tcp_write_space(struct sock *sk)
> >  {
> >  	read_lock(&sk->sk_callback_lock);
> >
> > -	/* from net/core/sock.c:sock_def_write_space */
> > -	if (sock_writeable(sk)) {
> > +	/* from net/core/stream.c:sk_stream_write_space */
> > +	if (sk_stream_wspace(sk) >=3D sk_stream_min_wspace(sk)) {
> >  		struct socket *sock;
> >  		struct rpc_xprt *xprt;
> >
> >
> > $ codiff net/sunrpc/xprtsock.o net/sunrpc/xprtsock.o.new
> > net/sunrpc/xprtsock.c:
> >   xs_tcp_write_space | -163
> >   xs_udp_write_space | -163
> >  2 functions changed, 326 bytes removed
> >
> > net/sunrpc/xprtsock.c:
> >   xs_write_space | +179
> >  1 function changed, 179 bytes added
> >
> > net/sunrpc/xprtsock.o.new:
> >  3 functions changed, 179 bytes added, 326 bytes removed, diff: -14=
7
> >
> > Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> > ---
> >  net/sunrpc/xprtsock.c |   53 +++++++++++++++++++------------------=
-----------
> >  1 files changed, 21 insertions(+), 32 deletions(-)
> >
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 5cbb404..b49e434 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1215,6 +1215,23 @@ out:
> >  	read_unlock(&sk->sk_callback_lock);
> >  }
> >
> > +static void xs_write_space(struct sock *sk)
> > +{
> > +	struct socket *sock;
> > +	struct rpc_xprt *xprt;
> > +
> > +	if (unlikely(!(sock =3D sk->sk_socket)))
> > +		return;
> > +	clear_bit(SOCK_NOSPACE, &sock->flags);
> > +
> > +	if (unlikely(!(xprt =3D xprt_from_sock(sk))))
> > +		return;
> > +	if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) =3D=3D 0=
)
> > +		return;
> > +
> > +	xprt_write_space(xprt);
> > +}
> > +
> >  /**
> >   * xs_udp_write_space - callback invoked when socket buffer space
> >   *                             becomes available
> > @@ -1230,23 +1247,9 @@ static void xs_udp_write_space(struct sock *=
sk)
> >  	read_lock(&sk->sk_callback_lock);
> >
> >  	/* from net/core/sock.c:sock_def_write_space */
> > -	if (sock_writeable(sk)) {
> > -		struct socket *sock;
> > -		struct rpc_xprt *xprt;
> > -
> > -		if (unlikely(!(sock =3D sk->sk_socket)))
> > -			goto out;
> > -		clear_bit(SOCK_NOSPACE, &sock->flags);
> > -
> > -		if (unlikely(!(xprt =3D xprt_from_sock(sk))))
> > -			goto out;
> > -		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) =3D=3D =
0)
> > -			goto out;
> > -
> > -		xprt_write_space(xprt);
> > -	}
> > +	if (sock_writeable(sk))
> > +		xs_write_space(sk);
> >
> > - out:
> >  	read_unlock(&sk->sk_callback_lock);
> >  }
> >
> > @@ -1265,23 +1268,9 @@ static void xs_tcp_write_space(struct sock *=
sk)
> >  	read_lock(&sk->sk_callback_lock);
> >
> >  	/* from net/core/stream.c:sk_stream_write_space */
> > -	if (sk_stream_wspace(sk) >=3D sk_stream_min_wspace(sk)) {
> > -		struct socket *sock;
> > -		struct rpc_xprt *xprt;
> > -
> > -		if (unlikely(!(sock =3D sk->sk_socket)))
> > -			goto out;
> > -		clear_bit(SOCK_NOSPACE, &sock->flags);
> > +	if (sk_stream_wspace(sk) >=3D sk_stream_min_wspace(sk))
> > +		xs_write_space(sk);
> >
> > -		if (unlikely(!(xprt =3D xprt_from_sock(sk))))
> > -			goto out;
> > -		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) =3D=3D =
0)
> > -			goto out;
> > -
> > -		xprt_write_space(xprt);
> > -	}
> > -
> > - out:
> >  	read_unlock(&sk->sk_callback_lock);
> >  }
> >
> >=20
