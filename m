From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy choice
Date: Tue, 14 Mar 2017 20:55:22 +0200
Message-ID: <05765FB0-BF27-4648-B7B7-93490EB50C13@cumulusnetworks.com>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com> <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>, jkbs@redhat.com,
        edumazet@google.com, pch@ordbogen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:36531 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdCNSzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:55:25 -0400
Received: by mail-wr0-f176.google.com with SMTP id u108so130016612wrb.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 11:55:24 -0700 (PDT)
In-Reply-To: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 14, 2017, at 5:36 PM, Nikolay Aleksandrov =
<nikolay@cumulusnetworks.com> wrote:
>=20
> This patch adds support for ECMP hash policy choice via a new sysctl
> called fib_multipath_hash_policy and also adds support for L4 hashes.
> The current values for fib_multipath_hash_policy are:
> 0 - layer 3 (default)
> 1 - layer 4
> If there's an skb hash already set and it matches the chosen policy =
then it
> will be used instead of being calculated (currently only for L4).
> In L3 mode we always calculate the hash due to the ICMP error special
> case, the flow dissector's field consistentification should handle the
> address order thus we can remove the address reversals.
>=20
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v3:
> - keep the ICMP error special handling and always calc L3 hash
>   Jakub, could you please run your tests with this version ?
>=20
> v2:
> - removed the output_key_hash as it's not needed anymore
> - reverted to my original/internal patch with L3 as default hash
>=20
> Documentation/networking/ip-sysctl.txt |  8 +++
> include/net/ip_fib.h                   | 14 ++----
> include/net/netns/ipv4.h               |  1 +
> include/net/route.h                    |  9 +---
> net/ipv4/fib_semantics.c               | 11 ++--
> net/ipv4/icmp.c                        | 19 +------
> net/ipv4/route.c                       | 92 =
++++++++++++++++++++++++++--------
> net/ipv4/sysctl_net_ipv4.c             |  9 ++++
> 8 files changed, 98 insertions(+), 65 deletions(-)
>=20
[snip]
> /* To make ICMP packets follow the right flow, the multipath hash is
> - * calculated from the inner IP addresses in reverse order.
> + * calculated from the inner IP addresses.
>  */
> -static int ip_multipath_icmp_hash(struct sk_buff *skb)
> +static void ip_multipath_icmp_hash(const struct sk_buff *skb,
> +				   struct flowi4 *fl4)
> {
> 	const struct iphdr *outer_iph =3D ip_hdr(skb);
> 	struct icmphdr _icmph;
> @@ -1746,33 +1746,85 @@ static int ip_multipath_icmp_hash(struct =
sk_buff *skb)
> 	struct iphdr _inner_iph;
> 	const struct iphdr *inner_iph;
>=20
> +	fl4->saddr =3D outer_iph->saddr;
> +	fl4->daddr =3D outer_iph->daddr;
> 	if (unlikely((outer_iph->frag_off & htons(IP_OFFSET)) !=3D 0))
> -		goto standard_hash;
> +		return;
>=20
> 	icmph =3D skb_header_pointer(skb, outer_iph->ihl * 4, =
sizeof(_icmph),
> 				   &_icmph);
> 	if (!icmph)
> -		goto standard_hash;
> +		return;
>=20
> 	if (icmph->type !=3D ICMP_DEST_UNREACH &&
> 	    icmph->type !=3D ICMP_REDIRECT &&
> 	    icmph->type !=3D ICMP_TIME_EXCEEDED &&
> -	    icmph->type !=3D ICMP_PARAMETERPROB) {
> -		goto standard_hash;
> -	}
> +	    icmph->type !=3D ICMP_PARAMETERPROB)
> +		return;
>=20
> 	inner_iph =3D skb_header_pointer(skb,
> 				       outer_iph->ihl * 4 + =
sizeof(_icmph),
> 				       sizeof(_inner_iph), &_inner_iph);
> 	if (!inner_iph)
> -		goto standard_hash;
> +		return;
> +	fl4->saddr =3D inner_iph->saddr;
> +	fl4->daddr =3D inner_iph->daddr;
> +}
>=20
> -	return fib_multipath_hash(inner_iph->daddr, inner_iph->saddr);
> +int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 =
*fl4,
> +		       const struct sk_buff *skb)
> +{
> +	struct net *net =3D fi->fib_net;
> +	struct flow_keys hash_keys;
> +	u32 mhash;
>=20
> -standard_hash:
> -	return fib_multipath_hash(outer_iph->saddr, outer_iph->daddr);
> -}
> +	switch (net->ipv4.sysctl_fib_multipath_hash_policy) {
> +	case 0:
> +		memset(&hash_keys, 0, sizeof(hash_keys));
> +		hash_keys.control.addr_type =3D =
FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> +		if (skb && ip_hdr(skb)->protocol =3D=3D IPPROTO_ICMP) {
> +			struct flowi4 _fl4;
>=20
> +			ip_multipath_icmp_hash(skb, &_fl4);

Ugh, obviously I could=E2=80=99ve just passed hash_keys here, will  =
change this in v4 but I=E2=80=99ll wait
to see if there aren=E2=80=99t any other comments or issues.

Thanks,
 Nik

> +			hash_keys.addrs.v4addrs.src =3D _fl4.saddr;
> +			hash_keys.addrs.v4addrs.dst =3D _fl4.daddr;
> +		} else {
> +			hash_keys.addrs.v4addrs.src =3D fl4->saddr;
> +			hash_keys.addrs.v4addrs.dst =3D fl4->daddr;
> +		}
> +		break;
> +	case 1:
> +		/* skb is currently provided only when forwarding */
> +		if (skb) {
> +			unsigned int flag =3D =
FLOW_DISSECTOR_F_STOP_AT_ENCAP;
> +			struct flow_keys keys;
> +
> +			/* short-circuit if we already have L4 hash =
present */
> +			if (skb->l4_hash)
> +				return skb_get_hash_raw(skb) >> 1;
> +			memset(&hash_keys, 0, sizeof(hash_keys));
> +			skb_flow_dissect_flow_keys(skb, &keys, flag);
> +			hash_keys.addrs.v4addrs.src =3D =
keys.addrs.v4addrs.src;
> +			hash_keys.addrs.v4addrs.dst =3D =
keys.addrs.v4addrs.dst;
> +			hash_keys.ports.src =3D keys.ports.src;
> +			hash_keys.ports.dst =3D keys.ports.dst;
> +			hash_keys.basic.ip_proto =3D =
keys.basic.ip_proto;
> +		} else {
> +			memset(&hash_keys, 0, sizeof(hash_keys));
> +			hash_keys.control.addr_type =3D =
FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> +			hash_keys.addrs.v4addrs.src =3D fl4->saddr;
> +			hash_keys.addrs.v4addrs.dst =3D fl4->daddr;
> +			hash_keys.ports.src =3D fl4->fl4_sport;
> +			hash_keys.ports.dst =3D fl4->fl4_dport;
> +			hash_keys.basic.ip_proto =3D fl4->flowi4_proto;
> +		}
> +		break;
> +	}
> +	mhash =3D flow_hash_from_keys(&hash_keys);
> +
> +	return mhash >> 1;
> +}
> +EXPORT_SYMBOL_GPL(fib_multipath_hash);
> #endif /* CONFIG_IP_ROUTE_MULTIPATH */
