From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Increased multicast packet drops in 3.4
Date: Thu, 06 Sep 2012 15:31:57 +0200
Message-ID: <1346938317.2484.40.camel@edumazet-glaptop>
References: <20120906001108.GA6035@BohrerMBP.rgmadvisors.com>
	 <1346912560.13121.175.camel@edumazet-glaptop>
	 <20120906130316.GA2310@BohrerMBP.gateway.2wire.net>
	 <1346937667.2484.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:34563 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab2IFNcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:32:01 -0400
Received: by eekc1 with SMTP id c1so698096eek.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 06:32:00 -0700 (PDT)
In-Reply-To: <1346937667.2484.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 15:21 +0200, Eric Dumazet wrote:

> 
> Are you receiving fragmented UDP frames ?
> 
> I ask this because with latest kernels (linux-3.5), we should no longer
> build a list of skb, but a single skb with page fragments.
> 
> commit 3cc4949269e01f39443d0fcfffb5bc6b47878d45
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sat May 19 03:02:20 2012 +0000
> 
>     ipv4: use skb coalescing in defragmentation
>     
>     ip_frag_reasm() can use skb_try_coalesce() to build optimized skb,
>     reducing memory used by them (truesize), and reducing number of cache
>     line misses and overhead for the consumer.
>     
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Cc: Alexander Duyck <alexander.h.duyck@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 

Unfortunately mlx4 pulls too many bytes from the frame to skb->head, so
it defeats coalescing completely.

Try following patch (if you also try linux-3.5)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9d27e42..700e70e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -150,7 +150,7 @@ enum {
 #define ETH_LLC_SNAP_SIZE	8
 
 #define SMALL_PACKET_SIZE      (256 - NET_IP_ALIGN)
-#define HEADER_COPY_SIZE       (128 - NET_IP_ALIGN)
+#define HEADER_COPY_SIZE       ETH_HLEN
 #define MLX4_LOOPBACK_TEST_PAYLOAD (HEADER_COPY_SIZE - ETH_HLEN)
 
 #define MLX4_EN_MIN_MTU		46
