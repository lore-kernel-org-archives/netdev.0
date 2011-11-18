From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] sky2: enforce minimum ring size
Date: Thu, 17 Nov 2011 16:37:23 -0800
Message-ID: <20111117163723.67964841@nehalam.linuxnetplumber.net>
References: <20111116234254.319625694@vyatta.com>
	<20111116234344.813201788@vyatta.com>
	<874ny2bgqa.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sven Joachim <svenjoac@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37780 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755413Ab1KRAhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 19:37:43 -0500
In-Reply-To: <874ny2bgqa.fsf@turtle.gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware has a restriction that the minimum ring size possible
is 128. The number of elements used is controlled by tx_pending and
the overall number of elements in the ring tx_ring_size, therefore it
is okay to limit the number of elements in use to a small value (63)
but still provide a bigger ring.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-17 16:25:40.079898621 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-17 16:33:19.088438709 -0800
@@ -4092,6 +4092,16 @@ static int sky2_set_coalesce(struct net_
 	return 0;
 }
 
+/*
+ * Hardware is limited to min of 128 and max of 2048 for ring size
+ * and  rounded up to next power of two
+ * to avoid division in modulus calclation
+ */
+static unsigned long roundup_ring_size(unsigned long pending)
+{
+	return max(128ul, roundup_pow_of_two(pending+1));
+}
+
 static void sky2_get_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *ering)
 {
@@ -4119,7 +4129,7 @@ static int sky2_set_ringparam(struct net
 
 	sky2->rx_pending = ering->rx_pending;
 	sky2->tx_pending = ering->tx_pending;
-	sky2->tx_ring_size = roundup_pow_of_two(sky2->tx_pending+1);
+	sky2->tx_ring_size = roundup_ring_size(sky2->tx_pending);
 
 	return sky2_reattach(dev);
 }
@@ -4714,7 +4724,7 @@ static __devinit struct net_device *sky2
 	spin_lock_init(&sky2->phy_lock);
 
 	sky2->tx_pending = TX_DEF_PENDING;
-	sky2->tx_ring_size = roundup_pow_of_two(TX_DEF_PENDING+1);
+	sky2->tx_ring_size = roundup_ring_size(TX_DEF_PENDING);
 	sky2->rx_pending = RX_DEF_PENDING;
 
 	hw->dev[port] = dev;
