From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Thu, 24 Mar 2016 11:32:28 -0700
Message-ID: <20160324183228.GA95371@kafai-mba.local>
References: <CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
 <CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
 <CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
 <20160322060220.GA50824@kafai-mba.local>
 <CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
 <20160322173939.GA53936@kafai-mba.local>
 <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
 <CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
 <1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Wei Wang <weiwan@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wei Wang <tracywwnj@gmail.com>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:63159 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbcCXSch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:32:37 -0400
Content-Disposition: inline
In-Reply-To: <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 04:57:22PM -0700, Wei Wang wrote:
> What about something like this:
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ed44663..21b4102 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1394,6 +1394,19 @@ static void ip6_rt_update_pmtu(struct dst_entry
> *dst, struct sock *sk,
>     __ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
>  }
>
> +static void ip6_fill_in_flow(struct flowi6 *fl6,  struct net *net,
> +                  struct sk_buff *skb, int oif, u32 mark)
> +{
> +   const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
> +
> +   memset(fl6, 0, sizeof(fl6));
> +   fl6->flowi6_oif = oif;
> +   fl6->flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
> +   fl6->daddr = iph->daddr;
> +   fl6->saddr = iph->saddr;
> +   fl6->flowlabel = ip6_flowinfo(iph);
> +}
> +
>  void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
>              int oif, u32 mark)
>  {
> @@ -1401,13 +1414,7 @@ void ip6_update_pmtu(struct sk_buff *skb,
> struct net *net, __be32 mtu,
>     struct dst_entry *dst;
>     struct flowi6 fl6;
>
> -   memset(&fl6, 0, sizeof(fl6));
> -   fl6.flowi6_oif = oif;
> -   fl6.flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
> -   fl6.daddr = iph->daddr;
> -   fl6.saddr = iph->saddr;
> -   fl6.flowlabel = ip6_flowinfo(iph);
> -
> +   ip6_fill_in_flow(&fl6, net, skb, oif, mark);
>     dst = ip6_route_output(net, NULL, &fl6);
>     if (!dst->error)
>         __ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
> @@ -1417,8 +1424,22 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);
>
>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>  {
> -   ip6_update_pmtu(skb, sock_net(sk), mtu,
> +   struct ipv6_pinfo *np = inet6_sk(sk);
> +   struct dst_entry *dst_new;
> +   struct flowi6 fl6;
> +   struct net *net = sock_net(sk);
> +
> +   ip6_update_pmtu(skb, net, mtu,
> +           sk->sk_bound_dev_if, sk->sk_mark);
> +
> +   if (sk->sk_state == TCP_ESTABLISHED &&
> +       !sk_dst_check(sk, np->dst_cookie)) {
sk_dst_check could hold a refcnt to the current sk->sk_dst_cache.
It has to be released.

> +       ip6_fill_in_flow(&fl6, net, skb,
>             sk->sk_bound_dev_if, sk->sk_mark);
> +       dst_new = ip6_route_output(net, NULL, &fl6);
> +       if (!IS_ERR(dst_new))
> +           ip6_dst_store(sk, dst_new, NULL, NULL);
Has sk been locked before ip6_dst_store?

Some fast path may do __sk_dst_get() which does not refcnt the sk->sk_dst_cache.

However, after a quick look, it seems udpv6_sendmsg() is calling ip6_dst_store()
after release_sock also.  I could be missing something.
