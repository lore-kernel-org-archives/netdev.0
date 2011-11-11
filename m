From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH v3] Phonet: set the pipe handle using setsockopt
Date: Fri, 11 Nov 2011 12:47:23 +0200
Message-ID: <2861462.RoD2sRHrFH@hector>
References: <1321007302-7269-1-git-send-email-hemant.ramdasi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:41787 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085Ab1KKKrO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 05:47:14 -0500
Received: from hector.localnet (esdhcp034217.research.nokia.com [172.21.34.217])
	by mgw-sa01.nokia.com (Switch-3.4.4/Switch-3.4.4) with ESMTP id pABAlBms014057
	for <netdev@vger.kernel.org>; Fri, 11 Nov 2011 12:47:11 +0200
In-Reply-To: <1321007302-7269-1-git-send-email-hemant.ramdasi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Vendredi 11 Novembre 2011 15:58:22 ext Hemant Vilas RAMDASI a =E9cri=
t :
> From: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
>=20
> This provides flexibility to set the pipe handle
> using setsockopt and enable the same.
>=20
> Signed-off-by: Hemant Ramdasi <hemant.ramdasi@stericsson.com>
> Signed-off-by: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
> ---
>  include/linux/phonet.h |    2 +
>  net/phonet/pep.c       |  111
> +++++++++++++++++++++++++++++++++++++++++++---- 2 files changed, 103
> insertions(+), 10 deletions(-)
>=20
> diff --git a/include/linux/phonet.h b/include/linux/phonet.h
> index 6fb1384..491caec 100644
> --- a/include/linux/phonet.h
> +++ b/include/linux/phonet.h
> @@ -37,6 +37,8 @@
>  #define PNPIPE_ENCAP		1
>  #define PNPIPE_IFINDEX		2
>  #define PNPIPE_HANDLE		3
> +#define PNPIPE_ENABLE		4
> +#define PNPIPE_INITSTATE	5
>=20
>  #define PNADDR_ANY		0
>  #define PNADDR_BROADCAST	0xFC
> diff --git a/net/phonet/pep.c b/net/phonet/pep.c
> index f17fd84..33230c5 100644
> --- a/net/phonet/pep.c
> +++ b/net/phonet/pep.c
> @@ -167,6 +167,12 @@ static int pipe_handler_send_created_ind(struct =
sock
> *sk) data, 4, GFP_ATOMIC);
>  }
>=20
> +static int pipe_handler_send_enabled_ind(struct sock *sk)
> +{
> +	return pep_indicate(sk, PNS_PIPE_ENABLED_IND, 0 /* sub-blocks */,
> +				NULL, 0, GFP_ATOMIC);
> +}

This really could be inlined.

> +
>  static int pep_accept_conn(struct sock *sk, struct sk_buff *skb)
>  {
>  	static const u8 data[20] =3D {
> @@ -533,6 +539,27 @@ static int pep_connresp_rcv(struct sock *sk, str=
uct
> sk_buff *skb) return pipe_handler_send_created_ind(sk);
>  }
>=20
> +static int pep_enableresp_rcv(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct pnpipehdr *hdr =3D pnp_hdr(skb);
> +
> +	if (hdr->error_code !=3D PN_PIPE_NO_ERROR)
> +		return -ECONNREFUSED;
> +
> +	return pipe_handler_send_enabled_ind(sk);
> +}
> +
> +static void pipe_start_flow_control(struct sock *sk)
> +{
> +	struct pep_sock *pn =3D pep_sk(sk);
> +
> +	if (!pn_flow_safe(pn->tx_fc)) {
> +		atomic_set(&pn->tx_credits, 1);
> +		sk->sk_write_space(sk);
> +	}
> +	pipe_grant_credits(sk, GFP_ATOMIC);
> +}
> +
>  /* Queue an skb to an actively connected sock.
>   * Socket lock must be held. */
>  static int pipe_handler_do_rcv(struct sock *sk, struct sk_buff *skb)
> @@ -578,13 +605,25 @@ static int pipe_handler_do_rcv(struct sock *sk,=
 struct
> sk_buff *skb) sk->sk_state =3D TCP_CLOSE_WAIT;
>  			break;
>  		}
> +		if (pn->init_enable =3D=3D PN_PIPE_DISABLE)
> +			sk->sk_state =3D TCP_SYN_RECV;
> +		else {
> +			sk->sk_state =3D TCP_ESTABLISHED;
> +			pipe_start_flow_control(sk);
> +		}
> +		break;
>=20
> -		sk->sk_state =3D TCP_ESTABLISHED;
> -		if (!pn_flow_safe(pn->tx_fc)) {
> -			atomic_set(&pn->tx_credits, 1);
> -			sk->sk_write_space(sk);
> +	case PNS_PEP_ENABLE_RESP:
> +		if (sk->sk_state !=3D TCP_SYN_SENT)
> +			break;
> +
> +		if (pep_enableresp_rcv(sk, skb)) {
> +			sk->sk_state =3D TCP_CLOSE_WAIT;
> +			break;
>  		}
> -		pipe_grant_credits(sk, GFP_ATOMIC);
> +
> +		sk->sk_state =3D TCP_ESTABLISHED;
> +		pipe_start_flow_control(sk);
>  		break;
>=20
>  	case PNS_PEP_DISCONNECT_RESP:
> @@ -863,14 +902,31 @@ static int pep_sock_connect(struct sock *sk, st=
ruct
> sockaddr *addr, int len) int err;
>  	u8 data[4] =3D { 0 /* sub-blocks */, PAD, PAD, PAD };
>=20
> -	pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
> +	if (pn->pipe_handle =3D=3D PN_PIPE_INVALID_HANDLE)
> +		pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
> +
>  	err =3D pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
> -					PN_PIPE_ENABLE, data, 4);
> -	if (err) {
> -		pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
> +				pn->init_enable, data, 4);
> +	if (err)
>  		return err;
> -	}
> +
>  	sk->sk_state =3D TCP_SYN_SENT;
> +
> +	return 0;
> +}
> +
> +static int pep_sock_enable(struct sock *sk, struct sockaddr *addr, i=
nt len)
> +{
> +	int err;
> +
> +	err =3D pipe_handler_request(sk, PNS_PEP_ENABLE_REQ, PAD,
> +				NULL, 0);
> +
> +	if (err)
> +		return err;
> +
> +	sk->sk_state =3D TCP_SYN_SENT;
> +
>  	return 0;
>  }
>=20
> @@ -959,6 +1015,30 @@ static int pep_setsockopt(struct sock *sk, int =
level,
> int optname, }
>  		goto out_norel;
>=20
> +	case PNPIPE_HANDLE:
> +		if ((sk->sk_state =3D=3D TCP_CLOSE) &&
> +			(val >=3D 0) && (val < PN_PIPE_INVALID_HANDLE))
> +			pn->pipe_handle =3D val;
> +		else
> +			err =3D -EINVAL;
> +		break;
> +
> +	case PNPIPE_ENABLE:
> +		if (sk->sk_state =3D=3D TCP_SYN_SENT)
> +			err =3D -EBUSY;
> +		else if (sk->sk_state =3D=3D TCP_ESTABLISHED)
> +			err =3D -EISCONN;
> +		else
> +			err =3D pep_sock_enable(sk, NULL, 0);
> +		break;

=46or the umpteenth time, this does not obey set/get conventions.

> +
> +	case PNPIPE_INITSTATE:
> +		if ((val =3D=3D 0) || (val =3D=3D 1))
> +			pn->init_enable =3D val;
> +		else
> +			err =3D -EINVAL;

I think kernel style is more akin to:

pn->init_enable =3D !!val;
