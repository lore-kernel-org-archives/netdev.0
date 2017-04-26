From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6: check skb->protocol before lookup for nexthop
Date: Wed, 26 Apr 2017 14:51:52 -0400 (EDT)
Message-ID: <20170426.145152.1344913070297099703.davem@davemloft.net>
References: <1493156235-9823-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com,
        steffen.klassert@secunet.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965496AbdDZSvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:51:53 -0400
In-Reply-To: <1493156235-9823-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 25 Apr 2017 14:37:15 -0700

> Andrey reported a out-of-bound access in ip6_tnl_xmit(), this
> is because we use an ipv4 dst in ip6_tnl_xmit() and cast an IPv4
> neigh key as an IPv6 address:
> 
>         neigh = dst_neigh_lookup(skb_dst(skb),
>                                  &ipv6_hdr(skb)->daddr);
>         if (!neigh)
>                 goto tx_err_link_failure;
> 
>         addr6 = (struct in6_addr *)&neigh->primary_key; // <=== HERE
>         addr_type = ipv6_addr_type(addr6);
> 
>         if (addr_type == IPV6_ADDR_ANY)
>                 addr6 = &ipv6_hdr(skb)->daddr;
> 
>         memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
> 
> Also the network header of the skb at this point should be still IPv4
> for 4in6 tunnels, we shold not just use it as IPv6 header.
> 
> This patch fixes it by checking if skb->protocol is ETH_P_IPV6: if it
> is, we are safe to do the nexthop lookup using skb_dst() and
> ipv6_hdr(skb)->daddr; if not (aka IPv4), we have no clue about which
> dest address we can pick here, we have to rely on callers to fill it
> from tunnel config, so just fall to ip6_route_output() to make the
> decision.
> 
> Fixes: ea3dc9601bda ("ip6_tunnel: Add support for wildcard tunnel endpoints.")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks Cong.
