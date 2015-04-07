From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/3] e1000,
 e1000e: Use dma_rmb instead of rmb for descriptor read ordering
Date: Tue, 07 Apr 2015 16:55:27 -0700
Message-ID: <20150407235527.1574.69801.stgit@ahduyck-vm-fedora22>
References: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924AbbDGXz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 19:55:28 -0400
In-Reply-To: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces calls to rmb with dma_rmb in the case where we want to
order all follow-on descriptor reads after the check for the descriptor
status bit.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c    |    8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index b548ef0cf56b..983eb4e6f7aa 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3856,7 +3856,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
-		rmb();	/* read buffer_info after eop_desc */
+		dma_rmb();	/* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -4154,7 +4154,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
-		rmb(); /* read descriptor and rx_buffer_info after status DD */
+		dma_rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 
@@ -4375,7 +4375,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
-		rmb(); /* read descriptor and rx_buffer_info after status DD */
+		dma_rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
 		length = le16_to_cpu(rx_desc->length);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4e56c3195989..74ec185a697f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -947,7 +947,7 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
-		rmb();	/* read descriptor and rx_buffer_info after status DD */
+		dma_rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
@@ -1232,7 +1232,7 @@ static bool e1000_clean_tx_irq(struct e1000_ring *tx_ring)
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
 
-		rmb();		/* read buffer_info after eop_desc */
+		dma_rmb();		/* read buffer_info after eop_desc */
 		for (; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
@@ -1332,7 +1332,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_ring *rx_ring, int *work_done,
 			break;
 		(*work_done)++;
 		skb = buffer_info->skb;
-		rmb();	/* read descriptor and rx_buffer_info after status DD */
+		dma_rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		/* in the packet split case this is header only */
 		prefetch(skb->data - NET_IP_ALIGN);
@@ -1536,7 +1536,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
-		rmb();	/* read descriptor and rx_buffer_info after status DD */
+		dma_rmb();	/* read descriptor and rx_buffer_info after status DD */
 
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
