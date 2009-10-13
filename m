From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 09:23:59 +0200
Message-ID: <4AD42B0F.8010809@gmail.com>
References: <20091013050705.GA2194@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53654 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933656AbZJMHZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:25:10 -0400
In-Reply-To: <20091013050705.GA2194@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> Hello,
>=20
> I was trying to use TCP_DEFER_ACCEPT and noticed that if the
> client does not talk, the connection is never accepted and
> remains in SYN_RECV state until the retransmits expire, where
> it finally is deleted. This is bad when some firewall such as
> netfilter sits between the client and the server because the
> firewall sees the connection in ESTABLISHED state while the
> server will finally silently drop it without sending an RST.
>=20
> This behaviour contradicts the man page which says it should
> wait only for some time :
>=20
>        TCP_DEFER_ACCEPT (since Linux 2.4)
>           Allows a listener to be awakened only when data arrives
>           on the socket.  Takes an integer value  (seconds), this
>           can  bound  the  maximum  number  of attempts TCP will
>           make to complete the connection. This option should not
>           be used in code intended to be portable.
>=20
> Also, looking at ipv4/tcp.c, a retransmit counter is correctly
> computed :
>=20
>         case TCP_DEFER_ACCEPT:
>                 icsk->icsk_accept_queue.rskq_defer_accept =3D 0;
>                 if (val > 0) {
>                         /* Translate value in seconds to number of
>                          * retransmits */
>                         while (icsk->icsk_accept_queue.rskq_defer_acc=
ept < 32 &&
>                                val > ((TCP_TIMEOUT_INIT / HZ) <<
>                                        icsk->icsk_accept_queue.rskq_d=
efer_accept))
>                                 icsk->icsk_accept_queue.rskq_defer_ac=
cept++;
>                         icsk->icsk_accept_queue.rskq_defer_accept++;
>                 }
>                 break;
>=20
> =3D=3D> rskq_defer_accept is used as a counter of retransmits.
>=20
> But in tcp_minisocks.c, this counter is only checked. And in
> fact, I have found no location which updates it. So I think
> that what was intended was to decrease it in tcp_minisocks
> whenever it is checked, which the trivial patch below does :
>=20
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index f8d67cc..1b443b0 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -645,6 +645,7 @@ struct sock *tcp_check_req(struct sock *sk, struc=
t sk_buff *skb,
>  	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
>  	    TCP_SKB_CB(skb)->end_seq =3D=3D tcp_rsk(req)->rcv_isn + 1) {
> +		inet_csk(sk)->icsk_accept_queue.rskq_defer_accept--;
>  		inet_rsk(req)->acked =3D 1;
>  		return NULL;
>  	}
> =20


I dont understand why you want to decrement rskq_defer_accept here.
We receive a pure ACK (wihout DATA).
We should receive exactly one such ACK.
(This is the third packet of the three way TCP handshake)

How this can solve the problem you mention ?
(ie, not sending an RST when we timeout the SYN_RECV session)
