From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH] Phonet: 'connect' socket implementation for Pipe
 controller
Date: Wed, 13 Oct 2010 10:02:45 +0530
Message-ID: <20101013043240.GA28430@bnru01.bnr.st.com>
References: <1286897211-3198-1-git-send-email-kumar.sanghvi@stericsson.com>
 <201010121930.32116.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linus WALLEIJ <linus.walleij@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:33346 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750698Ab0JMEdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 00:33:08 -0400
Content-Disposition: inline
In-Reply-To: <201010121930.32116.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi R=E9mi Denis-Courmontt,=20

On Tue, Oct 12, 2010 at 18:30:30 +0200, R=E9mi Denis-Courmont wrote:
> > +	static u8 host_pref_rx_fc[3] =3D {3, 2, 1}, host_req_tx_fc[3] =3D=
 {3, 2, 1};
>=20
> Why is this 'static' ? Doesn't that break concurrent uses?

Yes. The 'static' is not needed here. I will fix this.
Thanks.

 > +static int pn_socket_connect(struct socket *sock, struct sockaddr *=
addr,
> > +		int len, int flags)
> > +{
> > +	struct sock *sk =3D sock->sk;
> > +	struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
> > +	long timeo;
> > +	int err;
> > +
> > +	lock_sock(sk);
> > +
> > +	if (len < sizeof(struct sockaddr_pn))
> > +		return -EINVAL;
> > +	if (spn->spn_family !=3D AF_PHONET)
> > +		return -EAFNOSUPPORT;
>=20
> You should move lock_sock(sk); here, I think.

Yes. I will fix this locking.
Thanks.

>=20
> > +
> > +	switch (sock->state) {
> > +	case SS_UNCONNECTED:
> > +		sk->sk_state =3D TCP_CLOSE;
> > +		break;
> > +	case SS_CONNECTING:
> > +		switch (sk->sk_state) {
> > +		case TCP_SYN_RECV:
> > +			sock->state =3D SS_CONNECTED;
> > +			err =3D -EISCONN;
> > +			goto out;
> > +		case TCP_CLOSE:
> > +			err =3D -EALREADY;
> > +			if (flags & O_NONBLOCK)
> > +				goto out;
> > +			goto wait_connect;
> > +			break;
>=20
> I think the kernel policy is against redumdant break statements.

Yes, the break is redundant here. I will fix this.
Thanks.

>=20
> > +		}
> > +		break;
> > +	case SS_CONNECTED:
> > +		switch (sk->sk_state) {
> > +		case TCP_SYN_RECV:
> > +			err =3D -EISCONN;
> > +			goto out;
> > +		case TCP_CLOSE:
> > +			sock->state =3D SS_UNCONNECTED;
> > +			break;
> > +		}
> > +		break;
> > +	case SS_DISCONNECTING:
> > +	case SS_FREE:
> > +		break;
> > +	}
> > +	sk->sk_state =3D TCP_CLOSE;
> > +	sock->state =3D SS_UNCONNECTED;
>=20
> This is dead code...

Yes. I will remove the above assignment to sock->state which is not
required at all.
Thanks.

>=20
> > +	sk_stream_kill_queues(sk);
> > +
> > +
> > +	sock->state =3D SS_CONNECTING;
>=20
> ...because of this ^ .
>=20
> > +	err =3D sk->sk_prot->connect(sk, addr, len);

Thanks for the review. I will fix and upload v2 version of the patch.
I will also upload a patch on Documentation describing on 'connect' for
Pipe controller logic.

Thanks & regards,
Kumar.
