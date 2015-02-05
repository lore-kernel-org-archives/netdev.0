From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net] pktgen: fix UDP checksum computation
Date: Thu, 5 Feb 2015 15:57:47 -0800
Message-ID: <CA+mtBx9dT5JkDzj8AYojZBrm5-fd0GN0ZxY47t-43sZoqZmGsg@mail.gmail.com>
References: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:46402 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbbBEX5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:57:48 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so3123515igj.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 15:57:48 -0800 (PST)
In-Reply-To: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 2:08 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> This patch fixes two issues in UDP checksum computation in pktgen.
>
> First, the pseudo-header uses the source and destination IP
> addresses. Currently, the ports are used for IPv4.
>
> Second, the UDP checksum covers both header and data.  So we need to
> generate the data earlier (move pktgen_finalize_skb up), and compute
> the checksum for UDP header + data.
>
> Fixes: c26bf4a51308c ("pktgen: Add UDPCSUM flag to support UDP checksums")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  net/core/pktgen.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index da934fc3faa8..9fa25b0ea145 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2842,25 +2842,25 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>         skb->dev = odev;
>         skb->pkt_type = PACKET_HOST;
>
> +       pktgen_finalize_skb(pkt_dev, skb, datalen);
> +
>         if (!(pkt_dev->flags & F_UDPCSUM)) {
>                 skb->ip_summed = CHECKSUM_NONE;
>         } else if (odev->features & NETIF_F_V4_CSUM) {
>                 skb->ip_summed = CHECKSUM_PARTIAL;
>                 skb->csum = 0;
> -               udp4_hwcsum(skb, udph->source, udph->dest);
> +               udp4_hwcsum(skb, iph->saddr, iph->daddr);
>         } else {
> -               __wsum csum = udp_csum(skb);
> +               __wsum csum = skb_checksum(skb, skb_transport_offset(skb), datalen + 8, 0);
>
>                 /* add protocol-dependent pseudo-header */
> -               udph->check = csum_tcpudp_magic(udph->source, udph->dest,
> +               udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
>                                                 datalen + 8, IPPROTO_UDP, csum);
>
>                 if (udph->check == 0)
>                         udph->check = CSUM_MANGLED_0;
>         }
>
Would it be possible to use udp_set_csum to handle all of this?

Thanks,
Tom


> -       pktgen_finalize_skb(pkt_dev, skb, datalen);
> -
>  #ifdef CONFIG_XFRM
>         if (!process_ipsec(pkt_dev, skb, protocol))
>                 return NULL;
> @@ -2976,6 +2976,8 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
>         skb->dev = odev;
>         skb->pkt_type = PACKET_HOST;
>
> +       pktgen_finalize_skb(pkt_dev, skb, datalen);
> +
>         if (!(pkt_dev->flags & F_UDPCSUM)) {
>                 skb->ip_summed = CHECKSUM_NONE;
>         } else if (odev->features & NETIF_F_V6_CSUM) {
> @@ -2984,7 +2986,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
>                 skb->csum_offset = offsetof(struct udphdr, check);
>                 udph->check = ~csum_ipv6_magic(&iph->saddr, &iph->daddr, udplen, IPPROTO_UDP, 0);
>         } else {
> -               __wsum csum = udp_csum(skb);
> +               __wsum csum = skb_checksum(skb, skb_transport_offset(skb), udplen, 0);
>
>                 /* add protocol-dependent pseudo-header */
>                 udph->check = csum_ipv6_magic(&iph->saddr, &iph->daddr, udplen, IPPROTO_UDP, csum);
> @@ -2993,8 +2995,6 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
>                         udph->check = CSUM_MANGLED_0;
>         }
>
> -       pktgen_finalize_skb(pkt_dev, skb, datalen);
> -
>         return skb;
>  }
>
> --
> 2.2.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
