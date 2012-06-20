From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 14:38:40 +0200
Message-ID: <1340195920.4604.918.camel@edumazet-glaptop>
References: <20120619.214657.1345825814176201681.davem@davemloft.net>
	 <1340171940.4604.799.camel@edumazet-glaptop>
	 <20120619.231412.1236237191660427779.davem@davemloft.net>
	 <20120620.031543.1511134879638711616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59072 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab2FTMip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 08:38:45 -0400
Received: by bkcji2 with SMTP id ji2so6112742bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 05:38:43 -0700 (PDT)
In-Reply-To: <20120620.031543.1511134879638711616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 03:15 -0700, David Miller wrote:
> 			       dev->ifindex);
> +		if (sk) {
> +			skb_orphan(skb);
> +			skb->sk = sk;
> +			skb->destructor = sock_edemux;
> +			if (!skb_dst(skb) &&
> +			    sk->sk_state != TCP_TIME_WAIT) {
> +				struct dst_entry *dst = sk->sk_rx_dst;
> +				if (dst)
> +					dst = dst_check(dst, 0);
> +				if (dst) {
> +					struct rtable *rt = (struct rtable *) dst;
> +
> +					if (rt->rt_iif == dev->ifindex)
> +						skb_dst_set_noref(skb, dst);
> +				}
> +			}
> +		}
> +	}
> +	return pp;

I am trying to convince myself its safe.

skb_dst_set_noref() assumes caller hold rcu_read_lock() until we use the
skb dst.

And dev_gro_receive() releases RCU...

Problem could happen if sk->sk_rx_dst is freed while some packets are
still in napi or socket backlog (can happen with some network
reordering)

1) Socket backlog must be flushed before sk->sk_rx_dst freeing

2) Even if we move rcu_read_lock() in net_rx_action(), we need some
napi_gro_forcedstrefs() in case we sofnet_break

Or maybe just use napi_gro_flush() ?

diff --git a/net/core/dev.c b/net/core/dev.c
index 57c4f9b..c0f71a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3861,6 +3861,9 @@ static void net_rx_action(struct softirq_action *h)
 
 		budget -= work;
 
+		if (work == weight)
+			napi_gro_flush(n);
+
 		local_irq_disable();
 
 		/* Drivers must not modify the NAPI state if they
