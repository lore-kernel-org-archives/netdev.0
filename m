From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/14] pktgen: avoid calling gettimeofday
Date: Thu, 27 Aug 2009 16:55:15 -0700
Message-ID: <20090827235705.822648809@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58756 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010AbZH0X7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:25 -0400
Content-Disposition: inline; filename=pktgen-delay2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If not using delay then no need to update next_tx after
each packet sent. This allows pktgen to send faster especially
on systems with slower clock sources.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:45:41.488749725 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:56:42.101504858 -0700
@@ -3450,15 +3450,17 @@ static void pktgen_xmit(struct pktgen_de
 			pkt_dev->last_ok = 0;
 		}
 
-		pkt_dev->next_tx_us = getCurUs();
-		pkt_dev->next_tx_ns = 0;
-
-		pkt_dev->next_tx_us += pkt_dev->delay_us;
-		pkt_dev->next_tx_ns += pkt_dev->delay_ns;
-
-		if (pkt_dev->next_tx_ns > 1000) {
-			pkt_dev->next_tx_us++;
-			pkt_dev->next_tx_ns -= 1000;
+		if (pkt_dev->delay_us || pkt_dev->delay_ns) {
+			pkt_dev->next_tx_us = getCurUs();
+			pkt_dev->next_tx_ns = 0;
+
+			pkt_dev->next_tx_us += pkt_dev->delay_us;
+			pkt_dev->next_tx_ns += pkt_dev->delay_ns;
+
+			if (pkt_dev->next_tx_ns > 1000) {
+				pkt_dev->next_tx_us++;
+				pkt_dev->next_tx_ns -= 1000;
+			}
 		}
 	}
 	__netif_tx_unlock_bh(txq);

-- 

