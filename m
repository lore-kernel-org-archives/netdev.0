From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH] Phonet: 'connect' socket implementation for Pipe controller
Date: Tue, 12 Oct 2010 19:30:30 +0300
Message-ID: <201010121930.32116.remi@remlab.net>
References: <1286897211-3198-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, davem@davemloft.net,
	netdev@vger.kernel.org, linus.walleij@stericsson.com,
	gulshan.karmani@stericsson.com, sudeep.divakaran@stericsson.com
To: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:55308 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757785Ab0JLQae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 12:30:34 -0400
In-Reply-To: <1286897211-3198-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

Just a few comments...

Le mardi 12 octobre 2010 18:26:51 Kumar A Sanghvi, vous avez =C3=A9crit=
 :
> diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
> index def6cfa..b60b28c 100644
> --- a/include/net/phonet/pep.h
> +++ b/include/net/phonet/pep.h
> @@ -802,6 +682,42 @@ static void pipe_destruct(struct sock *sk)
>  	skb_queue_purge(&pn->ctrlreq_queue);
>  }
>=20
> +#ifdef CONFIG_PHONET_PIPECTRLR
> +static int pep_connresp_rcv(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct pep_sock *pn =3D pep_sk(sk);
> +	static u8 host_pref_rx_fc[3] =3D {3, 2, 1}, host_req_tx_fc[3] =3D {=
3, 2, 1};

Why is this 'static' ? Doesn't that break concurrent uses?

> +	u8 remote_pref_rx_fc[3], remote_req_tx_fc[3];
> +	u8 negotiated_rx_fc, negotiated_tx_fc;
> +	int ret;
> +
> +	pipe_get_flow_info(sk, skb, remote_pref_rx_fc,
> +			remote_req_tx_fc);
> +	negotiated_tx_fc =3D pipe_negotiate_fc(remote_req_tx_fc,
> +			host_pref_rx_fc,
> +			sizeof(host_pref_rx_fc));
> +	negotiated_rx_fc =3D pipe_negotiate_fc(host_req_tx_fc,
> +			remote_pref_rx_fc,
> +			sizeof(host_pref_rx_fc));
> +
> +	pn->pipe_state =3D PIPE_DISABLED;
> +	sk->sk_state =3D TCP_SYN_RECV;
> +	sk->sk_backlog_rcv =3D pipe_do_rcv;
> +	sk->sk_destruct =3D pipe_destruct;
> +	pn->rx_credits =3D 0;
> +	pn->rx_fc =3D negotiated_rx_fc;
> +	pn->tx_fc =3D negotiated_tx_fc;
> +	sk->sk_state_change(sk);
> +
> +	ret =3D pipe_handler_send_created_ind(sk,
> +			PNS_PIPE_CREATED_IND_UTID,
> +			PNS_PIPE_CREATED_IND
> +			);
> +
> +	return ret;
> +}
> +#endif
> +
>  static int pep_connreq_rcv(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct sock *newsk;

> diff --git a/net/phonet/socket.c b/net/phonet/socket.c
> index aca8fba..123a374 100644
> --- a/net/phonet/socket.c
> +++ b/net/phonet/socket.c
> @@ -225,6 +225,102 @@ static int pn_socket_autobind(struct socket *so=
ck)
>  	return 0; /* socket was already bound */
>  }
>=20
> +static int pn_socket_connect(struct socket *sock, struct sockaddr *a=
ddr,
> +		int len, int flags)
> +{
> +	struct sock *sk =3D sock->sk;
> +	struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
> +	long timeo;
> +	int err;
> +
> +	lock_sock(sk);
> +
> +	if (len < sizeof(struct sockaddr_pn))
> +		return -EINVAL;
> +	if (spn->spn_family !=3D AF_PHONET)
> +		return -EAFNOSUPPORT;

You should move lock_sock(sk); here, I think.

> +
> +	switch (sock->state) {
> +	case SS_UNCONNECTED:
> +		sk->sk_state =3D TCP_CLOSE;
> +		break;
> +	case SS_CONNECTING:
> +		switch (sk->sk_state) {
> +		case TCP_SYN_RECV:
> +			sock->state =3D SS_CONNECTED;
> +			err =3D -EISCONN;
> +			goto out;
> +		case TCP_CLOSE:
> +			err =3D -EALREADY;
> +			if (flags & O_NONBLOCK)
> +				goto out;
> +			goto wait_connect;
> +			break;

I think the kernel policy is against redumdant break statements.

> +		}
> +		break;
> +	case SS_CONNECTED:
> +		switch (sk->sk_state) {
> +		case TCP_SYN_RECV:
> +			err =3D -EISCONN;
> +			goto out;
> +		case TCP_CLOSE:
> +			sock->state =3D SS_UNCONNECTED;
> +			break;
> +		}
> +		break;
> +	case SS_DISCONNECTING:
> +	case SS_FREE:
> +		break;
> +	}
> +	sk->sk_state =3D TCP_CLOSE;
> +	sock->state =3D SS_UNCONNECTED;

This is dead code...

> +	sk_stream_kill_queues(sk);
> +
> +
> +	sock->state =3D SS_CONNECTING;

=2E..because of this ^ .

> +	err =3D sk->sk_prot->connect(sk, addr, len);
> +	if (err < 0) {
> +		sock->state =3D SS_UNCONNECTED;
> +		sk->sk_state =3D TCP_CLOSE;
> +		goto out;
> +	}
> +
> +	err =3D -EINPROGRESS;
> +wait_connect:
> +	if (sk->sk_state !=3D TCP_SYN_RECV && (flags & O_NONBLOCK))
> +		goto out;
> +
> +	timeo =3D sock_sndtimeo(sk, flags & O_NONBLOCK);
> +	release_sock(sk);
> +
> +	err =3D -ERESTARTSYS;
> +	timeo =3D wait_event_interruptible_timeout(*sk_sleep(sk),
> +			sk->sk_state !=3D TCP_CLOSE,
> +			timeo);
> +
> +	lock_sock(sk);
> +	if (timeo < 0)
> +		goto out; /* -ERESTARTSYS */
> +
> +	err =3D -ETIMEDOUT;
> +	if (timeo =3D=3D 0 && sk->sk_state !=3D TCP_SYN_RECV)
> +		goto out;
> +
> +	if (sk->sk_state !=3D TCP_SYN_RECV) {
> +		sock->state =3D SS_UNCONNECTED;
> +		err =3D sock_error(sk);
> +		if (!err)
> +			err =3D -ECONNREFUSED;
> +		goto out;
> +	}
> +	sock->state =3D SS_CONNECTED;
> +	err =3D 0;
> +
> +out:
> +	release_sock(sk);
> +	return err;
> +}
> +
>  static int pn_socket_accept(struct socket *sock, struct socket *news=
ock,
>  				int flags)
>  {


--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
