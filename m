From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [GIT PULL net-next 04/17] ndisc: Introduce ndisc_fill_redirect_hdr_option().
Date: Wed, 19 Dec 2012 12:47:33 +0100
Message-ID: <87txrib6wa.fsf@nemi.mork.no>
References: <50CF84A5.7030706@linux-ipv6.org>
	<50D04B4B.7060002@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56106 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab2LSLru convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 06:47:50 -0500
In-Reply-To: <50D04B4B.7060002@linux-ipv6.org> (YOSHIFUJI Hideaki's message of
	"Tue, 18 Dec 2012 19:54:03 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> writes:

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/ndisc.c |   21 +++++++++++++++------
>  1 file changed, 15 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index a181113..0a4f3a9 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1332,6 +1332,19 @@ static void ndisc_redirect_rcv(struct sk_buff =
*skb)
>  	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
>  }
> =20
> +static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff *o=
rig_skb,
> +					  int rd_len)
> +{
> +	memset(opt, 0, 8);
> +	*(opt++) =3D ND_OPT_REDIRECT_HDR;
> +	*(opt++) =3D (rd_len >> 3);
> +	opt +=3D 6;
> +
> +	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
> +
> +	return opt;
> +}
> +

I realize that it doesn't currently matter, but the above modification
of "opt" looks like a bug-waiting-to-happen to me.

>  void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr =
*target)
>  {
>  	struct net_device *dev =3D skb->dev;
> @@ -1461,12 +1474,8 @@ void ndisc_send_redirect(struct sk_buff *skb, =
const struct in6_addr *target)
>  	 *	build redirect option and copy skb over to the new packet.
>  	 */
> =20
> -	memset(opt, 0, 8);
> -	*(opt++) =3D ND_OPT_REDIRECT_HDR;
> -	*(opt++) =3D (rd_len >> 3);
> -	opt +=3D 6;
> -
> -	memcpy(opt, ipv6_hdr(skb), rd_len - 8);
> +	if (rd_len)
> +		opt =3D ndisc_fill_redirect_hdr_option(opt, skb, rd_len);


I understand that opt isn't currently used after this, but if it ever i=
s
then it is going to come as big a surprise that this implies opt +=3D 8=
;

This was previously quite clear when the code was inline, but it become=
s
problematic when it is factored out.


Bj=C3=B8rn
