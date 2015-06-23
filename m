From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] ip: report the original address of ICMP messages
Date: Tue, 23 Jun 2015 13:57:26 -0400
Message-ID: <CA+FuTSeza4ZhCUPoL9hLuZzNHAQf79mSBi9EvMvx3mK58A2RRQ@mail.gmail.com>
References: <1435037679-2304-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:34530 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932540AbbFWR54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 13:57:56 -0400
Received: by obbkm3 with SMTP id km3so11357344obb.1
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 10:57:55 -0700 (PDT)
In-Reply-To: <1435037679-2304-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ICMP messages can trigger ICMP and local errors. In this case
> serr->port is 0 and starting from Linux 4.0 we do not return
> the original target address to the error queue readers.
> Add function to define which errors provide addr_offset.
> With this fix my ping command is not silent anymore.
>
> Fixes: c247f0534cc5 ("ip: fix error queue empty skb handling")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Willem de Bruijn <willemb@google.com>

The ping utility from iputils relies on cmsg IP_RECVERR to get
the source address on icmp errors, not on msg_name, so that
worked for me both before and after applying the patch. I used
`ping -t 2 $hostname` to trigger a TTL exceeded. Perhaps you used
a different tool or test? In any case, the change looks fine to me.
Thanks for preparing the patch.

> ---
>  net/ipv4/ip_sockglue.c | 11 ++++++++++-
>  net/ipv6/datagram.c    | 12 +++++++++++-
>  2 files changed, 21 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 7cfb089..6ddde89 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -432,6 +432,15 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
>                 kfree_skb(skb);
>  }
>
> +/* For some errors we have valid addr_offset even with zero payload and
> + * zero port. Also, addr_offset should be supported if port is set.
> + */
> +static inline bool ipv4_datagram_support_addr(struct sock_exterr_skb *serr)
> +{
> +       return serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> +              serr->ee.ee_origin == SO_EE_ORIGIN_LOCAL || serr->port;
> +}
> +
>  /* IPv4 supports cmsg on all imcp errors and some timestamps
>   *
>   * Timestamp code paths do not initialize the fields expected by cmsg:
> @@ -498,7 +507,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>
>         serr = SKB_EXT_ERR(skb);
>
> -       if (sin && serr->port) {
> +       if (sin && ipv4_datagram_support_addr(serr)) {
>                 sin->sin_family = AF_INET;
>                 sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
>                                                    serr->addr_offset);
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 762a58c..62d908e 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -325,6 +325,16 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
>         kfree_skb(skb);
>  }
>
> +/* For some errors we have valid addr_offset even with zero payload and
> + * zero port. Also, addr_offset should be supported if port is set.
> + */
> +static inline bool ipv6_datagram_support_addr(struct sock_exterr_skb *serr)
> +{
> +       return serr->ee.ee_origin == SO_EE_ORIGIN_ICMP6 ||
> +              serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> +              serr->ee.ee_origin == SO_EE_ORIGIN_LOCAL || serr->port;
> +}
> +
>  /* IPv6 supports cmsg on all origins aside from SO_EE_ORIGIN_LOCAL.
>   *
>   * At one point, excluding local errors was a quick test to identify icmp/icmp6
> @@ -389,7 +399,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>
>         serr = SKB_EXT_ERR(skb);
>
> -       if (sin && serr->port) {
> +       if (sin && ipv6_datagram_support_addr(serr)) {
>                 const unsigned char *nh = skb_network_header(skb);
>                 sin->sin6_family = AF_INET6;
>                 sin->sin6_flowinfo = 0;
> --
> 1.9.3
>
