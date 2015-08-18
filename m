From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2] net: Move VRF change to udp_sendmsg to function
Date: Tue, 18 Aug 2015 09:38:52 -0700
Message-ID: <CALx6S34YcAbV6F6GairCCamDB=ztcOMJeHR0qpnv8Y8i8ZDVfg@mail.gmail.com>
References: <1439912309-5726-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34248 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbbHRQix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 12:38:53 -0400
Received: by igui7 with SMTP id i7so87188087igu.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 09:38:52 -0700 (PDT)
In-Reply-To: <1439912309-5726-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 8:38 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Functionally equivalent, but as a separate function with VRF config
> check. After 2f52bdcf6ba ("net: Updates to netif_index_is_vrf") function
> completely compiles out if VRF is not enabled; additional CONFIG
> check is not needed.
>
> Suggested-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - removed inline per Dave's comment
> - removed IS_ENABLED(CONFIG_NET_VRF) check; no longer needed after 2f52bdcf6ba
>
>  net/ipv4/udp.c | 43 +++++++++++++++++++++++--------------------
>  1 file changed, 23 insertions(+), 20 deletions(-)
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index c0a15e7f359f..76c5e5e945f8 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -873,6 +873,24 @@ int udp_push_pending_frames(struct sock *sk)
>  }
>  EXPORT_SYMBOL(udp_push_pending_frames);
>
> +/* unconnected socket. If output device is enslaved to a VRF
> + * device lookup source address from VRF table.
> + */
> +static void udp_sendmsg_vrf_saddr(struct net *net, struct flowi4 *fl4,
> +                                  int oif, struct sock *sk)
> +{
> +       if (netif_index_is_vrf(net, oif)) {

Sorry, but I still don't like this. Anything resembling device
specific code should not be in UDP, TCP, IP, etc. Proper layering in
essential to keeping implementation of transport protocols efficient,
generic, and maintainable.

It looks like the purpose of this is to provide a means of setting an
alternate route/device specific source address. I would suggest that
you could abstract it out as such. Maybe by implementing:

IFF_ALT_SRC

netif_provides_alt_source(net, oif)

FLOWI_FLAG_ALT_SRC

The have udp_sendmsg_alt_saddr be the function called from udp_sendmsg.

Thanks,
Tom

> +               __u8 flow_flags = fl4->flowi4_flags;
> +               struct rtable *rt;
> +
> +               fl4->flowi4_flags = flow_flags | FLOWI_FLAG_VRFSRC;
> +               rt = ip_route_output_flow(net, fl4, sk);
> +               if (!IS_ERR(rt))
> +                       ip_rt_put(rt);
> +               fl4->flowi4_flags = flow_flags;
> +       }
> +}
> +
>  int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  {
>         struct inet_sock *inet = inet_sk(sk);
> @@ -1013,33 +1033,16 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>
>         if (!rt) {
>                 struct net *net = sock_net(sk);
> -               __u8 flow_flags = inet_sk_flowi_flags(sk);
>
>                 fl4 = &fl4_stack;
>
> -               /* unconnected socket. If output device is enslaved to a VRF
> -                * device lookup source address from VRF table. This mimics
> -                * behavior of ip_route_connect{_init}.
> -                */
> -               if (netif_index_is_vrf(net, ipc.oif)) {
> -                       flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
> -                                          RT_SCOPE_UNIVERSE, sk->sk_protocol,
> -                                          (flow_flags | FLOWI_FLAG_VRFSRC),
> -                                          faddr, saddr, dport,
> -                                          inet->inet_sport);
> -
> -                       rt = ip_route_output_flow(net, fl4, sk);
> -                       if (!IS_ERR(rt)) {
> -                               saddr = fl4->saddr;
> -                               ip_rt_put(rt);
> -                       }
> -               }
> -
>                 flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
>                                    RT_SCOPE_UNIVERSE, sk->sk_protocol,
> -                                  flow_flags,
> +                                  inet_sk_flowi_flags(sk),
>                                    faddr, saddr, dport, inet->inet_sport);
>
> +               udp_sendmsg_vrf_saddr(net, fl4, ipc.oif, sk);
> +
>                 security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
>                 rt = ip_route_output_flow(net, fl4, sk);
>                 if (IS_ERR(rt)) {
> --
> 2.3.2 (Apple Git-55)
>
