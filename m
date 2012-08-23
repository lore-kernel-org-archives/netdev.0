From: Jeremy Brookman <jeremy.brookman@gmail.com>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Thu, 23 Aug 2012 11:42:44 +0100
Message-ID: <CAPc2XZBOKrZRTj0Ruj8MeEeM+JiTAOYn6iteSNCRpthbsbN48A@mail.gmail.com>
References: <4FF27CA0.7030708@8192.net>
	<20120702.221425.418792617776598841.davem@davemloft.net>
	<4FF2853D.9070707@8192.net>
	<20120702.224351.1587084404665143719.davem@davemloft.net>
	<CAPc2XZDHBPKEM+WsWTL+9N_sfgVhOZAoiY3LU=v-QTCb9eQObQ@mail.gmail.com>
	<11100.1345576795@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux@8192.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:61319 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933835Ab2HWKmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 06:42:45 -0400
Received: by obbuo13 with SMTP id uo13so1157105obb.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 03:42:44 -0700 (PDT)
In-Reply-To: <11100.1345576795@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A few questions on the actual patch inline now I've had a bit more time...

>  static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)

...

> +       if (skb->protocol == htons(ETH_P_IP) &&
> +               skb_network_header_len(skb) >= sizeof(struct iphdr)) {
> +               iph = ip_hdr(skb);
>                 return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>                         (data->h_dest[5] ^ data->h_source[5])) % count;
> +       } else if (skb->protocol == htons(ETH_P_IPV6) &&
> +               skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
> +               ipv6h = ipv6_hdr(skb);
> +               s = &ipv6h->saddr.s6_addr32[0];
> +               d = &ipv6h->daddr.s6_addr32[0];
> +               v6hash = (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
> +               v6hash ^= (v6hash >> 24) ^ (v6hash >> 16) ^ (v6hash >> 8);
> +               return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
>         }
>

If the IPv4 case needs an ntohl, does the IPv6 case (if we're
interpreting the address as 4 32-bits)?  If IPv4 hashing algorithm is
consistent across different endiannesses, then maybe IPv6 should be
too?

>  /*
>   * Hash for the output device based upon layer 3 and layer 4 data. If
>   * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
> - * altogether not IP, mimic bond_xmit_hash_policy_l2()
> + * altogether not IP, fall back on bond_xmit_hash_policy_l2()
>   */

Looking at the code below, we only check the first value of next_hdr
in the chain; however RFC 2460 lists the following possible extension
headers, all of which will therefore cause fallback to L3 hashing:

           Hop-by-Hop Options
           Routing (Type 0)
           Fragment
           Destination Options
           Authentication
           Encapsulating Security Payload

Clearly with some (eg ESP and fragment) we do need to drop out of
using L4 header info in the hash.  And anyone using Routing (Type 0)
probably deserves anything they get.  But should we at least comment
on the limitation that the existence of the other headers also causes
fallback to L3 hashing only? (And possibly even include in
documentation?)  Or of course, fix?

>         if (skb->protocol == htons(ETH_P_IP)) {
> +               iph = ip_hdr(skb);
>                 if (!ip_is_fragment(iph) &&
>                     (iph->protocol == IPPROTO_TCP ||
>                      iph->protocol == IPPROTO_UDP)) {
> +                       if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
> +                           skb_headlen(skb) - skb_network_offset(skb))
> +                               goto short_header;
> +                       layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
>                         layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
> +               } else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
> +                       goto short_header;
>                 }

I don't know the assertions we can make about
skb_network_header_len(skb), but it looks odd doing a length check
against sizeof(iphdr) after iph->protocol has already been
dereferenced. Is this really right?  (The pattern recurs a few times.)

Regards,

Jeremy
