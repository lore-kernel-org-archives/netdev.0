From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: [PATCH] net: macb: Fix race condition in driver when Rx frame is dropped
Date: Wed, 29 Apr 2015 08:34:46 +0530
Message-ID: <c84f3773-71f2-431a-bc20-6a969d32eb63@BN1BFFO11FD033.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<michals@xilinx.com>, <harinik@xilinx.com>, <kpc528@gmail.com>,
	<kalluripunnaiahchoudary@gmail.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>

Under heavy Rx load, observed that the Hw is updating the USED bit
and it is not updating the received frame status to the BD control
field. This could be lack of resources for processing the BDs at high
data rates. Driver drops the frame associated with this BD but not
clearing the USED bit. So, this is causing hang condition as Hw
expects USED bit to be cleared for this BD.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9f53872..d79b0b1 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -707,6 +707,9 @@ static void gem_rx_refill(struct macb *bp)
 
 			/* properly align Ethernet header */
 			skb_reserve(skb, NET_IP_ALIGN);
+		} else {
+			bp->rx_ring[entry].addr &= ~MACB_BIT(RX_USED);
+			bp->rx_ring[entry].ctrl = 0;
 		}
 	}
 
-- 
1.7.4
