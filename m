From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: RE: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Mon, 14 Nov 2011 11:36:12 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB090B0B8@EXDCVYMBSTM005.EQ1STM.local>
References: <1321257210-17200-1-git-send-email-hemant.ramdasi@stericsson.com>
 <2168215.tYVKKNoJjY@hector>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?iso-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:57557 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752803Ab1KNKgY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 05:36:24 -0500
In-Reply-To: <2168215.tYVKKNoJjY@hector>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remi,

> -----Original Message-----
> From: R=E9mi Denis-Courmont [mailto:remi.denis-courmont@nokia.com]
> Sent: Monday, November 14, 2011 3:00 PM
> To: Hemant-vilas RAMDASI; netdev@vger.kernel.org
> Subject: Re: [PATCH] Phonet: set the pipe handle using setsockopt
> > @@ -180,6 +182,7 @@ static inline __u8 pn_sockaddr_get_resource(con=
st
> struct
> > sockaddr_pn *spn) /* Phonet device ioctl requests */
> >  #ifdef __KERNEL__
> >  #define SIOCPNGAUTOCONF		(SIOCDEVPRIVATE + 0)
> > +#define SIOPNPIPE_ENABLE	_IO(SIOCPNGAUTOCONF,   1)
>=20
> Does this even work? I am not an expert on this, but I would think th=
at
> device-private controls are routed to the network device, not the
> socket. In
> any case, it does not seem right.
>=20
Yes, it works. The ioctl is routed to per-socket functions.

> > @@ -863,14 +898,31 @@ static int pep_sock_connect(struct sock *sk,
> struct
> > sockaddr *addr, int len) int err;
> >  	u8 data[4] =3D { 0 /* sub-blocks */, PAD, PAD, PAD };
> >
> > -	pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
> > +	if (pn->pipe_handle =3D=3D PN_PIPE_INVALID_HANDLE)
> > +		pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
> > +
> >  	err =3D pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
> > -					PN_PIPE_ENABLE, data, 4);
> > -	if (err) {
> > -		pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
>=20
> The current backlog functions assume that pipe_handle =3D
> PN_PIPE_INVALID_HANDLE
> if the socket is not yet connected. That's why the old code would cle=
ar
> the
> pipe_handle always on error.
Ok..I think clearing pipe-handle on connect error should take care of t=
his.
User-space need to set the handle again.
>=20
> So it is not that simple.
>=20
> > @@ -894,6 +946,16 @@ static int pep_ioctl(struct sock *sk, int cmd,
> unsigned
> > +	case SIOPNPIPE_ENABLE:
> > +		if (sk->sk_state =3D=3D TCP_SYN_SENT)
> > +			return -EBUSY;
> > +		else if (sk->sk_state =3D=3D TCP_ESTABLISHED)
> > +			return -EISCONN;
> > +		else
> > +			return pep_sock_enable(sk, NULL, 0);
> > +		break;
> >  	}
>=20
> I strongly suspect insufficient locking here.
Ok..
>=20
> >
> >  	return -ENOIOCTLCMD;
> > @@ -959,6 +1021,18 @@ static int pep_setsockopt(struct sock *sk, in=
t
> level,
> > int optname, }
> >  		goto out_norel;
> >
> > +	case PNPIPE_HANDLE:
> > +		if ((sk->sk_state =3D=3D TCP_CLOSE) &&
> > +			(val >=3D 0) && (val < PN_PIPE_INVALID_HANDLE))
> > +			pn->pipe_handle =3D val;
> > +		else
> > +			err =3D -EINVAL;
> > +		break;
>=20
> Same problem regarding pipe_handle as above.
I think locking already exists..

> > @@ -994,6 +1068,17 @@ static int pep_getsockopt(struct sock *sk, in=
t
> level,
> > int optname, return -EINVAL;
> >  		break;
> >
> > +	case PNPIPE_ENABLE:
> > +		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
> > +			val =3D 1;
> > +		else
> > +			val =3D 0;
> > +		break;
>=20
> Do you still need this read-only option?
Yes.
