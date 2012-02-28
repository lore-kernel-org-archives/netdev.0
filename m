From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: fix mss when it is bigger than IPV6_MAXPLEN -
 sizeof(struct tcphdr)
Date: Tue, 28 Feb 2012 01:56:23 -0800
Message-ID: <1330422983.2610.13.camel@edumazet-laptop>
References: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:51516 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801Ab2B1J41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 04:56:27 -0500
Received: by daed14 with SMTP id d14so2164893dae.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 01:56:26 -0800 (PST)
In-Reply-To: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 f=C3=A9vrier 2012 =C3=A0 16:28 +0800, roy.qing.li@gmail.com=
 a =C3=A9crit :
> From: RongQing.Li <roy.qing.li@gmail.com>
>=20
> When mss is bigger than IPV6_MAXPLEN - sizeof(struct tcphdr),
> set mss to IPV6_MAXPLEN - sizeof(struct tcphdr), not IPV6_MAXPLEN.
>=20
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---
>  net/ipv6/route.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 92be12b..42cc16c 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1054,7 +1054,7 @@ static unsigned int ip6_default_advmss(const st=
ruct dst_entry *dst)
>  	 * rely only on pmtu discovery"
>  	 */
>  	if (mtu > IPV6_MAXPLEN - sizeof(struct tcphdr))
> -		mtu =3D IPV6_MAXPLEN;
> +		mtu =3D IPV6_MAXPLEN - sizeof(struct tcphdr);
>  	return mtu;
>  }
> =20

Hmm... What about the comment above the code mentioning pmtu discovery =
?

        /*
         * Maximal non-jumbo IPv6 payload is IPV6_MAXPLEN and
         * corresponding MSS is IPV6_MAXPLEN - tcp_header_size.
         * IPV6_MAXPLEN is also valid and means: "any MSS,
         * rely only on pmtu discovery"
         */


Check out code from net/ipv6/ip6_output.c, ip6_append_data() :

        if (mtu <=3D sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
                if (cork->length + length > sizeof(struct ipv6hdr) + IP=
V6_MAXPLEN - fragheaderlen) {
                        ipv6_local_error(sk, EMSGSIZE, fl6, mtu-exthdrl=
en);
                        return -EMSGSIZE;
                }
        }

and __ip6_local_out()

	if (len > IPV6_MAXPLEN)
		len =3D 0;
