From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 18:57:13 +0000
Message-ID: <1260817033.9141.8.camel@merlyn>
References: <20091212.010340.227842186.davem@davemloft.net>
	 <4B2360BF.5000102@gmail.com>	<4B25D38F.1090702@gmail.com>
	 <20091213.234530.82029083.davem@davemloft.net> <4B267708.3010202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932191AbZLNS5U@vger.kernel.org>
In-Reply-To: <4B267708.3010202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-12-14 at 18:34 +0100, Eric Dumazet wrote:
> Le 14/12/2009 08:45, David Miller a =C3=A9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 14 Dec 2009 06:56:31 +0100
> >=20
> >> It seems to me tcp_create_openreq_child() doesnt properly initiali=
ze
> >> newtp->cookie_values to NULL, but this should not produce warnings=
 like that ?
> >=20
> > If oldtp->cookie_values is NULL, the child's should be as well
> > because of sk_clone().
>=20
> Right, maybe then its a tcp_ack() or a syncookie validation change ?
>=20
>=20
> tcp_v4_rcv()
>         bh_lock_sock_nested(sk);
>         if (!sock_owned_by_user(sk)) {
>=20
>         -> tcp_v4_do_rcv()
>                 -> tcp_v4_hnd_req()
>                         -> cookie_v4_check()
>                                 -> get_cookie_sock()
>                                         -> child =3D syn_recv_sock()
>                                         -> inet_csk_reqsk_queue_add(c=
hild) (TCP_SYN_RECV socket queued into parent)
>                 -> tcp_child_process() (backlog... not)
>                         -> tcp_rcv_state_process()
>                                 -> acceptable =3D tcp_ack() > 0;
>                                 -> if (acceptable) -> sk_state =3D TC=
P_ESTABLISHED
>                                         (but if tcp_ack() returned <=3D=
 0, state unchanged : TCP_SYN_RECV)
>=20
>=20
> And commit 96e0bf4b5193d0d97d139f99e2dd128763d55521
> (tcp: Discard segments that ack data not yet sent)
>=20
> Did change this area a bit :
>=20
> @@ -5632,7 +5639,7 @@ int tcp_rcv_state_process(struct sock *sk, stru=
ct sk_buff *skb,
> =20
>         /* step 5: check the ACK field */
>         if (th->ack) {
> -               int acceptable =3D tcp_ack(sk, skb, FLAG_SLOWPATH);
> +               int acceptable =3D tcp_ack(sk, skb, FLAG_SLOWPATH) > =
0;
> =20
>                 switch (sk->sk_state) {
>                 case TCP_SYN_RECV:

That test was changed to match a change in the return values of
tcp_ack().  No logic change was intended.

I won't be able to catch up on this thread and take a look at the code
until this evening, CST.

  --  John
