From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] ixgbe: skb_record_rx_queue should record rx
	queue instead of vector
Date: Wed, 06 May 2009 13:43:47 -0700
Message-ID: <20090506204347.18071.40100.stgit@localhost.localdomain>
References: <20090506204317.18071.96421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:34666
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932209AbZEFUoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:44:06 -0400
In-Reply-To: <20090506204317.18071.96421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

currently ixgbe_receive_skb is passing the vector index to
skb_record_rx_queue instead of the queue index.  This patch changes that so
that the ring index is passed instead.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 165bfa6..2c70fa0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -461,6 +461,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
  **/
 static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
                               struct sk_buff *skb, u8 status,
+                              struct ixgbe_ring *ring,
                               union ixgbe_adv_rx_desc *rx_desc)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
@@ -468,7 +469,7 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	skb_record_rx_queue(skb, q_vector->v_idx);
+	skb_record_rx_queue(skb, ring->queue_index);
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 		if (adapter->vlgrp && is_vlan && (tag != 0))
 			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
@@ -782,7 +783,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		total_rx_packets++;
 
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
-		ixgbe_receive_skb(q_vector, skb, staterr, rx_desc);
+		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;

