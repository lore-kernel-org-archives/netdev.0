From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] net: TCP thin linear timeouts
Date: Fri, 12 Feb 2010 04:52:13 +0100
Message-ID: <1265946733.2891.10.camel@edumazet-laptop>
References: <4B73F30D.6040205@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B73F30D.6040205@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 11 f=C3=A9vrier 2010 =C3=A0 13:07 +0100, Andreas Petlund a =C3=
=A9crit :
> Major changes:
>       -Possible to disable mechanisms by socket option
>       -Socket option value boundary check
>=20
>=20
> Signed-off-by: Andreas Petlund <apetlund@simula.no>
> ---
>  include/linux/sysctl.h     |    1 +
>  include/linux/tcp.h        |    3 +++
>  include/net/tcp.h          |    4 ++++
>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>  net/ipv4/tcp.c             |    7 +++++++
>  net/ipv4/tcp_timer.c       |   19 ++++++++++++++++++-
>  6 files changed, 40 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 9f236cd..d840d75 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -425,6 +425,7 @@ enum
>  	NET_TCP_ALLOWED_CONG_CONTROL=3D123,
>  	NET_TCP_MAX_SSTHRESH=3D124,
>  	NET_TCP_FRTO_RESPONSE=3D125,
> +	NET_TCP_FORCE_THIN_LINEAR_TIMEOUTS=3D126,
>  };
> =20
>  enum {
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7fee8a4..67da706 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -103,6 +103,7 @@ enum {
>  #define TCP_CONGESTION		13	/* Congestion control algorithm */
>  #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
>  #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
> +#define TCP_THIN_LT             16      /* Use linear timeouts for t=
hin streams*/
> =20
>  /* for TCP_INFO socket option */
>  #define TCPI_OPT_TIMESTAMPS	1
> @@ -341,6 +342,8 @@ struct tcp_sock {
>  	u16	advmss;		/* Advertised MSS			*/
>  	u8	frto_counter;	/* Number of new acks after RTO */
>  	u8	nonagle;	/* Disable Nagle algorithm?             */
> +	u8      thin_lt     : 1,/* Use linear timeouts for thin streams */
> +		thin_undef  : 7;
> =20
>  /* RTT measurement */
>  	u32	srtt;		/* smoothed round trip time << 3	*/
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index e5e2056..bc5856a 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -196,6 +196,9 @@ extern void tcp_time_wait(struct sock *sk, int st=
ate, int timeo);
>  #define TCP_NAGLE_CORK		2	/* Socket is corked	    */
>  #define TCP_NAGLE_PUSH		4	/* Cork is overridden for already queued d=
ata */
> =20
> +/* TCP thin-stream limits */
> +#define TCP_THIN_LT_RETRIES     6       /* After 6 linear retries, d=
o exp. backoff */
> +
>  extern struct inet_timewait_death_row tcp_death_row;
> =20
>  /* sysctl variables for tcp */
> @@ -241,6 +244,7 @@ extern int sysctl_tcp_workaround_signed_windows;
>  extern int sysctl_tcp_slow_start_after_idle;
>  extern int sysctl_tcp_max_ssthresh;
>  extern int sysctl_tcp_cookie_size;
> +extern int sysctl_tcp_force_thin_linear_timeouts;
> =20
>  extern atomic_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 7e3712c..cb2ed35 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -576,6 +576,13 @@ static struct ctl_table ipv4_table[] =3D {
>  		.proc_handler	=3D proc_dointvec
>  	},
>  	{
> +		.procname       =3D "tcp_force_thin_linear_timeouts",
> +		.data           =3D &sysctl_tcp_force_thin_linear_timeouts,
> +		.maxlen         =3D sizeof(int),
> +		.mode           =3D 0644,
> +		.proc_handler   =3D proc_dointvec
> +	},
> +	{
>  		.procname	=3D "udp_mem",
>  		.data		=3D &sysctl_udp_mem,
>  		.maxlen		=3D sizeof(sysctl_udp_mem),
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index d5d69ea..ce9aeb0 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2229,6 +2229,13 @@ static int do_tcp_setsockopt(struct sock *sk, =
int level,
>  		}
>  		break;
> =20
> +	case TCP_THIN_LT:
> +		if (val < 0 || val > 1)
> +			err =3D -EINVAL;
> +		else
> +			tp->thin_lt =3D val;
> +		break;
> +
>  	case TCP_CORK:
>  		/* When set indicates to always queue non-full frames.
>  		 * Later the user clears this option and we transmit
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index de7d1bf..a682479 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -29,6 +29,7 @@ int sysctl_tcp_keepalive_intvl __read_mostly =3D TC=
P_KEEPALIVE_INTVL;
>  int sysctl_tcp_retries1 __read_mostly =3D TCP_RETR1;
>  int sysctl_tcp_retries2 __read_mostly =3D TCP_RETR2;
>  int sysctl_tcp_orphan_retries __read_mostly;
> +int sysctl_tcp_force_thin_linear_timeouts __read_mostly;
> =20
>  static void tcp_write_timer(unsigned long);
>  static void tcp_delack_timer(unsigned long);
> @@ -415,7 +416,23 @@ void tcp_retransmit_timer(struct sock *sk)
>  	icsk->icsk_retransmits++;
> =20
>  out_reset_timer:
> -	icsk->icsk_rto =3D min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> +	/* If stream is thin, use linear timeouts. Since 'icsk_backoff' is
> +	 * used to reset timer, set to 0. Recalculate 'icsk_rto' as this
> +	 * might be increased if the stream oscillates between thin and thi=
ck,
> +	 * thus the old value might already be too high compared to the val=
ue
> +	 * set by 'tcp_set_rto' in tcp_input.c which resets the rto without
> +	 * backoff. Limit to TCP_THIN_LT_RETRIES before initiating exponent=
ial
> +	 * backoff behaviour to avoid continue hammering linear-timeout
> +	 * retransmissions into a black hole*/
> +	if ((tp->thin_lt || sysctl_tcp_force_thin_linear_timeouts) &&
> +	    tcp_stream_is_thin(sk) && sk->sk_state =3D=3D TCP_ESTABLISHED &=
&
> +	    icsk->icsk_retransmits <=3D TCP_THIN_LT_RETRIES) {
> +		icsk->icsk_backoff =3D 0;
> +		icsk->icsk_rto =3D min(__tcp_set_rto(tp), TCP_RTO_MAX);
> +	} else {
> +		/* Use normal (exponential) backoff */
> +		icsk->icsk_rto =3D min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> +	}
>  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TC=
P_RTO_MAX);
>  	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
>  		__sk_dst_reset(sk);

Hi Anreas

Could you include a section in Documentation/networking/ip-sysctl.txt
about tcp_force_thin_linear_timeouts setting ?

Also, you should provide some documentation to be included in man pages
(man 7 tcp), to Michael Kerrisk ( <mtk.manpages@gmail.com> ), both for
tcp_force_thin_linear_timeouts and TCP_THIN_LT

(Same applies for patch 3/3 and tcp_force_thin_dupack /
TCP_THIN_DUPACK )
