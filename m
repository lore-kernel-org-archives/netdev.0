From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Fix receive on real device when VLANs are
	configured
Date: Thu, 13 Aug 2009 17:09:38 -0700
Message-ID: <20090814000929.20911.77027.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Lucy Liu <lucy.liu@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:51868
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753268AbZHNAJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 20:09:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucy Liu <lucy.liu@intel.com>

Traffic received with a priority tag (VID = 0) and non-zero priority value was
incorrectly handled by the VLAN packet code path due to a check on zero for
the whole VLAN tag instead of just the VID.

This patch masked out the priority field when checking the vlan tag for
received VLAN packets.

Signed-off-by: Lucy Liu <lucy.liu@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e3cb949..77b0381 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -492,12 +492,12 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 
 	skb_record_rx_queue(skb, ring->queue_index);
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
-		if (adapter->vlgrp && is_vlan && (tag != 0))
+		if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
 			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
 		else
 			napi_gro_receive(napi, skb);
 	} else {
-		if (adapter->vlgrp && is_vlan && (tag != 0))
+		if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
 			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
 		else
 			netif_rx(skb);

