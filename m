From: Dave Taht <dave.taht@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Mon, 19 Jan 2015 18:37:16 -0800
Message-ID: <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	<1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	<54B590FB.5040805@dev.mellanox.co.il>
	<1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
	<1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
	<54BC286B.8000605@mellanox.com>
	<1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:59890 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbbATChR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 21:37:17 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp4so16307698obc.1
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 18:37:16 -0800 (PST)
In-Reply-To: <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 6:16 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Sun, 2015-01-18 at 23:40 +0200, Eyal Perry wrote:
>
>> So indeed, interrupt mitigation (tx-usecs 1 tx-frames 1) improves th=
ings up
>> for the "refined TSO autosizing" kernel (from 18.4Gbps to 19.7Gbps).=
 but
>> in the
>> other kernel, the BW is remains the same with and without the coales=
cing.
>
> OK thanks for testing.
>
> I believe the regression comes from inability for cc to cope with
> stretch acks.
>
> Nowadays on fast networks, each ACK packet acknowledges ~45 MSS, but
> CUBIC (and others cc) got support for this only during slow start, wi=
th
> commit 9f9843a751d0a2057f9f3d313886e7e5e6ebaac9
> ("tcp: properly handle stretch acks in slow start")
>
> I guess it is time to also handle congestion avoidance phase.

Are you saying that at long last, delayed acks as we knew them are
dead, dead, dead?

> With following patch (very close to what we use here at Google) I
> reached 37Gbps instead of 20Gbps :
>
> ethtool -C eth1 tx-usecs 4 tx-frames 4

What is the default here?

What happens with the default here?

>
> DUMP_TCP_INFO=3D1 ./netperf -H remote -T2,2 -t TCP_STREAM -l 20
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to rem=
ote () port 0 AF_INET : cpu bind
> rto=3D201000 ato=3D0 pmtu=3D1500 rcv_ssthresh=3D29200 rtt=3D67 rttvar=
=3D6 snd_ssthresh=3D263 cwnd=3D265 reordering=3D3 total_retrans=3D4569 =
ca_state=3D0

The above statistics are not dumped by my netperf, and look extremely
desirable to capture in netperf-wrapper. This is a script parsing some
other kernel data at the conclusion of the run? or a better netperf?

If ECN was on the bottleneck link, I imagine total_retrans would be 0,
or are packets getting dropped in the kernel?

> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>
>  87380  16384  16384    20.00    37213.05
>
> I guess this is a world record, my previous one was 34Gbps.
>
>
>  include/net/tcp.h    |    2
>  net/ipv4/tcp_cong.c  |    4 +
>  net/ipv4/tcp_cubic.c |   91 +++++++++++++++++++---------------------=
-
>  3 files changed, 47 insertions(+), 50 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index b8fdc6bab3f3..05815fbb490f 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -843,7 +843,7 @@ void tcp_get_available_congestion_control(char *b=
uf, size_t len);
>  void tcp_get_allowed_congestion_control(char *buf, size_t len);
>  int tcp_set_allowed_congestion_control(char *allowed);
>  int tcp_set_congestion_control(struct sock *sk, const char *name);
> -void tcp_slow_start(struct tcp_sock *tp, u32 acked);
> +int tcp_slow_start(struct tcp_sock *tp, u32 acked);
>  void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
>
>  u32 tcp_reno_ssthresh(struct sock *sk);
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 63c29dba68a8..f0fc696b9333 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -360,13 +360,15 @@ int tcp_set_congestion_control(struct sock *sk,=
 const char *name)
