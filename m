From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Wed, 09 Nov 2011 17:00:48 +0200
Message-ID: <6033284.KrP4yu8ukf@hector>
References: <1320837653-7471-1-git-send-email-hemant.ramdasi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
To: ext Hemant Vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:59822 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749Ab1KIPAq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 10:00:46 -0500
In-Reply-To: <1320837653-7471-1-git-send-email-hemant.ramdasi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline...

Le Mercredi 9 Novembre 2011 16:50:53 ext Hemant Vilas RAMDASI a =E9crit=
 :
> @@ -863,9 +902,27 @@ static int pep_sock_connect(struct sock *sk, str=
uct
> sockaddr *addr, int len) int err;
>  	u8 data[4] =3D { 0 /* sub-blocks */, PAD, PAD, PAD };
>=20
> -	pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
> +	if (pn->pipe_handle =3D=3D PN_PIPE_INVALID_HANDLE)
> +		pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
> +
>  	err =3D pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
> -					PN_PIPE_ENABLE, data, 4);
> +					pn->init_enable, data, 4);
> +
> +	if (err) {
> +		pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;

This undoes the setsockopt() silently. I'm not sure you intend this?

> +		return err;
> +	}
> +	sk->sk_state =3D TCP_SYN_SENT;
> +	return 0;
> +}
> +
> +static int pep_sock_enable(struct sock *sk, struct sockaddr *addr, i=
nt len)
> +{
> +	struct pep_sock *pn =3D pep_sk(sk);
> +	int err;
> +
> +	err =3D pipe_handler_request(sk, PNS_PEP_ENABLE_REQ, PAD,
> +				NULL, 0);
>  	if (err) {
>  		pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
>  		return err;
> @@ -959,6 +1016,24 @@ static int pep_setsockopt(struct sock *sk, int =
level,
> int optname, }
>  		goto out_norel;
>=20
> +	case PNPIPE_HANDLE:
> +		if (val)
> +			pn->pipe_handle =3D val;
> +		else
> +			err =3D -EINVAL;
> +		break;

Why is zero a special case? What about out-of-range values?

> +
> +	case PNPIPE_ENABLE:
> +		err =3D pep_sock_enable(sk, NULL, 0);
> +		break;

This is reintroducing the problems with the older code. As far as I kno=
w, =20
setsockopt() needs to be idempotent, which this does not seem to be?

> +
> +	case PNPIPE_INITSTATE:
> +		if ((val =3D=3D PN_PIPE_DISABLE) || (val =3D=3D PN_PIPE_ENABLE))
> +			pn->init_enable =3D val;
> +		else
> +			err =3D -EINVAL;
> +		break;

It looks like there is no use-case for init-enabled pipes then, right? =
How=20
about dropping this extra bit of code and assuming connect()ed pipes ar=
e=20
always init-disabled?

> +
>  	default:
>  		err =3D -ENOPROTOOPT;
>  	}
> @@ -994,6 +1069,13 @@ static int pep_getsockopt(struct sock *sk, int =
level,
> int optname, return -EINVAL;
>  		break;
>=20
> +	case PNPIPE_ENABLE:
> +		if (sk->sk_state !=3D TCP_ESTABLISHED)
> +			return -EINVAL;
> +		else
> +			val =3D 1;
> +		break;
> +
>  	default:
>  		return -ENOPROTOOPT;
>  	}
--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
