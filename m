From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 06/11] enic: bug fix: included MAC drops in
	rx_dropped netstat
Date: Thu, 03 Sep 2009 20:02:19 -0700
Message-ID: <20090904030219.5047.40334.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6507 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932740AbZIDDCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:16 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: included MAC drops in rx_dropped netstat

Bug fix: included MAC drops in rx_dropped netstat.  Also track Rx trunctations
stat at the MAC

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    1 +
 drivers/net/enic/enic_main.c |   11 ++++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index cfe94b2..f7c5b33 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -99,6 +99,7 @@ struct enic {
 	____cacheline_aligned struct vnic_rq rq[1];
 	unsigned int rq_count;
 	int (*rq_alloc_buf)(struct vnic_rq *rq);
+	u64 rq_truncated_pkts;
 	u64 rq_bad_fcs;
 	struct napi_struct napi;
 	struct net_lro_mgr lro_mgr;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 8d54deb..139c380 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -737,8 +737,9 @@ static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 	net_stats->rx_bytes = stats->rx.rx_bytes_ok;
 	net_stats->rx_errors = stats->rx.rx_errors;
 	net_stats->multicast = stats->rx.rx_multicast_frames_ok;
+	net_stats->rx_over_errors = enic->rq_truncated_pkts;
 	net_stats->rx_crc_errors = enic->rq_bad_fcs;
-	net_stats->rx_dropped = stats->rx.rx_no_bufs;
+	net_stats->rx_dropped = stats->rx.rx_no_bufs + stats->rx.rx_drop;
 
 	return net_stats;
 }
@@ -1028,8 +1029,12 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 	if (packet_error) {
 
-		if (bytes_written > 0 && !fcs_ok)
-			enic->rq_bad_fcs++;
+		if (!fcs_ok) {
+			if (bytes_written > 0)
+				enic->rq_bad_fcs++;
+			else if (bytes_written == 0)
+				enic->rq_truncated_pkts++;
+		}
 
 		dev_kfree_skb_any(skb);
 

