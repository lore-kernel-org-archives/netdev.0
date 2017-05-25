From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix inaccurate count of napi-processed rx
 packets reported to Octeon
Date: Thu, 25 May 2017 10:54:29 -0700
Message-ID: <20170525175429.GA1476@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0052.outbound.protection.outlook.com ([104.47.40.52]:30544
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S970127AbdEYRyv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 13:54:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

lio_enable_irq (called by napi poll) is reporting to Octeon an inaccurate
count of processed rx packets causing Octeon to eventually stop forwarding
packets to the host.  Fix it by using this formula for an accurate count:

    processed rx packets = droq->pkt_count - droq->pkts_pending

Also increase SOFT_COMMAND_BUFFER_SIZE to match what the firmware expects.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 6 ++++--
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h     | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index b5be707..3b7cc93 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1429,13 +1429,15 @@ int lio_get_device_id(void *dev)
 void lio_enable_irq(struct octeon_droq *droq, struct octeon_instr_queue *iq)
 {
 	u64 instr_cnt;
+	u32 pkts_pend;
 	struct octeon_device *oct = NULL;
 
 	/* the whole thing needs to be atomic, ideally */
 	if (droq) {
+		pkts_pend = (u32)atomic_read(&droq->pkts_pending);
 		spin_lock_bh(&droq->lock);
-		writel(droq->pkt_count, droq->pkts_sent_reg);
-		droq->pkt_count = 0;
+		writel(droq->pkt_count - pkts_pend, droq->pkts_sent_reg);
+		droq->pkt_count = pkts_pend;
 		/* this write needs to be flushed before we release the lock */
 		mmiowb();
 		spin_unlock_bh(&droq->lock);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 5063a12..5c3c8da 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -251,7 +251,7 @@ union octeon_instr_64B {
 
 /** The size of each buffer in soft command buffer pool
  */
-#define  SOFT_COMMAND_BUFFER_SIZE	1536
+#define  SOFT_COMMAND_BUFFER_SIZE	2048
 
 struct octeon_soft_command {
 	/** Soft command buffer info. */
