From: Wei Wang <tracywwnj@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Mon, 21 Mar 2016 10:13:41 -0700
Message-ID: <CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
	<20160316.195341.68257764618999441.davem@davemloft.net>
	<1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
	<CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
	<CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
	<CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
	<CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:33765 "EHLO
	mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251AbcCURNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 13:13:43 -0400
Received: by mail-vk0-f67.google.com with SMTP id q138so11914547vkb.0
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 10:13:42 -0700 (PDT)
In-Reply-To: <CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Cong,

This solution probably will not work.
First of all, if you look into __ip6_rt_update_pmtu(), it creates a
new dst and this dst does not get passed back to its caller. So unless
we tweak this function to pass the new dst back, we can only update
sk->sk_dst_cache inside the function itself.
Secondly, ip6_update_pmtu is called in multiple places. Not only here.
I am not sure how many places need to be changed like this. It seems
not a good thing to do.

Thanks.
Wei

On Fri, Mar 18, 2016 at 3:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 18, 2016 at 2:26 PM, Wei Wang <tracywwnj@gmail.com> wrote:
>> I don't think ip6_sk_update_pmtu() is a good place to put it as all it
>> does is to call ip6_update_pmtu(). And ip6_update_pmtu() does the
>> route lookup and call __ip6_rt_update_pmtu.
>> We can put it in ip6_update_pmtu(). But that still means we need to
>> pass sk to ip6_update_pmtu() and I don't think it makes any difference
>> compared to the current fix.
>>
>
> Well, your patch touches all the callers of ip6_update_pmtu() , if you just
> fix ip6_sk_update_pmtu() as I suggested, you only need to change one
> function, ideally. And the ipv4 code is there, although I am not sure, it
> looks like we can just mimic the logic here:
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ed44663..b88c2ff 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1417,8 +1417,28 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);
>
>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>  {
> -       ip6_update_pmtu(skb, sock_net(sk), mtu,
> -                       sk->sk_bound_dev_if, sk->sk_mark);
> +       const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
> +       struct net *net = sock_net(sk);
> +       struct dst_entry *dst;
> +       struct flowi6 fl6;
> +
> +       bh_lock_sock(sk);
> +
> +       memset(&fl6, 0, sizeof(fl6));
> +       fl6.flowi6_oif = sk->sk_bound_dev_if;
> +       fl6.flowi6_mark = sk->sk_mark ? : IP6_REPLY_MARK(net, skb->mark);
> +       fl6.daddr = iph->daddr;
> +       fl6.saddr = iph->saddr;
> +       fl6.flowlabel = ip6_flowinfo(iph);
> +
> +       dst = ip6_route_output(net, NULL, &fl6);
> +       if (!dst->error)
> +               __ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
> +
> +       sk_dst_set(sk, &rt->dst);
> +       bh_unlock_sock(sk);
> +
> +       dst_release(dst);
>  }
>
>
> Please don't judge me on the code, it could still miss a lot of things,
> but it can show my idea...
