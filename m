From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [RFC] IPv4 TCP fails to send window scale option when
 window scale is zero
Date: Tue, 29 Sep 2009 19:19:54 +0200
Message-ID: <4AC241BA.8040608@gmail.com>
References: <4AC22250.7060301@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ori Finkalman <ori@comsleep.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36961 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbZI2RTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 13:19:55 -0400
In-Reply-To: <4AC22250.7060301@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef a =E9crit :
> From: Ori Finkalman <ori@comsleep.com>
>=20
>=20
> Acknowledge TCP window scale support by inserting the proper option i=
n
> SYN/ACK header
> even if our window scale is zero.
>=20
>=20
> This fixes the following observed behavior:
>=20
>=20
> 1. Client sends a SYN with TCP window scaling option and non zero win=
dow
> scale value to a Linux box.
>=20
> 2. Linux box notes large receive window from client.
>=20
> 3. Linux decides on a zero value of window scale for its part.
>=20
> 4. Due to compare against requested window scale size option, Linux d=
oes
> not to send windows scale
>=20
> TCP option header on SYN/ACK at all.
>=20
>=20
> Result:
>=20
>=20
> Client box thinks TCP window scaling is not supported, since SYN/ACK =
had
> no TCP window scale option,
> while Linux thinks that TCP window scaling is supported (and scale mi=
ght
> be non zero), since SYN had
>=20
> TCP window scale option and we have a mismatched idea between the cli=
ent
> and server regarding window sizes.
>=20
>=20
> Please comment and/or apply.
>=20
>=20
> ---
>=20
>=20
> Bug reported and patch written by Ori Finkalman from Comsleep Ltd. I'=
m
> just helping mainline it.
>=20
>=20
> The behavior was observed with a Windows box as the client and latest
> Debian kernel but for the best
> of my understanding this can happen with latest kernel versions and
> other client OS (probably also Linux)
>=20
> as well.
>=20
>=20
>=20
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> Signed-off-by: Ori Finkelman <ori@comsleep.com>
>=20
>=20
> Index: net/ipv4/tcp_output.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net/ipv4/tcp_output.c    (revision 46)
> +++ net/ipv4/tcp_output.c    (revision 210)
> @@ -353,6 +353,7 @@ static void tcp_init_nondata_skb(struct
> #define OPTION_SACK_ADVERTISE    (1 << 0)
> #define OPTION_TS        (1 << 1)
> #define OPTION_MD5        (1 << 2)
> +#define OPTION_WSCALE        (1 << 3)
>=20
> struct tcp_out_options {
>     u8 options;        /* bit field of OPTION_* */
> @@ -417,7 +418,7 @@ static void tcp_options_write(__be32 *pt
>                    TCPOLEN_SACK_PERM);
>     }
>=20
> -    if (unlikely(opts->ws)) {
> +    if (unlikely(OPTION_WSCALE & opts->options)) {
>         *ptr++ =3D htonl((TCPOPT_NOP << 24) |
>                    (TCPOPT_WINDOW << 16) |
>                    (TCPOLEN_WINDOW << 8) |
> @@ -530,8 +531,8 @@ static unsigned tcp_synack_options(struc
>=20
>     if (likely(ireq->wscale_ok)) {
>         opts->ws =3D ireq->rcv_wscale;
> -        if(likely(opts->ws))
> -            size +=3D TCPOLEN_WSCALE_ALIGNED;
> +        opts->options |=3D OPTION_WSCALE;
> +        size +=3D TCPOLEN_WSCALE_ALIGNED;
>     }
>     if (likely(doing_ts)) {
>         opts->options |=3D OPTION_TS;
>=20
>=20
>=20

Seems not the more logical places to put this logic...

How about this instead ?

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5200aab..b78c084 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -216,6 +216,11 @@ void tcp_select_initial_window(int __space, __u32 =
mss,
 			space >>=3D 1;
 			(*rcv_wscale)++;
 		}
+		/*
+		 * Set a minimum wscale of 1
+		 */
+		if (*rcv_wscale =3D=3D 0)
+			*rcv_wscale =3D 1;
        }

        /* Set initial window to value enough for senders,
