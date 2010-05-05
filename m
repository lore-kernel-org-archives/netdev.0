From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/6] netdev: octeon_mgmt: Fix race condition freeing TX buffers.
Date: Wed,  5 May 2010 16:03:09 -0700
Message-ID: <1273100593-11043-3-git-send-email-ddaney@caviumnetworks.com>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1666 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758044Ab0EEXDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:49 -0400
In-Reply-To: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under heavy load the TX cleanup tasklet and xmit threads would race
and try to free too many buffers.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index bbbd737..b975a2f 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -189,12 +189,19 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 
 	mix_orcnt.u64 = cvmx_read_csr(CVMX_MIXX_ORCNT(port));
 	while (mix_orcnt.s.orcnt) {
+		spin_lock_irqsave(&p->tx_list.lock, flags);
+
+		mix_orcnt.u64 = cvmx_read_csr(CVMX_MIXX_ORCNT(port));
+
+		if (mix_orcnt.s.orcnt == 0) {
+			spin_unlock_irqrestore(&p->tx_list.lock, flags);
+			break;
+		}
+
 		dma_sync_single_for_cpu(p->dev, p->tx_ring_handle,
 					ring_size_to_bytes(OCTEON_MGMT_TX_RING_SIZE),
 					DMA_BIDIRECTIONAL);
 
-		spin_lock_irqsave(&p->tx_list.lock, flags);
-
 		re.d64 = p->tx_ring[p->tx_next_clean];
 		p->tx_next_clean =
 			(p->tx_next_clean + 1) % OCTEON_MGMT_TX_RING_SIZE;
-- 
1.6.6.1

