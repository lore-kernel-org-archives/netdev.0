From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/6] igb/ixgbe: remove unecessary checks for
	CHECKSUM_UNNECESSARY
Date: Tue, 28 Apr 2009 01:35:33 -0700
Message-ID: <20090428083532.32417.26831.stgit@localhost.localdomain>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:50608
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752982AbZD1Ifv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:35:51 -0400
In-Reply-To: <20090428083445.32417.77682.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Both of these drivers do a check to verify ip_summed is set to
CHECKSUM_UNNECESSARY prior to passing the packet to GRO.  GRO itself
already does such a check so it is redundant and can be removed as this
will likely cause out of order issues when receiving a packet that didn't
pass checksum validation.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c     |   20 ++++++--------------
 drivers/net/ixgbe/ixgbe_main.c |   17 +++++------------
 2 files changed, 11 insertions(+), 26 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4ecf4df..f7f8612 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4430,20 +4430,12 @@ static void igb_receive_skb(struct igb_ring *ring, u8 status,
 	bool vlan_extracted = (adapter->vlgrp && (status & E1000_RXD_STAT_VP));
 
 	skb_record_rx_queue(skb, ring->queue_index);
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		if (vlan_extracted)
-			vlan_gro_receive(&ring->napi, adapter->vlgrp,
-			                 le16_to_cpu(rx_desc->wb.upper.vlan),
-			                 skb);
-		else
-			napi_gro_receive(&ring->napi, skb);
-	} else {
-		if (vlan_extracted)
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-			                  le16_to_cpu(rx_desc->wb.upper.vlan));
-		else
-			netif_receive_skb(skb);
-	}
+	if (vlan_extracted)
+		vlan_gro_receive(&ring->napi, adapter->vlgrp,
+		                 le16_to_cpu(rx_desc->wb.upper.vlan),
+		                 skb);
+	else
+		napi_gro_receive(&ring->napi, skb);
 }
 
 static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c45e4e7..42b803d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -459,23 +459,16 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
 	skb_record_rx_queue(skb, q_vector - &adapter->q_vector[0]);
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 		if (adapter->vlgrp && is_vlan && (tag != 0))
 			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
 		else
 			napi_gro_receive(napi, skb);
 	} else {
-		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
-			if (adapter->vlgrp && is_vlan && (tag != 0))
-				vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
-			else
-				netif_receive_skb(skb);
-		} else {
-			if (adapter->vlgrp && is_vlan && (tag != 0))
-				vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
-			else
-				netif_rx(skb);
-		}
+		if (adapter->vlgrp && is_vlan && (tag != 0))
+			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
+		else
+			netif_rx(skb);
 	}
 }
 

