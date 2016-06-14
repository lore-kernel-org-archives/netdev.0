From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v2] tcp: use RFC6298 compliant TCP RTO calculation
Date: Tue, 14 Jun 2016 14:33:18 -0700
Message-ID: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
References: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
 <20160614191841.21496-1-dmetz@mytum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Metz <daniel.metz@rohde-schwarz.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Metz <dmetz@mytum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:34999 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcFNVd7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:33:59 -0400
Received: by mail-it0-f42.google.com with SMTP id z189so89382329itg.0
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 14:33:59 -0700 (PDT)
In-Reply-To: <20160614191841.21496-1-dmetz@mytum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 12:18 PM, Daniel Metz <dmetz@mytum.de> wrote:
> From: Daniel Metz <daniel.metz@rohde-schwarz.com>
>
> This patch adjusts Linux RTO calculation to be RFC6298 Standard
> compliant. MinRTO is no longer added to the computed RTO, RTO damping
> and overestimation are decreased.
>
> In RFC 6298 Standard TCP Retransmission Timeout (RTO) calculation the
> calculated RTO is rounded up to the Minimum RTO (MinRTO), if it is
> less.  The Linux implementation as a discrepancy to the Standard
> basically adds the defined MinRTO to the calculated RTO. When
> comparing both approaches, the Linux calculation seems to perform
> worse for sender limited TCP flows like Telnet, SSH or constant bit
> rate encoded transmissions, especially for Round Trip Times (RTT) of
> 50ms to 800ms.
>
> Compared to the Linux implementation the RFC 6298 proposed RTO
> calculation performs better and more precise in adapting to current
> network characteristics. Extensive measurements for bulk data did not
> show a negative impact of the adjusted calculation.
>
> Exemplary performance comparison for sender-limited-flows:
>
> - Rate: 10Mbit/s
> - Delay: 200ms, Delay Variation: 10ms
> - Time between each scheduled segment: 1s
> - Amount Data Segments: 300
> - Mean of 11 runs
>
>          Mean Response Waiting Time [milliseconds]
>
> PER [%] |   0.5      1    1.5      2      3      5      7     10
> --------+-------------------------------------------------------
> old     | 206.4  208.6  218.0  218.6  227.2  249.3  274.7  308.2
> new     | 203.9  206.0  207.0  209.9  217.3  225.6  238.7  259.1
>
>
> Detailed analysis:
> https://docs.google.com/document/d/1pKmPfnQb6fDK4qpiNVkN8cQyGE4wYDZuk=
cuZfR-BnnM/
>
> Reasoning for historic design:
> Sarolahti, P.; Kuznetsov, A. (2002). Congestion Control in Linux TCP.
> Conference Paper. Proceedings of the FREENIX Track. 2002 USENIX Annua=
l
> https://www.cs.helsinki.fi/research/iwtcp/papers/linuxtcp.pdf
>
>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Signed-off-by: Daniel Metz <dmetz@mytum.de>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>
> v2:
>  - Using the RFC 6298 compliant implementation, the tcp_sock struct v=
ariable
>          u32 mdev_max_us becomes obsolete and consequently is being r=
emoved.
>  - Add reference to Kuznetsov paper
>
>
>  include/linux/tcp.h    |  1 -
>  net/ipv4/tcp_input.c   | 74 ++++++++++++----------------------------=
----------
>  net/ipv4/tcp_metrics.c |  2 +-
>  3 files changed, 18 insertions(+), 59 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7be9b12..d1790c5 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -231,7 +231,6 @@ struct tcp_sock {
>  /* RTT measurement */
>         u32     srtt_us;        /* smoothed round trip time << 3 in u=
secs */
>         u32     mdev_us;        /* medium deviation                  =
   */
> -       u32     mdev_max_us;    /* maximal mdev for the last rtt peri=
od */
>         u32     rttvar_us;      /* smoothed mdev_max                 =
   */
>         u32     rtt_seq;        /* sequence number to update rttvar  =
   */
>         struct rtt_meas {
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 94d4aff..0d53537 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -680,8 +680,7 @@ static void tcp_event_data_recv(struct sock *sk, =
struct sk_buff *skb)
>  /* Called to compute a smoothed rtt estimate. The data fed to this
>   * routine either comes from timestamps, or from segments that were
>   * known _not_ to have been retransmitted [see Karn/Partridge
> - * Proceedings SIGCOMM 87]. The algorithm is from the SIGCOMM 88
> - * piece by Van Jacobson.
> + * Proceedings SIGCOMM 87].
>   * NOTE: the next three routines used to be one big routine.
>   * To save cycles in the RFC 1323 implementation it was better to br=
eak
>   * it up into three procedures. -- erics
> @@ -692,59 +691,21 @@ static void tcp_rtt_estimator(struct sock *sk, =
long mrtt_us)
>         long m =3D mrtt_us; /* RTT */
>         u32 srtt =3D tp->srtt_us;
>
> -       /*      The following amusing code comes from Jacobson's
> -        *      article in SIGCOMM '88.  Note that rtt and mdev
> -        *      are scaled versions of rtt and mean deviation.
> -        *      This is designed to be as fast as possible
> -        *      m stands for "measurement".
> -        *
> -        *      On a 1990 paper the rto value is changed to:
> -        *      RTO =3D rtt + 4 * mdev
> -        *
> -        * Funny. This algorithm seems to be very broken.
> -        * These formulae increase RTO, when it should be decreased, =
increase
> -        * too slowly, when it should be increased quickly, decrease =
too quickly
> -        * etc. I guess in BSD RTO takes ONE value, so that it is abs=
olutely
> -        * does not matter how to _calculate_ it. Seems, it was trap
> -        * that VJ failed to avoid. 8)
> -        */
>         if (srtt !=3D 0) {
> -               m -=3D (srtt >> 3);       /* m is now error in rtt es=
t */
> -               srtt +=3D m;              /* rtt =3D 7/8 rtt + 1/8 ne=
w */
> -               if (m < 0) {
> -                       m =3D -m;         /* m is now abs(error) */
> -                       m -=3D (tp->mdev_us >> 2);   /* similar updat=
e on mdev */
> -                       /* This is similar to one of Eifel findings.
> -                        * Eifel blocks mdev updates when rtt decreas=
es.
> -                        * This solution is a bit different: we use f=
iner gain
> -                        * for mdev in this case (alpha*beta).
> -                        * Like Eifel it also prevents growth of rto,
> -                        * but also it limits too fast rto decreases,
> -                        * happening in pure Eifel.
> -                        */
> -                       if (m > 0)
> -                               m >>=3D 3;
> -               } else {
> -                       m -=3D (tp->mdev_us >> 2);   /* similar updat=
e on mdev */
> -               }
> -               tp->mdev_us +=3D m;               /* mdev =3D 3/4 mde=
v + 1/4 new */
> -               if (tp->mdev_us > tp->mdev_max_us) {
> -                       tp->mdev_max_us =3D tp->mdev_us;
> -                       if (tp->mdev_max_us > tp->rttvar_us)
> -                               tp->rttvar_us =3D tp->mdev_max_us;
> -               }
> -               if (after(tp->snd_una, tp->rtt_seq)) {
> -                       if (tp->mdev_max_us < tp->rttvar_us)
> -                               tp->rttvar_us -=3D (tp->rttvar_us - t=
p->mdev_max_us) >> 2;
> +               m -=3D (srtt >> 3);        /* m' =3D m - srtt / 8 =3D=
 (R' - SRTT) */
> +               srtt +=3D m;      /* srtt =3D srtt + m=E2=80=99 =3D s=
rtt + m - srtt / 8 */
> +               if (m < 0)
> +                       m =3D -m;
> +               m -=3D (tp->mdev_us >> 2); /* m'' =3D |m'| - mdev / 4=
 */
> +               tp->mdev_us +=3D m;
> +               tp->rttvar_us =3D tp->mdev_us;
> +               if (after(tp->snd_una, tp->rtt_seq))
>                         tp->rtt_seq =3D tp->snd_nxt;
> -                       tp->mdev_max_us =3D tcp_rto_min_us(sk);
> -               }
>         } else {
>                 /* no previous measure. */
> -               srtt =3D m << 3;          /* take the measured time t=
o be rtt */
> -               tp->mdev_us =3D m << 1;   /* make sure rto =3D 3*rtt =
*/
> -               tp->rttvar_us =3D max(tp->mdev_us, tcp_rto_min_us(sk)=
);
> -               tp->mdev_max_us =3D tp->rttvar_us;
> +               srtt =3D m << 3;
> +               tp->mdev_us =3D m << 1;
> +               tp->rttvar_us =3D tp->mdev_us;
AFAICT we can update rttvar_us directly and don't need mdev_us anymore?

>                 tp->rtt_seq =3D tp->snd_nxt;
>         }
>         tp->srtt_us =3D max(1U, srtt);
> @@ -798,6 +759,7 @@ static void tcp_update_pacing_rate(struct sock *s=
k)
>   */
>  static void tcp_set_rto(struct sock *sk)
>  {
> +       const u32 min_rto =3D tcp_rto_min_us(sk);
>         const struct tcp_sock *tp =3D tcp_sk(sk);
>         /* Old crap is replaced with new one. 8)
>          *
> @@ -809,17 +771,15 @@ static void tcp_set_rto(struct sock *sk)
>          *    is invisible. Actually, Linux-2.4 also generates errati=
c
>          *    ACKs in some circumstances.
>          */
> -       inet_csk(sk)->icsk_rto =3D __tcp_set_rto(tp);
> -
> +       if (((tp->srtt_us >> 3) + tp->rttvar_us) < min_rto)
> +               inet_csk(sk)->icsk_rto =3D usecs_to_jiffies(min_rto);
> +       else
> +               inet_csk(sk)->icsk_rto =3D __tcp_set_rto(tp);

This is more aggressive than  RFC6298 that RTO <- SRTT + max (G,
K*RTTVAR) where G =3D MIN_RTO =3D 200ms

based on our discussion, in the spirit of keeping RTO more
conservative, I recommend we implement RFC formula. Acks being delayed
over 200ms is not uncommon (unfortunately due to bloat or other
issues).

Also I think we should change __tcp_set_rto so that the formula
applies to backoffs or ICMP timeouts calculations too.

>         /* 2. Fixups made earlier cannot be right.
>          *    If we do not estimate RTO correctly without them,
>          *    all the algo is pure shit and should be replaced
>          *    with correct one. It is exactly, which we pretend to do=
=2E
>          */
> -
> -       /* NOTE: clamping at TCP_RTO_MIN is not required, current alg=
o
> -        * guarantees that rto is higher.
> -        */
>         tcp_bound_rto(sk);
>  }
>
> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index b617826..7f59f5b 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -561,7 +561,7 @@ reset:
>                  * retransmission.
>                  */
>                 tp->rttvar_us =3D jiffies_to_usecs(TCP_TIMEOUT_FALLBA=
CK);
> -               tp->mdev_us =3D tp->mdev_max_us =3D tp->rttvar_us;
> +               tp->mdev_us =3D tp->rttvar_us;
>
>                 inet_csk(sk)->icsk_rto =3D TCP_TIMEOUT_FALLBACK;
>         }
> --
> 2.8.3
>
