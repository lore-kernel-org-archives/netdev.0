From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSecr != 0 check in inet_lro.c
Date: Tue, 25 Aug 2009 07:42:33 +0200
Message-ID: <4A9379C9.6050108@gmail.com>
References: <200908250054.50664.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan-Bernd Themann <themann@de.ibm.com>, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37479 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbZHYFmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 01:42:36 -0400
In-Reply-To: <200908250054.50664.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> Hi,
>=20
> We are seeing a performance issue with TSO/LRO which we tracked down =
to the=20
> TSecr !=3D0 check in lro_tcp_ip_check.

ouch...

>=20
> It happens when the LRO side's TSval wraps around and gets to 0. That=
 triggers=20
> the TSO side to send packets with TSecr set to 0, which means that su=
ch=20
> packets won't be aggregated - and that will put a lot of burden on th=
e stack=20
> which will result in lots of drops.

Probability of such event is 1 / 2^32 or so ?

>=20
> I'm failing to understand the purpose of this check. Any hints? :)
>=20

rfc1323 badly interpreted ?

I remember tsecr=3D0 was forbidden by Linux, while apparently rfc is no=
t
so clear.

rfc1323 : 3.2
         The Timestamp Echo Reply field (TSecr) is only valid if the AC=
K
         bit is set in the TCP header; if it is valid, it echos a times=
-
         tamp value that was sent by the remote TCP in the TSval field
         of a Timestamps option.  When TSecr is not valid, its value
         must be zero.  The TSecr value will generally be from the most
         recent Timestamp option that was received; however, there are
         exceptions that are explained below.

Note how this is not saying "a zero Tsecr value is not valid"

I could not find why : "When TSecr is not valid, its value
must be zero", and why we consider a zero value to be not meaningfull..=
=2E

static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
                                      const s32 seq_rtt)
{
        const struct tcp_sock *tp =3D tcp_sk(sk);
        /* Note that peer MAY send zero echo. In this case it is ignore=
d. (rfc1323) */
        if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
                tcp_ack_saw_tstamp(sk, flag);
        else if (seq_rtt >=3D 0)
                tcp_ack_no_tstamp(sk, seq_rtt, flag);
}

static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buf=
f *skb,
                                         struct tcphdr *th, unsigned le=
n)
{
        struct tcp_sock *tp =3D tcp_sk(sk);
        struct inet_connection_sock *icsk =3D inet_csk(sk);
        int saved_clamp =3D tp->rx_opt.mss_clamp;

        tcp_parse_options(skb, &tp->rx_opt, 0);

        if (th->ack) {
=2E..
                if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
                    !between(tp->rx_opt.rcv_tsecr, tp->retrans_stamp,
                             tcp_time_stamp)) {
                        NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSAC=
TIVEREJECTED);
                        goto reset_and_undo;
                }
=2E..

static inline void tcp_rcv_rtt_measure_ts(struct sock *sk,
                                          const struct sk_buff *skb)
{
        struct tcp_sock *tp =3D tcp_sk(sk);
        if (tp->rx_opt.rcv_tsecr &&
            (TCP_SKB_CB(skb)->end_seq -
             TCP_SKB_CB(skb)->seq >=3D inet_csk(sk)->icsk_ack.rcv_mss))
                tcp_rcv_rtt_update(tp, tcp_time_stamp - tp->rx_opt.rcv_=
tsecr, 0);
}
=2E..
static inline int tcp_packet_delayed(struct tcp_sock *tp)
{
        return !tp->retrans_stamp ||
                (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
                 before(tp->rx_opt.rcv_tsecr, tp->retrans_stamp));
}
=2E..

So we dont have a bit saying we received a tsecr, we use the=20
'if saw_tstamp AND tsecr is not null' convention...

