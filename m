From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH net-next 2/4] enic: record all bad FCS errs as frame errors
Date: Mon, 09 Feb 2009 16:57:17 -0800
Message-ID: <20090210005717.24315.53750.stgit@palito_client100.nuovasystems.com>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:47391 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbZBJA5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 19:57:17 -0500
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-1.cisco.com (8.12.11/8.12.11) with ESMTP id n1A0vH22024364
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 16:57:17 -0800
Received: from palito_client100.nuovasystems.com (savbu-palito-client100.cisco.com [10.193.70.13])
	by sj-core-2.cisco.com (8.13.8/8.13.8) with ESMTP id n1A0vHwZ000939
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:57:17 GMT
In-Reply-To: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: record all bad FCS errs as frame errors

Report all bad FCS errs as frames errs.  This includes frames with bad FCS on wire detected by MAC and frames which may be truncated due to ingress FIFO overruns.  No longer print a driver msg on bad FCS err.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    1 +
 drivers/net/enic/enic_main.c |   10 +++-------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 86b8c15..c26cea0 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -97,6 +97,7 @@ struct enic {
 	____cacheline_aligned struct vnic_rq rq[1];
 	unsigned int rq_count;
 	int (*rq_alloc_buf)(struct vnic_rq *rq);
+	u64 rq_bad_fcs;
 	struct napi_struct napi;
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_desc[ENIC_LRO_MAX_DESC];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 35fc9ea..3ba5f54 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -688,7 +688,7 @@ static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 	net_stats->rx_bytes = stats->rx.rx_bytes_ok;
 	net_stats->rx_errors = stats->rx.rx_errors;
 	net_stats->multicast = stats->rx.rx_multicast_frames_ok;
-	net_stats->rx_crc_errors = stats->rx.rx_crc_errors;
+	net_stats->rx_crc_errors = enic->rq_bad_fcs;
 	net_stats->rx_dropped = stats->rx.rx_no_bufs;
 
 	return net_stats;
@@ -933,12 +933,8 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 	if (packet_error) {
 
-		if (bytes_written > 0 && !fcs_ok) {
-			if (net_ratelimit())
-				printk(KERN_ERR PFX
-					"%s: packet error: bad FCS\n",
-					netdev->name);
-		}
+		if (bytes_written > 0 && !fcs_ok)
+			enic->rq_bad_fcs++;
 
 		dev_kfree_skb_any(skb);
 

