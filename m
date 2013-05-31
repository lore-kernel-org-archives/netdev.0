From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] gro: should aggregate frames without DF
Date: Fri, 31 May 2013 11:14:44 -0700
Message-ID: <CAPshTCg84TQs=k6=pFRBg5j5Vkn_JHKE_gQ7UkhYAA4S1izkBQ@mail.gmail.com>
References: <1370019752.5109.108.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:51475 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab3EaSOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 14:14:47 -0400
Received: by mail-lb0-f169.google.com with SMTP id 10so1998804lbf.0
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 11:14:44 -0700 (PDT)
In-Reply-To: <1370019752.5109.108.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 10:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> GRO on IPv4 doesn't aggregate frames if they don't have DF bit set.
>
> Some servers use IP_MTU_DISCOVER/IP_PMTUDISC_PROBE, so linux receivers
> are unable to aggregate this kind of traffic.
>
> The right thing to do is to allow aggregation as long as the DF bit has
> same value on all segments.
>
> bnx2x LRO does this correctly.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jerry Chu <hkchu@google.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> ---
>  net/ipv4/af_inet.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index b05ae96..328cc62 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1384,9 +1384,9 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
>         if (unlikely(ip_fast_csum((u8 *)iph, 5)))
>                 goto out_unlock;
>
> -       id = ntohl(*(__be32 *)&iph->id);
> -       flush = (u16)((ntohl(*(__be32 *)iph) ^ skb_gro_len(skb)) | (id ^ IP_DF));
> -       id >>= 16;
> +       flush = ntohs(iph->tot_len) ^ skb_gro_len(skb);
> +
> +       id = ntohs(iph->id);
>
>         for (p = *head; p; p = p->next) {
>                 struct iphdr *iph2;
> @@ -1407,6 +1407,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
>                 NAPI_GRO_CB(p)->flush |=
>                         (iph->ttl ^ iph2->ttl) |
>                         (iph->tos ^ iph2->tos) |
> +                       ((iph->frag_off ^ iph2->frag_off) & htons(IP_DF)) |
>                         ((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
>
>                 NAPI_GRO_CB(p)->flush |= flush;
>
>

Acked-by: Jerry Chu <hkchu@google.com>
