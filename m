From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: [PATCH] pch_gbe: Adding read memory barriers
Date: Mon, 07 May 2012 21:30:12 +0200
Message-ID: <4FA822C4.60809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tshimizu818@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38850 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964Ab2EGTaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 15:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From bb1e271db0fa1a29df19bede69faf8004389132d Mon Sep 17 00:00:00 2001
From: Erwan Velu <erwan.velu@zodiacaerospace.com>
Date: Mon, 7 May 2012 19:15:29 +0000
Subject: [PATCH 1/1] pch_gbe: Adding read memory barriers

Under a strong incoming packet stream and/or high cpu usage,
the pch_gbe driver reports "Receive CRC Error" and discards packet.

It occurred on an Intel ATOM E620T while running a 300mbit/sec multicast
network stream leading to a ~100% cpu usage.

Adding rmb() calls before considering the network card's status solve
this issue.

Getting it into stable would be perfect as it solves reliability issues.

Signed-off-by: Erwan Velu <erwan.velu@zodiacaerospace.com>
---
  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    3 +++
  1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c 
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 8035e5f..ace3654 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1413,6 +1413,7 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
  			pch_gbe_mac_set_pause_packet(hw);
  		}
  	}
+	smp_rmb(); /* prevent any other reads before*/

  	/* When request status is Receive interruption */
  	if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT)) ||
@@ -1582,6 +1584,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,

  	i = tx_ring->next_to_clean;
  	tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+	rmb();  /* prevent any other reads before*/
  	pr_debug("gbec_status:0x%04x  dma_status:0x%04x\n",
  		 tx_desc->gbec_status, tx_desc->dma_status);

@@ -1682,6 +1685,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
  	while (*work_done < work_to_do) {
  		/* Check Rx descriptor status */
  		rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
+		rmb(); /* prevent any other reads before*/
  		if (rx_desc->gbec_status == DSC_INIT16)
  			break;
  		cleaned = true;
-- 
1.7.3.4
