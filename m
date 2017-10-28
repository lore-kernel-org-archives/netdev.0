From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] forcedeth: Use common error handling code in two functions
Date: Sat, 28 Oct 2017 18:23:09 +0200
Message-ID: <bf6da649-44e9-4a3b-8cfd-2603b826257f@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:54561 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751189AbdJ1QX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 12:23:27 -0400
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 18:15:44 +0200

Add a jump target so that a bit of exception handling can be better reused
at the end of these functions.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 42 ++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index a235e8881af9..08dc2e8e5878 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2827,10 +2827,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 				if (unlikely(flags & NV_RX_ERROR)) {
 					if ((flags & NV_RX_ERROR_MASK) == NV_RX_ERROR4) {
 						len = nv_getlen(dev, skb->data, len);
-						if (len < 0) {
-							dev_kfree_skb(skb);
-							goto next_pkt;
-						}
+						if (len < 0)
+							goto next_free_skb;
 					}
 					/* framing errors are soft errors */
 					else if ((flags & NV_RX_ERROR_MASK) == NV_RX_FRAMINGERR) {
@@ -2844,13 +2842,12 @@ static int nv_rx_process(struct net_device *dev, int limit)
 							np->stat_rx_missed_errors++;
 							u64_stats_update_end(&np->swstats_rx_syncp);
 						}
-						dev_kfree_skb(skb);
-						goto next_pkt;
+
+						goto next_free_skb;
 					}
 				}
 			} else {
-				dev_kfree_skb(skb);
-				goto next_pkt;
+				goto next_free_skb;
 			}
 		} else {
 			if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
@@ -2858,10 +2855,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 				if (unlikely(flags & NV_RX2_ERROR)) {
 					if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_ERROR4) {
 						len = nv_getlen(dev, skb->data, len);
-						if (len < 0) {
-							dev_kfree_skb(skb);
-							goto next_pkt;
-						}
+						if (len < 0)
+							goto next_free_skb;
 					}
 					/* framing errors are soft errors */
 					else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
@@ -2870,16 +2865,14 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					}
 					/* the rest are hard errors */
 					else {
-						dev_kfree_skb(skb);
-						goto next_pkt;
+						goto next_free_skb;
 					}
 				}
 				if (((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_TCP) || /*ip and tcp */
 				    ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_UDP))   /*ip and udp */
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
-				dev_kfree_skb(skb);
-				goto next_pkt;
+				goto next_free_skb;
 			}
 		}
 		/* got a valid packet - forward it to the network core */
@@ -2900,6 +2893,10 @@ static int nv_rx_process(struct net_device *dev, int limit)
 	}
 
 	return rx_work;
+
+next_free_skb:
+	dev_kfree_skb(skb);
+	goto next_pkt;
 }
 
 static int nv_rx_process_optimized(struct net_device *dev, int limit)
@@ -2932,10 +2929,8 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			if (unlikely(flags & NV_RX2_ERROR)) {
 				if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_ERROR4) {
 					len = nv_getlen(dev, skb->data, len);
-					if (len < 0) {
-						dev_kfree_skb(skb);
-						goto next_pkt;
-					}
+					if (len < 0)
+						goto next_free_skb;
 				}
 				/* framing errors are soft errors */
 				else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
@@ -2944,8 +2939,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				}
 				/* the rest are hard errors */
 				else {
-					dev_kfree_skb(skb);
-					goto next_pkt;
+					goto next_free_skb;
 				}
 			}
 
@@ -2989,6 +2983,10 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 	}
 
 	return rx_work;
+
+next_free_skb:
+	dev_kfree_skb(skb);
+	goto next_pkt;
 }
 
 static void set_bufsize(struct net_device *dev)
-- 
2.14.3
