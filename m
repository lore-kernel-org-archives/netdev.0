From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 05/22] e1000: dynamic itr code fixes
Date: Fri, 08 Dec 2006 15:02:55 -0800
Message-ID: <20061208230255.30109.93522.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4381 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761247AbWLHWw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:52:59 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The dynamic interrupt rate control patches omitted proper counting
for jumbo's and TSO. We also & out the lower bits of a user-provided
hardcoded itr setting beccause they are used for control.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c  |   52 ++++++++++++++++++++++++++-------------
 drivers/net/e1000/e1000_param.c |    4 ++-
 2 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index fae30c7..f39b244 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2635,29 +2635,38 @@ static unsigned int e1000_update_itr(str
 	if (packets == 0)
 		goto update_itr_done;
 
-
 	switch (itr_setting) {
 	case lowest_latency:
-		if ((packets < 5) && (bytes > 512))
+		/* handle TSO and jumbo frames */
+		if (bytes/packets > 8000)
+			retval = bulk_latency;
+		else if ((packets < 5) && (bytes > 512)) {
 			retval = low_latency;
+		}
 		break;
 	case low_latency:  /* 50 usec aka 20000 ints/s */
 		if (bytes > 10000) {
-			if ((packets < 10) ||
-			     ((bytes/packets) > 1200))
+			/* this if handles the TSO accounting */
+			if (bytes/packets > 8000) {
 				retval = bulk_latency;
-			else if ((packets > 35))
+			} else if ((packets < 10) || ((bytes/packets) > 1200)) {
+				retval = bulk_latency;
+			} else if ((packets > 35)) {
 				retval = lowest_latency;
-		} else if (packets <= 2 && bytes < 512)
+			}
+		} else if (bytes/packets > 2000) {
+			retval = bulk_latency;
+		} else if (packets <= 2 && bytes < 512) {
 			retval = lowest_latency;
+		}
 		break;
 	case bulk_latency: /* 250 usec aka 4000 ints/s */
 		if (bytes > 25000) {
-			if (packets > 35)
-				retval = low_latency;
-		} else {
-			if (bytes < 6000)
+			if (packets > 35) {
 				retval = low_latency;
+			}
+		} else if (bytes < 6000) {
+			retval = low_latency;
 		}
 		break;
 	}
@@ -2686,17 +2695,20 @@ static void e1000_set_itr(struct e1000_a
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
@@ -3875,11 +3887,15 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			cleaned = (i == eop);
 
 			if (cleaned) {
-				/* this packet count is wrong for TSO but has a
-				 * tendency to make dynamic ITR change more
-				 * towards bulk */
+				struct sk_buff *skb = buffer_info->skb;
+#ifdef NETIF_F_TSO
+				unsigned int segs = skb_shinfo(skb)->gso_segs;
+				if (segs)
+					total_tx_packets += segs;
+#endif
+
 				total_tx_packets++;
-				total_tx_bytes += buffer_info->skb->len;
+				total_tx_bytes += skb->len;
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index cbfcd7f..cf2a279 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -487,7 +487,9 @@ e1000_check_options(struct e1000_adapter
 				e1000_validate_option(&adapter->itr, &opt,
 				        adapter);
 				/* save the setting, because the dynamic bits change itr */
-				adapter->itr_setting = adapter->itr;
+				/* clear the lower two bits because they are
+				 * used as control */
+				adapter->itr_setting = adapter->itr & ~3;
 				break;
 			}
 		} else {



---
Auke Kok <auke-jan.h.kok@intel.com>
