From: David Miller <davem@davemloft.net>
Subject: qlge packet receive
Date: Mon, 02 Feb 2009 14:01:15 -0800 (PST)
Message-ID: <20090202.140115.240697048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754082AbZBBWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 17:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I wanted to mention a bug that I noticed in the qlge driver
while perusing NAPI capable drivers last week.

Although qlge uses NAPI polling, it passes packets into the
stack using netif_rx() and vlan_hwaccel_rx().

That's wrong and incredibly inefficient, because these routines
are for the cases where the driver receives packets in hardware
interrupt context, so they schedule a new software interrupt to
process the frames.

NAPI ->poll() executes in software interrupt context so you can
pass the packets directly into the stack using netif_receive_skb()
and vlan_hwaccel_receive_skb().

It should even be fine to do this via the delayed workqueue that calls
ql_rx_clean().

Something like this:

qlge: Use netif_receive_skb() and vlan_hwaccel_receive_skb().

Since we receive packets either in software interrupt context
(via NAPI ->poll()) or process context (via delayed workqueues)
we should pass packets directly into the stack instead of
deferring them via another level of software interrupt processing.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3d1d7b6..79363b8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1449,12 +1449,12 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	if (qdev->vlgrp && (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V)) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"Passing a VLAN packet upstream.\n");
-		vlan_hwaccel_rx(skb, qdev->vlgrp,
-				le16_to_cpu(ib_mac_rsp->vlan_id));
+		vlan_hwaccel_receive_skb(skb, qdev->vlgrp,
+					 le16_to_cpu(ib_mac_rsp->vlan_id));
 	} else {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"Passing a normal packet upstream.\n");
-		netif_rx(skb);
+		netif_receive_skb(skb);
 	}
 }
 
