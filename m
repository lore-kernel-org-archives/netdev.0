From: Wei Wang <tracywwnj@gmail.com>
Subject: Re: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on
 pmtu events if possible
Date: Thu, 24 Mar 2016 14:38:14 -0700
Message-ID: <CAC15z3iWRx3XUhRD_ZNz_KdJx=ezi4C3f29iV9yssxwfLaKTYw@mail.gmail.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
	<1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Wei Wang <weiwan@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:36819 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbcCXViP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 17:38:15 -0400
Received: by mail-yw0-f182.google.com with SMTP id g3so76463824ywa.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 14:38:15 -0700 (PDT)
In-Reply-To: <1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +       if (new)
> +               ip6_dst_store(sk, dst, NULL, NULL);
> +
I read through the code for ip6_dst_store(), the last 2 params are for
sk->daddr_cache and sk->saddr_cache.
Those are examined and used in ip6_sk_dst_lookup_flow(). If those 2
(mostly only check sk->daddr_cache) are valid, it will try to use
sk->sk_dst_cache and avoid ip6_route_output() call. If we put it as
NULL, it is guaranteed to not pass the validation check and do
ip6_route_output() lookup.
So we probably don't want to use NULL but something similar as used in
udpv6_sendmsg() like the following?
            ip6_dst_store(sk, dst,
                      ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr) ?
                      &sk->sk_v6_daddr : NULL,
#ifdef CONFIG_IPV6_SUBTREES
                      ipv6_addr_equal(&fl6.saddr, &np->saddr) ?
                      &np->saddr :
#endif
                      NULL);


Thanks.
Wei
