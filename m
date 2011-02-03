From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Wed, 2 Feb 2011 18:25:06 -0800
Message-ID: <AANLkTimNOaE+4e7V-ueXueBDGf99METSMzj38WNoy8Tu@mail.gmail.com>
References: <20110202.170750.229739784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21223 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab1BCCZL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 21:25:11 -0500
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p132PAb9024242
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 18:25:10 -0800
Received: from ywc21 (ywc21.prod.google.com [10.192.3.21])
	by kpbe19.cbf.corp.google.com with ESMTP id p132P8k4001966
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 18:25:08 -0800
Received: by ywc21 with SMTP id 21so316787ywc.21
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 18:25:08 -0800 (PST)
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Nandita Dukkipati <nanditad@google.com>

On Wed, Feb 2, 2011 at 5:07 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> I've left the DCCP code to keep using RFC3390 logic, if they
> wish to adopt this change in their code they can do so by
> simply deleting the rfc33390_bytes_to_packets() function and
> using TCP_INIT_CWND in their assignment.
>
> =A0include/net/tcp.h =A0 =A0 =A0| =A0 12 +++---------
> =A0net/dccp/ccids/ccid2.c | =A0 =A09 +++++++++
> =A0net/ipv4/tcp_input.c =A0 | =A0 =A02 +-
> =A03 files changed, 13 insertions(+), 10 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 9179111..7118668 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -196,6 +196,9 @@ extern void tcp_time_wait(struct sock *sk, int st=
ate, int timeo);
> =A0/* TCP thin-stream limits */
> =A0#define TCP_THIN_LINEAR_RETRIES 6 =A0 =A0 =A0 /* After 6 linear re=
tries, do exp. backoff */
>
> +/* TCP initial congestion window */
> +#define TCP_INIT_CWND =A0 =A0 =A0 =A0 =A010
> +
> =A0extern struct inet_timewait_death_row tcp_death_row;
>
> =A0/* sysctl variables for tcp */
> @@ -799,15 +802,6 @@ static inline __u32 tcp_current_ssthresh(const s=
truct sock *sk)
> =A0/* Use define here intentionally to get WARN_ON location shown at =
the caller */
> =A0#define tcp_verify_left_out(tp) =A0 =A0 =A0 =A0WARN_ON(tcp_left_ou=
t(tp) > tp->packets_out)
>
> -/*
> - * Convert RFC 3390 larger initial window into an equivalent number =
of packets.
> - * This is based on the numbers specified in RFC 5681, 3.1.
> - */
> -static inline u32 rfc3390_bytes_to_packets(const u32 smss)
> -{
> - =A0 =A0 =A0 return smss <=3D 1095 ? 4 : (smss > 2190 ? 2 : 3);
> -}
> -
> =A0extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)=
;
> =A0extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *=
dst);
>
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
> index e96d5e8..fadecd2 100644
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -583,6 +583,15 @@ done:
> =A0 =A0 =A0 =A0dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
> =A0}
>
> +/*
> + * Convert RFC 3390 larger initial window into an equivalent number =
of packets.
> + * This is based on the numbers specified in RFC 5681, 3.1.
> + */
> +static inline u32 rfc3390_bytes_to_packets(const u32 smss)
> +{
> + =A0 =A0 =A0 return smss <=3D 1095 ? 4 : (smss > 2190 ? 2 : 3);
> +}
> +
> =A0static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct ccid2_hc_tx_sock *hc =3D ccid_priv(ccid);
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index eb7f82e..2f692ce 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -817,7 +817,7 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp, struct d=
st_entry *dst)
> =A0 =A0 =A0 =A0__u32 cwnd =3D (dst ? dst_metric(dst, RTAX_INITCWND) :=
 0);
>
> =A0 =A0 =A0 =A0if (!cwnd)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cwnd =3D rfc3390_bytes_to_packets(tp->m=
ss_cache);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cwnd =3D TCP_INIT_CWND;
> =A0 =A0 =A0 =A0return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
> =A0}
>
> --
> 1.7.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
