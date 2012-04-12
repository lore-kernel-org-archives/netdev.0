From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when dropping packets
Date: Thu, 12 Apr 2012 10:07:24 +0100
Message-ID: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
Cc: Will Deacon <will.deacon@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:57807 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754870Ab2DLJHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 05:07:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMSC911x ethernet controller provides a mechanism for quickly
skipping to the start of the next frame in the receive FIFO, however
the current code passes the number of words to a function that expects
the number of bytes. This can corrupt the FIFO head in the case that
the fastforward mechanism is not used.

This patch fixes the callers of smsc911x_rx_fastforward to pass the
correct data size.

Cc: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 4a69710..b5599bc 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1228,7 +1228,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 				  "Discarding packet with error bit set");
 			/* Packet has an error, discard it and continue with
 			 * the next */
-			smsc911x_rx_fastforward(pdata, pktwords);
+			smsc911x_rx_fastforward(pdata, pktlength);
 			dev->stats.rx_dropped++;
 			continue;
 		}
@@ -1238,7 +1238,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 			SMSC_WARN(pdata, rx_err,
 				  "Unable to allocate skb for rx packet");
 			/* Drop the packet and stop this polling iteration */
-			smsc911x_rx_fastforward(pdata, pktwords);
+			smsc911x_rx_fastforward(pdata, pktlength);
 			dev->stats.rx_dropped++;
 			break;
 		}
-- 
1.7.4.1
