From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH RESEND] ipv6: return with appropriate error code when
 sending RH0 using setsockopt()
Date: Thu, 04 Sep 2008 09:54:11 -0400
Message-ID: <48BFE883.7000203@hp.com>
References: <48BE4DA2.20800@cn.fujitsu.com> <48BED93E.2000204@hp.com> <48BF77D3.5010105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:4352 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbYIDNyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 09:54:13 -0400
In-Reply-To: <48BF77D3.5010105@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei wrote:
> Brian Haley =D0=B4=B5=C0:
>> Shan Wei wrote:
>=20
> ...snip...
>=20
>> There's actually another bug here and in the sendmsg() path in that =
you
>> can set the hdrlen and segments_left fields to be invalid (according=
 to
>> RFC3775), as long as the math works out (segments * 2 =3D=3D length)=
=2E
>> Segments_left should always be 1 and hdrlen 2 for a Type2 routing
>> header.  The packet should be dropped at the destination, but we
>> probably shouldn't send it.  I can send a patch for that later.
>>
> I check the RFC3775. May be the following patch is good to you.
>=20
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  net/ipv6/datagram.c      |    8 ++++++--
>  net/ipv6/ipv6_sockglue.c |    7 +++++--
>  2 files changed, 11 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 410046a..cfd499a 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -675,8 +675,12 @@ int datagram_send_ctl(struct net *net,
>  				goto exit_f;
>  			}
> =20
> -			/* segments left must also match */
> -			if ((rthdr->hdrlen >> 1) !=3D rthdr->segments_left) {
> +			/* Per RFC3775, for a type 2 routing header,
> +			 * the Hdr Ext Len MUST be 2 and the Segments Left
> +			 * MUST be 1.
> +			 */
> +			if ((rthdr->hdrlen !=3D 2) &&
> +			    (rthdr->segments_left !=3D 1)) {
>  				err =3D -EINVAL;
>  				goto exit_f;
>  			}
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 4e5eac3..b967965 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -377,8 +377,11 @@ static int do_ipv6_setsockopt(struct sock *sk, i=
nt level, int optname,
>  				goto sticky_done;
>  			}
> =20
> -			if ((rthdr->hdrlen & 1) ||
> -			    (rthdr->hdrlen >> 1) !=3D rthdr->segments_left)
> +			/* Per RFC3775, for a type 2 routing header,
> +			 * the Hdr Ext Len MUST be 2 and the Segments Left
> +			 * MUST be 1.
> +			 */
> +			if ((rthdr->hdrlen !=3D 2) && (rthdr->segments_left !=3D 1))
>  				goto sticky_done;
>  		}

I think these checks need to be in the Type 2 specific code since if we
add support for Type 7, for example, then we'd have to change this
again.  I"'ll send something out soon.

-Brian
