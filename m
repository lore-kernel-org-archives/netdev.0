From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 7/7] qlge: bugfix: Add missing rx buf clean index on early exit.
Date: Wed, 11 Feb 2009 05:58:37 -0800
Message-ID: <1234360717-32194-7-git-send-email-ron.mercer@qlogic.com>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886AbZBKOBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:20 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The large receive buffer queue is not properly tracking the current
index in the case where an early exit occurs.  This can happen when a
page alloc or dma mapping fails.  If this occurs the queue will get
out of sync and invalid indexes can be written to the hardware.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3ab0369..8ea72dc 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -898,6 +898,7 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 					lbq_desc->index);
 				lbq_desc->p.lbq_page = alloc_page(GFP_ATOMIC);
 				if (lbq_desc->p.lbq_page == NULL) {
+					rx_ring->lbq_clean_idx = clean_idx;
 					QPRINTK(qdev, RX_STATUS, ERR,
 						"Couldn't get a page.\n");
 					return;
@@ -907,6 +908,7 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 						   0, PAGE_SIZE,
 						   PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
+					rx_ring->lbq_clean_idx = clean_idx;
 					put_page(lbq_desc->p.lbq_page);
 					lbq_desc->p.lbq_page = NULL;
 					QPRINTK(qdev, RX_STATUS, ERR,
-- 
1.6.0.2

