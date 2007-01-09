From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/12] forcedeth: tx locking
Date: Tue, 09 Jan 2007 13:30:10 -0500
Message-ID: <45A3DF32.3090909@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030109000204040806000409"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:5483 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbXAIVXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:45 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030109000204040806000409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch reduces the amount of code within the lock to only the 
critical sections.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030109000204040806000409
Content-Type: text/plain;
 name="patch-tx-locking"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-tx-locking"

--- orig/drivers/net/forcedeth.c	2007-01-07 22:30:08.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-07 22:30:02.000000000 -0500
@@ -1569,12 +1569,11 @@
 			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
-	spin_lock_irq(&np->lock);
-
 	empty_slots = nv_get_empty_tx_slots(np);
 	if ((empty_slots - np->tx_limit_stop) <= entries) {
-		spin_unlock_irq(&np->lock);
+		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
+		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1669,6 +1668,8 @@
 		tx_flags_vlan = NV_TX3_VLAN_TAG_PRESENT | vlan_tx_tag_get(skb);
 	}
 
+	spin_lock_irq(&np->lock);
+
 	/* set tx flags */
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		start_tx.orig->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
@@ -1679,6 +1680,7 @@
 		np->put_tx.ex = put_tx.ex;
 	}
 
+	spin_unlock_irq(&np->lock);
 
 	dprintk(KERN_DEBUG "%s: nv_start_xmit: entries %d queued for transmission. tx_flags_extra: %x\n",
 		dev->name, entries, tx_flags_extra);
@@ -1693,7 +1695,6 @@
 	}
 
 	dev->trans_start = jiffies;
-	spin_unlock_irq(&np->lock);
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	pci_push(get_hwbase(dev));
 	return NETDEV_TX_OK;

--------------030109000204040806000409--
