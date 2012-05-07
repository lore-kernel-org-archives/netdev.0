From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: [PATCH] pch_gbe: Adding read memory barriers
Date: Mon, 07 May 2012 19:49:58 +0200
Message-ID: <4FA80B46.5070405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tshimizu818@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From 3b65802e4c5a8827a84022066f10dec4d61c1f22 Mon Sep 17 00:00:00 2001
From: Erwan Velu <erwan.velu@zodiacaerospace.com>
Date: Mon, 7 May 2012 14:53:17 +0200
Subject: [PATCH 1/1] pch_gbe: Adding read memory barriers

Under a strong incoming packet stream and/or high cpu usage,
the pch_gbe driver reports "Receive CRC Error" and discards packet.

It occurred on an Intel ATOM E620T while running a 300mbit/sec multicast 
network stream leading to a ~100% cpu usage.

Adding rmb() calls before considering the network card's status solve
this issues.

This patch got validated on the 3.2.16 kernel but also apply to the 3.x 
family.

Getting it into stable would be perfect as it solves reliability issues.


Signed-off-by: Erwan Velu <erwan.velu@zodiacaerospace.com>
---
  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    8 ++++++++
  1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c 
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 48406ca..7746ca3 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1222,6 +1222,8 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
  		}
  	}

+	smp_rmb(); /* prevent any other reads before*/
+
  	/* When request status is Receive interruption */
  	if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT)) ||
  	    (adapter->rx_stop_flag == true)) {
@@ -1390,6 +1392,9 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,

  	i = tx_ring->next_to_clean;
  	tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+
+	rmb();  /* prevent any other reads before*/
+
  	pr_debug("gbec_status:0x%04x  dma_status:0x%04x\n",
  		 tx_desc->gbec_status, tx_desc->dma_status);

@@ -1490,6 +1495,9 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
  	while (*work_done < work_to_do) {
  		/* Check Rx descriptor status */
  		rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
+
+		rmb(); /* prevent any other reads before*/
+
  		if (rx_desc->gbec_status == DSC_INIT16)
  			break;
  		cleaned = true;
-- 
1.7.4.4
