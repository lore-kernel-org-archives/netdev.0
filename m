From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Thu, 18 Feb 2016 16:18:05 +0100
Message-ID: <1455808685.648.16.camel@edumazet-ThinkPad-T530>
References: <1455630663-18400-1-git-send-email-bro.devel+kernel@gmail.com>
	 <1455630663-18400-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?ISO-8859-1?Q?P=E5l?= Halvorsen <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38541 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426127AbcBRPSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:18:09 -0500
Received: by mail-wm0-f54.google.com with SMTP id a4so30179816wme.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 07:18:09 -0800 (PST)
In-Reply-To: <1455630663-18400-3-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On mar., 2016-02-16 at 14:51 +0100, Bendik R=C3=B8nning Opstad wrote:
> RDB is a mechanism that enables a TCP sender to bundle redundant
> (already sent) data with TCP packets containing new data. By bundling
> (retransmitting) already sent data with each TCP packet containing ne=
w
> data, the connection will be more resistant to sporadic packet loss
> which reduces the application layer latency significantly in congeste=
d
> scenarios.
> =20
> -static void copy_skb_header(struct sk_buff *new, const struct sk_buf=
f *old)
> +void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  {
>  	__copy_skb_header(new, old);
> =20
> @@ -1061,6 +1061,7 @@ static void copy_skb_header(struct sk_buff *new=
, const struct sk_buff *old)
>  	skb_shinfo(new)->gso_segs =3D skb_shinfo(old)->gso_segs;
>  	skb_shinfo(new)->gso_type =3D skb_shinfo(old)->gso_type;
>  }
> +EXPORT_SYMBOL(copy_skb_header);

Why are you exporting this ? tcp is statically linked into vmlinux.


> =20
> +/**
> + * skb_append_data() - copy data from an SKB to the end of another
> + *                     update end sequence number and checksum
> + * @from_skb: the SKB to copy data from
> + * @to_skb: the SKB to copy data to
> + */
> +void skb_append_data(struct sk_buff *from_skb, struct sk_buff *to_sk=
b)
> +{
> +	skb_copy_from_linear_data(from_skb, skb_put(to_skb, from_skb->len),
> +				  from_skb->len);
> +	/* Update sequence range on original skb. */
> +	TCP_SKB_CB(to_skb)->end_seq =3D TCP_SKB_CB(from_skb)->end_seq;
> +
> +	if (from_skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
> +		to_skb->ip_summed =3D CHECKSUM_PARTIAL;
> +
> +	if (to_skb->ip_summed !=3D CHECKSUM_PARTIAL)
> +		to_skb->csum =3D csum_block_add(to_skb->csum, from_skb->csum,
> +					      to_skb->len);
> +}
> +EXPORT_SYMBOL(skb_append_data);

Same remark here.

And this is really a tcp helper, you should add a tcp_ prefix.

About rdb_build_skb() : I do not see where you make sure
@bytes_in_rdb_skb is not too big ?

tcp_rdb_max_bytes & tcp_rdb_max_packets seem to have no .extra2 upper
limit, so a user could do something really stupid and attempt to crash
the kernel.

Presumably I would use SKB_MAX_HEAD(MAX_TCP_HEADER) so that we do not
try high order page allocation.
