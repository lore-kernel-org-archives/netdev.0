From: linux@horizon.com
Subject: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: 8 Jan 2008 07:28:14 -0500
Message-ID: <20080108122814.12005.qmail@science.horizon.com>
References: <20080107.231447.08811264.davem@davemloft.net>
Cc: akpm@linux-foundation.org, davem@davemloft.net, linux@horizon.com
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:19696 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754038AbYAHN2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 08:28:10 -0500
In-Reply-To: <20080107.231447.08811264.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prompted by davem, this attempt at fixing the memory leak
actually appears to work.  At least, leaving ping -f -s1472 -l64
running doesn't drop packets and doesn't show up in /proc/slabinfo.
---
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..a0dfba5 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1110,10 +1110,9 @@ enum {
 	Frame_WithStart_WithEnd = 11
 };
 
-inline void ipg_nic_rx_free_skb(struct net_device *dev)
+inline void ipg_nic_rx_free_skb(struct net_device *dev, unsigned entry)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
-	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
 
 	if (sp->RxBuff[entry]) {
 		struct ipg_rx *rxfd = sp->rxd + entry;
@@ -1308,7 +1307,7 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
 
-		ipg_nic_rx_free_skb(dev);
+		ipg_nic_rx_free_skb(dev, entry);
 	} else {
 		IPG_DEV_KFREE_SKB(jumbo->skb);
 		jumbo->FoundStart = 0;
@@ -1337,7 +1336,7 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 				}
 			}
 			dev->last_rx = jiffies;
-			ipg_nic_rx_free_skb(dev);
+			ipg_nic_rx_free_skb(dev, entry);
 		}
 	} else {
 		IPG_DEV_KFREE_SKB(jumbo->skb);
