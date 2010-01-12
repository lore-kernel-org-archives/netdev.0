From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Tue, 12 Jan 2010 11:46:02 +0100
Message-ID: <4B4C52EA.6070705@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4C4962.8040207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Andi Kleen <andi@firstfloor.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754186Ab0ALKqN@vger.kernel.org>
In-Reply-To: <4B4C4962.8040207@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/01/2010 11:05, William Allen Simpson a =E9crit :
> Harmonize tcp_v4_rcv() and tcp_v6_rcv() -- better document tcp doff a=
nd
> header length assumptions.
>=20
> Reduces multiply/shifts, marginally improving speed.
>=20
> Retains redundant tcp header length checks before checksumming.
>=20
> Stand-alone patch, originally developed for TCPCT.
>=20
> Requires:
>   net: tcp_header_len_th and tcp_option_len_th
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  net/ipv4/tcp_ipv4.c |   36 +++++++++++++++++++-------------
>  net/ipv6/tcp_ipv6.c |   56
> ++++++++++++++++++++++++++++----------------------
>  2 files changed, 52 insertions(+), 40 deletions(-)

Seems fine, but :

1) What means the "Transformed ?" you wrote several times ?

2) This part :

-	th =3D tcp_hdr(skb);
-
-	if (th->doff < sizeof(struct tcphdr)/4)
+	/* Check bad doff, compare doff directly to constant value */
+	tcp_header_len =3D tcp_hdr(skb)->doff;
+	if (tcp_header_len < (sizeof(struct tcphdr) / 4))
 		goto bad_packet;
-	if (!pskb_may_pull(skb, th->doff*4))
+
+	/* Check too short header and options */
+	tcp_header_len *=3D 4;
+	if (!pskb_may_pull(skb, tcp_header_len))
 		goto discard_it;


could be :  (no need for 4 multiplies/divides)

	tcp_header_len =3D tcp_header_len_th(tcp_hdr(skb));
	if (tcp_header_len < sizeof(struct tcphdr))
		goto bad_packet;
	/* Check too short header and options */
	if (!pskb_may_pull(skb, tcp_header_len))
		goto discard_it;

	=20