>   * ABC caps N to 2. Slow start exits when cwnd grows over ssthresh a=
nd
>   * returns the leftover acks to adjust cwnd in congestion avoidance =
mode.
>   */
> -void tcp_slow_start(struct tcp_sock *tp, u32 acked)
> +int tcp_slow_start(struct tcp_sock *tp, u32 acked)
>  {
>         u32 cwnd =3D tp->snd_cwnd + acked;
>
>         if (cwnd > tp->snd_ssthresh)
>                 cwnd =3D tp->snd_ssthresh + 1;
> +       acked -=3D cwnd - tp->snd_cwnd;
>         tp->snd_cwnd =3D min(cwnd, tp->snd_cwnd_clamp);
> +       return acked;
>  }
>  EXPORT_SYMBOL_GPL(tcp_slow_start);
>
> diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
> index 6b6002416a73..c0e048929b74 100644
> --- a/net/ipv4/tcp_cubic.c
> +++ b/net/ipv4/tcp_cubic.c
> @@ -81,7 +81,6 @@ MODULE_PARM_DESC(hystart_ack_delta, "spacing betwee=
n ack's indicating train (mse
>
>  /* BIC TCP Parameters */
>  struct bictcp {
> -       u32     cnt;            /* increase cwnd by 1 after ACKs */
>         u32     last_max_cwnd;  /* last maximum snd_cwnd */
>         u32     loss_cwnd;      /* congestion window at last loss */
>         u32     last_cwnd;      /* the last snd_cwnd */
> @@ -93,20 +92,18 @@ struct bictcp {
>         u32     epoch_start;    /* beginning of an epoch */
>         u32     ack_cnt;        /* number of acks */
>         u32     tcp_cwnd;       /* estimated tcp cwnd */
> -#define ACK_RATIO_SHIFT        4
> -#define ACK_RATIO_LIMIT (32u << ACK_RATIO_SHIFT)
> -       u16     delayed_ack;    /* estimate the ratio of Packets/ACKs=
 << 4 */
>         u8      sample_cnt;     /* number of samples to decide curr_r=
tt */
>         u8      found;          /* the exit point is found? */
>         u32     round_start;    /* beginning of each round */
>         u32     end_seq;        /* end_seq of the round */
>         u32     last_ack;       /* last time when the ACK spacing is =
close */
>         u32     curr_rtt;       /* the minimum rtt of current round *=
/
> +       u32     last_bic_target;/* last target cwnd computed by cubic
> +                                * (not tcp_friendliness mode) */
>  };
>
>  static inline void bictcp_reset(struct bictcp *ca)
>  {
> -       ca->cnt =3D 0;
>         ca->last_max_cwnd =3D 0;
>         ca->last_cwnd =3D 0;
>         ca->last_time =3D 0;
> @@ -114,7 +111,6 @@ static inline void bictcp_reset(struct bictcp *ca=
)
>         ca->bic_K =3D 0;
>         ca->delay_min =3D 0;
>         ca->epoch_start =3D 0;
> -       ca->delayed_ack =3D 2 << ACK_RATIO_SHIFT;
>         ca->ack_cnt =3D 0;
>         ca->tcp_cwnd =3D 0;
>         ca->found =3D 0;
> @@ -205,12 +201,14 @@ static u32 cubic_root(u64 a)
>  /*
>   * Compute congestion window to use.
>   */
> -static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
> +static inline void bictcp_update(struct bictcp *ca, u32 pkts_acked, =
u32 cwnd)
>  {
> -       u32 delta, bic_target, max_cnt;
> +       u32 delta, bic_target;
>         u64 offs, t;
>
> -       ca->ack_cnt++;  /* count the number of ACKs */
> +       ca->ack_cnt +=3D pkts_acked;      /* count the number of pack=
ets that
> +                                        * have been ACKed
> +                                        */
>
>         if (ca->last_cwnd =3D=3D cwnd &&
>             (s32)(tcp_time_stamp - ca->last_time) <=3D HZ / 32)
> @@ -221,7 +219,7 @@ static inline void bictcp_update(struct bictcp *c=
a, u32 cwnd)
>
>         if (ca->epoch_start =3D=3D 0) {
>                 ca->epoch_start =3D tcp_time_stamp;       /* record b=
eginning */
> -               ca->ack_cnt =3D 1;                        /* start co=
unting */
> +               ca->ack_cnt =3D pkts_acked;               /* start co=
unting */
>                 ca->tcp_cwnd =3D cwnd;                    /* syn with=
 cubic */
>
>                 if (ca->last_max_cwnd <=3D cwnd) {
> @@ -269,19 +267,7 @@ static inline void bictcp_update(struct bictcp *=
ca, u32 cwnd)
>         else                                          /* above origin=
*/
>                 bic_target =3D ca->bic_origin_point + delta;
>
> -       /* cubic function - calc bictcp_cnt*/
> -       if (bic_target > cwnd) {
> -               ca->cnt =3D cwnd / (bic_target - cwnd);
> -       } else {
> -               ca->cnt =3D 100 * cwnd;              /* very small in=
crement*/
> -       }
> -
> -       /*
> -        * The initial growth of cubic function may be too conservati=
ve
> -        * when the available bandwidth is still unknown.
> -        */
> -       if (ca->last_max_cwnd =3D=3D 0 && ca->cnt > 20)
> -               ca->cnt =3D 20;   /* increase cwnd 5% per RTT */
> +       ca->last_bic_target =3D bic_target;
>
>         /* TCP Friendly */
>         if (tcp_friendliness) {
> @@ -292,18 +278,7 @@ static inline void bictcp_update(struct bictcp *=
ca, u32 cwnd)
>                         ca->ack_cnt -=3D delta;
>                         ca->tcp_cwnd++;
>                 }
> -
> -               if (ca->tcp_cwnd > cwnd) {      /* if bic is slower t=
han tcp */
> -                       delta =3D ca->tcp_cwnd - cwnd;
> -                       max_cnt =3D cwnd / delta;
> -                       if (ca->cnt > max_cnt)
> -                               ca->cnt =3D max_cnt;
> -               }
>         }
> -
> -       ca->cnt =3D (ca->cnt << ACK_RATIO_SHIFT) / ca->delayed_ack;
> -       if (ca->cnt =3D=3D 0)                       /* cannot be zero=
 */
> -               ca->cnt =3D 1;
>  }
>
>  static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
> @@ -314,13 +289,43 @@ static void bictcp_cong_avoid(struct sock *sk, =
u32 ack, u32 acked)
>         if (!tcp_is_cwnd_limited(sk))
>                 return;
>
> +       /* cwnd may first advance in slow start then move on to conge=
stion
> +        * control mode on a stretch ACK.
> +        */
>         if (tp->snd_cwnd <=3D tp->snd_ssthresh) {
>                 if (hystart && after(ack, ca->end_seq))
>                         bictcp_hystart_reset(sk);
> -               tcp_slow_start(tp, acked);
> -       } else {
> -               bictcp_update(ca, tp->snd_cwnd);
> -               tcp_cong_avoid_ai(tp, ca->cnt);
> +               acked =3D tcp_slow_start(tp, acked);
> +       }
> +
> +       if (acked && tp->snd_cwnd > tp->snd_ssthresh) {
> +               u32 target, cnt;
> +
> +               bictcp_update(ca, acked, tp->snd_cwnd);
> +               /* Compute target cwnd based on bic_target and tcp_cw=
nd
> +                * (whichever is faster)
> +                */
> +               target =3D (ca->last_bic_target >=3D ca->tcp_cwnd) ?
> +                               ca->last_bic_target : ca->tcp_cwnd;
> +               while (acked > 0) {
> +                       if (target > tp->snd_cwnd)
> +                               cnt =3D tp->snd_cwnd / (target - tp->=
snd_cwnd);
> +                       else
> +                               cnt =3D 100 * tp->snd_cwnd;
> +
> +                       /* The initial growth of cubic function may b=
e
> +                        * too conservative when the available
> +                        * bandwidth is still unknown.
> +                        */
> +                       if (ca->last_max_cwnd =3D=3D 0 && cnt > 20)
> +                               cnt =3D 20;   /* increase cwnd 5% per=
 RTT */
> +
> +                       if (cnt =3D=3D 0)           /* cannot be zero=
 */
> +                               cnt =3D 1;
> +
> +                       tcp_cong_avoid_ai(tp, cnt);
> +                       acked--;
> +               }
>         }
>  }
>
> @@ -411,20 +416,10 @@ static void hystart_update(struct sock *sk, u32=
 delay)
>   */
>  static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
>  {
> -       const struct inet_connection_sock *icsk =3D inet_csk(sk);
>         const struct tcp_sock *tp =3D tcp_sk(sk);
>         struct bictcp *ca =3D inet_csk_ca(sk);
>         u32 delay;
>
> -       if (icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
> -               u32 ratio =3D ca->delayed_ack;
> -
> -               ratio -=3D ca->delayed_ack >> ACK_RATIO_SHIFT;
> -               ratio +=3D cnt;
> -
> -               ca->delayed_ack =3D clamp(ratio, 1U, ACK_RATIO_LIMIT)=
;
> -       }
> -
>         /* Some calls are for duplicates without timetamps */
>         if (rtt_us < 0)
>                 return;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
