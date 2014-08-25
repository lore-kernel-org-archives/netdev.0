From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 1/3] ixgbe: support
 netdev_ops->ndo_xmit_flush()
Date: Mon, 25 Aug 2014 15:32:48 -0700 (PDT)
Message-ID: <20140825.153248.1202565040217198094.davem@davemloft.net>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-2-git-send-email-dborkman@redhat.com>
	<20140825140721.162a6c91@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbaHYWct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:32:49 -0400
In-Reply-To: <20140825140721.162a6c91@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 25 Aug 2014 14:07:21 +0200

> I've run some benchmarks with this patch only, which actually shows a
> performance regression.
> 
> Using trafgen with QDISC_BYPASS and mmap mode, via cmdline:
>  trafgen --cpp  --dev eth5 --conf udp_example01.trafgen -V --cpus 1
> 
> BASELINE(no-patch): trafgen QDISC_BYPASS and mmap:
>  - tx:1562539 pps
> 
> (This patch only): ixgbe use of .ndo_xmit_flush.
>  - tx:1532299 pps
> 
> Regression: -30240 pps
>  * In nanosec: (1/1562539*10^9)-(1/1532299*10^9) = -12.63 ns
> 
> 
> As DaveM points out, me might not need the mmiowb().
> Result when not performing the mmiowb():
>  - tx:1548352 pps
> 
> Still a small regression: -14187 pps
>  * In nanosec: (1/1562539*10^9)-(1/1548352*10^9) = -5.86 ns
> 
> I was not expecting this "slowdown", with this rather simple use of the
> new ndo_xmit_flush API.  Can anyone explain why this is happening?

Impressive amount of overhead for something that evaluates to just a
compiler barrier :-)

The extra indirect function call and walking down the data structures
to get to the queue pointer might account for the remaining cost.

This might be argument enough to contain the behavioral changes within
->ndo_start_xmit() itself.

Jesper, just for fun, could you revert all of the xmit flush stuff and
test this patch instead?

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 87bd53f..ba9ceaa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6958,9 +6958,10 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
-	/* notify HW of packet */
-	ixgbe_write_tail(tx_ring, i);
-
+	if (!skb->xmit_more) {
+		/* notify HW of packet */
+		ixgbe_write_tail(tx_ring, i);
+	}
 	return;
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 18ddf96..dc6141da 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -558,6 +558,7 @@ struct sk_buff {
 
 	__u16			queue_mapping;
 	kmemcheck_bitfield_begin(flags2);
+	__u8			xmit_more:1;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
