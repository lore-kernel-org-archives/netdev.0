From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/9] qlcnic: fix eswitch stats
Date: Mon,  4 Oct 2010 06:45:30 -0700
Message-ID: <1286199938-17367-3-git-send-email-amit.salecha@qlogic.com>
References: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45747 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755750Ab0JDNpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 09:45:44 -0400
In-Reply-To: <1286199938-17367-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the counters are not implemented in fw.
Fw return NOT AVAILABLE VALUE as (0xffffffffffffffff).
Adding these counters, result in invalid value.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h     |   12 ++++++++++++
 drivers/net/qlcnic/qlcnic_ctx.c |   31 ++++++++++++++++++++++---------
 2 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 714ddf4..4667463 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1169,6 +1169,18 @@ struct qlcnic_esw_func_cfg {
 #define QLCNIC_STATS_ESWITCH		2
 #define QLCNIC_QUERY_RX_COUNTER		0
 #define QLCNIC_QUERY_TX_COUNTER		1
+#define QLCNIC_ESW_STATS_NOT_AVAIL	0xffffffffffffffffULL
+
+#define QLCNIC_ADD_ESW_STATS(VAL1, VAL2)\
+do {	\
+	if (((VAL1) == QLCNIC_ESW_STATS_NOT_AVAIL) && \
+	    ((VAL2) != QLCNIC_ESW_STATS_NOT_AVAIL)) \
+		(VAL1) = (VAL2); \
+	else if (((VAL1) != QLCNIC_ESW_STATS_NOT_AVAIL) && \
+		 ((VAL2) != QLCNIC_ESW_STATS_NOT_AVAIL)) \
+			(VAL1) += (VAL2); \
+} while (0)
+
 struct __qlcnic_esw_statistics {
 	__le16 context_id;
 	__le16 version;
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 95a821e..a4c4d09 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -1016,7 +1016,14 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 	if (adapter->npars == NULL)
 		return -EIO;
 
-	memset(esw_stats, 0, sizeof(struct __qlcnic_esw_statistics));
+	memset(esw_stats, 0, sizeof(u64));
+	esw_stats->unicast_frames = QLCNIC_ESW_STATS_NOT_AVAIL;
+	esw_stats->multicast_frames = QLCNIC_ESW_STATS_NOT_AVAIL;
+	esw_stats->broadcast_frames = QLCNIC_ESW_STATS_NOT_AVAIL;
+	esw_stats->dropped_frames = QLCNIC_ESW_STATS_NOT_AVAIL;
+	esw_stats->errors = QLCNIC_ESW_STATS_NOT_AVAIL;
+	esw_stats->local_frames = QLCNIC_ESW_STATS_NOT_AVAIL;
+	esw_stats->numbytes = QLCNIC_ESW_STATS_NOT_AVAIL;
 	esw_stats->context_id = eswitch;
 
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
@@ -1029,14 +1036,20 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 
 		esw_stats->size = port_stats.size;
 		esw_stats->version = port_stats.version;
-		esw_stats->unicast_frames += port_stats.unicast_frames;
-		esw_stats->multicast_frames += port_stats.multicast_frames;
-		esw_stats->broadcast_frames += port_stats.broadcast_frames;
-		esw_stats->dropped_frames += port_stats.dropped_frames;
-		esw_stats->errors += port_stats.errors;
-		esw_stats->local_frames += port_stats.local_frames;
-		esw_stats->numbytes += port_stats.numbytes;
-
+		QLCNIC_ADD_ESW_STATS(esw_stats->unicast_frames,
+						port_stats.unicast_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->multicast_frames,
+						port_stats.multicast_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->broadcast_frames,
+						port_stats.broadcast_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->dropped_frames,
+						port_stats.dropped_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->errors,
+						port_stats.errors);
+		QLCNIC_ADD_ESW_STATS(esw_stats->local_frames,
+						port_stats.local_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->numbytes,
+						port_stats.numbytes);
 		ret = 0;
 	}
 	return ret;
-- 
1.6.0.2

