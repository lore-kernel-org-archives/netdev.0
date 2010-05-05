From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 5/6] netdev: octeon_mgmt: Try not to drop TX packets when stopping the queue.
Date: Wed,  5 May 2010 16:03:12 -0700
Message-ID: <1273100593-11043-6-git-send-email-ddaney@caviumnetworks.com>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1671 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758195Ab0EEXDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:50 -0400
In-Reply-To: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stop the queue when we add the packet that will fill it instead of dropping the packet

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 3cf6f62..1fdc7b3 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -955,6 +955,7 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	int port = p->port;
 	union mgmt_port_ring_entry re;
 	unsigned long flags;
+	int rv = NETDEV_TX_BUSY;
 
 	re.d64 = 0;
 	re.s.len = skb->len;
@@ -964,15 +965,18 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	spin_lock_irqsave(&p->tx_list.lock, flags);
 
+	if (unlikely(p->tx_current_fill >= ring_max_fill(OCTEON_MGMT_TX_RING_SIZE) - 1)) {
+		spin_unlock_irqrestore(&p->tx_list.lock, flags);
+		netif_stop_queue(netdev);
+		spin_lock_irqsave(&p->tx_list.lock, flags);
+	}
+
 	if (unlikely(p->tx_current_fill >=
 		     ring_max_fill(OCTEON_MGMT_TX_RING_SIZE))) {
 		spin_unlock_irqrestore(&p->tx_list.lock, flags);
-
 		dma_unmap_single(p->dev, re.s.addr, re.s.len,
 				 DMA_TO_DEVICE);
-
-		netif_stop_queue(netdev);
-		return NETDEV_TX_BUSY;
+		goto out;
 	}
 
 	__skb_queue_tail(&p->tx_list, skb);
@@ -995,8 +999,10 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	cvmx_write_csr(CVMX_MIXX_ORING2(port), 1);
 
 	netdev->trans_start = jiffies;
+	rv = NETDEV_TX_OK;
+out:
 	octeon_mgmt_update_tx_stats(netdev);
-	return NETDEV_TX_OK;
+	return rv;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.6.6.1

