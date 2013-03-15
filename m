From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.6+, gre+ipsec+forwarding = IP fragmentation broken
Date: Fri, 15 Mar 2013 15:03:21 +0200
Message-ID: <20130315150321.621d705e@vostro>
References: <20130313171453.0297f179@vostro>
	<20130315112516.4b1651ca@vostro>
	<20130315133820.006a42f6@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:53699 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab3CONCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 09:02:44 -0400
Received: by mail-ea0-f174.google.com with SMTP id q10so1557507eaj.33
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 06:02:40 -0700 (PDT)
In-Reply-To: <20130315133820.006a42f6@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Mar 2013 13:38:20 +0200
Timo Teras <timo.teras@iki.fi> wrote:

> [snip]
> Though, this implies that GSO cannot be used in ip_gre if ttl != inherit.
> 
> I added some ip_gre debugging and the following seems to happen:
> 
> - the mtu is calculated correctly on xmit path:
>   dst_mtu(&rt->dst) = 1458 (the tunnel's XFRMed IPv4 path)
> 
> - skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
>   is called with mtu=1430, which seems correct
> 
> - dst_mtu(skb_dst(skb)) seems to still return after above call the
>   value 1472 which is wrong. so update_pmtu is not working.
> 
> - skb->dev->ifindex implies skb->dev points to gre device when
>   update_pmtu is being called (and not the ethX from which the packet
>   was received), so ip_rt_update_pmtu() which eventually calls
>   build_skb_flow_key() is likely using wrong ifindex for the flow

One more observation is that the outer dst is an input route. And it
seems that input routes do not consult nexthop exception tables for
setting the rt_pmtu. Thus rt_pmtu is never set for forwarding entries.

- Timo
