From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v3] openvswitch: Fix egress tunnel info.
Date: Fri, 23 Oct 2015 12:47:09 -0700
Message-ID: <CALnjE+p644A-H1Kj3cc2WE_NOwyeU-8A_8bfvjp_ykUxcUmWeg@mail.gmail.com>
References: <1445563036-9623-1-git-send-email-pshelar@nicira.com>
	<20151023141738.4db54324@griffin>
	<CALnjE+oOrvGmXuW0aexHt_CO2W7DEMLJyHzW3psCFuK+aG+5Yg@mail.gmail.com>
	<20151023202207.1533982b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33994 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbbJWTrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 15:47:10 -0400
Received: by iow1 with SMTP id 1so134774265iow.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 12:47:10 -0700 (PDT)
In-Reply-To: <20151023202207.1533982b@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 11:22 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 23 Oct 2015 10:30:24 -0700, Pravin Shelar wrote:
...
>
>> > This doesn't do what the name suggests and is, actually, ovs specific.
>> > The ip_tunnel_info can be provided as a part of lwtstate and this
>> > function should handle that case, too. This is not a problem for
>> > net.git, as the function just returns EINVAL in such case, but should
>> > be addressed for net-next.git. As ovs is currently the only user, I'd
>> > be also fine with just a comment stating that, so it's clear for future
>> > users of this function that it needs to be extended before it can be
>> > used out of ovs.
>> >
>>
>> I considered lwstate, but I am reluctant to add this complexity
>> without a usecase.
>
> I don't think it's complex. See the quick and dirty patch below (that
> has even a negative diffstat):
>
> diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
> index ce009710120c..3a1d3966a79e 100644
> --- a/include/net/dst_metadata.h
> +++ b/include/net/dst_metadata.h
> @@ -60,36 +60,25 @@ static inline struct metadata_dst *tun_rx_dst(int md_size)
>         return tun_dst;
>  }
>
> -static inline struct metadata_dst *tun_dst_unclone(struct sk_buff *skb)
> +static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb)
>  {
> -       struct metadata_dst *md_dst = skb_metadata_dst(skb);
> -       int md_size = md_dst->u.tun_info.options_len;
> +       struct metadata_dst *dst;
> +       struct ip_tunnel_info *info = skb_tunnel_info(skb);
>         struct metadata_dst *new_md;
>
> -       if (!md_dst)
> +       if (!info)
>                 return ERR_PTR(-EINVAL);
> -
> -       new_md = metadata_dst_alloc(md_size, GFP_ATOMIC);
> +       new_md = metadata_dst_alloc(info->options_len, GFP_ATOMIC);
>         if (!new_md)
>                 return ERR_PTR(-ENOMEM);
>
> -       memcpy(&new_md->u.tun_info, &md_dst->u.tun_info,
> -              sizeof(struct ip_tunnel_info) + md_size);
> +       memcpy(&new_md->u.tun_info, info,
> +              sizeof(struct ip_tunnel_info) + info->options_len);
>         skb_dst_drop(skb);
>         dst_hold(&new_md->dst);
>         skb_dst_set(skb, &new_md->dst);
> -       return new_md;
> -}
> -
This is not complete code. I found couple of issues with it.

This code does not copy lwtunnel_state state into new dst.
And it is converting lwtunnel dst into metadata dst.

> -static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb)
> -{
> -       struct metadata_dst *dst;
> -
> -       dst = tun_dst_unclone(skb);
> -       if (IS_ERR(dst))
> -               return NULL;
>
> -       return &dst->u.tun_info;
> +       return info;
>  }
>
