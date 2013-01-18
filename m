From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: check if dereference of ipv6 header is safe
Date: Fri, 18 Jan 2013 04:08:19 +0100
Message-ID: <20130118030819.GA20324@order.stressinduktion.org>
References: <20130117035652.GB23782@order.stressinduktion.org> <20130118020612.GA14833@order.stressinduktion.org> <1358475697.11051.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35204 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342Ab3ARDIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 22:08:20 -0500
Content-Disposition: inline
In-Reply-To: <1358475697.11051.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 06:21:37PM -0800, Eric Dumazet wrote:
> But we use a 'struct iphdr' here, not a ipv6hdr
> 
> So we basically implicitely rely on sizeof(struct iphdr) <=
> sizeof(struct ipv6hdr)
> 
> I would leave the pskb_may_pull() call and fix it, even if not really
> needed.

Please correct me if I am wrong:

The callstack as captured in ipip6_rcv:
    ipip6_rcv+0xcd/0x680 [sit]
    tunnel64_rcv+0x4a/0x174 [tunnel4]
    ip_local_deliver+0x152/0x470
    ? ip_local_deliver+0x75/0x470
    ip_rcv+0x36d/0x650

ip_rcv does first check if the ipv4 header is complete (inclusive options) and
passes control to ip_local_deliver which calls __skb_pull(skb,
ip_hdrlen(skb)). So ->data is forwarded behind the ipv4 header. The next
pskb_may_pull check would check if the necessary amount of data behind the
ipv4 header is available hence I assume the check in tunnel64_rcv is enough:

    109 static int tunnel64_rcv(struct sk_buff *skb)
    110 {
    111         struct xfrm_tunnel *handler;
    112 
    113         if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
    114                 goto drop;
    115 
    116         for_each_tunnel_rcu(tunnel64_handlers, handler)
    117                 if (!handler->handler(skb))
    118                         return 0;

Thanks,

  Hannes
