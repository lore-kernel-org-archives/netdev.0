From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [Patch net-next 1/2] ping: some cleanup for net/ipv4/ping.c
Date: Mon, 3 Jun 2013 16:02:59 +0900
Message-ID: <CAKD1Yr0zHsM85ZJLwCeE6NkEZnaMqs3ba1PyOa_M09UB6i99=g@mail.gmail.com>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f42.google.com ([209.85.128.42]:41324 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab3FCHDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:03:20 -0400
Received: by mail-qe0-f42.google.com with SMTP id s14so394803qeb.15
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 00:03:19 -0700 (PDT)
In-Reply-To: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 3, 2013 at 2:55 PM, Cong Wang <amwang@redhat.com> wrote:
> -static inline int ping_supported(int family, int type, int code)
> +static inline bool ping_supported(int family, int type, int code)
>  {
> -       return (family == AF_INET && type == ICMP_ECHO && code == 0) ||
> -              (family == AF_INET6 && type == ICMPV6_ECHO_REQUEST && code == 0);
> +       if (family == AF_INET) {
> +               if (type == ICMP_ECHO && code == 0)
> +                       return true;
> +#if IS_ENABLED(CONFIG_IPV6)
> +       } else if (family == AF_INET6) {
> +               if (type == ICMPV6_ECHO_REQUEST && code == 0)
> +                       return true;
> +#endif
> +       }
> +       return false;
>  }

I don't think it's necessary to #ifdef out code here. It's not needed
to get the code to compile, because AF_INET6 and ICMPV6_ECHO_REQUEST
are defined even if CONFIG_IPV6=n. It's also not necessary at runtime,
because if we get here with family = AF_INET6 even though IPv6 is
disabled, then then there's already a problem. Adding the ifdef also
makes the function much hard to read.

>
>  /*
> @@ -472,11 +480,13 @@ void ping_err(struct sk_buff *skb, int offset, u32 info)
>                 type = icmp_hdr(skb)->type;
>                 code = icmp_hdr(skb)->code;
>                 icmph = (struct icmphdr *)(skb->data + offset);
> +#if IS_ENABLED(CONFIG_IPV6)
>         } else if (skb->protocol == htons(ETH_P_IPV6)) {
>                 family = AF_INET6;
>                 type = icmp6_hdr(skb)->icmp6_type;
>                 code = icmp6_hdr(skb)->icmp6_code;
>                 icmph = (struct icmphdr *) (skb->data + offset);
> +#endif
>         } else {
>                 BUG();
>         }

I think this is unnecessary too. ping_err is only called by icmp_err
and by icmpv6_err, and if icmp_err is calling us on an IPv4 packet, or
if icmpv6_err is calling us when IPv6 is unloaded, then there are
bigger problems.
