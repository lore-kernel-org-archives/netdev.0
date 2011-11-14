From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Mon, 14 Nov 2011 11:29:58 +0200
Message-ID: <2168215.tYVKKNoJjY@hector>
References: <1321257210-17200-1-git-send-email-hemant.ramdasi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: ext Hemant Vilas RAMDASI <hemant.ramdasi@stericsson.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:64994 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922Ab1KNJ3y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 04:29:54 -0500
In-Reply-To: <1321257210-17200-1-git-send-email-hemant.ramdasi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Lundi 14 Novembre 2011 13:23:30 ext Hemant Vilas RAMDASI a =E9crit :
> From: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
>=20
> This provides flexibility to set the pipe handle
> using setsockopt. The pipe can be enabled (if disabled) later
> using ioctl.
>=20
> Signed-off-by: Hemant Ramdasi <hemant.ramdasi@stericsson.com>
> Signed-off-by: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
> ---
>  include/linux/phonet.h |    3 +
>  net/phonet/pep.c       |  105
> +++++++++++++++++++++++++++++++++++++++++++----- 2 files changed, 98
> insertions(+), 10 deletions(-)
>=20
> diff --git a/include/linux/phonet.h b/include/linux/phonet.h
> index 6fb1384..4c00551 100644
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
> @@ -180,6 +182,7 @@ static inline __u8 pn_sockaddr_get_resource(const=
 struct
> sockaddr_pn *spn) /* Phonet device ioctl requests */
>  #ifdef __KERNEL__
>  #define SIOCPNGAUTOCONF		(SIOCDEVPRIVATE + 0)
> +#define SIOPNPIPE_ENABLE	_IO(SIOCPNGAUTOCONF,   1)

Does this even work? I am not an expert on this, but I would think that=
=20
device-private controls are routed to the network device, not the socke=
t. In=20
any case, it does not seem right.

>=20
>  struct if_phonet_autoconf {
>  	uint8_t device;
> diff --git a/net/phonet/pep.c b/net/phonet/pep.c
> index f17fd84..48339b9 100644
> --- a/net/phonet/pep.c
> +++ b/net/phonet/pep.c
> @@ -533,6 +533,29 @@ static int pep_connresp_rcv(struct sock *sk, str=
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
> +	return pep_indicate(sk, PNS_PIPE_ENABLED_IND, 0 /* sub-blocks */,
> +		NULL, 0, GFP_ATOMIC);
> +
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
> @@ -578,13 +601,25 @@ static int pipe_handler_do_rcv(struct sock *sk,=
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
> @@ -863,14 +898,31 @@ static int pep_sock_connect(struct sock *sk, st=
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

The current backlog functions assume that pipe_handle =3D PN_PIPE_INVAL=
ID_HANDLE=20
if the socket is not yet connected. That's why the old code would clear=
 the=20
pipe_handle always on error.

So it is not that simple.

> +				pn->init_enable, data, 4);
> +	if (err)
>  		return err;
> -	}
> +
> +	sk->sk_state =3D TCP_SYN_SENT;
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
>  	sk->sk_state =3D TCP_SYN_SENT;
> +
>  	return 0;
>  }
>=20
> @@ -894,6 +946,16 @@ static int pep_ioctl(struct sock *sk, int cmd, u=
nsigned
> long arg) answ =3D 0;
>  		release_sock(sk);
>  		return put_user(answ, (int __user *)arg);
> +		break;
> +
> +	case SIOPNPIPE_ENABLE:
> +		if (sk->sk_state =3D=3D TCP_SYN_SENT)
> +			return -EBUSY;
> +		else if (sk->sk_state =3D=3D TCP_ESTABLISHED)
> +			return -EISCONN;
> +		else
> +			return pep_sock_enable(sk, NULL, 0);
> +		break;
>  	}

I strongly suspect insufficient locking here.

>=20
>  	return -ENOIOCTLCMD;
> @@ -959,6 +1021,18 @@ static int pep_setsockopt(struct sock *sk, int =
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

Same problem regarding pipe_handle as above.

> +
> +	case PNPIPE_INITSTATE:
> +		pn->init_enable =3D !!val;
> +		break;
> +
>  	default:
>  		err =3D -ENOPROTOOPT;
>  	}
> @@ -994,6 +1068,17 @@ static int pep_getsockopt(struct sock *sk, int =
level,
> int optname, return -EINVAL;
>  		break;
>=20
> +	case PNPIPE_ENABLE:
> +		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
> +			val =3D 1;
> +		else
> +			val =3D 0;
> +		break;

Do you still need this read-only option?

> +
> +	case PNPIPE_INITSTATE:
> +		val =3D pn->init_enable;
> +		break;
> +
>  	default:
>  		return -ENOPROTOOPT;
>  	}
--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
