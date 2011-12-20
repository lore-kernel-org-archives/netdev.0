From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Mon, 19 Dec 2011 19:54:45 -0800
Message-ID: <CAGK4HS-koLoZ5r270mau1t0vVeSr--ZKDHBoDFuuyGVkW+BTTA@mail.gmail.com>
References: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, "H.K. Jerry Chu" <hkchu@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:64936 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003Ab1LTDyp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 22:54:45 -0500
Received: by vcbfk14 with SMTP id fk14so4584737vcb.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 19:54:45 -0800 (PST)
In-Reply-To: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 December 2011 19:32, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> =A0 =A0to record the state of SACK/FACK and DSACK for better readabil=
ity and maintenance.
>
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> =A0include/linux/tcp.h =A0 | =A0 =A05 +++++
> =A0include/net/tcp.h =A0 =A0 | =A0 =A04 ++--
> =A0net/ipv4/syncookies.c | =A0 =A02 +-
> =A0net/ipv4/tcp_input.c =A0| =A0 =A06 +++---
> =A04 files changed, 11 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7f59ee9..874b043 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -238,6 +238,11 @@ struct tcp_sack_block {
> =A0 =A0 =A0 =A0u32 =A0 =A0 end_seq;
> =A0};
>
> +/*These are used to set the sack_ok field in struct tcp_options_rece=
ived */
> +#define SACK_SEEN =A0 =A0 (1 << 0) =A0 /*1 =3D peer is SACK capable,=
 */
> +#define FACK_ENABLED =A0(1 << 1) =A0 /*1 =3D FACK is enabled locally=
*/
> +#define DSACK_SEEN =A0 =A0(1 << 2) =A0 /*1 =3D DSACK was received fr=
om peer*/
> +
> =A0struct tcp_options_received {
> =A0/* =A0 =A0 PAWS/RTTM data =A0*/
> =A0 =A0 =A0 =A0long =A0 =A0ts_recent_stamp;/* Time we stored ts_recen=
t (for aging) */
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index a4f52e1..cbb943e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -773,12 +773,12 @@ static inline int tcp_is_reno(const struct tcp_=
sock *tp)
>
> =A0static inline int tcp_is_fack(const struct tcp_sock *tp)
> =A0{
> - =A0 =A0 =A0 return tp->rx_opt.sack_ok & 2;
> + =A0 =A0 =A0 return tp->rx_opt.sack_ok & FACK_ENABLED;
> =A0}
>
> =A0static inline void tcp_enable_fack(struct tcp_sock *tp)
> =A0{
> - =A0 =A0 =A0 tp->rx_opt.sack_ok |=3D 2;
> + =A0 =A0 =A0 tp->rx_opt.sack_ok |=3D FACK_ENABLED;
> =A0}
>
> =A0static inline unsigned int tcp_left_out(const struct tcp_sock *tp)
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index 90f6544..dfba6a5 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -245,7 +245,7 @@ bool cookie_check_timestamp(struct tcp_options_re=
ceived *tcp_opt, bool *ecn_ok)
> =A0 =A0 =A0 =A0if (!sysctl_tcp_timestamps)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> - =A0 =A0 =A0 tcp_opt->sack_ok =3D (options >> 4) & 0x1;
> + =A0 =A0 =A0 tcp_opt->sack_ok =3D (options >> 4) & SACK_SEEN;
> =A0 =A0 =A0 =A0*ecn_ok =3D (options >> 5) & 1;
> =A0 =A0 =A0 =A0if (*ecn_ok && !sysctl_tcp_ecn)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index f131d92..5cbc788 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -865,13 +865,13 @@ static void tcp_disable_fack(struct tcp_sock *t=
p)
> =A0 =A0 =A0 =A0/* RFC3517 uses different metric in lost marker =3D> r=
eset on change */
> =A0 =A0 =A0 =A0if (tcp_is_fack(tp))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->lost_skb_hint =3D NULL;
> - =A0 =A0 =A0 tp->rx_opt.sack_ok &=3D ~2;
> + =A0 =A0 =A0 tp->rx_opt.sack_ok &=3D ~FACK_ENABLED;
> =A0}
>
> =A0/* Take a notice that peer is sending D-SACKs */
> =A0static void tcp_dsack_seen(struct tcp_sock *tp)
> =A0{
> - =A0 =A0 =A0 tp->rx_opt.sack_ok |=3D 4;
> + =A0 =A0 =A0 tp->rx_opt.sack_ok |=3D DSACK_SEEN;
> =A0}
>
> =A0/* Initialize metrics on socket. */
> @@ -3878,7 +3878,7 @@ void tcp_parse_options(const struct sk_buff *sk=
b, struct tcp_options_received *o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case TCPOPT_SACK_PERM:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (op=
size =3D=3D TCPOLEN_SACK_PERM && th->syn &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
!estab && sysctl_tcp_sack) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 opt_rx->sack_ok =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 opt_rx->sack_ok =3D SACK_SEEN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0tcp_sack_reset(opt_rx);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> --
> 1.7.0.4
>

This patch was created against net-next tree and not -net tree.
Apologies for the error. Should I resend it?

Regards,
Vijay
