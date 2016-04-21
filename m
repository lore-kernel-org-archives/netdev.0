From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Thu, 21 Apr 2016 05:59:06 -0700
Message-ID: <1461243546.7627.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160421074042.GF3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35304 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbcDUM7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 08:59:08 -0400
Received: by mail-pa0-f50.google.com with SMTP id fs9so29175025pac.2
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 05:59:07 -0700 (PDT)
In-Reply-To: <20160421074042.GF3347@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-21 at 09:40 +0200, Steffen Klassert wrote:
> This partly reverts the below mentioned patch because on
> forwarding, such skbs can't be offloaded to a NIC.
> 
> We need this to get IPsec GRO for forwarding to work properly,
> otherwise the GRO aggregated packets get segmented again by
> the GSO layer. Although discovered when implementing IPsec GRO,
> this is a general problem in the forwarding path.
> 
> -------------------------------------------------------------------------
> commit 8a29111c7ca68d928dfab58636f3f6acf0ac04f7
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Oct 8 09:02:23 2013 -0700
> 
>     net: gro: allow to build full sized skb
> 
>     skb_gro_receive() is currently limited to 16 or 17 MSS per GRO skb,
>     typically 24616 bytes, because it fills up to MAX_SKB_FRAGS frags.
> 
>     It's relatively easy to extend the skb using frag_list to allow
>     more frags to be appended into the last sk_buff.
> 
>     This still builds very efficient skbs, and allows reaching 45 MSS per
>     skb.
> 
>     (45 MSS GRO packet uses one skb plus a frag_list containing 2 additional
>     sk_buff)
> 
>     High speed TCP flows benefit from this extension by lowering TCP stack
>     cpu usage (less packets stored in receive queue, less ACK packets
>     processed)
> 
>     Forwarding setups could be hurt, as such skbs will need to be
>     linearized, although its not a new problem, as GRO could already
>     provide skbs with a frag_list.
> 
>     We could make the 65536 bytes threshold a tunable to mitigate this.
> 
>     (First time we need to linearize skb in skb_needs_linearize(), we could
>     lower the tunable to ~16*1460 so that following skb_gro_receive() calls
>     build smaller skbs)
> 
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> ---------------------------------------------------------------------------
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
> 
> Hi Eric, this is a followup on our discussion at the netdev
> conference. Would you still be ok with this revert, or do
> you think there is a better solution in sight?

Note that some GRO enabled drivers would still generate frag_list.

(This happens if they are using skb with some TCP payload in skb->head
and skb->head was allocated with kmalloc())

We have sysctl_max_skb_frags sysctl, we might have a sysctl
enabling/disabling GRO from building any frag_list.
Or simply reuse an existing one, like /proc/sys/net/ipv4/ip_forward ?)

Here at Google, we increased MAX_SKB_FRAGS, but this is a rather
intrusive change to be upstreamed :(
