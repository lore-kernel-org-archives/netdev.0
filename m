From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 18:34:00 +0100
Message-ID: <4B267708.3010202@gmail.com>
References: <20091212.010340.227842186.davem@davemloft.net>	<4B2360BF.5000102@gmail.com>	<4B25D38F.1090702@gmail.com> <20091213.234530.82029083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lists@nerdbynature.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Dykstra <john.dykstra1@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53932 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852AbZLNReI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 12:34:08 -0500
In-Reply-To: <20091213.234530.82029083.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/12/2009 08:45, David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 14 Dec 2009 06:56:31 +0100
>=20
>> It seems to me tcp_create_openreq_child() doesnt properly initialize
>> newtp->cookie_values to NULL, but this should not produce warnings l=
ike that ?
>=20
> If oldtp->cookie_values is NULL, the child's should be as well
> because of sk_clone().

Right, maybe then its a tcp_ack() or a syncookie validation change ?


tcp_v4_rcv()
        bh_lock_sock_nested(sk);
        if (!sock_owned_by_user(sk)) {

        -> tcp_v4_do_rcv()
                -> tcp_v4_hnd_req()
                        -> cookie_v4_check()
                                -> get_cookie_sock()
                                        -> child =3D syn_recv_sock()
                                        -> inet_csk_reqsk_queue_add(chi=
ld) (TCP_SYN_RECV socket queued into parent)
                -> tcp_child_process() (backlog... not)
                        -> tcp_rcv_state_process()
                                -> acceptable =3D tcp_ack() > 0;
                                -> if (acceptable) -> sk_state =3D TCP_=
ESTABLISHED
                                        (but if tcp_ack() returned <=3D=
 0, state unchanged : TCP_SYN_RECV)


And commit 96e0bf4b5193d0d97d139f99e2dd128763d55521
(tcp: Discard segments that ack data not yet sent)

Did change this area a bit :

@@ -5632,7 +5639,7 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
=20
        /* step 5: check the ACK field */
        if (th->ack) {
-               int acceptable =3D tcp_ack(sk, skb, FLAG_SLOWPATH);
+               int acceptable =3D tcp_ack(sk, skb, FLAG_SLOWPATH) > 0;
=20
                switch (sk->sk_state) {
                case TCP_SYN_RECV:



