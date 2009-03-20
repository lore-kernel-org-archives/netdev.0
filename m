From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] ixgbe: fix select_queue management (v2)
Date: Fri, 20 Mar 2009 09:12:47 -0700
Message-ID: <20090320091247.38326931@nehalam>
References: <20090319233404.6697768b@nehalam>
	<20090319233610.51fe4ee1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40665 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921AbZCTQMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 12:12:55 -0400
In-Reply-To: <20090319233610.51fe4ee1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert ixgbe to use net_device_ops properly.
Rather than changing the select_queue function pointer
just change number of available transmit queues.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   48 +++++++++++++++++----------------------
 1 file changed, 21 insertions(+), 27 deletions(-)

--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-03-20 09:01:19.643651162 -0700
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-03-20 09:11:09.645652169 -0700
@@ -102,12 +102,6 @@ static u8 ixgbe_dcbnl_get_state(struct n
 	return !!(adapter->flags & IXGBE_FLAG_DCB_ENABLED);
 }
 
-static u16 ixgbe_dcb_select_queue(struct net_device *dev, struct sk_buff *skb)
-{
-	/* All traffic should default to class 0 */
-	return 0;
-}
-
 static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 {
 	u8 err = 0;
@@ -135,7 +129,7 @@ static u8 ixgbe_dcbnl_set_state(struct n
 		kfree(adapter->rx_ring);
 		adapter->tx_ring = NULL;
 		adapter->rx_ring = NULL;
-		netdev->select_queue = &ixgbe_dcb_select_queue;
+		netdev->real_num_tx_queues = 1;
 
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
@@ -147,6 +141,7 @@ static u8 ixgbe_dcbnl_set_state(struct n
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			if (netif_running(netdev))
 				netdev->netdev_ops->ndo_stop(netdev);
+
 			ixgbe_reset_interrupt_capability(adapter);
 			ixgbe_napi_del_all(adapter);
 			INIT_LIST_HEAD(&netdev->napi_list);
@@ -154,7 +149,7 @@ static u8 ixgbe_dcbnl_set_state(struct n
 			kfree(adapter->rx_ring);
 			adapter->tx_ring = NULL;
 			adapter->rx_ring = NULL;
-			netdev->select_queue = NULL;
+			netdev->real_num_tx_queues = MAX_TX_QUEUES;
 
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
