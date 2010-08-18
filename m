From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/8] netfilter: ipt_CLUSTERIP: use proto_ports_offset()
 to support AH message
Date: Wed, 18 Aug 2010 08:08:28 +0200
Message-ID: <1282111708.2456.11.camel@edumazet-laptop>
References: <1282107952-3624-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58032 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab0HRGId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 02:08:33 -0400
In-Reply-To: <1282107952-3624-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 13:05 +0800, Changli Gao a =C3=A9c=
rit :
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/ipv4/netfilter/ipt_CLUSTERIP.c |   34 ++++++++++++++++++--------=
--------
>  1 file changed, 18 insertions(+), 16 deletions(-)
> diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/=
ipt_CLUSTERIP.c
> index 3a43cf3..11c3534 100644
> --- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
> +++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
> @@ -29,6 +29,7 @@
>  #include <net/netfilter/nf_conntrack.h>
>  #include <net/net_namespace.h>
>  #include <net/checksum.h>
> +#include <net/ip.h>
> =20
>  #define CLUSTERIP_VERSION "0.8"
> =20
> @@ -231,24 +232,25 @@ clusterip_hashfn(const struct sk_buff *skb,
>  {
>  	const struct iphdr *iph =3D ip_hdr(skb);
>  	unsigned long hashval;
> -	u_int16_t sport, dport;
> +	u_int16_t sport =3D 0, dport =3D 0;
>  	const u_int16_t *ports;
> =20
> -	switch (iph->protocol) {
> -	case IPPROTO_TCP:
> -	case IPPROTO_UDP:
> -	case IPPROTO_UDPLITE:
> -	case IPPROTO_SCTP:
> -	case IPPROTO_DCCP:
> -	case IPPROTO_ICMP:
> -		ports =3D (const void *)iph+iph->ihl*4;
> -		sport =3D ports[0];
> -		dport =3D ports[1];
> -		break;
> -	default:
> -		if (net_ratelimit())
> -			pr_info("unknown protocol %u\n", iph->protocol);
> -		sport =3D dport =3D 0;
> +	if (!(iph->frag_off & htons(IP_MF|IP_OFFSET))) {

This added test is not documented in your Changelog

Please dont add such things not telling why you do it.

I am not sure it is needed here, I dont know ipt_CLUSTERIP, but dont
defrag takes place before it ?

> +		int poff;
> +
> +		poff =3D proto_ports_offset(iph->protocol);
> +		if (poff >=3D 0) {
> +			u16 _ports[2];
> +			ports =3D skb_header_pointer(skb, iph->ihl * 4 + poff,
> +						   4, _ports);
> +			if (ports) {
> +				sport =3D ports[0];
> +				dport =3D ports[1];
> +			}
> +		} else {
> +			if (net_ratelimit())
> +				pr_info("unknown protocol %u\n", iph->protocol);
> +		}
>  	}
> =20
>  	switch (config->hash_mode) {


