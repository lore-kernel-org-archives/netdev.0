From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Wed, 19 Feb 2014 18:17:12 +0100
Message-ID: <50334B08-CD60-4C4C-9556-ACC758F75D7E@simula.no>
References: <20140218181205.GA7780@kau.se>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	=?windows-1252?Q?Anna_Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Michael Welzl <michawe@ifi.uio.no>, ilpo.jarvinen@helsinki.fi
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward4.uio.no ([129.240.10.33]:37871 "EHLO
	mail-forward4.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968AbaBSRkI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 12:40:08 -0500
Received: from exim by mail-out4.uio.no with local-bsmtp (Exim 4.80.1)
	(envelope-from <apetlund@simula.no>)
	id 1WGAln-0004wW-Lr
	for netdev@vger.kernel.org; Wed, 19 Feb 2014 18:17:15 +0100
In-Reply-To: <20140218181205.GA7780@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I=92ve applied and tested the patch on VMs with both 32 bit and 64 bit =
kernel.

Acked-by: Andreas Petlund <apetlund@simula.no>
Tested-by: Andreas Petlund <apetlund@simula.no>

Best regards,
Andreas Petlund

On 18 Feb 2014, at 19:12, Per Hurtig <per.hurtig@kau.se> wrote:

> This patch implements the RTO restart modification described in
> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>=20
> RTO Restart's goal is to provide quicker loss recovery for segments l=
ost in the
> end of a burst/connection. To accomplish this the algorithm adjusts t=
he RTO
> value on each rearm of the retransmission timer to be exactly RTO ms =
after the
> earliest outstanding segment was sent. The offsetting against the ear=
liest
> outstanding segment is not done by the regular rearm algorithm, which=
 causes
> RTOs to occur, on average, after RTO+RTT ms.
>=20
> As a faster timeout is only beneficial in scenarios where fast retran=
smit/early
> retransmit cannot be triggered the algorithm will only kick in when t=
here is a
> small amount of outstanding segments.
>=20
> The RTO Restart proposal is accepted as a working group item in the I=
ETF TCP
> Maintenance and Minor Extensions (tcpm) TCP wg and is intended for ex=
perimental
> RFC status.
>=20
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
> include/net/tcp.h          |    1 +
> net/ipv4/sysctl_net_ipv4.c |    7 +++++++
> net/ipv4/tcp_input.c       |   11 +++++++++++
> 3 files changed, 19 insertions(+)
>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 56fc366..575e82a 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle;
> extern int sysctl_tcp_thin_linear_timeouts;
> extern int sysctl_tcp_thin_dupack;
> extern int sysctl_tcp_early_retrans;
> +extern int sysctl_tcp_rto_restart;
> extern int sysctl_tcp_limit_output_bytes;
> extern int sysctl_tcp_challenge_ack_limit;
> extern unsigned int sysctl_tcp_notsent_lowat;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 44eba05..c605f4f 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] =3D {
> 		.extra2		=3D &four,
> 	},
> 	{
> +		.procname	=3D "tcp_rto_restart",
> +		.data		=3D &sysctl_tcp_rto_restart,
> +		.maxlen		=3D sizeof(int),
> +		.mode		=3D 0644,
> +		.proc_handler	=3D proc_dointvec,
> +	},
> +	{
> 		.procname	=3D "tcp_min_tso_segs",
> 		.data		=3D &sysctl_tcp_min_tso_segs,
> 		.maxlen		=3D sizeof(int),
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 227cba7..450ee30 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>=20
> int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
> int sysctl_tcp_early_retrans __read_mostly =3D 3;
> +int sysctl_tcp_rto_restart __read_mostly =3D 1;
>=20
> #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
> #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
> 			 */
> 			if (delta > 0)
> 				rto =3D delta;
> +		} else if (icsk->icsk_pending =3D=3D ICSK_TIME_RETRANS &&
> +			   sysctl_tcp_rto_restart &&
> +			   sk->sk_send_head =3D=3D NULL &&
> +			   tp->packets_out < 4) {
> +			struct sk_buff *skb =3D tcp_write_queue_head(sk);
> +			const u32 rto_time_stamp =3D TCP_SKB_CB(skb)->when;
> +			s32 delta =3D (s32)(tcp_time_stamp - rto_time_stamp);
> +
> +			if (delta > 0)
> +				rto -=3D delta;
> 		}
> 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
> 					  TCP_RTO_MAX);
> --=20
> 1.7.9.5
>=20
