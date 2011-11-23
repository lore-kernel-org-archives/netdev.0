From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 07:13:22 +0100
Message-ID: <1322028802.1298.10.camel@edumazet-laptop>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
	 <CABrhC0m75OHmdDD-crr=tvTiRq_hnh7WpHtLjM9TKgTa24MSOA@mail.gmail.com>
	 <1322025880.29324.1.camel@edumazet-laptop>
	 <1322027911.1298.4.camel@edumazet-laptop>
	 <1322028540.1298.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Young <jlyo@jlyo.org>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39000 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab1KWGN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 01:13:26 -0500
Received: by fagn18 with SMTP id n18so1293225fag.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 22:13:25 -0800 (PST)
In-Reply-To: <1322028540.1298.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 07:09 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mercredi 23 novembre 2011 =C3=A0 06:58 +0100, Eric Dumazet a =C3=A9=
crit :
>=20
> > First connection went well.
> >=20
> > Now we try to reuse tuple  (ports 49374, 8009 on loopback) while a =
socket is in TIMEWAIT, and first
> > SYN packet (time 06:48:20.337335) is dropped (considered as a packe=
t part of previous session)
> >=20
> > Now why the first SYN packet is dropped and not the second one, I d=
ont know yet.
>=20
>=20
> in netstat -s output, the suspect increasing counter is :
>=20
> "45 congestion windows recovered without slow start after partial ack=
"
>=20
>=20

# vi +2831 net/ipv4/tcp_input.c

/* Undo during loss recovery after partial ACK. */
static int tcp_try_undo_loss(struct sock *sk)
{
        struct tcp_sock *tp =3D tcp_sk(sk);

        if (tcp_may_undo(tp)) {
                struct sk_buff *skb;
                tcp_for_write_queue(skb, sk) {
                        if (skb =3D=3D tcp_send_head(sk))
                                break;
                        TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
                }

                tcp_clear_all_retrans_hints(tp);

                DBGUNDO(sk, "partial loss");
                tp->lost_out =3D 0;
                tcp_undo_cwr(sk, true);
HERE:            NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSUNDO);
                inet_csk(sk)->icsk_retransmits =3D 0;
                tp->undo_marker =3D 0;
                if (tcp_is_sack(tp))
                        tcp_set_ca_state(sk, TCP_CA_Open);
                return 1;
        }
        return 0;
}
