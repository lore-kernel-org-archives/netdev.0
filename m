From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: rx/tx queue cleanup
Date: Wed, 9 Aug 2017 12:07:08 -0700
Message-ID: <20170809190708.GA1122@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0053.outbound.protection.outlook.com ([104.47.36.53]:56001
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751523AbdHITGB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 15:06:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

When deleting a queue, clear its corresponding bit in the qmask, vfree its
memory, clear out the pointer that's pointing to it, and decrement the
queue count.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <fmanlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     | 4 ++++
 drivers/net/ethernet/cavium/liquidio/request_manager.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index f7b5d68..9372d4c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -209,6 +209,10 @@ int octeon_delete_droq(struct octeon_device *oct, u32 q_no)
 			     droq->desc_ring, droq->desc_ring_dma);
 
 	memset(droq, 0, OCT_DROQ_SIZE);
+	oct->io_qmask.oq &= ~(1ULL << q_no);
+	vfree(oct->droq[q_no]);
+	oct->droq[q_no] = NULL;
+	oct->num_oqs--;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 7b297f1..20a96ba 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -190,6 +190,10 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 		q_size = iq->max_count * desc_size;
 		lio_dma_free(oct, (u32)q_size, iq->base_addr,
 			     iq->base_addr_dma);
+		oct->io_qmask.iq &= ~(1ULL << iq_no);
+		vfree(oct->instr_queue[iq_no]);
+		oct->instr_queue[iq_no] = NULL;
+		oct->num_iqs--;
 		return 0;
 	}
 	return 1;
