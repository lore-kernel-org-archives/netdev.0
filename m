From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: pktgen multiqueue oops
Date: Mon, 27 Aug 2007 11:16:19 +0200
Message-ID: <18130.38499.765184.425431@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:57487 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbXH0JQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 05:16:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello,

Initially pkt_dev can be NULL this causes netif_subqueue_stopped to 
oops. The patch below should cure it. But maybe the pktgen TX logic 
should be reworked to better support the new multiqueue support. 

Cheers
					--ro

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 7bae576..a0db4d1 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3331,8 +3331,9 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	}
 
 	if ((netif_queue_stopped(odev) ||
-	     netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping)) ||
-	     need_resched()) {
+	     (pkt_dev->skb && 
+	      netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping))) ||
+	    need_resched()) {
 		idle_start = getCurUs();
 
 		if (!netif_running(odev)) {
