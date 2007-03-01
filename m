From: Mark Huth <mhuth@mvista.com>
Subject: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Wed, 28 Feb 2007 19:54:56 -0700
Message-ID: <45E64080.4070004@mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020302010200070301000700"
Cc: auke-jan.h.kok@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:19530 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932570AbXCACy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 21:54:57 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020302010200070301000700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------020302010200070301000700
Content-Type: text/x-patch;
 name="netdev_e1000_stop_rt_interrupt_nagging.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netdev_e1000_stop_rt_interrupt_nagging.patch"

Current e1000_xmit_frame spews raw interrupt disabled nag messages when
used with RT kernel patches.  This patch uses spin_trylock_irqsave,
which allows RT patches to properly manage the irq semantics.

Signed-off-by: Mark Huth <mhuth@mvista.com>
---
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 619c892..48f94ee 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3363,12 +3363,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	local_irq_save(flags);
-	if (!spin_trylock(&tx_ring->tx_lock)) {
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
 		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
-	}
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */

--------------020302010200070301000700--
