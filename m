From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 4/8] net: ipv4: Convert inet_rtm_getroute to
 rcu versions of route lookup
Date: Wed, 31 May 2017 21:34:51 -0700
Message-ID: <CAJieiUho7kr9WhnZDL_BZzKNz5tShq3ozi_fECgw2UjoKhC4hQ@mail.gmail.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
 <1495734160-47659-5-git-send-email-roopa@cumulusnetworks.com>
 <592F2373.7070909@gmail.com> <d3fa47fd-e717-88c0-701d-a408d9ad5207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: John Fastabend <john.fastabend@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Rami Rosen <rami.rosen@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:36853 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdFAEew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 00:34:52 -0400
Received: by mail-ua0-f174.google.com with SMTP id j17so21055763uag.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 21:34:52 -0700 (PDT)
In-Reply-To: <d3fa47fd-e717-88c0-701d-a408d9ad5207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 2:48 PM, David Ahern <dsahern@gmail.com> wrote:
> On 5/31/17 2:11 PM, John Fastabend wrote:
>>> @@ -2721,14 +2724,14 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>>>              skb->protocol   = htons(ETH_P_IP);
>>>              skb->dev        = dev;
>>>              skb->mark       = mark;
>>> -            err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
>>> +            err = ip_route_input_rcu(skb, dst, src, rtm->rtm_tos,
>>> +                                     dev, &res);
>>>
>>>              rt = skb_rtable(skb);
>>>              if (err == 0 && rt->dst.error)
>>>                      err = -rt->dst.error;
>>>      } else {
>>> -            rt = ip_route_output_key(net, &fl4);
>>> -
>>> +            rt = ip_route_output_key_hash_rcu(net, &fl4, &res, skb);
>>>              err = 0;
>>>              if (IS_ERR(rt))
>>>                      err = PTR_ERR(rt);
>>> @@ -2737,7 +2740,6 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>>>      if (err)
>>>              goto errout_free;
>>>
>>> -    skb_dst_set(skb, &rt->dst);
>>
>>
>> Why did you remove this? Neither ip_route_input() or ip_route_output_key()
>> seem to justify this with a quick scan on my side. Feel free to correct me
>> here.
>>
>
> original patch was done in January. I forget why I took it out. It is
> clearly needed to release the dst.

yes, looking at it now the attach is needed to release the dst.  The original
commit msg said "The rcu lock is held through the creation of the
response, so the
 rtable/dst does not need to be attached to the skb and is passed to
rt_fill_info directly."

> Might as well undo the argument
> change to rt_fill_info since it is attached to the skb. Something like
> this (whitespace damaged on paste - stupid Mac):

agree, I can submit the patch

>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index f1f2e5aaa2d6..93cca12a8319 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2547,8 +2547,9 @@ EXPORT_SYMBOL_GPL(ip_route_output_flow);
>  /* called with rcu_read_lock held */
>  static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32
> table_id,
>                         struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
> -                       u32 seq, struct rtable *rt)
> +                       u32 seq)
>  {
> +       struct rtable *rt = skb_rtable(skb);
>         struct rtmsg *r;
>         struct nlmsghdr *nlh;
>         unsigned long expires = 0;
> @@ -2750,6 +2751,8 @@ static int inet_rtm_getroute(struct sk_buff
> *in_skb, struct nlmsghdr *nlh,
>         if (err)
>                 goto errout_free;
>
> +       skb_dst_set(skb, &rt->dst);
> +
>         if (rtm->rtm_flags & RTM_F_NOTIFY)
>                 rt->rt_flags |= RTCF_NOTIFY;
>
> @@ -2763,8 +2766,7 @@ static int inet_rtm_getroute(struct sk_buff
> *in_skb, struct nlmsghdr *nlh,
>                                     fl4.flowi4_tos, res.fi, 0);
>         else
>                 err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
> -                                  NETLINK_CB(in_skb).portid,
> nlh->nlmsg_seq,
> -                                  rt);
> +                                  NETLINK_CB(in_skb).portid,
> nlh->nlmsg_seq);
>         if (err < 0)
>                 goto errout_free;
>
>
> Seems to work for me.
