From: Daniel J Blueman <daniel@quora.org>
Subject: Re: [4.9.10] ip_route_me_harder() reading off-slab
Date: Mon, 27 Feb 2017 22:41:48 +0800
Message-ID: <CAMVG2ssH8F-BgUzCxZdcAYgYo_2HMK_0=drg-JS596TT7A=5wA@mail.gmail.com>
References: <CAMVG2ssKxnEsu4=orZyB3UsHwT2CZhpWKFn2UmtoPOEu1KMHPw@mail.gmail.com>
 <20170217073928.GA25854@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jan Beulich <JBeulich@suse.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        netfilter-devel@vger.kernel.org, pablo@netfilter.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:33910 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751497AbdB0Omm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 09:42:42 -0500
Received: by mail-ua0-f193.google.com with SMTP id e4so7436511uae.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 06:41:49 -0800 (PST)
In-Reply-To: <20170217073928.GA25854@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 February 2017 at 15:39, Florian Westphal <fw@strlen.de> wrote:
> Daniel J Blueman <daniel@quora.org> wrote:
>
> [ CC nf-devel, pablo ]
>
>> When booting a VM in libvirt/KVM attached to a local bridge and KASAN
>> enabled on 4.9.10, we see a stream of KASAN warnings about off-slab
>> access [1].
>>
>> Let me know if you'd like more debug.
>
> Does this patch help?
>
> Subject: [PATCH nf] netfilter: use skb_to_full_sk in ip_route_me_harder
>
> inet_sk(skb->sk) is illegal in case skb is attached to request socket.
>
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Reported by: Daniel J Blueman <daniel@quora.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/ipv4/netfilter.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
> index b3cc1335adbc..c0cc6aa8cfaa 100644
> --- a/net/ipv4/netfilter.c
> +++ b/net/ipv4/netfilter.c
> @@ -23,7 +23,8 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
>         struct rtable *rt;
>         struct flowi4 fl4 = {};
>         __be32 saddr = iph->saddr;
> -       __u8 flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
> +       const struct sock *sk = skb_to_full_sk(skb);
> +       __u8 flags = sk ? inet_sk_flowi_flags(sk) : 0;
>         struct net_device *dev = skb_dst(skb)->dev;
>         unsigned int hh_len;
>
> @@ -40,7 +41,7 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
>         fl4.daddr = iph->daddr;
>         fl4.saddr = saddr;
>         fl4.flowi4_tos = RT_TOS(iph->tos);
> -       fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
> +       fl4.flowi4_oif = sk ? sk->sk_bound_dev_if : 0;
>         if (!fl4.flowi4_oif)
>                 fl4.flowi4_oif = l3mdev_master_ifindex(dev);
>         fl4.flowi4_mark = skb->mark;
> @@ -61,7 +62,7 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
>             xfrm_decode_session(skb, flowi4_to_flowi(&fl4), AF_INET) == 0) {
>                 struct dst_entry *dst = skb_dst(skb);
>                 skb_dst_set(skb, NULL);
> -               dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
> +               dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), sk, 0);
>                 if (IS_ERR(dst))
>                         return PTR_ERR(dst);
>                 skb_dst_set(skb, dst);

Apologies for the delays; this also addresses the issue just fine.

Tested-by: Daniel J Blueman <daniel@quora.org>

Dan
-- 
Daniel J Blueman
