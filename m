From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Fri, 26 Aug 2016 13:59:59 -0700
Message-ID: <CAKgT0UerR_D7xi6GNpJbB0cwjNLFCM4_7BMe2Yg-XPZ+u8dcuw@mail.gmail.com>
References: <20160823052030.GI3735@gauss.secunet.com> <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com> <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
 <20160825110019.GR3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:33180 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbcHZVAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 17:00:01 -0400
Received: by mail-it0-f54.google.com with SMTP id j128so5592808ith.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 14:00:01 -0700 (PDT)
In-Reply-To: <20160825110019.GR3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 4:00 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 989a362..ac46233 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1190,7 +1190,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
>  struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                  netdev_features_t features)
>  {
> -       bool udpfrag = false, fixedid = false, encap;
> +       bool udpfrag = false, fixedid = false, gso_partial, encap;
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         const struct net_offload *ops;
>         unsigned int offset = 0;
> @@ -1243,6 +1243,8 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>         if (IS_ERR_OR_NULL(segs))
>                 goto out;
>
> +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>         skb = segs;
>         do {
>                 iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
> @@ -1252,7 +1254,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                 iph->frag_off |= htons(IP_MF);
>                         offset += skb->len - nhoff - ihl;
>                         tot_len = skb->len - nhoff;
> -               } else if (skb_is_gso(skb)) {
> +               } else if (skb_is_gso(skb) && gso_partial) {
>                         if (!fixedid) {
>                                 iph->id = htons(id);
>                                 id += skb_shinfo(skb)->gso_segs;

So I was thinking about it and it occurred to me that this part of the
patch has a slight bug.  What you may want to do is take this section
and merge it with the next so that you get the IPv4 IDs right.  Right
now you are skipping this section so id is only increments by 1 in the
next section.  This will result in overlapping IDs in the final
result.  It should be updating like the code here shows for the
gso_partial portion.

- Alex
