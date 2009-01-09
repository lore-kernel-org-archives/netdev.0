From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/4] forcedeth: xmit lock fix
Date: Fri, 09 Jan 2009 16:03:44 -0500
Message-ID: <4967BBB0.90809@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070504060508080204030300"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8307 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbZAJAJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 19:09:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070504060508080204030300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes a potential race condition between xmit thread and xmit 
completion thread. The calculation of empty tx descriptors is not 
performed under the lock. This could cause it to set the stop flag while 
the completion thread finishes all tx's. This will result in the tx 
queue in stopped state and no one to wake it up.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------070504060508080204030300
Content-Type: text/plain;
 name="patch-forcedeth-xmitlockfix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-xmitlockfix"

--- old/drivers/net/forcedeth.c	2009-01-09 14:51:19.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-01-09 15:10:15.000000000 -0800
@@ -2096,14 +2096,15 @@
 			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
+	spin_lock_irqsave(&np->lock, flags);
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irqsave(&np->lock, flags);
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
 		spin_unlock_irqrestore(&np->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
+	spin_unlock_irqrestore(&np->lock, flags);
 
 	start_tx = put_tx = np->put_tx.orig;
 
@@ -2214,14 +2215,15 @@
 			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
+	spin_lock_irqsave(&np->lock, flags);
 	empty_slots = nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irqsave(&np->lock, flags);
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
 		spin_unlock_irqrestore(&np->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
+	spin_unlock_irqrestore(&np->lock, flags);
 
 	start_tx = put_tx = np->put_tx.ex;
 	start_tx_ctx = np->put_tx_ctx;

--------------070504060508080204030300--
