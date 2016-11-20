From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 10/18] net/ena: use READ_ONCE to access completion descriptors
Date: Sun, 20 Nov 2016 10:45:39 +0200
Message-ID: <1479631547-29354-11-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37004 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753462AbcKTIqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:46:19 -0500
Received: by mail-wm0-f48.google.com with SMTP id t79so98342453wmt.0
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:46:19 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Completion descriptors are accessed from the driver and from the device.
To avoid reading the old value, use READ_ONCE macro.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.h     | 1 +
 drivers/net/ethernet/amazon/ena/ena_eth_com.c | 8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.h b/drivers/net/ethernet/amazon/ena/ena_com.h
index 6883ee5..f8cdce0 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.h
+++ b/drivers/net/ethernet/amazon/ena/ena_com.h
@@ -33,6 +33,7 @@
 #ifndef ENA_COM
 #define ENA_COM
 
+#include <linux/compiler.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/gfp.h>
diff --git a/drivers/net/ethernet/amazon/ena/ena_eth_com.c b/drivers/net/ethernet/amazon/ena/ena_eth_com.c
index 539c536..f999305 100644
--- a/drivers/net/ethernet/amazon/ena/ena_eth_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_eth_com.c
@@ -45,7 +45,7 @@ static inline struct ena_eth_io_rx_cdesc_base *ena_com_get_next_rx_cdesc(
 	cdesc = (struct ena_eth_io_rx_cdesc_base *)(io_cq->cdesc_addr.virt_addr
 			+ (head_masked * io_cq->cdesc_entry_size_in_bytes));
 
-	desc_phase = (cdesc->status & ENA_ETH_IO_RX_CDESC_BASE_PHASE_MASK) >>
+	desc_phase = (READ_ONCE(cdesc->status) & ENA_ETH_IO_RX_CDESC_BASE_PHASE_MASK) >>
 			ENA_ETH_IO_RX_CDESC_BASE_PHASE_SHIFT;
 
 	if (desc_phase != expected_phase)
@@ -141,7 +141,7 @@ static inline u16 ena_com_cdesc_rx_pkt_get(struct ena_com_io_cq *io_cq,
 
 		ena_com_cq_inc_head(io_cq);
 		count++;
-		last = (cdesc->status & ENA_ETH_IO_RX_CDESC_BASE_LAST_MASK) >>
+		last = (READ_ONCE(cdesc->status) & ENA_ETH_IO_RX_CDESC_BASE_LAST_MASK) >>
 			ENA_ETH_IO_RX_CDESC_BASE_LAST_SHIFT;
 	} while (!last);
 
@@ -489,13 +489,13 @@ int ena_com_tx_comp_req_id_get(struct ena_com_io_cq *io_cq, u16 *req_id)
 	 * expected, it mean that the device still didn't update
 	 * this completion.
 	 */
-	cdesc_phase = cdesc->flags & ENA_ETH_IO_TX_CDESC_PHASE_MASK;
+	cdesc_phase = READ_ONCE(cdesc->flags) & ENA_ETH_IO_TX_CDESC_PHASE_MASK;
 	if (cdesc_phase != expected_phase)
 		return -EAGAIN;
 
 	ena_com_cq_inc_head(io_cq);
 
-	*req_id = cdesc->req_id;
+	*req_id = READ_ONCE(cdesc->req_id);
 
 	return 0;
 }
-- 
1.9.1
