From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH v2] Phonet: set the pipe handle using setsockopt
Date: Thu, 10 Nov 2011 11:36:49 +0100
Message-ID: <97b602ea42b0467fa4e9f63a909f9080@chewa.net>
References: <1320918622-22740-1-git-send-email-hemant.ramdasi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <remi.denis-courmont@nokia.com>, <netdev@vger.kernel.org>,
	Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
To: Hemant Vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:44882 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751863Ab1KJKpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 05:45:42 -0500
In-Reply-To: <1320918622-22740-1-git-send-email-hemant.ramdasi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2011 15:20:22 +0530, Hemant Vilas RAMDASI=0D
<hemant.ramdasi@stericsson.com> wrote:=0D
> From: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>=0D
> =0D
> This provides flexibility to set the pipe handle=0D
> using setsockopt and enable the same.=0D
> =0D
> Signed-off-by: Hemant Ramdasi <hemant.ramdasi@stericsson.com>=0D
> Signed-off-by: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>=0D
> ---=0D
>  include/linux/phonet.h |    2 +=0D
>  net/phonet/pep.c       |   90=0D
>  ++++++++++++++++++++++++++++++++++++++++++++++-=0D
>  2 files changed, 90 insertions(+), 2 deletions(-)=0D
> =0D
> diff --git a/include/linux/phonet.h b/include/linux/phonet.h=0D
> index 6fb1384..491caec 100644=0D
> --- a/include/linux/phonet.h=0D
> +++ b/include/linux/phonet.h=0D
> @@ -37,6 +37,8 @@=0D
>  #define PNPIPE_ENCAP		1=0D
>  #define PNPIPE_IFINDEX		2=0D
>  #define PNPIPE_HANDLE		3=0D
> +#define PNPIPE_ENABLE		4=0D
> +#define PNPIPE_INITSTATE	5=0D
>  =0D
>  #define PNADDR_ANY		0=0D
>  #define PNADDR_BROADCAST	0xFC=0D
> diff --git a/net/phonet/pep.c b/net/phonet/pep.c=0D
> index f17fd84..f8057a1 100644=0D
> --- a/net/phonet/pep.c=0D
> +++ b/net/phonet/pep.c=0D
> @@ -167,6 +167,12 @@ static int pipe_handler_send_created_ind(struct=0D
sock=0D
> *sk)=0D
>  				data, 4, GFP_ATOMIC);=0D
>  }=0D
>  =0D
> +static int pipe_handler_send_enabled_ind(struct sock *sk)=0D
> +{=0D
> +	return pep_indicate(sk, PNS_PIPE_ENABLED_IND, 0 /* sub-blocks */,=0D
> +				NULL, 0, GFP_ATOMIC);=0D
> +}=0D
> +=0D
>  static int pep_accept_conn(struct sock *sk, struct sk_buff *skb)=0D
>  {=0D
>  	static const u8 data[20] =3D {=0D
> @@ -533,6 +539,17 @@ static int pep_connresp_rcv(struct sock *sk, str=
uct=0D
> sk_buff *skb)=0D
>  	return pipe_handler_send_created_ind(sk);=0D
>  }=0D
>  =0D
> +static int pep_enableresp_rcv(struct sock *sk, struct sk_buff *skb)=0D
> +{=0D
> +	struct pnpipehdr *hdr =3D pnp_hdr(skb);=0D
> +=0D
> +	if (hdr->error_code !=3D PN_PIPE_NO_ERROR)=0D
> +		return -ECONNREFUSED;=0D
> +=0D
> +	return pipe_handler_send_enabled_ind(sk);=0D
> +}=0D
> +=0D
> +=0D
>  /* Queue an skb to an actively connected sock.=0D
>   * Socket lock must be held. */=0D
>  static int pipe_handler_do_rcv(struct sock *sk, struct sk_buff *skb)=
=0D
> @@ -578,6 +595,28 @@ static int pipe_handler_do_rcv(struct sock *sk,=0D
> struct sk_buff *skb)=0D
>  			sk->sk_state =3D TCP_CLOSE_WAIT;=0D
>  			break;=0D
>  		}=0D
> +		if (pn->init_enable =3D=3D PN_PIPE_DISABLE)=0D
> +			sk->sk_state =3D TCP_SYN_RECV;=0D
> +		else {=0D
> +			sk->sk_state =3D TCP_ESTABLISHED;=0D
> +=0D
> +			if (!pn_flow_safe(pn->tx_fc)) {=0D
> +				atomic_set(&pn->tx_credits, 1);=0D
> +				sk->sk_write_space(sk);=0D
> +			}=0D
> +			pipe_grant_credits(sk, GFP_ATOMIC);=0D
> +=0D
> +		}=0D
=0D
I'd rather not duplicate this code as far as possible.=0D
=0D
> +		break;=0D
> +=0D
> +	case PNS_PEP_ENABLE_RESP:=0D
> +		if (sk->sk_state !=3D TCP_SYN_SENT)=0D
> +			break;=0D
> +=0D
> +		if (pep_enableresp_rcv(sk, skb)) {=0D
> +			sk->sk_state =3D TCP_CLOSE_WAIT;=0D
> +			break;=0D
> +		}=0D
>  =0D
>  		sk->sk_state =3D TCP_ESTABLISHED;=0D
>  		if (!pn_flow_safe(pn->tx_fc)) {=0D
> @@ -863,9 +902,26 @@ static int pep_sock_connect(struct sock *sk, str=
uct=0D
> sockaddr *addr, int len)=0D
>  	int err;=0D
>  	u8 data[4] =3D { 0 /* sub-blocks */, PAD, PAD, PAD };=0D
>  =0D
> -	pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */=0D
> +	if (pn->pipe_handle =3D=3D PN_PIPE_INVALID_HANDLE)=0D
> +		pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */=0D
> +=0D
>  	err =3D pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,=0D
> -					PN_PIPE_ENABLE, data, 4);=0D
> +				pn->init_enable, data, 4);=0D
> +	if (err)=0D
> +		return err;=0D
> +=0D
> +	sk->sk_state =3D TCP_SYN_SENT;=0D
> +=0D
> +	return 0;=0D
> +}=0D
> +=0D
> +static int pep_sock_enable(struct sock *sk, struct sockaddr *addr, i=
nt=0D
> len)=0D
> +{=0D
> +	struct pep_sock *pn =3D pep_sk(sk);=0D
> +	int err;=0D
> +=0D
> +	err =3D pipe_handler_request(sk, PNS_PEP_ENABLE_REQ, PAD,=0D
> +				NULL, 0);=0D
>  	if (err) {=0D
>  		pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;=0D
>  		return err;=0D
=0D
I doubt that a pipe in connected state with no handle is going to work.=
=0D
=0D
> @@ -959,6 +1015,29 @@ static int pep_setsockopt(struct sock *sk, int=0D
> level, int optname,=0D
>  		}=0D
>  		goto out_norel;=0D
>  =0D
> +	case PNPIPE_HANDLE:=0D
> +		if ((val >=3D 0) && (val < PN_PIPE_INVALID_HANDLE))=0D
> +			pn->pipe_handle =3D val;=0D
> +		else=0D
> +			err =3D -EINVAL;=0D
> +		break;=0D
=0D
This should only be settable before connect(), I guess.=0D
=0D
> +=0D
> +	case PNPIPE_ENABLE:=0D
> +		if (sk->sk_state =3D=3D TCP_SYN_SENT)=0D
> +			err =3D -EBUSY;=0D
=0D
This statement has no effects. You probably forgot something.=0D
=0D
> +		if (sk->sk_state =3D=3D TCP_ESTABLISHED)=0D
> +			err =3D -EISCONN;=0D
> +		else=0D
> +			err =3D pep_sock_enable(sk, NULL, 0);=0D
> +		break;=0D
=0D
This still does not follow the setter/getter level-trigger semantics of=
=0D
(s|g)etsockopt().=0D
=0D
> +=0D
> +	case PNPIPE_INITSTATE:=0D
> +		if ((val =3D=3D PN_PIPE_DISABLE) || (val =3D=3D PN_PIPE_ENABLE))=0D
> +			pn->init_enable =3D val;=0D
> +		else=0D
> +			err =3D -EINVAL;=0D
=0D
IMHO, PNPIPE_INIT_ENABLE and boolean values would be simpler. I don't=0D
really fancy exposing protocol-internal values to user space unless rea=
lly=0D
needed.=0D
=0D
> +		break;=0D
> +=0D
>  	default:=0D
>  		err =3D -ENOPROTOOPT;=0D
>  	}=0D
> @@ -994,6 +1073,13 @@ static int pep_getsockopt(struct sock *sk, int=0D
> level, int optname,=0D
>  			return -EINVAL;=0D
>  		break;=0D
>  =0D
> +	case PNPIPE_ENABLE:=0D
> +		if (sk->sk_state !=3D TCP_ESTABLISHED)=0D
> +			return -EINVAL;=0D
> +		else=0D
> +			val =3D 1;=0D
> +		break;=0D
=0D
This does not look correct.=0D
=0D
> +=0D
=0D
PNPIPE_INITSTATE is missing.=0D
=0D
>  	default:=0D
>  		return -ENOPROTOOPT;=0D
>  	}=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net/
