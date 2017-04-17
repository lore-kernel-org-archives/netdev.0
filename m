From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net-timestamp: avoid use-after-free in
 ip_recv_error
Date: Mon, 17 Apr 2017 13:00:48 -0400 (EDT)
Message-ID: <20170417.130048.875097215533305645.davem@davemloft.net>
References: <20170412232435.80455-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
        willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755387AbdDQRAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:00:54 -0400
In-Reply-To: <20170412232435.80455-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 12 Apr 2017 19:24:35 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Syzkaller reported a use-after-free in ip_recv_error at line
> 
>     info->ipi_ifindex = skb->dev->ifindex;
> 
> This function is called on dequeue from the error queue, at which
> point the device pointer may no longer be valid.
> 
> Save ifindex on enqueue in __skb_complete_tx_timestamp, when the
> pointer is valid or NULL. Store it in temporary storage skb->cb.
> 
> It is safe to reference skb->dev here, as called from device drivers
> or dev_queue_xmit. The exception is when called from tcp_ack_tstamp;
> in that case it is NULL and ifindex is set to 0 (invalid).
> 
> Do not return a pktinfo cmsg if ifindex is 0. This maintains the
> current behavior of not returning a cmsg if skb->dev was NULL.
> 
> On dequeue, the ipv4 path will cast from sock_exterr_skb to
> in_pktinfo. Both have ifindex as their first element, so no explicit
> conversion is needed. This is by design, introduced in commit
> 0b922b7a829c ("net: original ingress device index in PKTINFO"). For
> ipv6 ip6_datagram_support_cmsg converts to in6_pktinfo.
> 
> Fixes: 829ae9d61165 ("net-timestamp: allow reading recv cmsg on errqueue with origin tstamp")
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks.

In the future please don't insert empty lines between the Fixes: and
other tags.

Thanks.
