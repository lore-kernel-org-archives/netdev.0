From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 3/6] Phonet: Pipe End Point for Phonet Pipes protocol
Date: Thu, 2 Oct 2008 13:50:52 +0300
Message-ID: <200810021350.53010.remi.denis-courmont@nokia.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com> <1222855985-22859-3-git-send-email-remi.denis-courmont@nokia.com> <20081001131856.GF970@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:41452 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbYJBKvO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 06:51:14 -0400
In-Reply-To: <20081001131856.GF970@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 October 2008 16:18:56 ext Arnaldo Carvalho de Melo, you=
 wrote:
> > +static struct sock *pep_find_pipe(const struct hlist_head *hlist,
> > +					const struct sockaddr_pn *dst,
> > +					u8 pipe_handle)
> > +{
> > +	struct hlist_node *node;
> > +	struct sock *sknode;
> > +	u16 dobj =3D pn_sockaddr_get_object(dst);
>
> What is the lock that protects this list traversal?

Either (accepted or unaccepted) sock lists should only be used with the=
 sock=20
lock of the listening sock. Is that insufficient?

> > +static int pep_wait_connreq(struct sock *sk, int noblock)
>
> This function looks familiar... inet_csk_accept,
> inet_csk_wait_for_connect...

I don't recall why I gave up on using request_sock and listen_sock ther=
e.

> perhaps we need a connection_sock father=20
> for inet_connection_sock? :-)

But you cannot have double inheritance, right? inet_sock and=20
connection_sock... I guess that's why listen_sock is _not_ a sock.

> > +{
> > +	struct task_struct *tsk =3D current;
> > +	struct pep_sock *pn =3D pep_sk(sk);
> > +	long timeo =3D sock_rcvtimeo(sk, noblock);
> > +
> > +	for (;;) {
> > +		DEFINE_WAIT(wait);
> > +
> > +		if (sk->sk_state !=3D TCP_LISTEN)
> > +			return -EINVAL;
> > +		if (!hlist_empty(&pn->ackq))
> > +			break;
> > +		if (!timeo)
> > +			return -EWOULDBLOCK;
> > +		if (signal_pending(tsk))
> > +			return sock_intr_errno(timeo);
> > +
> > +		prepare_to_wait_exclusive(&sk->sk_socket->wait, &wait,
> > +						TASK_INTERRUPTIBLE);
> > +		release_sock(sk);
> > +		timeo =3D schedule_timeout(timeo);
> > +		lock_sock(sk);
> > +		finish_wait(&sk->sk_socket->wait, &wait);
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static struct sock *pep_sock_accept(struct sock *sk, int flags, in=
t
> > *errp) +{
> > +	struct pep_sock *pn =3D pep_sk(sk);
> > +	struct sock *newsk =3D NULL;
> > +	struct sk_buff *oskb;
> > +	int err;
> > +
> > +	lock_sock(sk);
> > +	err =3D pep_wait_connreq(sk, flags & O_NONBLOCK);
> > +	if (err)
> > +		goto out;
> > +
> > +	newsk =3D __sk_head(&pn->ackq);
> > +
> > +	oskb =3D skb_dequeue(&newsk->sk_receive_queue);
> > +	err =3D pep_accept_conn(newsk, oskb);
> > +	if (err) {
> > +		skb_queue_head(&newsk->sk_receive_queue, oskb);
> > +		newsk =3D NULL;
> > +		goto out;
> > +	}
> > +
> > +	sock_hold(sk);
> > +	pep_sk(newsk)->listener =3D sk;
> > +
> > +	sock_hold(newsk);
> > +	sk_del_node_init(newsk);
> > +	sk_acceptq_removed(sk);
> > +	sk_add_node(newsk, &pn->hlist);
> > +	__sock_put(newsk);
> > +
> > +out:
> > +	release_sock(sk);
> > +	*errp =3D err;
> > +	return newsk;
> > +}
> > +
> > +static int pep_ioctl(struct sock *sk, int cmd, unsigned long arg)
> > +{
> > +	int answ;
> > +
> > +	switch (cmd) {
> > +	case SIOCINQ:
> > +		if (sk->sk_state =3D=3D TCP_LISTEN)
> > +			return -EINVAL;
> > +
> > +		lock_sock(sk);
> > +		if (!skb_queue_empty(&sk->sk_receive_queue))
> > +			answ =3D skb_peek(&sk->sk_receive_queue)->len;
> > +		else
> > +			answ =3D 0;
> > +		release_sock(sk);
> > +		return put_user(answ, (int __user *)arg);
>
> this is so common I wonder we if a helper wouldn't help 8) Look at
> dccp_ioctl before Ilpo does 8)

It is not so common with the next patch which checks for urgent inline.=
=2E. As=20
far as I know, there is no common queue for out-of-band data.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
