From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 02/13] wimax/i2400m: fix race condition with tcpdump et al
Date: Wed,  4 Nov 2009 13:39:57 -0800
Message-ID: <9835fd84990ca253c5b625005717a9be492788c0.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45111 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932708AbZKDVmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:11 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcpdump and friends were not being able to decode packets sent via
WiMAX; they had a zero ethernet type, even when the stack was properly
sending them to the device with the right type.

It happens that the driver was overwriting the (fake) ethernet header
for creating the hardware header and that was bitting the cloning used
by tcpdump (et al) to look into the packets.

Use pkskb_expand_head() [method copied from the e1000 driver] to fix.

Thanks to Herbert Xu and Andi Kleen for helping to diagnose and
pointing to the right fix.

Cc: Herbert Xu <gondor.apana.org.au>
Cc: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index fefd794..e7d1a51 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -358,6 +358,20 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff *skb,
 	int result;
 
 	d_fnstart(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
+	if (skb_header_cloned(skb)) {
+		/*
+		 * Make tcpdump/wireshark happy -- if they are
+		 * running, the skb is cloned and we will overwrite
+		 * the mac fields in i2400m_tx_prep_header. Expand
+		 * seems to fix this...
+		 */
+		result = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (result) {
+			result = NETDEV_TX_BUSY;
+			goto error_expand;
+		}
+	}
+
 	if (i2400m->state == I2400M_SS_IDLE)
 		result = i2400m_net_wake_tx(i2400m, net_dev, skb);
 	else
@@ -368,10 +382,11 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff *skb,
 		net_dev->stats.tx_packets++;
 		net_dev->stats.tx_bytes += skb->len;
 	}
+	result = NETDEV_TX_OK;
+error_expand:
 	kfree_skb(skb);
-
-	d_fnend(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
-	return NETDEV_TX_OK;
+	d_fnend(3, dev, "(skb %p net_dev %p) = %d\n", skb, net_dev, result);
+	return result;
 }
 
 
-- 
1.6.2.5

