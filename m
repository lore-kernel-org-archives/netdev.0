From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 4/5] ibmveth lockless TX
Date: Wed, 26 Oct 2005 10:47:16 -0600
Message-ID: <20051026164602.21820.48687.sendpatchset@localhost.localdomain>
References: <20051026164532.21820.72673.sendpatchset@localhost.localdomain>
Cc: Santiago Leon <santil@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964817AbVJZQr0@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
In-Reply-To: <20051026164532.21820.72673.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the lockless TX feature to the ibmveth driver.  The
hypervisor has its own locking so the only change that is necessary is
to protect the statistics counters.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---

 drivers/net/ibmveth.c |   44 +++++++++++++++++++++++++++++---------------
 drivers/net/ibmveth.h |    1 +
 2 files changed, 30 insertions(+), 15 deletions(-)

--- a/drivers/net/ibmveth.c	2005-10-17 12:37:06.000000000 -0500
+++ b/drivers/net/ibmveth.c	2005-10-18 11:58:56.000000000 -0500
@@ -621,12 +621,18 @@
 	unsigned long lpar_rc;
 	int nfrags = 0, curfrag;
 	unsigned long correlator;
+	unsigned long flags;
 	unsigned int retry_count;
+	unsigned int tx_dropped = 0;
+	unsigned int tx_bytes = 0;
+	unsigned int tx_packets = 0;
+	unsigned int tx_send_failed = 0;
+	unsigned int tx_map_failed = 0;
+
 
 	if ((skb_shinfo(skb)->nr_frags + 1) > IbmVethMaxSendFrags) {
-		adapter->stats.tx_dropped++;
-		dev_kfree_skb(skb);
-		return 0;
+		tx_dropped++;
+		goto out;
 	}
 
 	memset(&desc, 0, sizeof(desc));
@@ -645,10 +651,9 @@
 
 	if(dma_mapping_error(desc[0].fields.address)) {
 		ibmveth_error_printk("tx: unable to map initial fragment\n");
-		adapter->tx_map_failed++;
-		adapter->stats.tx_dropped++;
-		dev_kfree_skb(skb);
-		return 0;
+		tx_map_failed++;
+		tx_dropped++;
+		goto out;
 	}
 
 	curfrag = nfrags;
@@ -665,8 +670,8 @@
 
 		if(dma_mapping_error(desc[curfrag+1].fields.address)) {
 			ibmveth_error_printk("tx: unable to map fragment %d\n", curfrag);
-			adapter->tx_map_failed++;
-			adapter->stats.tx_dropped++;
+			tx_map_failed++;
+			tx_dropped++;
 			/* Free all the mappings we just created */
 			while(curfrag < nfrags) {
 				dma_unmap_single(&adapter->vdev->dev,
@@ -675,8 +680,7 @@
 						 DMA_TO_DEVICE);
 				curfrag++;
 			}
-			dev_kfree_skb(skb);
-			return 0;
+			goto out;
 		}
 	}
 
@@ -701,11 +705,11 @@
 			ibmveth_error_printk("tx: desc[%i] valid=%d, len=%d, address=0x%d\n", i,
 					     desc[i].fields.valid, desc[i].fields.length, desc[i].fields.address);
 		}
-		adapter->tx_send_failed++;
-		adapter->stats.tx_dropped++;
+		tx_send_failed++;
+		tx_dropped++;
 	} else {
-		adapter->stats.tx_packets++;
-		adapter->stats.tx_bytes += skb->len;
+		tx_packets++;
+		tx_bytes += skb->len;
 		netdev->trans_start = jiffies;
 	}
 
@@ -715,6 +719,14 @@
 				desc[nfrags].fields.length, DMA_TO_DEVICE);
 	} while(--nfrags >= 0);
 
+out:	spin_lock_irqsave(&adapter->stats_lock, flags);
+	adapter->stats.tx_dropped += tx_dropped;
+	adapter->stats.tx_bytes += tx_bytes;
+	adapter->stats.tx_packets += tx_packets;
+	adapter->tx_send_failed += tx_send_failed;
+	adapter->tx_map_failed += tx_map_failed;
+	spin_unlock_irqrestore(&adapter->stats_lock, flags);
+
 	dev_kfree_skb(skb);
 	return 0;
 }
@@ -980,6 +992,8 @@
 	netdev->ethtool_ops           = &netdev_ethtool_ops;
 	netdev->change_mtu         = ibmveth_change_mtu;
 	SET_NETDEV_DEV(netdev, &dev->dev);
+ 	netdev->features |= NETIF_F_LLTX; 
+	spin_lock_init(&adapter->stats_lock);
 
 	memcpy(&netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 
diff -urN a/drivers/net/ibmveth.h b/drivers/net/ibmveth.h
--- a/drivers/net/ibmveth.h	2005-10-17 12:35:13.000000000 -0500
+++ b/drivers/net/ibmveth.h	2005-10-18 11:58:56.000000000 -0500
@@ -131,6 +131,7 @@
     u64 tx_linearize_failed;
     u64 tx_map_failed;
     u64 tx_send_failed;
+    spinlock_t stats_lock;
 };
 
 struct ibmveth_buf_desc_fields {	
