From: Sam Russell <sam.h.russell@gmail.com>
Subject: Re: [PATCH net] mpls: fix sending of local encapped packets
Date: Tue, 8 Dec 2015 06:53:58 +1300
Message-ID: <CAJm+voW1iL6s6jhgDMUheByqL2TSwAB-S=dunodNp65x2PbD2w@mail.gmail.com>
References: <56656219.7070009@brocade.com>
	<1449492795-12406-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, ebiederm@xmission.com
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:35866 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbbLGRx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:53:59 -0500
Received: by ykdr82 with SMTP id r82so203088640ykd.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 09:53:58 -0800 (PST)
In-Reply-To: <1449492795-12406-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can confirm that this patch works for IPv4 and IPv6

modprobe mpls_router
modprobe mpls_gso
modprobe mpls_iptunnel
ifconfig enp0s8 192.168.99.2/24 up
ifconfig enp0s9 up
arp -s 192.168.99.5  00:12:34:56:78:90
ip -6 neigh add fe80::a00:27ff:1234:5678 lladdr 00:12:34:56:78:90 dev enp0s8
./dev/iproute2/ip/ip route add 192.168.2.0/24 encap mpls 100 via inet
192.168.99.5 dev enp0s8
./dev/iproute2/ip/ip -6 route add 2404:1234:5678::/48 encap mpls 150
via inet6 fe80::a00:27ff:1234:5678 dev enp0s8

ping 192.168.2.1

tcpdump: listening on enp0s8, link-type EN10MB (Ethernet), capture
size 262144 bytes
06:46:16.780466 08:00:27:39:3c:e0 > 00:12:34:56:78:90, ethertype MPLS
unicast (0x8847), length 102: MPLS (label 100, exp 0, [S], ttl 64)
(tos 0x0, ttl 64, id 24189, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.99.2 > 192.168.2.1: ICMP echo request, id 962, seq 1, length 64
06:46:17.790616 08:00:27:39:3c:e0 > 00:12:34:56:78:90, ethertype MPLS
unicast (0x8847), length 102: MPLS (label 100, exp 0, [S], ttl 64)
(tos 0x0, ttl 64, id 24297, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.99.2 > 192.168.2.1: ICMP echo request, id 962, seq 2, length 64
06:46:18.791064 08:00:27:39:3c:e0 > 00:12:34:56:78:90, ethertype MPLS
unicast (0x8847), length 102: MPLS (label 100, exp 0, [S], ttl 64)
(tos 0x0, ttl 64, id 24338, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.99.2 > 192.168.2.1: ICMP echo request, id 962, seq 3, length 64

ping6 2404:1234:5678::1

tcpdump: listening on enp0s8, link-type EN10MB (Ethernet), capture
size 262144 bytes
06:51:15.235286 08:00:27:39:3c:e0 > 00:12:34:56:78:90, ethertype MPLS
unicast (0x8847), length 122: MPLS (label 150, exp 0, [S], ttl 64)
(flowlabel 0xc4081, hlim 64, next-header ICMPv6 (58) payload length:
64) fe80::a00:27ff:fe39:3ce0 > 2404:1234:5678::1: [icmp6 sum ok]
ICMP6, echo request, seq 1
06:51:16.236016 08:00:27:39:3c:e0 > 00:12:34:56:78:90, ethertype MPLS
unicast (0x8847), length 122: MPLS (label 150, exp 0, [S], ttl 64)
(flowlabel 0xc4081, hlim 64, next-header ICMPv6 (58) payload length:
64) fe80::a00:27ff:fe39:3ce0 > 2404:1234:5678::1: [icmp6 sum ok]
ICMP6, echo request, seq 2

Thanks for the quick response!

Cheers
Sam

On 8 December 2015 at 01:53, Robert Shearman <rshearma@brocade.com> wrote:
> Locally generated IPv4 and (probably) IPv6 packets are dropped because
> skb->protocol isn't set. We could write wrappers to lwtunnel_output
> for IPv4 and IPv6 that set the protocol accordingly and then call
> lwtunnel_output, but mpls_output relies on the AF-specific type of dst
> anyway to get the via address.
>
> Therefore, make use of dst->dst_ops->family in mpls_output to
> determine the type of nexthop and thus protocol of the packet instead
> of checking skb->protocol.
>
> Fixes: 61adedf3e3f1 ("route: move lwtunnel state to dst_entry")
> Reported-by: Sam Russell <sam.h.russell@gmail.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/mpls_iptunnel.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> index 67591aef9cae..64afd3d0b144 100644
> --- a/net/mpls/mpls_iptunnel.c
> +++ b/net/mpls/mpls_iptunnel.c
> @@ -54,10 +54,10 @@ int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>         unsigned int ttl;
>
>         /* Obtain the ttl */
> -       if (skb->protocol == htons(ETH_P_IP)) {
> +       if (dst->ops->family == AF_INET) {
>                 ttl = ip_hdr(skb)->ttl;
>                 rt = (struct rtable *)dst;
> -       } else if (skb->protocol == htons(ETH_P_IPV6)) {
> +       } else if (dst->ops->family == AF_INET6) {
>                 ttl = ipv6_hdr(skb)->hop_limit;
>                 rt6 = (struct rt6_info *)dst;
>         } else {
> --
> 2.1.4
>
