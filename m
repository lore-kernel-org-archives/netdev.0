From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH] korina: fix loop back of receive descriptors
Date: Thu, 15 Jan 2009 23:29:55 +0100
Message-ID: <20090115223005.D6F694043831@mail.nwl.cc>
Cc: davem@davemloft.net, jeff@garzik.org, florian@openwrt.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:58493 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935762AbZAOWjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 17:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the last loop iteration, i has the value RC32434_NUM_RDS and
therefore leads to an index overflow when used afterwards to address the
last element. This is yet another another bug introduced when rewriting
parts of the driver for upstream preparation, as the original driver
used 'RC32434_NUM_RDS - 1' instead.

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 1d6e48e..67fbdf4 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -769,11 +769,12 @@ static void korina_alloc_ring(struct net_device *dev)
 		lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[i+1]);
 	}
 
-	/* loop back */
-	lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[0]);
-	lp->rx_next_done  = 0;
+	/* loop back receive descriptors, so the last
+	 * descriptor points to the first one */
+	lp->rd_ring[i - 1].link = CPHYSADDR(&lp->rd_ring[0]);
+	lp->rd_ring[i - 1].control |= DMA_DESC_COD;
 
-	lp->rd_ring[i].control |= DMA_DESC_COD;
+	lp->rx_next_done  = 0;
 	lp->rx_chain_head = 0;
 	lp->rx_chain_tail = 0;
 	lp->rx_chain_status = desc_empty;
-- 
1.5.6.4

