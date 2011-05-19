From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: Lower the initial RTO to 1s as per draft RFC 2988bis-02.
Date: Thu, 19 May 2011 10:42:19 -0700
Message-ID: <BANLkTinzF1LrvR_3Q5b02CFd6nLWqGgERg@mail.gmail.com>
References: <20110519.014656.1735519603194773578.davem@davemloft.net> <1305786976-84532-1-git-send-email-tsunanet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benoit Sigoure <tsuna@stumbleupon.com>,
	Hsiao-keng Jerry Chu <hkchu@google.com>
To: Benoit Sigoure <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305786976-84532-1-git-send-email-tsunanet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Benoit,

AFAICT, the passive open side would not fall back the
RTO to 3sec in this change because SYNACK timeouts are not
recorded in icsk_retransmits but reqsk->retrans?

Yuchung

On Wed, May 18, 2011 at 11:36 PM, Benoit Sigoure <tsunanet@gmail.com> w=
rote:
>
> From: Benoit Sigoure <tsuna@stumbleupon.com>
>
> Draft RFC 2988bis-02 recommends that the initial RTO be lowered
> from 3 seconds down to 1 second, and that in case of a timeout
> during the TCP 3WHS, the RTO should fallback to 3 seconds when
> data transmission begins.
> ---
>
> On Wed, May 18, 2011 at 10:46 PM, David Miller <davem@davemloft.net> =
wrote:
> > From: tsuna <tsunanet@gmail.com>
> > Date: Wed, 18 May 2011 21:33:21 -0700
> >
> >> On Wed, May 18, 2011 at 9:14 PM, David Miller <davem@davemloft.net=
> wrote:
> >>> I really would rather see the initial RTO be static and be set to=
 1
> >>> with fallback RTO of 3.
> >>
> >> I can also provide a simple patch for this if you want to start fr=
om
> >> there. =A0And then maybe we can discuss having a runtime knob some=
 more
> >> :-)
> >
> > Yeah why don't we do that :-)
>
> Alright, here we go.
>
>
> =A0include/net/tcp.h =A0 =A0| =A0 =A05 ++++-
> =A0net/ipv4/tcp_input.c | =A0 13 +++++++++----
> =A02 files changed, 13 insertions(+), 5 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index cda30ea..274d761 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -122,7 +122,10 @@ extern void tcp_time_wait(struct sock *sk, int s=
tate, int timeo);
> =A0#endif
> =A0#define TCP_RTO_MAX =A0 =A0((unsigned)(120*HZ))
> =A0#define TCP_RTO_MIN =A0 =A0((unsigned)(HZ/5))
> -#define TCP_TIMEOUT_INIT ((unsigned)(3*HZ)) =A0 =A0/* RFC 1122 initi=
al RTO value =A0 */
> +/* The next 2 values come from Draft RFC 2988bis-02. */
> +#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ)) =A0 =A0 =A0 =A0 =A0 =A0/=
* initial RTO value =A0 =A0*/
> +#define TCP_TIMEOUT_INIT_FALLBACK ((unsigned)(3*HZ)) =A0 /* initial =
RTO to fallback to when
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* a timeout happens during =
the 3WHS. =A0 */
>
> =A0#define TCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ/2U)) /* Maximal=
 interval between probes
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * for local resources.
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index bef9f04..a36bc35 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -868,6 +868,11 @@ static void tcp_init_metrics(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> =A0 =A0 =A0 =A0struct dst_entry *dst =3D __sk_dst_get(sk);
> + =A0 =A0 =A0 /* If we had to retransmit anything during the 3WHS, us=
e
> + =A0 =A0 =A0 =A0* the initial fallback RTO as per draft RFC 2988bis-=
02.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int init_rto =3D inet_csk(sk)->icsk_retransmits ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 TCP_TIMEOUT_INIT_FALLBACK : TCP_TIMEOUT=
_INIT;
>
> =A0 =A0 =A0 =A0if (dst =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto reset;
> @@ -890,7 +895,7 @@ static void tcp_init_metrics(struct sock *sk)
> =A0 =A0 =A0 =A0if (dst_metric(dst, RTAX_RTT) =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto reset;
>
> - =A0 =A0 =A0 if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_T=
IMEOUT_INIT << 3))
> + =A0 =A0 =A0 if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (init_=
rto << 3))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto reset;
>
> =A0 =A0 =A0 =A0/* Initial rtt is determined from SYN,SYN-ACK.
> @@ -916,7 +921,7 @@ static void tcp_init_metrics(struct sock *sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->mdev_max =3D tp->rttvar =3D max(tp=
->mdev, tcp_rto_min(sk));
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0tcp_set_rto(sk);
> - =A0 =A0 =A0 if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->r=
x_opt.saw_tstamp) {
> + =A0 =A0 =A0 if (inet_csk(sk)->icsk_rto < init_rto && !tp->rx_opt.sa=
w_tstamp) {
> =A0reset:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Play conservative. If timestamps ar=
e not
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * supported, TCP will fail to recalcu=
late correct
> @@ -924,8 +929,8 @@ reset:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!tp->rx_opt.saw_tstamp && tp->srtt=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->srtt =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->mdev =3D tp->mdev_m=
ax =3D tp->rttvar =3D TCP_TIMEOUT_INIT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto =
=3D TCP_TIMEOUT_INIT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->mdev =3D tp->mdev_m=
ax =3D tp->rttvar =3D init_rto;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto =
=3D init_rto;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
