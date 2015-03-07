From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] ip: fix error queue empty skb handling
Date: Sat, 7 Mar 2015 18:57:07 -0500
Message-ID: <CA+FuTSeHR_MRmCs6K6UxvggW13Tj_7+FV9CV24u=6AkfxGmMmQ@mail.gmail.com>
References: <1425761554-19499-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jan Niehusmann <jan@gondor.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:38898 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbbCGX5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 18:57:38 -0500
Received: by oiax69 with SMTP id x69so23606560oia.5
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 15:57:37 -0800 (PST)
In-Reply-To: <1425761554-19499-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 7, 2015 at 3:52 PM, Willem de Bruijn <willemb@google.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> When reading from the error queue, msg_name and msg_control are only
> populated for some errors. A new exception for empty timestamp skbs
> added a false positive on icmp errors without payload.
>
> `traceroute -M udpconn` only displayed gateways that return payload:
> the network headers are pulled before sock_queue_err_skb, leaving an
> skb with skb->len == 0.
>
> Fix this regression by refining when msg_name and msg_control
> branches are taken. The solutions for the two fields are independent.
>
> msg_name only makes sense for errors that configure serr->port and
> serr->addr_offset. Test the first instead of skb->len. This also fixes
> another issue. saddr could hold the wrong data, as serr->addr_offset
> is not initialized explicitly if serr->port is not set.
>
> msg_control support differs between IPv4 and IPv6. IPv4 only honors
> requests for ICMP and timestamps with SOF_TIMESTAMPING_OPT_CMSG. The
> skb->len test can simply be removed, because skb->dev is also tested
> and never true for empty skbs. Also rename the relevant function to
> make it more self describing.
>
> IPv6 honors requests for all errors aside from local errors and
> timestamps on empty skbs. Rewrite the function to make this policy
> self documenting, which fixes the false positive.
>
> The last case is rxrpc. Here, simply refine to only match timestamps.
>
> Fixes: 49ca0d8bfaf3 ("net-timestamp: no-payload option")
>
> Reported-by: Jan Niehusmann <jan@gondor.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/ipv4/ip_sockglue.c | 10 +++++-----
>  net/ipv6/datagram.c    | 38 +++++++++++++++++++++++++++++---------
>  net/rxrpc/ar-error.c   |  5 ++---
>  3 files changed, 36 insertions(+), 17 deletions(-)
>
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 31d8c71..0e1a9be 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -432,7 +432,8 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
>                 kfree_skb(skb);
>  }
>
> -static bool ipv4_pktinfo_prepare_errqueue(const struct sock *sk,
> +/* Support IP_PKTINFO on tstamp packets, to correlate tstamp with egress dev */
> +static bool ipv4_pktinfo_prepare_txtstamp(const struct sock *sk,
>                                           const struct sk_buff *skb,
>                                           int ee_origin)
>  {
> @@ -483,7 +484,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>
>         serr = SKB_EXT_ERR(skb);
>
> -       if (sin && skb->len) {
> +       if (sin && serr->port) {
>                 sin->sin_family = AF_INET;
>                 sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
>                                                    serr->addr_offset);
> @@ -496,9 +497,8 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>         sin = &errhdr.offender;
>         memset(sin, 0, sizeof(*sin));
>
> -       if (skb->len &&
> -           (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> -            ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin))) {
> +       if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> +           ipv4_pktinfo_prepare_txtstamp(sk, skb, serr->ee.ee_origin)) {
>                 sin->sin_family = AF_INET;
>                 sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
>                 if (inet_sk(sk)->cmsg_flags)
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index c215be7..d10ead3 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -325,14 +325,38 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
>         kfree_skb(skb);
>  }
>
> -static void ip6_datagram_prepare_pktinfo_errqueue(struct sk_buff *skb)
> +/* IPv6 supports cmsg on all origins aside from SO_EE_ORIGIN_LOCAL.
> + *
> + * At one point, excluding local errors was a quick test to identify icmp/icmp6
> + * errors. This is no longer true, but the test remained, so the v6 stack
> + * honors cmsg requests on wifi and timestamp errors (unlike v4).
> + *
> + * Those code paths do not initialize the fields expected by cmsgs, in
> + * particular the PKTINFO fields in skb->cb[]. Fill those in here, if possible.
> + */
> +static bool ip6_datagram_support_cmsg(struct sk_buff *skb,
> +                                     struct sock_exterr_skb *serr)
>  {
> -       int ifindex = skb->dev ? skb->dev->ifindex : -1;
> +       int ifindex;
> +
> +       if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> +           serr->ee.ee_origin == SO_EE_ORIGIN_ICMP6)
> +               return true;
>
> +       if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL)

This test is inverted. I'll send a v2

> +               return false;
> +
> +       /* tsonly timestamp: no network headers */
> +       if (!skb->len)
> +               return false;
> +
> +       ifindex = skb->dev ? skb->dev->ifindex : -1;
>         if (skb->protocol == htons(ETH_P_IPV6))
>                 IP6CB(skb)->iif = ifindex;
>         else
>                 PKTINFO_SKB_CB(skb)->ipi_ifindex = ifindex;
> +
> +       return true;
>  }
>
>  /*
> @@ -369,7 +393,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>
>         serr = SKB_EXT_ERR(skb);
>
> -       if (sin && skb->len) {
> +       if (sin && serr->port) {
>                 const unsigned char *nh = skb_network_header(skb);
>                 sin->sin6_family = AF_INET6;
>                 sin->sin6_flowinfo = 0;
> @@ -394,14 +418,10 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>         memcpy(&errhdr.ee, &serr->ee, sizeof(struct sock_extended_err));
>         sin = &errhdr.offender;
>         memset(sin, 0, sizeof(*sin));
> -       if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL && skb->len) {
> +       if (ip6_datagram_support_cmsg(skb, serr)) {
>                 sin->sin6_family = AF_INET6;
> -               if (np->rxopt.all) {
> -                       if (serr->ee.ee_origin != SO_EE_ORIGIN_ICMP &&
> -                           serr->ee.ee_origin != SO_EE_ORIGIN_ICMP6)
> -                               ip6_datagram_prepare_pktinfo_errqueue(skb);
> +               if (np->rxopt.all)
>                         ip6_datagram_recv_common_ctl(sk, msg, skb);
> -               }
>                 if (skb->protocol == htons(ETH_P_IPV6)) {
>                         sin->sin6_addr = ipv6_hdr(skb)->saddr;
>                         if (np->rxopt.all)
> diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
> index 5394b6b..c79b415 100644
> --- a/net/rxrpc/ar-error.c
> +++ b/net/rxrpc/ar-error.c
> @@ -27,7 +27,7 @@
>   */
>  void rxrpc_UDP_error_report(struct sock *sk)
>  {
> -       struct sock_exterr_skb *serr;
> +       struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
>         struct rxrpc_transport *trans;
>         struct rxrpc_local *local = sk->sk_user_data;
>         struct rxrpc_peer *peer;
> @@ -42,7 +42,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
>                 _leave("UDP socket errqueue empty");
>                 return;
>         }
> -       if (!skb->len) {
> +       if (!skb->len && serr->ee.ee_origin == SO_EE_TIMESTAMPING) {
>                 _leave("UDP empty message");
>                 kfree_skb(skb);
>                 return;
> @@ -50,7 +50,6 @@ void rxrpc_UDP_error_report(struct sock *sk)
>
>         rxrpc_new_skb(skb);
>
> -       serr = SKB_EXT_ERR(skb);
>         addr = *(__be32 *)(skb_network_header(skb) + serr->addr_offset);
>         port = serr->port;
>
> --
> 2.2.0.rc0.207.ga3a616c
>
