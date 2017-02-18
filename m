From: Daniel J Blueman <daniel@quora.org>
Subject: Re: [4.9.10] ip_route_me_harder() reading off-slab
Date: Sat, 18 Feb 2017 14:56:13 +0800
Message-ID: <CAMVG2sv5+4HsBD1nBiwAOHppB0ZWJ5Ojk2wQDTC_XLSmytQePA@mail.gmail.com>
References: <CAMVG2sszgMW0C3LB-u4bqyMYFgnarXspn9iX0GF9+KMW0A0bJg@mail.gmail.com>
 <1487309781.1311.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jan Beulich <JBeulich@suse.com>,
        Netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34532 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdBRHDH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 02:03:07 -0500
Received: by mail-vk0-f65.google.com with SMTP id r136so5194846vke.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 23:03:06 -0800 (PST)
In-Reply-To: <1487309781.1311.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 February 2017 at 13:36, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-02-17 at 12:36 +0800, Daniel J Blueman wrote:
>> When booting a VM in libvirt/KVM attached to a local bridge and KASAN
>> enabled on 4.9.10, we see a stream of KASAN warnings about off-slab
>> access [1].
>>
>> Let me know if you'd like more debug.
>
> Could you try the following patch ?
>
> Thanks !
>
> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
> index b3cc1335adbc1a20dcd225d0501b0a286d27e3c8..18839e59da849f0988924bcbc9873965a3681eb0 100644
> --- a/net/ipv4/netfilter.c
> +++ b/net/ipv4/netfilter.c
> @@ -23,7 +23,8 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
>         struct rtable *rt;
>         struct flowi4 fl4 = {};
>         __be32 saddr = iph->saddr;
> -       __u8 flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
> +       struct sock *sk = skb->sk;
> +       __u8 flags = sk && sk_fullsock(sk) ? inet_sk_flowi_flags(sk) : 0;
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

Fine work! This nicely resolves the issue. I'll test Florian's
proposed fix also.

Tested-by: Daniel J Blueman <daniel@quora.org>

Thanks,
  Dan
-- 
Daniel J Blueman
