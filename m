From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 03/10] cxgb4vf: fix bug in Generic Receive Offload
Date: Wed, 10 Nov 2010 18:04:05 -0800
Message-ID: <1289441052-4925-3-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19092 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211Ab0KKCEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:20 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix botch in Generic Receive Offload (the Packet Gather List Total length
field wasn't being initialized).  Also add ethtool statistics for GRO.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    6 ++++++
 drivers/net/cxgb4vf/sge.c          |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 224b36c..9e9e4f6 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1346,6 +1346,8 @@ struct queue_port_stats {
 	u64 rx_csum;
 	u64 vlan_ex;
 	u64 vlan_ins;
+	u64 lro_pkts;
+	u64 lro_merged;
 };
 
 /*
@@ -1383,6 +1385,8 @@ static const char stats_strings[][ETH_GSTRING_LEN] = {
 	"RxCsumGood        ",
 	"VLANextractions   ",
 	"VLANinsertions    ",
+	"GROPackets        ",
+	"GROMerged         ",
 };
 
 /*
@@ -1432,6 +1436,8 @@ static void collect_sge_port_stats(const struct adapter *adapter,
 		stats->rx_csum += rxq->stats.rx_cso;
 		stats->vlan_ex += rxq->stats.vlan_ex;
 		stats->vlan_ins += txq->vlan_ins;
+		stats->lro_pkts += rxq->stats.lro_pkts;
+		stats->lro_merged += rxq->stats.lro_merged;
 	}
 }
 
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index d791adb..1767bda 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1682,6 +1682,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
 				}
 				len = RSPD_LEN(len);
 			}
+			gl.tot_len = len;
 
 			/*
 			 * Gather packet fragments.
-- 
1.7.0.4

