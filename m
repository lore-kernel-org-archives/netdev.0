From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 04/11] udp: Handle VRF device in sendmsg
Date: Fri, 14 Aug 2015 09:27:32 -0700
Message-ID: <CALx6S34ymDARX9EjCUZtHzd=+iUpry5WbCR4axXSDFBhVSTDUw@mail.gmail.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
	<1439499551-90231-5-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, svaidya@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37821 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104AbbHNQ1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 12:27:33 -0400
Received: by igui7 with SMTP id i7so15489332igu.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 09:27:32 -0700 (PDT)
In-Reply-To: <1439499551-90231-5-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 1:59 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> For unconnected UDP sockets using a VRF device lookup source address
> based on VRF table. This allows the UDP header to be properly setup
> before showing up at the VRF device via the dst.
>
> Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv4/udp.c | 22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 83aa604f9273..7af5052e3b1f 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1013,11 +1013,31 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>
>         if (!rt) {
>                 struct net *net = sock_net(sk);
> +               __u8 flow_flags = inet_sk_flowi_flags(sk);
>
>                 fl4 = &fl4_stack;
> +
> +               /* unconnected socket. If output device is enslaved to a VRF
> +                * device lookup source address from VRF table. This mimics
> +                * behavior of ip_route_connect{_init}.
> +                */
> +               if (netif_index_is_vrf(net, ipc.oif)) {
> +                       flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
> +                                          RT_SCOPE_UNIVERSE, sk->sk_protocol,
> +                                          (flow_flags | FLOWI_FLAG_VRFSRC),
> +                                          faddr, saddr, dport,
> +                                          inet->inet_sport);
> +
> +                       rt = ip_route_output_flow(net, fl4, sk);
> +                       if (!IS_ERR(rt)) {
> +                               saddr = fl4->saddr;
> +                               ip_rt_put(rt);
> +                       }
> +               }
> +

I really don't like this. It seems like you're putting device specific
code in a critical L4 data path function. Also, does ipv6/udp.c need
be updated similarly? Why can't VRF be abstracted out in routing
lookups?

Tom

>                 flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
>                                    RT_SCOPE_UNIVERSE, sk->sk_protocol,
> -                                  inet_sk_flowi_flags(sk),
> +                                  flow_flags,
>                                    faddr, saddr, dport, inet->inet_sport);
>
>                 security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
> --
> 2.3.2 (Apple Git-55)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
