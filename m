From: Wei Wang <tracywwnj@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Wed, 23 Mar 2016 16:57:22 -0700
Message-ID: <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
References: <20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
	<CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
	<CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
	<CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
	<CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
	<CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
	<20160322060220.GA50824@kafai-mba.local>
	<CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
	<20160322173939.GA53936@kafai-mba.local>
	<CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
	<CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
	<1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:34562 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbcCWX5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 19:57:23 -0400
Received: by mail-vk0-f48.google.com with SMTP id e185so39107388vkb.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 16:57:23 -0700 (PDT)
In-Reply-To: <1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What about something like this:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed44663..21b4102 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1394,6 +1394,19 @@ static void ip6_rt_update_pmtu(struct dst_entry
*dst, struct sock *sk,
    __ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
 }

+static void ip6_fill_in_flow(struct flowi6 *fl6,  struct net *net,
+                  struct sk_buff *skb, int oif, u32 mark)
+{
+   const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
+
+   memset(fl6, 0, sizeof(fl6));
+   fl6->flowi6_oif = oif;
+   fl6->flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
+   fl6->daddr = iph->daddr;
+   fl6->saddr = iph->saddr;
+   fl6->flowlabel = ip6_flowinfo(iph);
+}
+
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
             int oif, u32 mark)
 {
@@ -1401,13 +1414,7 @@ void ip6_update_pmtu(struct sk_buff *skb,
struct net *net, __be32 mtu,
    struct dst_entry *dst;
    struct flowi6 fl6;

-   memset(&fl6, 0, sizeof(fl6));
-   fl6.flowi6_oif = oif;
-   fl6.flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
-   fl6.daddr = iph->daddr;
-   fl6.saddr = iph->saddr;
-   fl6.flowlabel = ip6_flowinfo(iph);
-
+   ip6_fill_in_flow(&fl6, net, skb, oif, mark);
    dst = ip6_route_output(net, NULL, &fl6);
    if (!dst->error)
        __ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
@@ -1417,8 +1424,22 @@ EXPORT_SYMBOL_GPL(ip6_update_pmtu);

 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 {
-   ip6_update_pmtu(skb, sock_net(sk), mtu,
+   struct ipv6_pinfo *np = inet6_sk(sk);
+   struct dst_entry *dst_new;
+   struct flowi6 fl6;
+   struct net *net = sock_net(sk);
+
+   ip6_update_pmtu(skb, net, mtu,
+           sk->sk_bound_dev_if, sk->sk_mark);
+
+   if (sk->sk_state == TCP_ESTABLISHED &&
+       !sk_dst_check(sk, np->dst_cookie)) {
+       ip6_fill_in_flow(&fl6, net, skb,
            sk->sk_bound_dev_if, sk->sk_mark);
+       dst_new = ip6_route_output(net, NULL, &fl6);
+       if (!IS_ERR(dst_new))
+           ip6_dst_store(sk, dst_new, NULL, NULL);
+   }
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);


Thanks.
Wei

On Tue, Mar 22, 2016 at 4:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-03-22 at 13:13 -0700, Cong Wang wrote:
>> On Tue, Mar 22, 2016 at 11:03 AM, Wei Wang <tracywwnj@gmail.com> wrote:
>> > Thanks Martin and Cong.
>> >
>> > I guess then we are going with the following fix in ip6_sk_update_pmtu():
>> > 1. call ip6_upate_pmtu() as it is
>> > 2. do a dst_check()
>> > 3. re-lookup() if it is invalid
>> > 4. and then do a ip6_dst_store()/dst_set
>>
>> Exactly, please try the attached patch. Note I did nothing more than a
>> compile test.
>>
>> Does it make sense to you now?
>
>
> Hard to reply on your patch as it was not inlined.
>
> 1) Lot of code duplication, for some reason I do not yet understand.
>
> ip6_sk_update_pmtu() and ip6_update_pmtu() will basically do the same
> thing...
>
> 2)
>
> +       if (sk->sk_state == TCP_ESTABLISHED)
> +               ip6_dst_store(sk, dst, &iph->daddr, &iph->saddr);
> +out:
>
>
> ip6_dst_store() will do :
>
> np->daddr_cache = daddr;  (&iph->daddr)
> np->saddr_cache = saddr;  (&iph->saddr)
>
> So when skb is freed, daddr_cache & saddr_cache point to freed data.
>
>
>
>
