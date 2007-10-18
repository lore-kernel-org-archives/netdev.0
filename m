From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [PATCH] [TCP]: Remove lost_retrans zero special cases
Date: Thu, 18 Oct 2007 19:55:58 +0900 (JST)
Message-ID: <20071018.195558.103454352.takano@axe-inc.co.jp>
References: <20071018.125045.90803775.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710181214140.3767@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0710181314130.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, y-kodama@aist.go.jp, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:52319 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764954AbXJRK4F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:56:05 -0400
In-Reply-To: <Pine.LNX.4.64.0710181314130.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Remove lost_retrans zero special cases
Date: Thu, 18 Oct 2007 13:17:24 +0300 (EEST)

> [PATCH] [TCP]: Remove lost_retrans zero seqno special cases
>=20
> Both high-sack detection and new lowest seq variables have
> unnecessary zero special case which are now removed by setting
> safe initial seqnos.
>=20
> This also fixes problem which caused zero received_upto being
> passed to tcp_mark_lost_retrans which confused after relations
> within the marker loop causing incorrect TCPCB_SACKED_RETRANS
> clearing. The problem was noticed because of a performance
> report from TAKANO Ryousei <takano@axe-inc.co.jp>.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 0f00966..9288220 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1121,7 +1121,7 @@ static int tcp_mark_lost_retrans(struct sock *s=
k, u32 received_upto)
>  	struct sk_buff *skb;
>  	int flag =3D 0;
>  	int cnt =3D 0;
> -	u32 new_low_seq =3D 0;
> +	u32 new_low_seq =3D tp->snd_nxt;
> =20
>  	tcp_for_write_queue(skb, sk) {
>  		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
> @@ -1153,7 +1153,7 @@ static int tcp_mark_lost_retrans(struct sock *s=
k, u32 received_upto)
>  				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
>  			}
>  		} else {
> -			if (!new_low_seq || before(ack_seq, new_low_seq))
> +			if (before(ack_seq, new_low_seq))
>  				new_low_seq =3D ack_seq;
>  			cnt +=3D tcp_skb_pcount(skb);
>  		}
> @@ -1242,7 +1242,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
>  	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
>  	int reord =3D tp->packets_out;
>  	int prior_fackets;
> -	u32 highest_sack_end_seq =3D 0;
> +	u32 highest_sack_end_seq =3D tp->lost_retrans_low;
>  	int flag =3D 0;
>  	int found_dup_sack =3D 0;
>  	int cached_fack_count;
> --=20
> 1.5.0.6

Thanks Ilpo! This patch solves the problem, as shown below:

iteration :001 .... done. T =3D 17.365902 BW =3D 460.672876 Mbps
iteration :002 .... done. T =3D 16.456351 BW =3D 486.134501 Mbps
iteration :003 .... done. T =3D 16.658353 BW =3D 480.239550 Mbps
iteration :004 .... done. T =3D 16.468834 BW =3D 485.766026 Mbps
iteration :005 .... done. T =3D 16.596055 BW =3D 482.042268 Mbps

Acked-by: Ryousei Takano <takano-ryousei@aist.go.jp>
