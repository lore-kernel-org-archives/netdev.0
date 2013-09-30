From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] xen-netfront: convert to GRO API
Date: Mon, 30 Sep 2013 13:46:34 +0100
Message-ID: <1380545194-13419-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xen.org>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Anirban Chakraborty <abchak@juniper.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:34907 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754079Ab3I3Mqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Sep 2013 08:46:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anirban was seeing netfront received MTU size packets, which downgraded
throughput. The following patch makes netfront use GRO API which
improves throughput for that case.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Anirban Chakraborty <abchak@juniper.net>
Cc: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Konrad Wilk <konrad.wilk@oracle.com>
---
 drivers/net/xen-netfront.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 36808bf..dd1011e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -952,7 +952,7 @@ static int handle_incoming_queue(struct net_device *dev,
 		u64_stats_update_end(&stats->syncp);
 
 		/* Pass it up. */
-		netif_receive_skb(skb);
+		napi_gro_receive(&np->napi, skb);
 	}
 
 	return packets_dropped;
@@ -1051,6 +1051,8 @@ err:
 	if (work_done < budget) {
 		int more_to_do = 0;
 
+		napi_gro_flush(napi, false);
+
 		local_irq_save(flags);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
-- 
1.7.10.4
