From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 03/11] ixgbe: bulk free SKBs during TX completion
 cleanup cycle
Date: Tue, 02 Feb 2016 22:11:54 +0100
Message-ID: <20160202211151.16315.57664.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933063AbcBBVLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:11:55 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an opportunity to bulk free SKBs during reclaiming of
resources after DMA transmit completes in ixgbe_clean_tx_irq.  Thus,
bulk freeing at this point does not introduce any added latency.

Simply use napi_consume_skb() which were recently introduced.  The
napi_budget parameter is needed by napi_consume_skb() to detect if it
is called from netpoll.

Benchmarking IPv4-forwarding, on CPU i7-4790K @4.2GHz (no turbo boost)
 Single CPU/flow numbers: before: 1982144 pps ->  after : 2064446 pps
 Improvement: +82302 pps, -20 nanosec, +4.1%
 (SLUB and GCC version 5.1.1 20150618 (Red Hat 5.1.1-4))

Joint work with Alexander Duyck.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4003a88bbf6..0c701b8438b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1089,7 +1089,7 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
  * @tx_ring: tx ring to clean
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
-			       struct ixgbe_ring *tx_ring)
+			       struct ixgbe_ring *tx_ring, int napi_budget)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_tx_buffer *tx_buffer;
@@ -1127,7 +1127,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		napi_consume_skb(tx_buffer->skb, napi_budget);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -2784,7 +2784,7 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 #endif
 
 	ixgbe_for_each_ring(ring, q_vector->tx)
-		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
+		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring, budget);
 
 	/* Exit if we are called by netpoll or busy polling is active */
 	if ((budget <= 0) || !ixgbe_qv_lock_napi(q_vector))
