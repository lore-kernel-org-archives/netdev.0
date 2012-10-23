From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] pch_gbe: fix error handling in pch_gbe_up()
Date: Tue, 23 Oct 2012 16:54:34 +0200
Message-ID: <1351004074-10225-1-git-send-email-vfalico@redhat.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21569 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754926Ab2JWOyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 10:54:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail to allocate rx buffers pool by any reason, we'll just return
with an error, however we've previously successfully requested an irq. Fix
this by releasing the irq before returning the error.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b2a94d0..876ea9f 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1971,12 +1971,12 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
 	struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
-	int err;
+	int err = -EINVAL;
 
 	/* Ensure we have a valid MAC */
 	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
 		pr_err("Error: Invalid MAC address\n");
-		return -EINVAL;
+		goto out;
 	}
 
 	/* hardware has been reset, we need to reload some things */
@@ -1989,13 +1989,13 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 
 	err = pch_gbe_request_irq(adapter);
 	if (err) {
-		pr_err("Error: can't bring device up\n");
-		return err;
+		pr_err("Error: can't bring device up - irq request failed\n");
+		goto out;
 	}
 	err = pch_gbe_alloc_rx_buffers_pool(adapter, rx_ring, rx_ring->count);
 	if (err) {
-		pr_err("Error: can't bring device up\n");
-		return err;
+		pr_err("Error: can't bring device up - alloc rx buffers pool failed\n");
+		goto freeirq;
 	}
 	pch_gbe_alloc_tx_buffers(adapter, tx_ring);
 	pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
@@ -2009,6 +2009,11 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	netif_start_queue(adapter->netdev);
 
 	return 0;
+
+freeirq:
+	pch_gbe_free_irq(adapter);
+out:
+	return err;
 }
 
 /**
-- 
1.7.1
