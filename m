From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 02/14] e1000: dynamic itr: take TSO and jumbo into account
Date: Fri, 15 Dec 2006 10:30:44 +0100
Message-ID: <1166175044.3365.113.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751536AbWLOKBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:11 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gj5R006137
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:45 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9gjkL006136
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:45 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: dynamic itr: take TSO and jumbo into account
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The dynamic interrupt rate control patches omitted proper counting
for jumbo's and TSO resulting in suboptimal interrupt mitigation strategies.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |   43 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -2628,29 +2628,34 @@ static unsigned int e1000_update_itr(str
 	if (packets == 0)
 		goto update_itr_done;
 
-
 	switch (itr_setting) {
 	case lowest_latency:
-		if ((packets < 5) && (bytes > 512))
+		/* jumbo frames get bulk treatment*/
+		if (bytes/packets > 8000)
+			retval = bulk_latency;
+		else if ((packets < 5) && (bytes > 512))
 			retval = low_latency;
 		break;
 	case low_latency:  /* 50 usec aka 20000 ints/s */
 		if (bytes > 10000) {
-			if ((packets < 10) ||
-			     ((bytes/packets) > 1200))
+			/* jumbo frames need bulk latency setting */
+			if (bytes/packets > 8000)
+				retval = bulk_latency;
+			else if ((packets < 10) || ((bytes/packets) > 1200))
 				retval = bulk_latency;
 			else if ((packets > 35))
 				retval = lowest_latency;
-		} else if (packets <= 2 && bytes < 512)
+		} else if (bytes/packets > 2000)
+			retval = bulk_latency;
+		else if (packets <= 2 && bytes < 512)
 			retval = lowest_latency;
 		break;
 	case bulk_latency: /* 250 usec aka 4000 ints/s */
 		if (bytes > 25000) {
 			if (packets > 35)
 				retval = low_latency;
-		} else {
-			if (bytes < 6000)
-				retval = low_latency;
+		} else if (bytes < 6000) {
+			retval = low_latency;
 		}
 		break;
 	}
@@ -2679,17 +2684,20 @@ static void e1000_set_itr(struct e1000_a
 	                            adapter->tx_itr,
 	                            adapter->total_tx_packets,
 	                            adapter->total_tx_bytes);
+	/* conservative mode (itr 3) eliminates the lowest_latency setting */
+	if (adapter->itr_setting == 3 && adapter->tx_itr == lowest_latency)
+		adapter->tx_itr = low_latency;
+
 	adapter->rx_itr = e1000_update_itr(adapter,
 	                            adapter->rx_itr,
 	                            adapter->total_rx_packets,
 	                            adapter->total_rx_bytes);
+	/* conservative mode (itr 3) eliminates the lowest_latency setting */
+	if (adapter->itr_setting == 3 && adapter->rx_itr == lowest_latency)
+		adapter->rx_itr = low_latency;
 
 	current_itr = max(adapter->rx_itr, adapter->tx_itr);
 
-	/* conservative mode eliminates the lowest_latency setting */
-	if (current_itr == lowest_latency && (adapter->itr_setting == 3))
-		current_itr = low_latency;
-
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
 	case lowest_latency:
@@ -3868,11 +3876,11 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			cleaned = (i == eop);
 
 			if (cleaned) {
-				/* this packet count is wrong for TSO but has a
-				 * tendency to make dynamic ITR change more
-				 * towards bulk */
+				struct sk_buff *skb = buffer_info->skb;
+				unsigned int segs = skb_shinfo(skb)->gso_segs;
+				total_tx_packets += segs;
 				total_tx_packets++;
-				total_tx_bytes += buffer_info->skb->len;
+				total_tx_bytes += skb->len;
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;

