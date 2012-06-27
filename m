From: annie.li@oracle.com
Subject: [Xen-devel] [PATCH 1/1] xen/netback: only non-freed SKB is queued into tx_queue
Date: Wed, 27 Jun 2012 18:46:58 +0800
Message-ID: <1340794018-17274-1-git-send-email-annie.li@oracle.com>
Cc: kurt.hackel@oracle.com, annie.li@oracle.com,
	Annie Li <Annie.li@oracle.com>
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	davem@davemloft.net, Ian.Campbell@citrix.com,
	konrad.wilk@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:45296 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756858Ab2F0Ksf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 06:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Annie Li <Annie.li@oracle.com>

After SKB is queued into tx_queue, it will be freed if request_gop is NULL.
However, no dequeue action is called in this situation, it is likely that
tx_queue constains freed SKB. This patch should fix this issue, and it is
based on 3.5.0-rc4+.

This issue is found through code inspection, no bug is seen with it currently.
I run netperf test for several hours, and no network regression was found.

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netback/netback.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f4a6fca..682633b 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1363,8 +1363,6 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 					     INVALID_PENDING_IDX);
 		}
 
-		__skb_queue_tail(&netbk->tx_queue, skb);
-
 		netbk->pending_cons++;
 
 		request_gop = xen_netbk_get_requests(netbk, vif,
@@ -1376,6 +1374,8 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		}
 		gop = request_gop;
 
+		__skb_queue_tail(&netbk->tx_queue, skb);
+
 		vif->tx.req_cons = idx;
 		xen_netbk_check_rx_xenvif(vif);
 
-- 
1.7.6.5
