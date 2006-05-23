From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/9] ixgb: add NETIF_F_LLTX analogous to e1000
Date: Tue, 23 May 2006 11:04:11 -0700
Message-ID: <20060523180411.17428.23285.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:42757 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932126AbWEWR7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:13 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


add NETIF_F_LLTX code like e1000 has

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 13181c4..466cbe2 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -449,6 +449,9 @@ ixgb_probe(struct pci_dev *pdev,
 #ifdef NETIF_F_TSO
 	netdev->features |= NETIF_F_TSO;
 #endif
+#ifdef NETIF_F_LLTX
+	netdev->features |= NETIF_F_LLTX;
+#endif
 
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -1408,13 +1411,26 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 		return 0;
 	}
 
+#ifdef NETIF_F_LLTX
+	local_irq_save(flags);
+	if (!spin_trylock(&adapter->tx_lock)) {
+		/* Collision - tell upper layer to requeue */
+		local_irq_restore(flags);
+		return NETDEV_TX_LOCKED;
+	}
+#else
 	spin_lock_irqsave(&adapter->tx_lock, flags);
+#endif
+
 	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
+
+#ifndef NETIF_F_LLTX
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+#endif
 
 	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
@@ -1426,6 +1442,9 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
+#ifdef NETIF_F_LLTX
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+#endif
 		return NETDEV_TX_OK;
 	}
 
@@ -1439,7 +1458,15 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 
 	netdev->trans_start = jiffies;
 
-	return 0;
+#ifdef NETIF_F_LLTX
+	/* Make sure there is space in the ring for the next send. */
+	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED))
+		netif_stop_queue(netdev);
+
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+
+#endif
+	return NETDEV_TX_OK;
 }
 
 /**



--
Auke Kok <auke-jan.h.kok@intel.com>
