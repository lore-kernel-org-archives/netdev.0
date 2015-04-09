From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 4/4] e100: Use dma_rmb/wmb where appropriate
Date: Wed, 08 Apr 2015 18:49:49 -0700
Message-ID: <20150409014949.4434.29969.stgit@ahduyck-vm-fedora22>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702AbbDIBtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 21:49:51 -0400
In-Reply-To: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the CPU overhead for transmit and receive by using lightweight dma_
barriers instead of full barriers where they are applicable.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e100.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 05f88394f9a5..1a450f4b6b12 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -899,7 +899,7 @@ static int e100_exec_cb(struct nic *nic, struct sk_buff *skb,
 	/* Order is important otherwise we'll be in a race with h/w:
 	 * set S-bit in current first, then clear S-bit in previous. */
 	cb->command |= cpu_to_le16(cb_s);
-	wmb();
+	dma_wmb();
 	cb->prev->command &= cpu_to_le16(~cb_s);
 
 	while (nic->cb_to_send != nic->cb_to_use) {
@@ -1843,7 +1843,7 @@ static int e100_tx_clean(struct nic *nic)
 	for (cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
-		rmb(); /* read skb after status */
+		dma_rmb(); /* read skb after status */
 		netif_printk(nic, tx_done, KERN_DEBUG, nic->netdev,
 			     "cb[%d]->status = 0x%04X\n",
 			     (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
@@ -1993,7 +1993,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 	netif_printk(nic, rx_status, KERN_DEBUG, nic->netdev,
 		     "status=0x%04X\n", rfd_status);
-	rmb(); /* read size after status bit */
+	dma_rmb(); /* read size after status bit */
 
 	/* If data isn't ready, nothing to indicate */
 	if (unlikely(!(rfd_status & cb_complete))) {
