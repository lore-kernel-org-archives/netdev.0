From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc 2/4] net-errqueue: add IP(V6)_PKTINFO support
Date: Tue, 25 Nov 2014 16:16:12 -0500
Message-ID: <CA+FuTSeRMv3WTJ+-9257Lj_kJ+bUR=aq_=Ld42kYCYSY6-AH3g@mail.gmail.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com> <1416938286-14147-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Richard Cochran <richardcochran@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:33514 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbaKYVQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 16:16:43 -0500
Received: by mail-qa0-f53.google.com with SMTP id bm13so1017276qab.40
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 13:16:42 -0800 (PST)
In-Reply-To: <1416938286-14147-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 12:58 PM, Willem de Bruijn <willemb@google.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> On INET and INET6 sockets with the IP_PKTINFO or IPV6_RECVPKTINFO
> socket option set, return a matching cmsg also for packets queued
> to the error queue.
>
> These packets are transmitted packets looped back. The fields of
> struct in[6]_pktinfo are changed to reflect that:
>
>   ifindex:   index of the outgoing device, if configured
>   addr:      destination address
>   spec_dst:  source address  (absent in v6)
>
> On IPv6, the mechanism currently returns two IPV6_PKTINFO when
> the option is enabled, because the existing code already supports
> the feature.

This points to a wider difference between when
ip_recv_error and ipv6_recv_error fill sockaddr and cmsg:

    if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP) {

vs

    if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {

The two were introduced in the same patch, when they were equivalent
bar the difference between ICMP and ICMP6, which this neatly handles.

Now that there are SO_EE_ORIGIN_TXSTATUS and
SO_EE_ORIGIN_TIMESTAMPING, this is no longer the case. This
is another case where it's not clear whether the difference should be
preserved for legacy reasons, or the two should be harmonized. The
fix, if any, is to make ipv6 explicitly check for ICMP and IMCP6.

> The legacy data does not produce a correct ifindex,
> however. Perhaps I can revise the patch to only send the legacy
> patch, but use the correct ifindex source in case of ERRQUEUE.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/ipv4/ip_sockglue.c | 15 +++++++++++++++
>  net/ipv6/datagram.c    | 22 ++++++++++++++++++++++
>  2 files changed, 37 insertions(+)
>
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index b782657..615f783 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -399,6 +399,20 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
>                 kfree_skb(skb);
>  }
>
> +static void ip_recv_error_pktinfo(struct msghdr *msg, struct sock *sk,
> +                                 struct sk_buff *skb)
> +{
> +       if (inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO && skb->dev) {
> +               struct in_pktinfo info = {0};
> +
> +               info.ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
> +               info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
> +               info.ipi_ifindex = skb->dev->ifindex;
> +
> +               put_cmsg(msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
> +       }
> +}
> +
>  /*
>   *     Handle MSG_ERRQUEUE
>   */
> @@ -429,6 +443,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>                 goto out_free_skb;
>
>         sock_recv_timestamp(msg, sk, skb);
> +       ip_recv_error_pktinfo(msg, sk, skb);
>
>         serr = SKB_EXT_ERR(skb);
>
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index cc11396..7d2ef7c 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -325,6 +325,27 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
>         kfree_skb(skb);
>  }
>
> +static void ipv6_recv_error_pktinfo(struct msghdr *msg, struct sock *sk,
> +                                   struct sk_buff *skb)
> +{
> +       struct ipv6_pinfo *np = inet6_sk(sk);
> +
> +       if (np->rxopt.bits.rxinfo && skb->dev) {
> +               struct in6_pktinfo info;
> +
> +               memset(&info, 0, sizeof(info));
> +               if (skb->protocol == htons(ETH_P_IPV6))
> +                       info.ipi6_addr = ipv6_hdr(skb)->daddr;
> +               else
> +                       ipv6_addr_set_v4mapped(ip_hdr(skb)->daddr,
> +                                              &info.ipi6_addr);
> +
> +               info.ipi6_ifindex = skb->dev->ifindex;
> +               net_info_ratelimited("yes: ifindex=%d\n", info.ipi6_ifindex);
> +               put_cmsg(msg, SOL_IPV6, IPV6_PKTINFO, sizeof(info), &info);
> +       }
> +}
> +
>  /*
>   *     Handle MSG_ERRQUEUE
>   */
> @@ -356,6 +377,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>                 goto out_free_skb;
>
>         sock_recv_timestamp(msg, sk, skb);
> +       ipv6_recv_error_pktinfo(msg, sk, skb);
>
>         serr = SKB_EXT_ERR(skb);
>
> --
> 2.1.0.rc2.206.gedb03e5
>
