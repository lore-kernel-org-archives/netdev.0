From: Dmitry Torokhov <dtor@insightbb.com>
Subject: [patch 1/2] prism54: fix potential race in reset scheduling
Date: Sun, 08 Oct 2006 00:38:14 -0400
Message-ID: <20061008043954.500897141.dtor@insightbb.com>
References: <20061008043813.401495520.dtor@insightbb.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:48048 "EHLO
	asav09.insightbb.com") by vger.kernel.org with ESMTP
	id S1750785AbWJHEkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 00:40:37 -0400
To: linville@tuxdriver.com
Content-Disposition: inline; filename=prism54-timeout-scheduling.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET: prism54 - fix potential race in reset scheduling

There appears to be a race in reset scheduling logic - thread
responsible for reseting the interface should clear "reset
pending" flag before restarting the queue, otherwise timeout
handler might not schedule another reset even if it is needed.

This race is mostly theoretical as far as I can see but a race
nonetheless.

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

 drivers/net/wireless/prism54/islpci_eth.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

Index: work/drivers/net/wireless/prism54/islpci_eth.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_eth.c
+++ work/drivers/net/wireless/prism54/islpci_eth.c
@@ -253,6 +253,7 @@ islpci_monitor_rx(islpci_private *priv, 
 	 * header and without the FCS. But there a is a bit that
 	 * indicates if the packet is corrupted :-) */
 	struct rfmon_header *hdr = (struct rfmon_header *) (*skb)->data;
+
 	if (hdr->flags & 0x01)
 		/* This one is bad. Drop it ! */
 		return -1;
@@ -464,10 +465,8 @@ islpci_eth_receive(islpci_private *priv)
 			break;
 		}
 		/* update the fragment address */
-		control_block->rx_data_low[index].address = cpu_to_le32((u32)
-									priv->
-									pci_map_rx_address
-									[index]);
+		control_block->rx_data_low[index].address =
+			cpu_to_le32((u32)priv->pci_map_rx_address[index]);
 		wmb();
 
 		/* increment the driver read pointer */
@@ -484,10 +483,12 @@ islpci_eth_receive(islpci_private *priv)
 void
 islpci_do_reset_and_wake(void *data)
 {
-	islpci_private *priv = (islpci_private *) data;
+	islpci_private *priv = data;
+
 	islpci_reset(priv, 1);
-	netif_wake_queue(priv->ndev);
 	priv->reset_task_pending = 0;
+	smp_wmb();
+	netif_wake_queue(priv->ndev);
 }
 
 void
@@ -499,12 +500,14 @@ islpci_eth_tx_timeout(struct net_device 
 	/* increment the transmit error counter */
 	statistics->tx_errors++;
 
-	printk(KERN_WARNING "%s: tx_timeout", ndev->name);
 	if (!priv->reset_task_pending) {
-		priv->reset_task_pending = 1;
-		printk(", scheduling a reset");
+		printk(KERN_WARNING
+			"%s: tx_timeout, scheduling reset", ndev->name);
 		netif_stop_queue(ndev);
+		priv->reset_task_pending = 1;
 		schedule_work(&priv->reset_task);
+	} else {
+		printk(KERN_WARNING
+			"%s: tx_timeout, waiting for reset", ndev->name);
 	}
-	printk("\n");
 }
